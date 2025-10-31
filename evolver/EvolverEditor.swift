
class EvolverEditor : SingleDocSynthEditor {
    
  var channel: Int {
    let ch = patch(forPath: [.global])?[[.channel]] ?? 0
    return ch > 0 ? ch - 1 : 0
  }

  private static let _patchMap: [SynthPath:Sysexible.Type] = {
    var map: [SynthPath:Sysexible.Type] = [
      [.global] : EvolverGlobalPatch.self,
      [.patch] : EvolverVoicePatch.self,
      [.wave] : EvolverWavePatch.self,
      [.bank, .wave] : EvolverWaveBank.self,
    ]
    (0..<4).forEach { map[[.bank, .i($0)]] = EvolverVoiceBank.self }
    return map
  }()
  class var patchMap: [SynthPath:Sysexible.Type] { return _patchMap }
  
  var sysexHeader: Data {
    return Data([0xf0, 0x01, 0x20, 0x01])
  }
  
  var waveNumber: UInt8 = 0
  
  override func fetchCommands(forPath path: SynthPath) -> [RxMidi.FetchCommand]? {
    switch path[0] {
    case .global:
      return [.request(sysexHeader + Data([0x0e, 0xf7]))]
    case .patch:
      return [.request(sysexHeader + Data([0x06, 0xf7]))]
    case .wave:
      return [.request(sysexHeader + Data([0x0b, waveNumber, 0xf7]))]
    case .bank:
      if let bank = path.i(1) {
        return [RxMidi.FetchCommand]((0..<128).map {
          // request patch, then name data
          return [.request(sysexHeader + Data([0x05, UInt8(bank), $0, 0xf7])),
                  .wait(0.01),
                  .request(sysexHeader + Data([0x10, UInt8(bank), $0, 0xf7])),
                  .wait(0.01)]
        }.joined())
      }
      else {
        // wave bank
        return [RxMidi.FetchCommand]((0..<32).map {
          return .request(sysexHeader + Data([0x0b, $0 + 96, 0xf7]))
        })
      }
    default:
      return nil
    }
  }
  
  override func changePatch(forPath path: SynthPath, _ change: PatchChange, transmit: Bool) {
    super.changePatch(forPath: path, change, transmit: transmit)
    guard path == [.wave],
          case let .paramsChange(changes) = change,
          let wave = changes[[.number]] else { return }
    waveNumber = UInt8(wave)
  }


  override func midiOuts() -> [Observable<[Data]?>] {
    var midiOuts = [Observable<[Data]?>]()

    midiOuts.append(globalOut(input: patchStateManager([.global])!.typedChangesOutput()))
    midiOuts.append(voiceOut(input: patchStateManager([.patch])!.typedChangesOutput()))

    midiOuts.append(GenericMidiOut.pushOnlyPatch(input: patchStateManager([.wave])!.typedChangesOutput() as Observable<(PatchChange,EvolverWavePatch, Bool)>, patchTransform: {
      // TODO: sending twice on push.. why?
      
      // only send if wave # is 96 or higher
      guard self.waveNumber >= 96 else { return nil }
      let data = $0.sysexData(location: Int(self.waveNumber) - 96)
      return [data]
    }))
    
    (0..<4).forEach { bank in
      midiOuts.append(GenericMidiOut.partiallyUpdatableBank(input: bankStateManager([.bank, .i(bank)])!.output, patchTransform: {
        guard let b = $0 as? EvolverVoicePatch else { return nil }
        return b.sysexData(bank: bank, location: $1)
      }))
    }

    midiOuts.append(GenericMidiOut.partiallyUpdatableBank(input: bankStateManager([.bank, .wave])!.output, patchTransform: {
      guard let b = $0 as? EvolverWavePatch else { return nil }
      return [b.sysexData(location: $1)]
    }))

    return midiOuts
  }

  override func midiChannel(forPath path: SynthPath) -> Int {
    return channel
  }

  
}

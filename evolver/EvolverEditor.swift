
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
  
  required init(baseURL: URL) {
    var migrationMap: [SynthPath:String] = [
      [.global] : "Global.syx",
      [.patch] : "Patch.syx",
      [.wave] : "Wave.syx",
      [.bank, .wave] : "Wave Bank.syx",
    ]
    (0..<4).forEach { migrationMap[[.bank, .i($0)]] = "Bank \($0 + 1).syx" }

    super.init(baseURL: baseURL, sysexMap: type(of: self).patchMap, migrationMap: migrationMap)
  }

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

  override func bankPaths(forPatchType patchType: SysexPatch.Type) -> [SynthPath] {
    switch patchType {
    case is EvolverVoicePatch.Type:
      return [[.bank, .i(0)],[.bank, .i(1)],[.bank, .i(2)], [.bank, .i(3)]]
    case is EvolverWavePatch.Type:
      return [[.bank, .wave]]
    default:
      return []
    }
  }
  
  override func bankTitles(forPatchType patchType: SysexPatch.Type) -> [String] {
    switch patchType {
    case is EvolverVoicePatch.Type:
      return ["Bank 1","Bank 2","Bank 3", "Bank 4"]
    case is EvolverWavePatch.Type:
      return ["Wave Bank"]
    default:
      return []
    }
  }
  
}

extension EvolverEditor {
  
  /// Transform <change,patch> into MIDI out data
  func globalOut(input: Observable<(PatchChange, EvolverGlobalPatch, Bool)>) -> Observable<[Data]?> {

    return GenericMidiOut.patchChange(throttle: .milliseconds(300), input: input, paramTransform: { (patch, path, value) -> [Data]? in
      guard let param = type(of: patch).params[path] else { return nil }

      let lNib = patch.bytes[param.byte] & 0x0f
      let mNib = (patch.bytes[param.byte] >> 4) & 0x0f
      return [Data([0xf0, 0x01, 0x20, 0x01, 0x09, UInt8(param.byte), lNib, mNib, 0xf7])]

    }, patchTransform: { (patch) -> [Data]? in
      return [patch.fileData()]
      
    })

  }
  
  /// Transform <channel, patchChange, patch> into MIDI out data
  func voiceOut(input: Observable<(PatchChange, EvolverVoicePatch, Bool)>) -> Observable<[Data]?> {
    
    return GenericMidiOut.patchChange(throttle: .milliseconds(200), input: input, paramTransform: { (patch, path, value) -> [Data]? in
      guard let param = type(of: patch).params[path] else { return nil }

      if path.first == .seq && path.last != .dest {
        guard let seq = path.i(1), let step = path.i(3) else { return nil }
        let lNib = UInt8(value) & 0x0f
        let mNib = (UInt8(value) >> 4) & 0x0f
        return [Data([0xf0, 0x01, 0x20, 0x01, 0x08, UInt8(seq * 16 + step), lNib, mNib, 0xf7])]
      }
      else {
        // use byte instead of passed value bc some params are 2-in-1-byte
        let lNib = patch.bytes[param.byte] & 0x0f
        let mNib = (patch.bytes[param.byte] >> 4) & 0x0f
        return [Data([0xf0, 0x01, 0x20, 0x01, 0x01, UInt8(param.byte), lNib, mNib, 0xf7])]
      }

    }, patchTransform: { (patch) -> [Data]? in
      return [patch.fileData()]

    })
  }
  
}


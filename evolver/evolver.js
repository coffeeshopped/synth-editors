const Global = require('./evolver_global.js')
const Voice = require('./evolver_voice.js')
const Wave = require('./evolver_wave.js')

const editor = {
  name: "",
  trussMap: ([
    ["global", Global.patchTruss],
    ['patch', Voice.patchTruss],
    ['wave', Wave.patchTruss],
    ['bank/wave', Wave.bankTruss],
  ]).concat(
    (4).map(i => [['bank', i], Voice.bankTruss])
  ),
  fetchTransforms: [
  ],

  midiOuts: [
  ],
  
  midiChannels: [
    ["voice", "basic"],
  ],
  slotTransforms: [
  ],
}



class EvolverEditor : SingleDocSynthEditor {
    
  var channel: Int {
    let ch = patch(forPath: "global")?["channel"] ?? 0
    return ch > 0 ? ch - 1 : 0
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
    guard path == "wave",
          case let .paramsChange(changes) = change,
          let wave = changes["number"] else { return }
    waveNumber = UInt8(wave)
  }


  override func midiOuts() -> [Observable<[Data]?>] {
    var midiOuts = [Observable<[Data]?>]()

    midiOuts.append(globalOut(input: patchStateManager("global")!.typedChangesOutput()))
    midiOuts.append(voiceOut(input: patchStateManager("patch")!.typedChangesOutput()))

    midiOuts.append(GenericMidiOut.pushOnlyPatch(input: patchStateManager("wave")!.typedChangesOutput() as Observable<(PatchChange,EvolverWavePatch, Bool)>, patchTransform: {
      // TODO: sending twice on push.. why?
      
      // only send if wave # is 96 or higher
      guard self.waveNumber >= 96 else { return nil }
      let data = $0.sysexData(location: Int(self.waveNumber) - 96)
      return [data]
    }))
    
    (0..<4).forEach { bank in
      midiOuts.append(GenericMidiOut.partiallyUpdatableBank(input: bankStateManager("bank/bank")!.output, patchTransform: {
        guard let b = $0 as? EvolverVoicePatch else { return nil }
        return b.sysexData(bank: bank, location: $1)
      }))
    }

    midiOuts.append(GenericMidiOut.partiallyUpdatableBank(input: bankStateManager("bank/wave")!.output, patchTransform: {
      guard let b = $0 as? EvolverWavePatch else { return nil }
      return [b.sysexData(location: $1)]
    }))

    return midiOuts
  }

  override func midiChannel(forPath path: SynthPath) -> Int {
    return channel
  }

  
}

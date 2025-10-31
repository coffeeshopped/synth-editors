const Voice = require('./ms2k_voice.js')

const editor = {
  name: "",
  trussMap: [
    ["global", "channel"],
    ['patch', Voice.patchTruss],
    ['bank', Voice.bankTruss],
  ],
  fetchTransforms: [
  ],

  midiOuts: [
  ],
  
  midiChannels: [
    ["patch", "basic"],
  ],
  slotTransforms: [
  ],
}



class MS2KEditor : SingleDocSynthEditor {
    
  override func fetchCommands(forPath path: SynthPath) -> [RxMidi.FetchCommand]? {
    switch path[0] {
    case .patch:
      return `request(Data([0xf0/${0x42}/${0x30 + UInt8(channel)}/${0x58}/${0x10}/${0xf7}`)),
              .send(editModeSysex())]
    case .bank:
      return `request(Data([0xf0/${0x42}/${0x30 + UInt8(channel)}/${0x58}/${0x1c}/${0xf7}`))]
    default:
      return nil
    }
  }
  
  private func editModeSysex() -> Data {
    // sysex for entering edit mode
    return Data([0xf0, 0x42, 0x30 + UInt8(channel), 0x58, 0x4e, 0x01, 0x00, 0xf7])
  }
  
  override func midiOuts() -> [Observable<[Data]?>] {
    var midiOuts = [Observable<[Data]?>]()
    
    midiOuts.append(voice(input: patchStateManager("patch")!.typedChangesOutput()))

    midiOuts.append(bank(input: bankStateManager("bank")!.typedChangesOutput()))

    return midiOuts
  }
    
}



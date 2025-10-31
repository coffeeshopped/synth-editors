  static let sysexHeader: [UInt8] = [0xf0, 0x00, 0x20, 0x33, 0x01]

static func commandHeader(deviceId: UInt8, functionId: UInt8) -> [UInt8] {
  return sysexHeader + [deviceId, functionId]
}


const editor = {
  name: "",
  trussMap: ([
    ["global", Global.patchTruss],
    ["patch", Voice.patchTruss],
    ["multi", EmbeddedMulti.patchTruss],
    ["multi/bank", EmbeddedMulti.bankTruss],
  ]).concat(
    (4).map(i => [["bank", i] = Voice.bankTruss }
  ),
  fetchTransforms: [
  ],

  midiOuts: [
    ([
      ["global", Global.patchTransform],
      ["patch", Voice.patchTransform],
      ["multi", EmbeddedMulti.patchTransform],
      ["multi/bank", EmbeddedMulti.bankTransform],
    ]).concat(
      (4).map(i => [["bank", i] = Voice.bankTransform(i) }
    ),
  ],
  
  midiChannels: [
    ["voice", "basic"],
  ],
  slotTransforms: [
  ],
}



class VirusTIEditor : SingleDocSynthEditor, VirusEditor {

  private func embMultiFetchRequest(_ bank: UInt8) -> [RxMidi.FetchCommand] {
    // get multi, then parts
    return [fetchRequest([0x31, bank, 0x00])] + (0..<16).map { fetchRequest([0x30, bank, $0]) }
  }
  
  // Time between send sysex msgs (for push)
  override var sendInterval: TimeInterval { return 0.2 }

  private let delayBetweenFetches: TimeInterval = 0.1
  
  override func fetchCommands(forPath path: SynthPath) -> [RxMidi.FetchCommand]? {
    switch path {
    case "patch":
      return [fetchRequest([0x30, 0x00, 0x40])]
    case "multi":
      return embMultiFetchRequest(0)
    case "bank/0", "bank/1", "bank/2", "bank/3":
      guard let bankIndex = path.i(1) else { return nil }
      return (0..<128).map { fetchRequest([0x30, UInt8(bankIndex + 1), $0]) }
    case "multi/bank":
      return Array((0..<16).map { embMultiFetchRequest($0 + 32) }.joined())
    default:
      return nil
    }
  }
    
  override func bankIndexLabelBlock(forPath path: SynthPath) -> ((Int) -> String)? {
    if let bankIndex = path.i(1) {
      return {
        let b = ["A", "B", "C", "D"][bankIndex]
        return "\(b)\($0)"
      }
    }
    else {
      return { "\($0)" }
    }
  }

}

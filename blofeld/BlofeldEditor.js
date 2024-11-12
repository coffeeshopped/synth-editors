const Blofeld = require('./Blofeld.js')

// MARK: MIDI I/O

const patchFetch = bytes => ['truss', Blofeld.sysex(deviceId, bytes)]

static func bankFetch(_ bytes: @escaping (UInt8) -> [UInt8]) -> FetchTransform {
  .bankTruss(deviceId, { sysex($0, bytes(UInt8($1))) }, waitInterval: 100)
}

const truss = {
  name: "Blofeld", 
  trussMap: trussMap,
  
  fetchTransforms, [
    "global" : patchFetch([0x04]),
    "voice" : patchFetch([0x00, 0x7f, 0x00]),
    "perf" : patchFetch([0x01, 0x7f, 0x00]),
    "perf/bank" : bankFetch({ [0x01, 0x00, $0, 0x7f] }),
  ]
  <<< 16.dict { ["part/$0" : patchFetch([0x00, 0x7f, UInt8($0)])] }
  <<< 8.dict { b in ["bank/b" : bankFetch({ [0x00, UInt8(b), $0, 0x7f] })] },
  
  compositeFetchWaitInterval: 100,
  compositeSendWaitInterval: 300

  extraParamOuts: 8.map {
    ("perf", .bankNames("bank/$0", "patch/name/$0"))
  },

  midiOuts: midiOuts,
  
  midiChannels: [
    "voice" : .basic(map: channelMap),
  ] <<< 16.dict {
    let partTransform: EditorValueTransform = .value("perf", "part/$0/channel")
    return ["part/$0" : .custom([rawChannel, partTransform], { values in
      let partCh = values[partTransform] ?? 0
      let rawCh = values[rawChannel] ?? 0
      return perfChannelMap(partCh: partCh, rawCh: rawCh)
    })]
  }
  
  slotTransforms: 8.dict { b in
    ["bank/b" : .user({ "\(Voice.bankLetter(b))\($0 + 1)" })]
  }
}
        
  const trussMap: [(SynthPath, any SysexTruss)] = [
    ("global", Global.patchTruss),
    ("voice", Voice.patchTruss),
    ("perf", MultiMode.patchTruss),
    ("perf/bank", MultiMode.bankTruss),
    ("backup", backupTruss),
    ("extra/perf", MultiMode.refTruss),
  ]
  + 16.map { ("part/$0", Voice.patchTruss) }
  + 8.map { ("bank/$0", Voice.bankTruss) }



  const midiOuts: [(path: SynthPath, transform: MidiTransform)] =
    [
      ("global", wholePatchTransform(400, dumpByte: Global.dumpByte, bank: 0, location: 0)),
      ("voice", Voice.patchChange(30, location: 0)),
      ("perf", wholePatchTransform(400, dumpByte: MultiMode.dumpByte, bank: 0x7f, location: 0)),
      ("perf/bank", bankPatch(dumpByte: MultiMode.dumpByte, bank: 0, interval: 200))
    ]
    + 16.map {
      ("part/$0", Voice.patchChange(30, location: UInt8($0)))
    }
    + 8.map {
      ("bank/$0", bankPatch(dumpByte: Voice.dumpByte, bank: $0, interval: 100))
    }
  
  private static func channelMap(_ raw: Int) -> Int { raw == 0 ? 0 : raw - 1 }
  
  private static func perfChannelMap(partCh: Int, rawCh: Int) -> Int {
    switch partCh {
    case 0: // 0 is Global
      return channelMap(rawCh)
    case 1: // 1 is omni
      return 0
    default: // else channel - 2
      return partCh - 2
    }
  }
  
  private const rawChannel: EditorValueTransform = .value("global", "channel")
  
//  private let partPaths: [SynthPath] = (0..<16).map { "part/$0" }
//  private let multiPath: SynthPath = "perf"
//
//  override func onSave(toBankPath bankPath: SynthPath, index: Int, fromPatchPath patchPath: SynthPath) {
//    // side effect: if saving from a part editor, update the multi
//    if partPaths.contains(patchPath) {
//      guard let bankIndex = bankPath.i(1) else { return }
//      let params: [SynthPath:Int] = [
//        patchPath + "bank" : bankIndex,
//        patchPath + "sound" : index
//      ]
//      changePatch(forPath: "perf", .paramsChange(params), transmit: true)
//    }
//  }
  
  // As far as I can tell and have experimented, the Blofeld cannot receive individual parameter changes for Multis.
      
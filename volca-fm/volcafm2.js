const editor = {
  name: "",
  trussMap: [
    ["global", Global.patchTruss],
    ["patch", Voice.patchTruss],
    ["perf", Sequence.patchTruss],
    ["bank", Voice.bankTruss],
    ["perf/bank", Sequence.bankTruss],
    ["backup", backupTruss],
    ["extra/perf", Sequence.refTruss],
  ],
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




public enum VolcaFM2 {
  
  static func sysexHeader(_ channel: UInt8) -> [UInt8] {
    [0xf0, 0x42, 0x30 + channel, 0x00, 0x01, 0x2f]
  }

  static func sysex(_ channel: Int, _ cmdBytes: [UInt8]) -> [UInt8] {
    sysexHeader(UInt8(channel)) + cmdBytes + [0xf7]
  }

  static func sysex(_ editor: SynthEditor, _ cmdBytes: [UInt8]) -> [UInt8] {
    let channel = UInt8(editor.basicChannel())
    return sysexHeader(channel) + cmdBytes + [0xf7]
  }


}


extension VolcaFM2 {

 enum Editor {

   static let truss: BasicEditorTruss = {
     var t = BasicEditorTruss("Volca FM2", truss: trussMap)
     t.fetchTransforms = [
       "patch" : patchFetch([0x12]),
       "perf" : patchFetch([0x10]),
       "bank" : bankFetch({ [0x1e, UInt8($0)] }),
       "perf/bank" : bankFetch({ [0x1c, UInt8($0)] }),
     ]
     t.extraParamOuts = [
       ("perf", .bankNames("bank", "patch/name"))
     ]
     
     t.midiOuts = [
       ("patch", Voice.patchTransform),
       ("perf", Sequence.patchTransform),
       ("bank", Voice.patchWerk.bankTransform()),
       ("perf/bank", Sequence.patchWerk.bankTransform()),
     ]
     
     t.midiChannels = [
       "patch" : .basic(),
       "perf" : .basic(),
     ]
     
     t.slotTransforms = [
       "bank" : .user({ "Int-\($0)"})
     ]
     return t
   }()
       
   static func patchFetch(_ bytes: [UInt8]) -> FetchTransform {
     .truss(.basicChannel, { sysex($0, bytes) })
   }

   static func bankFetch(_ bytes: @escaping (UInt8) -> [UInt8]) -> FetchTransform {
     .bankTruss(.basicChannel, { sysex($0, bytes(UInt8($1))) })
   }
   
 }

 
}

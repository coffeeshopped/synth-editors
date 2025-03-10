
//extension VolcaFM2 {
//
//  enum Editor {
//
//    static let truss: BasicEditorTruss = {
//      var t = BasicEditorTruss("Volca FM2", truss: trussMap)
//      t.fetchTransforms = [
//        [.patch] : patchFetch([0x12]),
//        [.perf] : patchFetch([0x10]),
//        [.bank] : bankFetch({ [0x1e, UInt8($0)] }),
//        [.perf, .bank] : bankFetch({ [0x1c, UInt8($0)] }),
//      ]
//      t.extraParamOuts = [
//        ([.perf], .bankNames([.bank], [.patch, .name]))
//      ]
//      
//      t.midiOuts = [
//        ([.patch], Voice.patchTransform),
//        ([.perf], Sequence.patchTransform),
//        ([.bank], Voice.patchWerk.bankTransform()),
//        ([.perf, .bank], Sequence.patchWerk.bankTransform()),
//      ]
//      
//      t.midiChannels = [
//        [.patch] : .basic(),
//        [.perf] : .basic(),
//      ]
//      
//      t.slotTransforms = [
//        [.bank] : .user({ "Int-\($0)"})
//      ]
//      return t
//    }()
//
//    static let trussMap: [(SynthPath, any SysexTruss)] = [
//      ([.global], Global.patchTruss),
//      ([.patch], Voice.patchTruss),
//      ([.perf], Sequence.patchTruss),
//      ([.bank], Voice.bankTruss),
//      ([.perf, .bank], Sequence.bankTruss),
//      ([.backup], backupTruss),
//      ([.extra, .perf], Sequence.refTruss),
//    ]
//        
//    static func patchFetch(_ bytes: [UInt8]) -> FetchTransform {
//      .truss(.basicChannel, { sysex($0, bytes) })
//    }
//
//    static func bankFetch(_ bytes: @escaping (UInt8) -> [UInt8]) -> FetchTransform {
//      .bankTruss(.basicChannel, { sysex($0, bytes(UInt8($1))) })
//    }
//    
//  }
//
//  
//}

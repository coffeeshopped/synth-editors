
extension FB01 {
  
  enum Editor {
    
    static let truss: BasicEditorTruss = {
      var t = BasicEditorTruss("FB01", truss: sysexMap)
      
      t.fetchTransforms = [
        [.perf] : fetch([0x20, 0x01, 0x00]),
        [.bank, .perf] : fetch([0x20, 0x03, 0x00]),
      ]
      <<< 8.dict { [[.part, .i($0)] : fetch([0x20 + UInt8($0 + 8), 0x0, 0x0])] }
      <<< 2.dict { [[.bank, .i($0)] : fetch([0x20, 0x00, UInt8($0)])] }
      
      t.extraParamOuts = 2.map {
        // options are names only, no numbers. Don't remember how it's presented on FB-01
        ([.perf], .bankNames([.bank, .i($0)], [.patch, .name, .i($0)], nameBlock: { $1 }))
      }

      t.midiOuts = 8.map {
        ([.part, .i($0)], Voice.patchChangeTransform(instrument: $0))
      }
      + 2.map { ([.bank, .i($0)], Voice.Bank.transform(bank: $0)) }
      + [
        ([.perf], Perf.patchChangeTransform()),
        ([.bank, .perf], Perf.Bank.transform())
     ]

      t.midiChannels = [[.global] : .patch([.global], [.channel])] <<< 8.dict {
        [[.part, .i($0)] : .patch([.perf], [.part, .i($0), .channel])]
      }
      
      return t
    }()
    
    static let sysexMap: [(SynthPath, any SysexTruss)] = [
      ([.global], ChannelSettingsTruss),
      ([.perf], Perf.patchTruss),
      ([.bank, .perf], Perf.Bank.bankTruss),
    ]
    + 8.map { ([.part, .i($0)], Voice.patchTruss) }
    + 2.map { ([.bank, .i($0)], Voice.Bank.bankTruss) }

    // MARK: MIDI I/O
    
    static func fetch(_ bytes: [UInt8]) -> FetchTransform {
      .truss(.value([.global], [.channel]), { [0xf0, 0x43, 0x75, UInt8($0)] + bytes + [0xf7] })
    }


//    override func onSave(toBankPath bankPath: SynthPath, index: Int, fromPatchPath patchPath: SynthPath) {
//      // side effect: if saving from a part editor, update the multi
//      guard patchPath.first == .part,
//        let bankIndex = bankPath.i(1) else { return }
//      let params: [SynthPath:Int] = [
//        patchPath + [.bank] : bankIndex,
//        patchPath + [.pgm] : index
//      ]
//      changePatch(forPath: [.perf], MakeParamsChange(params), transmit: true)
//    }
      
  }
  
}


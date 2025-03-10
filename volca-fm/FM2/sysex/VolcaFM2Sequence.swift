
//extension VolcaFM2 {
//
//  enum Sequence {
//    
//    static let patchWerk = PatchWerk(storeHeaderByte: 0x4c, tempHeaderByte: 0x40, bodyDataCount: 1920, patchFileDataCount: 2203)
//
//    static let patchTruss = SinglePatchTruss("Sequence", patchWerk.bodyDataCount, params: parms.params(), initFile: "volca-fm2-sequence-init", defaultName: "Sequence", createFileData: patchWerk.createFileData, parseBodyData: patchWerk.parseNative, isValidSizeDataAndFetch: patchWerk.isValidNative)
//        
//    static let sendPatch: EditorValueTransform = .value([.global], [.send, .patch])
//    static let latestPatch: EditorValueTransform = .patch([.patch])
//    
//    static let patchTransform: MidiTransform = .singleDict(throttle: 500, [sendPatch, latestPatch], .wholePatch({ editorVal, bodyData in
//      guard let send = editorVal[sendPatch] as? Int,
//            let patch = editorVal[latestPatch] as? SingleSysexPatch else { return [] }
//      
//      let seqMsg = patchWerk.sysexData(bodyData, channel: 0)
//      if send == 1 {
//        return [
//          (seqMsg, 50),
//          (Voice.patchWerk.sysexData(patch.bodyData, channel: 0), 0),
//        ]
//      }
//      else {
//        return [(seqMsg, 0)]
//      }
//    }))
//      
//    static let bankTruss: SingleBankTruss = {
//      let patchCount: Int = 16
//      
//      let createFileData = SingleBankTrussWerk.createFileDataWithLocationMap({ patchWerk.sysexData($0, channel: 0, location: UInt8($1)).bytes() })
//      let parseBodyData = SingleBankTrussWerk.sortAndParseBodyDataWithLocationIndex(7, patchTruss: patchTruss, patchCount: patchCount)
//      return SingleBankTruss(patchTruss: patchTruss, patchCount: patchCount, createFileData: createFileData, parseBodyData: parseBodyData, validBundle: SingleBankTruss.Core.validBundle(counts: [patchCount * 2204]))
//    }()
//
//    static let bipolarFormat = ParamOptions(isoF: Miso.switcher([
//      .int(0, -63),
//      .range(1...127, Miso.a(-64))
//    ]))
//    static let format99 = ParamOptions(isoF: Miso.lerp(in: 0...127, out: 0...99) >>> Miso.round())
//    static let arpTypeFormat = ParamOptions(isoS: Miso.lerp(in: 127, out: 0...Float(arpTypeOptions.count - 1)) >>> Miso.round() >>> Miso.options(arpTypeOptions))
//    static let arpDivFormat = ParamOptions(isoS: Miso.lerp(in: 127, out: 0...Float(arpDivOptions.count - 1)) >>> Miso.round() >>> Miso.options(arpDivOptions))
//    static let algoFormat = ParamOptions(isoF: Miso.lerp(in: 0...127, out: 1...32) >>> Miso.round())
//    static let octaveFormat = ParamOptions(isoF: Miso.lerp(in: 0...127, out: -2...2) >>> Miso.round())
//    static let noteFormat = ParamOptions(isoF: Miso.lerp(in: 0...127, out: -36...36) >>> Miso.round())
//
//    static let motionSections: [(SynthPath, ParamOptions?)] = [
//      ([.transpose], noteFormat),
//      ([.velo], bipolarFormat),
//      ([.algo], algoFormat),
//      ([.mod, .attack], bipolarFormat),
//      ([.mod, .decay], bipolarFormat),
//      ([.carrier, .attack], bipolarFormat),
//      ([.carrier, .decay], bipolarFormat),
//      ([.lfo, .rate], format99),
//      ([.lfo, .pitch], format99),
//      ([.arp, .type], arpTypeFormat),
//      ([.arp, .divide], arpDivFormat),
//      ([.chorus], nil),
//      ([.reverb], nil),
//    ]
//    
//    static let parms: [Parm] = {
//      var p: [Parm] = 8.flatMap { [
//        .p([.i($0), .on], 6, bit: $0),
//        .p([.i($0 + 8), .on], 7, bit: $0),
//        .p([.i($0), .active], 12, bit: $0),
//        .p([.i($0 + 8), .active], 13, bit: $0),
//      ] }
//      <<< [
//        .p([.pgm], 9, .max(63)),
//      ]
//
//      let motions = motionSections.map { $0.0 }
//      
//      p += .prefixes(motions, bx: 2, block: { _ in
//        [
//          .p([.on], 16, bit: 0),
//        ] +
//        8.flatMap { [
//          .p([.i($0)], 42, bit: $0),
//          .p([.i($0 + 8)], 43, bit: $0),
//        ] }
//      })
//      
//      p += [
//        .p([.motion, .on], 68, bit: 0),
//        .p([.smooth], 68, bit: 1),
//        .p([.warp, .active], 68, bit: 2),
//        .p([.tempo], 68, bits: 3...4, .opts(["1/1", "1/2", "1/4"])),
//        .p([.mono], 68, bit: 5),
//        .p([.unison], 68, bit: 6),
//        .p([.chorus, .on], 68, bit: 7),
//
//        .p([.arp, .on], 69, bit: 0),
//        .p([.transpose, .note], 69, bit: 1),
//        .p([.reverb, .on], 69, bit: 2),
//
//        .p([.arp, .type], 70, .opts(arpTypeOptions)),
//        .p([.arp, .divide], 71, .opts(arpDivOptions)),
//        .p([.chorus, .depth], 72),
//        .p([.reverb, .depth], 73),
//      ]
//
//      p += 16.flatMap { step in
//        let off = 80 + 112 * step
//        var q = [Parm]()
//        q += 6.flatMap { n in
//          .offset(b: off, block: {
//            .prefix([.note, .i(n)]) { [
//              .p([.pitch, .i(step)], n * 2, .iso(pitchIso)),
//              .p([.velo, .i(step)], 18 + n),
//              .p([.gate, .i(step)], 24 + n, bits: 0...6, .iso(gateIso)),
//              .p([.trigger, .i(step)], 24 + n, bit: 7),
//            ] }
//          })
//        }
//        q += .prefixes(motions, bx: 5, block: { _ in
//          5.map { .p([.step, .i(step), .data, .i($0)], off + 43 + $0) }
//        })
//        return q
//      }
//
//      p += 16.map {
//        .p([.motion, .transpose, .i($0)], 1872 + $0, .max(1))
//      }
//      
//      return p
//    }()
//    
//    
//    static let arpTypeOptions = ["Off", "Rise 1", "Rise 2", "Rise 3", "Fall 1", "Fall 2", "Fall 3", "Rand 1", "Rand 2", "Rand 3"]
//    static let arpDivOptions = ["1/12", "1/8", "1/4", "1/3", "1/2", "2/3", "1/1", "3/2", "2/1", "3/1", "4/1"]
//    
//    static let pitchIso = Miso.noteName(zeroNote: "C-2")
//    
//    static let gateIso = Miso.switcher([
//      .range(0...72, Miso.m(100/72) >>> Miso.round() >>> Miso.unitFormat("%")),
//      .range(73...126, Miso.str("100%%")),
//      .int(127, "Tie")
//    ])
//    
//    
//    static let refTruss: FullRefTruss = {
//      let refPath: SynthPath = [.perf]
//      
//      let trussMap: [(SynthPath, any SysexTruss)] = [
//        ([.perf], Sequence.patchTruss),
//        ([.patch], Voice.patchTruss),
//      ]
//
//      let pathForData: FullRefTruss.PathForDataFn = {
//        guard $0.count > 6 else { return nil }
//        switch $0[6] {
//        case 0x40:
//          return [.perf]
//        case 0x42:
//          return [.patch]
//        default:
//          return nil
//        }
//      }
//
//      let createFileData = FullRefTruss.defaultCreateFileData(trussMap: trussMap)
//
//      let isos: FullRefTruss.Isos = [
//        [.patch] : .basic(path: [], location: [.pgm], pathMap: [[.bank]])
//      ]
//      
//      return FullRefTruss("Full Sequence", trussMap: trussMap, refPath: refPath, isos: isos, sections: [
//        ("Sequence", [[.perf]]),
//        ("Patch", [[.patch]]),
//      ], initFile: "volca-fm2-full-perf-init", createFileData: createFileData, pathForData: pathForData)
//
//    }()
//    
//
//  }
//
//}

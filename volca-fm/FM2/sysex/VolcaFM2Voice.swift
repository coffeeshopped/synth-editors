
////open class TX802VoicePatch : YamahaMultiPatch, Algorithmic, BankablePatch, VoicePatch {
////
////  open class var bankType: SysexPatchBank.Type { return TX802VoiceBank.self }
////
////  private static let _subpatchTypes: [SynthPath : SysexPatch.Type] = [
////    [.voice] : DX7Patch.self,
////    [.extra] : TX802ACEDPatch.self,
////    ]
////  open class var subpatchTypes: [SynthPath : SysexPatch.Type] { return _subpatchTypes }
////
////  public var ySubpatches: [SynthPath:YamahaPatch]
////
//extension VolcaFM2 {
//
//  enum Voice {
//    
//    static let patchFileDataCount = 168
//    static let patchWerk = PatchWerk(storeHeaderByte: 0x4e, tempHeaderByte: 0x42, bodyDataCount: 140, patchFileDataCount: patchFileDataCount)
//    
//    static let patchTruss = SinglePatchTruss("Voice", patchWerk.bodyDataCount, namePackIso: .basic(118..<128), params: params, initFile: "volca-fm2-voice-init", createFileData: patchWerk.createFileData, parseBodyData: parseBodyData, isValidSizeDataAndFetch: {
//        patchWerk.isValidNative(fileSize: $0) || tx802isValid(fileSize: $0)
//    })
//    
//    public static func tx802isValid(fileSize: Int) -> Bool {
//      // 163: A DX7 (mkI) patch
//      return fileSize == 220 || fileSize == 163
//    }
//    
//    static func parseBodyData(d: [UInt8]) throws -> [UInt8] {
//      if patchWerk.isValidNative(fileSize: d.count) {
//        return patchWerk.parseNative(bodyData: d)
//      }
//      else {
//        let data = Data(d)
//        let dxPatch = TX802VoicePatch(data: data).ySubpatches[[.voice]] as! DX7Patch
//        return [UInt8](dxPatch.bankSysexData()) + [
//          64, 64, 64, 64, // 0 for attacks/decays
//          4, // 0 for transpose
//          1, 1, 1, 1, 1, 1, // all ops on
//          0, // reserved TODO: should it be some other value?
//        ]
//      }
//    }
//    
//    static let sendPatch: EditorValueTransform = .value([.global], [.send, .patch])
//    static let voicePatch: EditorValueTransform = .patch([.patch])
//    static let patchTransform: MidiTransform = .singleDict(throttle: 300, [.basicChannel, sendPatch], .wholePatch({ editorVal, bodyData in
//      let seqMsg = patchWerk.sysexData(bodyData, channel: 0)
//      let sendPatch = editorVal[sendPatch] as? Int ?? 0
//      if sendPatch == 1,
//         let voiceData = (editorVal[voicePatch] as? AnySysexible)?.anyBodyData.data() as? [UInt8] {
//        return [
//          (seqMsg, 50),
//          (patchWerk.sysexData(voiceData, channel: 0), 0),
//        ]
//      }
//      else {
//        return [(seqMsg, 0)]
//      }
//    }))
//
//    static func algorithms() -> [DXAlgorithm] { DX7Patch.algorithms() }
//    
////    static func randomize(patch: ByteBackedSysexPatch) {
////      patch.randomizeAllParams()
////
////      patch[[.partial, .i(0), .mute]] = 1
////
////      // find the output ops and set level 4 to 0
////      let algos = algorithms()
////      let algoIndex = patch[[.algo]] ?? 0
////
////      let algo = algos[algoIndex]
////
////      for outputId in algo.outputOps {
////        let op: SynthPath = [.op, .i(outputId)]
////        patch[op + [.level, .i(0)]] = 90+(0...9).random()!
////        patch[op + [.rate, .i(0)]] = 80+(0...19).random()!
////        patch[op + [.level, .i(2)]] = 80+(0...19).random()!
////        patch[op + [.level, .i(3)]] = 0
////        patch[op + [.rate, .i(3)]] = 30+(0...69).random()!
////        patch[op + [.level]] = 90+(0...9).random()!
////        patch[op + [.level, .scale, .left, .depth]] = (0...9).random()!
////        patch[op + [.level, .scale, .right, .depth]] = (0...9).random()!
////      }
////
////      // for one out, make it harmonic and louder
////      let randomOut = algo.outputOps[(0..<algo.outputOps.count).random()!]
////      let op: SynthPath = [.op, .i(randomOut)]
////      patch[op + [.osc, .mode]] = 0
////      patch[op + [.fine]] = 0
////      patch[op + [.coarse]] = 1
////
////      // flat pitch env
////      for i in 0..<4 {
////        patch[[.pitch, .env, .level, .i(i)]] = 50
////      }
////
////      // all ops on
////      for op in 0..<6 { patch[[.op, .i(op), .on]] = 1 }
////    }
//    
//    
//    static let bankPatchCount = 64
//    static let bankFileDataCount = bankPatchCount * (patchFileDataCount + 1)
//
//    static let bankTruss: SingleBankTruss = {
//
//      let createFileData = SingleBankTrussWerk.createFileDataWithLocationMap({
//        patchWerk.sysexData($0, channel: 0, location: UInt8($1)).bytes()
//      })
//
//      let parseBodyData: SingleBankTruss.Core.ParseBodyDataFn = {
//        if isValidNativeBank(fileSize: $0.count) {
//          return try SingleBankTrussWerk.singleSortedByteArrays(sysexData: $0, count: bankPatchCount, locationByteIndex: 7).map { try patchTruss.parseBodyData($0) }
//        }
//        else {
//          let halfBank = try TX802VoiceBank(data: Data($0)).patches.map {
//            try patchTruss.parseBodyData(($0.ySubpatches[[.voice]] as! DX7Patch).fileData().bytes())
//          }
//          let emptyBank = try (0..<32).map { _ in
//            try patchTruss.createInitBodyData()
//          }
//          return halfBank + emptyBank
//        }
//      }
//      
//      return SingleBankTruss(patchTruss: patchTruss, patchCount: bankPatchCount, fileDataCount: bankFileDataCount, createFileData: createFileData, parseBodyData: parseBodyData, validBundle: SingleBankTruss.Core.validBundle(validSize: {
//        isValidNativeBank(fileSize: $0) || TX802VoiceBank.isValid(fileSize: $0)
//      }))
//    }()
//    
//    static func isValidNativeBank(fileSize: Int) -> Bool { fileSize == bankFileDataCount }
//    
//    
//    static let params: [SynthPath : Param] = {
//      var p = [SynthPath:Param]()
//
//      for op in stride(from: 5, through: 0, by: -1) {
//        let opOffset = 17 * (5 - op)
//        let pre: SynthPath = [.op, .i(op)]
//        for i in 0..<4 {
//          p[pre + [.rate, .i(i)]] = RangeParam(byte: opOffset+i, maxVal: 99)
//          p[pre + [.level, .i(i)]] = RangeParam(byte: opOffset+(4+i), maxVal: 99)
//        }
//        p[pre + [.level, .scale, .brk, .pt]] = OptionsParam(byte: opOffset+8, options: breakOptions)
//        p[pre + [.level, .scale, .left, .depth]] = RangeParam(byte: opOffset+9, maxVal: 99)
//        p[pre + [.level, .scale, .right, .depth]] = RangeParam(byte: opOffset+10, maxVal: 99)
//        p[pre + [.level, .scale, .left, .curve]] = OptionsParam(byte: opOffset + 11, bits: 0...1, options: curveOptions)
//        p[pre + [.level, .scale, .right, .curve]] = OptionsParam(byte: opOffset + 11, bits: 2...3, options: curveOptions)
//        p[pre + [.rate, .scale]] = RangeParam(byte: opOffset+12, bits: 0...2, maxVal: 7)
//        p[pre + [.amp, .mod]] = RangeParam(byte: opOffset+13, bits: 0...1, maxVal: 3)
//        p[pre + [.velo]] = RangeParam(byte: opOffset+13, bits: 2...4, maxVal: 7)
//        p[pre + [.level]] = RangeParam(byte: opOffset+14, maxVal: 99)
//        p[pre + [.osc, .mode]] = RangeParam(byte: opOffset+15, bit: 0)
//        p[pre + [.coarse]] = RangeParam(byte: opOffset+15, bits: 1...6, maxVal: 31)
//        p[pre + [.fine]] = RangeParam(byte: opOffset+16, maxVal: 99)
//        p[pre + [.detune]] = RangeParam(byte: opOffset+12, bits: 3...6, maxVal: 14, displayOffset: -7)
//      }
//      
//      for i in 0..<4 {
//        p[[.pitch, .env, .rate, .i(i)]] = RangeParam(byte: 102+i, maxVal: 99)
//        p[[.pitch, .env, .level, .i(i)]] = RangeParam(byte: 106+i, maxVal: 99)
//      }
//      
//      p[[.algo]] = RangeParam(byte: 110, maxVal: 31, displayOffset: 1)
//      p[[.feedback]] = RangeParam(byte: 111, bits: 0...2, maxVal: 7)
//      p[[.osc, .sync]] = RangeParam(byte: 111, bit: 3)
//      p[[.lfo, .speed]] = RangeParam(byte: 112, maxVal: 99)
//      p[[.lfo, .delay]] = RangeParam(byte: 113, maxVal: 99)
//      p[[.lfo, .pitch, .mod, .depth]] = RangeParam(byte: 114, maxVal: 99)
//      p[[.lfo, .amp, .mod, .depth]] = RangeParam(byte: 115, maxVal: 99)
//      p[[.lfo, .sync]] = RangeParam(byte: 116, bit: 0)
//      p[[.lfo, .wave]] = OptionsParam(byte: 116, bits: 1...3, options: lfoWaveOptions)
//      p[[.lfo, .pitch, .mod]] = RangeParam(byte: 116, bits: 4...6, maxVal: 7)
//      p[[.transpose]] = OptionsParam(byte: 117, options: transposeOptions)
//      
//      return p <<< [
//        [.mod, .attack] : MisoParam.make(byte: 128, iso: adMiso),
//        [.mod, .decay] : MisoParam.make(byte: 129, iso: adMiso),
//        [.carrier, .attack] : MisoParam.make(byte: 130, iso: adMiso),
//        [.carrier, .decay] : MisoParam.make(byte: 131, iso: adMiso),
//        [.octave] : RangeParam(byte: 132, range: 2...6, displayOffset: -4),
//        [.op, .i(5), .on] : RangeParam(byte: 133, maxVal: 1),
//        [.op, .i(4), .on] : RangeParam(byte: 134, maxVal: 1),
//        [.op, .i(3), .on] : RangeParam(byte: 135, maxVal: 1),
//        [.op, .i(2), .on] : RangeParam(byte: 136, maxVal: 1),
//        [.op, .i(1), .on] : RangeParam(byte: 137, maxVal: 1),
//        [.op, .i(0), .on] : RangeParam(byte: 138, maxVal: 1),
//      ]
//    }()
//    
//    static let adMiso = Miso.switcher([
//      .int(0, -63),
//      .range(1...127, Miso.a(-64))
//    ])
//    
//    static let curveOptions = OptionsParam.makeOptions(["- Lin","- Exp","+ Exp","+ Lin"])
//    
//    static let lfoWaveOptions = OptionsParam.makeOptions(["Triangle","Saw Down","Saw Up","Square","Sine","Sample/Hold"])
//    
//    static let breakOptions = OptionsParam.makeOptions(["A-1", "A#-1", "B-1", "C0", "C#0", "D0", "D#0", "E0", "F0", "F#0", "G0", "G#0", "A0", "A#0", "B0", "C1", "C#1", "D1", "D#1", "E1", "F1", "F#1", "G1", "G#1", "A1", "A#1", "B1", "C2", "C#2", "D2", "D#2", "E2", "F2", "F#2", "G2", "G#2", "A2", "A#2", "B2", "C3", "C#3", "D3", "D#3", "E3", "F3", "F#3", "G3", "G#3", "A3", "A#3", "B3", "C4", "C#4", "D4", "D#4", "E4", "F4", "F#4", "G4", "G#4", "A4", "A#4", "B4", "C5", "C#5", "D5", "D#5", "E5", "F5", "F#5", "G5", "G#5", "A5", "A#5", "B5", "C6", "C#6", "D6", "D#6", "E6", "F6", "F#6", "G6", "G#6", "A6", "A#6", "B6", "C7", "C#7", "D7", "D#7", "E7", "F7", "F#7", "G7", "G#7", "A7", "A#7", "B7", "C8"])
//
//    static let transposeOptions = OptionsParam.makeOptions(["C1", "C#1", "D1", "D#1", "E1", "F1", "F#1", "G1", "G#1", "A1", "A#1", "B1", "C2", "C#2", "D2", "D#2", "E2", "F2", "F#2", "G2", "G#2", "A2", "A#2", "B2", "C3", "C#3", "D3", "D#3", "E3", "F3", "F#3", "G3", "G#3", "A3", "A#3", "B3", "C4", "C#4", "D4", "D#4", "E4", "F4", "F#4", "G4", "G#4", "A4", "A#4", "B4", "C5"])
//
//  }
//
//}

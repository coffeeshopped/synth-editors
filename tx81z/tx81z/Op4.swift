
/// Umbrella utils for TX81Z, DX100, DX21, DX11
public enum Op4 {
  
  static let synth = SynthWerk("Op4")

  static let sysexChannel: EditorValueTransform = .value([.global], [.channel])
  
  static let algorithms: [DXAlgorithm] = Op4.VCED.algorithms()

  static func editorTrussSetup(_ t: inout BasicEditorTruss) {
    t.extraParamOuts = extraParamOuts
    t.extraValues = extraValues
    t.commandEffects = commandEffects
    t.midiChannels = midiChannels
  }

  // used by TX81Z VCED, Perf.
  static func bankSysexData(bodyData: SingleBankTruss.BodyData, channel: Int, patchCount: Int, patchWerk: PatchWerk, cmdBytes: [UInt8], headerString: String) -> [UInt8] {
    var patchBytes: [UInt8] = bodyData.flatMap {
      patchWerk.compactTruss!.parse(otherData: $0, otherTruss: patchWerk.truss)
    }
    // pad out to 32 patches
    let remaining = 32 - patchCount
    patchBytes += [UInt8](repeating: 0, count: remaining * patchWerk.compactTruss!.bodyDataCount)

    let patchData = headerString.sysexBytes() + patchBytes
    return Yamaha.sysexData(channel: channel, cmdBytes: cmdBytes, bodyBytes: patchData)
  }

  static let microSysexMap: [(SynthPath, any SysexTruss)] = [
    ([.micro, .octave], Micro.Oct.werk.patchWerk.truss),
    ([.micro, .key], Micro.Full.werk.patchWerk.truss),
  ]
    
  static let midiChannels: [SynthPath:MidiChannelTransform] = [
    [.patch] : .basic(),
    [.micro, .octave] : .basic(),
    [.micro, .key] : .basic(),
  ]
  
  static let extraValues: EditorTrussCore.ExtraValues = [
    [.patch] : 4.dict { [[.voice, .op, .i($0), .on] : 1] },
  ]
  
  // when a new voice patch is pushed or replaced, reset op on values all to 1
  static let commandEffects: [EditorCommandEffect] = [
    .patchPushReplaceChange([.patch], 4.dict {
      [[.voice, .op, .i($0), .on] : 1]
    })
  ]
  
  static func createVoicePatchTruss(_ synth: SynthWerk, map: [(SynthPath, PatchWerk)], initFile: String, validSizes: [Int]) -> MultiPatchTruss {
    MultiPatchTruss(synth.id("voice"), trussMap: map.map { ($0.0, $0.1.truss)}, namePath: [.voice], initFile: initFile, validSizes: validSizes, includeFileDataCount: true)
  }

  static func createVoiceBankTruss(_ patchTruss: MultiPatchTruss, patchCount: Int, initFile: String, map: [(SynthPath, PatchWerk)]) -> MultiBankTruss {
    MultiBankTruss(patchTruss: patchTruss, patchCount: patchCount, initFile: initFile, fileDataCount: 4104, createFileData: {
      voiceBankSysexData(bodyData: $0, channel: 0, map: map)
    }, parseBodyData: {
      MultiBankTruss.compactData(fileData: $0, offset: 6, patchByteCount: 128).map { d in
        map.dict { [$0.0 : $0.1.parse(compactData: d)] }
      }
    })
  }
  
  static func voiceBankSysexData(bodyData: MultiBankTruss.BodyData, channel: Int, map: [(SynthPath, PatchWerk)]) -> [UInt8] {
    
    let patchData: [UInt8] = bodyData.flatMap { d in
      var compactData = [UInt8](repeating: 0, count: 128)
      map.forEach {
        guard let bodyData = d[$0.0] else { return }
        $0.1.transform(bodyData, intoCompact: &compactData)
      }
      return compactData
    }

    return Yamaha.sysexData(channel: channel, cmdBytes: [0x04, 0x20, 0x00], bodyBytes: patchData)
  }
  
  static func patchBankTransform(map: [(SynthPath, PatchWerk)]) -> MidiTransform {
    .multi(throttle: 0, sysexChannel, .wholeBank({ editorVal, bodyData in
      [(.sysex(voiceBankSysexData(bodyData: bodyData, channel: editorVal, map: map)), 100)]
    }))
  }
  
  /// For TX81z. Same as VCED only except send full patch (VCED and ACED) when there are multiple changes
  static func patchChangeTransform(truss: MultiPatchTruss, map: [(SynthPath, PatchWerk)]) -> MidiTransform {
    return .multiDict(throttle: 100, [sysexChannel] + opOns, .patch(param: { editorVal, bodyData, parm, value in
      let isOpOn = parm.path.first == .voice && parm.path.last == .on
      let opOnParam: Parm = .p([], 93)
      let parm = isOpOn ? opOnParam : parm
      let b = parm.b!
      guard let subpatch = bodyData[[parm.path[0]]],
            let channel = editorVal[Op4.sysexChannel] as? Int else { return nil }
      let data: [UInt8]
      switch parm.path[0] {
      case .voice:
        let value = isOpOn ? opOnByte(editorVal, newOp: parm.path.i(2) ?? 0, value: value) : subpatch[b]
        data = VCED.patchWerk.paramData(channel: channel, cmdBytes: [UInt8(b), value])
      case .extra:
        let value = subpatch[b]
        data = ACED.patchWerk.paramData(channel: channel, cmdBytes: [UInt8(b), value])
      case .aftertouch:
        // offset byte by 23 to get param address
        let value = subpatch[b]
        data = ACED.patchWerk.paramData(channel: channel, cmdBytes: [UInt8(b + 23), value])
      default:
        return nil
      }
      return [(.sysex(data), 0)]
      
    }, patch: { editorVal, bodyData in
      guard let channel = editorVal[sysexChannel] as? Int else { return nil }
      return try map.compactMap {
        guard let b = bodyData[$0.0] else { return nil }
        return try $0.1.patchTransform(channel, b)
      }.reduce([], +)

    }, name: { editorVal, bodyData, path, name in
      guard let b = bodyData[[.voice]],
            let channel = editorVal[sysexChannel] as? Int else { return nil }
      return try VCED.patchWerk.nameTransform(channel, b, path, name)

    }))
    
  }
  
  static let opOns: [EditorValueTransform] = 4.map { .extra([.patch], [.voice, .op, .i($0), .on]) }

  // calc based on stored editor values and new incoming value
  static func opOnByte(_ dict: [EditorValueTransform:Any], newOp: Int, value: Int) -> UInt8 {
    opOns.enumerated().map { i, transform in
      let isOn = i == newOp ? value > 0 : dict[transform] as? Int == 1
      guard isOn else { return 0 }
      return 1 << ((4 - 1) - i)
    }.reduce(0, +)
  }


//  static func createVoiceBankTruss(patchCount: Int, patchWerk: PatchWerk, initFile: String = "") -> SingleBankTruss {
//    SingleBankTruss(patchTruss: patchWerk.truss, patchCount: patchCount, initFile: initFile, fileDataCount: 4104, createFileData: {
//      voiceBankSysexData(bodyData: $0, channel: 0, patchCount: patchCount, patchWerk: patchWerk)
//    }, parseBodyData: {
//      YamahaCompactTrussWerk.compactParseBodyData($0, parseOffset: 6, patchTruss: patchWerk.truss, compactPatchTruss: patchWerk.compactTruss!, patchCount: patchCount)
//    })
//  }
  
//  static func voiceBankSysexData(bodyData: SingleBankTruss.BodyData, channel: Int, patchCount: Int, patchWerk: PatchWerk) -> [UInt8] {
//    bankSysexData(bodyData: bodyData, channel: channel, patchCount: patchCount, patchWerk: patchWerk, cmdBytes: [0x04, 0x20, 0x00], headerString: "")
//  }


  
  
  static func fetch(_ cmdBytes: [UInt8]) -> FetchTransform {
    .truss(sysexChannel, { Yamaha.fetchRequestBytes(channel: $0, cmdBytes: cmdBytes) })
  }

  static func fetch(header: String) -> FetchTransform {
    fetch([0x7e] + ("LM  " + header).sysexBytes())
  }

  static let extraParamOuts: [(path: SynthPath, transform: ParamOutTransform)] = [
    ([.perf], .bankNames([.bank], [.patch, .name], nameBlock: {
      "I\($0 + 1). \($1)"
    }))
  ]
    
  static func freqRatio(fixedMode: Bool, range: Int, coarse: Int, fine: Int) -> String {
    if fixedMode {
      let toShift = ((coarse & 0x3C) << 2) + fine + (coarse < 4 ? 8 : 0)
      let freq = Float(toShift << range)
      return String(format:"%.4g", freq)
    }
    else {
      let r = freqRatioLookup[coarse * 16 + fine]
      return String(format:"%.2f", r)
    }
  }

  static func coarseRatio(_ value: Int) -> Float {
    value >= coarseRatioLookup.count ? 0 : coarseRatioLookup[value]
  }

  static let coarseRatioLookup: [Float] = [ 0.5, 0.71, 0.78, 0.87, 1, 1.41, 1.57, 1.73, 2, 2.82, 3, 3.14, 3.46, 4, 4.24, 4.71, 5, 5.19, 5.65, 6, 6.28, 6.92, 7, 7.07, 7.85, 8, 8.48, 8.65, 9, 9.42, 9.89, 10, 10.38, 10.99, 11, 11.3, 12, 12.11, 12.56, 12.72, 13, 13.84, 14, 14.1, 14.13, 15, 15.55, 15.57, 15.7, 16.96, 17.27, 17.3, 18.37, 18.84, 19.03, 19.78, 20.41, 20.76, 21.2, 21.98, 22.49, 23.55, 24.22, 25.95 ]
  
  static let freqRatioLookup: [Float] = [ 0.50, 0.56, 0.62, 0.68, 0.75, 0.81, 0.87, 0.93, 0.93, 0.93, 0.93, 0.93, 0.93, 0.93, 0.93, 0.93, 0.71, 0.79, 0.88, 0.96, 1.05, 1.14, 1.23, 1.32, 1.32, 1.32, 1.32, 1.32, 1.32, 1.32, 1.32, 1.32, 0.78, 0.88, 0.98, 1.07, 1.17, 1.27, 1.37, 1.47, 1.47, 1.47, 1.47, 1.47, 1.47, 1.47, 1.47, 1.47, 0.87, 0.97, 1.08, 1.18, 1.29, 1.40, 1.51, 1.62, 1.47, 1.47, 1.47, 1.47, 1.47, 1.47, 1.47, 1.47, 1.00, 1.06, 1.12, 1.18, 1.25, 1.31, 1.37, 1.43, 1.50, 1.56, 1.62, 1.68, 1.75, 1.81, 1.87, 1.93, 1.41, 1.49, 1.58, 1.67, 1.76, 1.85, 1.93, 2.02, 2.11, 2.20, 2.29, 2.37, 2.46, 2.55, 2.64, 2.73, 1.57, 1.66, 1.76, 1.86, 1.96, 2.06, 2.15, 2.25, 2.35, 2.45, 2.55, 2.64, 2.74, 2.84, 2.94, 3.04, 1.73, 1.83, 1.94, 2.05, 2.16, 2.27, 2.37, 2.48, 2.59, 2.70, 2.81, 2.91, 3.02, 3.13, 3.24, 3.35, 2.00, 2.06, 2.12, 2.18, 2.25, 2.31, 2.37, 2.43, 2.50, 2.56, 2.62, 2.68, 2.75, 2.81, 2.87, 2.93, 2.82, 2.90, 2.99, 3.08, 3.17, 3.26, 3.34, 3.43, 3.52, 3.61, 3.70, 3.78, 3.87, 3.96, 4.05, 4.14, 3.00, 3.06, 3.12, 3.18, 3.25, 3.31, 3.37, 3.43, 3.50, 3.56, 3.62, 3.68, 3.75, 3.81, 3.87, 3.93, 3.14, 3.23, 3.33, 3.43, 3.53, 3.63, 3.72, 3.82, 3.92, 4.02, 4.12, 4.21, 4.31, 4.41, 4.51, 4.61, 3.46, 3.56, 3.67, 3.78, 3.89, 4.00, 4.10, 4.21, 4.32, 4.43, 4.54, 4.64, 4.75, 4.86, 4.97, 5.08, 4.00, 4.06, 4.12, 4.18, 4.25, 4.31, 4.37, 4.43, 4.50, 4.56, 4.62, 4.68, 4.75, 4.81, 4.87, 4.93, 4.24, 4.31, 4.40, 4.49, 4.58, 4.67, 4.75, 4.84, 4.93, 5.02, 5.11, 5.19, 5.28, 5.37, 5.46, 5.55, 4.71, 4.80, 4.90, 5.00, 5.10, 5.20, 5.29, 5.39, 5.49, 5.59, 5.69, 5.78, 5.88, 5.98, 6.08, 6.18, 5.00, 5.06, 5.12, 5.18, 5.25, 5.31, 5.37, 5.43, 5.50, 5.56, 5.62, 5.68, 5.75, 5.81, 5.87, 5.93, 5.19, 5.29, 5.40, 5.51, 5.62, 5.73, 5.83, 5.94, 6.05, 6.16, 6.27, 6.37, 6.48, 6.59, 6.70, 6.81, 5.65, 5.72, 5.81, 5.90, 5.99, 6.08, 6.16, 6.25, 6.34, 6.43, 6.52, 6.60, 6.69, 6.78, 6.87, 6.96, 6.00, 6.06, 6.12, 6.18, 6.25, 6.31, 6.37, 6.43, 6.50, 6.56, 6.62, 6.68, 6.75, 6.81, 6.87, 6.93, 6.28, 6.37, 6.47, 6.57, 6.67, 6.77, 6.86, 6.96, 7.06, 7.16, 7.26, 7.35, 7.45, 7.55, 7.65, 7.75, 6.92, 7.02, 7.13, 7.24, 7.35, 7.46, 7.56, 7.67, 7.78, 7.89, 8.00, 8.10, 8.21, 8.32, 8.43, 8.54, 7.00, 7.06, 7.12, 7.18, 7.25, 7.31, 7.37, 7.43, 7.50, 7.56, 7.62, 7.68, 7.75, 7.81, 7.87, 7.93, 7.07, 7.13, 7.22, 7.31, 7.40, 7.49, 7.57, 7.66, 7.75, 7.84, 7.93, 8.01, 8.10, 8.19, 8.28, 8.37, 7.85, 7.94, 8.04, 8.14, 8.24, 8.34, 8.43, 8.53, 8.63, 8.73, 8.83, 8.92, 9.02, 9.12, 9.22, 9.32, 8.00, 8.06, 8.12, 8.18, 8.25, 8.31, 8.37, 8.43, 8.50, 8.56, 8.62, 8.68, 8.75, 8.81, 8.87, 8.93, 8.48, 8.54, 8.63, 8.72, 8.81, 8.90, 8.98, 9.07, 9.16, 9.25, 9.34, 9.42, 9.51, 9.60, 9.69, 9.78, 8.65, 8.75, 8.86, 8.97, 9.08, 9.19, 9.29, 9.40, 9.51, 9.62, 9.73, 9.83, 9.94, 10.05, 10.16, 10.27, 9.00, 9.06, 9.12, 9.18, 9.25, 9.31, 9.37, 9.43, 9.50, 9.56, 9.62, 9.68, 9.75, 9.81, 9.87, 9.93, 9.42, 9.51, 9.61, 9.71, 9.81, 9.91, 10.00, 10.10, 10.20, 10.30, 10.40, 10.49, 10.59, 10.69, 10.79, 10.89, 9.89, 9.95, 10.04, 10.13, 10.22, 10.31, 10.39, 10.48, 10.57, 10.66, 10.75, 10.83, 10.92, 11.01, 11.10, 11.19, 10.00, 10.06, 10.12, 10.18, 10.25, 10.31, 10.37, 10.43, 10.50, 10.56, 10.62, 10.68, 10.75, 10.81, 10.87, 10.93, 10.38, 10.48, 10.59, 10.70, 10.81, 10.92, 11.02, 11.13, 11.24, 11.35, 11.46, 11.56, 11.67, 11.78, 11.89, 12.00, 10.99, 11.08, 11.18, 11.28, 11.38, 11.48, 11.57, 11.67, 11.77, 11.87, 11.97, 12.06, 12.16, 12.26, 12.36, 12.46, 11.00, 11.06, 11.12, 11.18, 11.25, 11.31, 11.37, 11.43, 11.50, 11.56, 11.62, 11.68, 11.75, 11.81, 11.87, 11.93, 11.30, 11.36, 11.45, 11.54, 11.63, 11.72, 11.80, 11.89, 11.98, 12.07, 12.16, 12.24, 12.33, 12.42, 12.51, 12.60, 12.00, 12.06, 12.12, 12.18, 12.25, 12.31, 12.37, 12.43, 12.50, 12.56, 12.62, 12.68, 12.75, 12.81, 12.87, 12.93, 12.11, 12.21, 12.32, 12.43, 12.54, 12.65, 12.75, 12.86, 12.97, 13.08, 13.19, 13.29, 13.40, 13.51, 13.62, 13.73, 12.56, 12.65, 12.75, 12.85, 12.95, 13.05, 13.14, 13.24, 13.34, 13.44, 13.54, 13.63, 13.73, 13.83, 13.93, 14.03, 12.72, 12.77, 12.86, 12.95, 13.04, 13.13, 13.21, 13.30, 13.39, 13.48, 13.57, 13.65, 13.74, 13.83, 13.92, 14.01, 13.00, 13.06, 13.12, 13.18, 13.25, 13.31, 13.37, 13.43, 13.50, 13.56, 13.62, 13.68, 13.75, 13.81, 13.87, 13.93, 13.84, 13.94, 14.05, 14.16, 14.27, 14.38, 14.48, 14.59, 14.70, 14.81, 14.92, 15.02, 15.13, 15.24, 15.35, 15.46, 14.00, 14.06, 14.12, 14.18, 14.25, 14.31, 14.37, 14.43, 14.50, 14.56, 14.62, 14.68, 14.75, 14.81, 14.87, 14.93, 14.10, 14.18, 14.27, 14.36, 14.45, 14.54, 14.62, 14.71, 14.80, 14.89, 14.98, 15.06, 15.15, 15.24, 15.33, 15.42, 14.13, 14.22, 14.32, 14.42, 14.52, 14.62, 14.71, 14.81, 14.91, 15.01, 15.11, 15.20, 15.30, 15.40, 15.50, 15.60, 15.00, 15.06, 15.12, 15.18, 15.25, 15.31, 15.37, 15.43, 15.50, 15.56, 15.62, 15.68, 15.75, 15.81, 15.87, 15.93, 15.55, 15.59, 15.68, 15.77, 15.86, 15.95, 16.03, 16.12, 16.21, 16.30, 16.39, 16.47, 16.56, 16.65, 16.74, 16.83, 15.57, 15.67, 15.78, 15.89, 16.00, 16.11, 16.21, 16.32, 16.43, 16.54, 16.65, 16.75, 16.86, 16.97, 17.08, 17.19, 15.70, 15.79, 15.89, 15.99, 16.09, 16.19, 16.28, 16.38, 16.48, 16.58, 16.68, 16.77, 16.87, 16.97, 17.07, 17.17, 16.96, 17.00, 17.09, 17.18, 17.27, 17.36, 17.44, 17.53, 17.62, 17.71, 17.80, 17.88, 17.97, 18.06, 18.15, 18.24, 17.27, 17.36, 17.46, 17.56, 17.66, 17.76, 17.85, 17.95, 18.05, 18.15, 18.25, 18.34, 18.44, 18.54, 18.64, 18.74, 17.30, 17.40, 17.51, 17.62, 17.73, 17.84, 17.94, 18.05, 18.16, 18.27, 18.38, 18.48, 18.59, 18.70, 18.81, 18.92, 18.37, 18.41, 18.50, 18.59, 18.68, 18.77, 18.85, 18.94, 19.03, 19.12, 19.21, 19.29, 19.38, 19.47, 19.56, 19.65, 18.84, 18.93, 19.03, 19.13, 19.23, 19.33, 19.42, 19.52, 19.62, 19.72, 19.82, 19.91, 20.01, 20.11, 20.21, 20.31, 19.03, 19.13, 19.24, 19.35, 19.46, 19.57, 19.67, 19.78, 19.89, 20.00, 20.11, 20.21, 20.32, 20.43, 20.54, 20.65, 19.78, 19.82, 19.91, 20.00, 20.09, 20.18, 20.26, 20.35, 20.44, 20.53, 20.62, 20.70, 20.79, 20.88, 20.97, 21.06, 20.41, 20.50, 20.60, 20.70, 20.80, 20.90, 20.99, 21.09, 21.19, 21.29, 21.39, 21.48, 21.58, 21.68, 21.78, 21.88, 20.76, 20.86, 20.97, 21.08, 21.19, 21.30, 21.40, 21.51, 21.62, 21.73, 21.84, 21.94, 22.05, 22.16, 22.27, 22.38, 21.20, 21.23, 21.32, 21.41, 21.50, 21.59, 21.67, 21.76, 21.85, 21.94, 22.03, 22.11, 22.20, 22.29, 22.38, 22.47, 21.98, 22.07, 22.17, 22.27, 22.37, 22.47, 22.56, 22.66, 22.76, 22.86, 22.96, 23.05, 23.15, 23.25, 23.35, 23.45, 22.49, 22.59, 22.70, 22.81, 22.92, 23.03, 23.13, 23.24, 23.35, 23.46, 23.57, 23.67, 23.78, 23.89, 24.00, 24.11, 23.55, 23.64, 23.74, 23.84, 23.94, 24.04, 24.13, 24.23, 24.33, 24.43, 24.53, 24.62, 24.72, 24.82, 24.92, 25.02, 24.22, 24.32, 24.43, 24.54, 24.65, 24.76, 24.86, 24.97, 25.08, 25.19, 25.30, 25.40, 25.51, 25.62, 25.73, 25.84, 25.95, 26.05, 26.16, 26.27, 26.38, 26.49, 26.59, 26.70, 26.81, 26.92, 27.03, 27.13, 27.24, 27.35, 27.46, 27.57 ]
  
  
}

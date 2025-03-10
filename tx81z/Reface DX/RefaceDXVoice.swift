
extension RefaceDX {
  
  enum Voice {
    
    static let trussMap: [(SynthPath, SinglePatchTruss)] = [
      ([.common], Common.patchTruss),
      ([.op, .i(0)], Op.patchTruss),
      ([.op, .i(1)], Op.patchTruss),
      ([.op, .i(2)], Op.patchTruss),
      ([.op, .i(3)], Op.patchTruss),
    ]
    static let patchTruss = MultiPatchTruss("refacedx.voice", trussMap: trussMap, namePath: [.common], initFile: "reface-dx-voice-init", fileDataCount: 241, createFileData: {
      sysexData($0, channel: 0)
    }, parseBodyData: {
      var bodyData = [SynthPath:[UInt8]]()
      try SysexData(data: $0.data()).forEach {
        let bytes = $0.bytes()
        if Common.patchTruss.isValidFileData(bytes) {
          bodyData[[.common]] = try Common.patchTruss.parseBodyData(bytes)
        }
        else if Op.patchTruss.isValidFileData(bytes) {
          let op = Int(bytes[9])
          bodyData[[.op, .i(op)]] = try Op.patchTruss.parseBodyData(bytes)
        }
      }
      
      for (path, truss) in trussMap {
        guard bodyData[path] == nil else { continue }
        bodyData[path] = try truss.createInitBodyData()
      }
      return bodyData
    }, validBundle: nil)
    
    static let bankTruss = MultiBankTruss(patchTruss: patchTruss, patchCount: 32, initFile: "reface-dx-voice-bank-init", createFileData: {
      $0.enumerated().flatMap {
        sysexData($0.element, channel: 0, location: $0.offset).flatMap { $0 }
      }

    }, parseBodyData: {
      // look for a header message
      // if header, then this and next 6 messages (7 total) are patch data.
      var patchData = [UInt8]()
      var inPatch = false
      var patches = [[SynthPath:[UInt8]]]()
      try SysexData(data: $0.data()).forEach { d in
        guard inPatch || (d.count == 13 && d[8] == 0x0e) else { return }
        inPatch = true
        patchData += d.bytes()
        
        if d.count == 13 && d[8] == 0x0f && patchTruss.isValidFileData(patchData) {
          // end of patch
          inPatch = false
          patches += [try patchTruss.parseBodyData(patchData)]
          patchData.removeAll(keepingCapacity: true)
        }
      }
      
      if patches.count < 32 {
        try (0..<(32 - patches.count)).forEach { _ in
          patches += [try patchTruss.createInitBodyData()]
        }
      }
      return patches
    }, validBundle: nil)
    
//    static func location(forData data: Data) -> Int { Int(data[10]) }
    

    
    /// Temp buffer sysex
    static func sysexData(_ bodyData: [SynthPath:[UInt8]], channel: Int) -> [UInt8] {
      Array(tempSysexData(bodyData, channel: channel).joined())
    }
    
    static func tempSysexData(_ bodyData: [SynthPath:[UInt8]], channel: Int) -> [[UInt8]] {
      sysexData(bodyData, channel: channel, address: [0x0f, 0x00])
    }
    
    /// Location should be 0...31
    static func sysexData(_ bodyData: [SynthPath:[UInt8]], channel: Int, location: Int) -> [[UInt8]] {
      sysexData(bodyData, channel: channel, address: [0x00, UInt8(location)])
    }
    
    // address should be 2 bytes
    static func sysexData(_ bodyData: [SynthPath:[UInt8]], channel: Int, address: [UInt8]) -> [[UInt8]] {
      var data = [bulkDumpData(channel: channel, byteCount: 4, address: [0x0e] + address, bodyBytes: [])]
      data += [Common.sysexData(bodyData[[.common]] ?? [], channel: channel)]
      data += 4.map {
        Op.sysexData(bodyData[[.op, .i($0)]] ?? [], channel: channel, op: $0)
      }
      data += [bulkDumpData(channel: channel, byteCount: 4, address: [0x0f] + address, bodyBytes: [])]
      return data
    }
    
    class Dummy {}
    
    static func algorithms() -> [DXAlgorithm] {
      let filename = "reface-dx-algos"
      guard let url = Bundle(for: Dummy.self).url(forResource: filename, withExtension: "json"),
        let data = try? Data(contentsOf: url) else { return [] }
      return DXAlgorithm.algorithms(fromJSON: data, key: filename)
    }
    
    static func freqRatio(fixedMode: Bool, coarse: Int, fine: Int) -> String {
      if fixedMode {
        let freq = pow(10, (Float(coarse / 8)) + (Float(fine) / 100))
        return String(format:"%.4g", freq)
      }
      else {
        let c = Float(coarse)
        let f = Float(fine)
        if coarse == 0 {
          return String(format:"%.3f", 0.5 + (f * 0.005))
        }
        else {
          return String(format:"%.2f", c + (f * 0.01))
        }
      }
    }
    
    static let patchTransform: MidiTransform = .multi(throttle: 100, .basicChannel, .patch(coalesce: 5, param: { editorVal, bodyData, parm, value in
      let address: [UInt8]
      switch parm.path[0] {
      case .common:
        address = [0x30, 0x00, UInt8(parm.b!)]
      case .op:
        guard let op = parm.path.i(1) else { return nil }
        address = [0x31, UInt8(op), UInt8(parm.b!)]
      default:
        return nil
      }
      return [(.sysex(paramData(channel: editorVal, address: address, value: UInt8(value))), 50)]

    }, patch: { editorVal, bodyData in
      return tempSysexData(bodyData, channel: editorVal).map { (.sysex($0), 50) }

    }, name: { editorVal, bodyData, path, name in
      guard let p = bodyData[[.common]] else { return [] }
      return 10.map {
        paramData(channel: editorVal, address: [0x30, 0x00, UInt8($0)], value: p[$0])
      }.map { (.sysex($0), 50) }

    }))
    
    static let bankTransform: MidiTransform = .multi(throttle: 100, .basicChannel, .wholeBank({ editorVal, bodyData in

      // change the first patch
      var bodyData = bodyData
      let path: SynthPath = [.common, .bend]
      guard let parm = patchTruss.parm(path) else { return [] }
      let value = patchTruss.getValue(bodyData[0], path: path) ?? 0
      let dirtyValue = value == parm.span.range.lowerBound ? value + 1 : parm.span.range.lowerBound // just something different from orig value
      patchTruss.setValue(&bodyData[0], path: path, dirtyValue)

      // change param back
      let address: [UInt8]
      switch path[0] {
      case .common:
        address = [0x30, 0x00, UInt8(parm.b!)]
      case .op:
        guard let op = path.i(1) else { return [] }
        address = [0x31, UInt8(op), UInt8(parm.b!)]
      default:
        return []
      }
      
      // send patches
      let data: [MidiMessage] = bodyData.enumerated().map {
        .sysex(sysexData($1, channel: editorVal, location: $0).flatMap({ $0 }))
      } + [
        // pgm change to 1, then 2, then 1
        .pgmChange(channel: UInt8(editorVal), value: 0),
        .pgmChange(channel: UInt8(editorVal), value: 1),
        .pgmChange(channel: UInt8(editorVal), value: 0),
        .sysex(paramData(channel: editorVal, address: address, value: UInt8(value))),
      ]

      // TODO: show msg to store bank
      return data.map { ($0, 50) }
    }))
    
//    func randomize() {
//      randomizeAllParams()
//
//      let algos = Self.algorithms()
//      let algoIndex = self[[.common, .algo]] ?? 0
//
//      let algo = algos[algoIndex]
//
//      // make output ops audible
//      for outputId in algo.outputOps {
//        let op: SynthPath = [.op, .i(outputId)]
//        self[op + [.level, .i(0)]] = 116 + (0...9).random()!
//        self[op + [.rate, .i(0)]] = 106 + (0...19).random()!
//        self[op + [.level, .i(2)]] = 106 + (0...19).random()!
//        self[op + [.level, .i(3)]] = 0
//        self[op + [.rate, .i(3)]] = 60 + (0...67).random()!
//        self[op + [.level]] = 116 + (0...9).random()!
//        self[op + [.level, .scale, .left, .depth]] = (0...9).random()!
//        self[op + [.level, .scale, .right, .depth]] = (0...9).random()!
//      }
//
//      let randomOut = algo.outputOps[(0..<algo.outputOps.count).random()!]
//      let op: SynthPath = [.op, .i(randomOut)]
//      self[op + [.freq, .mode]] = 0
//      self[op + [.fine]] = 0
//      self[op + [.coarse]] = 1
//
//      self[[.common, .transpose]] = 64
//      self[[.common, .porta]] = 0
//      
//      // flat pitch env
//      for i in 0..<4 {
//        self[[.common, .pitch, .env, .level, .i(i)]] = 64
//      }
//
//      // all ops on
//      for op in 0..<4 { self[[.op, .i(op), .on]] = 1 }
//    }

    enum Common {
      
      static let patchTruss = try! SinglePatchTruss("refacedx.voice.common", 38, namePackIso: .basic(0..<10), params: parms.params(), initFile: "reface-dx-voice-common-init", createFileData: {
        sysexData($0, channel: 0)
      }, parseOffset: 11)
      
      static func sysexData(_ bytes: [UInt8], channel: Int) -> [UInt8] {
        bulkDumpData(channel: channel, byteCount: 42, address: [0x30, 0x00, 0x00], bodyBytes: bytes)
      }

      static let parms: [Parm] = [
        .p([.transpose], 0x0c, .rng(40...88, dispOff: -64)),
        .p([.mono], 0x0d, .opts(["Poly", "Mono Full", "Mono Lgato"])),
        .p([.porta], 0x0e),
        .p([.bend], 0x0f, .rng(40...88, dispOff: -64)),
        .p([.algo], 0x10, .max(11, dispOff: 1)),
        .p([.lfo, .wave], 0x11, .opts(["Sin", "Tri", "Saw Up", "Saw Down", "Sqr", "S&H8", "S&H"])),
        .p([.lfo, .speed], 0x12),
        .p([.lfo, .delay], 0x13),
        .p([.lfo, .pitch, .mod], 0x14),
        .p([.pitch, .env, .rate, .i(0)], 0x15),
        .p([.pitch, .env, .rate, .i(1)], 0x16),
        .p([.pitch, .env, .rate, .i(2)], 0x17),
        .p([.pitch, .env, .rate, .i(3)], 0x18),
        .p([.pitch, .env, .level, .i(0)], 0x19, .rng(16...112, dispOff: -64)),
        .p([.pitch, .env, .level, .i(1)], 0x1a, .rng(16...112, dispOff: -64)),
        .p([.pitch, .env, .level, .i(2)], 0x1b, .rng(16...112, dispOff: -64)),
        .p([.pitch, .env, .level, .i(3)], 0x1c, .rng(16...112, dispOff: -64)),
        .p([.fx, .i(0), .type], 0x1d, .opts(fxTypeOptions)),
        .p([.fx, .i(0), .param, .i(0)], 0x1e),
        .p([.fx, .i(0), .param, .i(1)], 0x1f),
        .p([.fx, .i(1), .type], 0x20, .opts(fxTypeOptions)),
        .p([.fx, .i(1), .param, .i(0)], 0x21),
        .p([.fx, .i(1), .param, .i(1)], 0x22),
      ]

      static let fxTypeOptions = ["Thru", "Dist", "T.Wah", "Cho", "Fla", "Pha", "Dly", "Rev"]
    }
    
    enum Op {
    
      static let patchTruss = try! SinglePatchTruss("refacedx.voice.op", 28, params: parms.params(), initFile: "reface-dx-voice-op-init", createFileData: {
        sysexData($0, channel: 0, op: 0)
      }, parseOffset: 11)


      static func sysexData(_ bytes: [UInt8], channel: Int, op: Int) -> [UInt8] {
        bulkDumpData(channel: channel, byteCount: 32, address: [0x31, UInt8(op), 0x00], bodyBytes: bytes)
      }
      
      static let parms: [Parm] = [
        .p([.on], 0x00, .max(1)),
        .p([.rate, .i(0)], 0x01),
        .p([.rate, .i(1)], 0x02),
        .p([.rate, .i(2)], 0x03),
        .p([.rate, .i(3)], 0x04),
        .p([.level, .i(0)], 0x05),
        .p([.level, .i(1)], 0x06),
        .p([.level, .i(2)], 0x07),
        .p([.level, .i(3)], 0x08),
        .p([.rate, .scale], 0x09),
        .p([.level, .scale, .left, .depth], 0x0a),
        .p([.level, .scale, .right, .depth], 0x0b),
        .p([.level, .scale, .left, .curve], 0x0c, .opts(levelScaleCurveOptions)),
        .p([.level, .scale, .right, .curve], 0x0d, .opts(levelScaleCurveOptions)),
        .p([.lfo, .amp, .mod], 0x0e),
        .p([.lfo, .pitch, .mod], 0x0f, .max(1)),
        .p([.pitch, .env], 0x10, .max(1)),
        .p([.velo], 0x11),
        .p([.level], 0x12),
        .p([.feedback, .level], 0x13),
        .p([.feedback, .type], 0x14, .opts(["Saw", "Sqr"])),
        .p([.freq, .mode], 0x15, .opts(["Ratio", "Fixed"])),
        .p([.coarse], 0x16, .max(31)),
        .p([.fine], 0x17, .max(99)),
        .p([.detune], 0x18, .rng(dispOff: -64)),
      ]
      
      static let levelScaleCurveOptions = ["-Lin", "-Exp", "+Exp", "+Lin"]
      
      static let feedbackIso = Miso.switcher([
        .range((-127...(-1)), Miso.m(-1) >>> Miso.unitFormat("sw")),
        .int(0, "0"),
        .range(1...127, Miso.unitFormat("sq"))
      ])
    }
  }
  
}

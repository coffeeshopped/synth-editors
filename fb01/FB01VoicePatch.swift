
extension FB01 {
  
  enum Voice {
    
    static let patchTruss = try! SinglePatchTruss("voice", bodyDataCount, namePackIso: .basic(0..<8), params: parms.params(), initFile: "fb01-init", createFileData: { sysexData($0, channel: 0) }, parseBodyData: {
      let bytes = $0.safeBytes(offset: 9, count: 128)
      return packedBytes(bytes)
    })
    
    static let bodyDataCount = 64
    
    private static func packedBytes(_ b: [UInt8]) -> [UInt8] {
      bodyDataCount.map {
        let i = 2 * $0
        return b[i] + (b[i + 1] << 4)
      }
    }
    
    private static func unpackedBytes(_ b: [UInt8]) -> [UInt8] {
      [UInt8](b.map { [$0 & 0xf, ($0 >> 4) & 0xf] }.joined())
    }
    
    static func sysexData(_ bodyData: [UInt8], channel: Int) -> [UInt8] {
      sysexData(bodyData, channel: channel, part: 0)
    }
    
    static func sysexData(_ bodyData: [UInt8], channel: Int, part: Int) -> [UInt8] {
      // last 2 bytes of hello are the value 128 (number of bytes in packet) broken into two bytes per docs
      let b = unpackedBytes(bodyData)
      let cmdBytesWithChannel = [0x75, UInt8(channel), 0x08 + UInt8(part), 0, 0, 0x01, 0x00]
      return Yamaha.sysexData(cmdBytesWithChannel: cmdBytesWithChannel, bodyBytes: b)
    }
    
    static func paramTransform(instrument: Int) -> MidiTransform.Fn<SinglePatchTruss,Int>.Param {
      { (editorVal, bodyData, parm, value) in
        let data = paramData(channel: editorVal, instrument: instrument, paramAddress: parm.b!, value: bodyData[parm.b!])
        return [(.sysex(data), 10)]
      }
    }
    
    static func patchTransform(instrument: Int) -> MidiTransform.Fn<SinglePatchTruss,Int>.Whole {
      { (editorVal, bodyData) in
        [(.sysex(sysexData(bodyData, channel: editorVal, part: instrument)), 100)]
      }
    }

    static func nameTransform(instrument: Int) -> MidiTransform.Fn<SinglePatchTruss,Int>.Name {
      { (editorVal, bodyData, path, name) in
        return patchTruss.namePackIso?.byteRange.map {
          let data = paramData(channel: editorVal, instrument: instrument, paramAddress: $0, value: bodyData[$0])
          return (.sysex(data), 10)
        }
      }
    }
    
    static func patchChangeTransform(instrument: Int) -> MidiTransform {
      .single(throttle: 30, sysexChannel, .patch(param: paramTransform(instrument: instrument), patch: patchTransform(instrument: instrument), name: nameTransform(instrument: instrument)))
    }
    
    static func paramData(channel: Int, instrument: Int, paramAddress: Int, value: UInt8) -> [UInt8] {
      FB01.paramData(channel: channel, instrument: instrument, bodyBytes: [
        0x40 + UInt8(paramAddress),
        UInt8(value.bits(0...3)), UInt8(value.bits(4...7)),
      ])
    }


    enum Bank {

      // offset of 74 is from:
      // 7 bytes in header
      // 67: reserved packet. 2 bytes to describe size (64), 64 data bytes, 1 checksum byte

      static let bankTruss = SingleBankTruss(patchTruss: patchTruss, patchCount: 48, fileDataCount: 6363, createFileData: {
        sysexData($0, channel: 0, bank: 0)
      }, parseBodyData: {
        MultiBankTruss.compactData(fileData: $0, offset: 74, patchByteCount: 131).map {
          packedBytes($0.safeBytes(offset: 2, count: 128))
        }
      })

      static func sysexData(_ bodyData: [[UInt8]], channel: Int, bank: Int) -> [UInt8] {
        var data = [0xf0, 0x43, 0x75, UInt8(channel), 0x00, 0x00, UInt8(bank)]
        // reserved packet of data
        data += [0x00, 0x40, 0x05, 0x07, 0x03, 0x07, 0x05, 0x06, 0x02, 0x07, 0x00, 0x02, 0x01, 0x03, 0x00, 0x02, 0x00, 0x02, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x4C]
        data += bodyData.flatMap {
          let b = unpackedBytes($0)
          return [0x01, 0x00] + b + [Yamaha.checksum(bytes: b)]
        }
        data += [0xf7]
        return data
      }
      
      static func transform(bank: Int) -> MidiTransform {
        .single(throttle: 30, sysexChannel, .wholeBank({ editorVal, bodyData in
          [(.sysex(sysexData(bodyData, channel: editorVal, bank: bank)), 10)]
        }))
      }

    }



        
    
  //  override func randomize() {
  //    super.randomize()
  //    let algoIndex = value("Algorithm")!
  //    let algo = type(of: self).algorithms()[algoIndex]
  //
  //    for outputId in algo.outputOps {
  //      let op = "Op\(outputId+1)"
  //      // set output levels to between 100 and 127 (remember levels are inverted)
  //      set(value: (0...27).random()!, forParameterKey: "\(op)Level")
  //    }
  //
  //    set(value: 1, forParameterKey: "Op1On")
  //    set(value: 1, forParameterKey: "Op2On")
  //    set(value: 1, forParameterKey: "Op3On")
  //    set(value: 1, forParameterKey: "Op4On")
  //
  //    set(value: 0, forParameterKey: "Transpose")
  //    set(value: 0, forParameterKey: "Porta")
  //
  //    // for one out, make it harmonic and louder
  //    let randomOut = algo.outputOps[(0...(algo.outputOps.count-1)).random()!] + 1
  //    set(value: 1, forParameterKey: "Op\(randomOut)Coarse")
  //    set(value: 0, forParameterKey: "Op\(randomOut)Fine")
  //  }
    
    static func algorithms() -> [DXAlgorithm] {
      DXAlgorithm.algorithmsFromPlist("TX81Z Algorithms")
    }

    static func freqRatio(coarse: Int, fine: Int) -> Float {
      let c = coarse == 0 ? 0.5 : Float(coarse)
      guard fine < 4 else { return c }
      return c * [1, 1.41, 1.57, 1.73][fine]
    }
    
    static func levelScaleTypePack(byte: Int) -> PackIso {
      PackIso.splitter([
        (byte    , 7...7, 0...0),
        (byte + 2, 7...7, 1...1),
      ])
    }

    static let parms: [Parm] = [
      .p([.lfo, .speed], 0x08, .max(255)),
      .p([.lfo, .load], 0x09, bit: 7),
      .p([.amp, .mod, .depth], 0x09, bits: 0...6),
      .p([.lfo, .sync], 0x0a, bit: 7),
      .p([.pitch, .mod, .depth], 0x0a, bits: 0...6),
    ] <<< 4.map {
      .p([.op, .i($0), .on], 0x0b, bit: 6 - $0)
    } <<< [
      .p([.feedback], 0x0c, bits: 3...5, .max(7)),
      .p([.algo], 0x0c, bits: 0...2, .rng(0...7, dispOff: 1)),
      .p([.pitch, .mod, .sens], 0x0d, bits: 4...6, .max(7)),
      .p([.amp, .mod, .sens], 0x0d, bits: 0...1, .max(3)),
      .p([.lfo, .wave], 0x0e, bits: 5...6, .opts(lfoWaveOptions)),
      .p([.transpose], 0x0f, .rng(-128...127)),
    ] <<< [3,2,1,0].enumerated().map { i, op in
        .prefix([.op, .i(op)]) {
          let offset = 0x10 + (i * 0x08)
          return .offset(b: offset) { [
            .p([.level], 0x00, .max(127)),
            .p([.level, .scale, .type], 1, packIso: levelScaleTypePack(byte: offset + 1), .opts(["0","1","2","3"])),
            .p([.velo], 0x01, bits: 4...6, .max(7)),
            .p([.level, .scale], 0x02, bits: 4...7, .max(15)),
            .p([.level, .adjust], 0x02, bits: 0...3, .max(15)),
            .p([.detune], 0x03, bits: 4...6, .rng(-3...3)),
            .p([.coarse], 0x03, bits: 0...3, .max(15)),
            .p([.rate, .scale], 0x04, bits: 6...7, .max(3)),
            .p([.attack], 0x04, bits: 0...4, .max(31)),
            .p([.amp, .mod], 0x05, bit: 7),
            .p([.attack, .velo], 0x05, bits: 5...6, .max(3)),
            .p([.decay, .i(0)], 0x05, bits: 0...4, .max(31)),
            .p([.fine], 0x06, bits: 6...7, .max(3)),
            .p([.decay, .i(1)], 0x06, bits: 0...4, .max(31)),
            .p([.decay, .level], 0x07, bits: 4...7, .max(15)),
            .p([.release], 0x07, bits: 0...3, .max(15)),
          ] }
        }
    }.reduce([], +) <<< [
      .p([.poly], 0x3a, bit: 7),
      .p([.porta], 0x3a, bits: 0...6),
      .p([.pitch, .mod, .depth, .ctrl], 0x3b, bits: 4...6, .opts(ctrlOptions)),
      .p([.bend], 0x3b, bits: 0...3, .max(12)),
    ]
    
    static let lfoWaveOptions = ["Saw Up","Square","Triangle","S/Hold"]
    
    static let ctrlOptions = ["None","Aftertouch","Mod Wheel","Breath Ctrl","Foot Ctrl"]
    
  }
}


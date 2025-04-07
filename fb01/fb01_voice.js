
  
  const bodyDataCount = 64
  
  
  private static func unpackedBytes(_ b: [UInt8]) -> [UInt8] {
    [UInt8](b.map { [$0 & 0xf, ($0 >> 4) & 0xf] }.joined())
  }
  
  
// last 2 bytes of hello are the value 128 (number of bytes in packet) broken into two bytes per docs
const sysexData = part => ['>',
  ['nibblizeLSB'], // turn body data into 4-bit nibbles
  ['yamCmd', [0x75, 'channel', 0x08 + part, 0, 0, 0x01, 0x00], 'b'],
]
  
  static func paramTransform(instrument: Int) -> MidiTransform.Fn<SinglePatchTruss,Int>.Param {
    { (editorVal, bodyData, parm, value) in
      let data = paramData(channel: editorVal, instrument: instrument, paramAddress: parm.b!, value: bodyData[parm.b!])
      return [(.sysex(data), 10)]
    }
  }
  
  static func patchTransform(instrument: Int) -> MidiTransform.Fn<SinglePatchTruss,Int>.Whole {
    { (editorVal, bodyData) in
      [(.sysex(sysexData(instrument)), 100)]
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
    FB01.paramData(instrument, bodyBytes: [
      0x40 + UInt8(paramAddress),
      UInt8(value.bits(0...3)), UInt8(value.bits(4...7)),
    ])
  }


  enum Bank {

    // offset of 74 is from:
    // 7 bytes in header
    // 67: reserved packet. 2 bytes to describe size (64), 64 data bytes, 1 checksum byte

    const bankTruss = SingleBankTruss(patchTruss: patchTruss, patchCount: 48, fileDataCount: 6363, createFileData: {
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

  const parms: [Parm] = [
    ['lfo/speed', { b: 0x08, max: 255 }],
    ['lfo/load', { b: 0x09, bit: 7 }],
    ['amp/mod/depth', { b: 0x09, bits: 0...6 }],
    ['lfo/sync', { b: 0x0a, bit: 7 }],
    ['pitch/mod/depth', { b: 0x0a, bits: 0...6 }],
  ] <<< 4.map {
    ['op/$0/on', { b: 0x0b, bit: 6 - $0 }]
  } <<< [
    ['feedback', { b: 0x0c, bits: 3...5, max: 7 }],
    ['algo', { b: 0x0c, bits: 0...2, rng: [0, 8], dispOff: 1 }],
    ['pitch/mod/sens', { b: 0x0d, bits: 4...6, max: 7 }],
    ['amp/mod/sens', { b: 0x0d, bits: 0...1, max: 3 }],
    ['lfo/wave', { b: 0x0e, bits: 5...6, opts: lfoWaveOptions }],
    ['transpose', { b: 0x0f, .rng(-128...127) }],
  ] <<< [3,2,1,0].enumerated().map { i, op in
      .prefix("op/op") {
        let offset = 0x10 + (i * 0x08)
        return .offset(b: offset) { [
          ['level', { b: 0x00, max: 127 }],
          ['level/scale/type', { 1, packIso: levelScaleTypePack(byte: offset + 1), opts: ["0","1","2","3"] }],
          ['velo', { b: 0x01, bits: 4...6, max: 7 }],
          ['level/scale', { b: 0x02, bits: 4...7, max: 15 }],
          ['level/adjust', { b: 0x02, bits: 0...3, max: 15 }],
          ['detune', { b: 0x03, bits: 4...6, .rng(-3...3) }],
          ['coarse', { b: 0x03, bits: 0...3, max: 15 }],
          ['rate/scale', { b: 0x04, bits: 6...7, max: 3 }],
          ['attack', { b: 0x04, bits: 0...4, max: 31 }],
          ['amp/mod', { b: 0x05, bit: 7 }],
          ['attack/velo', { b: 0x05, bits: 5...6, max: 3 }],
          ['decay/0', { b: 0x05, bits: 0...4, max: 31 }],
          ['fine', { b: 0x06, bits: 6...7, max: 3 }],
          ['decay/1', { b: 0x06, bits: 0...4, max: 31 }],
          ['decay/level', { b: 0x07, bits: 4...7, max: 15 }],
          ['release', { b: 0x07, bits: 0...3, max: 15 }],
        ] }
      }
  }.reduce([], +) <<< [
    ['poly', { b: 0x3a, bit: 7 }],
    ['porta', { b: 0x3a, bits: 0...6 }],
    ['pitch/mod/depth/ctrl', { b: 0x3b, bits: 4...6, opts: ctrlOptions }],
    ['bend', { b: 0x3b, bits: 0...3, max: 12 }],
  ]
  
const lfoWaveOptions = ["Saw Up","Square","Triangle","S/Hold"]
  
const ctrlOptions = ["None","Aftertouch","Mod Wheel","Breath Ctrl","Foot Ctrl"]
  
const patchTruss = {
  type: 'singlePatch',
  id: "voice", 
  bodyDataCount, 
  namePack: [0, 8], 
  parms: parms, 
  initFile: "fb01-init", 
  createFile: sysexData(0), 
  parseBody: ['>',
    ['bytes', { start: 9, count: 128 }],
    'denibblizeLSB',    
  ],
}
const FS1R = require('./FS1R.js')

// TODO: treat byte (b) values as RolandAddresses for the purposes of packing/unpacking
// i.e. take b, make a RolandAddress from it, then get intValue(), and that's the actual byte address
// whereas the b value itself can be used for parameter midi transmission


// TODO: API QUESTION: should operators like prefix, offset, etc for Parms always treat b and p values as RolandAddresses? Seems like they should. Are there situations where they should not be (check out the Virus)? Should there be a switch to specify which behavior is desired?

private static func multiPack(_ byte: Int) -> PackIso {
  PackIso.splitter([
    (byte: byte, byteBits: nil, valueBits: 7...13),
    (byte: byte + 1, byteBits: nil, valueBits: 0...6),
  ])
}

const parms = [
  ["category", { b: 0x0e, opts: Voice.categoryOptions }],
  ["volume", { b: 0x10 }],
  ["pan", { b: 0x11, rng: [1, 127+1], dispOff: -64 }],
  ["note/shift", { b: 0x12, rng: [0, 48+1], dispOff: -24 }],
  ["part/out", { b: 0x14, opts: ["Off","Pre Ins","Post Ins"] }],
  ["fseq/part", { b: 0x15, opts: ["Off","1","2","3","4"] }],
  ["fseq/bank", { b: 0x16, opts: ["Int","Pre"] }],
  ["fseq/number", { b: 0x17, max: 89, dispOff: 1 }],
  ["fseq/speed", { b: 0x18, opts: fseqSpeedOptions, packIso: multiPack(0x18) }],
  ["fseq/start", { b: 0x1a, packIso: multiPack(0x1a) }],
  ["fseq/loop/start", { b: 0x1c, packIso: multiPack(0x1c) }],
  ["fseq/loop/end", { b: 0x1e, packIso: multiPack(0x1e) }],
  ["fseq/loop", { b: 0x20, opts: ["1-way","Round"] }],
  ["fseq/mode", { b: 0x21, opts: [1 : "Scratch",2 : "Fseq"] }],
  ["fseq/speed/velo", { b: 0x22, max: 7 }],
  ["fseq/formant/pitch", { b: 0x23, opts: ["Fseq","Fixed"] }],
  ["fseq/trigger", { b: 0x24, opts: ["First","All"] }],
  ["fseq/formant/seq/delay", { b: 0x26, max: 99 }],
  ["fseq/level/velo", { b: 0x27, dispOff: -64 }],
  { prefix: 'ctrl', count: 8, bx: 1, block: 
    { prefix: 'part', count: 4, block: part => 
      ['', {b: 0x28, bit: part }]
    },
    ["dest", { b: 0x40, opts: destOptions }],
    ["depth", { b: 0x48, dispOff: -64 }],
  },
  { prefix: 'ctrl', count: 8, block: ctrl => 
    ([
    "knob/0",
    "knob/1",
    "knob/2",
    "knob/3",
    "midi/ctrl/0",
    "midi/ctrl/1",
    "bend",
    
    "channel/aftertouch",
    "poly/aftertouch",
    "foot",
    "breath",
    "midi/ctrl/2",
    "modWheel",
    "midi/ctrl/3",
    ]).mapWithIndex((path, i) =>
      [path, { b: 0x30 + (2 * ctrl) + (i < 7 ? 1 : 0), bit: i % 7 }]
    )
  },
  { prefix: 'reverb', count: 16, block: i => {
    if (i < 8) {
      return ["", { b: 0x50 + 2 * i, packIso: multiPack(0x50 + 2 * i) }]
    }
    else {
      return ["", { b: 0x60 + i - 8 }]
    }
  } },
  { prefix: 'vary', count: 16, block: i => 
    ["", { p: 2, b: 0x68 + 2 * i }]
  },
  { prefix: 'insert', count: 16, block: i => 
    ["", { p: 2, b: 0x88 + 2 * i }]
  },
  { inc: 1, b: 0xa8, block: [
    ["reverb/type", { opts: reverbOptions }],
    ["reverb/pan", { rng: [1, 127+1], dispOff: -64 }],
    ["reverb/level", { }],
    ["vary/type", { opts: varyOptions }],
    ["vary/pan", { rng: [1, 127+1], dispOff: -64 }],
    ["vary/level", { }],
    ["vary/reverb", { }],
    ["insert/type", { opts: insertOptions }],
    ["insert/pan", { rng: [1, 127+1], dispOff: -64 }],
    ["insert/reverb", { }],
    ["insert/vary", { }],
    ["insert/level", { }],
    
    ["lo/gain", { rng: [52, 76+1], dispOff: -64 }],
    ["lo/freq", { opts: optionsDict(4...40, cutoffOptions) }],
    ["lo/q", { opts: eqQOptions }],
    ["lo/shape", { opts: eqShapeOptions }],
    ["mid/gain", { rng: [52, 76+1], dispOff: -64 }],
    ["mid/freq", { opts: optionsDict(14...54, cutoffOptions) }],
    ["mid/q", { opts: eqQOptions }],
    ["hi/gain", { rng: [52, 76+1], dispOff: -64 }],
    ["hi/freq", { opts: optionsDict(28...58, cutoffOptions) }],
    ["hi/q", { opts: eqQOptions }],
    ["hi/shape", { opts: eqShapeOptions }],
  ] },
  { b: 192, offset: 
    { prefix: 'part', count: 4, bx: 52, block: { b2p: 
      { inc: 1, b: 0, block: [
        ["note/reserve", { }],
        ["bank", { opts: bankOptions }],
        ["pgm", {  }],
        ["channel/hi", { opts: channelMaxOptions }],
        ["channel", { opts: channelOptions }],
        ["poly", { opts: ["Mono","Poly"] }],
        ["mono/priority", { opts: ["Last","Top","Bottom","First"] }],
        ["filter/on", { max: 1 }],
        ["note/shift", { max: 48, dispOff: -24 }],
        ["detune", { dispOff: -64 }],
        ["voiced/unvoiced", { dispOff: -64 }],
        ["volume", { }],
        ["velo/depth", { }],
        ["velo/offset", { }],
        ["pan", { opts: panOptions }],
        ["note/lo", { }],
        ["note/hi", { }],
        ["level", { }],
        ["vary", { }],
        ["reverb", { }],
        ["insert", { }],
        ["lfo/0/rate", { dispOff: -64 }],
        ["lfo/0/pitch/mod", { dispOff: -64 }],
        ["lfo/0/delay", { dispOff: -64 }],
        ["cutoff", { dispOff: -64 }],
        ["reson", { dispOff: -64 }],
        ["env/attack", { dispOff: -64 }],
        ["env/decay", { dispOff: -64 }],
        ["env/release", { dispOff: -64 }],
        ["formant", { dispOff: -64 }],
        ["fm", { dispOff: -64 }],
        ["filter/env/depth", { dispOff: -64 }],
        ["pitch/env/innit", { dispOff: -64 }],
        ["pitch/env/attack", { dispOff: -64 }],
        ["pitch/env/release/level", { dispOff: -64 }],
        ["pitch/env/release/time", { dispOff: -64 }],
        ["porta", { opts: [0:"Off",1:"Fingered",3:"Fulltime"] }],
        ["porta/time", { }],
        ["bend/hi", { range: [0x10, 0x59], dispOff: -64 }],
        ["bend/lo", { range: [0x10, 0x59], dispOff: -64 }],
        ["pan/scale", { max: 100, dispOff: -50 }],
        ["pan/lfo/depth", { max: 99 }],
        ["velo/lo", { rng: [1, 127+1] }],
        ["velo/hi", { rng: [1, 127+1] }],
        ["pedal/lo", { }],
        ["sustain/rcv", { max: 1 }],
        ["lfo/1/rate", { dispOff: -64 }],
        ["lfo/1/depth", { dispOff: -64 }],
      ] } } 
    }
  },
]

/// sysex bytes for patch as temp perf
const sysexData = deviceId => FS1R.sysexData(deviceId, [0x10, 0x00, 0x00])

/// sysex bytes for patch as stored in memory location
const sysexDataWithLocation = (deviceId, location) => FS1R.sysexData(deviceId, [0x11, 0x00, location])

const patchTruss = {
  type: 'singlePatch',
  id: "perf", 
  bodyDataCount: 400, 
  namePack: [0, 0x0c],
  parms: parms, 
  initFile: "fs1r-perf-init", 
  createFile: sysexData(0),
  parseBody: FS1R.parseOffset,
}

const bankTruss = {
  type: 'singleBank',
  patchTruss: patchTruss,
  patchCount: 128, 
  createFile: {
    locationMap: location => sysexDataWithLocation(0, location)
  },
  parseBody: {
    locationIndex: 8,
    parseBody: patchTruss.parseBody,
    patchCount: 128,
  },
}


const refTruss: FullRefTruss = {

  let refPath: SynthPath = "perf"
  let sections: [(String, [SynthPath])] = [
    ("Performance", ["perf"]),
    ("Parts", 4.map { "part/$0" }),
    ("Fseq", ["fseq"]),
  ]

  let createFileData: FullRefTruss.Core.ToMidiFn = { bodyData in
    // map over the types to ensure ordering of data
    try trussMap.compactMap {
      guard case .single(let d) = bodyData[$0.0] else { return nil }
      switch $0.1.displayId {
      case Voice.patchTruss.displayId:
        return Voice.tempSysexData(d, deviceId: 0, part: $0.0.endex).bytes()
      default:
        return try $0.1.createFileData(anyBodyData: .single(d))
      }
    }.reduce([], +)
  }

  let isos: FullRefTruss.Isos = [
    "fseq" : .basic(path: "fseq/bank", location: "fseq/number", pathMap: [
      "bank/fseq", "preset/fseq",
    ])
  ]
  <<< 4.dict {
    let part: SynthPath = "part/$0"
    return [part : .basic(path: part + "bank", location: part + "pgm", pathMap: [
      [], "bank/voice",
    ] + 11.map { "preset/voice/$0" })]
  }

  return FullRefTruss("perf.full", trussMap: trussMap, refPath: refPath, isos: isos, sections: sections, initFile: "fs1r-full-perf-init", createFileData: createFileData, pathForData: path(forData:))
}()

const trussMap: [(SynthPath, any SysexTruss)] = [
  ("perf", Perf.patchTruss),
] + 4.map { ("part/$0", Voice.patchTruss)} + [
  ("fseq", Fseq.patchTruss)
]

static func path(forData data: [UInt8]) -> SynthPath? {
  guard data.count > 6 else { return nil }
  switch data[6] {
  case 0x10:
    return "perf"
  case 0x40...0x43:
    return "part/Int(data[") - 0x40)]
  case 0x60:
    return "fseq"
  default:
    return nil
  }
}

const patchChangeTransform: MidiTransform = .single(throttle: 30, deviceId, .patch(param: { editorVal, bodyData, path, value in
  guard let param = patchTruss.params[path] else { return nil }
  let deviceId = deviceIdMap(editorVal)
  
  if let part = path[0] == .part ? path.i(1) : nil {
    return [(partParamData(deviceId, bodyData: bodyData, part: part, param: param), 30)]
  }
  else {
    // common params have param address stored in .byte
    var byte = param.byte
    var byteCount = param.packIso != nil ? 2 : 1
    if (0x30..<0x40).contains(byte) {
      // special treatment for src bits
      byte = byte - (byte % 2)
      byteCount = 2
    }
    return [(commonParamData(deviceId, bodyData: bodyData, paramAddress: byte, byteCount: byteCount), 30)]
  }
}, patch: { editorVal, bodyData in
  [(sysexData(bodyData, deviceId: deviceIdMap(editorVal)), 100)]
}, name: { editorVal, bodyData, path, name in
  let deviceId = deviceIdMap(editorVal)
  return patchTruss.namePackIso?.byteRange.map {
    (commonParamData(deviceId, bodyData: bodyData, paramAddress: $0, byteCount: 1), 30)
  }
}))

// instead of sending <value>, we send the byte from the bytes array, because some params share bytes with others
static func commonParamData(_ deviceId: UInt8, bodyData: [UInt8], paramAddress: Int, byteCount: Int) -> MidiMessage {
  let v = byteCount == 1 ? Int(bodyData[paramAddress]) : (Int(bodyData[paramAddress]) << 7) + Int(bodyData[paramAddress + 1])
  let paramBytes = RolandAddress(intValue: paramAddress).sysexBytes(count: 2)
  return dataSetMsg(deviceId: deviceId, address: [0x10] + paramBytes, value: v)
}

static func partParamData(_ deviceId: UInt8, bodyData: [UInt8], part: Int, param: Param) -> MidiMessage {
  let v = Int(bodyData[param.byte])
  return dataSetMsg(deviceId: deviceId, address: [0x30 + UInt8(part), 0x00, UInt8(param.parm)], value: v)
}

const bankChangeTransform: MidiTransform = .single(throttle: 0, deviceId, .bank({ 
  [(sysexData($1, deviceId: deviceIdMap($0), location: $2), 100)]
}))



extension FS1R {
  
  enum Perf {
    

    
    const presetFseqOptions = OptionsParam.makeNumberedOptions(["ShoobyDo", "2BarBeat", "D&B", "D&B Fill", "4BarBeat", "YouCanG", "EBSayHey", "RtmSynth", "VocalRtm", "WooWaPa", "UooLha", "FemRtm", "ByonRole", "WowYeah", "ListenVo", "YAMAHAFS", "Laugh", "Laugh2", "AreYouR", "Oiyai", "Oiaiuo", "UuWaUu", "Wao", "RndArp1", "FiltrArp", "RndArp2", "TechArp", "RndArp3", "Voco-Seq", "PopTech", "1BarBeat", "1BrBeat2", "Undo", "RndArp4", "VoclRtm2", "Reiyowha", "RndArp5", "VocalArp", "CanYouGi", "Pu-Yo", "Yaof", "MyaOh", "ChuckRtm", "ILoveYou", "Jan-On", "Welcome", "One-Two", "Edokko", "Everybdy", "Uwau", "YEEAAH", "4-3-2-1", "Test123", "CheckSnd", "ShavaDo", "R-M-H-R", "HiSchool", "M.Blastr", "L&G MayI", "Hellow", "ChowaUu", "Everybd2", "Dodidowa", "Check123", "BranNewY", "BoomBoom", "Hi=Woo", "FreeForm", "FreqPad", "YouKnow", "OldTech", "B/M", "MiniJngl", "EveryB-S", "IYaan", "Yeah", "ThankYou", "Yes=No", "UnWaEDon", "MouthPop", "Fire", "TBLine", "China", "Aeiou", "YaYeYiYo", "C7Seq", "SoundLib", "IYaan2", "Relax", "PSYAMAHA"], offset: 1)
    
    const bankOptions = ["Off","Int","PrA","PrB","PrC", "PrD","PrE","PrF","PrG","PrH","PrI","PrJ","PrK"]

    const channelOptions: [Int:String] = {
      var options = (0..<16).map { "\($0+1)"} 
      options[0x10] = "Pfm"
      options[0x7f] = "Off"
      return options
    }()

    const channelMaxOptions: [Int:String] = {
      var options = (0..<16).map { "\($0+1)"} 
      options[0x7f] = "Off"
      return options
    }()

    const fseqMidiSpeedOptions = ["Midi 1/4","Midi 1/2","Midi","Midi 2/1","Midi 4/1"]
    const fseqSpeedOptions: [Int:String] = {
      var opts = ["Midi 1/4","Midi 1/2","Midi","Midi 2/1","Midi 4/1"]
      opts.append(contentsOf: [String](repeating: "10.0%", count: 95))
      opts.append(contentsOf: (100...5000).map { String(format: "%.1f%%", (Float($0) * 0.1)) })
      return opts
    }()
    
    const panOptions: [Int:String] = {
      var options = [Int:String]()
      options[0] = "Random"
      (1..<128).forEach { options[$0] = "\($0-64)"}
      return options
    }()
    
    const destOptions = ["Off","Insert Param 1", "Insert Param 2", "Insert Param 3", "Insert Param 4", "Insert Param 5", "Insert Param 6", "Insert Param 7", "Insert Param 8", "Insert Param 9", "Insert Param 10", "Insert Param 11", "Insert Param 12", "Insert Param 13", "Insert Param 14", "Ins->Rev", "Ins->Vari", "Volume", "Pan", "Rev Send", "Var Send", "Flt Cutoff", "Flt Reson", "Flt EG Depth", "Attack", "Decay", "Release", "Pitch EG Init", "Pitch EG Attack", "Pitch EG Rel Level", "Pitch EG Rel Time", "V/N Balance", "Formant", "FM", "Pitch Bias", "Amp EG Bias", "Freq Bias", "Voiced BW", "Unvoiced BW", "LFO1 Pitch Mod", "LFO1 Amp Mod", "LFO1 Freq Mod", "LFO1 Filter Mod", "LFO1 Speed", "LFO2 Filter Mod", "LFO2 Speed", "Fseq Speed", "Formant Scratch"]
    
    const reverbOptions = ["None", "Hall 1", "Hall 2", "Room 1", "Room 2", "Room 3", "Stage 1", "Stage 2", "Plate", "White Room", "Tunnel", "Basement", "Canyon", "Delay LCR", "Delay L,R", "Echo", "Cross Delay",]

    const varyOptions = ["None", "Chorus", "Celeste", "Flanger", "Symphonic", "Phaser 1", "Phaser 2", "Ens Detune", "Rotary Sp", "Tremolo", "Auto Pan", "Auto Wah", "Touch Wah", "3-Band EQ", "HM Enhancer", "Noise Gate", "Compressor", "Distortion", "Overdrive", "Amp Sim", "Delay LCR", "Delay L,R", "Echo", "Cross Delay", "Karaoke", "Hall", "Room", "Stage", "Plate"]

    const insertOptions = ["Thru", "Chorus", "Celeste", "Flanger", "Symphonic", "Phaser 1", "Phaser 2", "Pitch Chng", "Ens Detune", "Rotary Sp", "2 Way Rotary", "Tremolo", "Auto Pan", "Ambience", "A-Wah+Dist", "A-Wah+Odrv", "T-Wah+Dist", "T-Wah+Odrv", "Wah+DS+Dly", "Wah+OD+Dly", "Lo-Fi", "3-Band EQ", "HM Enhncr", "Noise Gate", "Compressor", "Comp+Dist", "Cmp+DS+Dly", "Cmp+OD+Dly", "Distortion", "Dist+Dly", "Overdrive", "Ovdrv+Dly", "Amp Sim", "Delay LCR", "Delay L,R", "Echo", "CrossDelay", "ER 1", "ER 2", "Gate Rev", "Revrs Gate"]
    
    const eqShapeOptions = ["Shelv", "Peak"]
    const eqQOptions = optionsDict(1...120) { String(format: "%.1f", Float($0) / 10) }
    
    const reverbTimeParam = OptionsParam(options: OptionsParam.makeOptions({
      var options = [String]()
      options += (0...47).map { "\(0.3 + Float($0) * 0.1)"}
      options += (48...57).map { "\(5.0 + Float($0-47) * 0.5)"}
      options += (58...67).map { "\(10.0 + Float($0-57) * 1)"}
      options += (68...69).map { "\(20.0 + Float($0-67) * 5)"}
      return options
    }()))
    
    const delay200Param = OptionsParam(options: OptionsParam.makeOptions({
      return (0...127).map { String(format: "%.1f", (0.1 + (Float($0)/127) * 199.9))}
    }()))

    const revDelayParam = OptionsParam(options: OptionsParam.makeOptions({
      return (0...63).map { String(format: "%.1f", (0.1 + (Float($0)/63) * 99.2))}
      }()))
    
    const hiDampParam = OptionsParam(options: {
      var opts = [Int:String]()
      (1...10).forEach { opts[$0] = String(format: "%.1f", (Float($0) * 0.1))}
      return opts
      }())
    
    const gainParam = RangeParam(rng: [52, 76+1], displayOffset: -64)

    const cutoffOptions = ["thru","22","25","28","32","36","40","45","50","56","63","70", "80","90","100","110","125","140","160","180","200","225","250","280","315","355","400","450","500","560", "630","700","800","900","1.0k","1.1k","1.2k","1.4k","1.6k","1.8k","2.0k","2.2k","2.5k", "2.8k","3.2k","3.6k","4.0k","4.5k","5.0k","5.6k","6.3k","7.0k","8.0k","9.0k", "10.0k", "11.0k", "12.0k", "14.0k", "16.0k", "18.0k", "thru"]

    static func optionsDict(_ range: CountableClosedRange<Int>, _ options: [String]) -> [Int:String] {
      var o = [Int:String]()
      range.forEach { o[$0] = options[$0] }
      return o
    }
    
    static func optionsDict(_ range: CountableClosedRange<Int>, _ transform: (Int) -> String) -> [Int:String] {
      var opts = [Int:String]()
      range.forEach { opts[$0] = transform($0) }
      return opts
    }
    
    const hpfCutoffParam = OptionsParam(options: optionsDict(0...52, cutoffOptions))
    const lpfCutoffParam = OptionsParam(options: optionsDict(34...60, cutoffOptions))
    const eqLoFreqParam = OptionsParam(options: optionsDict(4...40, cutoffOptions))
    const eqHiFreqParam = OptionsParam(options: optionsDict(28...58, cutoffOptions))
    const eqMidFreqParam = OptionsParam(options: optionsDict(14...54, cutoffOptions))

    const qParam = OptionsParam(options: optionsDict(10...120, { String(format: "%.1f", Float($0) / 10) }))

    const erRevParam = OptionsParam(options: {
      var opts = [Int:String]()
      (1...63).forEach { opts[$0] = "E\(64-$0)>R"}
      opts[64] = "E=R"
      (65...127).forEach { opts[$0] = "E<R\($0-64)"}
      return opts
      }())
    
    const dimOptions = ["0.5", "0.8", "1.0", "1.3", "1.5", "1.8", "2.0", "2.3", "2.6", "2.8", "3.1", "3.3", "3.6", "3.9", "4.1", "4.4", "4.6", "4.9", "5.2", "5.4", "5.7", "5.9", "6.2", "6.5", "6.7", "7.0", "7.2", "7.5", "7.8", "8.0", "8.3", "8.6", "8.8", "9.1", "9.4", "9.6", "9.9", "10.2", "10.4", "10.7", "11.0", "11.2", "11.5", "11.8", "12.1", "12.3", "12.6", "12.9", "13.1", "13.4", "13.7", "14.0", "14.2", "14.5", "14.8", "15.1", "15.4", "15.6", "15.9", "16.2", "16.5", "16.8", "17.1", "17.3", "17.6", "17.9", "18.2", "18.5", "18.8", "19.1", "19.4", "19.7", "20.0", "20.2", "20.5", "20.8", "21.1", "21.4", "21.7", "22.0", "22.4", "22.7", "23.0", "23.3", "23.6", "23.9", "24.2", "24.5", "24.9", "25.2", "25.5", "25.8", "26.1", "26.5", "26.8", "27.1", "27.5", "27.8", "28.1", "28.5", "28.8", "29.2", "29.5", "29.9", "30.2"]
    const widthParam = OptionsParam(options: {
      var options = [Int:String]()
      (0...37).forEach { options[$0] = dimOptions[$0] }
      return options
    }())
    const heightParam = OptionsParam(options: {
      var options = [Int:String]()
      (0...73).forEach { options[$0] = dimOptions[$0] }
      return options
    }())
    const depthParam = OptionsParam(options: {
      var options = [Int:String]()
      (0...104).forEach { options[$0] = dimOptions[$0] }
      return options
    }())

    const delay1365Param = OptionsParam(options: {
      var opts = [Int:String]()
      (1...13650).forEach { opts[$0] = String(format: "%.1f", (Float($0) / 10))}
      return opts
    }())
    // 1: 0.1

    private struct Pairs {
      const loFreq: (String,Param) = ("EQ LowFreq", eqLoFreqParam)
      const loGain: (String,Param) = ("EQ Low Gain", gainParam)
      const hiFreq: (String,Param) = ("EQ HiFreq", eqHiFreqParam)
      const hiGain: (String,Param) = ("EQ Hi Gain", gainParam)
      const hiDamp: (String,Param) = ("High Damp", hiDampParam)

      const midFreq: (String,Param) = ("Mid Freq", eqMidFreqParam)
      const midGain: (String,Param) = ("Mid Gain", gainParam)
      const midQ: (String,Param) = ("Mid Q", qParam)

      const lfoFreq: (String,Param) = ("LFO Freq", RangeParam())
      const lfoDepth: (String,Param) = ("LFO Depth", RangeParam())
      const fbLevel: (String,Param) = ("FB Level", RangeParam(rng: [1, 127+1], displayOffset: -64))
      const mode: (String,Param) = ("Mode", RangeParam())

      const delayOffset: (String,Param) = ("Delay Ofst", RangeParam())
      const phaseShift: (String,Param) = ("Phase Shift", RangeParam())

      const dryWet: (String,Param) = ("Dry/Wet", RangeParam())

      const drive: (String,Param) = ("Drive", RangeParam())
      const distLoGain: (String,Param) = ("DS Low Gain", gainParam)
      const distMidGain: (String,Param) = ("DS Mid Gain", gainParam)
      const lpfCutoff: (String,Param) = ("LPF Cutoff", RangeParam())
      const outLevel: (String,Param) = ("Output Level", RangeParam())

      const cutoff: (String,Param) = ("Cutoff", RangeParam())
      const reson: (String,Param) = ("Reson", RangeParam())
      const sens: (String,Param) = ("Sensitivity", RangeParam())

      const delay: (String,Param) = ("Delay", RangeParam())
      const leftDelay: (String,Param) = ("LchDelay", delay1365Param)
      const rightDelay: (String,Param) = ("RchDelay", delay1365Param)
      const centerDelay: (String,Param) = ("CchDelay", delay1365Param)
      const fbDelay: (String,Param) = ("FB Delay", delay1365Param)

    }
    
    // MARK: Reverb Params
    
    const reverbParams: [[Int:(String,Param)]] = [
      [:],
      hallParams, // hall 1
      hallParams, // hall 2
      hallParams, // room 1
      hallParams, // room 2
      hallParams, // room 3
      hallParams, // stage 1
      hallParams, // stage 2
      hallParams, // plate
      whiteRoomParams, // white room
      whiteRoomParams, // tunnel
      whiteRoomParams, // basement
      whiteRoomParams, // canyon
      delayLCRParams,
      delayLRParams,
      echoParams,
      crossDelayParams,
    ]
    
    const hallParams: [Int:(String,Param)] = [
      0 : ("Time", reverbTimeParam),
      1 : ("Diffusion", RangeParam(maxVal: 10)),
      2 : ("InitDelay", delay200Param),
      3 : ("HPF Cutoff", hpfCutoffParam),
      4 : ("LPF Cutoff", lpfCutoffParam),
      10 : ("Rev Delay", revDelayParam),
      11 : ("Density", RangeParam(maxVal: 4)),
      12 : ("ER/Rev", erRevParam),
      13 : Pairs.hiDamp,
      14 : Pairs.fbLevel,
    ]
    
    const whiteRoomParams: [Int:(String,Param)] = [
      0 : ("Time", reverbTimeParam),
      1 : ("Diffusion", RangeParam(maxVal: 10)),
      2 : ("InitDelay", delay200Param),
      3 : ("HPF Cutoff", hpfCutoffParam),
      4 : ("LPF Cutoff", lpfCutoffParam),
      5 : ("Width", widthParam),
      6 : ("Height", heightParam),
      7 : ("Depth", depthParam),
      8 : ("Wall Vary", RangeParam(maxVal: 30)),
      10 : ("Rev Delay", revDelayParam),
      11 : ("Density", RangeParam(maxVal: 4)),
      12 : ("ER/Rev", erRevParam),
      13 : Pairs.hiDamp,
      14 : Pairs.fbLevel,
      ]

    const delayLCRParams: [Int:(String,Param)] = [
      0 : Pairs.leftDelay,
      1 : Pairs.rightDelay,
      2 : Pairs.centerDelay,
      3 : Pairs.fbDelay,
      4 : Pairs.fbLevel,
      5 : ("CchLevel", RangeParam()),
      6 : Pairs.hiDamp,
      12 : Pairs.loFreq,
      13 : Pairs.loGain,
      14 : Pairs.hiFreq,
      15 : Pairs.hiGain,
      ]

    const delayLRParams: [Int:(String,Param)] = [
      0 : Pairs.leftDelay,
      1 : Pairs.rightDelay,
      2 : ("FBDelay1", RangeParam()),
      3 : ("FBDelay2", RangeParam()),
      4 : Pairs.fbLevel,
      5 : Pairs.hiDamp,
      12 : Pairs.loFreq,
      13 : Pairs.loGain,
      14 : Pairs.hiFreq,
      15 : Pairs.hiGain,
      ]
    
    const echoParams: [Int:(String,Param)] = [
      0 : Pairs.leftDelay,
      1 : ("Lch FB Lvl", RangeParam()),
      2 : Pairs.rightDelay,
      3 : ("Rch FB Lvl", RangeParam()),
      4 : Pairs.hiDamp,
      5 : ("LchDelay2", RangeParam()),
      6 : ("RchDelay2", RangeParam()),
      7 : ("Delay2 Lvl", RangeParam()),
      12 : Pairs.loFreq,
      13 : Pairs.loGain,
      14 : Pairs.hiFreq,
      15 : Pairs.hiGain,
      ]

    const crossDelayParams: [Int:(String,Param)] = [
      0 : ("L>R Delay", RangeParam()),
      1 : ("R>L Delay", RangeParam()),
      2 : Pairs.fbLevel,
      3 : ("InputSelect", RangeParam()),
      4 : Pairs.hiDamp,
      12 : Pairs.loFreq,
      13 : Pairs.loGain,
      14 : Pairs.hiFreq,
      15 : Pairs.hiGain,
      ]
    
    // MARK: Variation Params
    
    const varyParams: [[Int:(String,Param)]] = [
      [:],
      chorusParams,
      chorusParams, // celeste
      flangerParams,
      symphParams,
      phaser1Params,
      phaser2Params,
      ensDetuneParams,
      rotarySpParams,
      tremoloParams,
      autoPanParams,
      autoWahParams,
      touchWahParams,
      triBandEQParams,
      hmEnhancerParams,
      noiseGateParams,
      compressorParams,
      distortionParams,
      distortionParams, // overdrive
      ampSimParams,
      delayLCRParams,
      delayLRParams,
      echoParams,
      crossDelayParams,
      karaokeParams,
      hallParams, // hall
      hallParams, // room
      hallParams, // stage
      hallParams, // plate
      ]
    
    const chorusParams: [Int:(String,Param)] = [
      0 : Pairs.lfoFreq,
      1 : Pairs.lfoDepth,
      2 : Pairs.fbLevel,
      3 : Pairs.delayOffset,
      5 : Pairs.loFreq,
      6 : Pairs.loGain,
      7 : Pairs.hiFreq,
      8 : Pairs.hiGain,
      14 : Pairs.mode,
      ]

    const flangerParams: [Int:(String,Param)] = [
      0 : Pairs.lfoFreq,
      1 : Pairs.lfoDepth,
      2 : Pairs.fbLevel,
      3 : Pairs.delayOffset,
      5 : Pairs.loFreq,
      6 : Pairs.loGain,
      7 : Pairs.hiFreq,
      8 : Pairs.hiGain,
      13 : ("LFO Phase", RangeParam()),
    ]

    const symphParams: [Int:(String,Param)] = [
      0 : Pairs.lfoFreq,
      1 : Pairs.lfoDepth,
      2 : Pairs.delayOffset,
      5 : Pairs.loFreq,
      6 : Pairs.loGain,
      7 : Pairs.hiFreq,
      8 : Pairs.hiGain,
      ]
    
    const phaser1Params: [Int:(String,Param)] = [
      0 : Pairs.lfoFreq,
      1 : Pairs.lfoDepth,
      2 : Pairs.phaseShift,
      3 : Pairs.fbLevel,
      10 : ("Stage",RangeParam()),
      11 : ("Diffuse",RangeParam()),
      5 : Pairs.loFreq,
      6 : Pairs.loGain,
      7 : Pairs.hiFreq,
      8 : Pairs.hiGain,
      ]

    const phaser2Params: [Int:(String,Param)] = [
      0 : Pairs.lfoFreq,
      1 : Pairs.lfoDepth,
      2 : Pairs.phaseShift,
      3 : Pairs.fbLevel,
      10 : ("Stage",RangeParam()),
      12 : ("LFO Phase", RangeParam()),
      5 : Pairs.loFreq,
      6 : Pairs.loGain,
      7 : Pairs.hiFreq,
      8 : Pairs.hiGain,
      ]

    const ensDetuneParams: [Int:(String,Param)] = [
      0 : ("Detune",RangeParam()),
      1 : ("InitDelayL",RangeParam()),
      2 : ("InitDelayR",RangeParam()),
      10 : Pairs.loFreq,
      11 : Pairs.loGain,
      12 : Pairs.hiFreq,
      13 : Pairs.hiGain,
      ]
    
    const rotarySpParams: [Int:(String,Param)] = [
      0 : Pairs.lfoFreq,
      1 : Pairs.lfoDepth,
      5 : Pairs.loFreq,
      6 : Pairs.loGain,
      7 : Pairs.hiFreq,
      8 : Pairs.hiGain,
      ]
    
    const tremoloParams: [Int:(String,Param)] = [
      0 : Pairs.lfoFreq,
      1 : ("AM Depth", RangeParam()),
      2 : ("PM Depth", RangeParam()),
      13 : ("LFO Phase", RangeParam()),
      5 : Pairs.loFreq,
      6 : Pairs.loGain,
      7 : Pairs.hiFreq,
      8 : Pairs.hiGain,
      14 : Pairs.mode,
    ]
    
    const autoPanParams: [Int:(String,Param)] = [
      0 : Pairs.lfoFreq,
      1 : ("L/R Depth", RangeParam()),
      2 : ("F/R Depth", RangeParam()),
      3 : ("Pan Dir", RangeParam()),
      5 : Pairs.loFreq,
      6 : Pairs.loGain,
      7 : Pairs.hiFreq,
      8 : Pairs.hiGain,
    ]
    
    const autoWahParams: [Int:(String,Param)] = [
      0 : Pairs.lfoFreq,
      1 : Pairs.lfoDepth,
      2 : ("Cutoff", RangeParam()),
      3 : ("Reson", RangeParam()),
      5 : Pairs.loFreq,
      6 : Pairs.loGain,
      7 : Pairs.hiFreq,
      8 : Pairs.hiGain,
    ]
    
    const touchWahParams: [Int:(String,Param)] = [
      0 : ("Sensitivity", RangeParam()),
      1 : ("Cutoff", RangeParam()),
      2 : ("Reson", RangeParam()),
      5 : Pairs.loFreq,
      6 : Pairs.loGain,
      7 : Pairs.hiFreq,
      8 : Pairs.hiGain,
    ]
    
    const triBandEQParams: [Int:(String,Param)] = [
      5 : Pairs.loFreq,
      0 : Pairs.loGain,
      1 : Pairs.midFreq,
      2 : Pairs.midGain,
      3 : Pairs.midQ,
      6 : Pairs.hiFreq,
      4 : Pairs.hiGain,
      14 : Pairs.mode,
    ]
    
    const hmEnhancerParams: [Int:(String,Param)] = [
      0 : ("HPF Cutoff", RangeParam()),
      1 : ("Drive", RangeParam()),
      2 : ("Mix Level", RangeParam()),
    ]
    
    const noiseGateParams: [Int:(String,Param)] = [
      0 : ("Attack", RangeParam()),
      1 : ("Release", RangeParam()),
      2 : ("Threshold", RangeParam()),
      3 : ("Output Level", RangeParam()),
    ]
    
    const compressorParams: [Int:(String,Param)] = [
      0 : ("Attack", RangeParam()),
      1 : ("Release", RangeParam()),
      2 : ("Threshold", RangeParam()),
      3 : ("Ratio", RangeParam()),
      4 : ("Output Level", RangeParam()),
    ]
    
    const distortionParams: [Int:(String,Param)] = [
      0 : Pairs.drive,
      1 : Pairs.loFreq,
      2 : Pairs.loGain,
      6 : Pairs.midFreq,
      7 : Pairs.midGain,
      8 : Pairs.midQ,
      3 : Pairs.lpfCutoff,
      10 : ("Edge", RangeParam()),
      4 : Pairs.outLevel,
    ]
    
    const ampSimParams: [Int:(String,Param)] = [
      0 : Pairs.drive,
      1 : ("Amp Type", RangeParam()),
      2 : Pairs.lpfCutoff,
      10 : ("Edge", RangeParam()),
      3 : Pairs.outLevel,
    ]
    
    const karaokeParams: [Int:(String,Param)] = [
      0 : ("Delay Time", RangeParam()),
      1 : Pairs.fbLevel,
      2 : ("HPF Cutoff", RangeParam()),
      3 : ("LPF Cutoff", RangeParam()),
      ]
    
    // MARK: Insert Params
    
    const insertParams: [[Int:(String,Param)]] = [
      [:],
      Insert.chorusParams,
      Insert.chorusParams, // celeste
      Insert.flangerParams,
      Insert.symphParams,
      Insert.phaser1Params,
      Insert.phaser2Params,
      Insert.pitchChangeParams,
      Insert.ensDetuneParams,
      Insert.rotarySpParams,
      Insert.twoWayRotaryParams,
      Insert.tremoloParams,
      Insert.autoPanParams,
      Insert.ambienceParams,
      Insert.autoWahDistParams,
      Insert.autoWahDistParams, // autowah/OD
      Insert.touchWahDistParams,
      Insert.touchWahDistParams, // touchwah/OD
      Insert.wahDistDelayParams,
      Insert.wahDistDelayParams, // wah/OD/delay
      Insert.loFiParams,
      Insert.triBandEQParams,
      Insert.hmEnhancerParams,
      noiseGateParams,
      compressorParams,
      Insert.compDistParams,
      Insert.compDistDelayParams,
      Insert.compDistDelayParams, // comp/OD/delay
      Insert.distortionParams,
      Insert.distDelayParams,
      Insert.distortionParams, // overdrive
      Insert.distDelayParams, // OD/delay
      Insert.ampSimParams,
      Insert.delayLCRParams,
      Insert.delayLRParams,
      Insert.echoParams,
      Insert.crossDelayParams,
      Insert.er1Params,
      Insert.er1Params, // ER 2
      Insert.gateRevParams,
      Insert.gateRevParams, // reverse gate
    ]
    
    private struct Insert {
      
      const chorusParams: [Int:(String,Param)] = [
        0 : Pairs.lfoFreq,
        1 : Pairs.lfoDepth,
        2 : Pairs.fbLevel,
        3 : Pairs.delayOffset,
        5 : Pairs.loFreq,
        6 : Pairs.loGain,
        10 : Pairs.midFreq,
        11 : Pairs.midGain,
        12 : Pairs.midQ,
        7 : Pairs.hiFreq,
        8 : Pairs.hiGain,
        14 : Pairs.mode,
        9 : Pairs.dryWet,
      ]
      
      const flangerParams: [Int:(String,Param)] = [
        0 : Pairs.lfoFreq,
        1 : Pairs.lfoDepth,
        2 : Pairs.fbLevel,
        3 : Pairs.delayOffset,
        5 : Pairs.loFreq,
        6 : Pairs.loGain,
        10 : Pairs.midFreq,
        11 : Pairs.midGain,
        12 : Pairs.midQ,
        7 : Pairs.hiFreq,
        8 : Pairs.hiGain,
        13 : ("LFO Phase", RangeParam()),
        9 : Pairs.dryWet,
      ]
      
      const symphParams: [Int:(String,Param)] = [
        0 : Pairs.lfoFreq,
        1 : Pairs.lfoDepth,
        2 : Pairs.delayOffset,
        5 : Pairs.loFreq,
        6 : Pairs.loGain,
        10 : Pairs.midFreq,
        11 : Pairs.midGain,
        12 : Pairs.midQ,
        7 : Pairs.hiFreq,
        8 : Pairs.hiGain,
        9 : Pairs.dryWet,
      ]
      
      const phaser1Params: [Int:(String,Param)] = [
        0 : Pairs.lfoFreq,
        1 : Pairs.lfoDepth,
        2 : Pairs.phaseShift,
        3 : Pairs.fbLevel,
        10 : ("Stage",RangeParam()),
        11 : ("Diffuse",RangeParam()),
        5 : Pairs.loFreq,
        6 : Pairs.loGain,
        7 : Pairs.hiFreq,
        8 : Pairs.hiGain,
        9 : Pairs.dryWet,
      ]
      
      const phaser2Params: [Int:(String,Param)] = [
        0 : Pairs.lfoFreq,
        1 : Pairs.lfoDepth,
        2 : Pairs.phaseShift,
        3 : Pairs.fbLevel,
        10 : ("Stage",RangeParam()),
        12 : ("LFO Phase", RangeParam()),
        5 : Pairs.loFreq,
        6 : Pairs.loGain,
        7 : Pairs.hiFreq,
        8 : Pairs.hiGain,
        9 : Pairs.dryWet,
        ]
      
      const pitchChangeParams: [Int:(String,Param)] = [
        0 : ("Pitch",RangeParam()),
        1 : ("Init Delay", RangeParam()),
        2 : ("Fine 1",RangeParam()),
        3 : ("Fine 2", RangeParam()),
        4 : Pairs.fbLevel,
        10 : ("Pan 1", RangeParam()),
        11 : ("Out Level 1", RangeParam()),
        12 : ("Pan 2",RangeParam()),
        13 : ("Out Level 2", RangeParam()),
        9 : Pairs.dryWet,
      ]
      
      const ensDetuneParams: [Int:(String,Param)] = [
        0 : ("Detune",RangeParam()),
        1 : ("InitDelayL",RangeParam()),
        2 : ("InitDelayR",RangeParam()),
        10 : Pairs.loFreq,
        11 : Pairs.loGain,
        12 : Pairs.hiFreq,
        13 : Pairs.hiGain,
        9 : Pairs.dryWet,
      ]
      
      const rotarySpParams: [Int:(String,Param)] = [
        0 : Pairs.lfoFreq,
        1 : Pairs.lfoDepth,
        5 : Pairs.loFreq,
        6 : Pairs.loGain,
        10 : Pairs.midFreq,
        11 : Pairs.midGain,
        12 : Pairs.midQ,
        7 : Pairs.hiFreq,
        8 : Pairs.hiGain,
        9 : Pairs.dryWet,
      ]
      
      const twoWayRotaryParams: [Int:(String,Param)] = [
        0 : ("Rotor Spd",RangeParam()),
        1 : ("Drive Low",RangeParam()),
        2 : ("Drive Hi",RangeParam()),
        3 : ("Low/High",RangeParam()),
        11 : ("Mic Angle",RangeParam()),
        10 : ("CrossFreq",RangeParam()),
        5 : Pairs.loFreq,
        6 : Pairs.loGain,
        7 : Pairs.hiFreq,
        8 : Pairs.hiGain,
      ]
      
      const tremoloParams: [Int:(String,Param)] = [
        0 : Pairs.lfoFreq,
        1 : ("AM Depth", RangeParam()),
        2 : ("PM Depth", RangeParam()),
        13 : ("LFO Phase", RangeParam()),
        5 : Pairs.loFreq,
        6 : Pairs.loGain,
        10 : Pairs.midFreq,
        11 : Pairs.midGain,
        12 : Pairs.midQ,
        7 : Pairs.hiFreq,
        8 : Pairs.hiGain,
        14 : Pairs.mode,
      ]
      
      const autoPanParams: [Int:(String,Param)] = [
        0 : Pairs.lfoFreq,
        1 : ("L/R Depth", RangeParam()),
        2 : ("F/R Depth", RangeParam()),
        3 : ("Pan Dir", RangeParam()),
        5 : Pairs.loFreq,
        6 : Pairs.loGain,
        10 : Pairs.midFreq,
        11 : Pairs.midGain,
        12 : Pairs.midQ,
        7 : Pairs.hiFreq,
        8 : Pairs.hiGain,
      ]
      
      const ambienceParams: [Int:(String,Param)] = [
        0 : ("Delay Time", RangeParam()),
        1 : ("Phase", RangeParam()),
        5 : Pairs.loFreq,
        6 : Pairs.loGain,
        7 : Pairs.hiFreq,
        8 : Pairs.hiGain,
        9 : Pairs.dryWet,
      ]
      
      const autoWahDistParams: [Int:(String,Param)] = [
        0 : Pairs.lfoFreq,
        1 : Pairs.lfoDepth,
        2 : Pairs.cutoff,
        3 : Pairs.reson,
        5 : Pairs.loFreq,
        6 : Pairs.loGain,
        7 : Pairs.hiFreq,
        8 : Pairs.hiGain,
        10 : Pairs.drive,
        11 : Pairs.distLoGain,
        12 : Pairs.distMidGain,
        13 : Pairs.lpfCutoff,
        14 : Pairs.outLevel,
        9 : Pairs.dryWet,
      ]
      
      const touchWahDistParams: [Int:(String,Param)] = [
        0 : Pairs.sens,
        1 : Pairs.cutoff,
        2 : Pairs.reson,
        15 : ("Release", RangeParam()),
        5 : Pairs.loFreq,
        6 : Pairs.loGain,
        7 : Pairs.hiFreq,
        8 : Pairs.hiGain,
        10 : Pairs.drive,
        11 : Pairs.distLoGain,
        12 : Pairs.distMidGain,
        13 : Pairs.lpfCutoff,
        14 : Pairs.outLevel,
        9 : Pairs.dryWet,
      ]
      
      const wahDistDelayParams: [Int:(String,Param)] = [
        10 : Pairs.sens,
        11 : Pairs.cutoff,
        12 : Pairs.reson,
        13 : ("Release", RangeParam()),
        3 : Pairs.drive,
        4 : Pairs.outLevel,
        5 : Pairs.distLoGain,
        6 : Pairs.distMidGain,
        0 : Pairs.delay,
        1 : Pairs.fbLevel,
        2 : ("Delay Mix", RangeParam()),
        9 : Pairs.dryWet,
      ]
      
      const loFiParams: [Int:(String,Param)] = [
        0 : ("Smpl Freq", RangeParam()),
        1 : ("Word Length", RangeParam()),
        2 : ("Output Gain", RangeParam()),
        3 : Pairs.lpfCutoff,
        5 : ("LPF Reso", RangeParam()),
        4 : ("Filter", RangeParam()),
        6 : ("Bit Assign", RangeParam()),
        7 : ("Emphasis", RangeParam()),
        9 : Pairs.dryWet,
      ]
      
      const triBandEQParams: [Int:(String,Param)] = [
        5 : Pairs.loFreq,
        0 : Pairs.loGain,
        1 : Pairs.midFreq,
        2 : Pairs.midGain,
        3 : Pairs.midQ,
        6 : Pairs.hiFreq,
        4 : Pairs.hiGain,
        14 : Pairs.mode,
      ]
      
      const hmEnhancerParams: [Int:(String,Param)] = [
        0 : ("HPF Cutoff", RangeParam()),
        1 : Pairs.drive,
        2 : ("Mix Level", RangeParam()),
      ]
      
      const compDistParams: [Int:(String,Param)] = [
        11 : ("Attack", RangeParam()),
        12 : ("Release", RangeParam()),
        13 : ("Threshold", RangeParam()),
        14 : ("Ratio", RangeParam()),
        0 : Pairs.drive,
        1 : Pairs.loFreq,
        2 : Pairs.loGain,
        6 : Pairs.midFreq,
        7 : Pairs.midGain,
        8 : Pairs.midQ,
        3 : Pairs.lpfCutoff,
        10 : ("Edge", RangeParam()),
        4 : Pairs.outLevel,
        9 : Pairs.dryWet,
      ]
      
      const compDistDelayParams: [Int:(String,Param)] = [
        10 : ("Attack", RangeParam()),
        11 : ("Release", RangeParam()),
        12 : ("Threshold", RangeParam()),
        13 : ("Ratio", RangeParam()),
        3 : Pairs.drive,
        4 : Pairs.outLevel,
        5 : Pairs.distLoGain,
        6 : Pairs.distMidGain,
        0 : Pairs.delay,
        1 : Pairs.fbLevel,
        2 : ("Delay Mix", RangeParam()),
        9 : Pairs.dryWet,
      ]
      
      const distortionParams: [Int:(String,Param)] = [
        0 : Pairs.drive,
        1 : Pairs.loFreq,
        2 : Pairs.loGain,
        6 : Pairs.midFreq,
        7 : Pairs.midGain,
        8 : Pairs.midQ,
        3 : Pairs.lpfCutoff,
        10 : ("Edge", RangeParam()),
        4 : Pairs.outLevel,
        9 : Pairs.dryWet,
      ]
      
      const distDelayParams: [Int:(String,Param)] = [
        5 : Pairs.drive,
        7 : Pairs.distLoGain,
        8 : Pairs.distMidGain,
        0 : ("LchDelay", RangeParam()),
        1 : ("RchDelay", RangeParam()),
        2 : ("FB Delay", RangeParam()),
        3 : Pairs.fbLevel,
        4 : ("Delay Mix", RangeParam()),
        6 : Pairs.outLevel,
        9 : Pairs.dryWet,
        ]
      
      const ampSimParams: [Int:(String,Param)] = [
        0 : Pairs.drive,
        1 : ("Amp Type", RangeParam()),
        2 : Pairs.lpfCutoff,
        10 : ("Edge", RangeParam()),
        3 : Pairs.outLevel,
        9 : Pairs.dryWet,
      ]
      
      const delayLCRParams: [Int:(String,Param)] = [
        0 : Pairs.leftDelay,
        1 : Pairs.rightDelay,
        2 : Pairs.centerDelay,
        3 : Pairs.fbDelay,
        4 : Pairs.fbLevel,
        5 : ("CchLevel", RangeParam()),
        6 : Pairs.hiDamp,
        12 : Pairs.loFreq,
        13 : Pairs.loGain,
        14 : Pairs.hiFreq,
        15 : Pairs.hiGain,
        9 : Pairs.dryWet,
      ]
      
      const delayLRParams: [Int:(String,Param)] = [
        0 : Pairs.leftDelay,
        1 : Pairs.rightDelay,
        2 : ("FBDelay1", RangeParam()),
        3 : ("FBDelay2", RangeParam()),
        4 : Pairs.fbLevel,
        5 : Pairs.hiDamp,
        12 : Pairs.loFreq,
        13 : Pairs.loGain,
        14 : Pairs.hiFreq,
        15 : Pairs.hiGain,
        9 : Pairs.dryWet,
      ]
      
      const echoParams: [Int:(String,Param)] = [
        0 : Pairs.leftDelay,
        1 : ("Lch FB Lvl", RangeParam()),
        2 : Pairs.rightDelay,
        3 : ("Rch FB Lvl", RangeParam()),
        4 : Pairs.hiDamp,
        5 : ("LchDelay2", RangeParam()),
        6 : ("RchDelay2", RangeParam()),
        7 : ("Delay2 Lvl", RangeParam()),
        12 : Pairs.loFreq,
        13 : Pairs.loGain,
        14 : Pairs.hiFreq,
        15 : Pairs.hiGain,
        9 : Pairs.dryWet,
      ]
      
      const crossDelayParams: [Int:(String,Param)] = [
        0 : ("L>R Delay", RangeParam()),
        1 : ("R>L Delay", RangeParam()),
        2 : Pairs.fbLevel,
        3 : ("InputSelect", RangeParam()),
        4 : Pairs.hiDamp,
        12 : Pairs.loFreq,
        13 : Pairs.loGain,
        14 : Pairs.hiFreq,
        15 : Pairs.hiGain,
        9 : Pairs.dryWet,
      ]
      
      const er1Params: [Int:(String,Param)] = [
        0 : ("Early Type", RangeParam()),
        1 : ("Room Size", RangeParam()),
        2 : ("Diffusion", RangeParam()),
        3 : ("Init Delay", delay200Param),
        4 : Pairs.fbLevel,
        5 : ("HPF Cutoff", RangeParam()),
        6 : Pairs.lpfCutoff,
        10 : ("Liveness", RangeParam()),
        11 : ("Density", RangeParam()),
        12 : Pairs.hiDamp,
        9 : Pairs.dryWet,
      ]
      
      const gateRevParams: [Int:(String,Param)] = [
        0 : ("Gate Type", RangeParam()),
        1 : ("Room Size", RangeParam()),
        2 : ("Diffusion", RangeParam()),
        3 : ("Init Delay", delay200Param),
        4 : Pairs.fbLevel,
        5 : ("HPF Cutoff", RangeParam()),
        6 : Pairs.lpfCutoff,
        10 : ("Liveness", RangeParam()),
        11 : ("Density", RangeParam()),
        12 : Pairs.hiDamp,
        9 : Pairs.dryWet,
      ]
      
      
    }
  }
  
}

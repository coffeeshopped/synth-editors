const lfoWaves = ["Triangle","Saw","Square","Noise"]

const modSources = ["LFO 1", "LFO 2", "LFO 3", "Env 1", "Env 2", "Env 3", "Env 4", "Vel", "Vel 2", "Kybd", "Kybd 2", "Wheel", "Pedal", "Xctrl", "Pressure", "Off"]

const waves = ["Saw", "Bell", "Sine", "Square", "Pulse", "Noise 1", "Noise 2", "Noise 3", "Bass", "Piano", "Electric Piano", "Voice 1", "Voice 2", "Kick", "Reed", "Organ", "Synth 1", "Synth 2", "Synth 3", "Formant 1", "Formant 2", "Formant 3", "Formant 4", "Formant 5", "Pulse 2", "Square 2", "Four Octaves", "Prime", "Bass 2", "Electric Piano 2", "Octave", "Octave +5"]

const programOptions = (40).map(i => `${i + 1}`)

subscript(path: SynthPath) -> Int? {
  get {
    guard let param = type(of: self).params[path] else { return nil }
    let byte = param.byte
    if path.first == .lfo && path.last == .src {
      let v = 0.set(bits: [2, 3], value: bytes[byte].bits([6, 7]))
      return v.set(bits: [0, 1], value: bytes[byte+1].bits([6, 7]))
    }
    else if path.first == .osc && path.last == .octave {
      return Int(bytes[byte] / 12) - 3
    }
    else if path.first == .osc && path.last == .semitone {
      return Int(bytes[byte] % 12)
    }
    else if path == "split/direction" {
      return bytes[98].bit(7) == 0 ? 0 : bytes[96].bit(7) + 1
    }
    else {
      let v = defaultUnpack(param: param)
      if let param = param as? RangeParam,
        let v = v {
        return param.range.lowerBound < 0 && v > 63 ? v - 128 : v
      }
      else {
        return v
      }
    }
  }
  set {
    guard let param = type(of: self).params[path],
      let v = newValue else { return }
    let byte = param.byte
    if path.first == .lfo && path.last == .src {
      bytes[byte] = bytes[byte].set(bits: [6, 7], value: v.bits([2, 3]))
      bytes[byte+1] = bytes[byte+1].set(bits: [6, 7], value: v.bits([0, 1]))
    }
    else if path.first == .osc && path.last == .octave {
      guard let osc = path.i(1) else { return }
      let semi = self["osc/osc/semitone"] ?? 0
      bytes[byte] = UInt8((12 * (v+3)) + semi)
    }
    else if path.first == .osc && path.last == .semitone {
      guard let osc = path.i(1) else { return }
      let octave = self["osc/osc/octave"] ?? 0
      bytes[byte] = UInt8((12 * (octave+3)) + v)
    }
    else if path == "split/direction" {
      bytes[96] = bytes[96].set(bit: 7, value: (v > 0 ? v-1 : 0))
      bytes[98] = bytes[98].set(bit: 7, value: (v > 0 ? 1 : 0))
    }
    else {
      defaultPack(value: v < 0 ? v + 128 : v, forParam: param)
    }
  }
}

const parms = [
  { prefix: 'env', count: 4, bx: 10, px: 10, block: [
    { inc: 1, p: 0, block: [
      ["level/0", { b: 6, bits: [1, 7], rng: [-63, 63] }],
      ["level/1", { b: 7, bits: [1, 7], rng: [-63, 63] }],
      ["level/2", { b: 8, bits: [1, 7], rng: [-63, 63] }],
      ["level/velo", { b: 13, bits: [2, 7], max: 63 }],
      ["time/0/velo", { b: 14, max: 63 }],
      ["time/0", { b: 9, max: 63 }],
      ["time/1", { b: 10, max: 63 }],
      ["time/2", { b: 11, max: 63 }],
      ["time/3", { b: 12, bits: [0, 5], max: 63 }],
      ["time/key", { b: 15, max: 63 }],
    ] },
  ] },
  { prefix: 'lfo', count: 3, bx: 4, px: 8, block: [
    { inc: 1, p: 40, block: [
      { b: 46, offset: [
        ["freq", { b: 0, bits: [0, 5], max: 63 }],
        ["reset", { b: 3, bit: 7 }],
        ["analogFeel", { b: 3, bit: 6 }],
        ["wave", { b: boff, bits: [6, 7], opts: lfoWaves }],
        ["level/0", { b: 1, bits: [0, 5], max: 63 }],
        ["delay", { b: 3, bits: [0, 5], max: 63 }],
        ["level/1", { b: 2, bits: [0, 5], max: 63 }],
        ["mod/src", { b: 1, opts: modSources }],
      ] },
    ] },
  ] },
  { prefix: 'osc', count: 3, bx: 10, px: 8, block: [
    { inc: 1, p: 64, block: [
      { b: 58, offset: [
        ["octave", { b: 0, rng: [-3, 5] }],
        ["semitone", { b: 0, max: 11 }],
        ["fine", { b: 1, bits: [3, 7], max: 31) }],
        ["wave", { b: 5, opts: waves }],
        ["mod/0/src", { b: 2, bits: [0, 3], opts: modSources }],
        ["mod/0/amt", { b: 3, bits: [1, 7], rng: [-63, 63] }],
        ["mod/1/src", { b: 2, bits: [4, 7], opts: modSources }],
        ["mod/1/amt", { b: 4, bits: [1, 7], rng: [-63, 63] }],
      ] },
    ] },
  ] },  
  { prefix: 'amp', count: 3, bx: 10, px: 6, block: [
    { inc: 1, p: 88, block: [
      { b: 58, offset: [
        ["level", { b: 6, bits: [1, 6], max: 63 }],
        ["on", { b: 6, bit: 7 }],
        ["mod/0/src", { b: 7, bits: [0, 3], opts: modSources }],
        ["mod/0/amt", { b: 8, bits: [1, 7], rng: [-63, 63] }],
        ["mod/1/src", { b: 7, bits: [4, 7], opts: modSources }],
        ["mod/1/amt", { b: 9, bits: [1, 7], rng: [-63, 63] }],
      ] },
    ] },
  ] },
  { inc: 1, p: 106, block: [
    ["amp/3/mod/amt", { b: 88, bits: [1, 6], max: 63 }], // chart shows 7 bits, wrong?
    ["pan", { b: 100, bits: [4, 7], max: 15 }],
    ["pan/mod/src", { b: 100, bits: [0, 3], opts: modSources }],
    ["pan/mod/amt", { b: 101, bits: [0, 6], rng: [-63, 63] }],
    ["cutoff", { b: 89, bits: [0, 6], max: 127 }],
    ["reson", { b: 90, max: 31 }],
    ["filter/mod/2/amt", { b: 94, bits: [1, 6], max: 63 }],
    ["filter/mod/0/src", { b: 91, bits: [0, 3], opts: modSources }],
    ["filter/mod/0/amt", { b: 92, bits: [0, 6], rng: [-63, 63] }],
    ["filter/mod/1/src", { b: 91, bits: [4, 7], opts: modSources }],
    ["filter/mod/1/amt", { b: 93, bits: [0, 6], rng: [-63, 63] }],
    ["am", { b: 88, bit: 7 }],
    ["glide", { b: 95, bits: [0, 5], max: 63 }],
    ["mono", { b: 93, bit: 7 }],
    ["sync", { b: 89, bit: 7 }],
    ["rotate", { b: 92, bit: 7 }],
    ["env/reset", { b: 94, bit: 7 }],
    ["wave/reset", { b: 95, bit: 7 }],
    ["cycle", { b: 101, bit: 7 }],
    ["split/layer", { b: 99, bit: 7 }],
    ["split/layer/pgm", { b: 99, bits: [0, 6], opts: programOptions }],
    ["layer", { b: 97, bit: 7 }],
    ["layer/pgm", { b: 97, bits: [0, 6], opts: programOptions }],
    ["split/direction", { b: 96, bit: 7, opts: ["Off","Lower","Upper"] }],
    ["split/pgm", { b: 98, bits: [0, 6], opts: programOptions }],
    ["split/pt", { b: 96, bits: [0, 6], rng: [21, 108] }],
  ] },
}
//    p["split", { p: 0, b: 98, bit: 7)

const sysexData = ['>',
  [['nibblizeLSB']],
  [0xf0, 0x0f, 0x02, 'channel', 0x01, 'b', 0xf7],
]

const patchTruss = {
  single: 'esq.voice',
  bodyDataCount: 102,
  initFile: "ESQ-init",
  parseBody: ['>',
    ['bytes', { start: 5, count: 204 }],
    'denibblizeLSB',
  ],
  parms: parms,
  namePack: {
    type: 'filtered',
    range: [0, 5],
    toBytes: ['upper'],
    toString: ['clean'],
  },
  createFile: sysexData,
}

// const fileDataCount = 210

const bankTruss = {
  singleBank: patchTruss,
  patchCount: 40,
  initFile: 'esq-bank-init',
  validSizes: [8166],
  createFile: {
    wrapper: [0xf0, 0x0f, 0x02, 'channel', 0x02, 'b', 0xf7],
    patchBodyTransform: [['nibblizeLSB']],
  },
  parseBody: {
    offset: 5,
    patchByteCount: 204,
    patchBodyTransform: [['denibblizeLSB']],  
  },
}


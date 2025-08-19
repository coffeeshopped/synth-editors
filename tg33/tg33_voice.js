
const fxOptions = ["Rev Hall","Rev Room","Rev Plate","Rev Club", "Rev Metal", "Delay 1", "Delay 2", "Delay 3", "Doubler", "Ping Pong", "Pan Ref", "Early Ref", "Gate Rev", "Dly&Rev 1", "Dly&Rev 2", "Dist&Rev"]

const envOptions = ["User", "Preset", "Piano", "Guitar", "Pluck", "Brass", "Strings", "Organ"]

const lfoOptions = [
  0x00 : "Saw Down",
  0x20 : "Triangle",
  0x40 : "Square",
  0x60 : "Samp&Hold",
  0x80 : "Saw Up"
]

const panOptions = ["Left", "Left Center", "Center", "Right Center", "Right"]

const speedOptions = (0..<16.map {
  return $0 == 0 ? "160 ms" : `${$0*10} ms`
})

// TODO: these are slightly off. fix.
const options99Values: [Int] = (128).map(i =>  ($0 * 100) / 128 )
const options99 = options99Values.map { `${$0}` }
const inverse99 = options99Values.map { `${99 - $0}` }

const options99for63 = (0..<64.map {
  return $0 < 37 ? `${$0 * 2}` : `${36 + $0}`
})

const signedOptions99for63 = {
  var opts = [Int:String]()
  ([-36, 36]).forEach {
    opts[$0] = `${$0 * 2}`
  }
  ([37, 63]).forEach {
    opts[$0] = `${36 + $0}`
  }
  (-63 ... -37).forEach {
    opts[$0] = `${-36 + $0}`
  }
  return opts
}()

const levelScalingOptions = [
  0x00 : "1",
  0x10 : "2",
  0x20 : "3",
  0x30 : "4",
  0x40 : "5",
  0x50 : "6",
  0x60 : "7",
  0x70 : "8",
  0x80 : "9",
  0x90 : "10",
  0xa0 : "11",
  0xb0 : "12",
  0xc0 : "13",
  0xd0 : "14",
  0xe0 : "15",
  0xf0 : "16",
]

const levelScalingImageOptions = {
  var opts = [Int:String]()
  (0..<16).forEach { opts[$0 * 0x10] = `tg33-ls-${$0+1}` }
  return opts
}()

const rateScalingImageOptions = {
  var opts = [Int:String]()
  (0..<8).forEach { opts[$0] = `tg33-rs-${$0+1}` }
  return opts
}()

const timeOptions = (0..<256.map {
  switch $0 {
  case 254: return "Repeat"
  case 255: return "End"
  default: return `${$0+1}`
  }
})

const startTimeOptions = {
  var opts = timeOptions
  opts[254] = "(invalid)"
  return opts
}()

const opWaveOptions = (7).map(i =>  `${$0+1}` )

const waveOptions = ["Piano", "E.piano", "Clavi", "Cembalo", "Celesta", "P.organ", "E.organ1", "E.organ2", "Reed", "Trumpet", "Mute Trp", "Trombone", "Flugel", "Fr horn", "BrasAtak", "SynBrass", "Flute", "Clarinet", "Oboe", "Sax", "Gut", "Steel", "E.Gtr 1", "E.Gtr 2", "Mute Gtr", "Sitar", "Pluck 1", "Pluck 2", "Wood B 1", "Wood B 2", "E.Bass 1", "E.Bass 2", "E.Bass 3", "E.Bass 4", "Slap", "Fretless", "SynBass1", "SynBass2", "Strings", "Vn.Ens.", "Cello", "Pizz", "Syn Str", "Choir", "Itopia", "Ooo!", "Vibes", "Marimba", "Bells", "Timpani", "Tom", "E. Tom", "Cuica", "Whistle", "Claps", "Hit", "Harmonic", "Mix", "Sync", "Bell Mix", "Styroll", "DigiAtak", "Noise 1", "Noise 2", "Oh Hit", "Water 1", "Water 2", "Stream", "Coin", "Crash", "Bottle", "Tear", "Cracker", "Scratch", "Metal 1", "Metal 2", "Metal 3", "Metal 4", "Wood", "Bamboo", "Slam", "Tp. Body", "Tb. Body", "Horn Body", "Fl. Body", "Str. Body", "AirBlown", "Reverse1", "Reverse2", "Reverse3", "EP wv", "Organ wv", "M.TP wv", "Gtr wv", "Str wv 1", "Str wv 2", "Pad wv", "Digital1", "Digital2", "Digital3", "Digital4", "Digital5", "Saw 1", "Saw 2", "Saw 3", "Saw 4", "Square 1", "Square 2", "Square 3", "Square 4", "Pulse 1", "Pulse 2", "Pulse 3", "Pulse 4", "Pulse 5", "Pulse 6", "Tri", "Sin8'", "Sin8'+4'", "SEQ1", "SEQ 2", "SEQ 3", "SEQ 4", "SEQ 5", "SEQ 6", "SEQ 7", "SEQ 8", "Drum set"]

const fmOptions = ["E.Piano1", "E.Piano2", "E.Piano3", "E.Piano4", "E.Piano5", "E.Piano6", "E.organ1", "E.organ2", "E.organ3", "E.organ4", "E.organ5", "E.organ6", "E.organ7", "E.organ8", "Brass 1", "Brass 2", "Brass 3", "Brass 4", "Brass 5", "Brass 6", "Brass 7", "Brass 8", "Brass 9", "Brass 10", "Brass 11", "Brass 12", "Brass 13", "Brass 14", "Wood 1", "Wood 2", "Wood 3", "Wood 4", "Wood 5", "Wood 6", "Wood 7", "Wood 8", "Reed 1", "Reed 2", "Reed 3", "Reed 4", "Reed 5", "Reed 6", "Clavi 1", "Clavi 2", "Clavi 3", "Clavi 4", "Guitar 1", "Guitar 2", "Guitar 3", "Guitar 4", "Guitar 5", "Guitar 6", "Guitar 7", "Guitar 8", "Bass 1", "Bass 2", "Bass 3", "Bass 4", "Bass 5", "Bass 6", "Bass 7", "Bass 8", "Bass 9", "Str 1", "Str 2", "Str 3", "Sir 4", "Str 5", "Str 6", "Str 7", "Vibes 1", "Vibes 2", "Vibes 3", "Vibes 4", "Marimba1", "Marimba2", "Marimba3", "Bells 1", "Bells 2", "Bells 3", "Bells 4", "Bells 5", "Bells 6", "Bells 7", "Bells 8", "Metal 1", "Metal 2", "Metal 3", "Metal 4", "Metal 5", "Metal 6", "Lead 1", "Lead 2", "Lead 3", "Lead 4", "Lead 5", "Lead 6", "Lead 7", "Sus. 1", "Sus. 2", "Sus. 3", "Sus. 4", "Sus. 5", "Sus. 6", "Sus. 7", "Sus. 8", "Sus. 9", "Sus. 10", "Sus. 11", "Sus. 12", "Sus. 13", "Sus, 14", "Sus. 15", "Attack 1", "Attack 2", "Attack 3", "Attack 4", "Attack 5", "Move 1", "Move 2", "Move 3", "Move 4", "Move 5", "Move 6", "Move 7", "Decay 1", "Decay 2", "Decay 3", "Decay 4", "Decay 5", "Decay 6", "Decay 7", "Decay 8", "Decay 9", "Decay 10", "Decay 11", "Decay 12", "Decay 13", "Decay 14", "Decay 15", "Decay 16", "Decay 17", "Decay 18", "SFX 1", "SFX 2", "SFX 3", "SFX 4", "SFX 5", "SFX 6", "SFX 7", "Sin 16'", "Sin 8'", "Sin 4'", "Sin 2 2/3", "Sin 2'", "Saw 1", "Saw 2", "Square", "LFOnoise", "Noise 1", "Noise 2", "Digi 1", "Digi 2", "Digi 3", "Digi 4", "Digi 5", "Digi 6", "Digi 7", "Digi 8", "Digi 9", "Digi 10", "Digi 11", "wave1-1", "wave1-2", "wave1-3", "wave2-1", "wave2-2", "wave2-3", "wave3-1", "wave3-2", "wave3-3", "wave4-1", "wave4-2", "wave4-3", "wave5-1", "wave5-2", "wave5-3", "wave6-1", "wave6-2", "wave6-3", "wave7-1", "wave7-2", "wave7-3", "wave8-1", "wave8-2", "wave8-3", "wave9-1", "wave9-2", "wave9-3", "wave10-1", "wave10-2", "wave10-3", "wave11-1", "wave11-2", "wave11-3", "wave12-1", "wave12-2", "wave12-3", "wave13-1", "wave13-2", "wave13-3", "wave14-1", "wave14-2", "wave14-3", "wave15-1", "wave15-2", "wave15-3", "wave16-1", "wave16-2", "wave16-3", "wave17-1", "wave17-2", "wave17-3", "wave18-1", "wave18-2", "wave18-3", "wave19-1", "wave19-2", "wave19-3", "wave20-1", "wave20-2", "wave20-3", "wave21-1", "wave21-2", "wave21-3", "wave22-1", "wave22-2", "wave22-3", "wave23-1", "wave23-2", "wave23-3", "wave24-1", "wave24-2", "wave24-3", "wave25-1", "wave25-2", "wave25-3", "wave26-1", "wave26-2", "wave26-3", "wave27-1", "wave27-2", "wave27-3", "wave28", "wave29", "wave30"]

const elemAParms = [
  ["wave", { p: 0x000000, parm2: 0x017f, b: 0x1d, opts: waveOptions }],
  ["note/shift", { p: 0x010001, parm2: 0x017f, b: 0x1f, rng: [-12, 12] }],
  ["aftertouch", { p: 0x050002, parm2: 0x010f, b: 0x20, bits: [4, 6], rng: [-3, 3] }],
  ["velo", { p: 0x040002, parm2: 0x0170, b: 0x20, bits: [0, 3], rng: [-5, 5] }],
  
  // LFO
  ["lfo", { p: 0x070003, parm2: 0x001f, b: 0x21, opts: lfoOptions }],
  ["lfo/speed", { p: 0x090003, parm2: 0x0160, b: 0x22, bits: [0, 4], max: 31 }],
  ["lfo/delay", { p: 0x080004, parm2: 0x017f, b: 0x24, opts: options99 }],
  ["lfo/rate", { p: 0x080005, parm2: 0x017f, b: 0x26, opts: inverse99 }],
  ["lfo/amp/mod", { p: 0x070006, parm2: 0x0170, b: 0x27, bits: [0, 3], max: 15 }],
  ["lfo/pitch/mod", { p: 0x070007, parm2: 0x0160, b: 0x28, bits: [0, 4], max: 31 }],
  ["lfo/amp/mod/on", { b: 0x27, bit: 4 }],
  ["lfo/pitch/mod/on", { b: 0x28, bit: 5 }],
  
  ["pan", { p: 0x030008, parm2: 0x0178, b: 0x29, bits: [0, 2], opts: panOptions }],
  ["volume", { p: 0x020009, parm2: 0x017f, b: 0x2a, opts: inverse99 }],
  
  ["env", { p: 0x000008, parm2: 0x010f, b: 0x29, bits: [4, 6], opts: envOptions }],
  ["env/level/scale", { p: 0x07000b, parm2: 0x000f, b: 0x2c, bits: [0, 3], opts: levelScalingOptions }],
  ["env/rate/scale", { p: 0x08000b, parm2: 0x0178, b: 0x2d, bits: [0, 2], max: 7, dispOff: 1 }],
  ["env/delay", { p: 0x01000c, parm2: 0x007f, b: 0x2e }],
  ["env/attack/rate", { p: 0x03000c, parm2: 0x0140, b: 0x2f, bits: [0, 5], opts: options99for63 }],
  ["env/decay/0/rate", { p: 0x04000d, parm2: 0x0140, b: 0x30, bits: [0, 5], opts: options99for63 }],
  ["env/decay/1/rate", { p: 0x05000e, parm2: 0x0140, b: 0x32, bits: [0, 5], opts: options99for63 }],
  ["env/release/rate", { p: 0x06000f, parm2: 0x0140, b: 0x33, bits: [0, 5], opts: options99for63 }],
  ["env/innit/level", { p: 0x020010, parm2: 0x0100, b: 0x34, opts: inverse99 }],
  ["env/attack/level", { p: 0x030011, parm2: 0x0100, b: 0x35, opts: inverse99 }],
  ["env/decay/0/level", { p: 0x040012, parm2: 0x0100, b: 0x36, opts: inverse99 }],
  ["env/decay/1/level", { p: 0x050013, parm2: 0x0100, b: 0x37, opts: inverse99 }],
  
  // HIDDEN PARAMS
  ["detune", { b: 0x2b, bits: [0, 3], max: 15 }],
  ["scale", { b: 0x2b, bits: [4, 5], max: 3 }],
]

const elemBParms = [
  ["wave", { p: 0x000016, parm2: 0x017f, b: 0x3a, opts: fmOptions }],
  ["note/shift", { p: 0x010017, parm2: 0x017f, b: 0x3d, rng: [-12, 12] }],
  ["aftertouch", { p: 0x050018, parm2: 0x010f, b: 0x3e, bits: [4, 6], rng: [-3, 3] }],
  ["velo", { p: 0x040018, parm2: 0x0170, b: 0x3e, bits: [0, 3], rng: [-5, 5] }],
  
  // LFO
  ["lfo", { p: 0x070019, parm2: 0x001f, b: 0x3f, bits: [5, 6], opts: lfoOptions }],
  ["lfo/speed", { p: 0x090019, parm2: 0x0160, b: 0x40, bits: [0, 4], max: 31 }],
  ["lfo/delay", { p: 0x08001a, parm2: 0x017f, b: 0x41, opts: options99 }],
  ["lfo/rate", { p: 0x08001b, parm2: 0x017f, b: 0x43, opts: inverse99 }],
  ["lfo/amp/mod", { p: 0x07001c, parm2: 0x0170, b: 0x45, bits: [0, 3], max: 15 }],
  ["lfo/pitch/mod", { p: 0x07001d, parm2: 0x0160, b: 0x46, bits: [0, 4], max: 31 }],
  
  ["pan", { p: 0x03001e, parm2: 0x0178, b: 0x47, bits: [0, 2], opts: panOptions }],
  ["feedback", { p: 0x06001f, parm2: 0x0178, b: 0x48, bits: [0, 2], max: 7 }],
  ["tone/level", { p: 0x060021, parm2: 0x017f, b: 0x4b, opts: inverse99 }],
  ["volume", { p: 0x02002d, parm2: 0x017f, b: 0x5b, opts: inverse99 }],
  
  ["env", { p: 0x00001e, parm2: 0x010f, b: 0x47, bits: [4, 6], opts: envOptions }],
  ["env/level/scale", { p: 0x07002f, parm2: 0x000f, b: 0x5d, bits: [4, 6], opts: levelScalingOptions }],
  ["env/rate/scale", { p: 0x08002f, parm2: 0x0178, b: 0x5e, bits: [0, 3], max: 7, dispOff: 1 }],
  ["env/delay", { p: 0x010030, parm2: 0x007f, b: 0x5f }],
  ["env/attack/rate", { p: 0x030030, parm2: 0x0140, b: 0x60, bits: [0, 5], opts: options99for63 }],
  ["env/decay/0/rate", { p: 0x040031, parm2: 0x0140, b: 0x62, bits: [0, 5], opts: options99for63 }],
  ["env/decay/1/rate", { p: 0x050032, parm2: 0x0140, b: 0x63, bits: [0, 5], opts: options99for63 }],
  ["env/release/rate", { p: 0x060033, parm2: 0x0140, b: 0x64, bits: [0, 5], opts: options99for63 }],
  ["env/innit/level", { p: 0x020034, parm2: 0x0100, b: 0x65, opts: inverse99 }],
  ["env/attack/level", { p: 0x030035, parm2: 0x0100, b: 0x66, opts: inverse99 }],
  ["env/decay/0/level", { p: 0x040036, parm2: 0x0100, b: 0x67, opts: inverse99 }],
  ["env/decay/1/level", { p: 0x050037, parm2: 0x0100, b: 0x68, opts: inverse99 }],
  
  // HIDDEN PARAMS
  ["detune", { b: 0x5c, bits: [0, 3], max: 15 }],
  ["scale", { b: 0x5c, bits: [4, 5], max: 3 }],
  
  ["algo", { b: 0x48, bit: 4, opts: ["FM","Mix"] }],
  
  ["wave/type", { b: 0x5a, bits: [4, 6], opts: opWaveOptions }],
  ["ratio", { b: 0x5a, bits: [0, 3], max: 15 }],
  ["fixed", { b: 0x59, bit: 0 }],
  ["amp/mod", { b: 0x45, bit: 5 }],
  ["pitch/mod", { b: 0x46, bit: 6 }],
  
  ["mod/detune", { b: 0x4c, bits: [0, 3], max: 15 }],
  ["mod/scale", { b: 0x4c, bits: [4, 5], max: 3 }],
  ["mod/wave/type", { b: 0x4a, bits: [4, 6], opts: opWaveOptions }],
  ["mod/ratio", { b: 0x4a, bits: [0, 3], max: 15 }],
  ["mod/fixed", { b: 0x49, bit: 0 }],
  ["mod/amp/mod", { b: 0x45, bit: 4 }],
  ["mod/pitch/mod", { b: 0x46, bit: 5 }],
  
  ["mod/env/level/scale", { b: 0x4e, bits: [4, 6], opts: levelScalingOptions }],
  ["mod/env/rate/scale", { b: 0x4e, bits: [0, 3], max: 7, dispOff: 1 }],
  ["mod/env/delay", { b: 0x4f, max: 1 }],
  ["mod/env/attack/rate", { b: 0x50, bits: [0, 5], opts: options99for63 }],
  ["mod/env/decay/0/rate", { b: 0x52, bits: [0, 5], opts: options99for63 }],
  ["mod/env/decay/1/rate", { b: 0x53, bits: [0, 5], opts: options99for63 }],
  ["mod/env/release/rate", { b: 0x54, bits: [0, 5], opts: options99for63 }],
  ["mod/env/innit/level", { b: 0x55, opts: inverse99 }],
  ["mod/env/attack/level", { b: 0x56, opts: inverse99 }],
  ["mod/env/decay/0/level", { b: 0x57, opts: inverse99 }],
  ["mod/env/decay/1/level", { b: 0x58, opts: inverse99 }],
]

const parms = [
  ["common/structure", { p: 0x000000, parm2: 0x017e, b: 0x00, bit: 0, opts: ["A-B","A-B-C-D"] }],
  ["common/fx/type", { p: 0x010001, parm2: 0x017f, b: 0x01, opts: fxOptions }],
  ["common/fx/balance", { p: 0x020002, parm2: 0x017f, b: 0x02 }],
  ["common/fx/send", { p: 0x020006, parm2: 0x017f, b: 0x06 }],
  ["common/bend", { p: 0x030014, parm2: 0x017f, b: 0x14, max: 12 }],
  ["common/aftertouch/level/mod", { p: 0x060015, parm2: 0x013f, b: 0x15, bit: 6 }],
  ["common/aftertouch/pitch/mod", { p: 0x050015, parm2: 0x015f, b: 0x15, bit: 5 }],
  ["common/aftertouch/amp/mod", { p: 0x050015, parm2: 0x016f, b: 0x15, bit: 4 }],
  ["common/modWheel/pitch/mod", { p: 0x040015, parm2: 0x017d, b: 0x15, bit: 1 }],
  ["common/modWheel/amp/mod", { p: 0x040015, parm2: 0x017e, b: 0x15, bit: 0 }],
  ["common/pitch/bias", { p: 0x060016, parm2: 0x017f, b: 0x16, rng: [-12, 12] }],
  ["common/env/delay", { p: 0x010017, parm2: 0x017f, b: 0x18, opts: options99 }],
  ["common/env/attack", { p: 0x070018, parm2: 0x017f, b: 0x19, opts: signedOptions99for63 }],
  ["common/env/release", { p: 0x070019, parm2: 0x017f, b: 0x1b, opts: signedOptions99for63 }],
  
  ["vector/level/speed", { p: 0x000000, parm2: 0x017f, b: 0xb9, opts: speedOptions }],
  ["vector/detune/speed", { p: 0x030001, parm2: 0x017f, b: 0xba, opts: speedOptions }],
  // TODO: either b and p math should always be RolandAddress math, or there needs to be a way to specify when it is/isn't
  { prefix: 'vector/level', count: 50, bx: 4, px: 3, block: (i) => {
    return [
      // parm2 is fixed here.
      ["time", { p: 0x020002, parm2: 0x017f, b: 0xbb, opts: i == 0 ? startTimeOptions : timeOptions }],
      ["x", { p: 0x020003, parm2: 0x017f, b: 0xbd, max: 62, dispOff: -31 }],
      ["y", { p: 0x020004, parm2: 0x017f, b: 0xbe, max: 62, dispOff: -31 }],
    ]
  } },
  { prefix: 'vector/detune', count: 50, bx: 4, px: 3, block: (i) => {
    return [
      // parm2 is fixed here.
      ["time", { p: 0x050118, parm2: 0x017f, b: 0x183, opts: i == 0 ? startTimeOptions : timeOptions }],
      ["x", { p: 0x050119, parm2: 0x017f, b: 0x185, max: 62, dispOff: -31 }],
      ["y", { p: 0x05011a, parm2: 0x017f, b: 0x186, max: 62, dispOff: -31 }],
    ]
  } },
  { prefix: 'element/0', block: elemAParms },
  { prefix: 'element/1', block: elemBParms },
  { prefix: 'element/2', block: { b: 39, offset: elemAParms }},
  { prefix: 'element/3', block: { b: 39, offset: elemBParms }},
]



  subscript(path: SynthPath) -> Int? {
  get {
    guard let param = type(of: self).params[path] else { return nil }
    
    switch path.last! {
    case .shift, .bias:
      let v = bytes[param.byte]
      return Int(Int8(bitPattern: v << 1)) >> 1
    case .wave:
      guard let index = path.i(1) else { return nil }
      if index % 2 == 1 {
        let hi: UInt8 = (bytes[param.byte] & 0x1) << 7
        let lo: UInt8 = bytes[param.byte+1] & 0x7f
        return Int(hi) + Int(lo)
      }
    case .scale:
      // accommodate .mod as well
      if path[path.count - 2] == .level {
        let hi: UInt8 = (bytes[param.byte] & 0x1) << 3
        let lo: UInt8 = (bytes[param.byte+1] & 0x7f) >> 4
        return (Int(hi) + Int(lo)) << 4
      }
    case .lfo:
      let hi: UInt8 = (bytes[param.byte] & 0x1) << 2
      let lo: UInt8 = (bytes[param.byte+1] & 0x7f) >> 5
      return (Int(hi) + Int(lo)) << 5
    case .i:
      if path[2] == .time {
        let hi: UInt8 = (bytes[param.byte] & 0x1) << 7
        let lo: UInt8 = bytes[param.byte+1] & 0x7f
        return Int(hi) + Int(lo)
      }
    case .attack, .release:
      let hi: UInt8 = (bytes[param.byte] & 0x1) << 7
      let lo: UInt8 = bytes[param.byte+1] & 0x7f
      return Int(Int8(bitPattern: hi + lo))
    default:
      break
    }
    return unpack(param: param)
  }
  set {
    guard let param = type(of: self).params[path],
      let newValue = newValue else { return }
    var packValue = newValue
    switch path.last! {
    case .shift, .bias:
      packValue = Int(UInt8(bitPattern: Int8(newValue << 1))) >> 1
    case .wave:
      guard let index = path.i(1) else { return }
      if index % 2 == 1 {
        bytes[param.byte] = UInt8((newValue >> 7) & 0x1)
        bytes[param.byte + 1] = UInt8(newValue & 0x7f)
        return
      }
    case .scale:
      if path[path.count - 2] == .level {
        // have to maintain value for rate scaling too
        let v = newValue >> 4
        bytes[param.byte] = UInt8((v >> 3) & 0x1)
        bytes[param.byte + 1] = (UInt8(v & 0x7) << 4) | (bytes[param.byte + 1] & 0x0f)
        return
      }
    case .lfo:
      let v = newValue >> 4
      bytes[param.byte] = UInt8((v >> 2) & 0x1)
      bytes[param.byte + 1] = (UInt8(v & 0x3) << 5) | (bytes[param.byte + 1] & 0x1f)
      return
    case .i:
      if path[2] == .time {
        bytes[param.byte] = UInt8((newValue >> 7) & 0x1)
        bytes[param.byte + 1] = UInt8(newValue & 0x7f)
        return
      }
    case .attack, .release:
      let v = UInt8(bitPattern: Int8(newValue))
      bytes[param.byte] = UInt8((v >> 7) & 0x1)
      bytes[param.byte + 1] = UInt8(v & 0x7f)
      return
    default:
      break
    }
    pack(value: packValue, forParam: param)
  }
}


func unpack(param: Param) -> Int? {
  guard let p = param as? ParamWithRange,
    p.range.lowerBound < 0 else {
      return defaultUnpack(param: param)
  }
  
  // range check
  let byte = param.byte
  guard byte < bytes.count else { return nil }

  let bits = p.bits ?? [0, 6]
  let bitLength = 1 + UInt8(bits.upperBound - bits.lowerBound)
  let ander: UInt8 = (1 << bitLength) - 1
  var v = (bytes[byte] >> UInt8(bits.lowerBound)) & ander
  // need to look at top bit (based on bits) and extend sign to the left...
  let signBitIndex = Int(bitLength - 1)
  if v.bits(signBitIndex...signBitIndex) == 1 {
    let orer: UInt8 = ((1 << (8 - bitLength)) - 1) << bitLength
    v |= orer // extend the sign bit to the left
    return Int(Int8(bitPattern: v))
  }
  else {
    return Int(v)
  }
}


func pack(value: Int, forParam param: Param) {
  guard value < 0 else {
    return defaultPack(value: value, forParam: param)
  }
  
  var b = bytes[param.byte]
  let v = UInt8(bitPattern: Int8(value))
  if let bits = param.bits {
    let bitlen = 1 + (bits.upperBound - bits.lowerBound)
    let bitmask: UInt8 = (1 << bitlen) - 1 // all 1's
    // clear the bits
    b &= ~(bitmask << bits.lowerBound)
    // set the bits
    b |= ((v & bitmask) << bits.lowerBound)
  }
  else {
    b = v
  }
  
  bytes[param.byte] = b
}



func sysexData(channel: Int) -> Data {
  var b = "LM  0012VE".unicodeScalars.map { UInt8($0.value) }
  b.append(contentsOf: bytes)

  let byteCountMSB = UInt8((b.count >> 7) & 0x7f)
  let byteCountLSB = UInt8(b.count & 0x7f)
  var data = Data([0xf0, 0x43, UInt8(channel), 0x7e, byteCountMSB, byteCountLSB])
  data.append(contentsOf: b)
  data.append(type(of: self).checksum(bytes: b))
  data.append(0xf7)
  return data
}


func randomize() {
  randomizeAllParams()
  
  (0..<4).forEach {
    // set max level for all elements
    self["element/$0/volume"] = 0
    // normal scale
    self["element/$0/scale"] = 0
    self["element/$0/velo"] = ([0, 3]).random()!
    self["element/$0/env/attack/level"] = ([0, 5]).random()!
  }

  // no env delay
  self["common/env/delay"] = 127
  self["common/env/attack"] = 0
  self["common/env/release"] = 0
}



const patchTruss = {
  single: 'voice',
  parms: parms,
  namePack: [0x0c, 0x13],
  initFile: "tg33-init",
  // 587 bytes
  parseBody: ['bytes', { start: 0x10, count: 0x24b }],
}

const bankTruss = {
  compactSingleBank: patchTruss,
  patchCount: 64,
  initFile: "tg33-bank-init",
}

class TG33VoiceBank : TypicalTypedSysexPatchBank<TG33VoicePatch>, ChannelizedSysexible {
  
  override class var fileDataCount: Int { return 37631 }
  
  func sysexData(channel: Int) -> Data {
    var data = Data([0xf0, 0x43, UInt8(channel), 0x7e])

    stride(from: 0, to: 64, by: 4).forEach {
      var b = [UInt8]()
      if $0 == 0 {
        b.append(contentsOf: "LM  0012VC".unicodeScalars.map { UInt8($0.value) })
      }
      
      for i in 0..<4 { b.append(contentsOf: patches[$0 + i].bytes) }
      
      let byteCountMSB = UInt8((b.count >> 7) & 0x7f)
      let byteCountLSB = UInt8(b.count & 0x7f)

      data.append(contentsOf: [byteCountMSB, byteCountLSB])
      data.append(contentsOf: b)
      data.append(Patch.checksum(bytes: b))
      
      // TODO: gotta add in those 100ms delays in transmit...
    }
    data.append(0xf7)
    return data
  }
  
  required init(data: Data) {
    let offset = 14
    let patchByteCount = 587
    let skipCount = (patchByteCount * 4) + 3 // 4 patches plus 2 header bytes and 1 checksum byte
    
    let mapped: [[Patch]] = stride(from: offset, to: data.count, by: skipCount).map { doff in
      return (0..<4).compactMap { patchIndex in
        let start = 2 + doff + (patchByteCount * patchIndex)
        let endex = start + patchByteCount
        guard endex <= data.count else { return nil }
        let sysex = data.subdata(in: start..<endex)
        return Patch(bankData: sysex)
      }
    }
    let p = [Patch](mapped.joined())
    super.init(patches: p)
  }
    
}

const ramBanks = [
  ["SP*Pro33", "SP*Echo", "SP*BelSt", "SP*Full", "SP*Ice", "SP*Dandy", "SP*Arkle", "SP*BrVec", "SP*Matrx", "SP*Gut", "SP*Omni", "SP*Oiled", "SP*Ace", "SP*Quire", "SP*Digit", "SP*Swell", "SC:Groov", "SC*Airy", "SC*Solid", "SC*Sweep", "SC*Drops", "SC*Euro", "SC*Decay", "SC:Steel", "SC*Rude", "SC*Bellz", "SC*Pluck", "SC*Glass", "SC*Wood", "SC*Wire", "SC*Cave", "SC*Wispa", "SL*Sync", "SL*VCO", "SL*Chic", "SL:Mini", "SL*Wisul", "SL*Blues", "SL:Cosmo", "SL*Super", "ME*Vecta", "ME*NuAge", "PC*Hit+", "ME*Glace", "ME*Astro", "ME*Vger", "ME*Hitch", "ME*Indus", "SE*Mount", "SE*5.PM", "SE*FlyBy", "SE*Fear", "SE:Wolvs", "SE*Hades", "SE*Neuro", "SE*Angel", "SQ:MrSeq", "SQ:It", "SQ*Id", "SQ*Wrapa", "SQ*TG809", "SQ*Devol", "DR:Kit", "DR*EFX"],
  ["EP*Arlad", "AP*Piano", "EP*Malet", "AP*ApStr", "EP*DX6Op", "EP*Pin", "EP*NewDX", "EP*Fosta", "OR*Gospl", "OR*Rock", "OR*Pipe", "OR*Perc", "KY*Squez", "KY*Hrpsi", "KY*Celst", "KY*Clavi", "BA*Slap", "BA*Atack", "BA*Seq", "BA*Trad", "BA*Pick", "BA*Syn", "BA:Rezz", "BA:Unisn", "BA:Fingr", "BA*Frtls", "BA:Wood", "PL*Foksy", "PL*12Str", "PL*Mute", "PL*Nylon", "PL*Dist", "BR*Power", "BR*Fanfr", "BR*Class", "BR*Reeds", "BR*Chill", "BR*Zeus", "BR*Moot", "BR*Anlog", "BR:FrHrn", "BR:Trmpt", "BR*Tromb", "WN*Sax", "WN:Pan", "WN:Oboe", "WN:Clart", "WN:Flute", "ST*Arco", "ST:Chmbr", "ST*Full", "ST:Pizza", "ST*CelSt", "ST*Exel", "ST*Synth", "ST*Eroid", "CH*Modrn", "CH*Duwop", "CH*Itopy", "CH*Astiz", "PC:Marim", "PC:Vibes", "PC*Bells", "PC*Clang"],
]

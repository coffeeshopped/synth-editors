
const toneData = [0xf0, 0x41, 0x35, 'channel', 0x21, 0x20, 0x01, ['bytes', { start: 0, count: 59 }], 0xf7]

const sysexData = [
  // the tone
  ['syx', toneData],
  // the patch
  ['syx', [0xf0, 0x41, 0x36, 'channel', 0x21, 0x30, 0x01,
    0, ['byte', 59],
    1, ['byte', 60],
    2, ['byte', 61],
    3, ['byte', 62],
    4, ['byte', 63],
    5, ['byte', 64],
    6, ['byte', 65],
    0xf7]],
]

function writeData(location) {
  return [
    ['syx', toneData],
    ['syx', [0xf0, 0x41, 0x34, 'channel', 0x21, 0x20, 0x01, 0x00, location, 0x02, 0xf7]],
  ]
}

const patchTruss = {
  single: 'voice',
  // func nameSetFilter(_ n: String) -> String { n.uppercased() }
  namePack: [0, 9],
  initFile: "jx8p-voice-init",
  createFile: sysexData,
  // 67 bytes - 3.1 All Params with Tone Name // transmitted when patch change on synth
  // 77 bytes - apparently what the synth sends. patch param set to memory location, followed by tone.
  // 78 bytes : found online. tone, then msg to save to memory
  // 89 bytes : tone, then patch params (without bank and tone #)
  validSizes: [67,77,78,89],
}

class JX8PVoicePatch : ByteBackedSysexPatch, VoicePatch, BankablePatch {
  
    
  const fileDataCount = 77

  required init(data: Data) {
    let sysex = SysexData(data: data)
    bytes = [UInt8](repeating: 0, count: 66)
    // TODO: Init the Patch part with good data (in case it isn't there)
    sysex.forEach { msg in
      switch msg.count {
      case 67:
        (0..<59).forEach { bytes[$0] = msg[$0 + 7] }
      case 22:
        (0..<7).forEach { bytes[$0 + 59] = msg[$0 + 7]}
      default:
        break
      }
    }
  }
    
  subscript(path: SynthPath) -> Int? {
    get {
      guard let param = type(of: self).params[path] else { return nil }
      guard let v = unpack(param: param) else { return nil }
      switch path {
      case "osc/0/range",
           "osc/0/wave",
           "osc/1/range",
           "osc/1/wave",
           "osc/mod",
           "pitch/velo",
           "pitch/env/mode",
           "osc/1/amp/velo",
           "osc/1/amp/env/mode",
           "hi/cutoff",
           "filter/velo",
           "filter/env/mode",
           "amp/velo",
           "env/0/keyTrk",
           "env/1/keyTrk":
        return (v / 32) * 32 // map to 0/32/64/96
      case "chorus",
           "lfo/wave":
        return min((v / 32) * 32, 64) // map to 0/32/64
      case "amp/env/mode":
        return (v / 64) * 64 // map to 0/64
      // ... PATCH
      case "patch/bend":
        return (v / 32) * 32 // map to 0/32/64/96
      case "patch/porta":
        return (v / 64) * 64 // map to 0/64
      default:
        return v
      }
    }
    set { // standard setter
      guard let param = type(of: self).params[path],
        let newValue = newValue else { return }
      pack(value: newValue, forParam: param)
    }
  }

static func mapper(forArray arr: [Int]) -> ParamValueMapper {
  return (
    format: {
      return `${arr[$0]}`
    },
    parse: {
      let i = Int($0) ?? 0
      return arr.firstIndex(of: i) ?? 0
    }
  )
}

const map99Values = [0, 1, 2, 3, 3, 4, 5, 6, 6, 7, 8, 9, 10, 10, 11, 12, 13, 14, 14, 15, 16, 17, 17, 18, 19, 20, 20, 21, 22, 23, 24, 24, 25, 26, 27, 28, 28, 29, 30, 31, 31, 32, 33, 34, 35, 35, 36, 37, 38, 39, 39, 40, 41, 42, 43, 43, 44, 45, 46, 46, 47, 48, 49, 49, 50, 51, 52, 53, 53, 54, 55, 56, 56, 57, 58, 59, 60, 60, 61, 62, 63, 63, 64, 65, 66, 67, 67, 68, 69, 70, 71, 71, 72, 73, 74, 74, 75, 76, 77, 77, 78, 79, 80, 80, 81, 82, 83, 84, 84, 85, 86, 87, 88, 88, 89, 90, 91, 91, 92, 92, 93, 94, 95, 96, 96, 97, 98, 99]
const mapper99 = mapper(forArray: map99Values)

const map12Values = [-12, -12, -12, -12, -12, -12, -12, -12, -11, -11, -11, -11, -10, -10, -10, -10, -9, -9, -9, -9, -8, -8, -8, -8, -7, -7, -7, -7, -7, -7, -7, -7, -6, -6, -6, -6, -5, -5, -5, -5, -4, -4, -4, -4, -3, -3, -3, -3, -2, -2, -2, -2, -1, -1, -1, -1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 4, 4, 4, 4, 5, 5, 5, 5, 6, 6, 6, 6, 7, 7, 7, 7, 7, 7, 7, 7, 8, 8, 8, 8, 9, 9, 9, 9, 10, 10, 10, 10, 11, 11, 11, 11, 12, 12, 12, 12, 12, 12, 12, 12]
const mapper12 = mapper(forArray: map12Values)

const map50Values = [-50, -49, -48, -47, -46, -46, -45, -44, -43, -43, -42, -41, -40, -39, -39, -38, -37, -36, -35, -35, -34, -33, -32, -31, -31, -30, -29, -28, -28, -27, -26, -25, -24, -24, -23, -22, -21, -20, -20, -19, -18, -17, -17, -16, -15, -14, -14, -13, -12, -11, -10, -10, -9, -8, -7, -6, -6, -5, -4, -3, -3, -2, -1, 0, 0, 1, 2, 3, 3, 4, 5, 6, 6, 7, 8, 9, 10, 10, 11, 12, 13, 14, 14, 15, 16, 17, 17, 18, 19, 20, 20, 21, 22, 23, 24, 24, 25, 26, 27, 28, 28, 29, 30, 31, 31, 32, 33, 34, 35, 35, 36, 37, 38, 39, 39, 40, 41, 42, 43, 43, 44, 45, 46, 46, 47, 48, 49, 50]
const mapper50 = mapper(forArray: map50Values)

static func fourOptions(_ opts: [String]) -> [Int:String] {
  var out = [Int:String]()
  (0..<4).forEach { out[$0 * 32] = opts[$0] }
  return out
}

const oscRangeOptions = fourOptions(["16'", "8'", "4'", "2'"])

const oscWaveOptions = fourOptions(["Noise", "Square", "Pulse", "Saw"])

const oscModOptions = fourOptions(["Off", "Sync 1", "Sync 2", "X Mod"])

const dynOptions = fourOptions(["Off", "1", "2", "3"])

const envModeOptions = fourOptions(["Env 2 Invert", "Env 2 Normal", "Env 1 Invert", "Env 1 Normal"])

const hiPassOptions = fourOptions(["0", "1", "2", "3"])

const chorusOptions = [
  0 : "Off",
  32 : "1",
  64 : "2",
]

const lfoWaveOptions = [
  0 : "Random",
  32 : "Square",
  64 : "Sine",
]

const ampEnvModeOptions = [
  0 : "Gate",
  64 : "Env 2 Normal",
]


// PATCH

const bendOptions = fourOptions(["2", "3", "4", "7"])
  
const aftertouchOptions = [
  0 : "Off",
  1 : "Vibrato",
  2 : "Brilliance",
  4 : "Volume",
]



const parms = [
  { inc: 1, b: 11, block: [
    ["osc/0/range", { opts: oscRangeOptions }],
    ["osc/0/wave", { opts: oscWaveOptions }],
    ["osc/0/tune", { iso: mapper12 }],
    ["osc/0/lfo/depth", { iso: mapper99 }],
    ["osc/0/env/depth", { iso: mapper99 }],
    ["osc/1/range", { opts: oscRangeOptions }],
    ["osc/1/wave", { opts: oscWaveOptions }],
    ["osc/mod", { opts: oscModOptions }],
    ["osc/1/tune", { iso: mapper12 }],
    ["osc/1/fine", { iso: mapper50 }],
    ["osc/1/lfo/depth", { iso: mapper99 }],
    ["osc/1/env/depth", { iso: mapper99 }],
  ] },
  { inc: 1, b: 26, block: [
    ["pitch/velo", { opts: dynOptions }],
    ["pitch/env/mode", { opts: envModeOptions }],
    ["osc/0/level", { iso: mapper99 }],
    ["osc/1/level", { iso: mapper99 }],
    ["osc/1/amp/env/depth", { iso: mapper99 }],
    ["osc/1/amp/velo", { opts: dynOptions }],
    ["osc/1/amp/env/mode", { opts: envModeOptions }],
    ["hi/cutoff", { opts: hiPassOptions }],
    ["cutoff", { iso: mapper99 }],
    ["reson", { iso: mapper99 }],
    ["filter/lfo/depth", { iso: mapper99 }],
    ["filter/env/depth", { iso: mapper99 }],
    ["filter/keyTrk", { iso: mapper99 }],
    ["filter/velo", { opts: dynOptions }],
    ["filter/env/mode", { opts: envModeOptions }],
    ["amp/level", { iso: mapper99 }],
    ["amp/velo", { opts: dynOptions }],
    ["chorus", { opts: chorusOptions }],
    ["lfo/wave", { opts: lfoWaveOptions }],
    ["lfo/delay", { iso: mapper99 }],
    ["lfo/rate", { iso: mapper99 }],
    ["env/0/attack", { iso: mapper99 }],
    ["env/0/decay", { iso: mapper99 }],
    ["env/0/sustain", { iso: mapper99 }],
    ["env/0/release", { iso: mapper99 }],
    ["env/0/keyTrk", { opts: dynOptions }],
    ["env/1/attack", { iso: mapper99 }],
    ["env/1/decay", { iso: mapper99 }],
    ["env/1/sustain", { iso: mapper99 }],
    ["env/1/release", { iso: mapper99 }],
    ["env/1/keyTrk", { opts: dynOptions }],
  ] },
  ["amp/env/mode", { b: 58, opts: ampEnvModeOptions }],
  // PATCH params
  { inc: 1, b: 59, block: [
    ["patch/bend", { opts: bendOptions }],
    ["patch/porta/time", { }], //, iso: mapper99 }],
    ["patch/porta", { opts: [0 : "Off", 64: "On"] }],
    ["patch/assign/mode", { opts: Array.sparse([
      [0, "Poly 1"],
      [1, "Unison 1"],
      [2, "Solo 1"],
      [4, "Poly 2"],
      [5, "Unison 2"],
      [6, "Solo 2"],
    ]) }],
    ["patch/aftertouch", { opts: aftertouchOptions }],
    ["patch/bend/lfo", { }], //, iso: mapper99 }],
    ["patch/unison/detune", { }], //, iso: mapper50 }],
  ] },  
]

const patchTransform = {
  throttle: 200,
  param: (path, parm, value) => {
    let isPatch = byte > 58
    var data = Data([0xf0, 0x41, 0x36, UInt8(channel), 0x21, isPatch ? 0x30 : 0x20, 0x01])
    data.append(UInt8(byte % 59))
    data.append(UInt8(value))
    data.append(0xf7)
    return data
  },
  singlePatch: [[sysexData, 10]],
  name: n => {
    var data = Data([0xf0, 0x41, 0x36, UInt8(self.channel), 0x21, 0x20, 0x01])
    (0..<10).forEach {
      data.append(UInt8($0))
      data.append(UInt8(patch.bytes[$0]))
    }
    data.append(0xf7)
    return [data]
  } 
}



class JX8PVoiceBank : TypicalTypedSysexPatchBank<JX8PVoicePatch>, VoiceBank {
  
  // 77 * 32
  override class var fileDataCount: Int { 2464 }
  override class var patchCount: Int { 32 }
  override class var initFileName: String { "jx8p-voice-bank-init" }
  
  override class func isValid(fileSize: Int) -> Bool {
    fileSize == fileDataCount || fileSize == 2496
  }
  
  // data should be 32 pairs of sysex msgs:
  // either: tone, then write to location (this is what we write to)
  // or: patch param to indicate location, then tone (this is fetch via pressing buttons)
  required init(data: Data) {
    let sysex = SysexData(data: data)
    var p = [Patch](repeating: Patch(), count: Self.patchCount)
    (0..<(sysex.count / 2)).forEach { i in
      let msg1 = sysex[i * 2]
      let msg2 = sysex[i * 2 + 1]
      let toneMsg = msg1.count == 67 ? msg1 : msg2
      let writeMsg = msg1.count == 67 ? msg2 : msg1

      let nextP = Patch(data: toneMsg)
      let location = writeMsg.count >= 9 ? writeMsg[8] : 0
      p[Int(location)] = nextP
    }
    
    super.init(patches: p)
  }
  
  func sysexData(channel: Int) -> [Data] {
    let msgs = (0..<Self.patchCount).map {
      patches[$0].writeData(channel: channel, location: $0)
    }
    return [Data](msgs.joined())
  }
  
}

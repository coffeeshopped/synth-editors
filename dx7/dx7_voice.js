
enum DXLevelScalingCurve: Int {
 case negativeLinear = 0
 case negativeExponential = 1
 case positiveExponential = 2
 case positiveLinear = 3
}

const curveOptions = ["- Lin","- Exp","+ Exp","+ Lin"]
 
const lfoWaveOptions = ["Triangle","Saw Down","Saw Up","Square","Sine","Sample/Hold"]
  
const parms = [
  { prefix: 'op', count: 6, block: (op) => {
    const off = 21 * (5 - op)
    return [
      { prefix: 'rate', count: 4, bx: 1, block: [
        ["", { b: off, max: 99 }],
      ] },
      { prefix: 'level', count: 4, bx: 1, block: [
        ["", { b: off + 4, max: 99 }],
      ] },
      ["level/scale/brk/pt", { b: off + 8, iso: ['noteName', 'A-1'], max: 87 }],
      ["level/scale/left/depth", { b: off + 9, max: 99 }],
      ["level/scale/right/depth", { b: off + 10, max: 99 }],
      ["level/scale/left/curve", { b: off + 11, opts: curveOptions }],
      ["level/scale/right/curve", { b: off + 12, opts: curveOptions }],
      ["rate/scale", { b: off+13, max: 7 }],
      ["amp/mod", { b: off+14, max: 3 }],
      ["velo", { b: off+15, max: 7 }],
      ["level", { b: off+16, max: 99 }],
      ["osc/mode", { b: off+17, max: 1 }],
      ["coarse", { b: off+18, max: 31 }],
      ["fine", { b: off+19, max: 99 }],
      ["detune", { b: off+20, max: 14, dispOff: -7 }],
      
      ["on", { p: 155, bit: 5-op }],
    ]
  } },
  { prefix: 'pitch/env/rate', count: 4, bx: 1, block: [
    ["", { b: 126, max: 99 }],
  ] },
  { prefix: 'pitch/env/level', count: 4, bx: 1, block: [
    ["", { b: 130, max: 99 }],
  ] },   
  ["algo", { b: 134, max: 31, dispOff: 1 }],
  ["feedback", { b: 135, max: 7 }],
  ["osc/sync", { b: 136, max: 1 }],
  ["lfo/speed", { b: 137, max: 99 }],
  ["lfo/delay", { b: 138, max: 99 }],
  ["lfo/pitch/mod/depth", { b: 139, max: 99 }],
  ["lfo/amp/mod/depth", { b: 140, max: 99 }],
  ["lfo/sync", { b: 141, max: 1 }],
  ["lfo/wave", { b: 142, opts: lfoWaveOptions }],
  ["lfo/pitch/mod", { b: 143, max: 7 }],
  ["transpose", { b: 144, iso: ['noteName', 'C1'], max: 48 }],
]

const compactParms = [
  { prefix: 'op', count: 6, block: (op) => {
    const off = 17 * (5 - op)
    return [
      { prefix: 'rate', count: 4, bx: 1, block: [
        ["", { b: off }],
      ] },
      { prefix: 'level', count: 4, bx: 1, block: [
        ["", { b: off + 4 }],
      ] },
      ["level/scale/brk/pt", { b: off+8 }],
      ["level/scale/left/depth", { b: off+9 }],
      ["level/scale/right/depth", { b: off+10 }],
      ["level/scale/left/curve", { b: off + 11, bits: [0, 1] }],
      ["level/scale/right/curve", { b: off + 11, bits: [2, 3] }],
      ["rate/scale", { b: off+12, bits: [0, 2] }],
      ["amp/mod", { b: off+13, bits: [0, 1] }],
      ["velo", { b: off+13, bits: [2, 4] }],
      ["level", { b: off+14 }],
      ["osc/mode", { b: off+15, bit: 0 }],
      ["coarse", { b: off+15, bits: [1, 6] }],
      ["fine", { b: off+16 }],
      ["detune", { b: off+12, bits: [3, 6] }],
    ]
  } },
  { prefix: 'pitch/env/rate', count: 4, bx: 1, block: [
    ["", { b: 102 }],
  ] },
  { prefix: 'pitch/env/level', count: 4, bx: 1, block: [
    ["", { b: 106 }],
  ] },   
  ["algo", { b: 110 }],
  ["feedback", { b: 111, bits: [0, 2] }],
  ["osc/sync", { b: 111, bit: 3 }],
  ["lfo/speed", { b: 112 }],
  ["lfo/delay", { b: 113 }],
  ["lfo/pitch/mod/depth", { b: 114 }],
  ["lfo/amp/mod/depth", { b: 115 }],
  ["lfo/sync", { b: 116, bit: 0 }],
  ["lfo/wave", { b: 116, bits: [1, 3] }],
  ["lfo/pitch/mod", { b: 116, bits: [4, 6] }],
  ["transpose", { b: 117 }],
]

const sysexData = ['yamCmd', ['channel', 0x00, 0x01, 0x1b]]

const patchTruss = {
  single: 'voice',
  parms: parms,
  initFile: "DX-init",
  namePack: [145, 154],
  parseBody: ['bytes', { start: 6, count: 155 }],
  createFile: sysexData,
}

 // open func randomize() {
  //  self["partial/0/mute"] = 1
// 
  //  // find the output ops and set level 4 to 0
  //  let algos = Self.algorithms()
  //  let algoIndex = self["algo"] ?? 0
// 
  //  let algo = algos[algoIndex]
// 
  //  for outputId in algo.outputOps {
  //    let op: SynthPath = "op/outputId"
  //    self[op + "level/0"] = 90+([0, 9]).random()!
  //    self[op + "rate/0"] = 80+([0, 19]).random()!
  //    self[op + "level/2"] = 80+([0, 19]).random()!
  //    self[op + "level/3"] = 0
  //    self[op + "rate/3"] = 30+([0, 69]).random()!
  //    self[op + "level"] = 90+([0, 9]).random()!
  //    self[op + "level/scale/left/depth"] = ([0, 9]).random()!
  //    self[op + "level/scale/right/depth"] = ([0, 9]).random()!
  //  }
// 
  //  // for one out, make it harmonic and louder
  //  let randomOut = algo.outputOps[(0..<algo.outputOps.count).random()!]
  //  let op: SynthPath = "op/randomOut"
  //  self[op + "osc/mode"] = 0
  //  self[op + "fine"] = 0
  //  self[op + "coarse"] = 1
// 
  //  // flat pitch env
  //  for i in 0..<4 {
  //    self["pitch/env/level/i"] = 50
  //  }
// 
  //  // all ops on
  //  for op in 0..<6 { self["op/op/on"] = 1 }
 // }

open class DX7Patch : DXPatch, Algorithmic, CompactBankablePatch {
 

 public const fileDataCount = 163
 public var opOns = [Int](repeating: 1, count: 6)

 required public init(bankData: Data) {
   // create empty bytes to pack into
   bytes = [UInt8](repeating: 0, count: 155)

   let b = [UInt8](bankData)

   // unpack the name
   name = type(of: self).name(forRange: type(of: self).bankNameByteRange, bytes: b)

   type(of: self).bankParams.forEach {
     self[$0.key] = type(of: self).defaultUnpack(param: $0.value, forBytes: b)
   }
 }
 
 public func bankSysexData() -> Data {
   var b = [UInt8](repeating: 0, count: 128)
   
   // pack the name
   let nameByteRange = type(of: self).bankNameByteRange
   let n = nameSetFilter(name) as NSString
   let nameBytes = (0..<nameByteRange.count).map { $0 < n.length ? UInt8(n.character(at: $0)) : 32 }
   b.replaceSubrange(nameByteRange, with: nameBytes)

   // pack the params
   type(of: self).bankParams.forEach {
     let param = $0.value
     b[param.byte] = type(of: self).defaultPackedByte(value: self[$0.key] ?? 0, forParam: param, byte: b[param.byte])
   }
   
   return Data(b)
 }
 
}

const compactTruss = {
  single: 'voice.compact',
  namePack: [118, 127],
}

function freqRatio(fixedMode, coarse, fine) {
   if (fixedMode) {
     let freq = powf(10, Float(coarse % 4)) * exp(Float(M_LN10)*(Float(fine)/100))
     return String(format:"%.4g", freq)
   }
   else {
     // ratio mode
     let c = coarse == 0 ? 0.5 : Float(coarse)
     let f = (Float(fine) * c) / 100
     return String(format:"%.2f", c + f)
   }
 }
 
 
 const bankTruss = {
   compactSingleBank: patchTruss,
   patchCount: 32,
   initFile: "dx7-voice-bank-init",
 }
 public class DX7VoiceBank : TypicalTypedSysexPatchBank<DX7Patch>, ChannelizedSysexible, VoiceBank {
  
  override public class var fileDataCount: Int { 4104 }
  
  public func sysexData(channel: Int) -> Data {
    var data = Data([0xf0, 0x43, UInt8(channel), 0x09, 0x20, 0x00])
    let patchData = [UInt8](patches.map{ $0.bankSysexData() }.reduce(Data(), +))
    data.append(contentsOf: patchData)
    data.append(DX7Patch.checksum(bytes: patchData))
    data.append(0xf7)
    return data
  }
  
  required public init(data: Data) {
    let p = type(of: self).compactPatches(fromData: data, offset: 6, patchByteCount: 128)
    super.init(patches: p)
  }
 
 }
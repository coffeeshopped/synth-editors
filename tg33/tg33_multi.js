


const onOptions = [
  0 : "Off",
  8 : "On"
]

const groupOptions = [
  0 : "1",
  4 : "2"
]

const assignOptions = ["32/0", "24/8", "16/16"]

const bankOptions = ["Internal", "Preset 1", "Preset 2"]

const panOptions = {
  var opts = TG33VoicePatch.panOptions
  opts[5] = "Voice"
  return opts
}()

const parms = [
  ["common/fx/type", { p: 0x080000, parm2: 0x017f, b: 0x00, bits: [0, 3], opts: Voice.fxOptions }],
  ["common/fx/balance", { p: 0x090001, parm2: 0x017f, b: 0x01 }],
  ["common/fx/send/0", { p: 0x0a0005, parm2: 0x017f, b: 0x05 }],
  ["common/fx/send/1", { p: 0x0a0006, parm2: 0x017f, b: 0x06 }],
  ["common/out/0", { p: 0x070007, parm2: 0x017e, b: 0x07, bit: 0, opts: [0: "Out 1", 1: "Out 2"] }],
  ["common/out/1", { p: 0x070007, parm2: 0x017d, b: 0x07, bit: 1, opts: [0: "Out 1", 2: "Out 2"] }],
  ["common/assign", { p: 0x050015, parm2: 0x017f, b: 0x15, bits: [0, 1], opts: assignOptions }],
  { prefix: 'part', count: 16, bx: 0x0b, block: [
    ["on", { p: 0x000000, parm2: 0x0177, b: 0x20, bit: 3, opts: onOptions }],
    ["group", { p: 0x060000, parm2: 0x017b, b: 0x20, bit: 2, opts: groupOptions }],
    ["bank", { p: 0x000001, parm2: 0x017f, b: 0x21, bits: [0, 1], opts: bankOptions }],
    ["number", { p: 0x000002, parm2: 0x017f, b: 0x22, bits: [0, 5] }],
    ["volume", { p: 0x010003, parm2: 0x017f, b: 0x23, opts: Voice.inverse99 }],
    ["detune", { p: 0x020004, parm2: 0x017f, b: 0x25, rng: [-50, 50] }],
    ["note/shift", { p: 0x030005, parm2: 0x017f, b: 0x27, rng: [-12, 12] }],
    ["pan", { p: 0x040006, parm2: 0x017f, b: 0x28, bits: [0, 2], opts: panOptions }],
  ] },
]


  subscript(path: SynthPath) -> Int? {
  get {
    guard let param = type(of: self).params[path] else { return nil }
    
    switch path.last! {
    case .on:
      let value = unpack(param: param) ?? 0
      return value << 3
    case .group:
      let value = unpack(param: param) ?? 0
      return value << 2
    case .shift, .detune:
      let v = bytes[param.byte]
      return Int(Int8(bitPattern: v << 1)) >> 1
    case .i(1):
      if path[path.count-2] == .out {
        let value = unpack(param: param) ?? 0
        return value << 1
      }
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
    case .on:
      let v = newValue >> 3
      pack(value: v, forParam: param)
      return
    case .group:
      let v = newValue >> 2
      pack(value: v, forParam: param)
      return
    case .shift, .detune:
      packValue = Int(UInt8(bitPattern: Int8(newValue << 1))) >> 1
    case .i(1):
      if path[path.count-2] == .out {
        let v = newValue >> 1
        pack(value: v, forParam: param)
        return
      }
    default:
      break
    }
    pack(value: packValue, forParam: param)
  }
}


func sysexData(channel: Int) -> Data {
  var b = "LM  0012ME".unicodeScalars.map { UInt8($0.value) }
  b.append(contentsOf: bytes)
  
  let byteCountMSB = UInt8((b.count >> 7) & 0x7f)
  let byteCountLSB = UInt8(b.count & 0x7f)
  var data = Data([0xf0, 0x43, UInt8(channel), 0x7e, byteCountMSB, byteCountLSB])
  data.append(contentsOf: b)
  data.append(type(of: self).checksum(bytes: b))
  data.append(0xf7)
  return data
}

const patchTruss = {
  single: 'multi',
  parms: parms,
  namePack: [0x0d, 0x14],
  initFile: "tg33-multi-init",
  parseBody: ['bytes', { start: 0x10, count: 208 }],
}

const patchTransform = (location) => ({
  throttle: 100,
  param: (path, parm, value) => {
    // HIDDEN PARAMS
    guard param.parm > 0 else { return [patch.sysexData(channel: self.channel)] }
    
    let adds = RolandAddress(param.parm).sysexBytes(count: 5)
    let v1 = UInt8((value >> 7) & 0x7f)
    let v2 = UInt8(value & 0x7f)
    var postST: UInt8
    switch path[0] {
    case .part:
      guard let i = path.i(1) else { return nil }
      postST = UInt8(i)
    default:
      postST = 0
    }
    return [Data([0xf0, 0x43, 0x10 + UInt8(self.channel), 0x26, 0x04, adds[0], postST, adds[1], adds[2], adds[3], adds[4], v1, v2, 0xf7])]
  },
  singlePatch: [[sysexData, 10]],
  name: [[sysexData, 10]],
})


class TG33MultiBank : TypicalTypedSysexPatchBank<TG33MultiPatch>, ChannelizedSysexible {
  
  override class var patchCount: Int { return 16 }
  override class var fileDataCount: Int { return 3346 }
  override class var initFileName: String { return "tg33-multi-bank-init" }
  
  func sysexData(channel: Int) -> Data {
    var b = "LM  0012MU".unicodeScalars.map { UInt8($0.value) }
    (0..<16).forEach { b.append(contentsOf: patches[$0].bytes) }
    
    let byteCountMSB = UInt8((b.count >> 7) & 0x7f)
    let byteCountLSB = UInt8(b.count & 0x7f)
    
    var data = Data([0xf0, 0x43, UInt8(channel), 0x7e, byteCountMSB, byteCountLSB])
    data.append(contentsOf: b)
    data.append(Patch.checksum(bytes: b))
    data.append(0xf7)
    return data
  }
    
  required init(data: Data) {
    let offset = 16
    let patchByteCount = 208
    
    let p: [Patch] = stride(from: offset, to: data.count, by: patchByteCount).compactMap { doff in
      let endex = doff + patchByteCount
      guard endex <= data.count else { return nil }
      let sysex = data.subdata(in: doff..<endex)
      return Patch(bankData: sysex)
    }
    super.init(patches: p)
  }
  

}

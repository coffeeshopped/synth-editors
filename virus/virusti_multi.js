  
//  static func location(forData data: Data) -> Int {
//    guard data.count > 8 else { return 0 }
//    return Int(data[8])
//  }
  
//  subscript(path: SynthPath) -> Int? {
//    get {
//      guard let v = rawValue(path: path) else { return nil }
//      switch path {
//      case "0/wave", "1/wave":
//        let inst = v.bits([0, 7])
//        let set = v.bits([8, 12])
//        return Self.reverseInstMap[set]?[inst] ?? 0
//      default:
//        return v
//      }
//    }
//    set {
//      guard let param = type(of: self).params[path],
//        let newValue = newValue else { return }
//      let off = param.parm * 2
//      switch path {
//      case "0/wave", "1/wave":
//        guard newValue < Self.instMap.count else { return }
//        let item = Self.instMap[newValue]
//        let v = 0.set(bits: [0, 7], value: item.inst).set(bits: [8, 12], value: item.set)
//        bytes[off] = UInt8(v.bits([0, 6]))
//        bytes[off + 1] = UInt8(v.bits([7, 13]))
//      default:
//        bytes[off] = UInt8(newValue.bits([0, 6]))
//        bytes[off + 1] = UInt8(newValue.bits([7, 13]))
//      }
//    }
//  }
  
  
  // TODO
  func randomize() {
    randomizeAllParams()
//    (0..<3).forEach {
//      self["link/$0"] = -1
//    }
//    (0..<4).forEach {
//      self["key/lo/$0"] = 0
//      self["key/hi/$0"] = 127
//    }
//    (0..<2).forEach {
//      self["$0/key/lo"] = 0
//      self["$0/key/hi"] = 127
//    }
//    self["0/volume"] = 127
//    self["0/delay"] = 0
//    self["0/start"] = 0
//    self["1/delay"] = ([0, 10]).random()!
//
//    self["mix"] = 0
  }

const outOptions = ["Out1 L", "Out1 L+R", "Out1 R", "Out2 L", "Out2 L+R", "Out2 R", "Out3 L", "Out3 L+R", "Out3 R"]

const volIso = Miso.switcher([
  .int(0, "Off")
], default: Miso.str())

const panIso = Miso.switcher([
  .int(0, "Patch")
], default: Miso.a(-64) >>> Miso.str())


const parms = [
  ["clock", { p: 0x0f, b: 15, dispOff: 63 }],
  { prefix: 'part', count: 16, bx: 1, block: [
    ["channel", { p: 0x22, b: 64, max: 15, dispOff: 1 }],
    ["key/lo", { p: 0x23, b: 80, iso: Miso.noteName(zeroNote: "C-1") }],
    ["key/hi", { p: 0x24, b: 96, iso: Miso.noteName(zeroNote: "C-1") }],
    ["transpose", { p: 0x25, b: 112, rng: [16, 112], dispOff: -64 }],
    ["detune", { p: 0x26, b: 128, dispOff: -64 }],
    ["volume", { p: 0x27, b: 144, dispOff: -64 }],
    ["innit/volume", { p: 0x28, b: 160, iso: volIso }],
    ["out", { p: 0x29, b: 176, opts: outOptions }],
    ["pan", { p: 0x2b, b: 208, iso: panIso }],
    ["on", { p: 0x48, b: 240, bit: 0 }],
    ["rcv/volume", { p: 0x49, b: 240, bit: 1 }],
    ["hold", { p: 0x4a, b: 240, bit: 2 }],
    ["priority", { p: 0x4d, b: 240, bit: 5, opts: ["Low", "High"] }],
    ["rcv/pgmChange", { p: 0x4e, b: 240, bit: 6 }],
  ] },
]

const patchTruss ={
  single: 'mutli',
  parms: parms,
  initFile: "virusti-multi-init",
  parseBody: ['bytes', { start: 9, count: 256 }],
}

const patchTransform = {
  throttle: 100,
  param: (path, parm, value) => {
    let cmdByte: UInt8
    let part: Int
    let parm: Int
    switch path[0] {
    case .common:
      let subpath = path.subpath(from: 1)
      guard let param = VirusTIMultiPatch.params[subpath] else { return nil }
      part = subpath.i(1) ?? 0
      cmdByte = 0x72
      parm = param.parm
    default:
      let subpath = path.subpath(from: 2)
      guard let param = VirusTIVoicePatch.params[subpath] else { return nil }
      part = path.i(1) ?? 0
      let section = param.byte / 128 // should be 0...3
      cmdByte = [0x70, 0x71, 0x6e, 0x6f][section]
      parm = param.byte % 128
    }
    
    let cmdBytes = self.sysexCommand([cmdByte, UInt8(part), UInt8(parm), UInt8(value)])
    return [Data(cmdBytes)]
  },
  singlePatch: [[tempMultiData(patch: patch), 10]],
  name: { (patch, path, name) -> [Data]? in
    let cmdByte: UInt8
    let part: Int
    let parm: Int
    switch path.first {
    case nil:
      part = 0
      cmdByte = 0x72
      parm = 0x04
    default:
      part = path.i(1) ?? 0
      cmdByte = 0x71
      parm = 0x70
    }
    
    // both voice and multi have 10-char names
    return [Data(name.bytes(forCount: 10).enumerated().map {
      Data(self.sysexCommand([cmdByte, UInt8(part), UInt8(parm + $0.offset), $0.element]))
    }.joined())]
  }
}

const bankTransform = {
  throttle: 0,
  singleBank: loc => [[sysexData(deviceId, loc), 50]],
}
  
  private func tempMultiData(patch: VirusTIEmbeddedMultiPatch) -> [Data] {
  return patch.sysexData(deviceId: deviceId, location: -1)
}



const parms = [
  ["tone", { p: 0, b: 0, opts: (128).map(i =>`${i+1}`) }],
  ["key/lo", { p: 1, b: 1, range: [12, 108] }],
  ["key/hi", { p: 2, b: 2, range: [13, 109] }],
  ["porta/time", { p: 3, b: 3 }],
  ["mod/amt", { p: 5, b: 4 }],
  ["transpose", { p: 6, b: 5, range: [-12, 12] }],
  ["volume", { p: 7, b: 6 }],
  ["detune", { p: 8, b: 7, range: [-63, 63] }], // this range is crazy. see docs
  ["bend", { p: 10, b: 8, bits: [4, 7], max: 12 }],
  ["chord", { p: 11, b: 8, bits: [0, 3], max: 15, dispOff: 1 }],
  ["aftertouch", { p: 9, b: 9, bit: 6 }],
  ["bend/ctrl", { p: 9, b: 9, bit: 5 }],
  ["sysex", { p: 9, b: 9, bit: 4 }],
  ["hold", { p: 9, b: 9, bit: 3 }],
  ["modWheel", { p: 9, b: 9, bit: 2 }],
  ["volume/ctrl", { p: 9, b: 9, bit: 1 }],
  ["porta/ctrl", { p: 9, b: 9, bit: 0 }],
//    ["expression", { p: -1, b: 10, bit: 7 }], // not sure what this is yet.
  ["key/assign", { p: 12, b: 10, bits: [5, 6], opts: [0: "Poly", 2: "Chord", 3: "Mono"] }],
  ["porta", { p: 4, b: 10, bit: 4 }],
]

const patchTruss = {
  namePack: [11, 20],
  initFile: "mks50-patch-init",
  validSizes: [31,64],
  parms: parms,
}

class MKS50PatchPatch : AlphaJunoNamedPatch, BankablePatch {
  
  const bankType: SysexPatchBank.Type = MKS50PatchBank.self
  static func location(forData data: Data) -> Int {
    return Int(data[8]) // this is the general block location, not specific patch
  }

  // 31 bytes - 3.1.2 All Params with Patch Name // transmitted when patch change on synth
  // 64 bytes - 3.2.2 Bulk Dump: an entire bulk dump has 4 patches. The 64 bytes will be just the data bytes for 1 patch (as nibbles)
  
  // internal PB bytes are in 3.2.2 format (BULK)
  // 32 bytes
  
  const fileDataCount = 31

  // TODO: patch can be from fetch format, or bulk!
  
  required init(data: Data) {
    switch data.count {
    case 31:
      bytes = [UInt8](repeating: 0, count: 32)
      bytes[31] = 10 // PATCH DATA code
      // set params
      data[7..<20].enumerated().forEach { (parm, value) in
        switch parm {
        case 9:
          // multiple params in param 9
          type(of: self).params.filter { $0.value.parm == 9 }.forEach {
            self[$0.key] = 1 - value.bit($0.value.bits!.lowerBound) // 0 = on
          }
        default:
          let paramPair = type(of: self).params.first { $0.value.parm == parm }
          guard let path = paramPair?.key else { return }
          self[path] = Int(value >> (parm == 12 ? 5 : 0))
        }
      }
      // set name
      data[20..<30].enumerated().forEach {
        let bOff = 11 + $0.offset
        bytes[bOff] = bytes[bOff].set(bits: [0, 5], value: Int($0.element))
      }
    case 64:
      // bulk data
      bytes = (0..<32).map {
        // LSB first
        let lsb = data[$0 * 2] & 0xf
        let msb = (data[$0 * 2 + 1] & 0xf) << 4
        return lsb + msb
      }
    default:
      debugPrint("MKS-50 Patch: Unknown data count for init")
      bytes = [UInt8](repeating: 0, count: 32)
    }
  }
  
  func fileData() -> Data {
    return sysexData(channel: 0)
  }
  
  /// Patch as sysex for edit buffer - 4.1.4 (dump with name)
  func sysexData(channel: Int) -> Data {
    var data = Data([0xf0, 0x41, 0x35, UInt8(channel), 0x23, 0x30, 0x01])
    let params = (0..<13).map { parm -> UInt8 in
      switch parm {
      case 9:
        // multiple params in param 9
        var byte = 0
        type(of: self).params.filter { $0.value.parm == 9 }.forEach {
          byte = byte.set(bit: $0.value.bits!.lowerBound, value: 1 - self[$0.key]!)
        }
        return UInt8(byte)
      default:
        guard let paramPair = type(of: self).params.first(where: { $0.value.parm == parm }) else { return 0 }
        let v = self[paramPair.key] ?? 0
        return UInt8(v < 0 ? 128 + v : v) << (parm == 12 ? 5 : 0)
      }
    }
    data.append(contentsOf: params)
    // then name
    data.append(contentsOf: bytes[type(of: self).nameByteRange].map { UInt8($0.bits([0, 5])) })
    data.append(0xf7)
    return data
  }

  subscript(path: SynthPath) -> Int? {
    get {
      guard let param = type(of: self).params[path] else { return nil }
      switch param.parm {
      case 9:
        return 1 - unpack(param: param)! // these bits are all flipped
      default:
        let v = unpack(param: param)!
        if ((param as? RangeParam)?.range.lowerBound ?? 0) < 0 {
          return v > 63 ? v - 128 : v
        }
        else {
          return v
        }
      }
    }
    set {
      guard let param = type(of: self).params[path],
        let v = newValue else { return }
      switch param.parm {
      case 9:
        pack(value: 1 - v, forParam: param)
      default:
        // handle negatives
        pack(value: v < 0 ? 128 + v : v, forParam: param)
      }
    }
  }
  
  func randomize() {
    randomizeAllParams()
    self["sysex"] = 1
  }

}


class MKS50PatchBank : TypicalTypedSysexPatchBank<MKS50PatchPatch> {
  
  // 266 * 16
  override class var fileDataCount: Int { return 4256 }
  override class var patchCount: Int { return 64 }
  // TODO: need actual init file
  override class var initFileName: String { return "mks50-patch-bank-init" }
    
  required init(data: Data) {
    let sysex = SysexData(data: data)
    var p = [Patch]()
    (0..<sysex.count).forEach {
      let msg = sysex[$0]
      let dOff = 9
      let next4 = (0..<4).compactMap { subindex -> Patch? in
        let thisOff = dOff + subindex * 64
        guard thisOff + 64 <= msg.count else { return nil }
        return Patch(data: Data(msg[thisOff..<(thisOff+64)]))
      }
      p.append(contentsOf: next4)
    }
    
    (0..<(type(of: self).patchCount-p.count)).forEach { _ in
      p.append(Patch.init())
    }
    super.init(patches: p)
  }
  
  func sysexData(channel: Int) -> [Data] {
    return (0..<16).map { msgIndex -> Data in
      let pOff = msgIndex * 4
      var d = Data([0xf0, 0x41, 0x37, UInt8(channel), 0x23, 0x30, 0x01, 0x00, UInt8(pOff)])
      (0..<4).forEach { subindex in
        let bytes = patches[pOff + subindex].bytes
        d.append(contentsOf: bytes.map {
          [$0 & 0x0f, ($0 >> 4) & 0x0f]
          }.joined())
      }
      d.append(0xf7)
      return d
    }
  }
  
}


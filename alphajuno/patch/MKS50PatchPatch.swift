
class MKS50PatchPatch : AlphaJunoNamedPatch, BankablePatch {
  
  static let bankType: SysexPatchBank.Type = MKS50PatchBank.self
  static func location(forData data: Data) -> Int {
    return Int(data[8]) // this is the general block location, not specific patch
  }

  // 31 bytes - 3.1.2 All Params with Patch Name // transmitted when patch change on synth
  // 64 bytes - 3.2.2 Bulk Dump: an entire bulk dump has 4 patches. The 64 bytes will be just the data bytes for 1 patch (as nibbles)
  
  // internal PB bytes are in 3.2.2 format (BULK)
  // 32 bytes
  
  static let fileDataCount = 31
  static let nameByteRange = 11..<21
  // TODO: need actual init file
  static let initFileName = "mks50-patch-init"

  var bytes: [UInt8]

  static func isValid(fileSize: Int) -> Bool {
    return [31,64].contains(fileSize)
  }

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
        bytes[bOff] = bytes[bOff].set(bits: 0...5, value: Int($0.element))
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
    data.append(contentsOf: bytes[type(of: self).nameByteRange].map { UInt8($0.bits(0...5)) })
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
    self[[.sysex]] = 1
  }

  
  static let params : SynthPathParam = {
    var p = SynthPathParam()
    
    p[[.tone]] = OptionsParam(parm: 0, byte: 0, options: OptionsParam.makeOptions((0..<128).map {
      return "\($0+1)"
    }))
    p[[.key, .lo]] = RangeParam(parm: 1, byte: 1, range: 12...108)
    p[[.key, .hi]] = RangeParam(parm: 2, byte: 2, range: 13...109)
    p[[.porta, .time]] = RangeParam(parm: 3, byte: 3)
    p[[.mod, .amt]] = RangeParam(parm: 5, byte: 4)
    p[[.transpose]] = RangeParam(parm: 6, byte: 5, range: -12...12)
    p[[.volume]] = RangeParam(parm: 7, byte: 6)
    p[[.detune]] = RangeParam(parm: 8, byte: 7, range: -63...63) // this range is crazy. see docs
    p[[.bend]] = RangeParam(parm: 10, byte: 8, bits: 4...7, maxVal: 12)
    p[[.chord]] = RangeParam(parm: 11, byte: 8, bits: 0...3, maxVal: 15, displayOffset: 1)
    p[[.aftertouch]] = RangeParam(parm: 9, byte: 9, bit: 6)
    p[[.bend, .ctrl]] = RangeParam(parm: 9, byte: 9, bit: 5)
    p[[.sysex]] = RangeParam(parm: 9, byte: 9, bit: 4)
    p[[.hold]] = RangeParam(parm: 9, byte: 9, bit: 3)
    p[[.modWheel]] = RangeParam(parm: 9, byte: 9, bit: 2)
    p[[.volume, .ctrl]] = RangeParam(parm: 9, byte: 9, bit: 1)
    p[[.porta, .ctrl]] = RangeParam(parm: 9, byte: 9, bit: 0)
//    p[[.expression]] = RangeParam(parm: -1, byte: 10, bit: 7) // not sure what this is yet.
    p[[.key, .assign]] = OptionsParam(parm: 12, byte: 10, bits: 5...6, options: [0: "Poly", 2: "Chord", 3: "Mono"])
    p[[.porta]] = RangeParam(parm: 4, byte: 10, bit: 4)

    return p
  }()
  

}


protocol AlphaJunoNamedPatch : ByteBackedSysexPatch { }
extension AlphaJunoNamedPatch {

  var name: String {
    get {
      let letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789 -"
      let n: [Character] = bytes[type(of: self).nameByteRange].map { b in
        let bClip = b.bits(0...5)
        guard bClip < letters.count else { return Character(" ") }
        let subIndex = letters.index(letters.startIndex, offsetBy: bClip)
        return letters[subIndex]
      }
      return String(n).trimmingCharacters(in: CharacterSet.whitespacesAndNewlines.union(.controlCharacters))
    }
    set {
      let letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789 -"
      let nameRangeStart = type(of: self).nameByteRange.lowerBound
      newValue.enumerated().forEach {
        // if name is too long to encode, stop
        guard $0.offset < 10 else { return }
        
        var index = 62
        if let lookupIndex = letters.firstIndex(of: $0.element) {
          index = letters.distance(from: letters.startIndex, to: lookupIndex)
        }
        let bOff = nameRangeStart + $0.offset
        bytes[bOff] = bytes[bOff].set(bits: 0...5, value: index)
      }
      // pad the rest with spaces
      if newValue.count < 10 {
        (newValue.count..<10).forEach {
          let bOff = nameRangeStart + $0
          bytes[bOff] = bytes[bOff].set(bits: 0...5, value: 62)
        }
      }
    }
  }
  
}

class AlphaJunoVoicePatch : AlphaJunoNamedPatch, BankablePatch, VoicePatch {
  
  static let bankType: SysexPatchBank.Type = AlphaJunoVoiceBank.self
  static func location(forData data: Data) -> Int {
    return Int(data[8]) // this is the general block location, not specific patch
  }

  // 44 bytes - 4.1 Dump without name
  // 54 bytes - 3.1.1 All Params with Tone Name // transmitted when patch change on synth
  // 64 bytes - 3.2 Bulk Dump: an entire bulk dump has 4 tones. The 64 bytes will be just the data bytes for 1 tone (as nibbles)
  
  // internal PB bytes are in 3.2 BULK format, but not nibblized. this is weird but it works.
  // 32 bytes. 21 for values + 10 for name (with some value bits) + a 0 at the end
  
  static let fileDataCount = 54 // FILES will be in 3.1.1 format!
  static let nameByteRange = 21..<31
  // TODO: need actual init file
  static let initFileName = "alpha-juno-voice-init"

  var bytes: [UInt8]

  static func isValid(fileSize: Int) -> Bool {
    return [44,54,64].contains(fileSize)
  }

  required init(data: Data) {
    switch data.count {
    case 44, 54:
      bytes = [UInt8](repeating: 0, count: 32)
      // set params
      data[7..<43].enumerated().forEach { (parm, value) in
        let paramPair = type(of: self).params.first { $0.value.parm == parm }
        guard let path = paramPair?.key else { return }
        if let rangeParam = paramPair?.value as? RangeParam,
          rangeParam.range.upperBound == 15 {
          self[path] = Int(value >> 3) // for some reason these are shifted?
        }
        else {
          self[path] = Int(value)
        }
      }
      if data.count == 54 {
        // set name
        data[43..<53].enumerated().forEach {
          let bOff = 21 + $0.offset
          bytes[bOff] = bytes[bOff].set(bits: 0...5, value: Int($0.element))
        }
      }
    case 64:
      // bulk data. de-nibblize bytes and store directly
      bytes = (0..<32).map {
        // LSB first
        let lsb = data[$0 * 2] & 0xf
        let msb = (data[$0 * 2 + 1] & 0xf) << 4
        return lsb + msb
      }
    default:
      debugPrint("Alpha Juno: Unknown data count for init")
      bytes = [UInt8](repeating: 0, count: 32)
    }
  }
    
  
  func fileData() -> Data {
    return sysexData(channel: 0)
  }
  
  /// Patch as sysex for edit buffer - 3.1.1 (dump WITH name)
  func sysexData(channel: Int) -> Data {
    var data = Data([0xf0, 0x41, 0x35, UInt8(channel), 0x23, 0x20, 0x01])
    let params = (0..<36).map { parm -> UInt8 in
      guard let paramPair = type(of: self).params.first(where: { $0.value.parm == parm }) else { return 0 }
      if let rangeParam = paramPair.value as? RangeParam,
        rangeParam.range.upperBound == 15 {
        return UInt8(self[paramPair.key] ?? 0) << 3 // again, weird shift
      }
      else {
        return UInt8(self[paramPair.key] ?? 0)
      }
    }
    data.append(contentsOf: params)
    // then name
    data.append(contentsOf: bytes[type(of: self).nameByteRange].map { UInt8($0.bits(0...5)) })
    data.append(0xf7)
    return data
  }

  /// Helper function to reference bits like the docs do
  private func b(_ index: Int) -> UInt8 {
    return bytes[index + 4].bit(7)
  }
  
  private func setB(_ index: Int, value: UInt8) {
    bytes[index + 4] = bytes[index + 4].set(bit: 7, value: Int(value))
  }
  
  subscript(path: SynthPath) -> Int? {
    get {
      guard let param = type(of: self).params[path] else { return nil }
      switch path {
      case [.pitch, .env, .mode]:
        return Int((b(1) << 1) + b(2))
      case [.filter, .env, .mode]:
        return Int((b(3) << 1) + b(4))
      case [.amp, .env, .mode]:
        return Int((b(5) << 1) + b(6))
      case [.osc, .wave, .sub]:
        return Int((b(7) << 2) + (b(8) << 1) + b(9))
      case [.osc, .wave, .saw]:
        return Int((b(10) << 2) + (b(11) << 1) + b(12))
      case [.osc, .wave, .pulse]:
        return Int((b(13) << 1) + b(14))
      case [.hi, .cutoff]:
        return Int((b(15) << 1) + b(16))
      case [.osc, .range]:
        return Int((b(17) << 1) + b(18))
      case [.osc, .sub, .level]:
        return Int((b(19) << 1) + b(20))
      case [.osc, .noise, .level]:
        return Int((b(21) << 1) + b(22))
      case [.chorus, .rate]:
        let b6 = (bytes[30].bit(6) as Int) << 6
        let b54 = bytes[29].bits(6...7) << 4
        let b32 = bytes[28].bits(6...7) << 2
        let b10 = bytes[27].bits(6...7)
        return b6 + b54 + b32 + b10
      default:
        return unpack(param: param)
      }
    }
    set {
      guard let param = type(of: self).params[path],
        let v = newValue else { return }
      switch path {
      case [.pitch, .env, .mode]:
        setB(1, value: v.bit(1))
        setB(2, value: v.bit(0))
      case [.filter, .env, .mode]:
        setB(3, value: v.bit(1))
        setB(4, value: v.bit(0))
      case [.amp, .env, .mode]:
        setB(5, value: v.bit(1))
        setB(6, value: v.bit(0))
      case [.osc, .wave, .sub]:
        setB(7, value: v.bit(2))
        setB(8, value: v.bit(1))
        setB(9, value: v.bit(0))
      case [.osc, .wave, .saw]:
        setB(10, value: v.bit(2))
        setB(11, value: v.bit(1))
        setB(12, value: v.bit(0))
      case [.osc, .wave, .pulse]:
        setB(13, value: v.bit(1))
        setB(14, value: v.bit(0))
      case [.hi, .cutoff]:
        setB(15, value: v.bit(1))
        setB(16, value: v.bit(0))
      case [.osc, .range]:
        setB(17, value: v.bit(1))
        setB(18, value: v.bit(0))
      case [.osc, .sub, .level]:
        setB(19, value: v.bit(1))
        setB(20, value: v.bit(0))
      case [.osc, .noise, .level]:
        setB(21, value: v.bit(1))
        setB(22, value: v.bit(0))
      case [.chorus, .rate]:
        bytes[30] = bytes[30].set(bits: 6...7, value: v.bits(6...7))
        bytes[29] = bytes[29].set(bits: 6...7, value: v.bits(4...5))
        bytes[28] = bytes[29].set(bits: 6...7, value: v.bits(2...3))
        bytes[27] = bytes[29].set(bits: 6...7, value: v.bits(0...1))
      default:
        pack(value: v, forParam: param)
      }
    }
  }
  
  static let params : SynthPathParam = {
    var p = SynthPathParam()
    
    p[[.pitch, .env, .mode]] = OptionsParam(parm: 0, byte: -1, options: ["Normal", "Inverted", "Normal+Dyn", "Invert+Dyn"])
    p[[.filter, .env, .mode]] = OptionsParam(parm: 1, byte: -1, options: ["Normal", "Inverted", "Normal+Dyn", "Dynamics"])
    p[[.amp, .env, .mode]] = OptionsParam(parm: 2, byte: -1, options: ["Normal", "Gate", "Normal+Dyn", "Gate+Dyn"])
    p[[.osc, .wave, .pulse]] = OptionsParam(parm: 3, byte: -1, options: OptionsParam.makeOptions((0..<4).map { "alpha-juno-pulse-\($0)"}))
    p[[.osc, .wave, .saw]] = OptionsParam(parm: 4, byte: -1, options: OptionsParam.makeOptions((0..<6).map { "alpha-juno-saw-\($0)"}))
    p[[.osc, .wave, .sub]] = OptionsParam(parm: 5, byte: -1, options: OptionsParam.makeOptions((0..<6).map { "alpha-juno-sub-\($0)"}))
    p[[.osc, .range]] = OptionsParam(parm: 6, byte: -1, options: ["4'", "8'", "16'", "32'"])
    p[[.osc, .sub, .level]] = RangeParam(parm: 7, byte: -1, maxVal: 3)
    p[[.osc, .noise, .level]] = RangeParam(parm: 8, byte: -1, maxVal: 3)
    p[[.hi, .cutoff]] = OptionsParam(parm: 9, byte: -1, options: ["Low Boost", "Off", "Lo Cutoff", "Hi Cutoff"])
    p[[.chorus]] = RangeParam(parm: 10, byte: 4, bit: 7)
    p[[.pitch, .lfo]] = RangeParam(parm: 11, byte: 3, bits: 0...6)
    p[[.pitch, .env]] = RangeParam(parm: 12, byte: 4, bits: 0...6)
    p[[.pitch, .aftertouch]] = RangeParam(parm: 13, byte: 0, bits: 4...7, maxVal: 15)
    p[[.osc, .pw, .depth]] = RangeParam(parm: 14, byte: 5, bits: 0...6)
    p[[.osc, .pw, .rate]] = RangeParam(parm: 15, byte: 6, bits: 0...6)
    p[[.cutoff]] = RangeParam(parm: 16, byte: 7, bits: 0...6)
    p[[.reson]] = RangeParam(parm: 17, byte: 8, bits: 0...6)
    p[[.filter, .lfo]] = RangeParam(parm: 18, byte: 10, bits: 0...6)
    p[[.filter, .env]] = RangeParam(parm: 19, byte: 9, bits: 0...6)
    p[[.filter, .keyTrk]] = RangeParam(parm: 20, byte: 0, bits: 0...3, maxVal: 15)
    p[[.filter, .aftertouch]] = RangeParam(parm: 21, byte: 1, bits: 4...7, maxVal: 15)
    p[[.amp, .level]] = RangeParam(parm: 22, byte: 11, bits: 0...6)
    p[[.amp, .aftertouch]] = RangeParam(parm: 23, byte: 1, bits: 0...3, maxVal: 15)
    p[[.lfo, .rate]] = RangeParam(parm: 24, byte: 12, bits: 0...6)
    p[[.lfo, .delay]] = RangeParam(parm: 25, byte: 13, bits: 0...6)
    p[[.env, .time, .i(0)]] = RangeParam(parm: 26, byte: 14, bits: 0...6)
    p[[.env, .level, .i(0)]] = RangeParam(parm: 27, byte: 15, bits: 0...6)
    p[[.env, .time, .i(1)]] = RangeParam(parm: 28, byte: 16, bits: 0...6)
    p[[.env, .level, .i(1)]] = RangeParam(parm: 29, byte: 17, bits: 0...6)
    p[[.env, .time, .i(2)]] = RangeParam(parm: 30, byte: 18, bits: 0...6)
    p[[.env, .level, .i(2)]] = RangeParam(parm: 31, byte: 19, bits: 0...6)
    p[[.env, .time, .i(3)]] = RangeParam(parm: 32, byte: 20, bits: 0...6)
    p[[.env, .keyTrk]] = RangeParam(parm: 33, byte: 2, bits: 4...7, maxVal: 15)
    p[[.chorus, .rate]] = RangeParam(parm: 34, byte: -1)
    p[[.bend]] = RangeParam(parm: 35, byte: 2, bits: 0...3, maxVal: 12)

    return p
  }()
  

}

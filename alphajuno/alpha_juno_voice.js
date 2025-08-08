
const parms = [
  { inc: 1, p: 0, block: [
    ["pitch/env/mode", { b: -1, opts: ["Normal", "Inverted", "Normal+Dyn", "Invert+Dyn"] }],
    ["filter/env/mode", { b: -1, opts: ["Normal", "Inverted", "Normal+Dyn", "Dynamics"] }],
    ["amp/env/mode", { b: -1, opts: ["Normal", "Gate", "Normal+Dyn", "Gate+Dyn"] }],
    ["osc/wave/pulse", { b: -1, opts: (4).map(i =>  `alpha-juno-pulse-${$0}`) }],
    ["osc/wave/saw", { b: -1, opts: (6).map(i =>  `alpha-juno-saw-${$0}`) }],
    ["osc/wave/sub", { b: -1, opts: (6).map(i =>  `alpha-juno-sub-${$0}`) }],
    ["osc/range", { b: -1, opts: ["4'", "8'", "16'", "32'"] }],
    ["osc/sub/level", { b: -1, max: 3 }],
    ["osc/noise/level", { b: -1, max: 3 }],
    ["hi/cutoff", { b: -1, opts: ["Low Boost", "Off", "Lo Cutoff", "Hi Cutoff"] }],
    ["chorus", { b: 4, bit: 7 }],
    ["pitch/lfo", { b: 3, bits: [0, 6] }],
    ["pitch/env", { b: 4, bits: [0, 6] }],
    ["pitch/aftertouch", { b: 0, bits: [4, 7], max: 15 }],
    ["osc/pw/depth", { b: 5, bits: [0, 6] }],
    ["osc/pw/rate", { b: 6, bits: [0, 6] }],
    ["cutoff", { b: 7, bits: [0, 6] }],
    ["reson", { b: 8, bits: [0, 6] }],
    ["filter/lfo", { b: 10, bits: [0, 6] }],
    ["filter/env", { b: 9, bits: [0, 6] }],
    ["filter/keyTrk", { b: 0, bits: [0, 3], max: 15 }],
    ["filter/aftertouch", { b: 1, bits: [4, 7], max: 15 }],
    ["amp/level", { b: 11, bits: [0, 6] }],
    ["amp/aftertouch", { b: 1, bits: [0, 3], max: 15 }],
    ["lfo/rate", { b: 12, bits: [0, 6] }],
    ["lfo/delay", { b: 13, bits: [0, 6] }],
    ["env/time/0", { b: 14, bits: [0, 6] }],
    ["env/level/0", { b: 15, bits: [0, 6] }],
    ["env/time/1", { b: 16, bits: [0, 6] }],
    ["env/level/1", { b: 17, bits: [0, 6] }],
    ["env/time/2", { b: 18, bits: [0, 6] }],
    ["env/level/2", { b: 19, bits: [0, 6] }],
    ["env/time/3", { b: 20, bits: [0, 6] }],
    ["env/keyTrk", { b: 2, bits: [4, 7], max: 15 }],
    ["chorus/rate", { b: -1 }],
    ["bend", { b: 2, bits: [0, 3], max: 12 }],
  ] },
]

const patchTruss = {
  single: 'alpha_juno.voice'
  // const fileDataCount = 54 // FILES will be in 3.1.1 format!
  bodyDataCount: 32,
  namePack: [21, 30],
  initFile: "alpha-juno-voice-init",
  validSizes: [44,54,64],
  parms: parms,
}

protocol AlphaJunoNamedPatch : ByteBackedSysexPatch { }
extension AlphaJunoNamedPatch {

  var name: String {
    get {
      let letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789 -"
      let n: [Character] = bytes[type(of: self).nameByteRange].map { b in
        let bClip = b.bits([0, 5])
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
        bytes[bOff] = bytes[bOff].set(bits: [0, 5], value: index)
      }
      // pad the rest with spaces
      if newValue.count < 10 {
        (newValue.count..<10).forEach {
          let bOff = nameRangeStart + $0
          bytes[bOff] = bytes[bOff].set(bits: [0, 5], value: 62)
        }
      }
    }
  }
  
}

class AlphaJunoVoicePatch : AlphaJunoNamedPatch, BankablePatch, VoicePatch {
  
  static func location(forData data: Data) -> Int {
    return Int(data[8]) // this is the general block location, not specific patch
  }

  // 44 bytes - 4.1 Dump without name
  // 54 bytes - 3.1.1 All Params with Tone Name // transmitted when patch change on synth
  // 64 bytes - 3.2 Bulk Dump: an entire bulk dump has 4 tones. The 64 bytes will be just the data bytes for 1 tone (as nibbles)
  
  // internal PB bytes are in 3.2 BULK format, but not nibblized. this is weird but it works.
  // 32 bytes. 21 for values + 10 for name (with some value bits) + a 0 at the end
  
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
          bytes[bOff] = bytes[bOff].set(bits: [0, 5], value: Int($0.element))
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
    data.append(contentsOf: bytes[type(of: self).nameByteRange].map { UInt8($0.bits([0, 5])) })
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
      case "pitch/env/mode":
        return Int((b(1) << 1) + b(2))
      case "filter/env/mode":
        return Int((b(3) << 1) + b(4))
      case "amp/env/mode":
        return Int((b(5) << 1) + b(6))
      case "osc/wave/sub":
        return Int((b(7) << 2) + (b(8) << 1) + b(9))
      case "osc/wave/saw":
        return Int((b(10) << 2) + (b(11) << 1) + b(12))
      case "osc/wave/pulse":
        return Int((b(13) << 1) + b(14))
      case "hi/cutoff":
        return Int((b(15) << 1) + b(16))
      case "osc/range":
        return Int((b(17) << 1) + b(18))
      case "osc/sub/level":
        return Int((b(19) << 1) + b(20))
      case "osc/noise/level":
        return Int((b(21) << 1) + b(22))
      case "chorus/rate":
        let b6 = (bytes[30].bit(6) as Int) << 6
        let b54 = bytes[29].bits([6, 7]) << 4
        let b32 = bytes[28].bits([6, 7]) << 2
        let b10 = bytes[27].bits([6, 7])
        return b6 + b54 + b32 + b10
      default:
        return unpack(param: param)
      }
    }
    set {
      guard let param = type(of: self).params[path],
        let v = newValue else { return }
      switch path {
      case "pitch/env/mode":
        setB(1, value: v.bit(1))
        setB(2, value: v.bit(0))
      case "filter/env/mode":
        setB(3, value: v.bit(1))
        setB(4, value: v.bit(0))
      case "amp/env/mode":
        setB(5, value: v.bit(1))
        setB(6, value: v.bit(0))
      case "osc/wave/sub":
        setB(7, value: v.bit(2))
        setB(8, value: v.bit(1))
        setB(9, value: v.bit(0))
      case "osc/wave/saw":
        setB(10, value: v.bit(2))
        setB(11, value: v.bit(1))
        setB(12, value: v.bit(0))
      case "osc/wave/pulse":
        setB(13, value: v.bit(1))
        setB(14, value: v.bit(0))
      case "hi/cutoff":
        setB(15, value: v.bit(1))
        setB(16, value: v.bit(0))
      case "osc/range":
        setB(17, value: v.bit(1))
        setB(18, value: v.bit(0))
      case "osc/sub/level":
        setB(19, value: v.bit(1))
        setB(20, value: v.bit(0))
      case "osc/noise/level":
        setB(21, value: v.bit(1))
        setB(22, value: v.bit(0))
      case "chorus/rate":
        bytes[30] = bytes[30].set(bits: [6, 7], value: v.bits([6, 7]))
        bytes[29] = bytes[29].set(bits: [6, 7], value: v.bits([4, 5]))
        bytes[28] = bytes[29].set(bits: [6, 7], value: v.bits([2, 3]))
        bytes[27] = bytes[29].set(bits: [6, 7], value: v.bits([0, 1]))
      default:
        pack(value: v, forParam: param)
      }
    }
  }
  
}


class AlphaJunoVoiceBank : TypicalTypedSysexPatchBank<AlphaJunoVoicePatch>, VoiceBank {
  
  // 266 * 16
  override class var fileDataCount: Int { 4256 }
  override class var patchCount: Int { 64 }
  // TODO: need actual init file
  override class var initFileName: String { return "alpha-juno-voice-bank-init" }
  
//  override class func isValid(fileSize: Int) -> Bool {
//    return fileSize == fileDataCount || fileSize == 33152
//  }
  
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
  
  required init(patches p: [Patch]) {
    super.init(patches: p)
  }
  
  func sysexData(channel: Int) -> [Data] {
    return (0..<16).map { msgIndex -> Data in
      let pOff = msgIndex * 4
      var d = Data([0xf0, 0x41, 0x37, UInt8(channel), 0x23, 0x20, 0x01, 0x00, UInt8(pOff)])
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
  
  // put here bc TypicalTypedRolandAddressableBank has same impl, but calls protocol version of
  // sysexData(deviceId: for some reason
  override open func fileData() -> Data {
    return Data(sysexData(channel: 0).joined())
  }

}

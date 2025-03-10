
class MicronVoicePatch : ByteBackedSysexPatch, BankablePatch {
  
  static let bankType: SysexPatchBank.Type = MicronVoiceBank.self
  static func location(forData data: Data) -> Int { return Int(data[8] & 0x7f) }
    
  static let nameByteRange = 0..<14
  static let initFileName = "micron-voice-init"
  static let fileDataCount = 434
  
  var bytes: [UInt8]
  
  static var debugBytes = [UInt8](repeating: 0, count: 315)
  
  required init(data: Data) {
    let b = data.unpackR87(count: 371, inRange: 9..<433)
    // 315 patch data bytes
    bytes = [UInt8](b[56..<371])
    
//    DispatchQueue.main.async {
//      (0..<315).forEach {
//        guard self.bytes.count > $0 && type(of: self).debugBytes.count > $0 else { return }
//        if self.bytes[$0] != type(of: self).debugBytes[$0] {
//          let binString = String(self.bytes[$0], radix: 2)
//          let other = String(repeating: Character("0"), count: 8 - binString.count) + binString
//          debugPrint("\($0): \(other)")
//        }
//        type(of: self).debugBytes[$0] = self.bytes[$0]
//      }
//    }
  }
  
  // same as default implementation, except name gets saved in TWO spots
  var name: String {
    set {
      set(string: newValue, forByteRange: type(of: self).nameByteRange)
      // name is from 296-309 (repeated)
      set(string: newValue, forByteRange: 296..<310)
    }
    get {
      let nameByteRange = type(of: self).nameByteRange
      return type(of: self).name(forRange: nameByteRange, bytes: bytes)
    }
  }

  
  subscript(path: SynthPath) -> Int? {
    get {
      guard let param = type(of: self).params[path] else { return nil }
      
      switch path {
      case [.lfo, .i(0), .tempo, .sync],
           [.lfo, .i(1), .tempo, .sync],
           [.sample, .tempo, .sync],
           [.bend]:
        // syncs and p bend are flipped...
        return 1 - (unpack(param: param) ?? 0)
      case [.unison]:
        // 0 is 2 voices, 1 is unison OFF
        let v = (unpack(param: param) ?? 0)
        return v < 2 ? 1 - v : v
      case [.osc, .sync]:
        let v = (bytes[35].bit(0) << 2) +  bytes[34].bits(6...7)
        return type(of: self).syncMap.firstIndex(of: v)
      case [.fm, .type]:
        let v = (bytes[36].bit(7) << 2) + bytes[35].bits(2...3)
        return type(of: self).fmMap.firstIndex(of: v)
      case [.filter, .i(0), .type],
           [.filter, .i(1), .type]:
        let v = (unpack(param: param) ?? 0)
        return type(of: self).filterMap.firstIndex(of: v)
      case [.porta]:
        let v: Int = (bytes[19].bit(0) << 1) + bytes[16].bit(7)
        return type(of: self).portaMap.firstIndex(of: v)
      case [.fx, .i(0), .type]:
        let v = (unpack(param: param) ?? 0)
        return type(of: self).fx0Map.firstIndex(of: v)
      case [.fx, .i(0), .param, .i(5)]:
        if [1,2,3,5].contains(self[[.fx, .i(0), .type]]) {
          // chorus, flangers, string phaser. sync param is inverted
          let v = (unpack(param: param) ?? 0)
          return v == 0 ? 1 : 0
        }
      case [.fx, .i(0), .param, .i(6)]:
        if self[[.fx, .i(0), .type]] == 4 {
          // super phaser. sync param is inverted
          let v = (unpack(param: param) ?? 0)
          return v == 0 ? 1 : 0
        }
      case [.fx, .i(0), .param, .i(7)]:
        let v = (unpack(param: param) ?? 0)
        return 24 - v
      case [.trk, .src]:
        let v = (unpack(param: param) ?? 0)
        return type(of: self).trkSrcMap.firstIndex(of: v)
      case [.sample, .src]:
        let v = (unpack(param: param) ?? 0)
        return type(of: self).shSrcMap.firstIndex(of: v)
      case [.mod, .i(0), .src],
           [.mod, .i(1), .src],
           [.mod, .i(2), .src],
           [.mod, .i(3), .src],
           [.mod, .i(4), .src],
           [.mod, .i(5), .src],
           [.mod, .i(6), .src],
           [.mod, .i(7), .src],
           [.mod, .i(8), .src],
           [.mod, .i(9), .src],
           [.mod, .i(10), .src],
           [.mod, .i(11), .src]:
        let v = (unpack(param: param) ?? 0)
        return type(of: self).modSrcMap.firstIndex(of: v)
      case [.mod, .i(0), .dest],
           [.mod, .i(1), .dest],
           [.mod, .i(2), .dest],
           [.mod, .i(3), .dest],
           [.mod, .i(4), .dest],
           [.mod, .i(5), .dest],
           [.mod, .i(6), .dest],
           [.mod, .i(7), .dest],
           [.mod, .i(8), .dest],
           [.mod, .i(9), .dest],
           [.mod, .i(10), .dest],
           [.mod, .i(11), .dest]:
        let v = (unpack(param: param) ?? 0)
        return type(of: self).modDestMap.firstIndex(of: v)
      default:
        break
      }
      return unpack(param: param)
    }
    set {
      guard let param = type(of: self).params[path],
        let newValue = newValue else { return }
      var packValue = newValue
      switch path {
      case [.lfo, .i(0), .tempo, .sync],
           [.lfo, .i(1), .tempo, .sync],
           [.sample, .tempo, .sync]:
        packValue = newValue == 0 ? 1 : 0
      case [.unison]:
        packValue = newValue < 2 ? 1 - newValue : newValue
      case [.osc, .sync]:
        packValue = type(of: self).syncMap[newValue]
        bytes[34] = bytes[34].set(bits: 6...7, value: packValue.bits(0...1))
        bytes[35] = bytes[35].set(bit: 0, value: packValue.bit(2))
        return
      case [.fm, .type]:
        packValue = type(of: self).fmMap[newValue]
        bytes[35] = bytes[35].set(bits: 2...3, value: packValue.bits(0...1))
        bytes[36] = bytes[36].set(bit: 7, value: packValue.bit(2))
        return
      case [.filter, .i(0), .type],
           [.filter, .i(1), .type]:
        packValue = type(of: self).filterMap[newValue]
      case [.porta]:
        packValue = type(of: self).portaMap[newValue]
        bytes[16] = bytes[16].set(bit: 7, value: packValue.bit(0))
        bytes[19] = bytes[19].set(bit: 0, value: packValue.bit(1))
        return
      case [.fx, .i(0), .type]:
        packValue = type(of: self).fx0Map[newValue]
      case [.fx, .i(0), .param, .i(5)]:
        if [1,2,3,5].contains(self[[.fx, .i(0), .type]]) {
          // chorus, flangers, string phaser. sync param is inverted
          packValue = newValue == 0 ? 1 : 0
        }
      case [.fx, .i(0), .param, .i(6)]:
        if self[[.fx, .i(0), .type]] == 4 {
          // super phaser. sync param is inverted
          packValue = newValue == 0 ? 1 : 0
        }
      case [.fx, .i(0), .param, .i(7)]:
        packValue = 24 - newValue
      case [.trk, .src]:
        packValue = type(of: self).trkSrcMap[newValue]
      case [.sample, .src]:
        packValue = type(of: self).shSrcMap[newValue]
      case [.mod, .i(0), .src],
           [.mod, .i(1), .src],
           [.mod, .i(2), .src],
           [.mod, .i(3), .src],
           [.mod, .i(4), .src],
           [.mod, .i(5), .src],
           [.mod, .i(6), .src],
           [.mod, .i(7), .src],
           [.mod, .i(8), .src],
           [.mod, .i(9), .src],
           [.mod, .i(10), .src],
           [.mod, .i(11), .src]:
        packValue = type(of: self).modSrcMap[newValue]
      case [.mod, .i(0), .dest],
           [.mod, .i(1), .dest],
           [.mod, .i(2), .dest],
           [.mod, .i(3), .dest],
           [.mod, .i(4), .dest],
           [.mod, .i(5), .dest],
           [.mod, .i(6), .dest],
           [.mod, .i(7), .dest],
           [.mod, .i(8), .dest],
           [.mod, .i(9), .dest],
           [.mod, .i(10), .dest],
           [.mod, .i(11), .dest]:
        packValue = type(of: self).modDestMap[newValue]
      default:
        break
      }
      pack(value: packValue, forParam: param)
    }
  }
  
  static let portaMap = [1,2,0]
  static let syncMap = [1,4,6,0,2]
  static let fmMap = [2,1,0,6,5,4]
  static let filterMap = [0, 2, 6, 1, 7, 5, 8, 3, 10, 9, 17, 4, 18, 14, 15, 16, 12, 13, 19, 20, 11]
  static let fx0Map = [0, 5, 3, 4, 1, 2, 6]
  static let trkSrcMap = [33, 8, 9, 10, 7, 2, 111, 15, 16, 11, 12, 17, 18, 13, 14, 23, 24, 19, 20, 25, 26, 21, 22, 3, 4, 5, 31, 30, 32, 29, 28, 27, 6, 0, 1, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110]
  static let shSrcMap = [34, 8, 9, 10, 7, 2, 112, 15, 16, 11, 12, 17, 18, 13, 14, 23, 24, 19, 20, 25, 26, 21, 22, 3, 4, 5, 30, 29, 33, 28, 27, 6, 31, 32, 0, 1, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 111]
  static let modSrcMap = [0, 36, 9, 10, 11, 8, 3, 114, 16, 17, 12, 13, 18, 19, 14, 15, 24, 25, 20, 21, 26, 27, 22, 23, 4, 5, 6, 32, 31, 35, 30, 29, 28, 7, 33, 34, 1, 2, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 111, 112, 113]
  static let modDestMap = [0, 1, 79, 11, 2, 5, 8, 3, 6, 9, 4, 7, 10, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 42, 43, 44, 45, 46, 47, 48, 49, 51, 74, 75, 76, 77, 78, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 35, 36, 37, 38, 39, 40, 41]
  
  func unpack(param: Param) -> Int? {
    if let _ = param.extra[MicronVoicePatch.ByteCount] {
      // 2-byte param
      let v = 0.set(bits: 8...15, value: bytes[param.byte])
        .set(bits: 0...7, value: bytes[param.byte+1])
      if let rangeParam = param as? ParamWithRange,
        rangeParam.range.lowerBound < 0 {
        return v.int16()
      }
      else {
        return v
      }
    }
    else {
      // 1-byte param
      let v = defaultUnpack(param: param)
      if let rangeParam = param as? ParamWithRange,
        rangeParam.range.lowerBound < 0 {

        guard param.byte < bytes.count else { return nil }
        guard let bits = param.bits else { return Int(Int8(bitPattern: bytes[param.byte])) }
        return Int(bytes[param.byte]).signedBits(bits)
      }
      else {
        return v
      }
    }
  }
  
  func pack(value: Int, forParam param: Param) {
    // all multi-byte params are 2 bytes, so don't need to check count
    if let _ = param.extra[MicronVoicePatch.ByteCount] {
      let v: Int = value.int16()
      bytes[param.byte] = UInt8(v.bits(8...15))
      bytes[param.byte+1] = UInt8(v.bits(0...7))
    }
    else {
      defaultPack(value: value, forParam: param)
    }
  }

    // save to synth
    // f0 00 00 0e 22 01 <bank> 02 <location> ...
    // fetch (huge) bank (micron/miniak)
    // f0 00 00 0e 22 41 00 06 00 f7
    // fetch patch (from bank only?) bank 0 loc 0 doesn't respond tho?
    // f0 00 00 0e 22 41 <bank> 00 <location> f7
    func sysexData(bank: UInt8, location: UInt8) -> Data {
      var sum: Int64 = 0
      (0..<78).forEach {
        sum += (Int64(bytes[($0 * 4)])     << 24)
        sum += (Int64(bytes[($0 * 4) + 1]) << 16)
        sum += (Int64(bytes[($0 * 4) + 2]) << 8)
        sum += (Int64(bytes[($0 * 4) + 3]) << 0)
      }
      sum = -1 * sum
      let sum32 = Int(truncatingIfNeeded: sum)
      
      // 0x02 command saves by location! 0x00 saves by name.
      var data = Data([0xf0, 0x00, 0x00, 0x0e, 0x26, 0x01, bank, 0x02, location])
      var bytes78 = [UInt8]()
      bytes78 += "Q01SYNTH".unicodeScalars.map { UInt8($0.value) }
      // checksum ( 4 bytes)
      bytes78 += [UInt8(sum32.bits(24...31)),
                  UInt8(sum32.bits(16...23)),
                  UInt8(sum32.bits(8...15)),
                  UInt8(sum32.bits(0...7))]
      // version # (4 bytes)
      bytes78 += [0x80, 0x00, 0x00, 0x00]
      // blank bytes
      bytes78 += [UInt8](repeating: 0, count: 28)
      // size
      bytes78 += [0x00, 0x00, 0x01, 0x3b]
      // blank bytes
      bytes78 += [UInt8](repeating: 0, count: 8)
      bytes78 += bytes
      data.appendR78(bytes: bytes78, count: 424)
      data.append(0xf7)
      return data
    }
    
    func fileData() -> Data {
      return sysexData(bank: 7, location: 127)
    }

    func randomize() {
      randomizeAllParams()
    }
    
    static let ByteCount = 0
  
    static let params: SynthPathParam = {
      var p = SynthPathParam()
      
      p[[.poly]] = RangeParam(parm: 0, byte: 15, bit: 0)
      p[[.unison]] = OptionsParam(parm: 1, byte: 15, bits: 1...3, options: [
        0 : "Off",
        1 : "2 voices",
        2 : "4 voices",
        4 : "8 voices",
      ])
      p[[.porta, .type]] = OptionsParam(parm: 4, byte: 15, bits: 6...7, options: ["Fixed", "Scaled", "Gliss Fixed", "Gliss Scaled"])
      p[[.unison, .detune]] = RangeParam(parm: 2, byte: 16, bits: 0...6, maxVal: 100)
      p[[.porta]] = OptionsParam(parm: 3, byte: 19, options: ["Off", "Legato", "Always"])
      p[[.porta, .time]] = RangeParam(parm: 5, byte: 17, formatter: {
        guard $0 < 127 else { return "10000" }
        return String(format:"%.0f" , exp(Double($0) / 18.38514) * 10)
      })
      p[[.bend]] = OptionsParam(parm: 6, byte: 18, options: ["Held", "Playing"])
      p[[.analogFeel]] = RangeParam(parm: 7, byte: 20, maxVal: 100)
      p[[.category]] = OptionsParam(parm: 154, byte: 23, options: ["Recent", "Faves", "Bass", "Lead", "Pad", "String", "Brass", "Key", "Comp", "Drum", "SFX"])
      p[[.osc, .i(0), .fine]] = RangeParam(parm: 15, byte: 24, extra: [ByteCount:2], range: -999...999)
      p[[.osc, .i(1), .fine]] = RangeParam(parm: 21, byte: 26, extra: [ByteCount:2], range: -999...999)
      p[[.osc, .i(2), .fine]] = RangeParam(parm: 27, byte: 28, extra: [ByteCount:2], range: -999...999)
      p[[.osc, .i(0), .shape]] = RangeParam(parm: 12, byte: 30, range: -100...100)
      p[[.osc, .i(1), .shape]] = RangeParam(parm: 18, byte: 31, range: -100...100)
      p[[.osc, .i(2), .shape]] = RangeParam(parm: 24, byte: 32, range: -100...100)
      p[[.osc, .i(0), .octave]] = RangeParam(parm: 13, byte: 33, bits: 0...2, maxVal: 6, displayOffset: -3)
      p[[.osc, .i(0), .semitone]] = RangeParam(parm: 14, byte: 33, bits: 4...7, maxVal: 14, displayOffset: -7)
      let oscWaveOptions = OptionsParam.makeOptions(["Sin", "Tri/Saw", "Pulse"])
      p[[.osc, .i(0), .wave]] = OptionsParam(parm: 11, byte: 34, bits: 0...1, options: oscWaveOptions)
      p[[.osc, .i(0), .bend]] = RangeParam(parm: 16, byte: 34, bits: 2...5, maxVal: 12)
      p[[.osc, .sync]] = OptionsParam(parm: 8, byte: 34, options: ["Off", "Hard 2>1", "Hard 2+3>1", "Soft 2>1", "Soft 2+3>1"])
      p[[.osc, .i(1), .wave]] = OptionsParam(parm: 17, byte: 35, bits: 4...5, options: oscWaveOptions)
      p[[.osc, .i(2), .wave]] = OptionsParam(parm: 23, byte: 35, bits: 6...7, options: oscWaveOptions)
      p[[.fm, .type]] = OptionsParam(parm: 10, byte: 36, options:["Lin 2>1", "Lin 2+3>1", "Lin 3>2>1", "Exp 2> 1", "Exp 2+3>1", "Exp 3>2>1", ])
      p[[.osc, .i(1), .octave]] = RangeParam(parm: 19, byte: 37, bits: 0...2, maxVal: 6, displayOffset: -3)
      p[[.osc, .i(1), .semitone]] = RangeParam(parm: 20, byte: 37, bits: 4...7, maxVal: 14, displayOffset: -7)
      p[[.osc, .i(2), .octave]] = RangeParam(parm: 25, byte: 38, bits: 0...2, maxVal: 6, displayOffset: -3)
      p[[.osc, .i(2), .semitone]] = RangeParam(parm: 26, byte: 38, bits: 4...7, maxVal: 14, displayOffset: -7)
      p[[.osc, .i(1), .bend]] = RangeParam(parm: 22, byte: 39, bits: 0...3, maxVal: 12)
      p[[.osc, .i(2), .bend]] = RangeParam(parm: 28, byte: 39, bits: 4...7, maxVal: 12)
      p[[.fm, .amt]] = RangeParam(parm: 9, byte: 40, extra: [ByteCount:2], maxVal: 1000)
      p[[.osc, .i(0), .level]] = RangeParam(parm: 29, byte: 45, maxVal: 100)
      p[[.osc, .i(1), .level]] = RangeParam(parm: 30, byte: 46, maxVal: 100)
      p[[.osc, .i(2), .level]] = RangeParam(parm: 31, byte: 47, maxVal: 100)
      p[[.ringMod, .level]] = RangeParam(parm: 32, byte: 48, maxVal: 100)
      p[[.ext, .level]] = RangeParam(parm: 34, byte: 49, maxVal: 100)
      p[[.osc, .i(0), .balance]] = RangeParam(parm: 35, byte: 50, range: -50...50, formatter: balanceFrmt)
      p[[.osc, .i(1), .balance]] = RangeParam(parm: 36, byte: 51, range: -50...50, formatter: balanceFrmt)
      p[[.osc, .i(2), .balance]] = RangeParam(parm: 37, byte: 52, range: -50...50, formatter: balanceFrmt)
      p[[.ringMod, .balance]] = RangeParam(parm: 38, byte: 53, range: -50...50, formatter: balanceFrmt)
      p[[.ext, .balance]] = RangeParam(parm: 40, byte: 54, range: -100...100)
      p[[.noise, .balance]] = RangeParam(parm: 39, byte: 55, range: -50...50, formatter: balanceFrmt)
      p[[.filter, .balance]] = RangeParam(parm: 41, byte: 56, maxVal: 100)
      p[[.noise, .level]] = RangeParam(parm: 33, byte: 57, bits: 0...6, maxVal: 100)
      p[[.noise, .type]] = OptionsParam(parm: 42, byte: 57, bit: 7, options: ["Pink", "White"])
      p[[.filter, .i(0), .cutoff]] = RangeParam(parm: 44, byte: 63, extra: [ByteCount:2], maxVal: 1023, formatter: cutoffFrmt)
      p[[.filter, .i(1), .cutoff]] = RangeParam(parm: 50, byte: 65, extra: [ByteCount:2], maxVal: 1023, formatter: cutoffFrmt)
      p[[.filter, .i(0), .reson]] = RangeParam(parm: 45, byte: 67, maxVal: 100)
      p[[.filter, .i(1), .reson]] = RangeParam(parm: 51, byte: 68, maxVal: 100)
      p[[.filter, .i(0), .env, .amt]] = RangeParam(parm: 47, byte: 69, range: -100...100)
      p[[.filter, .i(1), .env, .amt]] = RangeParam(parm: 53, byte: 70, range: -100...100)
      p[[.filter, .i(0), .key, .trk]] = RangeParam(parm: 46, byte: 71, extra: [ByteCount:2], range: -100...200)
      p[[.filter, .i(1), .key, .trk]] = RangeParam(parm: 52, byte: 73, extra: [ByteCount:2], range: -100...200)
      p[[.filter,. i(1), .offset, .type]] = OptionsParam(parm: 48, byte: 75, options: ["Absolute", "Offset"])
      let filterTypeOptions = OptionsParam.makeOptions([ "Bypass", "LP Ob 2-pole",  "LP Tb 3-pole",  "LP Mg 4-pole",  "LP Jp 4-pole",  "LP Rp 4-pole",  "LP 8-pole",  "BP Ob 2-pole",  "BP 6-pole",  "BP 8ve Dual",  "BP Bandlimit",  "HP Ob 2-pole",  "HP Op 4-Pole",  "Vocal Fmt 1",  "Vocal Fmt 2",  "Vocal Fmt 3",  "Comb Filter 1",  "Comb Filter 2",  "Comb Filter 3",  "Comb Filter 4",  "Phase Warp" ])
      p[[.filter, .i(0), .type]] = OptionsParam(parm: 43, byte: 76, options: filterTypeOptions)
      p[[.filter, .i(1), .type]] = OptionsParam(parm: 49, byte: 77, options: filterTypeOptions)
      p[[.filter, .i(1), .offset, .freq]] = RangeParam(parm: 158, byte: 78, extra: [ByteCount:2], range: -400...400, formatter: offsetFreqFrmt)
      p[[.filter, .i(0), .level]] = RangeParam(parm: 54, byte: 83, maxVal: 100)
      p[[.filter, .i(1), .level]] = RangeParam(parm: 55, byte: 84, maxVal: 100)
      p[[.pre, .filter, .level]] = RangeParam(parm: 56, byte: 85, maxVal: 100)
      p[[.pre, .filter, .src]] = OptionsParam(parm: 60, byte: 86, options: ["Osc1", "Osc2", "Osc3", "F1 Input", "F2 Input", "Ring", "Noise"])
      p[[.filter, .i(0), .polarity]] = OptionsParam(parm: 61, byte: 87, options: ["+", "-"])
      p[[.filter, .i(0), .pan]] = RangeParam(parm: 57, byte: 88, range: -100...100)
      p[[.filter, .i(1), .pan]] = RangeParam(parm: 58, byte: 89, range: -100...100)
      p[[.pre, .filter, .pan]] = RangeParam(parm: 59, byte: 90, range: -100...100)
      p[[.env, .i(0), .attack]] = RangeParam(parm: 66, byte: 105, maxVal: 255, formatter: attackFrmt)
      p[[.env, .i(1), .attack]] = RangeParam(parm: 79, byte: 106, maxVal: 255, formatter: attackFrmt)
      p[[.env, .i(2), .attack]] = RangeParam(parm: 92, byte: 107, maxVal: 255, formatter: attackFrmt)
      p[[.env, .i(0), .decay]] = RangeParam(parm: 68, byte: 108, maxVal: 255, formatter: attackFrmt)
      p[[.env, .i(1), .decay]] = RangeParam(parm: 81, byte: 109, maxVal: 255, formatter: attackFrmt)
      p[[.env, .i(2), .decay]] = RangeParam(parm: 94, byte: 110, maxVal: 255, formatter: attackFrmt)
      p[[.env, .i(0), .sustain]] = RangeParam(parm: 71, byte: 111, maxVal: 100)
      p[[.env, .i(1), .sustain]] = RangeParam(parm: 84, byte: 112, range: -100...100)
      p[[.env, .i(2), .sustain]] = RangeParam(parm: 97, byte: 113, range: -100...100)
      p[[.env, .i(0), .sustain, .time]] = RangeParam(parm: 70, byte: 114, extra: [ByteCount:2], maxVal: 256, formatter: releaseFrmt)
      p[[.env, .i(1), .sustain, .time]] = RangeParam(parm: 83, byte: 116, extra: [ByteCount:2], maxVal: 256, formatter: releaseFrmt)
      p[[.env, .i(2), .sustain, .time]] = RangeParam(parm: 96, byte: 118, extra: [ByteCount:2], maxVal: 256, formatter: releaseFrmt)
      p[[.env, .i(0), .release]] = RangeParam(parm: 72, byte: 120, extra: [ByteCount:2], maxVal: 256, formatter: releaseFrmt)
      p[[.env, .i(1), .release]] = RangeParam(parm: 85, byte: 122, extra: [ByteCount:2], maxVal: 256, formatter: releaseFrmt)
      p[[.env, .i(2), .release]] = RangeParam(parm: 98, byte: 124, extra: [ByteCount:2], maxVal: 256, formatter: releaseFrmt)
      p[[.env, .i(0), .velo]] = RangeParam(parm: 74, byte: 126, maxVal: 100)
      p[[.env, .i(1), .velo]] = RangeParam(parm: 87, byte: 127, maxVal: 100)
      p[[.env, .i(2), .velo]] = RangeParam(parm: 100, byte: 128, maxVal: 100)
      let loopOptions = OptionsParam.makeOptions(["Decay", "Zero", "Hold", "Off"])
      let envResetOptions = OptionsParam.makeOptions(["Reset", "Legato"])
      p[[.env, .i(0), .loop]] = OptionsParam(parm: 77, byte: 129, bits: 0...1, options: loopOptions)
      p[[.env, .i(0), .pedal]] = RangeParam(parm: 78, byte: 129, bit: 3)
      p[[.env, .i(0), .reset]] = OptionsParam(parm: 75, byte: 129, bit: 4, options: envResetOptions)
      p[[.env, .i(0), .run]] = RangeParam(parm: 76, byte: 129, bit: 6)
      p[[.env, .i(1), .loop]] = OptionsParam(parm: 90, byte: 130, bits: 0...1, options: loopOptions)
      p[[.env, .i(1), .pedal]] = RangeParam(parm: 91, byte: 130, bit: 3)
      p[[.env, .i(1), .reset]] = OptionsParam(parm: 88, byte: 130, bit: 4, options: envResetOptions)
      p[[.env, .i(1), .run]] = RangeParam(parm: 89, byte: 130, bit: 6)
      p[[.env, .i(2), .loop]] = OptionsParam(parm: 103, byte: 131, bits: 0...1, options: loopOptions)
      p[[.env, .i(2), .pedal]] = RangeParam(parm: 104, byte: 131, bit: 3)
      p[[.env, .i(2), .reset]] = OptionsParam(parm: 101, byte: 131, bit: 4, options: envResetOptions)
      p[[.env, .i(2), .run]] = RangeParam(parm: 102, byte: 131, bit: 6)
      let slopeOptions = OptionsParam.makeOptions(["Linear", "Exp +", "Exp -"])
      p[[.env, .i(0), .attack, .slew]] = OptionsParam(parm: 67, byte: 132, bits: 0...1, options: slopeOptions)
      p[[.env, .i(0), .decay, .slew]] = OptionsParam(parm: 69, byte: 132, bits: 4...5, options: slopeOptions)
      p[[.env, .i(0), .release, .slew]] = OptionsParam(parm: 73, byte: 132, bits: 6...7, options: slopeOptions)
      p[[.env, .i(1), .attack, .slew]] = OptionsParam(parm: 80, byte: 133, bits: 0...1, options: slopeOptions)
      p[[.env, .i(1), .decay, .slew]] = OptionsParam(parm: 82, byte: 133, bits: 4...5, options: slopeOptions)
      p[[.env, .i(1), .release, .slew]] = OptionsParam(parm: 86, byte: 133, bits: 6...7, options: slopeOptions)
      p[[.env, .i(2), .attack, .slew]] = OptionsParam(parm: 93, byte: 134, bits: 0...1, options: slopeOptions)
      p[[.env, .i(2), .decay, .slew]] = OptionsParam(parm: 95, byte: 134, bits: 4...5, options: slopeOptions)
      p[[.env, .i(2), .release, .slew]] = OptionsParam(parm: 99, byte: 134, bits: 6...7, options: slopeOptions)
      p[[.lfo, .i(0), .rate]] = RangeParam(parm: 106, byte: 140, extra: [ByteCount:2], maxVal: 1023, formatter: lfoFreqFrmt)
      p[[.lfo, .i(1), .rate]] = RangeParam(parm: 110, byte: 142, extra: [ByteCount:2], maxVal: 1023, formatter: lfoFreqFrmt)
      p[[.lfo, .i(0), .modWheel]] = RangeParam(parm: 108, byte: 144, maxVal: 100)
      p[[.lfo, .i(1), .modWheel]] = RangeParam(parm: 112, byte: 145, maxVal: 100)
      let trkSrcArr = ["Aftertouch", "Env 1", "Env 2", "Env 3", "Exp Pedal", "Keytrk", "KeytrkXT", "LFO1 Saw", "LFO1 Csaw", "LFO1 Sin", "LFO1 Csin", "LFO1 Sqr", "LFO1 Csqr", "LFO1 Tri", "LFO1 CTri", "LFO2 Saw", "LFO2 Csaw", "LFO2 Sin", "LFO2 Csin", "LFO2 Sqr", "LFO2 Csqr", "LFO2 Tri", "LFO2 CTri", "M1 Wheel", "M2 Wheel", "P Wheel", "PortaEfx", "PortaLvl", "Pressure", "RndmGlobl", "RndmVoice", "S/H", "Sus Pedal", "Velocity", "VelociUp", "CC 1", "CC 2", "CC 3", "CC 4", "CC 7", "CC 8", "CC 9", "CC 10", "CC 11", "CC 12", "CC 13", "CC 14", "CC 15", "CC 16", "CC 17", "CC 18", "CC 19", "CC 20", "CC 21", "CC 22", "CC 23", "CC 24", "CC 25", "CC 26", "CC 27", "CC 28", "CC 29", "CC 30", "CC 31", "CC 66", "CC 67", "CC 68", "CC 69", "CC 70", "CC 71", "CC 72", "CC 73", "CC 74", "CC 75", "CC 76", "CC 77", "CC 78", "CC 79", "CC 80", "CC 81", "CC 82", "CC 83", "CC 84", "CC 85", "CC 86", "CC 87", "CC 88", "CC 89", "CC 90", "CC 91", "CC 92", "CC 93", "CC 94", "CC 95", "CC 102", "CC 103", "CC 104", "CC 105", "CC 106", "CC 107", "CC 108", "CC 109", "CC 110", "CC 111", "CC 112", "CC 113", "CC 114", "CC 115", "CC 116", "CC 117", "CC 118", "CC 119", ]
      let trkSrcOptions = OptionsParam.makeOptions(trkSrcArr)
      let shInputOptions = OptionsParam.makeOptions(trkSrcArr[0...30] + ["Sus Pedal", "Track", "Trk Step"] + trkSrcArr[33...111])
      let modSrcOptions = OptionsParam.makeOptions(["Off"] + trkSrcArr[0...32] + ["Track", "Trk Step"] + trkSrcArr[33...111])
      p[[.sample, .src]] = OptionsParam(parm: 116, byte: 146, options: shInputOptions)
      p[[.sample, .rate]] = RangeParam(parm: 114, byte: 147, extra: [ByteCount:2], maxVal: 1023, formatter: lfoFreqFrmt)
      let resetOptions = OptionsParam.makeOptions(["Mono", "Poly", "Key Mono", "Key Poly", "Arp Mono"])
      p[[.sample, .reset]] = OptionsParam(parm: 115, byte: 149, options: resetOptions)
      p[[.lfo, .i(0), .tempo, .sync]] = RangeParam(parm: 105, byte: 150, bit: 0)
      p[[.sample, .smooth]] = RangeParam(parm: 117, byte: 150, bits: 1...7, maxVal: 100)
      p[[.lfo, .i(1), .tempo, .sync]] = RangeParam(parm: 109, byte: 151, bit: 2)
      p[[.sample, .tempo, .sync]] = RangeParam(parm: 113, byte: 151, bit: 4)
      let syncRateOptions = OptionsParam.makeOptions(["1/16", "1/12", "3/32", "1/8", "1/6", "3/16", "1/4", "1/3", "3/8", "1/2", "2/3", "3/4", "1", "1 1/3", "1 1/2", "2", "2 2/3", "3", "4", "5 1/3", "6", "8", "10 2/3", "12", "16"])
      p[[.lfo, .i(0), .sync, .rate]] = OptionsParam(parm: 159, byte: 152, options: syncRateOptions)
      p[[.lfo, .i(1), .sync, .rate]] = OptionsParam(parm: 160, byte: 153, options: syncRateOptions)
      p[[.sample, .sync, .rate]] = OptionsParam(parm: 161, byte: 154, options: syncRateOptions)
      p[[.lfo, .i(0), .reset]] = OptionsParam(parm: 107, byte: 155, bits: 0...2, options: resetOptions)
      p[[.lfo, .i(1), .reset]] = OptionsParam(parm: 111, byte: 155, bits: 4...6, options: resetOptions)
//      p[[.arp, .pattern]] = OptionsParam(parm: 512, byte: 157, bits: 0...4, options: ["*random*", "ant march", "teletype", "acid bass", "spitter", "samba", "chemical", " bodiddle", "hats on", " hats off", "rave stomp", "carnaval", "stutter", "a three and a four", " samba march", "skip to this", "skittering", " pipeline", "fanfare", "swinging", "chikka-chikka", " fee oh fee", "robo-shuffle", "deliberate", "morse code", "hit the 4", " heart beep", "perka", " reveille", "vari-poly", "tango", "hesitant"])
//      p[[.arp, .tempo, .multi]] = OptionsParam(parm: 513, byte: 157, bits: 5...7, options: ["1/4", "1/3", "1/2", "1", "2", "3", "4"])
//      p[[.arp, .length]] = RangeParam(parm: 514, byte: 158, bits: 0...3, maxVal: 14, displayOffset: 2)
//      p[[.arp, .octave, .range]] = RangeParam(parm: 515, byte: 158, bits: 4...6, maxVal: 4)
//      p[[.arp, .octave, .direction]] = OptionsParam(parm: 516, byte: 159, bits: 0...1, options: ["Up", "Down", "Centered"])
//      p[[.arp, .note, .sortOrder]] = OptionsParam(parm: 517, byte: 159, bits: 3...5, options: ["forward", "reverse", "trigger", "r-n-r in", "r-n-r x", "oct jump"])
//      p[[.arp, .mode]] = OptionsParam(parm: 518, byte: 159, bits: 6...7, options: ["On", "Off", "Latch"])
//      p[[.arp, .tempo]] = RangeParam(parm: 519, byte: 160, extra: [ByteCount:2], range: 500...2500)
      let destArray = ["Off", "Pitch", "PtchNar", "FM Amt", "Osc1 Pitch", "Osc1 Nar", "Osc1 Shp", "Osc2 Pitch", "Osc2 Nar", "Osc2 Shp", "Osc3 Pitch", "Osc3 Nar", "Osc3 Shp", "Osc1 Lvl", "Osc2 Lvl", "Osc3 Lvl", "Ring Lvl", "Noise Lvl", "Ext Lvl", "Osc1 Bal", "Osc2 Bal", "Osc3 Bal", "Ring Bal", "Noise Bal", "Ext Bal", "F1F2 Lvl", "Porta Time", "Uni Detune", "F1 Freq", "F1 Res", "F1 Env", "F1 Keytrk", "F2 Freq", "F2 Res", "F2 Env", "F2 Keytrk", "F1 Lvl", "F2 Lvl", "PreF Lvl", "F1 Pan", "F2 Pan", "PreF Pan", "Drive Lvl", "Pgm Lvl", "Pan", "FX Mix", "FX1 A", "FX1 B", "FX1 C", "FX1 D", "Env1 Amp", "Env1 Rat", "Env1 Atk", "Env1 Dcy", "Env1 Sus T", "Env1 Sus L", "Env1 Rel", "Env2 Amp", "Env2 Rat", "Env2 Atk", "Env2 Dcy", "Env2 Sus T", "Env2 Sus L", "Env2 Rel", "Env3 Amp", "Env3 Rat", "Env3 Atk", "Env3 Dcy", "Env3 Sus T", "Env3 Sus L", "Env3 Rel", "LFO1 Rate", "LFO1 Amp", "LFO2 Rate", "LFO2 Amp", "S/H Rate", "S/H Sm", "S/H Amp"]
      let modDestOptions = OptionsParam.makeOptions(destArray)
      let modFrmt: ParamValueFormatter = { String(format:"%.1f", Float($0)/10) }
      (0..<12).forEach { mod in
        let modOff = mod * 4
        // parm: 180 + modOff
        // parm: 181 + modOff
        // Set parm to -1 to trigger full patch send on change
        // if we ever change this back to nrpn, know that values are wrong!
        // they're right for patch parsing, but not nrpn sending
        p[[.mod, .i(mod), .src]] = OptionsParam(parm: -1, byte: 167 + mod, options: modSrcOptions)
        p[[.mod, .i(mod), .dest]] = OptionsParam(parm: -1, byte: 179 + mod, options: modDestOptions)
        p[[.mod, .i(mod), .level]] = RangeParam(parm: 182 + modOff, byte: 191 + mod * 2, extra: [ByteCount:2], range: -1000...1000, formatter: modFrmt)
        p[[.mod, .i(mod), .offset]] = RangeParam(parm: 183 + modOff, byte: 215 + mod * 2, extra: [ByteCount:2], range: -1000...1000, formatter: modFrmt)
      }
      p[[.trk, .src]] = OptionsParam(parm: 118, byte: 239, options: trkSrcOptions)
      p[[.trk, .pt, .number]] = OptionsParam(parm: 120, byte: 240, options: ["12", "16"])
      (-16...16).forEach { pt in
        p[[.trk, .pt, .i(pt)]] = RangeParam(parm: 121 + (pt + 16), byte: 241 + (pt + 16), range: -100...100)
      }
      p[[.trk, .preset]] = OptionsParam(parm: 119, byte: 274, options: ["custom", "bypass", "negate", "abs val", "neg abs", "exp+", "exp-", "zero", "maximum", "minimum"])
      p[[.fx, .i(1), .param, .i(0)]] = RangeParam(parm: 246, byte: 91, extra: [ByteCount:2])
      p[[.fx, .i(1), .param, .i(1)]] = RangeParam(parm: 247, byte: 93, extra: [ByteCount:2])
      p[[.drive, .level]] = RangeParam(parm: 63, byte: 96, maxVal: 100)
      p[[.drive, .type]] = OptionsParam(parm: 62, byte: 97, options: ["bypass", "compressor", "rmslimiter", "tubeoverdrive", "distortion", "tubeamp", "fuzzpedal"])
      p[[.out, .level]] = RangeParam(parm: 64, byte: 98, maxVal: 100)
      let knobParamOptions = OptionsParam.makeOptions(["Polyphony", "Unison", "Unison Detune", "Porta", "PortaType", "Porta Time", "Pitch wheel", "Analog drift", "Osc sync", "FM amount", "FM type", "O1 wave", "O1 shape", "O1 octave", "O1 transpose", "O1 pitch", "O1 PWhlRange", "O2 wave", "O2 shape", "O2 octave", "O2 transpose", "O2 pitch", "O2 PWhlRange", "O3 wave", "O3 shape", "O3 octave", "O3 transpose", "O3 pitch", "O3 PWhlRange", "O1 level", "O2 level", "O3 level", "Ring level", "Noise level", "ExtIn level", "O1 bal", "O2 bal", "O3 bal", "Ring bal", "Noise bal", "ExtIn bal", "Series level", "Noise type", "F1 type", "F1 freq", "F1 res", "F1 keytrk", "F1 env amt", "F2 offset", "F2 type", "F2 freq", "F2 res", "F2 keytrk", "F2 env amt", "F1 level", "F2 level", "Preflt level", "F1 pan", "F2 pan", "Preflt pan", "Preflt src", "F1 sign", "Drive type", "Drive level", "Prog level", "Fx mix", "Env1 Attack", "Env1 A sl", "Env1 Decay", "Env1 D sl", "Env1 S tm", "Env1 Sustain", "Env1 Release", "Env1 R sl", "Env1 Velo", "Env1 reset", "Env1 freerun", "Env1 loop", "Env1 pedal", "Env2 Attack", "Env2 A sl", "Env2 Decay", "Env2 D sl", "Env2 S tm", "Env2 Sustain", "Env2 Release", "Env2 R sl", "Env2 Velo", "Env2 reset", "Env2 freerun", "Env2 loop", "Env2 pedal", "Env3 Attack", "Env3 A sl", "Env3 Decay", "Env3 D sl", "Env3 S tm", "Env3 Sustain", "Env3 Release", "Env3 R sl", "Env3 Velo", "Env3 reset", "Env3 freerun", "Env3 loop", "Env3 pedal", "LFO1 tempo sync", "LFO1 rate", "LFO1 reset", "LFO1 Mod1", "LFO2 tempo sync", "LFO2 rate", "LFO2 reset", "LFO2 Mod1", "S/H tempo sync", "S/H rate", "S/H reset", "S/H input", "S/H smoothing", "Tracking", "Trk preset", "Trk grid", "Trk Pt -16", "Trk Pt -15", "Trk Pt -14", "Trk Pt -13", "Trk Pt -12", "Trk Pt -11", "Trk Pt -10", "Trk Pt -9", "Trk Pt -8", "Trk Pt -7", "Trk Pt -6", "Trk Pt -5", "Trk Pt -4", "Trk Pt -3", "Trk Pt -2", "Trk Pt - 1", "Trk Pt 0", "Trk Pt 1", "Trk Pt 2", "Trk Pt 3", "Trk Pt 4", "Trk Pt 5", "Trk Pt 6", "Trk Pt 7", "Trk Pt 8", "Trk Pt 9", "Trk Pt 10", "Trk Pt 11", "Trk Pt 12", "Trk Pt 13", "Trk Pt 14", "Trk Pt 15", "Trk Pt 16", "Category", "Knob X param", "Knob Y param", "Knob Z param", "F2 freq offset", "LFO1 rate sync", "LFO2 rate sync", "S/H rate sync"])
      p[[.knob, .i(0), .param]] = OptionsParam(parm: 155, byte: 99, options: knobParamOptions)
      p[[.knob, .i(1), .param]] = OptionsParam(parm: 156, byte: 100, options: knobParamOptions)
      p[[.knob, .i(2), .param]] = OptionsParam(parm: 157, byte: 101, options: knobParamOptions)
      p[[.fx, .i(1), .param, .i(2)]] = RangeParam(parm: 248, byte: 135, extra: [ByteCount:2])
      p[[.fx, .i(1), .param, .i(3)]] = RangeParam(parm: 249, byte: 137, extra: [ByteCount:2])
      p[[.fx, .i(1), .param, .i(4)]] = RangeParam(parm: 250, byte: 139, extra: [ByteCount:2])
      p[[.fx, .i(0), .type]] = OptionsParam(parm: 231, byte: 279, options: ["Bypass", "Chorus", "Flanger Theta", "Flanger Thru-0", "Phaser Super", "Phaser String", "Vocoder"])
      p[[.fx, .i(0), .mix]] = RangeParam(parm: 65, byte: 280, bits: 1...7, range: -50...50, formatter: { "\($0+50)" })
      p[[.fx, .i(0), .param, .i(0)]] = RangeParam(parm: 232, byte: 281, range: -100...100)
      p[[.fx, .i(0), .param, .i(1)]] = RangeParam(parm: 233, byte: 282)
      p[[.fx, .i(0), .param, .i(2)]] = RangeParam(parm: 234, byte: 283)
      p[[.fx, .i(0), .param, .i(3)]] = RangeParam(parm: 235, byte: 284)
      p[[.fx, .i(0), .param, .i(4)]] = RangeParam(parm: 236, byte: 285, range: -100...100)
      p[[.fx, .i(0), .param, .i(5)]] = RangeParam(parm: 237, byte: 286)
      p[[.fx, .i(0), .param, .i(6)]] = RangeParam(parm: 238, byte: 287)
      p[[.fx, .i(0), .param, .i(7)]] = RangeParam(parm: 239, byte: 288)
      p[[.fx, .i(1), .balance]] = RangeParam(parm: 230, byte: 289, range: -50...50, formatter: balanceFrmt)
      p[[.fx, .i(1), .type]] = OptionsParam(parm: 245, byte: 290, options: ["bypass", "mono delay", "stereo delay", "split delay", "hall revb", "plate revb", "room revb"])

      // byte 295 has something to do with fx2 working?
      
//      "294: 00100011"
//      "295: 11111111"
      
      return p
    }()

  static let balanceFrmt: ParamValueFormatter = {
    return "\(50-$0)/\(50+$0)"
  }

  static let cutoffFrmt: ParamValueFormatter = {
    guard $0 < 1023 else { return "20kHz" }
    let f = exp(Double($0) / 147.933647) * 20
    return f < 1000 ? String(format: "%.1fHz", f) : String(format: "%.1fkHz", f/1000)
  }

  static let offsetFreqFrmt: ParamValueFormatter = { String(format: "%.2f", Float($0)/100)}

  static let attackFrmt: ParamValueFormatter = {
    let f = exp(Double($0) / 23.177415) / 2
    switch f {
    case -1..<10:
      return String(format: "%.2fms", f)
    case 10..<100:
      return String(format: "%.1fms", f)
    case 100..<1000:
      return String(format: "%.0fms", f)
    default:
      return String(format: "%.1fs", f/1000)
    }
  }

  static let releaseFrmt: ParamValueFormatter = {
    guard $0 != 256 else { return "hold" }
    guard $0 != 255 else { return "30s" }
    
    let f = exp(Double($0) / 25.5188668) / 2
    switch f {
    case -1..<10:
      return String(format: "%.2fms", f)
    case 10..<100:
      return String(format: "%.1fms", f)
    case 100..<1000:
      return String(format: "%.0fms", f)
    default:
      return String(format: "%.1fs", f/1000)
    }
  }

  static let lfoFreqFrmt: ParamValueFormatter = {
    guard $0 != 1023 else { return "1kHz" }
    
    let f = exp(Double($0) / 88.85677) / 100
    switch f {
    case -1..<10:
      return String(format: "%.2fHz", f)
    case 10..<100:
      return String(format: "%.1fHz", f)
    default:
      return String(format: "%.0fHz", f)
    }
  }
}

struct MicronFX {
  
  let name: String
  let params: [Int:(String,Param)]
  
  static let allFX0: [MicronFX] = [
    MicronFX(name: "Bypass", params: [:]),
    MicronFX(name: "Chorus", params: chorusParams),
    MicronFX(name: "Theta Flanger", params: flangerParams),
    MicronFX(name: "Thru Zero Flanger", params: flangerParams),
    MicronFX(name: "Super Phaser", params: superPhaserParams),
    MicronFX(name: "String Phaser", params: stringPhaserParams),
    MicronFX(name: "Vocoder", params: vocoderParams),
//    MicronFX(name: "Slap-back", params: slapbackParams),
  ]
  
  static let superPhaserParams: [Int:(String,Param)] = [
    0 : ("Feedbk", RangeParam(range: -100...100)),
    1 : ("Notch Freq", RangeParam(maxVal: 100)),
    2 : ("LFO Rate", RangeParam(maxVal: 127, formatter: lfoRateFrmt)),
    3 : ("LFO Depth", RangeParam(maxVal: 100)),
    4 : ("LFO Shape", OptionsParam(options: ["Sine","Tri"])),
    5 : ("Stages", OptionsParam(options: ["4","8","16","32","48","64"])),
    6 : ("Tempo Sync", RangeParam(maxVal: 1)),
    7 : ("LFO Rate", OptionsParam(options: syncRateOptions)),
  ]

  static let stringPhaserParams: [Int:(String,Param)] = [
    0 : ("Feedbk", RangeParam(range: 0...100)),
    1 : ("Notch Freq", RangeParam(maxVal: 100)),
    2 : ("LFO Rate", RangeParam(maxVal: 127, formatter: lfoRateFrmt)),
    3 : ("LFO Depth", RangeParam(maxVal: 100)),
    4 : ("LFO Shape", OptionsParam(options: ["Sine","Tri"])),
    5 : ("Tempo Sync", RangeParam(maxVal: 1)),
    7 : ("LFO Rate", OptionsParam(options: syncRateOptions)),
  ]

  static let chorusParams: [Int:(String,Param)] = [
    0 : ("Feedbk", RangeParam(range: 0...100)),
    1 : ("Manual Delay", RangeParam(maxVal: 100)),
    2 : ("LFO Rate", RangeParam(maxVal: 127, formatter: lfoRateFrmt)),
    3 : ("LFO Depth", RangeParam(maxVal: 100)),
    4 : ("LFO Shape", OptionsParam(options: ["Sine","Tri"])),
    5 : ("Tempo Sync", RangeParam(maxVal: 1)),
    7 : ("LFO Rate", OptionsParam(options: syncRateOptions)),
  ]

  static let flangerParams: [Int:(String,Param)] = [
    0 : ("Feedbk", RangeParam(range: -100...100)),
    1 : ("Manual Delay", RangeParam(maxVal: 100)),
    2 : ("LFO Rate", RangeParam(maxVal: 127, formatter: lfoRateFrmt)),
    3 : ("LFO Depth", RangeParam(maxVal: 100)),
    4 : ("LFO Shape", OptionsParam(options: ["Sine","Tri"])),
    5 : ("Tempo Sync", RangeParam(maxVal: 1)),
    7 : ("LFO Rate", OptionsParam(options: syncRateOptions)),
  ]
  
  static let vocoderParams: [Int:(String,Param)] = [
    0 : ("Analysis Sens", RangeParam(range: -100...100)),
    1 : ("Sib Boost", RangeParam(maxVal: 100)),
    2 : ("Decay", RangeParam(maxVal: 100)),
    3 : ("Band Shift", RangeParam(range: -100...100)),
    4 : ("Synth Sig", OptionsParam(options: sigOptions)),
    5 : ("Anal Sig", OptionsParam(options: analSigOptions)),
    6 : ("Anal Mix", RangeParam(maxVal: 100)),
  ]

  static let slapbackParams: [Int:(String,Param)] = [
    0 : ("Delay", RangeParam(range: 1...80)),
    1 : ("Regen", RangeParam(maxVal: 100)),
  ]

  static let syncRateOptions = OptionsParam.makeOptions(["1/16", "1/12", "3/32", "1/8", "1/6", "3/16", "1/4", "1/3", "3/8", "1/2", "2/3", "3/4", "1", "1 1/3", "1 1/2", "2", "2 2/3", "3", "4", "5 1/3", "6", "8", "10 2/3", "12", "16"])
  
  static let sigOptions = OptionsParam.makeOptions(["FX Send", "Aux", "Ext L", "Ext Stereo" ])
  static let analSigOptions = OptionsParam.makeOptions(["FX Send", "Aux", "Ext R", "Ext Stereo" ])

  static let lfoRateFrmt: ParamValueFormatter = {
    let f = exp(Double($0) / 20.570845484869301) / 100
    switch f {
    case -1..<10:
      return String(format: "%.2fHz", f)
    case 10..<100:
      return String(format: "%.1fHz", f)
    default:
      return String(format: "%.0fHz", f)
    }
  }
  
  static let allFX1: [MicronFX] = [
    MicronFX(name: "Bypass", params: [:]),
    MicronFX(name: "Mono Delay", params: monoDelayParams),
    MicronFX(name: "Stereo Delay", params: stereoDelayParams),
    MicronFX(name: "Split Delay", params: splitDelayParams),
    MicronFX(name: "Hall Reverb", params: reverbParams),
    MicronFX(name: "Plate Reverb", params: reverbParams),
    MicronFX(name: "Room Reverb", params: reverbParams),
  ]
  
  static let monoDelayParams: [Int:(String,Param)] = [
    0 : ("Delay (fix)", RangeParam(range: 1...680)),
    1 : ("Regen", RangeParam(maxVal: 100)),
    2 : ("Brightness", RangeParam(maxVal: 100)),
    3 : ("Sync", OptionsParam(options: ["Fixed", "Tempo"])),
    4 : ("Delay (sync)", OptionsParam(options: delaySyncRateOptions)),
  ]

  static let stereoDelayParams: [Int:(String,Param)] = [
    0 : ("Delay (fix)", RangeParam(range: 1...340)),
    1 : ("Regen", RangeParam(maxVal: 100)),
    2 : ("Brightness", RangeParam(maxVal: 100)),
    3 : ("Sync", OptionsParam(options: ["Fixed", "Tempo"])),
    4 : ("Delay (sync)", OptionsParam(options: delaySyncRateOptions)),
  ]
  
  static let splitDelayParams: [Int:(String,Param)] = [
    0 : ("L Delay", RangeParam(range: 1...340)),
    1 : ("Regen", RangeParam(maxVal: 100)),
    2 : ("Brightness", RangeParam(maxVal: 100)),
    3 : ("R Delay", RangeParam(range: 1...340)),
  ]

  static let reverbParams: [Int:(String,Param)] = [
    0 : ("Diffusion", RangeParam(maxVal: 100)),
    1 : ("Decay", RangeParam(maxVal: 100)),
    2 : ("Brightness", RangeParam(maxVal: 100)),
    3 : ("Color", RangeParam(range: 1...100)),
  ]

  static let delaySyncRateOptions: [Int:String] = {
    let arr = ["1", "1 1/3", "1 1/2", "2", "2 2/3", "3", "4", "5 1/3", "6", "8", "10 2/3", "12", "16"]
    var opts = [Int:String]()
    (12..<25).forEach {
      opts[$0] = arr[$0-12]
    }
    return opts
  }()

}

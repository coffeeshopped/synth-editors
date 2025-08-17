
const patchTruss = {
  single: 'voice',
  namePack: [0, 13],
  initFile: "micron-voice-init",
}

class MicronVoicePatch : ByteBackedSysexPatch, BankablePatch {
  
  static func location(forData data: Data) -> Int { return Int(data[8] & 0x7f) }
    
  const fileDataCount = 434
    
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
//          debugPrint(`${$0}: \(other)`)
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
      case "lfo/0/tempo/sync",
           "lfo/1/tempo/sync",
           "sample/tempo/sync",
           "bend":
        // syncs and p bend are flipped...
        return 1 - (unpack(param: param) ?? 0)
      case "unison":
        // 0 is 2 voices, 1 is unison OFF
        let v = (unpack(param: param) ?? 0)
        return v < 2 ? 1 - v : v
      case "osc/sync":
        let v = (bytes[35].bit(0) << 2) +  bytes[34].bits([6, 7])
        return type(of: self).syncMap.firstIndex(of: v)
      case "fm/type":
        let v = (bytes[36].bit(7) << 2) + bytes[35].bits([2, 3])
        return type(of: self).fmMap.firstIndex(of: v)
      case "filter/0/type",
           "filter/1/type":
        let v = (unpack(param: param) ?? 0)
        return type(of: self).filterMap.firstIndex(of: v)
      case "porta":
        let v: Int = (bytes[19].bit(0) << 1) + bytes[16].bit(7)
        return type(of: self).portaMap.firstIndex(of: v)
      case "fx/0/type":
        let v = (unpack(param: param) ?? 0)
        return type(of: self).fx0Map.firstIndex(of: v)
      case "fx/0/param/5":
        if [1,2,3,5].contains(self["fx/0/type"]) {
          // chorus, flangers, string phaser. sync param is inverted
          let v = (unpack(param: param) ?? 0)
          return v == 0 ? 1 : 0
        }
      case "fx/0/param/6":
        if self["fx/0/type"] == 4 {
          // super phaser. sync param is inverted
          let v = (unpack(param: param) ?? 0)
          return v == 0 ? 1 : 0
        }
      case "fx/0/param/7":
        let v = (unpack(param: param) ?? 0)
        return 24 - v
      case "trk/src":
        let v = (unpack(param: param) ?? 0)
        return type(of: self).trkSrcMap.firstIndex(of: v)
      case "sample/src":
        let v = (unpack(param: param) ?? 0)
        return type(of: self).shSrcMap.firstIndex(of: v)
      case "mod/0/src",
           "mod/1/src",
           "mod/2/src",
           "mod/3/src",
           "mod/4/src",
           "mod/5/src",
           "mod/6/src",
           "mod/7/src",
           "mod/8/src",
           "mod/9/src",
           "mod/10/src",
           "mod/11/src":
        let v = (unpack(param: param) ?? 0)
        return type(of: self).modSrcMap.firstIndex(of: v)
      case "mod/0/dest",
           "mod/1/dest",
           "mod/2/dest",
           "mod/3/dest",
           "mod/4/dest",
           "mod/5/dest",
           "mod/6/dest",
           "mod/7/dest",
           "mod/8/dest",
           "mod/9/dest",
           "mod/10/dest",
           "mod/11/dest":
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
      case "lfo/0/tempo/sync",
           "lfo/1/tempo/sync",
           "sample/tempo/sync":
        packValue = newValue == 0 ? 1 : 0
      case "unison":
        packValue = newValue < 2 ? 1 - newValue : newValue
      case "osc/sync":
        packValue = type(of: self).syncMap[newValue]
        bytes[34] = bytes[34].set(bits: [6, 7], value: packValue.bits([0, 1]))
        bytes[35] = bytes[35].set(bit: 0, value: packValue.bit(2))
        return
      case "fm/type":
        packValue = type(of: self).fmMap[newValue]
        bytes[35] = bytes[35].set(bits: [2, 3], value: packValue.bits([0, 1]))
        bytes[36] = bytes[36].set(bit: 7, value: packValue.bit(2))
        return
      case "filter/0/type",
           "filter/1/type":
        packValue = type(of: self).filterMap[newValue]
      case "porta":
        packValue = type(of: self).portaMap[newValue]
        bytes[16] = bytes[16].set(bit: 7, value: packValue.bit(0))
        bytes[19] = bytes[19].set(bit: 0, value: packValue.bit(1))
        return
      case "fx/0/type":
        packValue = type(of: self).fx0Map[newValue]
      case "fx/0/param/5":
        if [1,2,3,5].contains(self["fx/0/type"]) {
          // chorus, flangers, string phaser. sync param is inverted
          packValue = newValue == 0 ? 1 : 0
        }
      case "fx/0/param/6":
        if self["fx/0/type"] == 4 {
          // super phaser. sync param is inverted
          packValue = newValue == 0 ? 1 : 0
        }
      case "fx/0/param/7":
        packValue = 24 - newValue
      case "trk/src":
        packValue = type(of: self).trkSrcMap[newValue]
      case "sample/src":
        packValue = type(of: self).shSrcMap[newValue]
      case "mod/0/src",
           "mod/1/src",
           "mod/2/src",
           "mod/3/src",
           "mod/4/src",
           "mod/5/src",
           "mod/6/src",
           "mod/7/src",
           "mod/8/src",
           "mod/9/src",
           "mod/10/src",
           "mod/11/src":
        packValue = type(of: self).modSrcMap[newValue]
      case "mod/0/dest",
           "mod/1/dest",
           "mod/2/dest",
           "mod/3/dest",
           "mod/4/dest",
           "mod/5/dest",
           "mod/6/dest",
           "mod/7/dest",
           "mod/8/dest",
           "mod/9/dest",
           "mod/10/dest",
           "mod/11/dest":
        packValue = type(of: self).modDestMap[newValue]
      default:
        break
      }
      pack(value: packValue, forParam: param)
    }
  }
  
  const portaMap = [1,2,0]
  const syncMap = [1,4,6,0,2]
  const fmMap = [2,1,0,6,5,4]
  const filterMap = [0, 2, 6, 1, 7, 5, 8, 3, 10, 9, 17, 4, 18, 14, 15, 16, 12, 13, 19, 20, 11]
  const fx0Map = [0, 5, 3, 4, 1, 2, 6]
  const trkSrcMap = [33, 8, 9, 10, 7, 2, 111, 15, 16, 11, 12, 17, 18, 13, 14, 23, 24, 19, 20, 25, 26, 21, 22, 3, 4, 5, 31, 30, 32, 29, 28, 27, 6, 0, 1, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110]
  const shSrcMap = [34, 8, 9, 10, 7, 2, 112, 15, 16, 11, 12, 17, 18, 13, 14, 23, 24, 19, 20, 25, 26, 21, 22, 3, 4, 5, 30, 29, 33, 28, 27, 6, 31, 32, 0, 1, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 111]
  const modSrcMap = [0, 36, 9, 10, 11, 8, 3, 114, 16, 17, 12, 13, 18, 19, 14, 15, 24, 25, 20, 21, 26, 27, 22, 23, 4, 5, 6, 32, 31, 35, 30, 29, 28, 7, 33, 34, 1, 2, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 111, 112, 113]
  const modDestMap = [0, 1, 79, 11, 2, 5, 8, 3, 6, 9, 4, 7, 10, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 42, 43, 44, 45, 46, 47, 48, 49, 51, 74, 75, 76, 77, 78, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 35, 36, 37, 38, 39, 40, 41]
  
  func unpack(param: Param) -> Int? {
    if let _ = param.extra[MicronVoicePatch.ByteCount] {
      // 2-byte param
      let v = 0.set(bits: [8, 15], value: bytes[param.byte])
        .set(bits: [0, 7], value: bytes[param.byte+1])
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
      bytes[param.byte] = UInt8(v.bits([8, 15]))
      bytes[param.byte+1] = UInt8(v.bits([0, 7]))
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
      bytes78 += [UInt8(sum32.bits([24, 31])),
                  UInt8(sum32.bits([16, 23])),
                  UInt8(sum32.bits([8, 15])),
                  UInt8(sum32.bits([0, 7]))]
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
    
    const ByteCount = 0
  
  const balanceFrmt: ParamValueFormatter = {
    return `${50-$0}/\(50+$0)`
  }

  const cutoffFrmt: ParamValueFormatter = {
    guard $0 < 1023 else { return "20kHz" }
    let f = exp(Double($0) / 147.933647) * 20
    return f < 1000 ? String(format: "%.1fHz", f) : String(format: "%.1fkHz", f/1000)
  }

  const offsetFreqFrmt: ParamValueFormatter = { String(format: "%.2f", Float($0)/100)}

  const attackFrmt: ParamValueFormatter = {
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

  const releaseFrmt: ParamValueFormatter = {
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

  const lfoFreqFrmt: ParamValueFormatter = {
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
  
  const allFX0: [MicronFX] = [
    MicronFX(name: "Bypass", params: [:]),
    MicronFX(name: "Chorus", params: chorusParams),
    MicronFX(name: "Theta Flanger", params: flangerParams),
    MicronFX(name: "Thru Zero Flanger", params: flangerParams),
    MicronFX(name: "Super Phaser", params: superPhaserParams),
    MicronFX(name: "String Phaser", params: stringPhaserParams),
    MicronFX(name: "Vocoder", params: vocoderParams),
//    MicronFX(name: "Slap-back", params: slapbackParams),
  ]
  
  const superPhaserParams: [Int:(String,Param)] = [
    0 : ("Feedbk", RangeParam(range: [-100, 100])),
    1 : ("Notch Freq", RangeParam(maxVal: 100)),
    2 : ("LFO Rate", RangeParam(maxVal: 127, formatter: lfoRateFrmt)),
    3 : ("LFO Depth", RangeParam(maxVal: 100)),
    4 : ("LFO Shape", OptionsParam(options: ["Sine","Tri"])),
    5 : ("Stages", OptionsParam(options: ["4","8","16","32","48","64"])),
    6 : ("Tempo Sync", RangeParam(maxVal: 1)),
    7 : ("LFO Rate", OptionsParam(options: syncRateOptions)),
  ]

  const stringPhaserParams: [Int:(String,Param)] = [
    0 : ("Feedbk", RangeParam(range: [0, 100])),
    1 : ("Notch Freq", RangeParam(maxVal: 100)),
    2 : ("LFO Rate", RangeParam(maxVal: 127, formatter: lfoRateFrmt)),
    3 : ("LFO Depth", RangeParam(maxVal: 100)),
    4 : ("LFO Shape", OptionsParam(options: ["Sine","Tri"])),
    5 : ("Tempo Sync", RangeParam(maxVal: 1)),
    7 : ("LFO Rate", OptionsParam(options: syncRateOptions)),
  ]

  const chorusParams: [Int:(String,Param)] = [
    0 : ("Feedbk", RangeParam(range: [0, 100])),
    1 : ("Manual Delay", RangeParam(maxVal: 100)),
    2 : ("LFO Rate", RangeParam(maxVal: 127, formatter: lfoRateFrmt)),
    3 : ("LFO Depth", RangeParam(maxVal: 100)),
    4 : ("LFO Shape", OptionsParam(options: ["Sine","Tri"])),
    5 : ("Tempo Sync", RangeParam(maxVal: 1)),
    7 : ("LFO Rate", OptionsParam(options: syncRateOptions)),
  ]

  const flangerParams: [Int:(String,Param)] = [
    0 : ("Feedbk", RangeParam(range: [-100, 100])),
    1 : ("Manual Delay", RangeParam(maxVal: 100)),
    2 : ("LFO Rate", RangeParam(maxVal: 127, formatter: lfoRateFrmt)),
    3 : ("LFO Depth", RangeParam(maxVal: 100)),
    4 : ("LFO Shape", OptionsParam(options: ["Sine","Tri"])),
    5 : ("Tempo Sync", RangeParam(maxVal: 1)),
    7 : ("LFO Rate", OptionsParam(options: syncRateOptions)),
  ]
  
  const vocoderParams: [Int:(String,Param)] = [
    0 : ("Analysis Sens", RangeParam(range: [-100, 100])),
    1 : ("Sib Boost", RangeParam(maxVal: 100)),
    2 : ("Decay", RangeParam(maxVal: 100)),
    3 : ("Band Shift", RangeParam(range: [-100, 100])),
    4 : ("Synth Sig", OptionsParam(options: sigOptions)),
    5 : ("Anal Sig", OptionsParam(options: analSigOptions)),
    6 : ("Anal Mix", RangeParam(maxVal: 100)),
  ]

  const slapbackParams: [Int:(String,Param)] = [
    0 : ("Delay", RangeParam(range: [1, 80])),
    1 : ("Regen", RangeParam(maxVal: 100)),
  ]

  const syncRateOptions = ["1/16", "1/12", "3/32", "1/8", "1/6", "3/16", "1/4", "1/3", "3/8", "1/2", "2/3", "3/4", "1", "1 1/3", "1 1/2", "2", "2 2/3", "3", "4", "5 1/3", "6", "8", "10 2/3", "12", "16"]
  
  const sigOptions = ["FX Send", "Aux", "Ext L", "Ext Stereo" ]
  const analSigOptions = ["FX Send", "Aux", "Ext R", "Ext Stereo" ]

  const lfoRateFrmt: ParamValueFormatter = {
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
  
  const allFX1: [MicronFX] = [
    MicronFX(name: "Bypass", params: [:]),
    MicronFX(name: "Mono Delay", params: monoDelayParams),
    MicronFX(name: "Stereo Delay", params: stereoDelayParams),
    MicronFX(name: "Split Delay", params: splitDelayParams),
    MicronFX(name: "Hall Reverb", params: reverbParams),
    MicronFX(name: "Plate Reverb", params: reverbParams),
    MicronFX(name: "Room Reverb", params: reverbParams),
  ]
  
  const monoDelayParams: [Int:(String,Param)] = [
    0 : ("Delay (fix)", RangeParam(range: [1, 680])),
    1 : ("Regen", RangeParam(maxVal: 100)),
    2 : ("Brightness", RangeParam(maxVal: 100)),
    3 : ("Sync", OptionsParam(options: ["Fixed", "Tempo"])),
    4 : ("Delay (sync)", OptionsParam(options: delaySyncRateOptions)),
  ]

  const stereoDelayParams: [Int:(String,Param)] = [
    0 : ("Delay (fix)", RangeParam(range: [1, 340])),
    1 : ("Regen", RangeParam(maxVal: 100)),
    2 : ("Brightness", RangeParam(maxVal: 100)),
    3 : ("Sync", OptionsParam(options: ["Fixed", "Tempo"])),
    4 : ("Delay (sync)", OptionsParam(options: delaySyncRateOptions)),
  ]
  
  const splitDelayParams: [Int:(String,Param)] = [
    0 : ("L Delay", RangeParam(range: [1, 340])),
    1 : ("Regen", RangeParam(maxVal: 100)),
    2 : ("Brightness", RangeParam(maxVal: 100)),
    3 : ("R Delay", RangeParam(range: [1, 340])),
  ]

  const reverbParams: [Int:(String,Param)] = [
    0 : ("Diffusion", RangeParam(maxVal: 100)),
    1 : ("Decay", RangeParam(maxVal: 100)),
    2 : ("Brightness", RangeParam(maxVal: 100)),
    3 : ("Color", RangeParam(range: [1, 100])),
  ]

  const delaySyncRateOptions: [Int:String] = {
    let arr = ["1", "1 1/3", "1 1/2", "2", "2 2/3", "3", "4", "5 1/3", "6", "8", "10 2/3", "12", "16"]
    var opts = [Int:String]()
    (12..<25).forEach {
      opts[$0] = arr[$0-12]
    }
    return opts
  }()

}

let oscWaveOptions = ["Sin", "Tri/Saw", "Pulse"]

let filterTypeOptions = [ "Bypass", "LP Ob 2-pole",  "LP Tb 3-pole",  "LP Mg 4-pole",  "LP Jp 4-pole",  "LP Rp 4-pole",  "LP 8-pole",  "BP Ob 2-pole",  "BP 6-pole",  "BP 8ve Dual",  "BP Bandlimit",  "HP Ob 2-pole",  "HP Op 4-Pole",  "Vocal Fmt 1",  "Vocal Fmt 2",  "Vocal Fmt 3",  "Comb Filter 1",  "Comb Filter 2",  "Comb Filter 3",  "Comb Filter 4",  "Phase Warp" ]

let loopOptions = ["Decay", "Zero", "Hold", "Off"]
let envResetOptions = ["Reset", "Legato"]

let trkSrcArr = ["Aftertouch", "Env 1", "Env 2", "Env 3", "Exp Pedal", "Keytrk", "KeytrkXT", "LFO1 Saw", "LFO1 Csaw", "LFO1 Sin", "LFO1 Csin", "LFO1 Sqr", "LFO1 Csqr", "LFO1 Tri", "LFO1 CTri", "LFO2 Saw", "LFO2 Csaw", "LFO2 Sin", "LFO2 Csin", "LFO2 Sqr", "LFO2 Csqr", "LFO2 Tri", "LFO2 CTri", "M1 Wheel", "M2 Wheel", "P Wheel", "PortaEfx", "PortaLvl", "Pressure", "RndmGlobl", "RndmVoice", "S/H", "Sus Pedal", "Velocity", "VelociUp", "CC 1", "CC 2", "CC 3", "CC 4", "CC 7", "CC 8", "CC 9", "CC 10", "CC 11", "CC 12", "CC 13", "CC 14", "CC 15", "CC 16", "CC 17", "CC 18", "CC 19", "CC 20", "CC 21", "CC 22", "CC 23", "CC 24", "CC 25", "CC 26", "CC 27", "CC 28", "CC 29", "CC 30", "CC 31", "CC 66", "CC 67", "CC 68", "CC 69", "CC 70", "CC 71", "CC 72", "CC 73", "CC 74", "CC 75", "CC 76", "CC 77", "CC 78", "CC 79", "CC 80", "CC 81", "CC 82", "CC 83", "CC 84", "CC 85", "CC 86", "CC 87", "CC 88", "CC 89", "CC 90", "CC 91", "CC 92", "CC 93", "CC 94", "CC 95", "CC 102", "CC 103", "CC 104", "CC 105", "CC 106", "CC 107", "CC 108", "CC 109", "CC 110", "CC 111", "CC 112", "CC 113", "CC 114", "CC 115", "CC 116", "CC 117", "CC 118", "CC 119", ]
let trkSrcOptions = trkSrcArr
let shInputOptions = trkSrcArr[[0, 30]] + ["Sus Pedal", "Track", "Trk Step"] + trkSrcArr[[33, 111]]
let modSrcOptions = ["Off"] + trkSrcArr[[0, 32]] + ["Track", "Trk Step"] + trkSrcArr[[33, 111]]

let resetOptions = ["Mono", "Poly", "Key Mono", "Key Poly", "Arp Mono"]
let syncRateOptions = ["1/16", "1/12", "3/32", "1/8", "1/6", "3/16", "1/4", "1/3", "3/8", "1/2", "2/3", "3/4", "1", "1 1/3", "1 1/2", "2", "2 2/3", "3", "4", "5 1/3", "6", "8", "10 2/3", "12", "16"]

let destArray = ["Off", "Pitch", "PtchNar", "FM Amt", "Osc1 Pitch", "Osc1 Nar", "Osc1 Shp", "Osc2 Pitch", "Osc2 Nar", "Osc2 Shp", "Osc3 Pitch", "Osc3 Nar", "Osc3 Shp", "Osc1 Lvl", "Osc2 Lvl", "Osc3 Lvl", "Ring Lvl", "Noise Lvl", "Ext Lvl", "Osc1 Bal", "Osc2 Bal", "Osc3 Bal", "Ring Bal", "Noise Bal", "Ext Bal", "F1F2 Lvl", "Porta Time", "Uni Detune", "F1 Freq", "F1 Res", "F1 Env", "F1 Keytrk", "F2 Freq", "F2 Res", "F2 Env", "F2 Keytrk", "F1 Lvl", "F2 Lvl", "PreF Lvl", "F1 Pan", "F2 Pan", "PreF Pan", "Drive Lvl", "Pgm Lvl", "Pan", "FX Mix", "FX1 A", "FX1 B", "FX1 C", "FX1 D", "Env1 Amp", "Env1 Rat", "Env1 Atk", "Env1 Dcy", "Env1 Sus T", "Env1 Sus L", "Env1 Rel", "Env2 Amp", "Env2 Rat", "Env2 Atk", "Env2 Dcy", "Env2 Sus T", "Env2 Sus L", "Env2 Rel", "Env3 Amp", "Env3 Rat", "Env3 Atk", "Env3 Dcy", "Env3 Sus T", "Env3 Sus L", "Env3 Rel", "LFO1 Rate", "LFO1 Amp", "LFO2 Rate", "LFO2 Amp", "S/H Rate", "S/H Sm", "S/H Amp"]
let modDestOptions = destArray
let modFrmt: ParamValueFormatter = { String(format:"%.1f", Float($0)/10) }

let slopeOptions = ["Linear", "Exp +", "Exp -"]

let knobParamOptions = ["Polyphony", "Unison", "Unison Detune", "Porta", "PortaType", "Porta Time", "Pitch wheel", "Analog drift", "Osc sync", "FM amount", "FM type", "O1 wave", "O1 shape", "O1 octave", "O1 transpose", "O1 pitch", "O1 PWhlRange", "O2 wave", "O2 shape", "O2 octave", "O2 transpose", "O2 pitch", "O2 PWhlRange", "O3 wave", "O3 shape", "O3 octave", "O3 transpose", "O3 pitch", "O3 PWhlRange", "O1 level", "O2 level", "O3 level", "Ring level", "Noise level", "ExtIn level", "O1 bal", "O2 bal", "O3 bal", "Ring bal", "Noise bal", "ExtIn bal", "Series level", "Noise type", "F1 type", "F1 freq", "F1 res", "F1 keytrk", "F1 env amt", "F2 offset", "F2 type", "F2 freq", "F2 res", "F2 keytrk", "F2 env amt", "F1 level", "F2 level", "Preflt level", "F1 pan", "F2 pan", "Preflt pan", "Preflt src", "F1 sign", "Drive type", "Drive level", "Prog level", "Fx mix", "Env1 Attack", "Env1 A sl", "Env1 Decay", "Env1 D sl", "Env1 S tm", "Env1 Sustain", "Env1 Release", "Env1 R sl", "Env1 Velo", "Env1 reset", "Env1 freerun", "Env1 loop", "Env1 pedal", "Env2 Attack", "Env2 A sl", "Env2 Decay", "Env2 D sl", "Env2 S tm", "Env2 Sustain", "Env2 Release", "Env2 R sl", "Env2 Velo", "Env2 reset", "Env2 freerun", "Env2 loop", "Env2 pedal", "Env3 Attack", "Env3 A sl", "Env3 Decay", "Env3 D sl", "Env3 S tm", "Env3 Sustain", "Env3 Release", "Env3 R sl", "Env3 Velo", "Env3 reset", "Env3 freerun", "Env3 loop", "Env3 pedal", "LFO1 tempo sync", "LFO1 rate", "LFO1 reset", "LFO1 Mod1", "LFO2 tempo sync", "LFO2 rate", "LFO2 reset", "LFO2 Mod1", "S/H tempo sync", "S/H rate", "S/H reset", "S/H input", "S/H smoothing", "Tracking", "Trk preset", "Trk grid", "Trk Pt -16", "Trk Pt -15", "Trk Pt -14", "Trk Pt -13", "Trk Pt -12", "Trk Pt -11", "Trk Pt -10", "Trk Pt -9", "Trk Pt -8", "Trk Pt -7", "Trk Pt -6", "Trk Pt -5", "Trk Pt -4", "Trk Pt -3", "Trk Pt -2", "Trk Pt - 1", "Trk Pt 0", "Trk Pt 1", "Trk Pt 2", "Trk Pt 3", "Trk Pt 4", "Trk Pt 5", "Trk Pt 6", "Trk Pt 7", "Trk Pt 8", "Trk Pt 9", "Trk Pt 10", "Trk Pt 11", "Trk Pt 12", "Trk Pt 13", "Trk Pt 14", "Trk Pt 15", "Trk Pt 16", "Category", "Knob X param", "Knob Y param", "Knob Z param", "F2 freq offset", "LFO1 rate sync", "LFO2 rate sync", "S/H rate sync"]

const parms = [
  ["poly", { p: 0, b: 15, bit: 0 }],
  ["unison", { p: 1, b: 15, bits: [1, 3], opts: [
    0 : "Off",
    1 : "2 voices",
    2 : "4 voices",
    4 : "8 voices",
  ]],
  ["porta/type", { p: 4, b: 15, bits: [6, 7], opts: ["Fixed", "Scaled", "Gliss Fixed", "Gliss Scaled"] }],
  ["unison/detune", { p: 2, b: 16, bits: [0, 6], max: 100 }],
  ["porta", { p: 3, b: 19, opts: ["Off", "Legato", "Always"] }],
  ["porta/time", { p: 5, b: 17, formatter: {
    guard $0 < 127 else { return "10000" }
    return String(format:"%.0f" , exp(Double($0) / 18.38514) * 10)
  } }],
  ["bend", { p: 6, b: 18, opts: ["Held", "Playing"] }],
  ["analogFeel", { p: 7, b: 20, max: 100 }],
  ["category", { p: 154, b: 23, opts: ["Recent", "Faves", "Bass", "Lead", "Pad", "String", "Brass", "Key", "Comp", "Drum", "SFX"] }],
  ["osc/0/fine", { p: 15, b: 24, ext: { ByteCount:2 }, rng: [-999, 999] }],
  ["osc/1/fine", { p: 21, b: 26, ext: { ByteCount:2 }, rng: [-999, 999] }],
  ["osc/2/fine", { p: 27, b: 28, ext: { ByteCount:2 }, rng: [-999, 999] }],
  ["osc/0/shape", { p: 12, b: 30, rng: [-100, 100] }],
  ["osc/1/shape", { p: 18, b: 31, rng: [-100, 100] }],
  ["osc/2/shape", { p: 24, b: 32, rng: [-100, 100] }],
  ["osc/0/octave", { p: 13, b: 33, bits: [0, 2], max: 6, dispOff: -3 }],
  ["osc/0/semitone", { p: 14, b: 33, bits: [4, 7], max: 14, dispOff: -7 }],
  ["osc/0/wave", { p: 11, b: 34, bits: [0, 1], opts: oscWaveOptions }],
  ["osc/0/bend", { p: 16, b: 34, bits: [2, 5], max: 12 }],
  ["osc/sync", { p: 8, b: 34, opts: ["Off", "Hard 2>1", "Hard 2+3>1", "Soft 2>1", "Soft 2+3>1"] }],
  ["osc/1/wave", { p: 17, b: 35, bits: [4, 5], opts: oscWaveOptions }],
  ["osc/2/wave", { p: 23, b: 35, bits: [6, 7], opts: oscWaveOptions }],
  ["fm/type", { p: 10, b: 36, opts:["Lin 2>1", "Lin 2+3>1", "Lin 3>2>1", "Exp 2> 1", "Exp 2+3>1", "Exp 3>2>1", ] }],
  ["osc/1/octave", { p: 19, b: 37, bits: [0, 2], max: 6, dispOff: -3 }],
  ["osc/1/semitone", { p: 20, b: 37, bits: [4, 7], max: 14, dispOff: -7 }],
  ["osc/2/octave", { p: 25, b: 38, bits: [0, 2], max: 6, dispOff: -3 }],
  ["osc/2/semitone", { p: 26, b: 38, bits: [4, 7], max: 14, dispOff: -7 }],
  ["osc/1/bend", { p: 22, b: 39, bits: [0, 3], max: 12 }],
  ["osc/2/bend", { p: 28, b: 39, bits: [4, 7], max: 12 }],
  ["fm/amt", { p: 9, b: 40, ext: { ByteCount:2 }, max: 1000 }],
  ["osc/0/level", { p: 29, b: 45, max: 100 }],
  ["osc/1/level", { p: 30, b: 46, max: 100 }],
  ["osc/2/level", { p: 31, b: 47, max: 100 }],
  ["ringMod/level", { p: 32, b: 48, max: 100 }],
  ["ext/level", { p: 34, b: 49, max: 100 }],
  ["osc/0/balance", { p: 35, b: 50, rng: [-50, 50], formatter: balanceFrmt }],
  ["osc/1/balance", { p: 36, b: 51, rng: [-50, 50], formatter: balanceFrmt }],
  ["osc/2/balance", { p: 37, b: 52, rng: [-50, 50], formatter: balanceFrmt }],
  ["ringMod/balance", { p: 38, b: 53, rng: [-50, 50], formatter: balanceFrmt }],
  ["ext/balance", { p: 40, b: 54, rng: [-100, 100] }],
  ["noise/balance", { p: 39, b: 55, rng: [-50, 50], formatter: balanceFrmt }],
  ["filter/balance", { p: 41, b: 56, max: 100 }],
  ["noise/level", { p: 33, b: 57, bits: [0, 6], max: 100 }],
  ["noise/type", { p: 42, b: 57, bit: 7, opts: ["Pink", "White"] }],
  ["filter/0/cutoff", { p: 44, b: 63, ext: { ByteCount:2 }, max: 1023, formatter: cutoffFrmt }],
  ["filter/1/cutoff", { p: 50, b: 65, ext: { ByteCount:2 }, max: 1023, formatter: cutoffFrmt }],
  ["filter/0/reson", { p: 45, b: 67, max: 100 }],
  ["filter/1/reson", { p: 51, b: 68, max: 100 }],
  ["filter/0/env/amt", { p: 47, b: 69, rng: [-100, 100] }],
  ["filter/1/env/amt", { p: 53, b: 70, rng: [-100, 100] }],
  ["filter/0/key/trk", { p: 46, b: 71, ext: { ByteCount:2 }, rng: [-100, 200] }],
  ["filter/1/key/trk", { p: 52, b: 73, ext: { ByteCount:2 }, rng: [-100, 200] }],
  ["filter/ i(1)/offset/type", { p: 48, b: 75, opts: ["Absolute", "Offset"] }],
  ["filter/0/type", { p: 43, b: 76, opts: filterTypeOptions }],
  ["filter/1/type", { p: 49, b: 77, opts: filterTypeOptions }],
  ["filter/1/offset/freq", { p: 158, b: 78, ext: { ByteCount:2 }, rng: [-400, 400], formatter: offsetFreqFrmt }],
  ["filter/0/level", { p: 54, b: 83, max: 100 }],
  ["filter/1/level", { p: 55, b: 84, max: 100 }],
  ["pre/filter/level", { p: 56, b: 85, max: 100 }],
  ["pre/filter/src", { p: 60, b: 86, opts: ["Osc1", "Osc2", "Osc3", "F1 Input", "F2 Input", "Ring", "Noise"] }],
  ["filter/0/polarity", { p: 61, b: 87, opts: ["+", "-"] }],
  ["filter/0/pan", { p: 57, b: 88, rng: [-100, 100] }],
  ["filter/1/pan", { p: 58, b: 89, rng: [-100, 100] }],
  ["pre/filter/pan", { p: 59, b: 90, rng: [-100, 100] }],
  ["env/0/attack", { p: 66, b: 105, max: 255, formatter: attackFrmt }],
  ["env/1/attack", { p: 79, b: 106, max: 255, formatter: attackFrmt }],
  ["env/2/attack", { p: 92, b: 107, max: 255, formatter: attackFrmt }],
  ["env/0/decay", { p: 68, b: 108, max: 255, formatter: attackFrmt }],
  ["env/1/decay", { p: 81, b: 109, max: 255, formatter: attackFrmt }],
  ["env/2/decay", { p: 94, b: 110, max: 255, formatter: attackFrmt }],
  ["env/0/sustain", { p: 71, b: 111, max: 100 }],
  ["env/1/sustain", { p: 84, b: 112, rng: [-100, 100] }],
  ["env/2/sustain", { p: 97, b: 113, rng: [-100, 100] }],
  ["env/0/sustain/time", { p: 70, b: 114, ext: { ByteCount:2 }, max: 256, formatter: releaseFrmt }],
  ["env/1/sustain/time", { p: 83, b: 116, ext: { ByteCount:2 }, max: 256, formatter: releaseFrmt }],
  ["env/2/sustain/time", { p: 96, b: 118, ext: { ByteCount:2 }, max: 256, formatter: releaseFrmt }],
  ["env/0/release", { p: 72, b: 120, ext: { ByteCount:2 }, max: 256, formatter: releaseFrmt }],
  ["env/1/release", { p: 85, b: 122, ext: { ByteCount:2 }, max: 256, formatter: releaseFrmt }],
  ["env/2/release", { p: 98, b: 124, ext: { ByteCount:2 }, max: 256, formatter: releaseFrmt }],
  ["env/0/velo", { p: 74, b: 126, max: 100 }],
  ["env/1/velo", { p: 87, b: 127, max: 100 }],
  ["env/2/velo", { p: 100, b: 128, max: 100 }],
  ["env/0/loop", { p: 77, b: 129, bits: [0, 1], opts: loopOptions }],
  ["env/0/pedal", { p: 78, b: 129, bit: 3 }],
  ["env/0/reset", { p: 75, b: 129, bit: 4, opts: envResetOptions }],
  ["env/0/run", { p: 76, b: 129, bit: 6 }],
  ["env/1/loop", { p: 90, b: 130, bits: [0, 1], opts: loopOptions }],
  ["env/1/pedal", { p: 91, b: 130, bit: 3 }],
  ["env/1/reset", { p: 88, b: 130, bit: 4, opts: envResetOptions }],
  ["env/1/run", { p: 89, b: 130, bit: 6 }],
  ["env/2/loop", { p: 103, b: 131, bits: [0, 1], opts: loopOptions }],
  ["env/2/pedal", { p: 104, b: 131, bit: 3 }],
  ["env/2/reset", { p: 101, b: 131, bit: 4, opts: envResetOptions }],
  ["env/2/run", { p: 102, b: 131, bit: 6 }],
  ["env/0/attack/slew", { p: 67, b: 132, bits: [0, 1], opts: slopeOptions }],
  ["env/0/decay/slew", { p: 69, b: 132, bits: [4, 5], opts: slopeOptions }],
  ["env/0/release/slew", { p: 73, b: 132, bits: [6, 7], opts: slopeOptions }],
  ["env/1/attack/slew", { p: 80, b: 133, bits: [0, 1], opts: slopeOptions }],
  ["env/1/decay/slew", { p: 82, b: 133, bits: [4, 5], opts: slopeOptions }],
  ["env/1/release/slew", { p: 86, b: 133, bits: [6, 7], opts: slopeOptions }],
  ["env/2/attack/slew", { p: 93, b: 134, bits: [0, 1], opts: slopeOptions }],
  ["env/2/decay/slew", { p: 95, b: 134, bits: [4, 5], opts: slopeOptions }],
  ["env/2/release/slew", { p: 99, b: 134, bits: [6, 7], opts: slopeOptions }],
  ["lfo/0/rate", { p: 106, b: 140, ext: { ByteCount:2 }, max: 1023, formatter: lfoFreqFrmt }],
  ["lfo/1/rate", { p: 110, b: 142, ext: { ByteCount:2 }, max: 1023, formatter: lfoFreqFrmt }],
  ["lfo/0/modWheel", { p: 108, b: 144, max: 100 }],
  ["lfo/1/modWheel", { p: 112, b: 145, max: 100 }],
  ["sample/src", { p: 116, b: 146, opts: shInputOptions }],
  ["sample/rate", { p: 114, b: 147, ext: { ByteCount:2 }, max: 1023, formatter: lfoFreqFrmt }],
  ["sample/reset", { p: 115, b: 149, opts: resetOptions }],
  ["lfo/0/tempo/sync", { p: 105, b: 150, bit: 0 }],
  ["sample/smooth", { p: 117, b: 150, bits: [1, 7], max: 100 }],
  ["lfo/1/tempo/sync", { p: 109, b: 151, bit: 2 }],
  ["sample/tempo/sync", { p: 113, b: 151, bit: 4 }],
  ["lfo/0/sync/rate", { p: 159, b: 152, opts: syncRateOptions }],
  ["lfo/1/sync/rate", { p: 160, b: 153, opts: syncRateOptions }],
  ["sample/sync/rate", { p: 161, b: 154, opts: syncRateOptions }],
  ["lfo/0/reset", { p: 107, b: 155, bits: [0, 2], opts: resetOptions }],
  ["lfo/1/reset", { p: 111, b: 155, bits: [4, 6], opts: resetOptions }],
  //      ["arp/pattern", { p: 512, b: 157, bits: [0, 4], opts: ["*random*", "ant march", "teletype", "acid bass", "spitter", "samba", "chemical", " bodiddle", "hats on", " hats off", "rave stomp", "carnaval", "stutter", "a three and a four", " samba march", "skip to this", "skittering", " pipeline", "fanfare", "swinging", "chikka-chikka", " fee oh fee", "robo-shuffle", "deliberate", "morse code", "hit the 4", " heart beep", "perka", " reveille", "vari-poly", "tango", "hesitant"] }],
  //      ["arp/tempo/multi", { p: 513, b: 157, bits: [5, 7], opts: ["1/4", "1/3", "1/2", "1", "2", "3", "4"] }],
  //      ["arp/length", { p: 514, b: 158, bits: [0, 3], max: 14, dispOff: 2 }],
  //      ["arp/octave/range", { p: 515, b: 158, bits: [4, 6], max: 4 }],
  //      ["arp/octave/direction", { p: 516, b: 159, bits: [0, 1], opts: ["Up", "Down", "Centered"] }],
  //      ["arp/note/sortOrder", { p: 517, b: 159, bits: [3, 5], opts: ["forward", "reverse", "trigger", "r-n-r in", "r-n-r x", "oct jump"] }],
  //      ["arp/mode", { p: 518, b: 159, bits: [6, 7], opts: ["On", "Off", "Latch"] }],
  //      ["arp/tempo", { p: 519, b: 160, ext: { ByteCount:2 }, rng: [500, 2500] }],
        (0..<12).forEach { mod in
          let modOff = mod * 4
          // parm: 180 + modOff
          // parm: 181 + modOff
          // Set parm to -1 to trigger full patch send on change
          // if we ever change this back to nrpn, know that values are wrong!
          // they're right for patch parsing, but not nrpn sending
          ["mod/mod/src", { p: -1, b: 167 + mod, opts: modSrcOptions }],
          ["mod/mod/dest", { p: -1, b: 179 + mod, opts: modDestOptions }],
          ["mod/mod/level", { p: 182 + modOff, b: 191 + mod * 2, ext: { ByteCount:2 }, rng: [-1000, 1000], formatter: modFrmt }],
          ["mod/mod/offset", { p: 183 + modOff, b: 215 + mod * 2, ext: { ByteCount:2 }, rng: [-1000, 1000], formatter: modFrmt }],
        }
  ["trk/src", { p: 118, b: 239, opts: trkSrcOptions }],
  ["trk/pt/number", { p: 120, b: 240, opts: ["12", "16"] }],
  ([-16, 16]).forEach { pt in
    ["trk/pt/pt", { p: 121 + (pt + 16), b: 241 + (pt + 16), rng: [-100, 100] }],
  }
  ["trk/preset", { p: 119, b: 274, opts: ["custom", "bypass", "negate", "abs val", "neg abs", "exp+", "exp-", "zero", "maximum", "minimum"] }],
  ["fx/1/param/0", { p: 246, b: 91, ext: { ByteCount:2 } }],
  ["fx/1/param/1", { p: 247, b: 93, ext: { ByteCount:2 } }],
  ["drive/level", { p: 63, b: 96, max: 100 }],
  ["drive/type", { p: 62, b: 97, opts: ["bypass", "compressor", "rmslimiter", "tubeoverdrive", "distortion", "tubeamp", "fuzzpedal"] }],
  ["out/level", { p: 64, b: 98, max: 100 }],
  ["knob/0/param", { p: 155, b: 99, opts: knobParamOptions }],
  ["knob/1/param", { p: 156, b: 100, opts: knobParamOptions }],
  ["knob/2/param", { p: 157, b: 101, opts: knobParamOptions }],
  ["fx/1/param/2", { p: 248, b: 135, ext: { ByteCount:2 } }],
  ["fx/1/param/3", { p: 249, b: 137, ext: { ByteCount:2 } }],
  ["fx/1/param/4", { p: 250, b: 139, ext: { ByteCount:2 } }],
  ["fx/0/type", { p: 231, b: 279, opts: ["Bypass", "Chorus", "Flanger Theta", "Flanger Thru-0", "Phaser Super", "Phaser String", "Vocoder"] }],
  ["fx/0/mix", { p: 65, b: 280, bits: [1, 7], rng: [-50, 50], formatter: { `${$0+50}` } }],
  ["fx/0/param/0", { p: 232, b: 281, rng: [-100, 100] }],
  ["fx/0/param/1", { p: 233, b: 282 }],
  ["fx/0/param/2", { p: 234, b: 283 }],
  ["fx/0/param/3", { p: 235, b: 284 }],
  ["fx/0/param/4", { p: 236, b: 285, rng: [-100, 100] }],
  ["fx/0/param/5", { p: 237, b: 286 }],
  ["fx/0/param/6", { p: 238, b: 287 }],
  ["fx/0/param/7", { p: 239, b: 288 }],
  ["fx/1/balance", { p: 230, b: 289, rng: [-50, 50], formatter: balanceFrmt }],
  ["fx/1/type", { p: 245, b: 290, opts: ["bypass", "mono delay", "stereo delay", "split delay", "hall revb", "plate revb", "room revb"] }],
        // byte 295 has something to do with fx2 working?
  //      "294: 00100011"
  //      "295: 11111111"
]




const bankTruss = {
  singleBank: patchTruss,
  patchCount: 128,
  initFile: "micron-voice-bank-init",
}

class MicronVoiceBank : TypicalTypedSysexPatchBank<MicronVoicePatch> {
    
  // Micron returns all fetched data with same location indexes
  // So just go off the order of the messages
  required public init(data: Data) {
    let sysex = SysexData(data: data)
    var p: [Patch] = sysex.compactMap {
      guard Patch.isValid(sysex: $0) else { return nil }
      return Patch(data: $0)
    }
    let patchesLeft = type(of: self).patchCount - p.count
    // Add in any missing patches
    p.append(contentsOf: (0..<patchesLeft).map { _ in Patch() })
    super.init(patches: p)
  }
    
  override func fileData() -> Data {
    return sysexData { (patch, location) -> Data in
      patch.sysexData(bank: 0, location: UInt8(location))
    }
  }

}

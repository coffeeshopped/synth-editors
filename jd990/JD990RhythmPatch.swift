
class JD990RhythmPatch : JD990MultiPatch, BankablePatch, RhythmPatch {
  
  class var bankType: SysexPatchBank.Type { return JD990RhythmBank.self }
  
  static func location(forData data: Data) -> Int { return 0 }
  
  static func startAddress(_ path: SynthPath?) -> RolandAddress {
    if (path?.count ?? 0) > 1 {
      return 0x07000000
    }
    else {
      return 0x04000000
    }
  }

  class var initFileName: String { return "jd990-rhythm-init" }
  
  var addressables: [SynthPath:RolandSingleAddressable]
  
  required init(data: Data) {
    addressables = type(of: self).addressables(forData: data)
  }
  
  private static let _addressableTypes: [SynthPath:RolandSingleAddressable.Type] = {
    var types: [SynthPath:RolandSingleAddressable.Type] =  [
      [.common]      : JD990RhythmCommonPatch.self,
      ]
    (0..<61).forEach {
      types[[.tone, .i($0)]] = JD990RhythmTonePatch.self
    }
    return types
  }()
  class var addressableTypes: [SynthPath:RolandSingleAddressable.Type] {
    return _addressableTypes
  }
  
  static let subpatchAddresses: [SynthPath:RolandAddress] = {
    var adds: [SynthPath:RolandAddress] = [
      [.common]      : 0x0000,
      ]
    (0..<61).forEach {
      adds[[.tone, .i($0)]] = RolandAddress(0x003a) + ($0 * RolandAddress(0x006a))
    }
    return adds
  }()
  
  static func addressables(forData data: Data) -> [SynthPath:RolandSingleAddressable] {
    if data.count == 6821 {
      return addressables(forCompactData: data)
    }
    else {
      return defaultAddressables(forData: data)
    }
  }

  // Synth saves this as common + 1 msg per tone
  // note this is not what a typical "compact" patch would be, hence we define below
  func sysexData(deviceId: Int, address: RolandAddress) -> [Data] {
    // save common as one sysex msg
    var data = [Data]()
    if let common = addressables[[.common]] {
      data.append(contentsOf: common.sysexData(deviceId: deviceId, address: address))
    }

    // then parts as 1 more sysex msg, compacted
    (0..<61).forEach {
      let path: SynthPath = [.tone, .i($0)]
      guard let a = type(of: self).subpatchAddresses[path],
        let tone = addressables[path] else { return }
      data.append(contentsOf: tone.sysexData(deviceId: deviceId, address: a + address))
    }

    return data
  }
  
  static func isValid(fileSize: Int) -> Bool {
    // 6821 is compacted form (267-byte msgs)
    return [7206, fileDataCount, 6821].contains(fileSize)
  }

  
}

class JD990RhythmCommonPatch : JD990Patch {
  
  static let initFileName = ""
  static let nameByteRange = 0..<0x10
  class var size: RolandAddress { return 0x3a }
  
  static func startAddress(_ path: SynthPath?) -> RolandAddress {
    return 0x0000
  }
  
  var bytes: [UInt8]
  
  required init(data: Data) {
    bytes = type(of: self).contentBytes(forData: data)
  }
  
  func randomize() {
    randomizeAllParams()
//    self[.level] = 127
//    self[[.out, .assign]] = 13
  }

  private static let _params: SynthPathParam = {
    var p = SynthPathParam()
    
    p[[.level]] = RangeParam(byte: 0x10, maxVal: 100, displayOffset: -50)
    p[[.pan]] = RangeParam(byte: 0x11, maxVal: 100, displayOffset: -50)
    p[[.analogFeel]] = RangeParam(byte: 0x12, maxVal: 100)
    p[[.bend, .down]] = RangeParam(byte: 0x13, maxVal: 48)
    p[[.bend, .up]] = RangeParam(byte: 0x14, maxVal: 12)
    p[[.ctrl, .src, .i(0)]] = OptionsParam(byte: 0x15, options: JD990CommonPatch.ctrlSrcOptions)
    p[[.ctrl, .src, .i(1)]] = OptionsParam(byte: 0x16, options: JD990CommonPatch.ctrlSrcOptions)
    p[[.lo, .freq]] = OptionsParam(byte: 0x17, options: JD800CommonPatch.loFreqOptions)
    p[[.lo, .gain]] = RangeParam(byte: 0x18, maxVal: 30, displayOffset: -15)
    p[[.mid, .freq]] = OptionsParam(byte: 0x19, options: JD800CommonPatch.midFreqOptions)
    p[[.mid, .q]] = OptionsParam(byte: 0x1a, options: JD800CommonPatch.midQOptions)
    p[[.mid, .gain]] = RangeParam(byte: 0x1b, maxVal: 30, displayOffset: -15)
    p[[.hi, .freq]] = OptionsParam(byte: 0x1c, options: JD800CommonPatch.hiFreqOptions)
    p[[.hi, .gain]] = RangeParam(byte: 0x1d, maxVal: 30, displayOffset: -15)

    p[[.fx, .ctrl, .src, .i(0)]] = OptionsParam(byte: 0x1e, options: JD990CommonPatch.ctrlSrcOptions)
    p[[.fx, .ctrl, .dest, .i(0)]] = OptionsParam(byte: 0x1f, options: JD990CommonPatch.ctrlDestOptions)
    p[[.fx, .ctrl, .depth, .i(0)]] = RangeParam(byte: 0x20, maxVal: 100, displayOffset: -50)
    p[[.fx, .ctrl, .src, .i(1)]] = OptionsParam(byte: 0x21, options: JD990CommonPatch.ctrlSrcOptions)
    p[[.fx, .ctrl, .dest, .i(1)]] = OptionsParam(byte: 0x22, options: JD990CommonPatch.ctrlDestOptions)
    p[[.fx, .ctrl, .depth, .i(1)]] = RangeParam(byte: 0x23, maxVal: 100, displayOffset: -50)

    p[[.chorus, .rate]] = MisoParam.make(byte: 0x24, maxVal: 99, iso: JD990CommonPatch.chorusRateMiso)
    p[[.chorus, .depth]] = RangeParam(byte: 0x25, maxVal: 100)
    p[[.chorus, .delay]] = MisoParam.make(byte: 0x26, maxVal: 99, iso: JD990CommonPatch.chorusDelayIso)
    p[[.chorus, .feedback]] = MisoParam.make(byte: 0x27, maxVal: 98, iso: JD990CommonPatch.feedBackIso)
    p[[.chorus, .level]] = RangeParam(byte: 0x28, maxVal: 100)
    
    p[[.delay, .mode]] = OptionsParam(byte: 0x29, options: JD990CommonPatch.delayModeOptions)
    p[[.delay, .mid, .time]] = MisoParam.make(parm: 2, byte: 0x2a, maxVal: 255, iso: JD990CommonPatch.delayTimeIso)
    p[[.delay, .mid, .level]] = RangeParam(byte: 0x2c, maxVal: 100)
    p[[.delay, .left, .time]] = MisoParam.make(parm: 2, byte: 0x2d, maxVal: 255, iso: JD990CommonPatch.delayTimeIso)
    p[[.delay, .left, .level]] = RangeParam(byte: 0x2f, maxVal: 100)
    p[[.delay, .right, .time]] = MisoParam.make(parm: 2, byte: 0x30, maxVal: 255, iso: JD990CommonPatch.delayTimeIso)
    p[[.delay, .right, .level]] = RangeParam(byte: 0x32, maxVal: 100)
    p[[.delay, .feedback]] = MisoParam.make(byte: 0x33, maxVal: 98, iso:  JD990CommonPatch.feedBackIso)
    
    p[[.reverb, .type]] = OptionsParam(byte: 0x34, options: JD800FXPatch.reverbTypeOptions)
    p[[.reverb, .pre]] = RangeParam(byte: 0x35, maxVal: 120)
    p[[.reverb, .early]] = RangeParam(byte: 0x36, maxVal: 100)
    p[[.reverb, .hi, .cutoff]] = OptionsParam(byte: 0x37, options: JD800FXPatch.reverbHiCutoffOptions)
    p[[.reverb, .time]] = MisoParam.make(byte: 0x38, iso: JD990CommonPatch.reverbTimeIso)
    p[[.reverb, .level]] = RangeParam(byte: 0x39, maxVal: 100)

    return p
  }()
  
  class var params: SynthPathParam { return _params }
}



class JD990RhythmTonePatch : JD990Patch {
  
  static func startAddress(_ path: SynthPath?) -> RolandAddress {
    let index = path?.endex ?? 0
    return RolandAddress(0x3a) + (RolandAddress(0x6a) * index)
  }
  
    static let initFileName = ""
    static let nameByteRange = 0..<0x0a
    class var size: RolandAddress { return 0x6a }
    
    var bytes: [UInt8]
    
    required init(data: Data) {
      bytes = type(of: self).contentBytes(forData: data)
    }
    
    func randomize() {
      randomizeAllParams()
  //    self[.level] = 127
  //    self[[.out, .assign]] = 13
    }

    private static let _params: SynthPathParam = {
      var p = SynthPathParam()
      
      p[[.env, .mode]] = OptionsParam(byte: 0x0a, options: ["Sustain", "No Sus"])
      p[[.mute, .group]] = RangeParam(byte: 0x0b, maxVal: 26, formatter: {
        return $0 == 0 ? "Off" : String(UnicodeScalar(UInt8(64 + $0)))
      })
      p[[.fx, .mode]] = OptionsParam(byte: 0x0c, options: ["EQ:Mix", "EQ+R:Mix", "EQ+C+R:Mix", "EQ+D+R:Mix", "Dir 1", "Dir 2", "Dir 3"])
      p[[.fx, .level]] = RangeParam(byte: 0x0d, maxVal: 100)

      // pull in normal tone params and add 0x0e to every byte value.
      JD990TonePatch.params.forEach {
        let parm: Param
        let offset = 0x0e
        if let oldParm = $0.value as? RangeParam {
          parm = RangeParam(parm: oldParm.parm, byte: oldParm.byte + offset, bits: oldParm.bits, extra: oldParm.extra, range: oldParm.range, displayOffset: oldParm.displayOffset, formatter: oldParm.formatter)
        }
        else if let oldParm = $0.value as? OptionsParam {
          parm = OptionsParam(parm: oldParm.parm, byte: oldParm.byte + offset, bits: oldParm.bits, extra: oldParm.extra, options: oldParm.options)
        }
        else {
          debugPrint("Deal with this JD990TonePatch Param! \($0.value)")
          return
        }
        p[$0.key] = parm
      }
      
      
      return p
    }()

  class var params: SynthPathParam { return _params }
}

class JD990RhythmKeyTonePatch : JD990TonePatch {
  
  override class func startAddress(_ path: SynthPath?) -> RolandAddress {
    return 0x000e
  }

}

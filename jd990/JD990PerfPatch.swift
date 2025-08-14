
class JD990PerfPatch : JD990MultiPatch, PerfPatch, BankablePatch {
  
class var bankType: SysexPatchBank.Type { return JD990PerfBank.self }

  static func location(forData data: Data) -> Int {
    return Int(addressBytes(forSysex: data)[1])
  }
  
  static func startAddress(_ path: SynthPath?) -> RolandAddress {
    return 0x01000000
  }
  
  class var initFileName: String { return "jd990-perf-init" }
  
  var addressables: [SynthPath:RolandSingleAddressable]
  
  required init(data: Data) {
    addressables = type(of: self).addressables(forData: data)
  }
  
  private static let _addressableTypes: [SynthPath:RolandSingleAddressable.Type] = {
    var types: [SynthPath:RolandSingleAddressable.Type] =  [
      [.common]             : JD990PerfCommonPatch.self,
      ]
    (0..<8).forEach {
      types[[.part, .i($0)]] = JD990PerfPartPatch.self
    }
    return types
  }()
  class var addressableTypes: [SynthPath:RolandSingleAddressable.Type] {
    return _addressableTypes
  }
  
  private static let _subpatchAddresses: [SynthPath:RolandAddress] = {
    var adds: [SynthPath:RolandAddress] = [
      [.common]      : 0x0000,
      ]
    (0..<8).forEach {
      adds[[.part, .i($0)]] = RolandAddress(0x30) + ($0 * RolandAddress(0xc))
    }
    return adds
  }()
  class var subpatchAddresses: [SynthPath:RolandAddress] {
    return _subpatchAddresses
  }

  // Synth saves this as common message + part msgs compacted!
  func sysexData(deviceId: Int, address: RolandAddress) -> [Data] {
    // save common as one sysex msg
    var data = [Data]()
    if let common = addressables[[.common]] {
      data.append(contentsOf: common.sysexData(deviceId: deviceId, address: address))
    }

    // then parts as 1 more sysex msg, compacted
    let partData: [[Data]] = (0..<8).compactMap {
      let path: SynthPath = [.part, .i($0)]
      guard let a = type(of: self).subpatchAddresses[path] else { return nil }
      return addressables[path]?.sysexData(deviceId: deviceId, address: a)
    }
    let rData = RolandData(sysexData: [Data](partData.joined()), addressableType: type(of: self))
    data.append(contentsOf: rData.sysexMsgs(deviceId: deviceId, offsetAddress: address))

    return data
  }
  
  static func isValid(fileSize: Int) -> Bool {
    return fileSize == 166 || fileSize == fileDataCount
  }
}

class JD990PerfCommonPatch : JD990Patch {
  
  static let initFileName = ""
  static let nameByteRange = 0..<0x10
  class var size: RolandAddress { return 0x30 }
  
  static func startAddress(_ path: SynthPath?) -> RolandAddress {
    return 0x0000
  }
  
  var bytes: [UInt8]
  
  required init(data: Data) {
    bytes = type(of: self).contentBytes(forData: data)
  }
  
  private static let _params: SynthPathParam = {
    var p = SynthPathParam()
    
    p[[.sync, .part]] = OptionsParam(byte: 0x10, options: OptionsParam.makeOptions((0...7).map {
      return $0 == 0 ? "None" : "Part \($0)"
    }))
    (0..<8).forEach {
      p[[.voice, .reserve, .i($0)]] = RangeParam(byte: 0x11 + $0, maxVal: 24)
    }
    p[[.chorus, .rate]] = MisoParam.make(byte: 0x19, maxVal: 99, iso: JD990CommonPatch.chorusRateMiso)
    p[[.chorus, .depth]] = RangeParam(byte: 0x1a, maxVal: 100)
    p[[.chorus, .delay]] = MisoParam.make(byte: 0x1b, maxVal: 99, iso: JD990CommonPatch.chorusDelayIso)
    p[[.chorus, .feedback]] = MisoParam.make(byte: 0x1c, maxVal: 98, iso: JD990CommonPatch.feedBackIso)
    p[[.chorus, .level]] = RangeParam(byte: 0x1d, maxVal: 100)
    p[[.delay, .mode]] = OptionsParam(byte: 0x1e, options: JD990CommonPatch.delayModeOptions)
    p[[.delay, .mid, .time]] = MisoParam.make(parm: 2, byte: 0x1f, maxVal: 255, iso: JD990CommonPatch.delayTimeIso)
    p[[.delay, .mid, .level]] = RangeParam(byte: 0x21, maxVal: 100)
    p[[.delay, .left, .time]] = MisoParam.make(parm: 2, byte: 0x22, maxVal: 255, iso: JD990CommonPatch.delayTimeIso)
    p[[.delay, .left, .level]] = RangeParam(byte: 0x24, maxVal: 100)
    p[[.delay, .right, .time]] = MisoParam.make(parm: 2, byte: 0x25, maxVal: 255, iso: JD990CommonPatch.delayTimeIso)
    p[[.delay, .right, .level]] = RangeParam(byte: 0x27, maxVal: 100)
    p[[.delay, .feedback]] = MisoParam.make(byte: 0x28, maxVal: 98, iso:  JD990CommonPatch.feedBackIso)
    p[[.reverb, .type]] = OptionsParam(byte: 0x29, options: JD800FXPatch.reverbTypeOptions)
    p[[.reverb, .pre]] = RangeParam(byte: 0x2a, maxVal: 120)
    p[[.reverb, .early]] = RangeParam(byte: 0x2b, maxVal: 100)
    p[[.reverb, .hi, .cutoff]] = OptionsParam(byte: 0x2c, options: JD800FXPatch.reverbHiCutoffOptions)
    p[[.reverb, .time]] = MisoParam.make(byte: 0x2d, iso: JD990CommonPatch.reverbTimeIso)
    p[[.reverb, .level]] = RangeParam(byte: 0x2e, maxVal: 100)
    return p
  }()
  
  class var params: SynthPathParam { return _params }
  
}

class JD990PerfPartPatch : JD990Patch {
  
  static let initFileName = ""
  class var size: RolandAddress { return 0x0c }
  
  static func startAddress(_ path: SynthPath?) -> RolandAddress {
    return RolandAddress(0x30) + ((path?.endex ?? 0) * RolandAddress(0x0c))
  }
  
  var bytes: [UInt8]
  
  required init(data: Data) {
    bytes = type(of: self).contentBytes(forData: data)
  }
  
  
  private static let _params: SynthPathParam = {
    var p = SynthPathParam()
    
    p[[.on]] = RangeParam(byte: 0x00, maxVal: 1)
    p[[.channel]] = RangeParam(byte: 0x01, maxVal: 15, displayOffset: 1)
    p[[.bank]] = OptionsParam(byte: 0x02, options: ["Int/Card", "Preset A/B"])
    p[[.pgm, .number]] = RangeParam(byte: 0x03, displayOffset: 1)
    p[[.level]] = RangeParam(byte: 0x04, maxVal: 100)
    p[[.pan]] = RangeParam(byte: 0x05, maxVal: 100, displayOffset: -50)
    p[[.coarse]] = RangeParam(byte: 0x06, maxVal: 96, displayOffset: -48)
    p[[.fine]] = RangeParam(byte: 0x07, maxVal: 100, displayOffset: -50)
    p[[.out, .assign]] = OptionsParam(byte: 0x08, options: ["Mix", "Dir-1", "Dir-2", "Dir-3"])
    p[[.fx, .mode]] = OptionsParam(byte: 0x09, options: ["Dry", "Rev", "C+R", "D+R"])
    p[[.fx, .level]] = RangeParam(byte: 0x0a, maxVal: 100)

    return p
  }()
  
  class var params: SynthPathParam { return _params }
  
  static let presetsA: [String] = ["Killer Pad", "Pulse Pad", "Lovely Vox Pad", "Tempest", "Deep Breath Pad", "Pure Glass", "Cherish", "GlassVoices", "Ac.Piano 2", "Ac.Piano Hybrid", "Crystal Rhodes 2", "E.Piano 1", "E.Piano 2", "Agogo Rhodes", "Seq E.Piano", "Whispery Piano", "Pipe Organ", "Choir Organ", "CLS 222 (Mod) 1", "Ring Organ", "CLS 222 (Mod) 2", "Jazz Organ", "Dist.Organ", "French New Organ", "Authentic Harp", "Harmo Harpo", "Authentic Clav", "Digital Clav", "Nylon Guitar", "String Guitar", "Electric Guitar", "Velo Harmonics", "12 String Guitar", "Clang Guitar", "Stratomaster PJ", "That's Funky", "ChinaGuitar", "Reso Strat", "Big Country", "Velo-Crunch", "Fretless Bass", "Woody Bass", "Velo-Switch Bass", "Slap Bass", "Pick Bass", "Fingered Bass", "Flubber Bass", "House Bass", "Rubber Bass", "Stick Bass", "Wiry Sync Bass", "A Funk Bass 1", "A Funk Bass 2", "Techno Bass", "Structure Bass", "Mega Mono Bass", "Warm Vibe", "Marimba", "Night Kalimba", "Perc Stab", "Harlequin 990", "Cow Vibes", "Ethnic", "AfricaMetals"].enumerated().map {
    return "A\(($0.offset / 8) + 1)\(($0.offset % 8) + 1): \($0.element)"
  }
  
  static let presetsB: [String] = ["JD-T.Chimes", "Wave Bells", "Tria Bells", "Lite Delay", "Like Dee", "Reincarnate", "Fantasy Bell", "Ring Chimes", "Brass Section", "Brass Mix", "French Horn", "Bad Wolf Horn", "Wagner Chorale", "Analog Brass 2", "Brass Vel.Fall", "Sax Tpt Tbn", "Trumpet Solo", "Harmon Mute", "Trombone Solo", "Alto Sax", "Tenor Sax", "Intimate Flute", "Mellowtron Flute", "Panhandler", "Fusion Solo", "Tap Sequence", "Wavy Flutone", "KoreanTongPoo", "Lyric Flute Solo", "BendSaxVoice", "Saw Lead", "Bubbly Lead", "990 Strings", "Pizzicato", "Soaring Strings", "Silky Strings", "Carry on it", "B-V's Oooze", "Dreaming Time", "Waveola Vox Rize", "Tangerine", "Twinkling String", "Strat'O'Dreams", "Euro E.Piano", "Betazoid Harp", "Glory", "Orgatoron", "Oasis", "WinterVox", "From Far East", "Macho Swell", "R-Mod Brass Pad", "The Pad", "Story Pad", "Hybrid Poly Syn", "JX Sweepee", "Let's Dance !!", "GreatExpectation", "Letting Go", "Aqueous Strings", "CyberneticEmpire", "Kalahari", "Passing Asteroid", "Pink Bomb"].enumerated().map {
    return "B\(($0.offset / 8) + 1)\(($0.offset % 8) + 1): \($0.element)"
  }
  
  static let presetOptions: [Int:String] = OptionsParam.makeOptions(presetsA + presetsB)
  
  static let presetRhythmOptions: [Int:String] = OptionsParam.makeOptions([
    "A: Drum Set A",
    "B: Drum Set B",
  ])
}



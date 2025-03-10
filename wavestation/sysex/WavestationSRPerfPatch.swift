
class WavestationSRPerfPatch : WavestationPatch, BankablePatch, PerfPatch {

  static let bankType: SysexPatchBank.Type = WavestationSRPerfBank.self
  static func location(forData data: Data) -> Int { return 0 }
    
  static let initFileName = "wavestationsr-perf-init"
  static let fileDataCount = 371
  static let nameByteRange = 0..<16

  var bytes: [UInt8]
  
  required init(data: Data) {
    // 181 bytes
    bytes = stride(from: 7, to: 369, by: 2).map { data[$0] + (data[$0 + 1] << 4) }
    guard bytes.map({ Int($0) }).reduce(0, +) > 0 else { return }
    var str = ""
    bytes[16..<37].enumerated().forEach {
      str += "\($0.offset): ".appending(String(format: "%02hhx", $0.element)).appending("      ")
    }
    debugPrint(str)
  }

  init(bodyData: Data) {
    bytes = stride(from: 0, to: 362, by: 2).map { bodyData[$0] + (bodyData[$0 + 1] << 4) }
  }

  // 0, 1 : RAM 1, 2
  // 2 : ROM 11
  // 3 : --- prob card?
  // 4 : RAM 3
  // 5, 6, 7, 8, 9, 10, 11 : ROM 4, 5, 6, 7, 8, 9, 10
  
  // map displayed bank to fetch msg
  static let patchBankMap = [0,1,4,5,6,7,8,9,10,11,2]

  subscript(path: SynthPath) -> Int? {
    get {
      guard let param = type(of: self).params[path] else { return nil }
      
      switch path.last {
      case .bank:
        guard let part = path.i(1),
          let lilBank = unpack(param: param),
          let bankExtra = self[[.part, .i(part), .bank, .extra]] else { return nil }
        let bigBank = lilBank + (bankExtra << 2)
        return type(of: self).patchBankMap.firstIndex(of: bigBank) ?? 0
        
      default:
        break
      }
      return unpack(param: param)
    }
    set {
      guard let param = type(of: self).params[path],
        let newValue = newValue else { return }
      var packValue = newValue
      switch path.last {
      case .bank:
        guard let part = path.i(1) else { return }
        // find the right internal value
        let mapBank = type(of: self).patchBankMap[packValue]
        packValue = mapBank & 0x3
        self[[.part, .i(part), .bank, .extra]] = (mapBank >> 2) & 0x3

      default:
        break
      }
      pack(value: packValue, forParam: param)
    }
  }

  func sysexData(channel: Int, bank: Int, location: Int) -> Data {
    var data = Data(sysexHeader(channel: channel) + [0x49, UInt8(bank), UInt8(location)])
    let bodyData = sysexBodyData()
    data.append(bodyData)
    data.append(checksum(bodyData))
    data.append(0xf7)
    return data
  }
        
  func fileData() -> Data {
    return sysexData(channel: 0, bank: 0, location: 0)
  }

    // TODO
    func randomize() {
      randomizeAllParams()
  //    self[[.structure]] = (0...10).random()!
    }


  static let ByteCount = 0

  static let params: SynthPathParam = {
    var p = SynthPathParam()

    // FX??? 21 Bytes. 16..<37
    
    // fx 1 type: bytes 0, 5, 7, 8, 9, 10, 11, 12
    // none 82, small hall, 83, med hall 84
    let fxOff = 16
    // fx routing
    p[[.fx, .routing]] = RangeParam(byte: 0 + fxOff, bit: 7)
//    // fx1 type
//    // fx2 type
    p[[.fx, .i(0), .type]] = RangeParam(byte: 0 + fxOff, bits: 0...5)
    p[[.fx, .i(1), .type]] = RangeParam(byte: 1 + fxOff, bits: 0...5)
//    // fx1 params
//    // fx2 params
//    // mix3, mix4,
    p[[.fx, .mix, .i(2)]] = RangeParam(byte: 2 + fxOff, bits: 0...3)
    p[[.fx, .mix, .i(3)]] = RangeParam(byte: 2 + fxOff, bits: 4...7)
//    // mod3 src, amt
    p[[.fx, .mod, .i(2), .src]] = RangeParam(byte: 3 + fxOff, bits: 0...3)
    p[[.fx, .mod, .i(2), .amt]] = RangeParam(byte: 4 + fxOff, bits: 0...3) // byte 0, bit: 6 is the sign bit
//    // mod4 src, amt
    p[[.fx, .mod, .i(3), .src]] = RangeParam(byte: 3 + fxOff, bits: 4...7)
    p[[.fx, .mod, .i(3), .amt]] = RangeParam(byte: 4 + fxOff, bits: 4...7) // byte 1, bit: 6 is the sign bit

    
    (0..<8).forEach { part in
      let off = (part * 18) + 37
      
      p[[.part, .i(part), .bank]] = RangeParam(parm: 57, byte: 0 + off, maxVal: 10, displayOffset: 1)
      p[[.part, .i(part), .patch]] = RangeParam(parm: 58, byte: 1 + off)
      p[[.part, .i(part), .level]] = RangeParam(parm: 61, byte: 2 + off, maxVal: 99)
      p[[.part, .i(part), .out]] = RangeParam(parm: 62, byte: 3 + off)
      p[[.part, .i(part), .bank, .extra]] = RangeParam(parm: 0, byte: 4 + off, bits: 6...7)
      p[[.part, .i(part), .local]] = OptionsParam(parm: 75, byte: 4 + off, options: [
        1 : "Local",
        2 : "MIDI",
        3 : "Both",
      ])
      p[[.part, .i(part), .key, .assign]] = OptionsParam(parm: 71, byte: 4 + off, bits: 0...1, options: ["Low Note", "Hi Note", "Last Note"])
      p[[.part, .i(part), .poly]] = OptionsParam(parm: 71, byte: 4 + off, bits: 2...3, options: [
        1 : "Poly",
        2 : "Uni Retrig",
        3 : "Uni Legato",
      ])
      p[[.part, .i(part), .key, .lo]] = RangeParam(parm: 63, byte: 5 + off)
      p[[.part, .i(part), .key, .hi]] = RangeParam(parm: 64, byte: 6 + off)
      p[[.part, .i(part), .velo, .lo]] = RangeParam(parm: 65, byte: 7 + off, range: 1...127)
      p[[.part, .i(part), .velo, .hi]] = RangeParam(parm: 66, byte: 8 + off, range: 1...127)
      p[[.part, .i(part), .transpose]] = RangeParam(parm: 67, byte: 9 + off, range: -24...24)
      p[[.part, .i(part), .detune]] = RangeParam(parm: 68, byte: 10 + off, range: -99...99)
      p[[.part, .i(part), .micro]] = OptionsParam(parm: 72, byte: 11 + off, options: microScaleOptions)
      p[[.part, .i(part), .micro, .key]] = OptionsParam(parm: 73, byte: 12 + off, options: microKeyOptions)
      p[[.part, .i(part), .midi, .channel]] = RangeParam(parm: 74, byte: 13 + off)
      p[[.part, .i(part), .midi, .pgm]] = RangeParam(parm: 76, byte: 14 + off)
      p[[.part, .i(part), .sustain]] = RangeParam(parm: 69, byte: 15 + off)
      p[[.part, .i(part), .delay]] = RangeParam(parm: 70, byte: 16 + off, extra: [ByteCount:2], range: 0...9999)
    }

    return p
  }()
  
  static let fxTypeOptions = OptionsParam.makeOptions(["None", "Small Hall", "Medium Hall", "Large Hall", "Small Room", "Large Room", "Live Stage", "Wet Plate", "Dry Plate", "Spring Reverb", "Early Reflec 1", "Early Reflec 2", "Early Reflec 3", "Gated Reverb", "Reverse Gate", "Stereo Delay", "Ping Pong Delay", "Dual Mono Delay", "Multi-Tap 1", "Multi-Tap 2", "Multi-Tap 3", "Stereo Chorus", "Quad Chorus", "Xover Chorus", "Harmonic Chorus", "Flanger 1", "Flanger 2", "Xover Flanger", "Enhance/Excite", "Distortion", "Overdrive", "Phaser 1", "Phaser 2", "Rotary Speaker", "Stereo Mod Pan", "Quad Mod Pan", "Parametric EQ", "Chorus>Delay", "Flange>Delay", "Delay/Hall", "Delay/Room", "Delay/Chorus", "Delay/Flange", "Delay/Distort", "Delay/Overdrive", "Delay/Phaser", "Delay/Rotary", "Pitch Shift", "Mod Pitch Shift", "Compressor-Limiter/Gate", "Small Vocoder 1", "Small Vocoder 2", "Small Vocoder 3", "Small Vocoder 4", "Stereo Vocoder 1", "Stereo Vocoder 2"])
  
  static let microScaleOptions = OptionsParam.makeOptions(["Eq Temp 1", "Eq Temp 2", "Pure Maj", "Pure Min", "User 1", "User 2", "User 3", "User 4", "User 5", "User 6", "User 7", "User 8", "User 9", "User 10", "User 11", "User 12"])

  static let microKeyOptions = OptionsParam.makeOptions(["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"])

  static let patchOptions: [[Int:String]] = [
    OptionsParam.makeNumberedOptions(["Piano Low", "Piano Hi", "DigiPiano", "CelloEnsmble", "String Pad", "Fretless", "Slap Bass", "Dyno Bass", "SynBass 3", "Deep Mini Bass", "Marimba", "Kalimba", "Harp", "Nylon Guitar", "Pan Flute", "Wood Flute", "A.Sax 2", "French Horn", "SynBrass2", "Accordion", "VoiceSynthPad2", "MagicWind", "Wave Bell", "AttackBell", "VS155s", "PsychoWave", "VS126", "PWMs", "BugsAtSea", "Acoustic Guitar", "Amazon", "WavePolice", "DanceNow", "Snare&16th", "Bad Dance"]),
    OptionsParam.makeNumberedOptions(["Analog Bass", "RudeBass", "FingerBass", "WaveBass", "Jazz Bass", "Jazz Guitar", "D.P.E. Piano", "OB-Res", "DigitalPerc", "The Classics", "SawStringsWHEEL", "LA Bell", "P-saws", "Sine Pad", "AeroSynth", "AngelBell", "BellPiano", "Elec. Guit2", "Organ 3", "Slapper", "Pulsey", "Analog Pad", "Mini 2", "Vibes", "WaterPhone", "Filter Vox", "Harmonic", "Super Sync", "Jupiter Dream", "Voicey", "HouseBass", "Busy Bass", "Tenor Sax", "TromboneTrumpet", "Chug"]),
    OptionsParam.makeNumberedOptions(["FunkHouse", "Stdy 4/4", "Funk", "Rhythm 1", "Mizik", "Visitor", "Scriti", "HoUsE", "PercMiniBass", "Stick", "MIDI Grand", "DynoWhirly", "Cross Bee", "KorgyClavi", "BritePipes", "E.Piano2", "MagicSynth", "WS Punch", "Brasser", "Analogness", "Analog Seq. 2", "TrasHybrid", "E.Guitar", "Ethnic Bell", "M Heaven", "VS Ago", "Swirling", "Harp Wind", "Highlands", "Four Singers", "JetString", "SynFlute", "2 Flutes", "Mr.Perky", "MultiMarimba"]),
    OptionsParam.makeNumberedOptions(["Organic", "AngelBell2", "Air Choir", "BriteAnaBrass", "Log Bass", "VocalPad", "WS Harp", "WS SpaceBell", "Tubular2", "WS EPiano", "Dreaming", "Solar Rings", "Synbass#1", "Vox Strings", "Wind Magic", "Twang Bass", "Roadz", "Punch Bass", "Digi Bass", "L.A.Piano", "PWM", "East Side", "Cheesy Farfeesy", "PwmPad", "Pole Wind", "JB Harpsi", "PCM Synth", "Inharmonic", "String KD", "BigPad", "AirHarp", "Spike", "Bender Mini", "Alien", "Ta Vox"]),
    OptionsParam.makeNumberedOptions(["VelCello", "Synth Pizzi", "DelaySwellStrng", "Mid Bells", "VoxKeys", "Glass EPiano", "Metal Tines", "VS ElPiano", "SynKeys 1", "Vibes ala Pr VS", "Glass Pad", "Funky Metally", "Hollow Marimba", "Breath Pad", "Breathaton Pad", "Syn Soprano", "Organ Donor", "Holy Organs", "Ourghan", "Snazzo Organ", "Bach's Organ", "Organ Frills", "Pulsanaloggin'", "Velocity Flute", "Perko Pan Flute", "AnaPlukPad", "Digizip Twists", "God Chime", "Mini1Bass", "Saw Key 'n Bass", "Bassnap", "MC-WS Rap", "Scratch 2", "Rap Fill", "Midi Echo"]),
    OptionsParam.makeNumberedOptions(["Tines 2", "Slow String Pad", "Plux Nirvana", "TimeWorm", "FairVoice", "Suspense Pad", "Dream's Essence", "Tubular", "Chromes", "OrganPercussion", "Ancient Light", "Orchestra Swat", "E.P.1", "Inharma Star", "Res Sweep Pad", "Sicilian", "Heaven's Gate", "Arianne", "Res2Sweep", "Drum Seq 1", "Angelica", "Bell Chorus", "Ice Cubes", "Elka Rhapsody", "Inspires", "SyncBass", "Syn Brass For U", "Poly Filler", "VS Wave 3", "New Steel Git.1", "Rippin", "GuiPad", "Destructo", "Vector Hell....", "Descending"]),
    OptionsParam.makeNumberedOptions(["Galaxis", "Space Sailing", "Wheel Vox", "Surf", "7/8 Seq", "Nick’s Pad", "Slow Glass", "One", "Clarinet", "Forest", "Whistle", "Accordeon", "Horn Knee", "Rappa 1", "Drum Kit", "Kit1 DWN", "Ride Cymbal", "WS Crash", "RapHatOpn", "RapHat", "RapSnare", "RapBDsus", "Kit1 +", "Kit1 UP", "RapCowbell", "RapKick", "KinGuit", "Tambo 1", "E.Bass Pt 1", "Percus 1", "Afro Pt", "Samba(Rio)", "PhaseDrums", "The Dream", "Orbits"]),
    OptionsParam.makeNumberedOptions(["Touch Tone", "Deep Waves", "Quarks", "DigitalResWave", "WS Strings", "Motion", "WS Metal", "WS S&H", "WS Table", "Vocalise", "Voices", "Air Vox", "Glass Vox", "Glass Bottle", "Softwaves", "SynOrch", "PWM Strings", "SynString", "Ravel By Number", "EP Body 1", "EP Tine", "E.Piano", "Mini", "Super Clav", "Pluck 3", "Digi Harp", "Tambotack", "Syn Bass 1", "Vox Bass", "VS Bell", "Sweet Bells", "Soft Horn", "Syn Brass", "Wave Song", "Industrial"]),
    ]
  
//  // this last one is for CARD
//      { "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23", "24", "25", "26", "27", "28", "29", "30", "31", "32", "33", "34" }

}


struct JDXiDigitalPatch : JDXiMultiPatch, BankedPatchTemplate {

  typealias Bank = JDXiDigitalBank
    
  static func startAddress(_ path: SynthPath?) -> RolandAddress {
    guard (path?.count ?? 0) > 1 else { return 0 }
    return RolandAddress([0x19, 0x20 * UInt8(path?.endex ?? 0) + 0x01, 0,0])
  }
  
//  static let fileDataCount = 513
//  
//  // 354: what it *should* be based on the size of the subpatches
//  // 513: what is *is* bc the JD-Xi sends an extra sysex msg. undocumented
//  static func isValid(fileSize: Int) -> Bool {
//    return fileSize == fileDataCount || fileSize == 354
//  }

  static let initFileName = ""
  
  static let rolandMap: [RolandMapItem] = [
    ([.common], 0x0000, CommonPatch.self),
    ([.extra], 0x0200, ExtraPatch.self),
    ([.partial, .i(0)], 0x2000, PartialPatch.self),
    ([.partial, .i(1)], 0x2100, PartialPatch.self),
    ([.partial, .i(2)], 0x2200, PartialPatch.self),
    ([.mod], 0x5000, ModifyPatch.self),
  ]
  
  struct CommonPatch : JDXiSinglePatch {
    
    static let initFileName = ""
    static let nameByteRange: CountableRange<Int>? = 0..<0x0c
    static let size: RolandAddress = 0x40

    static func startAddress(_ path: SynthPath?) -> RolandAddress { 0x0000 }

    static let params: [SynthPath : Param] = {
      var p = [SynthPath:Param]()

      p[[.tone, .level]] = RangeParam(byte: 0x000c)
      p[[.porta]] = RangeParam(byte: 0x0012, maxVal: 1)
      p[[.porta, .time]] = RangeParam(byte: 0x0013)
      p[[.mono]] = RangeParam(byte: 0x0014, maxVal: 1)
      p[[.octave, .shift]] = RangeParam(byte: 0x0015, range: 61...67, displayOffset: -64)
      p[[.bend, .up]] = RangeParam(byte: 0x0016, maxVal: 24)
      p[[.bend, .down]] = RangeParam(byte: 0x0017, maxVal: 24)
      p[[.partial, .i(0), .on]] = RangeParam(byte: 0x0019, maxVal: 1)
      p[[.partial, .i(0), .select]] = RangeParam(byte: 0x001a, maxVal: 1)
      p[[.partial, .i(1), .on]] = RangeParam(byte: 0x001b, maxVal: 1)
      p[[.partial, .i(1), .select]] = RangeParam(byte: 0x001c, maxVal: 1)
      p[[.partial, .i(2), .on]] = RangeParam(byte: 0x001d, maxVal: 1)
      p[[.partial, .i(2), .select]] = RangeParam(byte: 0x001e, maxVal: 1)
      p[[.ringMod]] = OptionsParam(byte: 0x001f, options: [0:"Off",2:"On"])
      p[[.unison]] = RangeParam(byte: 0x002e, maxVal: 1)
      p[[.porta, .legato]] = RangeParam(byte: 0x0031, maxVal: 1)
      p[[.legato]] = RangeParam(byte: 0x0032, maxVal: 1)
      p[[.analogFeel]] = RangeParam(byte: 0x0034)
      p[[.wave, .shape]] = RangeParam(byte: 0x0035)
      p[[.category]] = OptionsParam(byte: 0x0036, options: categoryOptions)
      p[[.unison, .number]] = OptionsParam(byte: 0x003c, options: ["2", "4", "6", "8"])
      return p
    }()
    
    static let categoryOptions : [Int:String] = [
      0 : "None",
      26 : "Brass",
      40 : "Seq",
      39 : "FX/Other",
      9 : "Key",
      21 : "Bass",
      34 : "Lead",
      36 : "Str/Pad",
    ]
    
  }

  struct ModifyPatch : JDXiSinglePatch {
    
    static let initFileName = ""
    static let size: RolandAddress = 0x25
    
    static func startAddress(_ path: SynthPath?) -> RolandAddress { 0x5000 }
        
    static let params: [SynthPath : Param] = {
      var p = [SynthPath:Param]()
      
      p[[.attack, .interval, .sens]] = RangeParam(byte: 0x0001)
      p[[.release, .interval, .sens]] = RangeParam(byte: 0x0002)
      p[[.porta, .interval, .sens]] = RangeParam(byte: 0x0003)
      p[[.env, .loop, .mode]] = OptionsParam(byte: 0x0004, options: ["Off", "Free Run", "Tempo Sync"])
      p[[.env, .loop, .sync, .note]] = OptionsParam(byte: 0x0005, options: ["16", "12", "8", "4", "2", "1", "3/4", "2/3", "1/2", "3/8", "1/3", "1/4", "3/16", "1/6", "1/8", "3/32", "1/12", "1/16", "1/24", "1/32"])
      p[[.chromatic, .porta]] = RangeParam(byte: 0x0006, maxVal: 1)
      
      return p
    }()
    
  }

  struct PartialPatch : JDXiSinglePatch {
    
    static let initFileName = ""
    static let size: RolandAddress = 0x3d
    
    static func startAddress(_ path: SynthPath?) -> RolandAddress {
      RolandAddress([0x20 + UInt8(path?.endex ?? 0), 0x00])
    }
    
    static let params: [SynthPath : Param] = {
      var p = [SynthPath:Param]()

      p[[.osc, .wave]] = OptionsParam(byte: 0x0000, options: ["Saw", "Square", "PW Square", "Triangle", "Sine", "Noise", "Super Saw", "PCM Wave"])
      p[[.osc, .wave, .mod]] = OptionsParam(byte: 0x0001, options: ["A", "B", "C"])
      p[[.coarse]] = RangeParam(byte: 0x0003, range: 40...88, displayOffset: -64)
      p[[.fine]] = RangeParam(byte: 0x0004, range: 14...114, displayOffset: -64)
      p[[.pw, .mod, .depth]] = RangeParam(byte: 0x0005)
      p[[.pw]] = RangeParam(byte: 0x0006)
      p[[.pitch, .env, .attack]] = RangeParam(byte: 0x0007)
      p[[.pitch, .env, .decay]] = RangeParam(byte: 0x0008)
      p[[.pitch, .env, .depth]] = RangeParam(byte: 0x0009, range: 1...127, displayOffset: -64)
      p[[.filter, .mode]] = OptionsParam(byte: 0x000a, options: ["Bypass", "Lo-Pass", "Hi-Pass", "Bandpass", "Peaking", "LPF2", "LPF3", "LPF4"])
      p[[.filter, .curve]] = OptionsParam(byte: 0x000b, options: ["-12dB", "-24dB"])
      p[[.cutoff]] = RangeParam(byte: 0x000c)
      p[[.filter, .key, .trk]] = RangeParam(byte: 0x000d, range: 54...74, displayOffset: -64)
      p[[.filter, .env, .velo]] = RangeParam(byte: 0x000e, range: 1...127, displayOffset: -64)
      p[[.reson]] = RangeParam(byte: 0x000f)
      p[[.filter, .env, .attack]] = RangeParam(byte: 0x0010)
      p[[.filter, .env, .decay]] = RangeParam(byte: 0x0011)
      p[[.filter, .env, .sustain]] = RangeParam(byte: 0x0012)
      p[[.filter, .env, .release]] = RangeParam(byte: 0x0013)
      p[[.filter, .env, .depth]] = RangeParam(byte: 0x0014, range: 1...127, displayOffset: -64)
      p[[.amp, .level]] = RangeParam(byte: 0x0015)
      p[[.amp, .velo]] = RangeParam(byte: 0x0016, range: 1...127, displayOffset: -64)
      p[[.amp, .env, .attack]] = RangeParam(byte: 0x0017)
      p[[.amp, .env, .decay]] = RangeParam(byte: 0x0018)
      p[[.amp, .env, .sustain]] = RangeParam(byte: 0x0019)
      p[[.amp, .env, .release]] = RangeParam(byte: 0x001a)
      p[[.pan]] = RangeParam(byte: 0x001b, displayOffset: -64)
      
      p[[.lfo, .shape]] = OptionsParam(byte: 0x001c, options: lfoShapes)
      p[[.lfo, .rate]] = RangeParam(byte: 0x001d)
      p[[.lfo, .tempo, .sync]] = RangeParam(byte: 0x001e, maxVal: 1)
      p[[.lfo, .sync, .note]] = OptionsParam(byte: 0x001f, options: lfoSyncNotes)
      
      p[[.lfo, .fade]] = RangeParam(byte: 0x0020)
      p[[.lfo, .key, .sync]] = RangeParam(byte: 0x0021, maxVal: 1)
      p[[.lfo, .pitch, .depth]] = RangeParam(byte: 0x0022, range: 1...127, displayOffset: -64)
      p[[.lfo, .filter, .depth]] = RangeParam(byte: 0x0023, range: 1...127, displayOffset: -64)
      p[[.lfo, .amp, .depth]] = RangeParam(byte: 0x0024, range: 1...127, displayOffset: -64)
      p[[.lfo, .pan, .depth]] = RangeParam(byte: 0x0025, range: 1...127, displayOffset: -64)
      p[[.mod, .lfo, .shape]] = OptionsParam(byte: 0x0026, options: lfoShapes)
      p[[.mod, .lfo, .rate]] = RangeParam(byte: 0x0027)
      p[[.mod, .lfo, .tempo, .sync]] = RangeParam(byte: 0x0028, maxVal: 1)
      p[[.mod, .lfo, .sync, .note]] = OptionsParam(byte: 0x0029, options: lfoSyncNotes)
      p[[.pw, .shift]] = RangeParam(byte: 0x002a)
      p[[.mod, .lfo, .pitch, .depth]] = RangeParam(byte: 0x002c, range: 1...127, displayOffset: -64)
      p[[.mod, .lfo, .filter, .depth]] = RangeParam(byte: 0x002d, range: 1...127, displayOffset: -64)
      p[[.mod, .lfo, .amp, .depth]] = RangeParam(byte: 0x002e, range: 1...127, displayOffset: -64)
      p[[.mod, .lfo, .pan, .depth]] = RangeParam(byte: 0x002f, range: 1...127, displayOffset: -64)
      p[[.cutoff, .aftertouch, .sens]] = RangeParam(byte: 0x0030, range: 1...127, displayOffset: -64)
      p[[.level, .aftertouch, .sens]] = RangeParam(byte: 0x0031, range: 1...127, displayOffset: -64)
      p[[.wave, .gain]] = OptionsParam(byte: 0x0034, options: ["-6dB", "0dB", "6dB", "12dB"])
      p[[.wave, .number]] = OptionsParam(parm: 4, byte: 0x0035, options: ["OFF", "Calc.Saw", "DistSaw Wave", "GR-300 Saw", "Lead Wave 1", "Lead Wave 2", "Unison Saw", "Saw+Sub Wave", "SqrLeadWave", "SqrLeadWave+", "FeedbackWave", "Bad Axe", "Cutting Lead", "DistTB Sqr", "Sync Sweep", "Saw Sync", "Unison Sync+", "Sync Wave", "Cutters", "Nasty", "Bagpipe Wave", "Wave Scan", "Wire String", "Lead Wave 3", "PWM Wave 1", "PWM Wave 2", "MIDI Clav", "Huge MIDI", "Wobble Bs 1", "Wobble Bs 2", "Hollow Bass", "SynBs Wave", "Solid Bass", "House Bass", "4OP FM Bass", "Fine Wine", "Bell Wave 1", "Bell Wave 1+", "Bell Wave 2", "Digi Wave 1", "Digi Wave 2", "Org Bell", "Gamelan", "Crystal", "Finger Bell", "DipthongWave", "DipthongWv +", "Hollo Wave1", "Hollo Wave2", "Hollo Wave2+", "Heaven Wave", "Doo", "MMM Vox", "Eeh Formant", "Iih Formant", "Syn Vox 1", "Syn Vox 2", "Org Vox", "Male Ooh", "LargeChrF 1", "LargeChrF 2", "Female Oohs", "Female Aahs", "Atmospheric", "Air Pad 1", "Air Pad 2", "Air Pad 3", "VP-330 Choir", "SynStrings 1", "SynStrings 2", "SynStrings 3", "SynStrings 4", "SynStrings 5", "SynStrings 6", "Revalation", "Alan's Pad", "lfo, . Poly", "Boreal Pad L", "Boreal Pad R", "HPF Pad L", "HPF Pad R", "Sweep Pad", "Chubby Ld", "Fantasy Pad", "Legend Pad", "D-50 Stack", "ChrdOfCnadaL", "ChrdOfCnadaR", "Fireflies", "JazzyBubbles", "SynthFx 1", "SynthFx 2", "X-mod, . Wave 1", "X-mod, . Wave 2", "SynVox Noise", "Dentist Nz", "Atmosphere", "Anklungs", "Xylo Seq", "O'Skool Hit", "Orch. Hit", "Punch Hit", "Philly Hit", "ClassicHseHt", "Tao Hit", "Smear Hit", "808 Kick 1Lp", "808 Kick 2Lp", "909 Kick Lp", "JD Piano", "E.Grand", "Stage EP", "Wurly", "EP Hard", "FM EP 1", "FM EP 2", "FM EP 3", "Harpsi Wave", "Clav Wave 1", "Clav Wave 2", "Vibe Wave", "Organ Wave 1", "Organ Wave 2", "PercOrgan 1", "PercOrgan 2", "Vint.Organ", "Harmonica", "Ac. Guitar", "Nylon Gtr", "Brt Strat", "Funk Guitar", "Jazz Guitar", "Dist Guitar", "D.Mute Gtr", "FatAc. Bass", "Fingerd Bass", "Picked Bass", "Fretless Bs", "Slap Bass", "Strings 1", "Strings 2", "Strings 3 L", "Strings 3 R", "Pizzagogo", "Harp Harm", "Harp Wave", "PopBrsAtk", "PopBrass", "Tp Section", "Studio Tp", "Tp Vib Mari", "Tp Hrmn Mt", "FM Brass", "Trombone", "Wide Sax", "Flute Wave", "Flute Push", "E.Sitar", "Sitar Drone", "Agogo", "Steel Drums"])
      p[[.hi, .pass, .cutoff]] = RangeParam(byte: 0x0039)
      p[[.saw, .detune]] = RangeParam(byte: 0x003a)
      p[[.mod, .lfo, .rate, .ctrl]] = RangeParam(byte: 0x003b, range: 1...127, displayOffset: -64)
      p[[.amp, .key, .trk]] = RangeParam(byte: 0x003c, range: 54...74, displayOffset: -64)

      return p
    }()
    
    static let lfoShapes = OptionsParam.makeOptions(["Triangle", "Sine", "Saw", "Square", "S&H", "Random"])
    static let lfoSyncNotes = OptionsParam.makeOptions(["16", "12", "8", "4", "2", "1", "3/4", "2/3", "1/2", "3/8", "1/3", "1/4", "3/16", "1/6", "1/8", "3/32", "1/12", "1/16", "1/24", "1/32"])
  }

  struct ExtraPatch : JDXiSinglePatch {
    
    static let initFileName = ""
    static let size: RolandAddress = 0x111
    
    static func startAddress(_ path: SynthPath?) -> RolandAddress { 0x0200 }
    
    static let params = [SynthPath:Param]()
  }
}

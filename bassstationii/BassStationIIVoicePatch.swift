
class BassStationIIVoicePatch : BassStationIIPatch, BankablePatch {

  static let bankType: SysexPatchBank.Type = BassStationIIVoiceBank.self
  static func location(forData data: Data) -> Int { return Int(data[8]) }
  
  static let initFileName = "bassstationii-voice-init"
  static let fileDataCount = 154
  
  var bytes: [UInt8]
  var nameBytes: [UInt8]
  
  required init(data: Data) {
    bytes = [UInt8](data[9..<137]).sevenToEightStraight()
    nameBytes = [UInt8](data[137..<153])
  }
  
  static func fromOverlay(_ overlay: BassStationIIOverlayKeyPatch) -> BassStationIIVoicePatch {
    let patch = BassStationIIVoicePatch()
    patch.name = overlay.name
    BassStationIIOverlayKeyPatch.params.forEach { (path, param) in
      switch path {
      case [.pitch]:
        patch[[.osc, .slop]] = overlay[[.pitch]]
      case [.level]:
        patch[[.glide, .split]] = overlay[[.level]]
      default:
        patch[path] = overlay[path]
      }
    }
    return patch
  }
  
  func sysexData(save: Bool, location: Int? = nil) -> Data {
    var data = Data(Self.sysexHeader() + [save ? 1 : 0, UInt8(location ?? 0)])
    data.append(contentsOf: bytes.eightToSevenStraight())
    data.append(contentsOf: nameBytes)
    data.append(0xf7)
    return data
  }
  
  func fileData() -> Data {
    return sysexData(save: false)
  }

  func randomize() {
    randomizeAllParams()
    
    self[[.extra]] = 0
    self[[.micro, .tune]] = 0
    self[[.arp, .on]] = 0
  }

  
  static let LSB = 0
  static let NRPN = 1
  static let AFX = 2
  
  static let params: SynthPathParam = {
    var p = SynthPathParam()
    
    p[[.porta]] = RangeParam(parm: 5, byte: 4)
    p[[.bend]] = RangeParam(parm: 107, byte: 6, range: 40...88, displayOffset: -64)
    p[[.sync]] = RangeParam(parm: 110, byte: 7, bit: 0, extra: [AFX:1])
    p[[.osc, .i(0), .wave]] = OptionsParam(parm: 0, byte: 8, extra: [NRPN:72, AFX:2], options: oscWaveOptions)
    p[[.osc, .i(0), .pw]] = MisoParam.make(parm: 74, byte: 9, extra: [AFX:3], iso: pwIso)
    p[[.osc, .i(0), .octave]] = OptionsParam(parm: 70, byte: 10, extra: [AFX:4], options: oscOctaveOptions)
    p[[.osc, .i(0), .coarse]] = MisoParam.make(parm: 27, byte: 11, extra: [LSB:59, AFX: 5], maxVal: 255, displayOffset: -128, iso: coarseIso)
    p[[.osc, .i(0), .fine]] = MisoParam.make(parm: 26, byte: 12, extra: [LSB:58, AFX: 6], range: 27...228, displayOffset: -128, iso: fineIso)
    p[[.osc, .i(1), .wave]] = OptionsParam(parm: 0, byte: 13, extra: [NRPN:82, AFX: 7], options: oscWaveOptions)
    p[[.osc, .i(1), .pw]] = MisoParam.make(parm: 79, byte: 14, extra: [AFX:8], iso: pwIso)
    p[[.osc, .i(1), .octave]] = OptionsParam(parm: 75, byte: 15, extra: [AFX:9], options: oscOctaveOptions)
    p[[.osc, .i(1), .coarse]] = MisoParam.make(parm: 30, byte: 16, extra: [LSB:62, AFX:10], maxVal: 255, displayOffset: -128, iso: coarseIso)
    p[[.osc, .i(1), .fine]] = MisoParam.make(parm: 29, byte: 17, extra: [LSB:61, AFX:11], range: 27...228, displayOffset: -128, iso: fineIso)
    
    p[[.sub, .wave]] = OptionsParam(parm: -1, byte: 18, bits: 0...1, extra: [NRPN:21, AFX:12], options: oscWaveOptions)
    p[[.sub, .mode]] = OptionsParam(parm: -1, byte: 18, bit: 2, extra: [NRPN:21, AFX:12], options: ["Classic", "Osc 3"])
    p[[.sub, .pw]] = MisoParam.make(parm: -1, byte: 19, extra: [NRPN:22, AFX:13], iso: pwIso)
    p[[.sub, .octave]] = OptionsParam(parm: -1, byte: 20, extra: [NRPN:23, AFX:14], options: subOscOctaveOptions)

    p[[.sub, .coarse]] = MisoParam.make(parm: 0, byte: 21, extra: [NRPN:84, AFX:15], maxVal: 255, displayOffset: -128, iso: coarseIso)
    p[[.sub, .fine]] = MisoParam.make(parm: 0, byte: 22, extra: [NRPN:77, AFX:16], range: 27...228, displayOffset: -128, iso: fineIso)
    p[[.sub, .sub, .wave]] = OptionsParam(parm: 80, byte: 23, extra: [AFX:17], options: ["Sine", "Pulse", "Square"])
    p[[.sub, .sub, .octave]] = OptionsParam(parm: 81, byte: 24, extra: [AFX:18], options: [62: "-2", 63: "-1"])
    p[[.osc, .i(0), .level]] = RangeParam(parm: 20, byte: 25, extra: [LSB:52, AFX:19], maxVal: 255)
    p[[.osc, .i(1), .level]] = RangeParam(parm: 21, byte: 26, extra: [LSB:53, AFX:20], maxVal: 255)
    p[[.sub, .level]] = RangeParam(parm: 22, byte: 27, extra: [LSB:54, AFX:21], maxVal: 255)
    p[[.noise, .level]] = RangeParam(parm: 23, byte: 28, extra: [LSB:55, AFX:22], maxVal: 255)
    p[[.ringMod, .level]] = RangeParam(parm: 24, byte: 29, extra: [LSB:56, AFX:23], maxVal: 255)
    p[[.ext, .level]] = RangeParam(parm: 25, byte: 30, extra: [LSB:57, AFX:24], maxVal: 255)
    p[[.filter, .cutoff]] = RangeParam(parm: 16, byte: 31, extra: [LSB:48, AFX: 25], maxVal: 255)
    p[[.filter, .reson]] = RangeParam(parm: 82, byte: 32, extra: [AFX:26])
    p[[.filter, .drive]] = RangeParam(parm: 114, byte: 33, extra: [AFX:27])
    p[[.filter, .slop]] = OptionsParam(parm: 106, byte: 34, bit: 3, extra: [AFX:28], options: ["12dB", "24dB"])
    p[[.filter, .type]] = OptionsParam(parm: 83, byte: 34, bit: 2, extra: [AFX:28], options: ["Classic", "Acid"])
    p[[.filter, .shape]] = OptionsParam(parm: 84, byte: 34, bits: 0...1, extra: [AFX:28], options: ["LP", "BP", "HP"])
    p[[.amp, .env, .velo]] = RangeParam(parm: 112, byte: 35, extra: [AFX:29], range: 1...127, displayOffset: -64)
    p[[.amp, .env, .attack]] = RangeParam(parm: 90, byte: 36, extra: [AFX:30])
    p[[.amp, .env, .decay]] = RangeParam(parm: 91, byte: 37, extra: [AFX:31])
    p[[.amp, .env, .sustain]] = RangeParam(parm: 92, byte: 38, extra: [AFX:32])
    p[[.amp, .env, .release]] = RangeParam(parm: 93, byte: 39, extra: [AFX:33])
    p[[.amp, .env, .trigger]] = OptionsParam(parm: 0, byte: 40, extra: [NRPN:73, AFX:34], options: envTriggerOptions)
    p[[.mod, .env, .velo]] = RangeParam(parm: 113, byte: 41, extra: [AFX:35], range: 1...127, displayOffset: -64)
    p[[.mod, .env, .attack]] = RangeParam(parm: 102, byte: 42, extra: [AFX:36])
    p[[.mod, .env, .decay]] = RangeParam(parm: 103, byte: 43, extra: [AFX:37])
    p[[.mod, .env, .sustain]] = RangeParam(parm: 104, byte: 44, extra: [AFX:38])
    p[[.mod, .env, .release]] = RangeParam(parm: 105, byte: 45, extra: [AFX:39])
    p[[.mod, .env, .trigger]] = OptionsParam(parm: 0, byte: 46, extra: [NRPN:105, AFX:40], options: envTriggerOptions)
    p[[.lfo, .i(0), .wave]] = OptionsParam(parm: 88, byte: 47, extra: [AFX:41], options: lfoWaveOptions)
    p[[.lfo, .i(0), .delay]] = RangeParam(parm: 86, byte: 48, extra: [AFX:42])
    p[[.lfo, .i(0), .slew]] = RangeParam(parm: 0, byte: 49, extra: [NRPN:86, AFX:43])
    p[[.lfo, .i(0), .speed]] = RangeParam(parm: 18, byte: 50, extra: [LSB:50, AFX:44], maxVal: 255)
    p[[.lfo, .i(0), .sync]] = OptionsParam(parm: 0, byte: 51, extra: [NRPN:87, AFX:45], options: lfoSyncOptions)
    p[[.lfo, .i(0), .time, .sync]] = OptionsParam(parm: 0, byte: 52, bit: 0, extra: [NRPN:88, AFX:46], options: lfoSpeedSyncOptions)
    p[[.lfo, .i(0), .key, .sync]] = RangeParam(parm: 0, byte: 52, bit: 1, extra: [NRPN:89, AFX:46])
    p[[.lfo, .i(1), .wave]] = OptionsParam(parm: 89, byte: 53, extra: [AFX:47], options: lfoWaveOptions)
    p[[.lfo, .i(1), .delay]] = RangeParam(parm: 87, byte: 54, extra: [AFX:48])
    p[[.lfo, .i(1), .slew]] = RangeParam(parm: 0, byte: 55, extra: [NRPN:90, AFX:49])
    p[[.lfo, .i(1), .speed]] = RangeParam(parm: 19, byte: 56, extra: [LSB:51, AFX:50], maxVal: 255)
    p[[.lfo, .i(1), .sync]] = OptionsParam(parm: 0, byte: 57, extra: [NRPN: 91, AFX:51], options: lfoSyncOptions)
    p[[.lfo, .i(1), .time, .sync]] = OptionsParam(parm: 0, byte: 58, bit: 0, extra: [NRPN:92, AFX:52], options: lfoSpeedSyncOptions)
    p[[.lfo, .i(1), .key, .sync]] = RangeParam(parm: 0, byte: 58, bit: 1, extra: [NRPN:93, AFX:52])
    p[[.arp, .on]] = RangeParam(parm: 108, byte: 59, bit: 0)
    p[[.arp, .latch]] = RangeParam(parm: 109, byte: 59, bit: 1)
    p[[.arp, .seq, .retrigger]] = RangeParam(parm: 0, byte: 59, bit: 2, extra: [NRPN:106])
    p[[.arp, .octave]] = OptionsParam(parm: 111, byte: 60, bits: 0...3, options: arpOctaveOptions)
    p[[.arp, .note, .mode]] = OptionsParam(parm: 118, byte: 61, options: arpNoteModeOptions)
    p[[.arp, .rhythm]] = RangeParam(parm: 119, byte: 62, maxVal: 31, displayOffset: 1)
    p[[.arp, .swing]] = RangeParam(parm: 116, byte: 63, range: 3...97)
    p[[.mod, .filter, .cutoff]] = RangeParam(parm: 0, byte: 64, extra: [NRPN:94], displayOffset: -64)
    p[[.mod, .lfo, .i(0), .pitch]] = RangeParam(parm: 0, byte: 65, extra: [NRPN:70], displayOffset: -64)
    p[[.mod, .lfo, .i(1), .filter, .cutoff]] = RangeParam(parm: 0, byte: 66, extra: [NRPN:71], displayOffset: -64)
    p[[.mod, .osc, .i(1), .pitch]] = RangeParam(parm: 0, byte: 67, extra: [NRPN:78], displayOffset: -64)
    p[[.aftertouch, .filter, .cutoff]] = RangeParam(parm: 0, byte: 68, extra: [NRPN:74, AFX:53], displayOffset: -64)
    p[[.aftertouch, .lfo, .i(0), .pitch]] = RangeParam(parm: 0, byte: 69, extra: [NRPN:75, AFX:54], displayOffset: -64)
    p[[.aftertouch, .lfo, .i(1), .speed]] = RangeParam(parm: 0, byte: 70, extra: [NRPN:76, AFX:55], displayOffset: -64)

    p[[.osc, .i(0), .lfo, .i(0), .pitch, .amt]] = MisoParam.make(parm: 28, byte: 71, extra: [LSB:60, AFX:56], maxVal: 255, displayOffset: -128, iso: bipolar127Iso)
    p[[.osc, .i(1), .lfo, .i(0), .pitch, .amt]] = MisoParam.make(parm: 31, byte: 72, extra: [LSB:63, AFX:57], maxVal: 255, displayOffset: -128, iso: bipolar127Iso)
    p[[.sub, .lfo, .i(0), .pitch, .amt]] = MisoParam.make(parm: -1, byte: 73, extra: [NRPN:83, AFX:58], maxVal: 255, displayOffset: -128, iso: bipolar127Iso)

    p[[.osc, .i(0), .lfo, .i(1), .pw, .amt]] = MisoParam.make(parm: 73, byte: 74, extra: [AFX:59], displayOffset: -64, iso: pwModIso)
    p[[.osc, .i(1), .lfo, .i(1), .pw, .amt]] = MisoParam.make(parm: 78, byte: 75, extra: [AFX:60], displayOffset: -64, iso: pwModIso)
    p[[.sub, .lfo, .i(1), .pw, .amt]] = MisoParam.make(parm: -1, byte: 76, extra: [NRPN:86, AFX:61], displayOffset: -64, iso: pwModIso)

    p[[.filter, .lfo, .i(1), .cutoff, .amt]] = MisoParam.make(parm: 17, byte: 77, extra: [LSB:49, AFX:62], maxVal: 255, displayOffset: -128, iso: bipolar127Iso)
    
    p[[.osc, .i(0), .mod, .env, .pitch, .amt]] = MisoParam.make(parm: 71, byte: 78, extra: [AFX:63], displayOffset: -64, iso: bipolar63Iso)
    p[[.osc, .i(1), .mod, .env, .pitch, .amt]] = MisoParam.make(parm: 76, byte: 79, extra: [AFX:64], displayOffset: -64, iso: bipolar63Iso)
    p[[.sub, .mod, .env, .pitch, .amt]] = MisoParam.make(parm: -1, byte: 80, extra: [NRPN:90, AFX:65], displayOffset: -64, iso: bipolar63Iso)

    p[[.osc, .i(0), .mod, .env, .pw, .amt]] = MisoParam.make(parm: 72, byte: 81, extra: [AFX:66], displayOffset: -64, iso: pwModIso)
    p[[.osc, .i(1), .mod, .env, .pw, .amt]] = MisoParam.make(parm: 77, byte: 82, extra: [AFX:67], displayOffset: -64, iso: pwModIso)
    p[[.sub, .mod, .env, .pw, .amt]] = MisoParam.make(parm: -1, byte: 83, extra: [NRPN:94, AFX:68], displayOffset: -64, iso: pwModIso)

    p[[.filter, .mod, .env, .cutoff, .amt]] = MisoParam.make(parm: 85, byte: 84, extra: [AFX:69], displayOffset: -64, iso: bipolar63Iso)
    p[[.osc, .filter, .mod]] = RangeParam(parm: 115, byte: 85, extra: [AFX:70])
    p[[.dist]] = RangeParam(parm: 94, byte: 86, extra: [AFX:71])
    p[[.limiter]] = RangeParam(parm: 95, byte: 87, extra: [AFX:72])
    p[[.paraphonic]] = RangeParam(parm: 0, byte: 89, bit: 0, extra: [NRPN:107])
    p[[.filter, .trk]] = OptionsParam(parm: 0, byte: 90, extra: [NRPN:108], options: filterTrackOptions)
    p[[.amp, .env, .retrigger]] = RangeParam(parm: 0, byte: 91, bit: 0, extra: [NRPN:109, AFX:73])
    p[[.mod, .env, .retrigger]] = RangeParam(parm: 0, byte: 92, bit: 0, extra: [NRPN:110, AFX:74])
    p[[.micro, .tune]] = RangeParam(parm: -1, byte: 93, extra: [NRPN:0], maxVal: 8)
    // on overlay, these next two are pitch/outlevel
    // pitch? 94
    // outlevel? 95
    p[[.osc, .slop]] = RangeParam(parm: 0, byte: 94, extra: [NRPN:111, AFX:75])
    p[[.glide, .split]] = RangeParam(parm: 0, byte: 95, extra: [NRPN:113, AFX:76], maxVal: 15)
    p[[.amp, .env, .fixed]] = RangeParam(parm: 0, byte: 96, bit: 0, extra: [NRPN:114, AFX:77])
    p[[.mod, .env, .fixed]] = RangeParam(parm: 0, byte: 97, bit: 0, extra: [NRPN:115, AFX:78])
    p[[.amp, .env, .retrigger, .number]] = MisoParam.make(parm: 0, byte: 98, extra: [NRPN:117, AFX:79], maxVal: 16, iso: retriggerCountIso)
    p[[.mod, .env, .retrigger, .number]] = MisoParam.make(parm: 0, byte: 99, extra: [NRPN:118, AFX:80], maxVal: 16, iso: retriggerCountIso)

    // afx overlay
    p[[.extra]] = RangeParam(parm: 0, byte: 101, extra: [NRPN:112], maxVal: 8)
    return p
  }()
  
  static let oscWaveOptions = OptionsParam.makeOptions(["Sine", "Triangle", "Saw", "Pulse"])
  
  static let oscOctaveOptions = [
    63: "16'",
    64: "8'",
    65: "4'",
    66: "2'",
  ]
  
  static let subOscOctaveOptions: [Int:String] = {
    var opts = oscOctaveOptions
    opts[67] = "1'"
    return opts
  }()

  static let coarseIso = Miso.options(coarseValues) >>> Miso.str()
  
  // https://github.com/francoisgeorgy/BS2-Web/blob/master/src/bass-station-2/constants.js
  static let coarseValues: [Float] = [-12.0, -11.9, -11.8, -11.7, -11.6, -11.5, -11.4, -11.3, -11.2, -11.1, -11.0, -10.9, -10.8, -10.7, -10.6, -10.5, -10.4, -10.2, -10.1, -10.0, -10.0, -9.9, -9.8, -9.7, -9.6, -9.5, -9.4, -9.3, -9.2, -9.1, -9.0, -9.0, -8.9, -8.8, -8.7, -8.6, -8.5, -8.4, -8.3, -8.2, -8.1, -8.0, -8.0, -7.9, -7.8, -7.7, -7.6, -7.5, -7.4, -7.3, -7.2, -7.1, -7.0, -7.0, -6.8, -6.7, -6.6, -6.5, -6.4, -6.3, -6.2, -6.1, -6.0, -6.0, -5.9, -5.8, -5.7, -5.6, -5.5, -5.4, -5.3, -5.2, -5.1, -5.0, -5.0, -4.9, -4.8, -4.7, -4.6, -4.5, -4.4, -4.3, -4.2, -4.1, -4.0, -4.0, -3.9, -3.8, -3.7, -3.6, -3.5, -3.3, -3.2, -3.1, -3.0, -3.0, -2.9, -2.8, -2.7, -2.6, -2.5, -2.4, -2.3, -2.2, -2.1, -2.0, -2.0, -1.9, -1.8, -1.7, -1.6, -1.5, -1.4, -1.3, -1.2, -1.1, -1.0, -1.0, -0.9, -0.8, -0.7, -0.6, -0.5, -0.4, -0.3, -0.2, -0.1,   0,   0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0, 1.0, 1.1, 1.2, 1.3, 1.4, 1.5, 1.6, 1.7, 1.8, 1.9, 2.0, 2.0, 2.1, 2.2, 2.3, 2.4, 2.5, 2.6, 2.7, 2.8, 2.9, 3.0, 3.0, 3.1, 3.2, 3.3, 3.5, 3.6, 3.7, 3.8, 3.9, 4.0, 4.0, 4.1, 4.2, 4.3, 4.4, 4.5, 4.6, 4.7, 4.8, 4.9, 5.0, 5.0, 5.1, 5.2, 5.3, 5.4, 5.5, 5.6, 5.7, 5.8, 5.9, 6.0, 6.0, 6.1, 6.2, 6.3, 6.4, 6.5, 6.6, 6.7, 6.8, 7.0, 7.0, 7.1, 7.2, 7.3, 7.4, 7.5, 7.6, 7.7, 7.8, 7.9, 8.0, 8.0, 8.1, 8.2, 8.3, 8.4, 8.5, 8.6, 8.7, 8.8, 8.9, 9.0, 9.0, 9.1, 9.2, 9.3, 9.4, 9.5, 9.6, 9.7, 9.8, 9.9, 10.0, 10.0, 10.1, 10.2, 10.4, 10.5, 10.6, 10.7, 10.8, 10.9, 11.0, 11.1, 11.2, 11.3, 11.4, 11.5, 11.6, 11.7, 11.8, 11.9, 12.0]
  
  static let fineIso = Miso.switcher([
    .range(27...127, Miso.a(-127)),
    .range(128...228, Miso.a(-128)),
  ]) >>> Miso.str()
  
  static let lfoWaveOptions = OptionsParam.makeOptions(["Triangle", "Saw", "Square", "S&H"])
  
  static let envTriggerOptions = OptionsParam.makeOptions(["Multi", "Single", "Autoglide"])
  
  static let retriggerCountIso = Miso.switcher([
    .int(0, "Loop")
  ], default: Miso.str())
  
  static let lfoSpeedSyncOptions = OptionsParam.makeOptions(["Speed", "Sync"])
  
  static let lfoSyncOptions = OptionsParam.makeOptions(["64", "48", "42", "36", "32", "30", "28", "24", "21 ⅔", "20", "18 ⅔", "18", "16", "13 ⅓", "12", "10 ⅔", "8", "6", "5 ⅓", "4", "3", "2 ⅔", "1/2", "1/4.", "1 ⅓", "1/4", "1/8.", "1/4 tr", "1/8", "1/16.", "1/8tr", "1/16", "1/16tr", "1/32", "1/32tr"])
  
  static let arpNoteModeOptions = OptionsParam.makeOptions(["Up", "Down", "Up-Down", "Up-Down 2", "Played", "Random", "Play", "Record"])
  
  static let arpOctaveOptions = [
    1 : "1",
    2 : "2",
    3 : "3",
    4 : "4",
  ]
  
  static let filterTrackOptions = OptionsParam.makeOptions(["Full", "1", "2", "3", "4", "5", "6", "None"])
  
  static let pwIso = Miso.switcher([
    .range(0...63, Miso.lerp(in: 0...63, out: 5...50)),
    .range(64...127, Miso.lerp(in: 64...127, out: 50...95)),
  ]) >>> Miso.round() >>> Miso.str()

  static let pwModOptions: [Float] = [-90, -88, -86, -85, -84, -82, -80, -78, -76, -75, -74, -73, -71, -70, -68, -66, -65, -64, -63, -61, -60, -59, -57, -56, -55, -53, -51, -50, -49, -47, -46, -45, -44, -42, -40, -39, -38, -36, -35, -34, -32, -30, -28, -26, -25, -24, -23, -22, -20, -19, -17, -16, -15, -14, -12, -10, -9, -7, -5, -4, -3, -2, -1, 0, 0, 1, 2, 3, 4, 5, 7, 9, 10, 12, 14, 15, 16, 17, 19, 20, 22, 23, 24, 25, 26, 28, 30, 32, 34, 35, 36, 38, 39, 40, 42, 44, 45, 46, 47, 49, 50, 51, 53, 55, 56, 57, 59, 60, 61, 63, 64, 65, 66, 68, 70, 71, 73, 74, 75, 76, 78, 80, 82, 84, 85, 86, 88, 90]
  static let pwModIso = Miso.lookupFunction(pwModOptions) >>> Miso.round() >>> Miso.str()

  static let bipolar63Iso = Miso.switcher([
    .range(0...63, Miso.a(-63)),
    .range(64...127, Miso.a(-64))
  ]) >>> Miso.str()
  
  static let bipolar127Iso = Miso.switcher([
    .range(0...127, Miso.a(-127)),
    .range(128...255, Miso.a(-128))
  ]) >>> Miso.str()

}

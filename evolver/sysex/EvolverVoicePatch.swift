
class EvolverVoicePatch : ByteBackedSysexPatch, BankablePatch {

  static let bankType: SysexPatchBank.Type = EvolverVoiceBank.self
  
  static func location(forData data: Data) -> Int { return Int(data[6]) }

  // 226 for edit buffer; 228 for pgm; 252 for pgm with name; 24 is for just name sysex
  static let fileDataCount = 226
  static let dataByteCount = 220 // number of data bytes in packed format
  static let initFileName = "evolver-voice-init"

  // name is in separate msg in banks
  var name = ""
  
  var bytes: [UInt8]
  
  required init(data: Data) {
    // make dependent on data count, since it can be 226 or 228 (bank)
    if data.count == 252 {
      // this should be 2 sysex msgs, 1 with name data
      let sysex = SysexData(data: data)
      let patchData = sysex[0].count == 24 ? sysex[1] : sysex[0]
      let nameData = sysex[0].count == 24 ? sysex[0] : sysex[1]

      let startByte = patchData.count - (type(of: self).dataByteCount + 1)
      bytes = data.unpack87(count: 192, inRange: startByte..<(patchData.count-1))
      
      name = String(data: nameData[7..<23], encoding: .ascii)?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines.union(.controlCharacters)) ?? ""
    }
    else {
      let startByte = data.count - (type(of: self).dataByteCount + 1)
      bytes = data.unpack87(count: 192, inRange: startByte..<(data.count-1))
    }
  }
  
  static func isValid(sysex: Data) -> Bool {
    return [fileDataCount, 228, 252, 24].contains(sysex.count)
  }

  /// Includes 2nd sysex msg for name data
  func sysexData(bank: Int, location: Int) -> [Data] {
    var data = Data([0xf0, 0x01, 0x20, 0x01, 0x02, UInt8(bank), UInt8(location)])
    data.append78(bytes: bytes, count: type(of: self).dataByteCount)
    data.append(0xf7)
    
    // append name bytes
    var nameData = Data([0xf0, 0x01, 0x20, 0x01, 0x11, UInt8(bank), UInt8(location)])
    let n = String(name.unicodeScalars.filter { return $0.isASCII }) as NSString
    let nameBytes = (0..<16).map { $0 < n.length ? UInt8(n.character(at: $0)) & 0x7f : 32 }
    nameData.append(contentsOf: nameBytes)
    nameData.append(0xf7)
    return [data, nameData]
  }

  /// Saved as edit buffer, no name.
  func fileData() -> Data {
    var data = Data([0xf0, 0x01, 0x20, 0x01, 0x03])
    data.append78(bytes: bytes, count: type(of: self).dataByteCount)
    data.append(0xf7)
    return data
  }
  
  func randomize() {
    randomizeAllParams()
    self[[.trigger]] = 0
    self[[.amp, .level]] = 0
    self[[.extAudio]] = 0
    self[[.extAudio, .volume]] = 0
    self[[.transpose]] = 37
    self[[.hi, .cutoff]] = 0
    self[[.amp, .volume]] = (50...100).random()!
    self[[.osc, .i(0), .semitone]] = 0
    self[[.osc, .i(1), .semitone]] = 0
    self[[.osc, .i(2), .semitone]] = 0
    self[[.osc, .i(3), .semitone]] = 0
  }
  
  private static let _params: SynthPathParam = {
    var p = SynthPathParam()

    p[[.osc, .i(0), .semitone]] = MisoParam.make(byte: 0, maxVal: 120, iso: noteIso)
    p[[.osc, .i(0), .detune]] = RangeParam(byte: 1, maxVal: 100, displayOffset: -50)
    p[[.osc, .i(0), .shape]] = RangeParam(byte: 2, maxVal: 102)
    p[[.osc, .i(0), .level]] = RangeParam(byte: 3, maxVal: 100)
    p[[.osc, .i(1), .semitone]] = MisoParam.make(byte: 4, maxVal: 120, iso: noteIso)
    p[[.osc, .i(1), .detune]] = RangeParam(byte: 5, maxVal: 100, displayOffset: -50)
    p[[.osc, .i(1), .shape]] = RangeParam(byte: 6, maxVal: 102)
    p[[.osc, .i(1), .level]] = RangeParam(byte: 7, maxVal: 100)
    p[[.osc, .i(2), .semitone]] = MisoParam.make(byte: 8, maxVal: 120, iso: noteIso)
    p[[.osc, .i(2), .detune]] = RangeParam(byte: 9, maxVal: 100, displayOffset: -50)
    p[[.osc, .i(2), .shape]] = RangeParam(byte: 10, displayOffset: 1)
    p[[.osc, .i(2), .level]] = RangeParam(byte: 11, maxVal: 100)
    p[[.osc, .i(3), .semitone]] = MisoParam.make(byte: 12, maxVal: 120, iso: noteIso)
    p[[.osc, .i(3), .detune]] = RangeParam(byte: 13, maxVal: 100, displayOffset: -50)
    p[[.osc, .i(3), .shape]] = RangeParam(byte: 14, displayOffset: 1)
    p[[.osc, .i(3), .level]] = RangeParam(byte: 15, maxVal: 100)

    p[[.filter, .cutoff]] = RangeParam(byte: 16, maxVal: 164)
    p[[.filter, .env, .amt]] = RangeParam(byte: 17, maxVal: 198, displayOffset: -99)
    p[[.filter, .env, .attack]] = RangeParam(byte: 18, maxVal: 110)
    p[[.filter, .env, .decay]] = RangeParam(byte: 19, maxVal: 110)
    p[[.filter, .env, .sustain]] = RangeParam(byte: 20, maxVal: 100)
    p[[.filter, .env, .release]] = RangeParam(byte: 21, maxVal: 110)
    p[[.filter, .reson]] = RangeParam(byte: 22, maxVal: 100)
    p[[.filter, .keyTrk]] = RangeParam(byte: 23, maxVal: 100)
    
    p[[.amp, .level]] = RangeParam(byte: 24, maxVal: 100)
    p[[.amp, .env, .amt]] = RangeParam(byte: 25, maxVal: 100)
    p[[.amp, .env, .attack]] = RangeParam(byte: 26, maxVal: 110)
    p[[.amp, .env, .decay]] = RangeParam(byte: 27, maxVal: 110)
    p[[.amp, .env, .sustain]] = RangeParam(byte: 28, maxVal: 100)
    p[[.amp, .env, .release]] = RangeParam(byte: 29, maxVal: 110)
    p[[.pan]] = OptionsParam(byte: 30, options: ["Full Wide", "Mostly Wide", "Lil Wide", "Mono", "Lil Cross", "Mostly Cross", "Full Cross"])
    p[[.amp, .volume]] = RangeParam(byte: 31, maxVal: 100)
    
    p[[.feedback, .freq]] = RangeParam(byte: 32, maxVal: 48)
    p[[.feedback, .amt]] = RangeParam(byte: 33, maxVal: 100)
    p[[.grunge]] = RangeParam(byte: 34, maxVal: 1)
    p[[.delay, .i(0), .time]] = RangeParam(byte: 35, maxVal: 166)
    p[[.delay, .i(0), .level]] = RangeParam(byte: 36, maxVal: 100)
    p[[.delay, .feedback, .delay]] = RangeParam(byte: 37, maxVal: 100)
    p[[.delay, .feedback, .filter]] = RangeParam(byte: 38, maxVal: 100)
    p[[.out, .hack]] = RangeParam(byte: 39, maxVal: 14)

    p[[.lfo, .i(0), .freq]] = RangeParam(byte: 40, maxVal: 160)
    p[[.lfo, .i(0), .shape]] = OptionsParam(byte: 41, options: lfoWaveOptions)
    p[[.lfo, .i(0), .amt]] = RangeParam(byte: 42, maxVal: 200)
    p[[.lfo, .i(0), .sync]] = RangeParam(byte: 42, maxVal: 200)
    p[[.lfo, .i(0), .dest]] = OptionsParam(byte: 43, options: modDestOptions)
    p[[.lfo, .i(1), .freq]] = RangeParam(byte: 44, maxVal: 160)
    p[[.lfo, .i(1), .shape]] = OptionsParam(byte: 45, options: lfoWaveOptions)
    p[[.lfo, .i(1), .amt]] = RangeParam(byte: 46, maxVal: 200)
    p[[.lfo, .i(1), .sync]] = RangeParam(byte: 46, maxVal: 200)
    p[[.lfo, .i(1), .dest]] = OptionsParam(byte: 47, options: modDestOptions)

    p[[.env, .i(2), .amt]] = RangeParam(byte: 48, maxVal: 198, displayOffset: -99)
    p[[.env, .i(2), .dest]] = OptionsParam(byte: 49, options: modDestOptions)
    p[[.env, .i(2), .env, .attack]] = RangeParam(byte: 50, maxVal: 110)
    p[[.env, .i(2), .env, .decay]] = RangeParam(byte: 51, maxVal: 110)
    p[[.env, .i(2), .env, .sustain]] = RangeParam(byte: 52, maxVal: 100)
    p[[.env, .i(2), .env, .release]] = RangeParam(byte: 53, maxVal: 110)

    p[[.trigger]] = OptionsParam(byte: 54, options: ["All", "Seq Only", "MIDI Only", "MIDI Reset", "Combo", "Combo Reset", "Ext In Env", "Ext In Env Reset", "Ext In Seq", "Ext In Seq Reset", "Seq Once", "Seq Reset", "Ext Trig", "Seq 1 Step"])
    p[[.transpose]] = RangeParam(byte: 55, maxVal: 73, formatter: {
      $0 == 0 ? "Key Off" : "\($0 - 37)"
    })
    
    p[[.seq, .i(0), .dest]] = OptionsParam(byte: 56, options: seqDestOptions)
    p[[.seq, .i(1), .dest]] = OptionsParam(byte: 57, options: seqDestOptions)
    p[[.seq, .i(2), .dest]] = OptionsParam(byte: 58, options: seqDestOptions)
    p[[.seq, .i(3), .dest]] = OptionsParam(byte: 59, options: seqDestOptions)
    p[[.noise]] = RangeParam(byte: 60, maxVal: 100)
    p[[.extAudio]] = RangeParam(byte: 61, maxVal: 100)
    p[[.extAudio, .volume]] = OptionsParam(byte: 62, options: ["Stereo", "Left", "Right", "L Audio/R Ctrl"])
    p[[.extAudio, .hack]] = RangeParam(byte: 63, maxVal: 14)
    
    p[[.osc, .i(0), .glide]] = RangeParam(byte: 64, maxVal: 200, formatter: glideFrmt)
    p[[.osc, .i(0), .sync]] = RangeParam(byte: 65, maxVal: 1)
    p[[.tempo]] = RangeParam(byte: 66, range: 30...250)
    p[[.clock, .divide]] = OptionsParam(byte: 67, options: clockDivOptions)
    p[[.osc, .i(1), .glide]] = RangeParam(byte: 68, maxVal: 200, formatter: glideFrmt)
    p[[.slop]] = RangeParam(byte: 69, maxVal: 5)
    p[[.bend]] = RangeParam(byte: 70, maxVal: 12)
    p[[.key, .mode]] = OptionsParam(byte: 71, options: keyAssignOptions)
    p[[.osc, .i(2), .glide]] = RangeParam(byte: 72, maxVal: 200, formatter: glideFrmt)
    p[[.osc, .i(2), .fm]] = RangeParam(byte: 73, maxVal: 100)
    p[[.osc, .i(2), .shape, .mod]] = OptionsParam(byte: 74, options: ["Off", "Seq 1", "Seq 2", "Seq 3", "Seq 4"])
    p[[.osc, .i(2), .ringMod]] = RangeParam(byte: 75, maxVal: 100)
    p[[.osc, .i(3), .glide]] = RangeParam(byte: 76, maxVal: 200, formatter: glideFrmt)
    p[[.osc, .i(3), .fm]] = RangeParam(byte: 77, maxVal: 100)
    p[[.osc, .i(3), .shape, .mod]] = OptionsParam(byte: 78, options: ["Off", "Seq 1", "Seq 2", "Seq 3", "Seq 4"])
    p[[.osc, .i(3), .ringMod]] = RangeParam(byte: 79, maxVal: 100)
    
    p[[.filter, .fourPole]] = RangeParam(byte: 80, maxVal: 1)
    p[[.filter, .env, .velo]] = RangeParam(byte: 81, maxVal: 100)
    p[[.filter, .mod]] = RangeParam(byte: 82, maxVal: 100)
    p[[.filter, .split]] = RangeParam(byte: 83, maxVal: 100)
    p[[.hi, .cutoff]] = RangeParam(byte: 84, maxVal: 199)
    p[[.mod, .i(0), .src]] = OptionsParam(byte: 85, options: modSrcOptions)
    p[[.mod, .i(0), .amt]] = RangeParam(byte: 86, maxVal: 198, displayOffset: -99)
    p[[.mod, .i(0), .dest]] = OptionsParam(byte: 87, options: modDestOptions)
    p[[.env, .mode]] = OptionsParam(byte: 88, options: ["Exp", "Lin"])
    p[[.amp, .env, .velo]] = RangeParam(byte: 89, maxVal: 100)
    p[[.mod, .i(1), .src]] = OptionsParam(byte: 90, options: modSrcOptions)
    p[[.mod, .i(1), .amt]] = RangeParam(byte: 91, maxVal: 198, displayOffset: -99)
    p[[.mod, .i(1), .dest]] = OptionsParam(byte: 92, options: modDestOptions)
    p[[.mod, .i(2), .src]] = OptionsParam(byte: 93, options: modSrcOptions)
    p[[.mod, .i(2), .amt]] = RangeParam(byte: 94, maxVal: 198, displayOffset: -99)
    p[[.mod, .i(2), .dest]] = OptionsParam(byte: 95, options: modDestOptions)
    p[[.mod, .i(3), .src]] = OptionsParam(byte: 96, options: modSrcOptions)
    p[[.mod, .i(3), .amt]] = RangeParam(byte: 97, maxVal: 198, displayOffset: -99)
    p[[.mod, .i(3), .dest]] = OptionsParam(byte: 98, options: modDestOptions)
    
    p[[.delay, .i(1), .time]] = RangeParam(byte: 99, maxVal: 166)
    p[[.delay, .i(1), .level]] = RangeParam(byte: 100, maxVal: 100)
    p[[.delay, .i(2), .time]] = RangeParam(byte: 101, maxVal: 166)
    p[[.delay, .i(2), .level]] = RangeParam(byte: 102, maxVal: 100)

    p[[.dist]] = RangeParam(byte: 103, maxVal: 199)

    p[[.lfo, .i(2), .freq]] = RangeParam(byte: 104, maxVal: 160)
    p[[.lfo, .i(2), .shape]] = OptionsParam(byte: 105, options: lfoWaveOptions)
    p[[.lfo, .i(2), .amt]] = RangeParam(byte: 106, maxVal: 200)
    p[[.lfo, .i(2), .sync]] = RangeParam(byte: 106, maxVal: 200)
    p[[.lfo, .i(2), .dest]] = OptionsParam(byte: 107, options: modDestOptions)
    p[[.lfo, .i(3), .freq]] = RangeParam(byte: 108, maxVal: 160)
    p[[.lfo, .i(3), .shape]] = OptionsParam(byte: 109, options: lfoWaveOptions)
    p[[.lfo, .i(3), .amt]] = RangeParam(byte: 110, maxVal: 200)
    p[[.lfo, .i(3), .sync]] = RangeParam(byte: 110, maxVal: 200)
    p[[.lfo, .i(3), .dest]] = OptionsParam(byte: 111, options: modDestOptions)

    p[[.env, .i(2), .delay]] = RangeParam(byte: 112, maxVal: 100)
    p[[.env, .i(2), .velo]] = RangeParam(byte: 113, maxVal: 100)
    p[[.extAudio, .peak, .amt]] = RangeParam(byte: 114, maxVal: 198, displayOffset: -99)
    p[[.extAudio, .peak, .dest]] = OptionsParam(byte: 115, options: modDestOptions)
    p[[.extAudio, .follow, .amt]] = RangeParam(byte: 116, maxVal: 198, displayOffset: -99)
    p[[.extAudio, .follow, .dest]] = OptionsParam(byte: 117, options: modDestOptions)
    p[[.velo, .amt]] = RangeParam(byte: 118, maxVal: 198, displayOffset: -99)
    p[[.velo, .dest]] = OptionsParam(byte: 119, options: modDestOptions)
    p[[.modWheel, .amt]] = RangeParam(byte: 120, maxVal: 198, displayOffset: -99)
    p[[.modWheel, .dest]] = OptionsParam(byte: 121, options: modDestOptions)
    p[[.pressure, .amt]] = RangeParam(byte: 122, maxVal: 198, displayOffset: -99)
    p[[.pressure, .dest]] = OptionsParam(byte: 123, options: modDestOptions)
    p[[.breath, .amt]] = RangeParam(byte: 124, maxVal: 198, displayOffset: -99)
    p[[.breath, .dest]] = OptionsParam(byte: 125, options: modDestOptions)
    p[[.foot, .amt]] = RangeParam(byte: 126, maxVal: 198, displayOffset: -99)
    p[[.foot, .dest]] = OptionsParam(byte: 127, options: modDestOptions)

    (0..<4).forEach { seq in
      (0..<16).forEach { step in
        let poff = seq * 16 + step
        p[[.seq, .i(seq), .step, .i(step)]] = RangeParam(byte: 128 + poff, maxVal: 102, formatter: seqFrmt)
      }
    }

    return p
  }()
  
  class var params: SynthPathParam { return _params }
  
  static let noteIso = Miso.noteName(zeroNote: "C-2")
  
  static let seqFrmt: ParamValueFormatter = {
    switch $0 {
    case 101: return "Reset"
    case 102: return "Off"
    default: return "\($0)"
    }
  }
  
  static let waveOptions = OptionsParam.makeOptions(["Saw","Tri","Saw/Tri","Pulse"])
  
  static let glideFrmt: ParamValueFormatter = {
    switch $0 {
    case 0...100:
      return "\($0)"
    case 101...199:
      return "F\($0 - 99)"
    default:
      return "Off"
    }
  }
  
  static let keyAssignOptions = OptionsParam.makeOptions(["Low Note","Low Note w/ retrig","High Note","High Note w/ retrig","Last Note","Last Note w/ retrig"])
  
  static let lfoFreqOptions = OptionsParam.makeOptions(["Unsynced","32 steps","16 steps","8 steps","4 steps","2 steps","1 step","1/2 step","1/4 step","1/8 step","1/16 step"])
  
  static let lfoWaveOptions = OptionsParam.makeOptions(["Tri","Rev Saw","Saw","Square","Random"])
  
  static let clockDivOptions = OptionsParam.makeOptions(["1/2","1/4","1/8","1/8 half swing","1/8 full swing","1/8 triplets","1/16","1/16 half swing","1/16 full swing","1/16 triplets","1/32","1/32 triplets","1/64 triplets"])
  
  static let syncDelayOptions = OptionsParam.makeOptions(["Unsynced","32 steps","16 steps","8 steps","4 steps","2 steps","1 step","1/2 step","1/4 step","1/8 step","1/16 step","6 steps","3 steps","1.5 steps","2/3 step","1/3 step","1/6 step"])

  static let modDestOptions = OptionsParam.makeOptions(["Off", "Osc 1 Freq", "Osc 2 Freq", "Osc 3 Freq", "Osc 4 Freq", "Osc All Freq", "Osc 1 Level", "Osc 2 Level", "Osc 3 Level", "Osc 4 Level", "Osc All Level", "Noise Level", "Ext In Level", "Osc 1 PW", "Osc 2 PW", "Osc All PW", "FM Osc 4 -> 3", "FM Osc 3 -> 4", "Ring Osc 4 -> 3", "Ring Osc 3 -> 4", "Filt Freq", "Filt Split", "Resonance", "Highpass Freq", "VCA Amt", "Pan", "Feedback Freq", "Feedback Amt", "Delay Time 1", "Delay Time 2", "Delay Time 3", "Delay Time All", "Delay Amt 1", "Delay Amt 2", "Delay Amt 3", "Delay Amt All", "Delay Feedbk 1", "Delay Feedbk 2", "LFO 1 Freq", "LFO 2 Freq", "LFO 3 Freq", "LFO 4 Freq", "LFO All Freq", "LFO 1 Amt", "LFO 2 Amt", "LFO 3 Amt", "LFO 4 Amt", "LFO A Amt", "Env 1 Amt", "Env 2 Amt", "Env 3 Amt", "Env A Amt", "Env 1 Attack", "Env 2 Attack", "Env 3 Attack", "Env A Attack", "Env 1 Decay", "Env 2 Decay", "Env 3 Decay", "Env A Decay", "Env 1 Rel", "Env 2 Rel", "Env 3 Rel", "Env A Rel", "Filt 1 (L) Cutoff", "Filt 2 (R) Cutoff", "Filt 1 (L) Reson", "Filt 2 (R) Reson", "Distortion"])
  
  static let seqDestOptions = OptionsParam.makeOptions(["Off", "Osc 1 Freq", "Osc 2 Freq", "Osc 3 Freq", "Osc 4 Freq", "Osc All Freq", "Osc 1 Level", "Osc 2 Level", "Osc 3 Level", "Osc 4 Level", "Osc All Level", "Noise Level", "Ext In Level", "Osc 1 PW", "Osc 2 PW", "Osc All PW", "FM Osc 4 -> 3", "FM Osc 3 -> 4", "Ring Osc 4 -> 3", "Ring Osc 3 -> 4", "Filt Freq", "Filt Split", "Resonance", "Highpass Freq", "VCA Amt", "Pan", "Feedback Freq", "Feedback Amt", "Delay Time 1", "Delay Time 2", "Delay Time 3", "Delay Time All", "Delay Amt 1", "Delay Amt 2", "Delay Amt 3", "Delay Amt All", "Delay Feedbk 1", "Delay Feedbk 2", "LFO 1 Freq", "LFO 2 Freq", "LFO 3 Freq", "LFO 4 Freq", "LFO All Freq", "LFO 1 Amt", "LFO 2 Amt", "LFO 3 Amt", "LFO 4 Amt", "LFO A Amt", "Env 1 Amt", "Env 2 Amt", "Env 3 Amt", "Env A Amt", "Env 1 Attack", "Env 2 Attack", "Env 3 Attack", "Env A Attack", "Env 1 Decay", "Env 2 Decay", "Env 3 Decay", "Env A Decay", "Env 1 Rel", "Env 2 Rel", "Env 3 Rel", "Env A Rel", "Filt 1 (L) Cutoff", "Filt 2 (R) Cutoff", "Filt 1 (L) Reson", "Filt 2 (R) Reson", "Distortion", "Clock Mult", "Note Out", "Velo Out", "Mod Wh Out", "Pressure Out", "Breath Out", "Foot Out"])
  
  static let modSrcOptions = OptionsParam.makeOptions(["None", "Seq 1", "Seq 2", "Seq 3", "Seq 4", "LFO 1", "LFO 2", "LFO 3", "LFO 4", "Filter Env", "Amp Env", "Env 3", "Ext In Peak", "Ext In Env Follow", "Pitch Bend", "Mod Wheel", "Pressure", "Breath", "Foot", "Note Velo", "Note #", "Expr", "Noise", "Osc 3", "Osc 4", ])
  
}

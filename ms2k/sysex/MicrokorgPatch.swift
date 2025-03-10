
class MicrokorgPatch : ByteBackedSysexPatch, BankablePatch {
  
  static let fileDataCount = 297
  class var bankType: SysexPatchBank.Type { return MicrokorgBank.self }
  static let nameByteRange = 0..<12

  class var initFileName: String { return "mk-init" }
  
  var bytes: [UInt8]
  
  required init(data: Data) {
    bytes = data.unpack87(count: 254, inRange: 5..<296)
  }

  subscript(path: SynthPath) -> Int? {
    get {
      guard let param = type(of: self).params[path] else { return nil }
      switch path {
      case [.arp, .tempo]:
        return (Int(bytes[30]) << 8) + Int(bytes[31])
      case [.tone, .i(0), .channel], [.tone, .i(1), .channel], [.vocoder, .channel], [.arp, .swing]:
        return Int(Int8(bitPattern: bytes[param.byte]))
      case [.trigger, .i(0)], [.trigger, .i(1)], [.trigger, .i(2)], [.trigger, .i(3)], [.trigger, .i(4)], [.trigger, .i(5)], [.trigger, .i(6)], [.trigger, .i(7)]:
        return 1 - (unpack(param: param) ?? 0)
      default:
        return unpack(param: param)
      }
    }
    set {
      guard let param = type(of: self).params[path],
        let newValue = newValue else { return }
      if path.starts(with: [.vocoder, .level]) {
        bytes[param.byte] = UInt8(newValue)
        bytes[param.byte+1] = UInt8(newValue)
      }
      else if path.starts(with: [.vocoder, .pan]) {
        bytes[param.byte] = UInt8(newValue)
        bytes[param.byte+1] = UInt8(newValue)
      }
      else if path.starts(with: [.vocoder, .env, .follow, .hold]) {
        // rough setting for this very high-res value
        bytes[param.byte] = UInt8(newValue)
        bytes[param.byte+1] = UInt8(newValue)
        bytes[param.byte+2] = UInt8(newValue)
        bytes[param.byte+3] = UInt8(newValue)
      }
      else {
        switch path {
        case [.arp, .tempo]:
          bytes[param.byte] = UInt8(newValue >> 8)
          bytes[param.byte+1] = UInt8(newValue & 0xff)
        case [.tone, .i(0), .channel], [.tone, .i(1), .channel], [.vocoder, .channel], [.arp, .swing]:
          bytes[param.byte] = UInt8(bitPattern: Int8(newValue))
        case [.trigger, .i(0)], [.trigger, .i(1)], [.trigger, .i(2)], [.trigger, .i(3)], [.trigger, .i(4)], [.trigger, .i(5)], [.trigger, .i(6)], [.trigger, .i(7)]:
          pack(value: 1 - newValue, forParam: param)
        default:
          pack(value: newValue, forParam: param)
        }
      }
    }
  }
  
  func sysexData(channel: Int) -> Data {
    var data = Data([0xf0, 0x42, 0x30 + UInt8(channel), 0x58, 0x40])
    data.append(Data.pack78(bytes: bytes, count: 291))
    data.append(0xf7)
    return data
  }
  
  func fileData() -> Data {
    return sysexData(channel: 0)
  }

  
//  override class func random() -> Patch {
//
//    let p = self.init()
//
//    p.name = self.randomName()
//
//    for (key, param) in template.params {
//      // initialize values dict for every param, because some won't get filled in by init data
//      // ie a vocoder patch won't init all of the synth voice values
//      p.values[key] = NSNumber(value: param.randomize() as Int)
//    }
//
//    // make all the midi channels global
//    p.values["TimbreChannel-1"] = NSNumber(value: -1 as Int)
//    p.values["TimbreChannel-2"] = NSNumber(value: -1 as Int)
//    p.values["TimbreChannel-V"] = NSNumber(value: -1 as Int)
//
//    // make the pans center
//    p.values["Pan-1"] = NSNumber(value: 0 as Int)
//    p.values["Pan-2"] = NSNumber(value: 0 as Int)
//
//    return p
//  }
  
  private static let _params: SynthPathParam = {
    var p = SynthPathParam()

    p[[.trigger, .length]] = RangeParam(byte: 14, bits: 0...2, maxVal: 7, displayOffset: 1)
    (0..<8).forEach {
      p[[.trigger, .i($0)]] = RangeParam(byte: 15, bit: $0)
    }
    p[[.voice, .mode]] = OptionsParam(byte: 16, bits: 4...5, options: [
      0 : "Single",
      2 : "Layer",
      3 : "Vocoder"
      ])
    p[[.delay, .sync, .note]] = OptionsParam(byte: 19, bits: 0...3, options: ["1/32", "1/24", "1/16", "1/12", "3/32", "1/8", "1/6", "3/16", "1/4", "1/3", "3/8", "1/2", "2/3", "3/4", "1/1"])
    p[[.delay, .tempo, .sync]] = RangeParam(byte: 19, bit: 7)
    p[[.delay, .time]] = RangeParam(parm: -40, byte: 20)
    p[[.delay, .depth]] = RangeParam(parm: -41, byte: 21)
    p[[.delay, .type]] = OptionsParam(byte: 22, options: ["Stereo", "Cross ", "Left/Right"])
    p[[.mod, .speed]] = RangeParam(parm: -38, byte: 23)
    p[[.mod, .depth]] = RangeParam(parm: -39, byte: 24)
    p[[.mod, .type]] = OptionsParam(byte: 25, options: ["Cho/Flg", "Ensemble", "Phaser"])
    p[[.hi, .freq]] = OptionsParam(byte: 26, options: hiFreqOptions)
    p[[.hi, .gain]] = makeRangeParam(byte: 27, range: -12...12)
    p[[.lo, .freq]] = OptionsParam(byte: 28, options: loFreqOptions)
    p[[.lo, .gain]] = makeRangeParam(byte: 29, range: -12...12)
    p[[.arp, .tempo]] = RangeParam(byte: 30, range: 20...300)
    p[[.arp, .key, .sync]] = RangeParam(byte: 32, bit: 0)
    p[[.arp, .dest]] = OptionsParam(byte: 32, bits: 4...5, options: ["Both", "Timbre 1", "Timbre 2"])
    p[[.arp, .latch]] = RangeParam(parm: 0x0004, byte: 32, bit: 6)
    p[[.arp, .on]] = RangeParam(parm: 0x0002, byte: 32, bit: 7)
    p[[.arp, .type]] = OptionsParam(parm: 0x0007, byte: 33, bits: 0...3, options: ["Up", "Down", "Alt1", "Alt2", "Random", "Trigger"])
    p[[.arp, .range]] = RangeParam(parm: 0x0003, byte: 33, bits: 4...7, maxVal: 3, displayOffset: 1)
    p[[.arp, .gate, .time]] = RangeParam(parm: 0x000a, byte: 34, maxVal: 100)
    p[[.arp, .resolution]] = OptionsParam(byte: 35, options: ["1/24", "1/16", "1/12", "1/8", "1/6", "1/4"])
    p[[.arp, .swing]] = RangeParam(byte: 36, range: -100...100)
    p[[.key, .octave]] = makeRangeParam(byte: 37, range: -3...3)
    
    
    // timbre mode
    for i in 0..<2 {
      let o = (i == 0 ? 38 : 146)
      let pre: SynthPath = [.tone, .i(i)]

      p[pre + [.voice, .assign]] = OptionsParam(byte: o+1, bits: 6...7, options: voiceAssignOptions)
      p[pre + [.trigger, .mode]] = OptionsParam(byte: o+1, bit: 3, options: triggerOptions)
      p[pre + [.unison, .tune]] = RangeParam(byte: o+2, maxVal: 99)
      p[pre + [.tune]] = makeRangeParam(byte: o+3, range: -50...50)
      p[pre + [.porta]] = RangeParam(parm: -1, byte: o+15)
      p[pre + [.bend]] = makeRangeParam(byte: o+4, range: -12...12)
      p[pre + [.transpose]] = makeRangeParam(byte: o+5, range: -24...24)
      p[pre + [.vib, .amt]] = makeRangeParam(byte: o+6, range: -63...63)
      
      p[pre + [.osc, .i(0), .wave, .mode]] = OptionsParam(parm: -2, byte: o+7, options: osc1WaveOptions)
      p[pre + [.osc, .i(0), .ctrl, .i(0)]] = RangeParam(parm: -3, byte: o+8)
      p[pre + [.osc, .i(0), .ctrl, .i(1)]] = RangeParam(parm: -4, byte: o+9)
      p[pre + [.osc, .i(0), .wave]] = OptionsParam(parm: -4, byte: o+10, options: dwgsWaveOptions) // PARM SAME AS CTRL 2
      
      p[pre + [.mod, .select]] = OptionsParam(parm: -6, byte: o+12, bits: 4...5, options: ["Off", "Ring", "Sync", "Ring/Sync"]
      )
      p[pre + [.osc, .i(1),  .wave]] = OptionsParam(parm: -5, byte: o+12, bits: 0...1, options: ["Saw", "Square", "Tri"])
      p[pre + [.osc, .i(1),  .semitone]] = makeRangeParam(parm: -7, byte: o+13, range: -24...24)
      p[pre + [.osc, .i(1),  .tune]] = makeRangeParam(parm: -8, byte: o+14, range: -63...63)
      
      p[pre + [.osc, .i(0),  .level]] = RangeParam(parm: -9, byte: o+16)
      p[pre + [.osc, .i(1),  .level]] = RangeParam(parm: -10, byte: o+17)
      p[pre + [.noise, .level]] = RangeParam(parm: -11, byte: o+18)
      
      p[pre + [.filter, .type]] = OptionsParam(parm: -12, byte: o+19, options: ["24LPF", "12LPF", "12BPF", "12HPF"])
      p[pre + [.cutoff]] = RangeParam(parm: -13, byte: o+20)
      p[pre + [.reson]] = RangeParam(parm: -14, byte: o+21)
      p[pre + [.filter, .env, .amt]] = makeRangeParam(parm: -15, byte: o+22, range: -63...63)
      p[pre + [.filter, .velo]] = makeRangeParam(byte: o+23, range: -63...63)
      p[pre + [.filter, .key, .trk]] = makeRangeParam(parm: -16, byte: o+24, range: -63...63)
      
      p[pre + [.amp, .level]] = RangeParam(parm: -17, byte: o+25)
      p[pre + [.pan]] = makeRangeParam(parm: -18, byte: o+26, range: -63...63)
      p[pre + [.amp, .mode]] = OptionsParam(parm: -19, byte: o+27, bit: 6, options: ["EG2", "Gate"])
      p[pre + [.dist]] = RangeParam(parm: -20, byte: o+27, bit: 0)
      p[pre + [.amp, .velo]] = makeRangeParam(byte: o+28, range: -63...63)
      p[pre + [.amp, .key, .trk]] = makeRangeParam(byte: o+29, range: -63...63)
      
      p[pre + [.env, .i(0), .attack]] = RangeParam(parm: -21, byte: o+30)
      p[pre + [.env, .i(0), .decay]] = RangeParam(parm: -22, byte: o+31)
      p[pre + [.env, .i(0), .sustain]] = RangeParam(parm: -23, byte: o+32)
      p[pre + [.env, .i(0), .release]] = RangeParam(parm: -24, byte: o+33)
      p[pre + [.env, .i(0), .reset]] = RangeParam(byte: o+1, bit: 4)
      
      p[pre + [.env, .i(1), .attack]] = RangeParam(parm: -25, byte: o+34)
      p[pre + [.env, .i(1), .decay]] = RangeParam(parm: -26, byte: o+35)
      p[pre + [.env, .i(1), .sustain]] = RangeParam(parm: -27, byte: o+36)
      p[pre + [.env, .i(1), .release]] = RangeParam(parm: -28, byte: o+37)
      p[pre + [.env, .i(1), .reset]] = RangeParam(byte: o+1, bit: 5)
      
      p[pre + [.lfo, .i(0), .key, .sync]] = OptionsParam(byte: o+38, bits: 4...5, options: keySyncOptions)
      p[pre + [.lfo, .i(0), .wave]] = OptionsParam(parm: -29, byte: o+38, bits: 0...1, options: lfo1WaveOptions)
      p[pre + [.lfo, .i(0), .freq]] = RangeParam(parm: -30, byte: o+39)
      p[pre + [.lfo, .i(0), .tempo, .sync]] = RangeParam(byte: o+40, bit: 7)
      p[pre + [.lfo, .i(0), .sync, .note]] = OptionsParam(parm: -30, byte: o+40, bits: 0...4, options: syncNoteOptions)
      
      p[pre + [.lfo, .i(1), .key, .sync]] = OptionsParam(byte: o+41, bits: 4...5, options: keySyncOptions)
      p[pre + [.lfo, .i(1), .wave]] = OptionsParam(parm: -31, byte: o+41, bits: 0...1, options: lfo2WaveOptions)
      p[pre + [.lfo, .i(1), .freq]] = RangeParam(parm: -32, byte: o+42)
      p[pre + [.lfo, .i(1), .tempo, .sync]] = RangeParam(byte: o+43, bit: 7)
      p[pre + [.lfo, .i(1), .sync, .note]] = OptionsParam(parm: -32, byte: o+43, bits: 0...4, options: syncNoteOptions)
      
      (0..<4).forEach {
        let off = 2 * $0
        p[pre + [.patch, .i($0), .src]] = OptionsParam(parm: 0x0400 + $0, byte: o+44+off, bits: 0...3, options: mkSources)
        p[pre + [.patch, .i($0), .amt]] = makeRangeParam(parm: -33 - $0, byte: o+45+off, range: -63...63)
        p[pre + [.patch, .i($0), .dest]] = OptionsParam(parm: 0x0408 + $0, byte: o+44+off, bits: 4...7, options: destinations)
      }
    }
    
    
    /**
     * VOCODER MODE
     */
    
    
    let o = 38
    let pre: SynthPath = [.vocoder]

    p[pre + [.voice, .assign]] = OptionsParam(byte: o+1, bits: 6...7, options: voiceAssignOptions)
    p[pre + [.trigger, .mode]] = OptionsParam(byte: o+1, bit: 3, options: triggerOptions)
    p[pre + [.unison, .tune]] = RangeParam(byte: o+2, maxVal: 99)
    p[pre + [.tune]] = makeRangeParam(byte: o+3, range: -50...50)
    p[pre + [.bend]] = makeRangeParam(byte: o+4, range: -12...12)
    p[pre + [.transpose]] = makeRangeParam(byte: o+5, range: -24...24)
    p[pre + [.vib, .amt]] = makeRangeParam(byte: o+6, range: -63...63)
    
    p[pre + [.osc, .i(0), .wave, .mode]] = OptionsParam(parm: -2, byte: o+7, options: osc1WaveOptions)
    p[pre + [.osc, .i(0), .ctrl, .i(0)]] = RangeParam(parm: -3, byte: o+8)
    p[pre + [.osc, .i(0), .ctrl, .i(1)]] = RangeParam(parm: -4, byte: o+9)
    p[pre + [.osc, .i(0), .wave]] = OptionsParam(byte: o+10, options: dwgsWaveOptions)
    p[pre + [.porta]] = RangeParam(parm: -1, byte: o+14)
    
    p[pre + [.osc, .i(0),  .level]] = RangeParam(parm: -9, byte: o+15)
    p[pre + [.extAudio, .level]] = RangeParam(parm: -10, byte: o+16)
    p[pre + [.noise, .level]] = RangeParam(parm: -11, byte: o+17)
    
    p[pre + [.hi, .pass, .level]] = RangeParam(parm: -7, byte: o+18)
    p[pre + [.extAudio, .gate, .sens]] = RangeParam(byte: o+19)
    p[pre + [.extAudio, .threshold]] = RangeParam(parm: -8, byte: o+20)
    p[pre + [.hi, .pass, .gate]] = RangeParam(byte: o+12, bit: 0)
    
    p[pre + [.formant, .shift]] = OptionsParam(parm: -12, byte: o+21, options: ["0", "+1", "+2", "-1", "-2"])
    p[pre + [.cutoff]] = makeRangeParam(parm: -13, byte: o+22, range: -63...63)
    p[pre + [.reson]] = RangeParam(parm: -14, byte: o+23)
    p[pre + [.filter, .mod, .src]] = OptionsParam(parm: 0x0400, byte: o+24, options: [
      1 : "Amp Env",
      2 : "LFO1",
      3 : "LFO2",
      4 : "Velocity",
      5 : "Key Track",
      6 : "Pitch Bend",
      7 : "Mod"
    ])

    p[pre + [.filter, .mod, .amt]] = makeRangeParam(parm: -15, byte: o+25, range: -63...63)
    p[pre + [.env, .follow, .sens]] = OptionsParam(parm: -16, byte: o+26, options: OptionsParam.makeOptions((0..<128).map { $0 == 127 ? "Hold" : "\($0)" }))

    
    p[pre + [.amp, .level]] = RangeParam(parm: -17, byte: o+27)
    p[pre + [.direct, .level]] = RangeParam(parm: -18, byte: o+28)
    p[pre + [.dist]] = RangeParam(parm: -20, byte: o+29, bit: 0)
    p[pre + [.amp, .velo]] = makeRangeParam(byte: o+30, range: -63...63)
    p[pre + [.amp, .key, .trk]] = makeRangeParam(byte: o+31, range: -63...63)
    
    p[pre + [.env, .i(1), .attack]] = RangeParam(parm: -25, byte: o+36)
    p[pre + [.env, .i(1), .decay]] = RangeParam(parm: -26, byte: o+37)
    p[pre + [.env, .i(1), .sustain]] = RangeParam(parm: -27, byte: o+38)
    p[pre + [.env, .i(1), .release]] = RangeParam(parm: -28, byte: o+39)
    p[pre + [.env, .i(1), .reset]] = RangeParam(byte: o+1, bit: 5) // parm # is made up
    
    p[pre + [.lfo, .i(0), .wave]] = OptionsParam(parm: -29, byte: o+40, bits: 0...1, options: lfo1WaveOptions)
    p[pre + [.lfo, .i(0), .freq]] = RangeParam(parm: -30, byte: o+41)
    p[pre + [.lfo, .i(0), .tempo, .sync]] = RangeParam(byte: o+42, bit: 7)
    p[pre + [.lfo, .i(0), .sync, .note]] = OptionsParam(byte: o+42, bits: 0...4, options: syncNoteOptions)
    p[pre + [.lfo, .i(0), .key, .sync]] = OptionsParam(byte: o+40, bits: 4...5, options: keySyncOptions)
    
    p[pre + [.lfo, .i(1), .wave]] = OptionsParam(parm: -31, byte: o+43, bits: 0...1, options: lfo2WaveOptions)
    p[pre + [.lfo, .i(1), .freq]] = RangeParam(parm: -32, byte: o+44)
    p[pre + [.lfo, .i(1), .tempo, .sync]] = RangeParam(byte: o+45, bit: 7)
    p[pre + [.lfo, .i(1), .sync, .note]] = OptionsParam(byte: o+45, bits: 0...4, options: syncNoteOptions)
    p[pre + [.lfo, .i(1), .key, .sync]] = OptionsParam(byte: o+43, bits: 4...5, options: keySyncOptions)
    for step in 0..<8 {
      let stepOff = 2 * step
      // each pair of channels is same value
      p[pre + [.level, .i(step)]] = RangeParam(parm: 0x0410 + stepOff, byte: o+46+stepOff)
      p[pre + [.pan, .i(step)]] = makeRangeParam(parm: 0x0420 + stepOff, byte: o+62+stepOff, range: -63...63)
    }
    for step in 0..<16 {
      let stepOff = 4 * step
      p[pre + [.env, .follow, .hold, .i(step)]] = RangeParam(byte: o+78+stepOff)
    }
    
    return p
  }()
  
  class var params: SynthPathParam { return _params }
  
  static func makeRangeParam(parm: Int = 0, byte: Int, range: ClosedRange<Int>) -> RangeParam {
    let modRange: ClosedRange<Int> = (range.lowerBound+64)...(range.upperBound+64)
    return RangeParam(parm: parm, byte: byte, range: modRange, displayOffset: -64)
  }
  
 
  // LFO options
  static let lfo1WaveOptions = OptionsParam.makeOptions(["Saw", "Square", "Tri", "S/H"])
  static let lfo2WaveOptions = OptionsParam.makeOptions(["Saw", "Square (+)", "Sine", "S/H"])
  static let keySyncOptions = OptionsParam.makeOptions(["Off", "Timbre", "Voice"])
  static let syncNoteOptions = OptionsParam.makeOptions(["1/1", "3/4", "2/3", "1/2", "3/8", "1/3", "1/4", "3/16", "1/6", "1/8", "3/32", "1/12", "1/16", "1/24", "1/32"])
  
  // common options
  static let voiceAssignOptions = OptionsParam.makeOptions(["Mono", "Poly", "Unison"])
  static let triggerOptions = OptionsParam.makeOptions(["Single", "Multi"])
  
  static let hiFreqOptions = OptionsParam.makeOptions(["1000", "1250", "1500", "1750", "2000", "2250", "2500", "2750", "3000", "3250", "3500", "3750", "4000", "4250", "4500", "4750", "5000", "5250", "5500", "5750", "6000", "7000", "8000", "9000", "10k", "11k", "12k", "14k", "16k", "18k"])
  
  static let loFreqOptions = OptionsParam.makeOptions(["40", "50", "60", "80", "100", "120", "140", "160", "180", "200", "220", "240", "260", "280", "300", "320", "340", "360", "380", "400", "420", "440", "460", "480", "500", "600", "700", "800", "900", "1000"])
  
  // oscillator options
  static let osc1WaveOptions = OptionsParam.makeOptions(["Saw", "Pulse", "Tri", "Sin (Cross)", "Vox Wave", "DWGS", "Noise", "Audio In"])
  static let dwgsWaveOptions = OptionsParam.makeOptions(["SynSine1", "SynSine2", "SynSine3", "SynSine4", "SynSine5", "SynSine6", "SynSine7", "SynBass1", "SynBass2", "SynBass3", "SynBass4", "SynBass5", "SynBass6", "SynBass7", "SynWave1", "SynWave2", "SynWave3", "SynWave4", "SynWave5", "SynWave6", "SynWave7", "SynWave8", "SynWave9", "5thWave1", "5thWave2", "5thWave3", "Digi1", "Digi2", "Digi3", "Digi4", "Digi5", "Digi6", "Digi7", "Digi8", "Endless", "E.Piano1", "E.Piano2", "E.Piano3", "E.Piano4", "Organ1", "Organ2", "Organ3", "Organ4", "Organ5", "Organ6", "Organ7", "Clav1", "Clav2", "Guitar1", "Guitar2", "Guitar3", "Bass1", "Bass2", "Bass3", "Bass4", "Bass5", "Bell1", "Bell2", "Bell3", "Bell4", "Voice1", "Voice2", "Voice3", "Voice4"])
  
  
  // patch source/dest
  static let mkSources = OptionsParam.makeOptions(["Filter Env", "Amp Env", "LFO1", "LFO2", "Velocity", "Key Track",
                                                   "Pitch", "Mod"])
  
  static let destinations = OptionsParam.makeOptions(["Pitch", "Osc2 Pitch", "Osc1 Ctrl 1", "Noise Level", "Cutoff", "Amp", "Pan", "LFO2 Freq"])


}


class MS2KPatch : ByteBackedSysexPatch, BankablePatch {
  
  class var bankType: SysexPatchBank.Type { return MS2KBank.self }

  static let fileDataCount = 297
  class var initFileName: String { return "ms2k-init" }
  static let nameByteRange = 0..<12

  var bytes: [UInt8]
  
  required init(data: Data) {
    bytes = data.unpack87(count: 254, inRange: 5..<296)
  }
  
  // TODO: test... do we need conditional packing/unpacking based on voice mode?
  
  
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
//
//    return p
//  }
  
  subscript(path: SynthPath) -> Int? {
    get {
      guard let param = type(of: self).params[path] else { return nil }
      switch path {
      case [.arp, .tempo]:
        return (Int(bytes[30]) << 8) + Int(bytes[31])
      case [.tone, .i(0), .channel], [.tone, .i(1), .channel], [.vocoder, .channel], [.arp, .swing]:
        return Int(Int8(bitPattern: bytes[param.byte]))
      default:
        return unpack(param: param)
      }
    }
    set {
      guard let param = type(of: self).params[path],
        let newValue = newValue else { return }
      switch path {
      case [.arp, .tempo]:
        bytes[param.byte] = UInt8(newValue >> 8)
        bytes[param.byte+1] = UInt8(newValue & 0xff)
      case [.tone, .i(0), .channel], [.tone, .i(1), .channel], [.vocoder, .channel], [.arp, .swing]:
        bytes[param.byte] = UInt8(bitPattern: Int8(newValue))
      default:
        pack(value: newValue, forParam: param)
      }
    }
  }
  
  private static let _params: SynthPathParam = {
    var p = SynthPathParam()
    
    p[[.voice, .mode]] = OptionsParam(parm: 16, byte: 16, bits: 4...5, options: ["Single", "Split", "Dual", "Vocoder"])
    p[[.split, .pt]] = RangeParam(parm: 17, byte: 18)
    p[[.timbre, .voice]] = OptionsParam(parm: 18, byte: 16, bits: 6...7, options: ["1+3", "2+2", "3+1"])
    p[[.scale, .type]] = OptionsParam(parm: 19, byte: 17, bits: 0...3, options: ["Equal Temp", "Pure Major", "Pure Minor", "Arabic", "Pythagorea", "Werckmeist", "Kirnberger", "Slendoro", "Pelog", "User Scale"])
    p[[.scale, .key]] = RangeParam(parm: 20, byte: 17, bits: 4...7, maxVal: 11)
    p[[.delay, .type]] = OptionsParam(parm: 21, byte: 22, options: ["Stereo", "Cross ", "Left/Right"])
    p[[.delay, .time]] = RangeParam(parm: 22, byte: 20)
    p[[.delay, .depth]] = RangeParam(parm: 23, byte: 21)
    p[[.mod, .type]] = OptionsParam(parm: 24, byte: 25, options: ["Cho/Flg", "Ensemble", "Phaser"])
    p[[.mod, .speed]] = RangeParam(parm: 25, byte: 23)
    p[[.mod, .depth]] = RangeParam(parm: 26, byte: 24)
    p[[.arp, .on]] = RangeParam(parm: 27, byte: 32, bit: 7)
    p[[.arp, .type]] = OptionsParam(parm: 28, byte: 33, bits: 0...3, options: ["Up", "Down", "Alt1", "Alt2", "Random", "Trigger"])
    p[[.arp, .range]] = RangeParam(parm: 29, byte: 33, bits: 4...7, maxVal: 3, displayOffset: 1)
    p[[.arp, .latch]] = RangeParam(parm: 30, byte: 32, bit: 6)
    
    p[[.arp, .tempo]] = RangeParam(parm: 31, byte: 30, range: 20...300)
    
    p[[.arp, .gate, .time]] = RangeParam(parm: 32, byte: 34, maxVal: 100)
    p[[.arp, .dest]] = OptionsParam(parm: 33, byte: 32, bits: 4...5, options: ["Both", "Timbre 1", "Timbre 2"])
    p[[.arp, .key, .sync]] = RangeParam(parm: 34, byte: 32, bit: 0)
    p[[.arp, .resolution]] = OptionsParam(parm: 35, byte: 35, options: ["1/24", "1/16", "1/12", "1/8", "1/6", "1/4"])
    p[[.arp, .swing]] = RangeParam(parm: 36, byte: 36, range: -100...100)
    
    p[[.hi, .freq]] = OptionsParam(parm: 0x25, byte: 26, options: hiFreqOptions)
    p[[.hi, .gain]] = makeRangeParam(parm: 0x26, byte: 27, range: -12...12)
    p[[.lo, .freq]] = OptionsParam(parm: 0x27, byte: 28, options: loFreqOptions)
    p[[.lo, .gain]] = makeRangeParam(parm: 0x28, byte: 29, range: -12...12)
    
    p[[.delay, .tempo, .sync]] = RangeParam(parm: 41, byte: 19, bit: 7)
    p[[.delay, .sync, .note]] = OptionsParam(parm: 42, byte: 19, bits: 0...3, options: ["1/32", "1/24", "1/16", "1/12", "3/32", "1/8", "1/6", "3/16", "1/4", "1/3", "3/8", "1/2", "2/3", "3/4", "1/1"])
    
    // timbre mode
    for i in 0..<2 {
      let o = (i == 0 ? 38 : 146)
      let po = (i == 0 ? 0x40 : 0xD0)
      let pre: SynthPath = [.tone, .i(i)]
      // this param is signed, hence the custom pack/unpack
      p[pre + [.channel]] = RangeParam(parm: po+3, byte: o+0, range: -1...15, displayOffset: 1)
      p[pre + [.voice, .assign]] = OptionsParam(parm: po+0, byte: o+1, bits: 6...7, options: voiceAssignOptions)
      p[pre + [.trigger, .mode]] = OptionsParam(parm: po+1, byte: o+1, bit: 3, options: triggerOptions)
      p[pre + [.voice, .priority]] = OptionsParam(parm: po+0x3e, byte: o+1, bits: 0...1, options: voicePriorityOptions)
      p[pre + [.unison, .tune]] = RangeParam(parm: po+2, byte: o+2, maxVal: 99)
      p[pre + [.tune]] = makeRangeParam(parm: po+5, byte: o+3, range: -50...50)
      p[pre + [.porta]] = RangeParam(parm: po+7, byte: o+15)
      p[pre + [.bend]] = makeRangeParam(parm: po+8, byte: o+4, range: -12...12)
      p[pre + [.transpose]] = makeRangeParam(parm: po+4, byte: o+5, range: -24...24)
      p[pre + [.vib, .amt]] = makeRangeParam(parm: po+6, byte: o+6, range: -63...63)
      
      p[pre + [.osc, .i(0), .wave, .mode]] = OptionsParam(parm: po+9, byte: o+7, options: osc1WaveOptions)
      p[pre + [.osc, .i(0), .ctrl, .i(0)]] = RangeParam(parm: po+0xa, byte: o+8)
      p[pre + [.osc, .i(0), .ctrl, .i(1)]] = RangeParam(parm: po+0xb, byte: o+9)
      p[pre + [.osc, .i(0), .wave]] = OptionsParam(parm: po+0xc, byte: o+10, options: dwgsWaveOptions)
      
      p[pre + [.mod, .select]] = OptionsParam(parm: po+0xe, byte: o+12, bits: 4...5, options: ["Off", "Ring", "Sync", "Ring/Sync"]
      )
      p[pre + [.osc, .i(1),  .wave]] = OptionsParam(parm: po+0xd, byte: o+12, bits: 0...1, options: ["Saw", "Square", "Tri"])
      p[pre + [.osc, .i(1),  .semitone]] = makeRangeParam(parm: po+0xf, byte: o+13, range: -24...24)
      p[pre + [.osc, .i(1),  .tune]] = makeRangeParam(parm: po+0x10, byte: o+14, range: -63...63)
      
      p[pre + [.osc, .i(0),  .level]] = RangeParam(parm: po+0x11, byte: o+16)
      p[pre + [.osc, .i(1),  .level]] = RangeParam(parm: po+0x12, byte: o+17)
      p[pre + [.noise, .level]] = RangeParam(parm: po+0x13, byte: o+18)
      
      p[pre + [.filter, .type]] = OptionsParam(parm: po+0x14, byte: o+19, options: ["24LPF", "12LPF", "12BPF", "12HPF"]
      )
      p[pre + [.cutoff]] = RangeParam(parm: po+0x15, byte: o+20)
      p[pre + [.reson]] = RangeParam(parm: po+0x16, byte: o+21)
      p[pre + [.filter, .env, .amt]] = makeRangeParam(parm: po+0x17, byte: o+22, range: -63...63)
      p[pre + [.filter, .velo]] = makeRangeParam(parm: po+0x22, byte: o+23, range: -63...63)
      p[pre + [.filter, .key, .trk]] = makeRangeParam(parm: po+0x18, byte: o+24, range: -63...63)
      
      p[pre + [.amp, .level]] = RangeParam(parm: po+0x19, byte: o+25)
      p[pre + [.pan]] = makeRangeParam(parm: po+0x1a, byte: o+26, range: -63...63)
      p[pre + [.amp, .mode]] = OptionsParam(parm: po+0x1b, byte: o+27, bit: 6, options: ["EG2", "Gate"])
      p[pre + [.dist]] = RangeParam(parm: po+0x1c, byte: o+27, bit: 0)
      p[pre + [.amp, .velo]] = makeRangeParam(parm: po+0x27, byte: o+28, range: -63...63)
      p[pre + [.amp, .key, .trk]] = makeRangeParam(parm: po+0x1d, byte: o+29, range: -63...63)
      
      p[pre + [.env, .i(0), .attack]] = RangeParam(parm: po+0x1e, byte: o+30)
      p[pre + [.env, .i(0), .decay]] = RangeParam(parm: po+0x1f, byte: o+31)
      p[pre + [.env, .i(0), .sustain]] = RangeParam(parm: po+0x20, byte: o+32)
      p[pre + [.env, .i(0), .release]] = RangeParam(parm: po+0x21, byte: o+33)
      p[pre + [.env, .i(0), .reset]] = RangeParam(parm: po+0x7c, byte: o+1, bit: 4)
      
      p[pre + [.env, .i(1), .attack]] = RangeParam(parm: po+0x23, byte: o+34)
      p[pre + [.env, .i(1), .decay]] = RangeParam(parm: po+0x24, byte: o+35)
      p[pre + [.env, .i(1), .sustain]] = RangeParam(parm: po+0x25, byte: o+36)
      p[pre + [.env, .i(1), .release]] = RangeParam(parm: po+0x26, byte: o+37)
      p[pre + [.env, .i(1), .reset]] = RangeParam(parm: po+0x7d, byte: o+1, bit: 5)
      
      p[pre + [.lfo, .i(0), .key, .sync]] = OptionsParam(parm: po+0x2c, byte: o+38, bits: 4...5, options: keySyncOptions)
      p[pre + [.lfo, .i(0), .wave]] = OptionsParam(parm: po+0x28, byte: o+38, bits: 0...1, options: lfo1WaveOptions)
      p[pre + [.lfo, .i(0), .freq]] = RangeParam(parm: po+0x29, byte: o+39)
      p[pre + [.lfo, .i(0), .tempo, .sync]] = RangeParam(parm: po+0x2b, byte: o+40, bit: 7)
      p[pre + [.lfo, .i(0), .sync, .note]] = OptionsParam(parm: po+0x2a, byte: o+40, bits: 0...4, options: syncNoteOptions)
      
      p[pre + [.lfo, .i(1), .key, .sync]] = OptionsParam(parm: po+0x31, byte: o+41, bits: 4...5, options: keySyncOptions)
      p[pre + [.lfo, .i(1), .wave]] = OptionsParam(parm: po+0x2d, byte: o+41, bits: 0...1, options: lfo2WaveOptions)
      p[pre + [.lfo, .i(1), .freq]] = RangeParam(parm: po+0x2e, byte: o+42)
      p[pre + [.lfo, .i(1), .tempo, .sync]] = RangeParam(parm: po+0x30, byte: o+43, bit: 7)
      p[pre + [.lfo, .i(1), .sync, .note]] = OptionsParam(parm: po+0x2f, byte: o+43, bits: 0...4, options: syncNoteOptions)
      
      (0..<4).forEach {
        let off = 2 * $0
        let poff = 3 * $0
        p[pre + [.patch, .i($0), .src]] = OptionsParam(parm: po+0x32+poff, byte: o+44+off, bits: 0...3, options: sources)
        p[pre + [.patch, .i($0), .amt]] = makeRangeParam(parm: po+0x34+poff, byte: o+45+off, range: -63...63)
        p[pre + [.patch, .i($0), .dest]] = OptionsParam(parm: po+0x33+poff, byte: o+44+off, bits: 4...7, options: destinations)
      }
      
      p[pre + [.seq, .on]] = RangeParam(parm: po+0x40, byte: o+52, bit: 7)
      p[pre + [.run, .mode]] = RangeParam(parm: po+0x43, byte: o+52, bit: 6)
      p[pre + [.seq, .resolution]] = OptionsParam(parm: po+0x45, byte: o+52, bits: 0...4, options: ["1/48", "1/32", "1/24", "1/16", "1/12", "3/32", "1/8", "1/6", "3/16", "1/4", "1/3", "3/8", "1/2", "2/3", "3/4", "1/1"])
      p[pre + [.seq, .last, .step]] = RangeParam(parm: po+0x41, byte: o+53, bits: 4...7, maxVal: 15, displayOffset: 1)
      p[pre + [.seq, .type]] = OptionsParam(parm: po+0x42, byte: o+53, bits: 2...3, options: ["Forward", "Reverse", "Alt1", "Alt2"])
      p[pre + [.seq, .key, .sync]] = OptionsParam(parm: po+0x44, byte: o+53, bits: 0...1, options: keySyncOptions)
      for j in 0..<3 {
        let seqOff = 54 + j * 18
        let pseqOff = 0x46 + j * 0x12
        p[pre + [.seq, .i(j), .knob]] = OptionsParam(parm: po + pseqOff, byte: o+seqOff, options: ["None", "Pitch", "Step Length", "Portamento", "Osc1 Ctrl 1", "Osc1 Ctrl 2", "Osc2 Semi", "Osc2 Tune", "Osc1 Level", "Osc2 Level", "Noise Level", "Cutoff", "Resonance", "EG1 Int", "Filter Key Trk", "Amp Level", "Pan", "EG1 Attack", "EG1 Decay", "EG1 Sustain", "EG1 Release", "EG2 Attack", "EG2 Decay", "EG2 Sustain", "EG2 Release", "LFO1 Freq", "LFO2 Freq", "Patch1 Int", "Patch2 Int", "Patch3 Int", "Patch4 Int"])
        p[pre + [.seq, .i(j), .motion, .type]] = OptionsParam(parm: po + pseqOff + 1, byte: o+seqOff+1, options: ["Smooth","Step"])
        for step in 0..<16 {
          p[pre + [.seq, .i(j), .step, .i(step)]] = makeRangeParam(parm: po + pseqOff + 2 + step, byte: o+seqOff+2+step, range: -63...63)
        }
      }
    }
    
    
    /**
     * VOCODER MODE
     */
    
    let o = 38
    let po = 0x160
    let pre: SynthPath = [.vocoder]
    // this param is signed, hence the custom pack/unpack
    p[pre + [.channel]] = RangeParam(parm: po+0x3, byte: o+0, range: -1...15, displayOffset: 1)
    p[pre + [.voice, .assign]] = OptionsParam(parm: po+0x0, byte: o+1, bits: 6...7, options: voiceAssignOptions)
    p[pre + [.trigger, .mode]] = OptionsParam(parm: po+0x1, byte: o+1, bit: 3, options: triggerOptions)
    p[pre + [.voice, .priority]] = OptionsParam(parm: po+0x4, byte: o+1, bits: 0...1, options: voicePriorityOptions)
    p[pre + [.unison, .tune]] = RangeParam(parm: po+0x2, byte: o+2, maxVal: 99)
    p[pre + [.tune]] = makeRangeParam(parm: po+0x9, byte: o+3, range: -50...50)
    p[pre + [.bend]] = makeRangeParam(parm: po+0xc, byte: o+4, range: -12...12)
    p[pre + [.transpose]] = makeRangeParam(parm: po+0x8, byte: o+5, range: -24...24)
    p[pre + [.vib, .amt]] = makeRangeParam(parm: po+0xa, byte: o+6, range: -63...63)
    
    p[pre + [.osc, .i(0), .wave, .mode]] = OptionsParam(parm: po+0x10, byte: o+7, options: osc1WaveOptions)
    p[pre + [.osc, .i(0), .ctrl, .i(0)]] = RangeParam(parm: po+0x11, byte: o+8)
    p[pre + [.osc, .i(0), .ctrl, .i(1)]] = RangeParam(parm: po+0x12, byte: o+9)
    p[pre + [.osc, .i(0), .wave]] = OptionsParam(parm: po+0x13, byte: o+10, options: dwgsWaveOptions)
    p[pre + [.porta]] = RangeParam(parm: po+0xb, byte: o+14)
    
    p[pre + [.osc, .i(0),  .level]] = RangeParam(parm: po+0x18, byte: o+15)
    p[pre + [.extAudio, .level]] = RangeParam(parm: po+0x19, byte: o+16)
    p[pre + [.noise, .level]] = RangeParam(parm: po+0x1a, byte: o+17)
    
    p[pre + [.hi, .pass, .level]] = RangeParam(parm: po+0x1b, byte: o+18)
    p[pre + [.extAudio, .gate, .sens]] = RangeParam(parm: po+0x1c, byte: o+19)
    p[pre + [.extAudio, .threshold]] = RangeParam(parm: po+0x1d, byte: o+20)
    p[pre + [.hi, .pass, .gate]] = RangeParam(parm: po+0x1e, byte: o+12, bit: 0)
    
    p[pre + [.formant, .shift]] = OptionsParam(parm: po+0x20, byte: o+21, options: ["0", "+1", "+2", "-1", "-2"])
    p[pre + [.cutoff]] = makeRangeParam(parm: po+0x21, byte: o+22, range: -63...63)
    p[pre + [.reson]] = RangeParam(parm: po+0x22, byte: o+23)
    p[pre + [.filter, .mod, .src]] = OptionsParam(parm: po+0x23, byte: o+24, options: sources)
    p[pre + [.filter, .mod, .amt]] = makeRangeParam(parm: po+0x24, byte: o+25, range: -63...63)
    p[pre + [.env, .follow, .sens]] = RangeParam(parm: po+0x25, byte: o+26)
    
    p[pre + [.amp, .level]] = RangeParam(parm: po+0x28, byte: o+27)
    p[pre + [.direct, .level]] = RangeParam(parm: po+0x29, byte: o+28)
    p[pre + [.dist]] = RangeParam(parm: po+0x2a, byte: o+29, bit: 0)
    p[pre + [.amp, .velo]] = makeRangeParam(parm: po+0x2b, byte: o+30, range: -63...63)
    p[pre + [.amp, .key, .trk]] = makeRangeParam(parm: po+0x2c, byte: o+31, range: -63...63)
    
    p[pre + [.env, .i(0), .attack]] = RangeParam(parm: po+0x34, byte: o+32)
    p[pre + [.env, .i(0), .decay]] = RangeParam(parm: po+0x35, byte: o+33)
    p[pre + [.env, .i(0), .sustain]] = RangeParam(parm: po+0x36, byte: o+34)
    p[pre + [.env, .i(0), .release]] = RangeParam(parm: po+0x37, byte: o+35)
    p[pre + [.env, .i(0), .reset]] = RangeParam(parm: po+0x6, byte: o+1, bit: 4) // parm # is made up
    
    p[pre + [.env, .i(1), .attack]] = RangeParam(parm: po+0x30, byte: o+36)
    p[pre + [.env, .i(1), .decay]] = RangeParam(parm: po+0x31, byte: o+37)
    p[pre + [.env, .i(1), .sustain]] = RangeParam(parm: po+0x32, byte: o+38)
    p[pre + [.env, .i(1), .release]] = RangeParam(parm: po+0x33, byte: o+39)
    p[pre + [.env, .i(1), .reset]] = RangeParam(parm: po+0x7, byte: o+1, bit: 5) // parm # is made up
    
    p[pre + [.lfo, .i(0), .wave]] = OptionsParam(parm: po+0x38, byte: o+40, bits: 0...1, options: lfo1WaveOptions)
    p[pre + [.lfo, .i(0), .freq]] = RangeParam(parm: po+0x39, byte: o+41)
    p[pre + [.lfo, .i(0), .tempo, .sync]] = RangeParam(parm: po+0x3b, byte: o+42, bit: 7)
    p[pre + [.lfo, .i(0), .sync, .note]] = OptionsParam(parm: po+0x3a, byte: o+42, bits: 0...4, options: syncNoteOptions)
    p[pre + [.lfo, .i(0), .key, .sync]] = OptionsParam(parm: po+0x3c, byte: o+40, bits: 4...5, options: keySyncOptions)
    
    p[pre + [.lfo, .i(1), .wave]] = OptionsParam(parm: po+0x40, byte: o+43, bits: 0...1, options: lfo2WaveOptions)
    p[pre + [.lfo, .i(1), .freq]] = RangeParam(parm: po+0x41, byte: o+44)
    p[pre + [.lfo, .i(1), .tempo, .sync]] = RangeParam(parm: po+0x43, byte: o+45, bit: 7)
    p[pre + [.lfo, .i(1), .sync, .note]] = OptionsParam(parm: po+0x42, byte: o+45, bits: 0...4, options: syncNoteOptions)
    p[pre + [.lfo, .i(1), .key, .sync]] = OptionsParam(parm: po+0x44, byte: o+43, bits: 4...5, options: keySyncOptions)
    
    for step in 0..<16 {
      p[pre + [.level, .i(step)]] = RangeParam(parm: po+0x4f+step+1, byte: o+45+step+1)
      p[pre + [.pan, .i(step)]] = makeRangeParam(parm: po+0x5f+step+1, byte: o+61+step+1, range: -63...63)
    }
    
    return p
  }()
  
  class var params: SynthPathParam { return _params }

  static func makeRangeParam(parm: Int, byte: Int, range: ClosedRange<Int>) -> RangeParam {
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
  static let voicePriorityOptions = OptionsParam.makeOptions(["Last", "Low", "High"])
  static let triggerOptions = OptionsParam.makeOptions(["Single", "Multi"])
  
  static let hiFreqOptions = OptionsParam.makeOptions(["1000", "1250", "1500", "1750", "2000", "2250", "2500", "2750", "3000", "3250", "3500", "3750", "4000", "4250", "4500", "4750", "5000", "5250", "5500", "5750", "6000", "7000", "8000", "9000", "10k", "11k", "12k", "14k", "16k", "18k"])
  
  static let loFreqOptions = OptionsParam.makeOptions(["40", "50", "60", "80", "100", "120", "140", "160", "180", "200", "220", "240", "260", "280", "300", "320", "340", "360", "380", "400", "420", "440", "460", "480", "500", "600", "700", "800", "900", "1000"])
  
  // oscillator options
  static let osc1WaveOptions = OptionsParam.makeOptions(["Saw", "Pulse", "Tri", "Sin (Cross)", "Vox Wave", "DWGS", "Noise", "Audio In"])
  static let dwgsWaveOptions = OptionsParam.makeOptions(["SynSine1", "SynSine2", "SynSine3", "SynSine4", "SynSine5", "SynSine6", "SynSine7", "SynBass1", "SynBass2", "SynBass3", "SynBass4", "SynBass5", "SynBass6", "SynBass7", "SynWave1", "SynWave2", "SynWave3", "SynWave4", "SynWave5", "SynWave6", "SynWave7", "SynWave8", "SynWave9", "5thWave1", "5thWave2", "5thWave3", "Digi1", "Digi2", "Digi3", "Digi4", "Digi5", "Digi6", "Digi7", "Digi8", "Endless", "E.Piano1", "E.Piano2", "E.Piano3", "E.Piano4", "Organ1", "Organ2", "Organ3", "Organ4", "Organ5", "Organ6", "Organ7", "Clav1", "Clav2", "Guitar1", "Guitar2", "Guitar3", "Bass1", "Bass2", "Bass3", "Bass4", "Bass5", "Bell1", "Bell2", "Bell3", "Bell4", "Voice1", "Voice2", "Voice3", "Voice4"])
  
  
  // patch source/dest
  static let sources = OptionsParam.makeOptions(["EG1", "EG2", "LFO1", "LFO2", "Velocity", "Key Track", "MIDI 1" , "MIDI 2"])
  
  static let destinations = OptionsParam.makeOptions(["Pitch", "Osc2 Pitch", "Osc1 Ctrl 1", "Noise Level", "Cutoff", "Amp", "Pan", "LFO2 Freq"])
  
}

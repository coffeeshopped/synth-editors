
protocol VirusVoicePatch : ByteBackedSysexPatch, VoicePatch, BankablePatch {
  func sysexData(deviceId: UInt8, bank: UInt8, part: UInt8) -> Data
}

extension VirusVoicePatch {

  static func location(forData data: Data) -> Int {
    guard data.count > 8 else { return 0 }
    return Int(data[8])
  }
  
  static var nameByteRange: Range<Int> { return 240..<250 }

  // save as single mode edit buffer patch. 16 deviceId is OMNI
  func fileData() -> Data {
    return sysexData(deviceId: 16, bank: 0, part: 0x40)
  }

}

class VirusTIVoicePatch : VirusVoicePatch {

  class var bankType: SysexPatchBank.Type { return VirusTIVoiceBank.self }
    
  static let initFileName = "virusti-voice-init"
  static let fileDataCount = 524

  var bytes: [UInt8]

  required init(data: Data) {
    // get 513 bytes (checksum is in the middle
    let b = data.safeBytes(9..<522)
    bytes = [UInt8](b[0..<256] + b[257..<513])
  }
    
  func sysexData(deviceId: UInt8, bank: UInt8, part: UInt8) -> Data {
    var data = Data(VirusTI.sysexHeader)
    var b1 = [deviceId, 0x10, bank, part] // these are included in checksum1
    b1.append(contentsOf: bytes[0..<256])
    // b1 holds deviceId + command header + bytes 0..<256
    data.append(contentsOf: b1)
    
    // checksum1
    let checksum1 = b1.map{ Int($0) }.reduce(0, +) & 0x7f
    var b2 = [UInt8(checksum1)]
    b2.append(contentsOf: bytes[256..<512])
    // b2 holds checksum1 + bytes 256..<512
    data.append(contentsOf: b2)
    
    // checksum2
    let checksum2 = (checksum1 + b2.map{ Int($0) }.reduce(0, +)) & 0x7f
    data.append(UInt8(checksum2))

    data.append(0xf7)
    return data
  }
  
  subscript(path: SynthPath) -> Int? {
    get {
      switch path {
      case [.arp, .mode]:
          // first look at TI arp mode byte. if 0, return C arp mode byte
        let ti = Int(bytes[143])
        let c = Int(bytes[129])
        return ti == 0 ? c : ti
      default:
        guard let param = Self.params[path] else { return nil }
        return unpack(param: param)
      }
    }
    set {
      guard let param = Self.params[path],
        let newValue = newValue else { return }
      switch path {
      case [.arp, .mode]:
          // first look at TI arp mode byte. if 0, return C arp mode byte
        bytes[143] = UInt8(newValue)
        bytes[129] = 0 // zero-out the C arp mode byte
      default:
        pack(value: newValue, forParam: param)
      }
    }
  }

//  subscript(path: SynthPath) -> Int? {
//    get {
//      guard let v = rawValue(path: path) else { return nil }
//      switch path {
//      case [.i(0), .wave], [.i(1), .wave]:
//        let inst = v.bits(0...7)
//        let set = v.bits(8...12)
//        return Self.reverseInstMap[set]?[inst] ?? 0
//      default:
//        return v
//      }
//    }
//    set {
//      guard let param = type(of: self).params[path],
//        let newValue = newValue else { return }
//      let off = param.parm * 2
//      switch path {
//      case [.i(0), .wave], [.i(1), .wave]:
//        guard newValue < Self.instMap.count else { return }
//        let item = Self.instMap[newValue]
//        let v = 0.set(bits: 0...7, value: item.inst).set(bits: 8...12, value: item.set)
//        bytes[off] = UInt8(v.bits(0...6))
//        bytes[off + 1] = UInt8(v.bits(7...13))
//      default:
//        bytes[off] = UInt8(newValue.bits(0...6))
//        bytes[off + 1] = UInt8(newValue.bits(7...13))
//      }
//    }
//  }
  
  
  // TODO
  func randomize() {
//    randomizeAllParams()
//
//    self[[.vocoder, .mode]] = 0
//    self[[.volume]] = 127
//    self[[.osc, .i(0), .keyTrk]] = 96
//    self[[.osc, .i(1), .keyTrk]] = 96
//    self[[.arp, .mode]] = 0
//
//    self[[.loop]] = 0 // atomizer off
    
    let keys: [SynthPath] = [
      [.osc, .i(0), .shape],
      [.osc, .i(0), .pw],
      [.osc, .i(0), .wave],
      [.osc, .i(1), .shape],
      [.osc, .i(1), .pw],
      [.osc, .i(1), .wave],
      [.osc, .i(1), .semitone],
      [.osc, .i(1), .detune],
      [.fm, .amt],
      [.osc, .i(0), .sync],
      [.filter, .env, .pitch],
      [.filter, .env, .fm],
      [.osc, .balance],
      [.sub, .level],
      [.sub, .shape],
//      [.osc, .level],
      [.noise, .level],
      [.noise, .color],
      [.filter, .i(0), .cutoff],
      [.filter, .i(1), .cutoff],
      [.filter, .reson],
      [.filter, .reson, .extra],
      [.filter, .env, .amt],
      [.filter, .env, .extra],
      [.filter, .keyTrk],
      [.filter, .keyTrk, .extra],
      [.filter, .balance],
      [.saturation, .type],
      [.ringMod, .level],
      [.filter, .i(0), .mode],
      [.filter, .i(1), .mode],
      [.filter, .routing],
      [.filter, .env, .attack],
      [.filter, .env, .decay],
      [.filter, .env, .sustain],
      [.filter, .env, .sustain, .slop],
      [.filter, .env, .release],
      [.amp, .env, .attack],
      [.amp, .env, .decay],
      [.amp, .env, .sustain],
      [.amp, .env, .sustain, .slop],
      [.amp, .env, .release],

      [.lfo, .i(0), .rate],
      [.lfo, .i(0), .shape],
      [.lfo, .i(0), .env, .mode],
      [.lfo, .i(0), .mode],
      [.lfo, .i(0), .curve],
      [.lfo, .i(0), .keyTrk],
      [.lfo, .i(0), .trigger],
      [.lfo, .i(0), .osc],
      [.lfo, .i(0), .osc, .i(1)],
      [.lfo, .i(0), .pw],
      [.lfo, .i(0), .filter, .reson],
      [.lfo, .i(0), .filter, .env],
      [.lfo, .i(1), .rate],
      [.lfo, .i(1), .shape],
      [.lfo, .i(1), .env, .mode],
      [.lfo, .i(1), .mode],
      [.lfo, .i(1), .curve],
      [.lfo, .i(1), .keyTrk],
      [.lfo, .i(1), .trigger],
      [.lfo, .i(1), .osc, .shape],
      [.lfo, .i(1), .fm],
      [.lfo, .i(1), .cutoff],
      [.lfo, .i(1), .cutoff, .i(1)],
      [.lfo, .i(1), .pan],

      [.osc, .key, .mode],

      [.chorus, .mix],
      [.chorus, .rate],
      [.chorus, .depth],
      [.chorus, .delay],
      [.chorus, .feedback],
      [.chorus, .shape],

      [.delay, .mode],
      [.delay, .send],
      [.delay, .time],
      [.delay, .feedback],
      [.delay, .rate],
      [.delay, .depth],
      [.delay, .shape],
      [.delay, .color],

      [.lfo, .i(2), .rate],
      [.lfo, .i(2), .shape],
      [.lfo, .i(2), .mode],
      [.lfo, .i(2), .keyTrk],
      [.lfo, .i(2), .dest],
      [.lfo, .i(2), .dest, .amt],
      [.lfo, .i(2), .fade],

      [.tempo],

      [.lfo, .i(0), .clock],
      [.lfo, .i(1), .clock],
      [.delay, .clock],
      [.lfo, .i(2), .clock],

      [.filter, .i(0), .env, .polarity],
      [.filter, .i(1), .env, .polarity],
      [.filter, .cutoff, .link],
      [.filter, .keyTrk, .start],
      [.fm, .mode],
      [.osc, .innit, .phase],
      [.osc, .pushIt],

      [.osc, .i(2), .mode],
      [.osc, .i(2), .level],
      [.osc, .i(2), .semitone],
      [.osc, .i(2), .fine],
      [.eq, .lo, .freq],
      [.eq, .hi, .freq],
      [.osc, .i(0), .shape, .velo],
      [.osc, .i(1), .shape, .velo],
      [.velo, .pw],
      [.velo, .fm],

      [.velo, .filter, .i(0), .env],
      [.velo, .filter, .i(1), .env],
      [.velo, .filter, .i(0), .reson],
      [.velo, .filter, .i(1), .reson],

      [.velo, .volume],
//      [.velo, .pan],

      [.phase, .mode],
      [.phase, .mix],
      [.phase, .rate],
      [.phase, .depth],
      [.phase, .freq],
      [.phase, .feedback],
      [.phase, .pan],
      [.eq, .mid, .gain],
      [.eq, .mid, .freq],
      [.eq, .mid, .q],
      [.eq, .lo, .gain],
      [.eq, .hi, .gain],
      [.character, .amt],
      [.character, .tune],

      [.dist, .type],
      [.dist, .amt],

      [.reverb, .mode],
      [.reverb, .send],
      [.reverb, .type],
      [.reverb, .time],
      [.reverb, .redamper],
      [.reverb, .color],
      [.reverb, .delay],
      [.reverb, .clock],
      [.reverb, .feedback],
      [.delay, .type],
      [.delay, .ratio],
      [.delay, .clock, .left],
      [.delay, .clock, .right],
      [.delay, .bw],

      [.freq, .shift, .type],
      [.freq, .shift, .mix],
      [.freq, .shift, .freq],
      [.freq, .shift, .phase],
      [.freq, .shift, .left],
      [.freq, .shift, .right],
      [.freq, .shift, .reson],
      [.character, .type],

      [.osc, .i(0), .mode],
      [.osc, .i(1), .mode],
      [.osc, .i(0), .formant, .pan],
      [.osc, .i(0), .formant, .shift],
      [.osc, .i(0), .local, .detune],
      [.osc, .i(0), .int],
      [.osc, .i(1), .formant, .pan],
      [.osc, .i(1), .formant, .shift],
      [.osc, .i(1), .local, .detune],
      [.osc, .i(1), .int],
      [.dist, .booster],
      [.dist, .hi, .cutoff],
      [.dist, .mix],
      [.dist, .q],
      [.dist, .tone],

    ]
    keys.forEach {
      self[$0] = Self.param($0)?.randomize() ?? 0
    }
  }

  
  private static let _params: SynthPathParam = {
    var p = SynthPathParam()

    // byte and param directly correlate
    
    // byte 0 and 1
    // from bank:  09 00
    // post fetch: 0c 01
    
    // When byte 2 is 4, that seems to indicate that the patch doesn't have any funny business
    // when it's 1, there is funny business
    
//    p[[.]] = RangeParam(byte: 1)        // $_Single Patchmanagement/Flags
//    p[[.]] = RangeParam(byte: 2)        // $_Single Patchmanagement/Original Bank
//    p[[.]] = RangeParam(byte: 3)        // $_Single Patchmanagement/Original Patch
//    p[[.]] = RangeParam(byte: 4)        // $_CC/Foot Controller CC04
    p[[.porta]] = MisoParam.make(byte: 5, iso: noiseVolIso)        // $_Portamento
//    p[[.]] = RangeParam(byte: 6)        // $_CC/Data Slider CC06
//    p[[.]] = RangeParam(byte: 7)        // $_Part Volume
//    p[[.]] = RangeParam(byte: 8)        // $_CC/Balance CC08
//    p[[.]] = RangeParam(byte: 9)        // $_CC/MIDI Controller CC09
    p[[.pan]] = RangeParam(byte: 10, displayOffset: -64)        // $_Patch Panorama
//    p[[.]] = RangeParam(byte: 11)        // $_CC/Expression 11
//    p[[.]] = RangeParam(byte: 12)        // $_CC/MIDI Controller 12
//    p[[.]] = RangeParam(byte: 13)        // $_CC/MIDI Controller 13
//    p[[.]] = RangeParam(byte: 14)        // $_CC/MIDI Controller 14
//    p[[.]] = RangeParam(byte: 15)        // $_CC/MIDI Controller 15
//    p[[.]] = RangeParam(byte: 16)        // $_CC/MIDI Controller 16
    p[[.osc, .i(0), .shape]] = MisoParam.make(byte: 17, iso: oscShapeIso)        // $_Oscillator 1 Waveform Shape - x
    p[[.osc, .i(0), .pw]] = MisoParam.make(byte: 18, iso: pwIso)        // $_Oscillator 1 Pulsewidth - x
    p[[.osc, .i(0), .wave]] = MisoParam.make(byte: 19, maxVal: 63, iso: waveSelectIso)        // $_Oscillator 1 Wave Select - x
    p[[.osc, .i(0), .semitone]] = RangeParam(byte: 20, range: 16...112, displayOffset: -64)        // $_Oscillator 1 Detune In Semitones - x
    p[[.osc, .i(0), .keyTrk]] = MisoParam.make(byte: 21, iso: keyFollowIso)        // $_Oscillator 1 Keyfollow - x
    p[[.osc, .i(1), .shape]] = MisoParam.make(byte: 22, iso: oscShapeIso)        // $_Oscillator 2 Shape - x
    p[[.osc, .i(1), .pw]] = MisoParam.make(byte: 23, iso: pwIso)        // $_Oscillator 2 Pulsewidth - x
    p[[.osc, .i(1), .wave]] = MisoParam.make(byte: 24, maxVal: 63, iso: waveSelectIso)        // $_Oscillator 2 Wave Select - x
    p[[.osc, .i(1), .semitone]] = RangeParam(byte: 25, range: 16...112, displayOffset: -64)        // $_Oscillator 2 Detune In Semitones - x
    p[[.osc, .i(1), .detune]] = RangeParam(byte: 26)        // $_Oscillator 2 Fine Detune - x
    p[[.fm, .amt]] = MisoParam.make(byte: 27, iso: fullPercIso)        // $_FM Amount - x
    p[[.osc, .i(0), .sync]] = RangeParam(byte: 28)        // $_Oscillator 1 Sync - x
    p[[.filter, .env, .pitch]] = MisoParam.make(byte: 29, iso: bipolarPercIso)        // $_Filter Envelope --> Pitch - x
    p[[.filter, .env, .fm]] = MisoParam.make(byte: 30, iso: bipolarPercIso)        // $_Filter Envelope --> FM - x
    p[[.osc, .i(1), .keyTrk]] = MisoParam.make(byte: 31, iso: keyFollowIso)        // $_Oscillator 2 Keyfollow - x
    p[[.osc, .balance]] = MisoParam.make(byte: 33, iso: bipolarPercIso)        // $_Oscillator Balance - x
    p[[.sub, .level]] = RangeParam(byte: 34)        // $_Sub Oscillator Volume - x
    p[[.sub, .shape]] = MisoParam.make(byte: 35, options: ["Square", "Triangle"])        // $_Sub Oscillator Waveform Shape - x
    p[[.osc, .level]] = RangeParam(byte: 36, displayOffset: -64)        // $_Oscillator Section Volume - x
    p[[.noise, .level]] = MisoParam.make(byte: 37, iso: noiseVolIso)        // $_Noise Oscillator Volume - x
    p[[.noise, .color]] = RangeParam(byte: 39, displayOffset: -64)        // $_Noise Color - x
    p[[.filter, .i(0), .cutoff]] = RangeParam(byte: 40)        // $_Filter 1 Cutoff - x
    p[[.filter, .i(1), .cutoff]] = RangeParam(byte: 41)        // $_Filter 2 Cutoff - x
    p[[.filter, .reson]] = RangeParam(byte: 42)        // $_Filter Resonance 1+2 - x
    p[[.filter, .reson, .extra]] = RangeParam(byte: 43)        // $_Filters/Resonance Helper - x
    p[[.filter, .env, .amt]] = MisoParam.make(byte: 44, iso: fullPercIso)        // $_Filter Envelope Amount 1+2 - x
    p[[.filter, .env, .extra]] = MisoParam.make(byte: 45, iso: fullPercIso)        // $_Filters/Envelope Helper - x
    p[[.filter, .keyTrk]] = RangeParam(byte: 46, displayOffset: -64)        // $_Filter Keyfollow 1+2 - x
    p[[.filter, .keyTrk, .extra]] = RangeParam(byte: 47, displayOffset: -64)        // $_Filters/Keyfollow Helper - x
    p[[.filter, .balance]] = RangeParam(byte: 48, displayOffset: -64)        // $_Filter Balance - x
    p[[.saturation, .type]] = MisoParam.make(byte: 49, options: ["Off", "Light", "Soft", "Middle", "Hard", "Digital", "Waveshaper", "Rectifier", "Bit Reducer", "Rate Reducer", "Rate+Follow", "Low Pass", "Low+Follow", "High Pass", "High+Follow"])        // $_Voice Saturation Type - x
    p[[.ringMod, .level]] = MisoParam.make(byte: 50, iso: noiseVolIso)        // $_Ring Modulator Volume - x
    p[[.filter, .i(0), .mode]] = MisoParam.make(byte: 51, options: ["Low Pass", "Hi Pass", "Band Pass", "Band Stop", "Analog 1 Pole", "Analog 2 Pole", "Analog 3 Pole", "Analog 4 Pole"])        // $_Filter 1 Mode - x
    p[[.filter, .i(1), .mode]] = MisoParam.make(byte: 52, options: ["Low Pass", "Hi Pass", "Band Pass", "Band Stop"])        // $_Filter 2 Mode - x
    p[[.filter, .routing]] = MisoParam.make(byte: 53, options: ["Serial 4", "Serial 6", "Parallel 4", "Split Mode"])        // $_Filter Routing - x
    p[[.filter, .env, .attack]] = RangeParam(byte: 54)        // $_Filter Envelope Attack - x
    p[[.filter, .env, .decay]] = RangeParam(byte: 55)        // $_Filter Envelope/Decay - x
    p[[.filter, .env, .sustain]] = MisoParam.make(byte: 56, iso: fullPercIso)        // $_Filter Envelope/Sustain - x
    p[[.filter, .env, .sustain, .slop]] = RangeParam(byte: 57, displayOffset: -64)        // $_Filter Envelope/Sustain Slope - x
    p[[.filter, .env, .release]] = RangeParam(byte: 58)        // $_Filter Envelope/Release - x
    p[[.amp, .env, .attack]] = RangeParam(byte: 59)        // $_Amplifier Envelope/Attack - x
    p[[.amp, .env, .decay]] = RangeParam(byte: 60)        // $_Amplifier Envelope/Decay - x
    p[[.amp, .env, .sustain]] = MisoParam.make(byte: 61, iso: fullPercIso)        // $_Amplifier Envelope/Sustain - x
    p[[.amp, .env, .sustain, .slop]] = RangeParam(byte: 62, displayOffset: -64)        // $_Amplifier Envelope/Sustain Slope - x
    p[[.amp, .env, .release]] = RangeParam(byte: 63)        // $_Amplifier Envelope/Release - x
//    p[[.]] = RangeParam(byte: 64)        // $_CC/Hold Pedal 64
//    p[[.]] = RangeParam(byte: 65)        // $_CC/Portamento Pedal 65
//    p[[.]] = RangeParam(byte: 66)        // $_CC/Sostenuto Pedal 66
    p[[.lfo, .i(0), .rate]] = RangeParam(byte: 67)        // $_LFO 1/Rate - x
    p[[.lfo, .i(0), .shape]] = MisoParam.make(byte: 68, maxVal: 67, iso: lfoShapeIso)        // $_LFO 1/Waveform Shape - x
    p[[.lfo, .i(0), .env, .mode]] = RangeParam(byte: 69, maxVal: 1)        // $_LFO 1 Envelope Mode - x
    p[[.lfo, .i(0), .mode]] = MisoParam.make(byte: 70, options: ["Poly", "Mono"])        // $_LFO 1 Mode - x
    p[[.lfo, .i(0), .curve]] = RangeParam(byte: 71, displayOffset: -64)        // $_LFO 1/Waveform Contour - x
    p[[.lfo, .i(0), .keyTrk]] = MisoParam.make(byte: 72, iso: fullPercIso)        // $_LFO 1 Keyfollow - x
    p[[.lfo, .i(0), .trigger]] = MisoParam.make(byte: 73, iso: noiseVolIso)        // $_LFO 1 Trigger Phase - x
    p[[.lfo, .i(0), .osc]] = MisoParam.make(byte: 74, iso: bipolarPercIso)        // $_LFO 1 --> Osc 1+2 - x
    p[[.lfo, .i(0), .osc, .i(1)]] = MisoParam.make(byte: 75, iso: bipolarPercIso)        // $_LFO 1 --> Osc 2 - x
    p[[.lfo, .i(0), .pw]] = MisoParam.make(byte: 76, iso: bipolarPercIso)        // $_LFO 1 --> Pulsewidth - x
    p[[.lfo, .i(0), .filter, .reson]] = MisoParam.make(byte: 77, iso: bipolarPercIso)        // $_LFO 1 -->Filter Resonance 1+2 - x
    p[[.lfo, .i(0), .filter, .env]] = MisoParam.make(byte: 78, iso: bipolarPercIso)        // $_LFO 1 --> Filter Envelope Gain - x
    p[[.lfo, .i(1), .rate]] = RangeParam(byte: 79)        // $_LFO 2/Rate - x
    p[[.lfo, .i(1), .shape]] = MisoParam.make(byte: 80, maxVal: 67, iso: lfoShapeIso)        // $_LFO 2/Waveform Shape - x
    p[[.lfo, .i(1), .env, .mode]] = RangeParam(byte: 81, maxVal: 1)        // $_LFO 2/Envelope Mode - x
    p[[.lfo, .i(1), .mode]] = MisoParam.make(byte: 82, options: ["Poly", "Mono"])        // $_LFO 2 Mode - x
    p[[.lfo, .i(1), .curve]] = RangeParam(byte: 83, displayOffset: -64)        // $_LFO 2 Waveform Contour - x
    p[[.lfo, .i(1), .keyTrk]] = MisoParam.make(byte: 84, iso: fullPercIso)        // $_LFO 2/Keyfollow - x
    p[[.lfo, .i(1), .trigger]] = MisoParam.make(byte: 85, iso: noiseVolIso)        // $_LFO 2/Trigger Phase - x
    p[[.lfo, .i(1), .osc, .shape]] = MisoParam.make(byte: 86, iso: bipolarPercIso)        // $_LFO 2 --> Shape 1+2 - x
    p[[.lfo, .i(1), .fm]] = MisoParam.make(byte: 87, iso: bipolarPercIso)        // $_LFO 2 --> FM Amount - x
    p[[.lfo, .i(1), .cutoff]] = MisoParam.make(byte: 88, iso: bipolarPercIso)        // $_LFO 2 --> Cutoff 1+2 - x
    p[[.lfo, .i(1), .cutoff, .i(1)]] = MisoParam.make(byte: 89, iso: bipolarPercIso)        // $_LFO 2 --> Cutoff 2 - x
    p[[.lfo, .i(1), .pan]] = MisoParam.make(byte: 90, iso: bipolarPercIso)        // $_LFO 2 --> Panorama - x
    p[[.volume]] = RangeParam(byte: 91)        // $_Patch Volume - x
    p[[.transpose]] = RangeParam(byte: 93, displayOffset: -64)        // $_Patch Transposition - x
    p[[.osc, .key, .mode]] = MisoParam.make(byte: 94, options: ["Poly", "Mono 1", "Mono 2", "Mono 3", "Mono 4", "Hold"])        // $_Oscillator Section Keyboard Mode - x
    p[[.chorus, .type]] = MisoParam.make(byte: 103, options: ["Off", "Classic", "Vintage", "Hyper", "Air", "Vibrato", "Rotary"])        // $_Chorus/Type - x
    p[[.chorus, .amt]] = RangeParam(byte: 104)        // $_Chorus/Mix - x
    p[[.chorus, .mix]] = RangeParam(byte: 105)        // $_Chorus/Mix - x
    p[[.chorus, .rate]] = RangeParam(byte: 106)        // $_Chorus/LFO Rate - x
    p[[.chorus, .depth]] = MisoParam.make(byte: 107, iso: fullPercIso)        // $_Chorus/LFO Depth - x
    p[[.chorus, .delay]] = RangeParam(byte: 108)        // $_Chorus/Delay - x
    p[[.chorus, .feedback]] = MisoParam.make(byte: 109, iso: bipolarPercIso)        // $_Chorus/Feedback - x
    p[[.chorus, .shape]] = MisoParam.make(byte: 110, options: delayLFOWaveOptions)        // $_Chorus/LFO Shape - x
    p[[.chorus, .cross]] = RangeParam(byte: 111)        // $_Chorus/X Over - x

    p[[.delay, .mode]] = MisoParam.make(byte: 112, options: delayModeOptions, startIndex: 1)        // $_Delay Mode - x
    p[[.delay, .send]] = MisoParam.make(byte: 113, iso: delaySendIso)        // $_Delay Send - x
    p[[.delay, .time]] = MisoParam.make(byte: 114, iso: delayTimeIso)        // $_Delay Time (ms) - x
    p[[.delay, .feedback]] = MisoParam.make(byte: 115, iso: fullPercIso)        // $_Delay Feedback - x. ACTUALLY depends on mode
    p[[.delay, .rate]] = RangeParam(byte: 116)        // $_Delay LFO Rate - x
    p[[.delay, .depth]] = MisoParam.make(byte: 117, iso: fullPercIso)        // $_Delay LFO Depth - x
    p[[.delay, .shape]] = MisoParam.make(byte: 118, options: delayLFOWaveOptions)        // $_Delay LFO Shape - x
    p[[.delay, .color]] = RangeParam(byte: 119, displayOffset: -64)        // $_Delay Color - x
    p[[.local]] = RangeParam(byte: 122)        // $_CC/Local On (prob no sens on a desktop module)!
//    p[[.]] = RangeParam(byte: 123)        // $_CC/All Notes Off

    p[[.arp, .pattern]] = MisoParam.make(byte: 130, maxVal: 63, iso: arpPatternIso)        // $_Arpeggiator/Pattern - x
    p[[.arp, .range]] = RangeParam(byte: 131, maxVal: 3, displayOffset: 1)        // $_Arpeggiator Range In Octaves - x
    p[[.arp, .hold]] = RangeParam(byte: 132)        // $_Arpeggiator Hold Mode - x
    p[[.arp, .note, .length]] = MisoParam.make(byte: 133, iso: bipolarPercIso)        // $_Arpeggiator Note Length - x
    p[[.arp, .swing]] = MisoParam.make(byte: 134, iso: arpSwingIso)        // $_Arpeggiator Swing Factor - x
    p[[.lfo, .i(2), .rate]] = RangeParam(byte: 135)        // $_LFO 3/Rate - x
    p[[.lfo, .i(2), .shape]] = MisoParam.make(byte: 136, maxVal: 67, iso: lfoShapeIso)        // $_LFO 3/Waveform Shape - x
    p[[.lfo, .i(2), .mode]] = MisoParam.make(byte: 137, options: ["Poly", "Mono"])        // $_LFO 3 Mode - x
    p[[.lfo, .i(2), .keyTrk]] = MisoParam.make(byte: 138, iso: fullPercIso)        // $_LFO 3 Keyfollow - x
    p[[.lfo, .i(2), .dest]] = MisoParam.make(byte: 139, options: ["Osc 1 Pitch", "Osc 1+2 Pitch", "Osc 2 Pitch", "Osc 1 PW", "Osc 1+2 PW", "Osc 2 PW", "Sync Phase"])        // $_LFO 3 User Destination - x
    p[[.lfo, .i(2), .dest, .amt]] = MisoParam.make(byte: 140, iso: fullPercIso)        // $_LFO 3 User Destination Amount - x
    p[[.lfo, .i(2), .fade]] = RangeParam(byte: 141)        // $_LFO 3/Fade In Time - x
    // byte 142???
    p[[.arp, .mode]] = MisoParam.make(byte: 143, options: ["Off", "Up", "Down", "Up&Down", "As Played", "Random", "Chord", "Arp>Matrix"])        // $_Arpeggiator/Mode - x
    p[[.tempo]] = RangeParam(byte: 144, displayOffset: 63)        // $_Tempo (Disabled When Used With Virus Control) - x
    p[[.arp, .clock]] = MisoParam.make(byte: 145, options: arpResolutionOptions, startIndex: 1)        // $_Arpeggiator Clock - ???? resolution?
    p[[.lfo, .i(0), .clock]] = MisoParam.make(byte: 146, options: lfoClockOptions)        // $_LFO 1/Clock - x
    p[[.lfo, .i(1), .clock]] = MisoParam.make(byte: 147, options: lfoClockOptions)        // $_LFO 2/Clock - x
    p[[.delay, .clock]] = MisoParam.make(byte: 148, options: delayClockOptions)        // $_Delay Clock - x
    p[[.lfo, .i(2), .clock]] = MisoParam.make(byte: 149, options: lfoClockOptions)        // $_LFO 3/Clock - x
    p[[.param, .smooth]] = MisoParam.make(byte: 153, options: smoothOptions)        // $_Parameter Smooth Mode - x
    p[[.bend, .up]] = RangeParam(byte: 154, displayOffset: -64)        // $_Bender Up Range - x
    p[[.bend, .down]] = RangeParam(byte: 155, displayOffset: -64)        // $_Bender Down Range - x
    p[[.bend, .scale]] = MisoParam.make(byte: 156, options: ["Linear", "Expon"])        // $_Bender Scale - x
    p[[.filter, .i(0), .env, .polarity]] = MisoParam.make(byte: 158, options: ["Negative", "Positive"])        // $_Filter 1 Envelope Polarity - x
    p[[.filter, .i(1), .env, .polarity]] = MisoParam.make(byte: 159, options: ["Negative", "Positive"])        // $_Filter 2 Polarity - x
    p[[.filter, .cutoff, .link]] = RangeParam(byte: 160)        // $_Filter Cutoff Link - x
    p[[.filter, .keyTrk, .start]] = MisoParam.make(byte: 161, iso: Miso.noteName(zeroNote: "C-1"))        // $_Filter Keyfollow Base - x
    p[[.fm, .mode]] = OptionsParam(byte: 162, options: ["Pos Tri", "Triangle", "Wave", "Noise", "In L", "In L+R", "In R"])        // $_FM Mode - x
    p[[.osc, .innit, .phase]] = MisoParam.make(byte: 163, iso: noiseVolIso)        // $_Oscillator Section Initial Phase - x
    p[[.osc, .pushIt]] = MisoParam.make(byte: 164, iso: fullPercIso)        // $_Oscillator Punch Intensity - x
    p[[.input, .follow]] = MisoParam.make(byte: 166, options: ["Off", "In L", "In L+R", "In R"])        // $_Input Follower/Select - x
    p[[.vocoder, .mode]] = MisoParam.make(byte: 167, options: vocoderModes)        // $_Vocoder Mode - x
    p[[.osc, .i(2), .mode]] = MisoParam.make(byte: 169, range: 0...67, iso: osc2WaveIso)        // $_Oscillator 3 Model - x
    p[[.osc, .i(2), .level]] = RangeParam(byte: 170)        // $_Oscillator 3 Volume - x
    p[[.osc, .i(2), .semitone]] = RangeParam(byte: 171, range: 16...112, displayOffset: -64)        // $_Oscillator 3 Detune In Semitone - x
    p[[.osc, .i(2), .fine]] = MisoParam.make(byte: 172, iso: Miso.switcher([.int(0, 0)], default: Miso.m(-1)) >>> Miso.str())        // $_Oscillator 3 Fine Detune - x
    p[[.eq, .lo, .freq]] = MisoParam.make(byte: 173, iso: loFreqIso)        // $_EQ/Low Frequency (Hz) - x
    p[[.eq, .hi, .freq]] = MisoParam.make(byte: 174, iso: hiFreqIso)        // $_EQ/High Frequency (kHz) - x
    p[[.osc, .i(0), .shape, .velo]] = MisoParam.make(byte: 175, iso: bipolarPercIso)        // $_Velocity -->Osc1 Waveform Shape - x
    p[[.osc, .i(1), .shape, .velo]] = MisoParam.make(byte: 176, iso: bipolarPercIso)        // $_Velocity --> Osc2 Waveform Shape - x
    p[[.velo, .pw]] = MisoParam.make(byte: 177, iso: bipolarPercIso)        // $_Velocity --> Pulsewidth - x
    p[[.velo, .fm]] = MisoParam.make(byte: 178, iso: bipolarPercIso)        // $_Velocity --> FM Amount - x
    p[[.knob, .i(0), .name]] = MisoParam.make(byte: 179, options: knobNames)        // $_Soft Knob 1 Name - x
    p[[.knob, .i(1), .name]] = MisoParam.make(byte: 180, options: knobNames)        // $_Soft Knob 2 Name - x
    p[[.knob, .i(2), .name]] = MisoParam.make(byte: 181, options: knobNames)        // $_Soft Knob 3 Name - x
    p[[.velo, .filter, .i(0), .env]] = MisoParam.make(byte: 182, iso: bipolarPercIso)        // $_Velocity --> Filter 1 Envelope Amount - x
    p[[.velo, .filter, .i(1), .env]] = MisoParam.make(byte: 183, iso: bipolarPercIso)        // $_Velocity --> Filter 2 Envelope Amount - x
    p[[.velo, .filter, .i(0), .reson]] = MisoParam.make(byte: 184, iso: bipolarPercIso)        // $_Velocity -->Filter 1 Resonance - x
    p[[.velo, .filter, .i(1), .reson]] = MisoParam.make(byte: 185, iso: bipolarPercIso)        // $_Velocity --> Filter 2 Resonance - x
    p[[.surround, .balance]] = RangeParam(byte: 186)        // $_Surround  Channel Balance - x
    // surround output doesn't seem to be in the patch?
    p[[.velo, .volume]] = MisoParam.make(byte: 188, iso: bipolarPercIso)        // $_Velocity --> Volume - x
    p[[.velo, .pan]] = MisoParam.make(byte: 189, iso: bipolarPercIso)        // $_Velocity --> Panorama - x
    p[[.knob, .i(0), .dest]] = MisoParam.make(byte: 190, options: knobOptions)        // $_Soft Knob 1 Destination - x
    p[[.knob, .i(1), .dest]] = MisoParam.make(byte: 191, options: knobOptions)        // $_Soft Knob 2 Destination - x

    p[[.mod, .i(0), .src]] = MisoParam.make(byte: 192, options: modSrcOptions)        // $_Mod Matrix Slot 1/Source - x
    p[[.mod, .i(0), .dest, .i(0)]] = MisoParam.make(byte: 193, options: modDestOptions)        // $_Mod Matrix Slot 1/Destination 1 - x
    p[[.mod, .i(0), .amt, .i(0)]] = RangeParam(byte: 194, displayOffset: -64)        // $_Mod Matrix Slot 1/Amount 1 - x
    p[[.mod, .i(1), .src]] = MisoParam.make(byte: 195, options: modSrcOptions)        // $_Mod Matrix Slot 2/Source - x
    p[[.mod, .i(1), .dest, .i(0)]] = MisoParam.make(byte: 196, options: modDestOptions)        // $_Mod Matrix Slot 2/Destination 1 - x
    p[[.mod, .i(1), .amt, .i(0)]] = RangeParam(byte: 197, displayOffset: -64)        // $_Mod Matrix Slot 2/Amount 1 - x
    p[[.mod, .i(1), .dest, .i(1)]] = MisoParam.make(byte: 198, options: modDestOptions)        // $_Mod Matrix Slot 2/Destination 2 - x
    p[[.mod, .i(1), .amt, .i(1)]] = RangeParam(byte: 199, displayOffset: -64)        // $_Mod Matrix Slot 2/Amount 2 - x
    p[[.mod, .i(2), .src]] = MisoParam.make(byte: 200, options: modSrcOptions)        // $_Mod Matrix Slot 3/Source - x
    p[[.mod, .i(2), .dest, .i(0)]] = MisoParam.make(byte: 201, options: modDestOptions)        // $_Mod Matrix Slot 3/Destination 1 - x
    p[[.mod, .i(2), .amt, .i(0)]] = RangeParam(byte: 202, displayOffset: -64)        // $_Mod Matrix Slot 3/Amount 1 - x
    p[[.mod, .i(2), .dest, .i(1)]] = MisoParam.make(byte: 203, options: modDestOptions)        // $_Mod Matrix Slot 3/Destination 2 - x
    p[[.mod, .i(2), .amt, .i(1)]] = RangeParam(byte: 204, displayOffset: -64)        // $_Mod Matrix Slot 3/Amount 2 - x
    p[[.mod, .i(2), .dest, .i(2)]] = MisoParam.make(byte: 205, options: modDestOptions)        // $_Mod Matrix Slot 3/Destination 3 - x
    p[[.mod, .i(2), .amt, .i(2)]] = RangeParam(byte: 206, displayOffset: -64)        // $_Mod Matrix Slot 3/Amount 3 - x

    p[[.lfo, .i(0), .dest]] = MisoParam.make(byte: 207, options: modDestOptions)        // $_LFO 1 User Destination - x
    p[[.lfo, .i(0), .dest, .amt]] = MisoParam.make(byte: 208, iso: bipolarPercIso)        // $_LFO 1 User Destination Amount - x
    p[[.lfo, .i(1), .dest]] = MisoParam.make(byte: 209, options: modDestOptions)        // $_LFO 2 User Destination - x
    p[[.lfo, .i(1), .dest, .amt]] = MisoParam.make(byte: 210, iso: bipolarPercIso)        // $_LFO 2 User Destination Amount - x
    p[[.phase, .mode]] = RangeParam(byte: 212, maxVal: 5, displayOffset: 1)        // $_Phaser/Stages - x
    p[[.phase, .mix]] = MisoParam.make(byte: 213, iso: noiseVolIso)        // $_Phaser/Mix - x
    p[[.phase, .rate]] = RangeParam(byte: 214)        // $_Phaser/LFO Rate - x
    p[[.phase, .depth]] = MisoParam.make(byte: 215, iso: fullPercIso)        // $_Phaser/Depth - x
    p[[.phase, .freq]] = RangeParam(byte: 216)        // $_Phaser/Frequency - x
    p[[.phase, .feedback]] = MisoParam.make(byte: 217, iso: bipolarPercIso)        // $_Phaser/Feedback - x
    p[[.phase, .pan]] = RangeParam(byte: 218)        // $_Phaser/Spread - x
    p[[.eq, .mid, .gain]] = MisoParam.make(byte: 220, iso: eqGainIso)        // $_EQ/Mid Gain (dB) - x
    p[[.eq, .mid, .freq]] = MisoParam.make(byte: 221, iso: midFreqIso)        // $_EQ/Mid Frequency (Hz) - x
    p[[.eq, .mid, .q]] = MisoParam.make(byte: 222, iso: midQIso)        // $_EQ/Mid Q-Factor - x
    p[[.eq, .lo, .gain]] = MisoParam.make(byte: 223, iso: eqGainIso)        // $_EQ/Low Gain (dB) - x
    p[[.eq, .hi, .gain]] = MisoParam.make(byte: 224, iso: eqGainIso)        // $_EQ/High Gain (dB) - x
    p[[.character, .amt]] = MisoParam.make(byte: 225, iso: fullPercIsoWOff)        // $_Character Intensity - x
    p[[.character, .tune]] = RangeParam(byte: 226)        // $_Character Tune - x
    p[[.ringMod, .mix]] = RangeParam(byte: 227)        // $_Ring Modulator Mix - x ??? FX don't seem to use it.
    p[[.dist, .type]] = MisoParam.make(byte: 228, options: distortModes)        // $_Distortion Type - x
    p[[.dist, .amt]] = MisoParam.make(byte: 229, iso: fullPercIso)        // $_Distortion Intensity - x
    p[[.mod, .i(3), .src]] = MisoParam.make(byte: 231, options: modSrcOptions)        // $_Mod Matrix Slot 4/Source - x
    p[[.mod, .i(3), .dest, .i(0)]] = MisoParam.make(byte: 232, options: modDestOptions)        // $_Mod Matrix Slot 4/Destination 1 - x
    p[[.mod, .i(3), .amt, .i(0)]] = RangeParam(byte: 233, displayOffset: -64)        // $_Assign Slot 4/Amount 1 - x
    p[[.mod, .i(4), .src]] = MisoParam.make(byte: 234, options: modSrcOptions)        // $_Mod Matrix Slot 5/Source - x
    p[[.mod, .i(4), .dest, .i(0)]] = MisoParam.make(byte: 235, options: modDestOptions)        // $_Mod Matrix Slot 5/Destination 1 - x
    p[[.mod, .i(4), .amt, .i(0)]] = RangeParam(byte: 236, displayOffset: -64)        // $_Mod Matrix Slot 5/Amount 1 - x
    p[[.mod, .i(5), .src]] = MisoParam.make(byte: 237, options: modSrcOptions)        // $_Mod Matrix Slot 6/Source - x
    p[[.mod, .i(5), .dest, .i(0)]] = MisoParam.make(byte: 238, options: modDestOptions)        // $_Mod Matrix Slot 6/Destination 1 - x
    p[[.mod, .i(5), .amt, .i(0)]] = RangeParam(byte: 239, displayOffset: -64)        // $_Mod Matrix Slot 6/Amount 1 - x
    p[[.filter, .select]] = MisoParam.make(byte: 250, options: ["Filter 1", "Filter 2", "Filter 1+2"])        // $_Filter Select - x
    p[[.category, .i(0)]] = MisoParam.make(byte: 251, options: categoryOptions)        // $_Patch Category 1 - x
    p[[.category, .i(1)]] = MisoParam.make(byte: 252, options: categoryOptions)        // $_Patch Category 2 - x
//    p[[.osc, .select]] = RangeParam(byte: 255)        // $_Oscillators/Select - ????

    p[[.reverb, .mode]] = MisoParam.make(byte: 257, options: reverbModeOptions, startIndex: 1)        // $_Reverb/Mode - x
    p[[.reverb, .send]] = MisoParam.make(byte: 258, iso: delaySendIso)        // $_Reverb/Send - x
    p[[.reverb, .type]] = MisoParam.make(byte: 259, options: reverbTypeOptions)        // $_Reverb/Type - x
    p[[.reverb, .time]] = RangeParam(byte: 260)        // $_Reverb/Time - x
    p[[.reverb, .redamper]] = MisoParam.make(byte: 261, iso: fullPercIso)        // $_Reverb/Damping - x
    p[[.reverb, .color]] = RangeParam(byte: 262, displayOffset: -64)        // $_Reverb/Color - x
    p[[.reverb, .delay]] = MisoParam.make(byte: 263, range: 0...92, iso: reverbPredelayIso)        // $_Reverb/Predelay - x
    p[[.reverb, .clock]] = MisoParam.make(byte: 264, options: delayClockOptions)        // $_Reverb/Clock - x
    p[[.reverb, .feedback]] = RangeParam(byte: 265)        // $_Reverb/Feedback - x
    p[[.delay, .type]] = MisoParam.make(byte: 266, options: ["Classic", "Tape Clked", "Tape Free", "Tape Dppl"])        // $_Delay Type - x
    p[[.delay, .ratio]] = MisoParam.make(byte: 268, options: delayRatioOptions)        // $_Delay Tape Delay Ratio - x
    p[[.delay, .clock, .left]] = MisoParam.make(byte: 269, options: delayLRClockOptions)        // $_Delay Tape Delay Clock Left - x
    p[[.delay, .clock, .right]] = MisoParam.make(byte: 270, options: delayLRClockOptions)        // $_Delay Tape Delay Clock Right - x
    p[[.delay, .bw]] = RangeParam(byte: 273)        // $_Delay Tape Delay Bandwidth - x
    p[[.freq, .shift, .type]] = MisoParam.make(byte: 275, options: ["Off", "Ring Mod", "Freq Shift", "Vowel Filter", "Comb Filter", "1 Pole XFade", "2 Pole XFade", "4 Pole XFade", "6 Pole XFade", "LP VariSlope", "HP VariSlope", "BP VariSlope"])        // $_Frequency Shifter Type - VOCODER???
    p[[.freq, .shift, .mix]] = MisoParam.make(byte: 276, iso: fullPercIso)        // $_Frequency Shifter Mix
    p[[.freq, .shift, .freq]] = RangeParam(byte: 277, displayOffset: -64)        // $_Frequency Shifter Frequency
    p[[.freq, .shift, .phase]] = RangeParam(byte: 278, displayOffset: -64)        // $_Frequency Shifter Stereo Phase
    p[[.freq, .shift, .left]] = MisoParam.make(byte: 279, iso: bipolarPercIso)        // $_Frequency Shifter Left Shape
    p[[.freq, .shift, .right]] = MisoParam.make(byte: 280, iso: bipolarPercIso)        // $_Frequency Shifter Right Shape
    p[[.freq, .shift, .reson]] = RangeParam(byte: 281, displayOffset: -64)        // $_Frequency Shifter Resonance
    p[[.character, .type]] = MisoParam.make(byte: 282, options: characterTypes)        // $_Character Type - x
    p[[.knob, .i(2), .dest]] = MisoParam.make(byte: 284, options: knobOptions)        // $_Soft Knob 3 Destination - x
    p[[.osc, .i(0), .mode]] = MisoParam.make(byte: 286, options: oscModelOptions)        // $_Oscillator 1 Model - x
    p[[.osc, .i(1), .mode]] = MisoParam.make(byte: 291, options: oscModelOptions)        // $_Oscillator 2 Model - x
    p[[.osc, .i(0), .formant, .pan]] = RangeParam(byte: 293)        // $_Oscillator 1 Formant Spread - x
    p[[.osc, .i(0), .formant, .shift]] = RangeParam(byte: 298, displayOffset: -64)        // $_Oscillator 1 Formant Shift - x
    p[[.osc, .i(0), .local, .detune]] = RangeParam(byte: 299)        // $_Oscillator 1 Local Detune - x
    p[[.osc, .i(0), .int]] = RangeParam(byte: 300)        // $_Oscillator 1 Interpolation - x
    p[[.osc, .i(1), .formant, .pan]] = RangeParam(byte: 313)        // $_Oscillator 2 Formant Spread - x
    p[[.osc, .i(1), .formant, .shift]] = RangeParam(byte: 318, displayOffset: -64)        // $_Oscillator 2 Formant Shift - x
    p[[.osc, .i(1), .local, .detune]] = RangeParam(byte: 319)        // $_Oscillator 2 Local Detune - x
    p[[.osc, .i(1), .int]] = RangeParam(byte: 320)        // $_Oscillator 2 Interpolation - x
    p[[.dist, .booster]] = MisoParam.make(byte: 326, iso: fullPercIso)        // $_Distortion Treble Booster - x
    p[[.dist, .hi, .cutoff]] = MisoParam.make(byte: 327, iso: fullPercIso)        // $_Distortion High Cut - x
    p[[.dist, .mix]] = MisoParam.make(byte: 328, iso: fullPercIso)        // $_Distortion Mix - x
    p[[.dist, .q]] = MisoParam.make(byte: 329, iso: fullPercIso)        // $_Distortion Quality - x
    p[[.dist, .tone]] = MisoParam.make(byte: 330, iso: bipolarPercIso)        // $_Distortion Tone W - x
        
    p[[.env, .i(2), .attack]] = RangeParam(byte: 336)
    p[[.env, .i(2), .decay]] = RangeParam(byte: 337)
    p[[.env, .i(2), .sustain]] = MisoParam.make(byte: 338, iso: fullPercIso)
    p[[.env, .i(2), .sustain, .slop]] = RangeParam(byte: 339, displayOffset: -64)
    p[[.env, .i(2), .release]] = RangeParam(byte: 340)
    p[[.env, .i(3), .attack]] = RangeParam(byte: 341)
    p[[.env, .i(3), .decay]] = RangeParam(byte: 342)
    p[[.env, .i(3), .sustain]] = MisoParam.make(byte: 343, iso: fullPercIso)
    p[[.env, .i(3), .sustain, .slop]] = RangeParam(byte: 344, displayOffset: -64)
    p[[.env, .i(3), .release]] = RangeParam(byte: 345)
    
    p[[.mod, .i(0), .dest, .i(1)]] = MisoParam.make(byte: 346, options: modDestOptions)        // $_Mod Matrix Slot 1/Destination 2 - x
    p[[.mod, .i(0), .amt, .i(1)]] = RangeParam(byte: 347, displayOffset: -64)        // $_Mod Matrix Slot 1/Amount 2 - x
    p[[.mod, .i(0), .dest, .i(2)]] = MisoParam.make(byte: 348, options: modDestOptions)        // $_Mod Matrix Slot 1/Destination 3 - x
    p[[.mod, .i(0), .amt, .i(2)]] = RangeParam(byte: 349, displayOffset: -64)        // $_Mod Matrix Slot 1/Amount 3 - x
    p[[.mod, .i(1), .dest, .i(2)]] = MisoParam.make(byte: 350, options: modDestOptions)        // $_Mod Matrix Slot 2/Destination 3 - x
    p[[.mod, .i(1), .amt, .i(2)]] = RangeParam(byte: 351, displayOffset: -64)        // $_Mod Matrix Slot 2/Amount 3 - x
    p[[.mod, .i(3), .dest, .i(1)]] = MisoParam.make(byte: 352, options: modDestOptions)        // $_Mod Matrix Slot 4/Destination 2 - x
    p[[.mod, .i(3), .amt, .i(1)]] = RangeParam(byte: 353, displayOffset: -64)        // $_Assign Slot 4/Amount 2 - x
    p[[.mod, .i(3), .dest, .i(2)]] = MisoParam.make(byte: 354, options: modDestOptions)        // $_Mod Matrix Slot 4/Destination 3 - x
    p[[.mod, .i(3), .amt, .i(2)]] = RangeParam(byte: 355, displayOffset: -64)        // $_Mod Matrix Slot 4/Amount 3 - x
    p[[.mod, .i(4), .dest, .i(1)]] = MisoParam.make(byte: 356, options: modDestOptions)        // $_Mod Matrix Slot 5/Destination 2 - x
    p[[.mod, .i(4), .amt, .i(1)]] = RangeParam(byte: 357, displayOffset: -64)        // $_Mod Matrix Slot 5/Amount 2 - x
    p[[.mod, .i(4), .dest, .i(2)]] = MisoParam.make(byte: 358, options: modDestOptions)        // $_Mod Matrix Slot 5/Destination 3 - x
    p[[.mod, .i(4), .amt, .i(2)]] = RangeParam(byte: 359, displayOffset: -64)        // $_Mod Matrix Slot 5/Amount 3 - x
    p[[.mod, .i(5), .dest, .i(1)]] = MisoParam.make(byte: 360, options: modDestOptions)        // $_Mod Matrix Slot 6/Destination 2 - x
    p[[.mod, .i(5), .amt, .i(1)]] = RangeParam(byte: 361, displayOffset: -64)        // $_Mod Matrix Slot 6/Amount 2 - x
    p[[.mod, .i(5), .dest, .i(2)]] = MisoParam.make(byte: 362, options: modDestOptions)        // $_Mod Matrix Slot 6/Destination 3 - x
    p[[.mod, .i(5), .amt, .i(2)]] = RangeParam(byte: 363, displayOffset: -64)        // $_Mod Matrix Slot 6/Amount 3 - x
//    p[[.lfo, .i(0), .backup, .shape]] = RangeParam(byte: 366)        // $_LFO 1/BackupShape
//    p[[.lfo, .i(1), .backup, .shape]] = RangeParam(byte: 367)        // $_LFO 2/BackupShape
//    p[[.lfo, .i(2), .backup, .shape]] = RangeParam(byte: 368)        // $_LFO 3/BackupShape
//    p[[.assign, .select]] = RangeParam(byte: 371)        // $_Assigns/Slot Select
//    p[[.lfo, .select]] = RangeParam(byte: 372)        // $_LFOs/Select
//    p[[.fx, .hi, .select]] = RangeParam(byte: 373)        // $_FX Upper/Select
//    p[[.fx, .lo, .select]] = RangeParam(byte: 374)        // $_FX Lower/Select
//    p[[.osc, .backup, .key, .mode]] = RangeParam(byte: 378)        // $_Oscillators/BackupKeyMode
//    p[[.arp, .backup, .mode]] = RangeParam(byte: 379)        // $_Arpeggiator/BackupMode
//    p[[.osc, .i(2), .backup, .mode]] = RangeParam(byte: 380)        // $_Oscillator 3/BackupMode
    p[[.arp, .pattern, .length]] = RangeParam(byte: 383, maxVal: 31, displayOffset: 1)        // $_Arpeggiator Pattern Length

    (0..<32).forEach {
      let off = $0 * 3
      p[[.arp, .i($0), .length]] = RangeParam(byte: 384 + off)        // $_Step 1 Length
      p[[.arp, .i($0), .velo]] = RangeParam(byte: 385 + off)        // $_Step 1 Velocity
      p[[.arp, .i($0), .on]] = RangeParam(byte: 386 + off)        // $_*
    }
    p[[.unison, .mode]] = MisoParam.make(byte: 504, range: 0...7, iso: VirusCVoicePatch.unisonModeIso)        // $_Unison Mode - x
    p[[.unison, .detune]] = RangeParam(byte: 505)        // $_Unison Detune - x
    p[[.unison, .pan]] = MisoParam.make(byte: 506, iso: fullPercIso)        // $_Unison Panorama Spread - x
    p[[.unison, .phase]] = RangeParam(byte: 507, displayOffset: -64)        // $_Unison LFO Phase Offset - x
    p[[.input, .mode]] = MisoParam.make(byte: 508, options: ["Off", "Dynamic", "Static"])        // $_Input Mode - x
    p[[.input, .select]] = MisoParam.make(byte: 509, options: ["Left", "L + R", "Right"])        // $_Input Select - x
    p[[.loop]] = MisoParam.make(byte: 510, maxVal: 16, iso: atomizerIso)        // $_Atomizer - x

    return p
  }()
  
  class var params: SynthPathParam { return _params }
  
  static let oscModelOptions = ["Classic", "HyperSaw", "Wavetable", "Wave PWM", "Grain Simple", "Grain Complex", "Formant Simple", "Formant Complex"]
  
  static let oscShapeIso = Miso.switcher([
    .int(0, "Wave"),
    .range(1...63, Miso.m(100/64) >>> Miso.round() >>> Miso.str("%g%% W>S")),
    .int(64, "Saw"),
    .range(65...126, Miso.a(-64) >>> Miso.m(100/64) >>> Miso.round() >>> Miso.str("%g%% S>P")),
    .int(127, "Pulse"),
  ])

  static let pwIso = Miso.d(127) >>> Miso.unitLerp(0.5...1) >>> tenthPercIso
  
  static let waveSelectIso = Miso.switcher([
    .int(0, "Sine"),
    .int(1, "Triangle"),
  ], default: Miso.a(1) >>> Miso.str("Wave %g"))
  
  static let osc2WaveIso = Miso.switcher([
    .int(0, "Off"),
    .int(1, "Slave"),
    .int(2, "Saw"),
    .int(3, "Pulse"),
    .int(4, "Sine"),
    .int(5, "Triangle"),
  ], default: Miso.a(-3) >>> Miso.str("Wave %g"))

  static let keyFollowIso = Miso.switcher([
    .int(96, "Norm")
  ], default: Miso.a(-64) >>> Miso.str())

  /// Map 0...1 to a % round to 1 dec place
  static let tenthPercIso = Miso.m(100) >>> Miso.round(1) >>> Miso.str("%g%%")
  
  static let fullPercIso = unitIso >>> tenthPercIso

  static let bipolarPercIso = unitLerp(-1...1) >>> tenthPercIso
  
  static let fullPercIsoWOff = Miso.switcher([
    .rangeString(0...0, "Off"),
  ], default: fullPercIso)
  
  static let perc200Iso = unitIso >>> Miso.m(2) >>> tenthPercIso
  
  static let noiseVolIso = Miso.switcher([
    .int(0, "Off")
  ], default: Miso.str())

  static let lfoShapeIso = Miso.switcher([
    .int(0, "Sine"),
    .int(1, "Triangle"),
    .int(2, "Saw"),
    .int(3, "Square"),
    .int(4, "S&H"),
    .int(5, "S&G"),
  ], default: Miso.a(-3) >>> Miso.str("Wave %g"))
  
  static let atomizerIso = Miso.switcher([
    .int(0, "Off"),
    .int(1, "On"),
  ], default: Miso.str())
  
  // map from 0...127 to 0...1 (the virus way)
  static let unitIso = Miso.switcher([.int(127, 1)], default: Miso.m(1/128))
  
  static func unitLerp(_ range: ClosedRange<Float>) -> Iso<Float, Float> {
    return unitIso >>> Miso.unitLerp(range)
  }
  
  static let eqGainIso = Miso.switcher([.int(64, "Off")], default: unitLerp(-16...16) >>> Miso.round(2) >>> Miso.str("%g dB"))
  
  static let delaySendIso = Miso.switcher([
    .int(0, "Off"),
    .range(1...35, Miso.ln() >>> Miso.m(8.6858) >>> Miso.a(-46.185) >>> Miso.round(1) >>> Miso.str("%g dB")),
    .range(36...95, Miso.m(0.25) >>> Miso.a(-24) >>> Miso.round(2) >>> Miso.str("%g dB")),
    .range(96...126, Miso.options([0, -0.3, -0.6, -0.9, -1.2, -1.5, -1.8, -2.1, -2.5, -2.9, -3.3, -3.7, -4.1, -4.5, -5, -5.5, -6, -6.6, -7.2, -7.8, -8.5, -9.3, -10.1, -11, -12, -13.2, -14.5, -16.1, -18.1, -20.6, -24], startIndex: 96) >>> Miso.str("0/%g dB")),
    .int(127, "Effect")
  ])
  
  static let delayTimeIso = Miso.m(5.4614173228) >>> Miso.round(1) >>> Miso.str("%g ms")

  static let reverbPredelayIso = Miso.switcher([.int(92, 500)], default: Miso.m(5.4614173228)) >>> Miso.round(1) >>> Miso.str("%g ms")
  
  static let loFreqIso = Miso.m(0.5) >>> Miso.floor() >>> Miso.m(0.04191964) >>> Miso.exp() >>> Miso.m(32.69248232) >>> Miso.a(-0.68997284) >>> Miso.round() >>> Miso.str()

  // a little off
  static let midFreqExpPartIso = Miso.m(0.05587764) >>> Miso.exp() >>> Miso.m(19.83282644) >>> Miso.a(-1.34511443)
  static let midFreqIso = Miso.switcher([
    .range(0...112, midFreqExpPartIso),
    .range(113...126, Miso.a(1) >>> midFreqExpPartIso),
    .int(127, 24000)
  ]) >>> Miso.round() >>> Miso.str()
  
  static let midQIso = Miso.switcher([
    .range(0...16, Miso.m(0.0106214427002507) >>> Miso.a(0.277336468944884)),
    .range(17...32, Miso.m(0.0163613868730386) >>> Miso.a(0.182936230077398)),
    .range(33...48, Miso.m(0.0113806676777093) >>> Miso.a(0.345343618929774)),
    .range(49...63, Miso.m(0.0430731688188778) >>> Miso.a(-1.17743337671029)),
    .range(64...79, Miso.m(0.0774705351108967) >>> Miso.a(-3.37664472031135)),
    .range(80...96, Miso.m(0.136813698962105) >>> Miso.a(-8.12372180820082)),
    .range(97...112, Miso.m(0.243824024403959) >>> Miso.a(-18.3971105934826)),
    .range(113...127, Miso.m(0.431214570166687) >>> Miso.a(-39.4044157591677)),
  ]) >>> Miso.round(2) >>> Miso.str()
  
  static let hiFreqIso = Miso.m(0.5) >>> Miso.floor() >>> Miso.m(4.18752638e-02) >>> Miso.exp() >>> Miso.m(1.83615763e+03) >>> Miso.a(-4.71797185e+00) >>> Miso.round() >>> Miso.str()

  static let freqShiftPolesIso = unitLerp(2...6) >>> Miso.round(2) >>> Miso.str()
  static let freqShiftFTypeIso = Miso.switcher([
    .int(0, "LP"),
    .int(64, "BP"),
    .int(127, "HP")
  ], default: Miso.str())
  
  static let oscDensityIso = Miso.switcher([
    .range(0...64, Miso.m(0.0309964160768649) >>> Miso.a(1.05119066190202)),
    .range(65...68, Miso.m(0.0998751397383792) >>> Miso.a(-3.39173934758308)),
    .range(69...73, Miso.m(0.0483287476928924) >>> Miso.a(0.147627189234737)),
    .range(74...80, Miso.m(0.0494096986612037) >>> Miso.a(0.0676368305753373)),
    .range(81...84, Miso.m(0.100006856833258) >>> Miso.a(-4.00050944576357)),
    .range(85...96, Miso.m(0.0489590010030881) >>> Miso.a(0.319206303112423)),
    .range(97...101, Miso.m(0.180041766883461) >>> Miso.a(-12.3441265253952)),
    .range(102...104, Miso.m(0.0499914852930645) >>> Miso.a(0.817464934300320)),
    .range(105...108, Miso.m(0.199910739509612) >>> Miso.a(-14.8904937865277)),
    .range(109...112, Miso.m(0.0699710423208910) >>> Miso.a(-0.806757604863247)),
    .range(113...116, Miso.m(0.199996226558739) >>> Miso.a(-15.4995913730911)),
    .range(117...120, Miso.m(0.0699877834673506) >>> Miso.a(-0.368534885309073)),
    .range(121...127, Miso.m(0.150003085632388) >>> Miso.a(-9.98610014923964)),
  ]) >>> Miso.round(1) >>> Miso.str()
  
  static let arpPatternIso = Miso.switcher([
    .int(0, "User")
  ], default: Miso.a(1) >>> Miso.str())
  
  static let arpSwingIso = Miso.switcher([
    .int(0, "Off"),
    .int(21, "16B"),
    .int(41, "16C"),
    .int(66, "16D"),
    .int(87, "16E"),
    .int(107, "16F"),
  ], default: unitLerp(50...75) >>> Miso.round(1) >>> Miso.str("%g%"))
  
  static let arpResolutionOptions = ["1/128", "1/64", "1/32", "1/16", "1/8", "1/4", "3/128", "3/64", "3/32", "3/16", "1/48", "1/24", "1/12", "1/6", "1/3", "3/8", "1/2"]

  static let wavetableOptions = ["Sine", "HarmncSweep", "Glass Sweep", "Draw Bars", "Clusters", "Insine Out", "Landing", "Liquid Metal", "Opposition", "Overtunes 1", "Overtunes 2", "Scale Trix", "sine Rider", "Sqr Series", "Upsine Down", "Thumbs Up", "Waterphone", "E-Chime", "Tinkabll", "Bellfizz", "Bellentine", "Robot WaFS", "Alternator", "Finger Bass", "Fizzybar", "Flutes", "HP Love", "Majestix", "Hotch Potch", "Resynater", "Smooth Rough", "Sawsalito", "Bells 1", "Bells 2", "SportReport", "Metal Guru", "Bat Cave", "Acetate", "Buzzbizz", "Buzzportout", "Vanish", "Ooverbones", "Pulsechecker", "Stratosfear", "Sooty Sweep", "Throoty", "Didgitalis", "Evil", "Chords", "FM Grit", "Bellsarnie", "Octavius", "Eat Pulse", "sinzin", "sine System", "clip Sweep", "Roughage", "waving", "Pling Saw", "E-Peas", "Bump Sweep", "Filter Sqr", "Fourmant", "Formantera", "Sundial 1", "Sundial 2", "Sundial 3", "Clipdial 1", "Clipdial 2", "Voxonix", "Solenoid", "Klingklang", "violator", "Potassium", "Pile Up", "Tincanali", "Sniper", "Squeezy", "Decomposer", "Morfants", "Fingvox", "Adenoids", "Nasal", "Partialism", "TableDance", "Cascade", "Prismism", "Friction", "Robotix", "Whizzfizz", "Spangly", "Fluxbin", "Fiboglide", "Fibonice", "Fibonasty", "Penetrator", "Blinder", "Element 5", "Bad Signs", "Domina7rix"]
  
  static let knobOptions = ["Off", "Mod Wheel", "Breath", "Ctrl 3", "Foot Pedal", "Data Entry", "Balance", "Ctrl 9", "Expression", "Ctrl 12", "Ctrl 13", "Ctrl 14", "Ctrl 15", "Ctrl 16", "Patch Volume", "Chan Volume", "Pan", "Transpose", "Porta", "Unison Detune", "Unison Spread", "Unison LFO Phase", "Chorus Mix", "Chorus Rate", "Chorus Depth", "Chorus Delay", "Chorus Feedback", "Effect Send (Delay)", "Delay Time", "Delay Feedbk", "Delay Rate", "Delay Depth", "Osc 1 Wave Select", "Osc 1 PW", "Osc 1 Pitch", "Osc 1 Keyfollow", "Osc 2 Wave Select", "Osc 2 PW", "F Env > Osc 2 Pitch", "F Env > FM Amt", "Osc 2 Keyfollow", "Noise Volume", "F1 Reson", "F2 Reson", "F1 Env Amt", "F2 Env Amt", "F1 Keyfollow", "F2 Keyfollow", "LFO 1 Contour", "LFO 1 > Osc 1", "LFO 1 > Osc 2", "LFO 1 > PW", "LFO 1 > Reson", "LFO 1 > Filter Gain", "LFO 2 Contour", "LFO 2 > Shape", "LFO 2 > FM Amt", "LFO 2 > Cutoff 1", "LFO 2 > Cutoff 2", "LFO 2 > Pan", "LFO 3 Rate", "LFO 3 Assign Amt", "Bend Up", "Bend Down", "Aftertouch", "Velo > FM Amt", "Velo > F1 Env Amt", "Velo > F2 Env Amt", "Velo > Reson 1", "Velo > Reson 2", "Velo > Volume", "Velo > Pan", "Assign 1 Amt 1", "Assign 2 Amt 1", "Assign 2 Amt 2", "Assign 3 Amt 1", "Assign 3 Amt 2", "Assign 3 Amt 3", "Clock Tempo", "Input Thru", "Osc Init Phase", "Punch Intens", "Ring Mod", "Noise Color", "Delay Color", "Analog Boost Int", "Analog Boost Tune", "Dist Intens", "FreqShift Freq", "Osc 3 Volume", "Osc 3 Pitch", "Osc 3 Detune", "LFO 1 > Assign Amt", "LFO 2 > Assign Amt", "Phaser Mix", "Phaser Rate", "Phaser Depth", "Phaser Freq", "Phase Feedbk", "Phaser Spread", "Reverb Decay", "Reverb Damp", "Reverb Color", "Reverb Feedbk", "Surround Bal", "Arp Mode", "Arp Pattern", "Arp Resolution", "Arp Note Len", "Arp Swing", "Arp Octaves", "Arp Hold", "EQ Mid Gain", "EQ Mid Freq", "EQ Mid Q", "Assign 4 Amt 1", "Assign 5 Amt 1", "Assign 6 Amt 1", "Effect Send (Revb)", "Osc 1 Local Detune", "Osc 2 Local Detune", "Osc 1 F-Shift", "Osc 2 F-Shift", "Osc 1 F-Spread", "Osc 2 F-Spread", "Osc 1 Interp", "Osc 2 Interp", "Freq Shift Mix"]
  
  static let knobNames = VirusCVoicePatch.knobNames + ["Bite", "Flanger", "RingMod", "Punch", "Fuzz", "Modulate", "Party!", "Interpolation", "F-Shift", "F-Spread", "Bush", "Muscle", "Sack", "Vowel", "Comb", "Speaker"]

  static let modSrcOptions = ["Off", "Pitch Bend", "Chan Press", "Mod Wheel", "Breath", "Ctrlr 3", "Foot Pedal", "Data Entry", "Balance", "Ctrlr 9", "Expression", "Ctlr 12", "Ctlr 13", "Ctlr 14", "Ctlr 15", "Ctlr 16", "Hold Pedal", "Porta Sw", "Sus Pedal", "Amp Env", "Filt Env", "LFO 1 Bi", "LFO 2 Bi", "LFO 3 Bi", "Velo On", "Velo Off", "Key Follow", "Random", "Arp Input", "LFO 1 Uni", "LFO 2 Uni", "LFO 3 Uni", "1% const", "10% const", "AnaKey1 Fine", "AnaKey2 Fine", "AnaKey1 Coarse", "AnaKey2 Coarse", "Env 3", "Env 4"]
  
  static let modDestOptions = ["Off", "Patch Vol", "Osc 1 Interp", "Pan", "Transpose", "Porta", "Osc 1 Shape/Index", "Osc 1 PW", "Osc 1 Wave Sel", "Osc 1 Pitch", "Slot 6 Amt 3", "Osc 2 Shape/Index", "Osc 2 PW", "Osc 2 Wave Sel", "Osc 2 Pitch", "Osc 2 Detune", "Osc 2 FM Amt", "Filt Env>Osc 2 Pitch", "Filt Env>FM/Sync", "Osc 2 Interp", "Osc Balance", "Sub Volume", "Osc Volume", "Noise Volume", "Filter 1 Cutoff", "Filter 2 Cutoff", "Filter 1 Reson", "Filter 2 Reson", "F1 Env Amt", "F2 Env Amt", "Slot 5 Amt 2", "Slot 5 Amt 3", "Filter Balance", "F Env Attack", "F Env Decay", "F Env Sustain", "F Env Slope", "F Env Release", "Amp Env Attack", "Amp Env Decay", "Amp Env Sustain", "Amp Env Slope", "Amp Env Release", "LFO 1 Rate", "LFO 1 Contour", "LFO 1>Osc 1 Pitch", "LFO 1>Osc 2 Pitch", "LFO 1>PW", "LFO 1>Reson", "LFO 1>Filter Gain", "LFO 2 Rate", "LFO 2 Contour", "LFO2>Shape", "LFO2>FM Amt", "LFO2>Cutoff 1", "LFO2>Cutoff 2", "LFO2>Pan", "LFO 3 Rate", "LFO 3 Assign Amt", "Unison Detune", "Pan Spread", "Unison LFO Phase", "Chorus Mix", "Chorus Mod Rate", "Chorus Mod Depth", "Chorus Delay", "Chorus Feedback", "Delay Send", "Delay Time", "Delay Feedback", "Delay Mod Rate", "Delay Mod Depth", "Reverb Send", "-reserved (73)-", "-reserved (74)-", "Slot 6 Amt 2", "Slot 4 Amt 2", "Slot 3 Amt 3", "Filterbank Reso", "Filterbank Poles", "Slot 2 Amt 3", "Filterbank Slope", "Slot 1 Amt 1", "Slot 2 Amt 1", "Slot 2 Amt 2", "Slot 3 Amt 1", "Slot 3 Amt 2", "Slot 3 Amt 3", "-reserved (88)-", "Punch Intens", "Ring Mod", "Noise Color", "Delay Color", "Slot 1 Amt 2", "Slot 1 Amt 3", "Dist Intens", "FreqShifter Freq", "Osc 3 Volume", "Osc 3 Pitch", "Osc 3 Detune", "LFO 1 Assign Amt", "LFO 2 Assign Amt", "Phaser Mix", "Phaser Mod Rate", "Phaser Mod Depth", "Phaser Freq", "Phaser Feedbk", "-reserved (107)-", "Reverb Time", "Reverb Damp", "Reverb Color", "Reverb PreDelay", "-reserved (112)-", "Surround Balance", "Arp Note Length", "Arp Swing Factor", "Arp Pattern", "EQ Mid Gain", "EQ Mid Freq", "-reserved (119)-", "Slot 4 Amt 1", "Slot 5 Amt 1", "Slot 6 Amt 1", "Osc 1 F-Shift", "Osc 2 F-Shift", "Osc 1 F-Spread", "Osc 2 F-Spread", "Dist Mix"]
  
  static let categoryOptions = VirusCVoicePatch.categoryOptions + ["Atomizer"]
  
  static let smoothOptions = VirusCVoicePatch.smoothOptions + ["Quantise 1/64", "Quantise 1/32", "Quantise 1/16", "Quantise 1/8", "Quantise 1/4", "Quantise 1/2", "Quantise 3/64", "Quantise 3/32", "Quantise 3/16", "Quantise 3/8", "Quantise 1/24", "Quantise 1/12", "Quantise 1/6", "Quantise 1/3", "Quantise 2/3", "Quantise 3/4", "Quantise 1/1"]
  
  static let chorusSpeedParam = MisoParam.make(iso: Miso.switcher([
    .rangeString(0...63, "Slow"),
    .rangeString(64...127, "Fast")
  ]))
  
  static let chorusDistanceIso = unitIso >>> Miso.switcher([
    .range(0.0...0.49975825646378563, Miso.m(16.0070327639812) >>> Miso.a(4.01076926406655)),
    .range(0.49975825646378563...0.6215075771071618, Miso.m(23.8305793295562) >>> Miso.a(0.100887273091541)),
    .range(0.6215075771071618...0.7534918320398745, Miso.m(31.9999820556711) >>> Miso.a(-4.97645842162877)),
    .range(0.7534918320398745...0.8750101247956927, Miso.m(40.1693819103551) >>> Miso.a(-11.1320344848009)),
    .range(0.8750101247956927...1.0, Miso.m(47.9826212970748) >>> Miso.a(-17.9686980556331)),
  ]) >>> Miso.round(1) >>> Miso.str("%gcm")
  static let chorusDistanceParam = MisoParam.make(iso: chorusDistanceIso)
  
  static let chorusMicAngleParam = MisoParam.make(iso: unitLerp(-180...180) >>> Miso.round() >>> Miso.str("%g°"))
  
  static let hyperChorusAmtParam = MisoParam.make(iso: unitLerp(1...3) >>> Miso.round(2) >>> Miso.str("%g"))

  static let distortModes = ["Off", "Light", "Soft", "Medium", "Hard", "Digital", "Wave Shaper", "Rectifier", "Bit Reducer Old", "Rate Reducer Old", "Low Pass", "High Pass", "Wide", "Soft Bounce", "Hard Bounce", "Sine Fold", "Triangle Fold", "Sawtooth Fold", "Rate Reducer", "Bit Reducer", "Mint Overdrive", "Curry Overdrive", "Saffron Overdrive", "Onion Overdrive", "Pepper Overdrive", "Chili Overdrive"]
  
  static let vocoderModes = ["Off", "Oscillator", "Osc Hold", "Noise", "In L", "In L+R", "In R"]
  
  static let characterTypes = ["Analog Boost", "Vintage 1", "Vintage 2", "Vintage 3", "Pad Opener", "Lead Enhancer", "Bass Enhancer", "Stereo Widener", "Speaker Cabinet"]
  
  static let delayLFOWaveOptions = ["Sine", "Triangle", "Saw", "Square", "S&H", "S&G"]
  // "Simple" = 1. 0 is off which we shouldn't send (puts the virus in a bad state)
  static let delayModeOptions = ["Simple", "Ping Pong 2:1", "Ping Pong 4:3", "Ping Pong 4:1", "Ping Pong 8:7", "Pattern 1+1", "Pattern 2+1", "Pattern 3+1", "Pattern 4+1", "Pattern 5+1", "Pattern 2+3", "Pattern 2+5", "Pattern 3+2", "Pattern 3+3", "Pattern 3+4", "Pattern 3+5", "Pattern 4+3", "Pattern 4+5", "Pattern 5+2", "Pattern 5+3", "Pattern 5+4", "Pattern 5+5"]
  
  static let delayClockOptions = ["Off", "1/64", "1/32", "1/16", "1/8", "1/4", "1/2", "3/64", "3/32", "3/16", "3/8", "1/24", "1/12", "1/6", "1/3", "2/3", "3/4"]
  static let delayLRClockOptions = ["1/32", "1/16", "2/16", "3/16", "4/16", "5/16"]
  static let delayRatioOptions = ["1/4", "2/4", "3/4", "4/4", "4/3", "4/2", "4/1"]
    
  // starts at 1. 0 is probably "Off"... avoid
  static let reverbModeOptions = ["Reverb", "Feedback 1", "Feedback 2"]
  
  static let reverbTypeOptions = ["Ambience", "Small Room", "Large Room", "Hall"]
  
  static let lfoClockOptions = ["Off", "1/64", "1/32", "1/16", "1/8", "1/4", "1/2", "3/64", "3/32", "3/16", "3/8", "1/24", "1/12", "1/6", "1/3", "2/3", "3/4", "1/1", "2/1", "4/1", "8/1", "16/1"]
}



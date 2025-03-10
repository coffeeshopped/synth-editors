
class VirusCVoicePatch : VirusVoicePatch {
  
  class var bankType: SysexPatchBank.Type { return VirusCVoiceBank.self }
    
  static let initFileName = "virusc-voice-init"
  static let fileDataCount = 267

  var bytes: [UInt8]

  required init(data: Data) {
    bytes = [UInt8](data.safeBytes(9..<265))
  }
    
  func sysexData(deviceId: UInt8, bank: UInt8, part: UInt8) -> Data {
    var data = Data(VirusTI.sysexHeader)
    var b1 = [deviceId, 0x10, bank, part] // these are included in checksum
    b1.append(contentsOf: bytes)
    data.append(contentsOf: b1)
    
    let checksum = b1.map{ Int($0) }.reduce(0, +) & 0x7f
    data.append(UInt8(checksum))
    
    data.append(0xf7)
    return data
  }
  
  // TODO
  func randomize() {
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
      [.velo, .pan],

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

    ]
    keys.forEach {
      self[$0] = Self.param($0)?.randomize() ?? 0
    }

//    randomizeAllParams()
//    self[[.porta]] = 0
//    self[[.vocoder, .mode]] = 0
//    self[[.volume]] = 127
//    self[[.osc, .i(0), .keyTrk]] = 96
//    self[[.osc, .i(1), .keyTrk]] = 96
//    self[[.arp, .mode]] = 0
//    self[[.input, .mode]] = 0
  }

  
  private static let _params: SynthPathParam = {
    var p = SynthPathParam()

    p[[.porta]] = MisoParam.make(byte: 5, iso: VirusTIVoicePatch.noiseVolIso)
    p[[.pan]] = RangeParam(byte: 10, displayOffset: -64)
    p[[.osc, .i(0), .shape]] = MisoParam.make(byte: 17, iso: VirusTIVoicePatch.oscShapeIso)
    p[[.osc, .i(0), .pw]] = MisoParam.make(byte: 18, iso: VirusTIVoicePatch.pwIso)
    p[[.osc, .i(0), .wave]] = MisoParam.make(byte: 19, maxVal: 63, iso: VirusTIVoicePatch.waveSelectIso)
    p[[.osc, .i(0), .semitone]] = RangeParam(byte: 20, range: 16...112, displayOffset: -64)
    p[[.osc, .i(0), .keyTrk]] = MisoParam.make(byte: 21, iso: VirusTIVoicePatch.keyFollowIso)
    p[[.osc, .i(1), .shape]] = MisoParam.make(byte: 22, iso: VirusTIVoicePatch.oscShapeIso)
    p[[.osc, .i(1), .pw]] = MisoParam.make(byte: 23, iso: VirusTIVoicePatch.pwIso)
    p[[.osc, .i(1), .wave]] = MisoParam.make(byte: 24, maxVal: 63, iso: VirusTIVoicePatch.waveSelectIso)
    p[[.osc, .i(1), .semitone]] = RangeParam(byte: 25, range: 16...112, displayOffset: -64)
    p[[.osc, .i(1), .detune]] = RangeParam(byte: 26)
    p[[.fm, .amt]] = RangeParam(byte: 27)
    p[[.osc, .i(0), .sync]] = RangeParam(byte: 28)
    p[[.filter, .env, .pitch]] = RangeParam(byte: 29, displayOffset: -64)
    p[[.filter, .env, .fm]] = RangeParam(byte: 30, displayOffset: -64)
    p[[.osc, .i(1), .keyTrk]] = MisoParam.make(byte: 31, iso: VirusTIVoicePatch.keyFollowIso)
    p[[.osc, .balance]] = RangeParam(byte: 33, displayOffset: -64)
    p[[.sub, .level]] = RangeParam(byte: 34)
    p[[.sub, .shape]] = MisoParam.make(byte: 35, options: ["Square", "Triangle"])
    p[[.osc, .level]] = RangeParam(byte: 36, displayOffset: -64)
    p[[.noise, .level]] = MisoParam.make(byte: 37, iso: VirusTIVoicePatch.noiseVolIso)
    p[[.noise, .color]] = RangeParam(byte: 39, displayOffset: -64)
    p[[.filter, .i(0), .cutoff]] = RangeParam(byte: 40)
    p[[.filter, .i(1), .cutoff]] = RangeParam(byte: 41)
    p[[.filter, .reson]] = RangeParam(byte: 42)
    p[[.filter, .reson, .extra]] = RangeParam(byte: 43)
    p[[.filter, .env, .amt]] = RangeParam(byte: 44)
    p[[.filter, .env, .extra]] = RangeParam(byte: 45)
    p[[.filter, .keyTrk]] = RangeParam(byte: 46, displayOffset: -64)
    p[[.filter, .keyTrk, .extra]] = RangeParam(byte: 47, displayOffset: -64)
    p[[.filter, .balance]] = RangeParam(byte: 48, displayOffset: -64)
    p[[.saturation, .type]] = MisoParam.make(byte: 49, options: ["Off", "Light", "Soft", "Middle", "Hard", "Digital", "Waveshaper", "Rectifier", "Bit Reducer", "Rate Reducer", "Rate+Follow", "Low Pass", "Low+Follow", "High Pass", "High+Follow"])
    p[[.ringMod, .level]] = MisoParam.make(byte: 50, iso: VirusTIVoicePatch.noiseVolIso)
    p[[.filter, .i(0), .mode]] = MisoParam.make(byte: 51, options: ["Low Pass", "Hi Pass", "Band Pass", "Band Stop", "Analog 1 Pole", "Analog 2 Pole", "Analog 3 Pole", "Analog 4 Pole"])
    p[[.filter, .i(1), .mode]] = MisoParam.make(byte: 52, options: ["Low Pass", "Hi Pass", "Band Pass", "Band Stop"])
    p[[.filter, .routing]] = MisoParam.make(byte: 53, options: ["Serial 4", "Serial 6", "Parallel 4", "Split Mode"])
    p[[.filter, .env, .attack]] = RangeParam(byte: 54)
    p[[.filter, .env, .decay]] = RangeParam(byte: 55)
    p[[.filter, .env, .sustain]] = RangeParam(byte: 56)
    p[[.filter, .env, .sustain, .slop]] = RangeParam(byte: 57, displayOffset: -64)
    p[[.filter, .env, .release]] = RangeParam(byte: 58)
    p[[.amp, .env, .attack]] = RangeParam(byte: 59)
    p[[.amp, .env, .decay]] = RangeParam(byte: 60)
    p[[.amp, .env, .sustain]] = RangeParam(byte: 61)
    p[[.amp, .env, .sustain, .slop]] = RangeParam(byte: 62, displayOffset: -64)
    p[[.amp, .env, .release]] = RangeParam(byte: 63)
    p[[.lfo, .i(0), .rate]] = RangeParam(byte: 67)
    p[[.lfo, .i(0), .shape]] = MisoParam.make(byte: 68, maxVal: 67, iso: VirusTIVoicePatch.lfoShapeIso)
    p[[.lfo, .i(0), .env, .mode]] = RangeParam(byte: 69, maxVal: 1)
    p[[.lfo, .i(0), .mode]] = MisoParam.make(byte: 70, options: ["Poly", "Mono"])
    p[[.lfo, .i(0), .curve]] = RangeParam(byte: 71, displayOffset: -64)
    p[[.lfo, .i(0), .keyTrk]] = RangeParam(byte: 72)
    p[[.lfo, .i(0), .trigger]] = MisoParam.make(byte: 73, iso: VirusTIVoicePatch.noiseVolIso)
    p[[.lfo, .i(0), .osc]] = RangeParam(byte: 74, displayOffset: -64)
    p[[.lfo, .i(0), .osc, .i(1)]] = RangeParam(byte: 75, displayOffset: -64)
    p[[.lfo, .i(0), .pw]] = RangeParam(byte: 76, displayOffset: -64)
    p[[.lfo, .i(0), .filter, .reson]] = RangeParam(byte: 77, displayOffset: -64)
    p[[.lfo, .i(0), .filter, .env]] = RangeParam(byte: 78, displayOffset: -64)
    p[[.lfo, .i(1), .rate]] = RangeParam(byte: 79)
    p[[.lfo, .i(1), .shape]] = MisoParam.make(byte: 80, maxVal: 67, iso: VirusTIVoicePatch.lfoShapeIso)
    p[[.lfo, .i(1), .env, .mode]] = RangeParam(byte: 81, maxVal: 1)
    p[[.lfo, .i(1), .mode]] = MisoParam.make(byte: 82, options: ["Poly", "Mono"])
    p[[.lfo, .i(1), .curve]] = RangeParam(byte: 83, displayOffset: -64)
    p[[.lfo, .i(1), .keyTrk]] = RangeParam(byte: 84)
    p[[.lfo, .i(1), .trigger]] = MisoParam.make(byte: 85, iso: VirusTIVoicePatch.noiseVolIso)
    p[[.lfo, .i(1), .osc, .shape]] = RangeParam(byte: 86, displayOffset: -64)
    p[[.lfo, .i(1), .fm]] = RangeParam(byte: 87, displayOffset: -64)
    p[[.lfo, .i(1), .cutoff]] = RangeParam(byte: 88, displayOffset: -64)
    p[[.lfo, .i(1), .cutoff, .i(1)]] = RangeParam(byte: 89, displayOffset: -64)
    p[[.lfo, .i(1), .pan]] = RangeParam(byte: 90, displayOffset: -64)
    p[[.volume]] = RangeParam(byte: 91)
    p[[.transpose]] = RangeParam(byte: 93, displayOffset: -64)
    p[[.osc, .key, .mode]] = MisoParam.make(byte: 94, options: ["Poly", "Mono 1", "Mono 2", "Mono 3", "Mono 4", "Hold"])
    
    // in Virus TI, these are elsewhere.
    p[[.unison, .mode]] = MisoParam.make(byte: 97, range: 0...15, iso: unisonModeIso)
    p[[.unison, .detune]] = RangeParam(byte: 98)
    p[[.unison, .pan]] = RangeParam(byte: 99)
    p[[.unison, .phase]] = RangeParam(byte: 100, displayOffset: -64)
    p[[.input, .mode]] = MisoParam.make(byte: 101, options: ["Off", "Dynamic", "Static", "To FX"])
    p[[.input, .select]] = MisoParam.make(byte: 102, options: ["In L", "In L + R", "In R", "Aux1 L", "Aux1 L + R", "Aux1 R", "Aux2 L", "Aux2 L + R", "Aux2 R"])
    
    p[[.chorus, .mix]] = MisoParam.make(byte: 105, iso: VirusTIVoicePatch.noiseVolIso)
    p[[.chorus, .rate]] = RangeParam(byte: 106)
    p[[.chorus, .depth]] = RangeParam(byte: 107)
    p[[.chorus, .delay]] = RangeParam(byte: 108)
    p[[.chorus, .feedback]] = RangeParam(byte: 109, displayOffset: -64)
    p[[.chorus, .shape]] = MisoParam.make(byte: 110, options: VirusTIVoicePatch.delayLFOWaveOptions)

    p[[.delay, .mode]] = MisoParam.make(byte: 112, options: delayModeOptions)
    p[[.delay, .send]] = RangeParam(byte: 113)
    p[[.delay, .time]] = MisoParam.make(byte: 114, iso: VirusTIVoicePatch.delayTimeIso)
    p[[.delay, .feedback]] = RangeParam(byte: 115)
    p[[.delay, .rate]] = RangeParam(byte: 116)
    p[[.delay, .depth]] = RangeParam(byte: 117)
    p[[.delay, .shape]] = MisoParam.make(byte: 118, options: VirusTIVoicePatch.delayLFOWaveOptions)
    p[[.delay, .color]] = RangeParam(byte: 119, displayOffset: -64)
//    p[[.local]] = RangeParam(byte: 122)

    p[[.arp, .mode]] = MisoParam.make(byte: 129, options: ["Off", "Up", "Down", "Up&Down", "As Played", "Random", "Chord"])
    p[[.arp, .pattern]] = RangeParam(byte: 130, maxVal: 63, displayOffset: 1)
    p[[.arp, .range]] = RangeParam(byte: 131, maxVal: 3, displayOffset: 1)
    p[[.arp, .hold]] = RangeParam(byte: 132)
    p[[.arp, .note, .length]] = RangeParam(byte: 133, displayOffset: -64)
    p[[.arp, .swing]] = MisoParam.make(byte: 134, iso: VirusTIVoicePatch.arpSwingIso)
    p[[.lfo, .i(2), .rate]] = RangeParam(byte: 135)
    p[[.lfo, .i(2), .shape]] = MisoParam.make(byte: 136, maxVal: 67, iso: VirusTIVoicePatch.lfoShapeIso)
    p[[.lfo, .i(2), .mode]] = MisoParam.make(byte: 137, options: ["Poly", "Mono"])
    p[[.lfo, .i(2), .keyTrk]] = RangeParam(byte: 138)
    p[[.lfo, .i(2), .dest]] = MisoParam.make(byte: 139, options: ["Osc 1 Pitch", "Osc 1+2 Pitch", "Osc 2 Pitch", "Osc 1 PW", "Osc 1+2 PW", "Osc 2 PW", "Sync Phase"])
    p[[.lfo, .i(2), .dest, .amt]] = RangeParam(byte: 140)
    p[[.lfo, .i(2), .fade]] = RangeParam(byte: 141)
//    p[[.arp, .mode]] = MisoParam.make(byte: 143, options: ["Off", "Up", "Down", "Up&Down", "As Played", "Random", "Chord", "Arp>Matrix"])
    p[[.tempo]] = RangeParam(byte: 144, displayOffset: 63)
    p[[.arp, .clock]] = MisoParam.make(byte: 145, options: arpResolutionOptions, startIndex: 1)
    p[[.lfo, .i(0), .clock]] = MisoParam.make(byte: 146, options: VirusTIVoicePatch.lfoClockOptions)
    p[[.lfo, .i(1), .clock]] = MisoParam.make(byte: 147, options: VirusTIVoicePatch.lfoClockOptions)
    p[[.delay, .clock]] = MisoParam.make(byte: 148, options: VirusTIVoicePatch.delayClockOptions)
    p[[.lfo, .i(2), .clock]] = MisoParam.make(byte: 149, options: VirusTIVoicePatch.lfoClockOptions)
    p[[.param, .smooth]] = MisoParam.make(byte: 153, options: smoothOptions)
    p[[.bend, .up]] = RangeParam(byte: 154, displayOffset: -64)
    p[[.bend, .down]] = RangeParam(byte: 155, displayOffset: -64)
    p[[.bend, .scale]] = MisoParam.make(byte: 156, options: ["Linear", "Expon"])
    p[[.filter, .i(0), .env, .polarity]] = MisoParam.make(byte: 158, options: ["Negative", "Positive"])
    p[[.filter, .i(1), .env, .polarity]] = MisoParam.make(byte: 159, options: ["Negative", "Positive"])
    p[[.filter, .cutoff, .link]] = RangeParam(byte: 160)
    p[[.filter, .keyTrk, .start]] = MisoParam.make(byte: 161, iso: Miso.noteName(zeroNote: "C-2"))
    p[[.fm, .mode]] = OptionsParam(byte: 162, options: ["Pos Tri", "Triangle", "Wave", "Noise", "In L", "In L+R", "In R", "Aux1 L", "Aux1 L+R", "Aux1 R", "Aux2 L", "Aux2 L+R", "Aux2 R", ])
    p[[.osc, .innit, .phase]] = MisoParam.make(byte: 163, iso: VirusTIVoicePatch.noiseVolIso)
    p[[.osc, .pushIt]] = RangeParam(byte: 164)
    p[[.input, .follow]] = RangeParam(byte: 166)
    p[[.vocoder, .mode]] = MisoParam.make(byte: 167, options: vocoderModes)
    p[[.osc, .i(2), .mode]] = MisoParam.make(byte: 169, range: 0...67, iso: VirusTIVoicePatch.osc2WaveIso)
    p[[.osc, .i(2), .level]] = RangeParam(byte: 170)
    p[[.osc, .i(2), .semitone]] = RangeParam(byte: 171, range: 16...112, displayOffset: -64)
    p[[.osc, .i(2), .fine]] = MisoParam.make(byte: 172, iso: Miso.switcher([.int(0, 0)], default: Miso.m(-1)) >>> Miso.str())
    p[[.eq, .lo, .freq]] = MisoParam.make(byte: 173, iso: VirusTIVoicePatch.loFreqIso)
    p[[.eq, .hi, .freq]] = MisoParam.make(byte: 174, iso: VirusTIVoicePatch.hiFreqIso)
    p[[.osc, .i(0), .shape, .velo]] = RangeParam(byte: 175, displayOffset: -64)
    p[[.osc, .i(1), .shape, .velo]] = RangeParam(byte: 176, displayOffset: -64)
    p[[.velo, .pw]] = RangeParam(byte: 177, displayOffset: -64)
    p[[.velo, .fm]] = RangeParam(byte: 178, displayOffset: -64)
    p[[.knob, .i(0), .name]] = MisoParam.make(byte: 179, options: knobNames)
    p[[.knob, .i(1), .name]] = MisoParam.make(byte: 180, options: knobNames)
    p[[.velo, .filter, .i(0), .env]] = RangeParam(byte: 182, displayOffset: -64)
    p[[.velo, .filter, .i(1), .env]] = RangeParam(byte: 183, displayOffset: -64)
    p[[.velo, .filter, .i(0), .reson]] = RangeParam(byte: 184, displayOffset: -64)
    p[[.velo, .filter, .i(1), .reson]] = RangeParam(byte: 185, displayOffset: -64)
    p[[.surround, .balance]] = RangeParam(byte: 186)
    p[[.velo, .volume]] = RangeParam(byte: 188, displayOffset: -64)
    p[[.velo, .pan]] = RangeParam(byte: 189, displayOffset: -64)
    p[[.knob, .i(0), .dest]] = MisoParam.make(byte: 190, options: knobOptions)
    p[[.knob, .i(1), .dest]] = MisoParam.make(byte: 191, options: knobOptions)

    p[[.mod, .i(0), .src]] = MisoParam.make(byte: 192, options: modSrcOptions)
    p[[.mod, .i(0), .dest, .i(0)]] = MisoParam.make(byte: 193, options: modDestOptions)
    p[[.mod, .i(0), .amt, .i(0)]] = RangeParam(byte: 194, displayOffset: -64)
    p[[.mod, .i(1), .src]] = MisoParam.make(byte: 195, options: modSrcOptions)
    p[[.mod, .i(1), .dest, .i(0)]] = MisoParam.make(byte: 196, options: modDestOptions)
    p[[.mod, .i(1), .amt, .i(0)]] = RangeParam(byte: 197, displayOffset: -64)
    p[[.mod, .i(1), .dest, .i(1)]] = MisoParam.make(byte: 198, options: modDestOptions)
    p[[.mod, .i(1), .amt, .i(1)]] = RangeParam(byte: 199, displayOffset: -64)
    p[[.mod, .i(2), .src]] = MisoParam.make(byte: 200, options: modSrcOptions)
    p[[.mod, .i(2), .dest, .i(0)]] = MisoParam.make(byte: 201, options: modDestOptions)
    p[[.mod, .i(2), .amt, .i(0)]] = RangeParam(byte: 202, displayOffset: -64)
    p[[.mod, .i(2), .dest, .i(1)]] = MisoParam.make(byte: 203, options: modDestOptions)
    p[[.mod, .i(2), .amt, .i(1)]] = RangeParam(byte: 204, displayOffset: -64)
    p[[.mod, .i(2), .dest, .i(2)]] = MisoParam.make(byte: 205, options: modDestOptions)
    p[[.mod, .i(2), .amt, .i(2)]] = RangeParam(byte: 206, displayOffset: -64)

    p[[.lfo, .i(0), .dest]] = MisoParam.make(byte: 207, options: modDestOptions)
    p[[.lfo, .i(0), .dest, .amt]] = RangeParam(byte: 208, displayOffset: -64)
    p[[.lfo, .i(1), .dest]] = MisoParam.make(byte: 209, options: modDestOptions)
    p[[.lfo, .i(1), .dest, .amt]] = RangeParam(byte: 210, displayOffset: -64)
    p[[.phase, .mode]] = RangeParam(byte: 212, maxVal: 5, displayOffset: 1)
    p[[.phase, .mix]] = MisoParam.make(byte: 213, iso: VirusTIVoicePatch.noiseVolIso)
    p[[.phase, .rate]] = RangeParam(byte: 214)
    p[[.phase, .depth]] = RangeParam(byte: 215)
    p[[.phase, .freq]] = RangeParam(byte: 216)
    p[[.phase, .feedback]] = RangeParam(byte: 217, displayOffset: -64)
    p[[.phase, .pan]] = RangeParam(byte: 218)
    p[[.eq, .mid, .gain]] = MisoParam.make(byte: 220, iso: VirusTIVoicePatch.eqGainIso)
    p[[.eq, .mid, .freq]] = MisoParam.make(byte: 221, range: 0...126, iso: VirusTIVoicePatch.midFreqIso)
    p[[.eq, .mid, .q]] = MisoParam.make(byte: 222, iso: VirusTIVoicePatch.midQIso)
    p[[.eq, .lo, .gain]] = MisoParam.make(byte: 223, iso: VirusTIVoicePatch.eqGainIso)
    p[[.eq, .hi, .gain]] = MisoParam.make(byte: 224, iso: VirusTIVoicePatch.eqGainIso)
    p[[.character, .amt]] = MisoParam.make(byte: 225, iso: VirusTIVoicePatch.fullPercIsoWOff)
    p[[.character, .tune]] = RangeParam(byte: 226)
    p[[.ringMod, .mix]] = RangeParam(byte: 227)
    p[[.dist, .type]] = MisoParam.make(byte: 228, options: distortModes)
    p[[.dist, .amt]] = RangeParam(byte: 229)
    p[[.mod, .i(3), .src]] = MisoParam.make(byte: 231, options: modSrcOptions)
    p[[.mod, .i(3), .dest, .i(0)]] = MisoParam.make(byte: 232, options: modDestOptions)
    p[[.mod, .i(3), .amt, .i(0)]] = RangeParam(byte: 233, displayOffset: -64)
    p[[.mod, .i(4), .src]] = MisoParam.make(byte: 234, options: modSrcOptions)
    p[[.mod, .i(4), .dest, .i(0)]] = MisoParam.make(byte: 235, options: modDestOptions)
    p[[.mod, .i(4), .amt, .i(0)]] = RangeParam(byte: 236, displayOffset: -64)
    p[[.mod, .i(5), .src]] = MisoParam.make(byte: 237, options: modSrcOptions)
    p[[.mod, .i(5), .dest, .i(0)]] = MisoParam.make(byte: 238, options: modDestOptions)
    p[[.mod, .i(5), .amt, .i(0)]] = RangeParam(byte: 239, displayOffset: -64)
    p[[.filter, .select]] = MisoParam.make(byte: 250, options: ["Filter 1", "Filter 2", "Filter 1+2"])
    p[[.category, .i(0)]] = MisoParam.make(byte: 251, options: categoryOptions)
    p[[.category, .i(1)]] = MisoParam.make(byte: 252, options: categoryOptions)

    
    return p
  }()
  
  class var params: SynthPathParam { return _params }
  
  static let midFreqExpPartIso = Miso.m(0.05594567) >>> Miso.exp() >>> Miso.m(19.71256116) >>> Miso.a(-0.60837824)
  static let midFreqIso = Miso.switcher([
    .range(0...112, midFreqExpPartIso),
    .range(113...126, Miso.a(1) >>> midFreqExpPartIso)
  ]) >>> Miso.round() >>> Miso.str()

 
  static let modSrcOptions = ["Off", "Pitch Bend", "Chan Press", "Mod Wheel", "Breath", "Ctrlr 3", "Foot Pedal", "Data Entry", "Balance", "Ctrlr 9", "Expression", "Ctlr 12", "Ctlr 13", "Ctlr 14", "Ctlr 15", "Ctlr 16", "Hold Pedal", "Porta Sw", "Sus Pedal", "Amp Env", "Filt Env", "LFO 1", "LFO 2", "LFO 3", "Velo On", "Velo Off", "Key Follow", "Random"]
  
  static let modDestOptions = ["Off", "Patch Vol", "Chan Vol", "Pan", "Transpose", "Porta", "Osc 1 Shape", "Osc 1 PW", "Osc 1 Wave Sel", "Osc 1 Pitch", "Osc 1 KeyFol", "Osc 2 Shape", "Osc 2 PW", "Osc 2 Wave Sel", "Osc 2 Pitch", "Osc 2 Detune", "Osc 2 FM Amt", "Filt Env>Osc 2 Pitch", "Filt Env>FM/Sync", "Osc 2 KeyFol", "Osc Balance", "Sub Volume", "Osc Volume", "Noise Volume", "Filter 1 Cutoff", "Filter 2 Cutoff", "Filter 1 Reson", "Filter 2 Reson", "F1 Env Amt", "F2 Env Amt",
                               
      "F1 KeyFol", "F2 KeyFol", "Filter Balance", "F Env Attack", "F Env Decay", "F Env Sustain", "F Env Sus Time", "F Env Release", "Amp Env Attack", "Amp Env Decay", "Amp Env Sustain", "Amp Env Sus Time", "Amp Env Release", "LFO 1 Rate", "LFO 1 Contour", "LFO 1>Osc 1 Pitch", "LFO 1>Osc 2 Pitch", "LFO 1>PW", "LFO 1>Reson", "LFO 1>Filter Gain", "LFO 2 Rate", "LFO 2 Contour", "LFO2>Shape", "LFO2>FM Amt", "LFO2>Cutoff 1", "LFO2>Cutoff 2", "LFO2>Pan", "LFO 3 Rate", "LFO 3 Assign Amt", "Unison Detune",
      
      "Uni Spread", "Unison LFO Phase", "Chorus Mix", "Chorus Rate", "Chorus Depth", "Chorus Delay", "Chorus Feedback", "FX Send", "Delay Time", "Delay Feedback", "Delay Rate", "Delay Depth", "Velo>Osc1 Sh", "Velo>Osc2 Sh", "Velo>PW", "Velo>FM", "Velo>F1 Env", "Velo>F2 Env", "Velo>Reso 1", "Velo>Reso 2", "Velo>Amp", "Velo Pan", "Assign 1 Amt 1", "Assign 2 Amt 1", "Assign 2 Amt 2", "Assign 3 Amt 1", "Assign 3 Amt 2", "Assign 3 Amt 3", "Osc Init Phase", "Punch Intens",
      
      "Ring Mod", "Noise Color", "Delay Color", "A Boost Int", "A Boost Tune", "Dist Intens", "Ringmod Mix", "Osc 3 Volume", "Osc 3 Pitch", "Osc 3 Detune", "LFO 1 Assign Amt", "LFO 2 Assign Amt", "Phaser Mix", "Phaser Rate", "Phaser Depth", "Phaser Freq", "Phaser Feedbk", "Phaser Spread", "Reverb Decay", "Reverb Damp", "Reverb Color", "Reverb PreDelay", "Reverb Feedbk", "Sec Balance", "Arp Note Length", "Arp Swing Factor", "Arp Pattern", "EQ Mid Gain", "EQ Mid Freq", "EQ Mid Q", "Assign 4 Amt", "Assign 5 Amt", "Assign 6 Amt"]
  
  static let knobNames = [">Para", "+3rds", "+4ths", "+5ths", "+7ths", "+Octave", "Access", "ArpMode", "ArpOct", "Attack", "Balance", "Chorus", "Cutoff", "Decay", "Delay", "Depth", "Destroy", "Detune", "Disolve", "Distort", "Dive", "Effects", "Elevate", "Energy", "EqHigh", "EqLow", "EqMid", "Fast", "Fear", "Filter", "FM", "Glide", "Hold", "Hype", "Infect", "Length", "Mix", "Morph", "Mutate", "Noise", "Open", "Orbit", "Pan", "Phaser", "Phatter", "Pitch", "Pulsate", "Push", "PWM", "Rate", "Release", "Reso", "Reverb", "Scream", "Shape", "Sharpen", "Slow", "Soften", "Speed", "SubOsc", "Sustain", "Sweep", "Swing", "Tempo", "Thinner", "Tone", "Tremolo", "Vibrato", "WahWah", "Warmth", "Warp", "Width"]

  static let knobOptions = ["Off", "Mod Wheel", "Breath", "Ctrl 3", "Foot", "Data", "Balance", "Ctrl 9", "Expression", "Ctrl 12", "Ctrl 13", "Ctrl 14", "Ctrl 15", "Ctrl 16", "Patch Volume", "Channel Volume", "Pan", "Transpose", "Portamento", "Unison Detune", "Unison Pan Sprd", "Unison Lfo Phase", "Chorus Mix", "Chorus Rate", "Chorus Depth", "Chorus Delay", "Chorus Feedback", "Effect Send", "Delay Time", "Delay Feedback", "Delay Rate", "Delay Depth", "Osc1 Wav Select", "Osc1 Pulse Width", "Osc1 Semitone", "Osc1 Keyfollow", "Osc2 Wav Select", "Osc2 Pulse Width", "Osc2 Env Amount", "Fm Env Amount", "Osc2 Keyfollow", "Noise Volume", "Filt1 Resonance", "Filt2 Resonance", "Filt1 Env Amount", "Filt2 Env Amount", "Filt1 Keyfollow", "Filt2 Keyfollow", "Lfo1 Contour", "Lfo1>Osc1", "Lfo1>Osc2", "Lfo1>Puls Width", "Lfo1>Resonance", "Lfo1>Filt Gain", "Lfo2 Contour", "Lfo2>Shape", "Lfo2>Fm Amount", "Lfo2>Cutoff1", "Lfo2>Cutoff2", "Lfo2>Pan", "Lfo3 Rate", "Lfo3 Osc Amount", "Osc1 Shape Vel", "Osc2 Shape Vel", "Puls Width Vel", "Fm Amount Vel", "Filt1 Env Vel", "Filt2 Env Vel", "Resonance1 Vel", "Resonance2 Vel", "Amplifier Vel", "Pan Vel", "Assign1 Amt1", "Assign2 Amt1", "Assign2 Amt2", "Assign3 Amt1", "Assign3 Amt2", "Assign3 Amt3", "Clock Tempo", "Input Thru", "Osc Init Phase", "Punch Intensity", "Ringmodulator", "Noise Color", "Delay Color", "Analog Boost Int", "Analog Bst Tune", "Distortion Int", "Ring Mod Mix", "Osc3 Volume", "Osc3 Semitone", "Osc3 Detune", "Lfo1 Assign Amt", "Lfo2 Assign Amt", "Phaser Mix", "Phaser Rate", "Phaser Depth", "Phaser Frequenc", "Phaser Feedback", "Phaser Spread", "Rev Decay Time", "Reverb Damping", "Reverb Color", "Reverb Feedback", "Second Balance", "Arp Mode", "Arp Pattern", "Arp Clock", "Arp Note Length", "Arp Swing", "Arp Octaves", "Arp Hold", "Eq Mid Gain", "Eq Mid Freq", "Eq Mid Q", "Assign4 Amt", "Assign5 Amt", "Assign6 Amt"]
  
  static let distortModes = ["Off", "Light", "Soft", "Middle", "Hard", "Digital", "Shaper", "Rectifier", "Bit Reducer", "Rate Reducer", "Low Pass", "High Pass"]
  
  static let arpResolutionOptions = ["1/64", "1/32", "1/16", "1/8", "1/4", "1/2", "3/64", "3/32", "3/16", "3/8", "1/24", "1/12", "1/6", "1/3", "2/3", "3/4", "1/1"]
  
  static let unisonModeIso = Miso.switcher([
    .int(0, "Off"),
    .int(1, "Twin")
  ], default: Miso.a(1) >>> Miso.str())

  static let vocoderModes = VirusTIVoicePatch.vocoderModes + ["Aux1 L", "Aux1 L+R", "Aux1 R", "Aux2 L", "Aux2 L+R", "Aux2 R"]
  
  static let delayModeOptions = ["Off", "Delay", "Reverb", "Reverb+Fdbk1", "Reverb+Fdbk2", "Delay 2:1", "Delay 4:3", "Delay 4:1", "Delay 8:7", "Pattern 1+1", "Pattern 2+1", "Pattern 3+1", "Pattern 4+1", "Pattern 5+1", "Pattern 2+3", "Pattern 2+5", "Pattern 3+2", "Pattern 3+3", "Pattern 3+4", "Pattern 3+5", "Pattern 4+3", "Pattern 4+5", "Pattern 5+2", "Pattern 5+3", "Pattern 5+4", "Pattern 5+5"]
  
  static let categoryOptions = ["Off", "Lead", "Bass", "Pad", "Decay", "Pluck", "Acid", "Classic", "Arpeggiator", "EFX", "Drums", "Percussion", "Input", "Vocoder", "Favourites 1", "Favourites 2", "Favourites 3", "Organ", "Piano", "String", "FM", "Digital"]
  
  static let smoothOptions = ["Off", "On", "Auto", "Note"]



}

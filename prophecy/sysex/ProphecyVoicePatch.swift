
class ProphecyVoicePatch : ByteBackedSysexPatch, VoicePatch, BankablePatch {

  static let bankType: SysexPatchBank.Type = ProphecyVoiceBank.self
  static func location(forData data: Data) -> Int { return Int(data[6]) }
  
  static let initFileName = "prophecy-voice-init"
  static let fileDataCount = 619
  static let nameByteRange = 0..<16
  
  var bytes: [UInt8]
  
  required init(data: Data) {
    let range = data.count == 619 ? 6..<618 : 8..<620
    bytes = data.unpack87(count: 535, inRange: range)
  }
  
  init(rawBytes: [UInt8]) {
    bytes = rawBytes
  }

  
  static func isValid(fileSize: Int) -> Bool {
    return [fileDataCount, 621].contains(fileSize)
  }
  
  func unpack(param: Param) -> Int? {
    guard let p = param as? ParamWithRange,
          p.range.lowerBound < 0 else { return defaultUnpack(param: param) }
    
    // handle negative values
    guard let bits = p.bits else { return Int(Int8(bitPattern: bytes[p.byte])) }
    return bytes[p.byte].signedBits(bits)
  }

    
  private func sysexData(channel: Int, headerBytes: [UInt8]) -> Data {
    var data = Data()
    data.append(contentsOf: Prophecy.sysexHeader(deviceId: UInt8(channel)) + headerBytes)
    data.append(Data.pack78(bytes: bytes, count: 612))
    data.append(0xf7)
    return data
  }
  
  /// Edit buffer sysex
  func sysexData(channel: Int) -> Data {
    return sysexData(channel: channel, headerBytes: [0x40, 0x01])
  }
  
  func sysexData(channel: Int, bank: Int, program: Int) -> Data {
    return sysexData(channel: channel, headerBytes: [0x4c, UInt8(bank), UInt8(program), 0x00])
  }
  
  func fileData() -> Data {
    return sysexData(channel: 0)
  }

  // TODO
  func randomize() {
    randomizeAllParams()

    self[[.osc, .i(0), .coarse]] = 0
    self[[.osc, .i(0), .fine]] = 0
    self[[.osc, .i(0), .offset]] = 0

    (0..<2).forEach { osc in
      self[[.osc, .i(osc), .key, .lo]] = 60
      self[[.osc, .i(osc), .key, .hi]] = 60
      self[[.osc, .i(osc), .slop, .lo]] = 50
      self[[.osc, .i(osc), .slop, .hi]] = 50
      self[[.osc, .i(osc), .pitch, .lfo, .amt]] = (-7...7).random()!
      self[[.osc, .i(osc), .thru, .gain]] = 99

    }
    
    let mixPres: [SynthPath] = [
      [.osc, .i(0)], [.osc, .i(1)], [.sub], [.noise], [.feedback]
    ]
    (0..<2).forEach { mix in
      self[[.mix, .i(mix), .noise, .level]] = (0...20).random()!
    }


    (0..<2).forEach { f in
      self[[.filter, .i(f), .input, .gain]] = 99
      self[[.filter, .i(f), .cutoff, .key, .lo]] = 60
      self[[.filter, .i(f), .cutoff, .key, .hi]] = 60
      self[[.filter, .i(f), .cutoff, .amt, .lo]] = 0
      self[[.filter, .i(f), .cutoff, .amt, .hi]] = 0
    }

    (0..<2).forEach { amp in
      self[[.amp, .i(amp), .level]] = 99
      self[[.amp, .i(amp), .key, .lo]] = 60
      self[[.amp, .i(amp), .key, .hi]] = 60
      self[[.amp, .i(amp), .amt, .lo]] = 0
      self[[.amp, .i(amp), .amt, .hi]] = 0
      self[[.amp, .i(amp), .env]] = 6
      self[[.amp, .i(amp), .env, .amt]] = 99
    }
    
    self[[.amp, .env, .attack, .level]] = 99

    
    self[[.pan]] = 64
    self[[.out, .level]] = 127
    
    if let oscSet = self[[.osc, .select]], oscSet < Self.oscPairs.count {
      let pairs = Self.oscPairs[oscSet]
      (0..<2).forEach { osc in
        guard let tp = pairs[osc] else { return }
        Self.params.forEach { (path, param) in
          guard path.starts(with: [.osc, .i(osc), tp]) else { return }
          self[path] = param.randomize()
        }
      }
    }
  }

    
  static let params: SynthPathParam = {
    var p = SynthPathParam()
    
    p[[.pgm, .category]] = OptionsParam(parm: 17, byte: 16, bits: 0...3, options: categoryOptions)
//    p[[.category]] = RangeParam(parm: 18, byte: 16, bits: 4...7) // user cat
//    p[[.osc, .mode]] = RangeParam(parm: 19, byte: 17, bits: 0...1) // (solo)
    p[[.hold]] = RangeParam(parm: 21, byte: 17, bit: 3)
    p[[.key, .priority]] = OptionsParam(parm:22, byte: 17, bits: 4...5, options: ["Last", "High", "Low"])
    p[[.trigger, .mode]] = OptionsParam(parm: 23, byte: 17, bits: 6...7, options: ["Multi", "Single", "Velo"])
//      (Retrigger Veclocty Control)    18
    p[[.retrigger, .threshold, .velo]] = RangeParam(parm: 24, byte: 18, bits: 0...6, range: 1...127)
    p[[.retrigger, .direction]] = OptionsParam(parm: 25, byte: 18, bit: 7, options: ["Above", "Below"])
    p[[.scale, .key]] = MisoParam.make(parm: 26, byte: 19, bits: 0...3, maxVal: 11, iso: Miso.noteName(zeroNote: "C", octave: false))
    p[[.scale, .type]] = OptionsParam(parm: 27, byte: 19, bits: 4...7, options: ["Equal Temperament", "Pure Major", "Pure Minor", "Arabic", "Pythagorean", "Werckmeister", "Kirnberger", "Slendro", "Pelog", "User Scale 1", "User Scale 2"])
    p[[.random, .pitch]] = RangeParam(parm: 28, byte: 20, maxVal: 99)
    (0..<4).forEach { env in
      let off = env * 18
      p[[.env, .i(env), .start, .level]] = RangeParam(parm: 30 + off, byte: 22 + off, range: -99...99)
      p[[.env, .i(env), .attack, .time]] = RangeParam(parm: 31 + off, byte: 23 + off, maxVal: 99)
      p[[.env, .i(env), .attack, .level]] = RangeParam(parm: 32 + off, byte: 24 + off, range: -99...99)
      p[[.env, .i(env), .decay, .time]] = RangeParam(parm: 33 + off, byte: 25 + off, maxVal: 99)
      p[[.env, .i(env), .decay, .level]] = RangeParam(parm: 34 + off, byte: 26 + off, range: -99...99)
      p[[.env, .i(env), .sustain, .time]] = RangeParam(parm: 35 + off, byte: 27 + off, maxVal: 99)
      p[[.env, .i(env), .sustain, .level]] = RangeParam(parm: 36 + off, byte: 28 + off, range: -99...99)
      p[[.env, .i(env), .release, .time]] = RangeParam(parm: 37 + off, byte: 29 + off, maxVal: 99)
      p[[.env, .i(env), .release, .level]] = RangeParam(parm: 38 + off, byte: 30 + off, range: -99...99)

      p[[.env, .i(env), .key, .attack]] = RangeParam(parm: 39 + off, byte: 31 + off, range: -99...99)
      p[[.env, .i(env), .key, .decay]] = RangeParam(parm: 40 + off, byte: 32 + off, range: -99...99)
      p[[.env, .i(env), .key, .slop]] = RangeParam(parm: 41 + off, byte: 33 + off, range: -99...99)
      p[[.env, .i(env), .key, .release]] = RangeParam(parm: 42 + off, byte: 34 + off, range: -99...99)
      
      p[[.env, .i(env), .velo, .level]] = RangeParam(parm: 43 + off, byte: 35 + off, range: -99...99)
      p[[.env, .i(env), .velo, .attack]] = RangeParam(parm: 44 + off, byte: 36 + off, range: -99...99)
      p[[.env, .i(env), .velo, .decay]] = RangeParam(parm: 45 + off, byte: 37 + off, range: -99...99)
      p[[.env, .i(env), .velo, .slop]] = RangeParam(parm: 46 + off, byte: 38 + off, range: -99...99)
      p[[.env, .i(env), .velo, .release]] = RangeParam(parm: 47 + off, byte: 39 + off, range: -99...99)
    }
    
    (0..<4).forEach { lfo in
      let poff = lfo * 13
      let boff = lfo * 11
      p[[.lfo, .i(lfo), .wave]] = OptionsParam(parm: 102 + poff, byte: 94 + boff, bits: 0...4, options: ["Sin '0", "Sin '180", "Cos '0", "Cos '180", "Tri '0", "Tri '90", "Tri '180", "Tri '270", "Saw Up '0", "Saw Up '180", "Saw Down '0", "Saw Down '180", "Sqr '0", "Sqr '180", "Random 1", "Random 2", "Random 3", "Random 4", "Random 5", "Random 6", "Growl", "Guitar Vibrato", "Step Tri", "Step Saw", "Step Tri4", "Step Saw6", "Exp Saw Up", "Exp Saw Down", "Exp Tri", "String Vibrato"])
      p[[.lfo, .i(lfo), .key, .sync]] = RangeParam(parm: 103 + poff, byte: 94 + boff, bit: 7)
      p[[.lfo, .i(lfo), .mode]] = OptionsParam(parm: 104 + poff, byte: 94 + boff, bits: 5...6, options: ["On", "Off", "Both"])
      p[[.lfo, .i(lfo), .freq]] = RangeParam(parm: 105 + poff, byte: 95 + boff, maxVal: 199)
      p[[.lfo, .i(lfo), .freq, .key, .trk]] = RangeParam(parm: 106 + poff, byte: 96 + boff, range: -99...99)
      p[[.lfo, .i(lfo), .freq, .ctrl]] = RangeParam(parm: 107 + poff, byte: 97 + boff, range: -99...99)
      p[[.lfo, .i(lfo), .freq, .mod, .src]] = OptionsParam(parm: 108 + poff, byte: 98 + boff, options: modSrcOptions)
      p[[.lfo, .i(lfo), .freq, .mod, .amt]] = RangeParam(parm: 109 + poff, byte: 99 + boff, range: -99...99)
      p[[.lfo, .i(lfo), .offset]] = RangeParam(parm: 110 + poff, byte: 100 + boff, range: -99...99)
      p[[.lfo, .i(lfo), .amp, .mod, .src]] = OptionsParam(parm: 111 + poff, byte: 101 + boff, options: modSrcOptions)
      p[[.lfo, .i(lfo), .amp, .mod, .depth]] = RangeParam(parm: 112 + poff, byte: 102 + boff, range: -99...99)
      p[[.lfo, .i(lfo), .delay]] = RangeParam(parm: 113 + poff, byte: 103 + boff, maxVal: 99)
      p[[.lfo, .i(lfo), .fade]] = RangeParam(parm: 114 + poff, byte: 104 + boff, range: -99...99)
    }

    p[[.osc, .select]] = OptionsParam(parm: 154, byte: 138, options: ["Std/Std", "Std/Comb", "Std/VPM", "Std/Mod", "Comb/Comb", "Comb/VPM", "Comb/Mod", "VPM/VPM", "VPM/Mod", "Brass", "Reed", "Pluck"])

    p[[.pitch, .env, .start, .level]] = RangeParam(parm: 155, byte: 139, range: -99...99)
    p[[.pitch, .env, .attack, .time]] = RangeParam(parm: 156, byte: 140, maxVal: 99)
    p[[.pitch, .env, .attack, .level]] = RangeParam(parm: 157, byte: 141, range: -99...99)
    p[[.pitch, .env, .decay, .time]] = RangeParam(parm: 158, byte: 142, maxVal: 99)
    p[[.pitch, .env, .decay, .level]] = RangeParam(parm: 159, byte: 143, range: -99...99)
    p[[.pitch, .env, .sustain, .time]] = RangeParam(parm: 160, byte: 144, maxVal: 99)
    p[[.pitch, .env, .release, .time]] = RangeParam(parm: 162, byte: 146, maxVal: 99)
    p[[.pitch, .env, .release, .level]] = RangeParam(parm: 163, byte: 147, range: -99...99)
    p[[.pitch, .env, .key, .level]] = RangeParam(parm: 164, byte: 148, range: -99...99)
    p[[.pitch, .env, .key, .time]] = RangeParam(parm: 165, byte: 149, range: -99...99)
    p[[.pitch, .env, .velo, .level]] = RangeParam(parm: 166, byte: 150, range: -99...99)
    p[[.pitch, .env, .velo, .time]] = RangeParam(parm: 167, byte: 151, range: -99...99)

    p[[.bend, .up]] = RangeParam(parm: 168, byte: 152, range: -60...12)
    p[[.bend, .down]] = RangeParam(parm: 169, byte: 153, range: -60...12)
    p[[.bend, .step, .up]] = RangeParam(parm: 170, byte: 154, bits: 0...3, range: 1...15)
    p[[.bend, .step, .down]] = RangeParam(parm: 171, byte: 154, bits: 4...7, range: 1...15)
    p[[.bend, .aftertouch]] = RangeParam(parm: 172, byte: 155, range: -12...12)
    
    p[[.porta, .mode]] = OptionsParam(parm: 173, byte: 156, bit: 7, options: ["Normal", "Fingered"])
    p[[.porta, .time]] = RangeParam(parm: 174, byte: 156, bits: 0...6, maxVal: 99)
    p[[.porta, .time, .velo]] = RangeParam(parm: 175, byte: 157, range: -99...99)

    (0..<2).forEach { osc in
      let poff = osc * 14
      let boff = osc * 48
      p[[.osc, .i(osc), .octave]] = OptionsParam(parm: 176 + poff, byte: 158 + boff, options: octaveOptions)
      p[[.osc, .i(osc), .coarse]] = RangeParam(parm: 177 + poff, byte: 159 + boff, range: -12...12)
      p[[.osc, .i(osc), .fine]] = RangeParam(parm: 178 + poff, byte: 160 + boff, range: -50...50)
      p[[.osc, .i(osc), .offset]] = MisoParam.make(parm: 179 + poff, byte: 161 + boff, range: -100...100, iso: Miso.m(0.1) >>> Miso.round(1))
      p[[.osc, .i(osc), .key, .lo]] = MisoParam.make(parm: 180 + poff, byte: 162 + boff, iso: noteIso)
      p[[.osc, .i(osc), .key, .hi]] = MisoParam.make(parm: 181 + poff, byte: 163 + boff, iso: noteIso)
      p[[.osc, .i(osc), .slop, .lo]] = MisoParam.make(parm: 182 + poff, byte: 164 + boff, range: -50...100, iso: pitchIntIso)
      p[[.osc, .i(osc), .slop, .hi]] = MisoParam.make(parm: 183 + poff, byte: 165 + boff, range: -50...100, iso: pitchIntIso)
      p[[.osc, .i(osc), .pitch, .lfo]] = OptionsParam(parm: 184 + poff, byte: 166 + boff, options: lfoSelectOptions)
      p[[.osc, .i(osc), .pitch, .lfo, .amt]] = RangeParam(parm: 185 + poff, byte: 167 + boff, range: -99...99)
      p[[.osc, .i(osc), .pitch, .lfo, .aftertouch]] = RangeParam(parm: 186 + poff, byte: 168 + boff, range: -99...99)
      p[[.osc, .i(osc), .pitch, .lfo, .ctrl]] = RangeParam(parm: 187 + poff, byte: 169 + boff, range: -99...99)
      p[[.osc, .i(osc), .pitch, .mod, .src]] = OptionsParam(parm: 188 + poff, byte: 170 + boff, options: modSrcOptions)
      p[[.osc, .i(osc), .pitch, .mod, .amt]] = RangeParam(parm: 189 + poff, byte: 171 + boff, range: -99...99)
      
      // parm depends on osc type
      let bb = 172 + boff
      let pp = (osc + 1) << 12
      
      // std osc
      p[[.osc, .i(osc), .normal, .wave]] = OptionsParam(parm: 388 + pp, byte: 0 + bb, options: ["Saw", "Pulse"])
      p[[.osc, .i(osc), .normal, .edge]] = RangeParam(parm: 389 + pp, byte: 1 + bb, maxVal: 99)
      p[[.osc, .i(osc), .normal, .wave, .level]] = RangeParam(parm: 390 + pp, byte: 2 + bb, maxVal: 99)
      p[[.osc, .i(osc), .normal, .ramp, .level]] = RangeParam(parm: 391 + pp, byte: 3 + bb, maxVal: 99)
      p[[.osc, .i(osc), .normal, .form]] = RangeParam(parm: 392 + pp, byte: 4 + bb, range: -99...99)
      p[[.osc, .i(osc), .normal, .lfo]] = OptionsParam(parm: 393 + pp, byte: 5 + bb, options: lfoSelectOptions)
      p[[.osc, .i(osc), .normal, .lfo, .amt]] = RangeParam(parm: 394 + pp, byte: 6 + bb, range: -99...99)
      p[[.osc, .i(osc), .normal, .mod, .src]] = OptionsParam(parm: 395 + pp, byte: 7 + bb, options: modSrcOptions)
      p[[.osc, .i(osc), .normal, .mod, .amt]] = RangeParam(parm: 396 + pp, byte: 8 + bb, range: -99...99)

      // comb filter osc
      p[[.osc, .i(osc), .filter, .noise]] = RangeParam(parm: 397 + pp, byte: 0 + bb, maxVal: 99)
      p[[.osc, .i(osc), .filter, .wave]] = OptionsParam(parm: 398 + pp, byte: 1 + bb, options: ["Saw", "Squ", "Tri"])
      p[[.osc, .i(osc), .filter, .wave, .level]] = RangeParam(parm: 399 + pp, byte: 2 + bb, maxVal: 99)
      p[[.osc, .i(osc), .filter, .gain]] = RangeParam(parm: 400 + pp, byte: 3 + bb, maxVal: 99)
      p[[.osc, .i(osc), .filter, .feedback]] = RangeParam(parm: 401 + pp, byte: 4 + bb, maxVal: 99)
      p[[.osc, .i(osc), .filter, .env]] = OptionsParam(parm: 402 + pp, byte: 5 + bb, options: envSelectOptions)
      p[[.osc, .i(osc), .filter, .env, .amt]] = RangeParam(parm: 403 + pp, byte: 6 + bb, range: -99...99)
      p[[.osc, .i(osc), .filter, .mod, .src]] = OptionsParam(parm: 404 + pp, byte: 7 + bb, options: modSrcOptions)
      p[[.osc, .i(osc), .filter, .mod, .amt]] = RangeParam(parm: 405 + pp, byte: 8 + bb, range: -99...99)
      p[[.osc, .i(osc), .filter, .cutoff]] = RangeParam(parm: 406 + pp, byte: 9 + bb, maxVal: 99)
      
      // vpm
      p[[.osc, .i(osc), .fm, .carrier, .wave]] = OptionsParam(parm: 407 + pp, byte: 0 + bb, options: ["Sin", "Saw", "Tri", "Squ"])
      p[[.osc, .i(osc), .fm, .carrier, .level]] = RangeParam(parm: 408 + pp, byte: 1 + bb, maxVal: 99)
      p[[.osc, .i(osc), .fm, .carrier, .env]] = OptionsParam(parm: 409 + pp, byte: 2 + bb, options: envSelectOptions)
      p[[.osc, .i(osc), .fm, .carrier, .env, .amt]] = RangeParam(parm: 410 + pp, byte: 3 + bb, range: -99...99)
      p[[.osc, .i(osc), .fm, .carrier, .mod, .src]] = OptionsParam(parm: 411 + pp, byte: 4 + bb, options: modSrcOptions)
      p[[.osc, .i(osc), .fm, .carrier, .mod, .amt]] = RangeParam(parm: 412 + pp, byte: 5 + bb, range: -99...99)
      p[[.osc, .i(osc), .fm, .table]] = RangeParam(parm: 413 + pp, byte: 6 + bb, maxVal: 99)
      p[[.osc, .i(osc), .fm, .table, .lfo]] = OptionsParam(parm: 414 + pp, byte: 7 + bb, options: lfoSelectOptions)
      p[[.osc, .i(osc), .fm, .table, .lfo, .amt]] = RangeParam(parm: 415 + pp, byte: 8 + bb, range: -99...99)
      p[[.osc, .i(osc), .fm, .table, .mod, .src]] = OptionsParam(parm: 416 + pp, byte: 9 + bb, options: modSrcOptions)
      p[[.osc, .i(osc), .fm, .table, .mod, .amt]] = RangeParam(parm: 417 + pp, byte: 10 + bb, range: -99...99)
      p[[.osc, .i(osc), .fm, .carrier, .feedback]] = RangeParam(parm: 418 + pp, byte: 11 + bb, maxVal: 99)
      p[[.osc, .i(osc), .fm, .mod, .coarse]] = RangeParam(parm: 419 + pp, byte: 12 + bb, range: -12...96)
      p[[.osc, .i(osc), .fm, .mod, .fine]] = RangeParam(parm: 420 + pp, byte: 13 + bb, range: -50...50)
      p[[.osc, .i(osc), .fm, .mod, .pitch, .key]] = RangeParam(parm: 421 + pp, byte: 14 + bb, range: -99...99)
      p[[.osc, .i(osc), .fm, .mod, .pitch, .mod, .src]] = OptionsParam(parm: 422 + pp, byte: 15 + bb, options: modSrcOptions)
      p[[.osc, .i(osc), .fm, .mod, .pitch, .mod, .amt]] = RangeParam(parm: 423 + pp, byte: 16 + bb, range: -99...99)
      p[[.osc, .i(osc), .fm, .mod, .wave]] = OptionsParam(parm: 424 + pp, byte: 17 + bb, options: ["Sin", "Saw", "Tri", "Squ", "Osc"])
      p[[.osc, .i(osc), .fm, .mod, .level]] = RangeParam(parm: 425 + pp, byte: 18 + bb, maxVal: 99)
      p[[.osc, .i(osc), .fm, .mod, .env]] = OptionsParam(parm: 426 + pp, byte: 19 + bb, options: envSelectOptions)
      p[[.osc, .i(osc), .fm, .mod, .env, .amt]] = RangeParam(parm: 427 + pp, byte: 20 + bb, range: -99...99)
      p[[.osc, .i(osc), .fm, .mod, .env, .key]] = RangeParam(parm: 428 + pp, byte: 21 + bb, range: -99...99)
      p[[.osc, .i(osc), .fm, .mod, .mod, .src]] = OptionsParam(parm: 429 + pp, byte: 22 + bb, options: modSrcOptions)
      p[[.osc, .i(osc), .fm, .mod, .mod, .amt]] = RangeParam(parm: 430 + pp, byte: 23 + bb, range: -99...99)
      
      // mod osc
      p[[.osc, .i(osc), .mod, .type]] = OptionsParam(parm: 431 + pp, byte: 0 + bb, options: ["Ring", "Cross", "Sync"])
      p[[.osc, .i(osc), .mod, .input]] = OptionsParam(parm: 432 + pp, byte: 1 + bb, options: ["Osc1", "Feedbk", "Noise"])
      p[[.osc, .i(osc), .mod, .ringMod]] = OptionsParam(parm: 433 + pp, byte: 2 + bb, options: ["Sin", "Saw", "Squ"])
      p[[.osc, .i(osc), .mod, .cross, .carrier]] = OptionsParam(parm: 434 + pp, byte: 3 + bb, options: ["Sin", "Saw", "Squ"])
      p[[.osc, .i(osc), .mod, .cross, .depth]] = RangeParam(parm: 435 + pp, byte: 4 + bb, maxVal: 99)
      p[[.osc, .i(osc), .mod, .cross, .env]] = OptionsParam(parm: 436 + pp, byte: 5 + bb, options: envSelectOptions)
      p[[.osc, .i(osc), .mod, .cross, .env, .amt]] = RangeParam(parm: 437 + pp, byte: 6 + bb, range: -99...99)
      p[[.osc, .i(osc), .mod, .cross, .mod, .src]] = OptionsParam(parm: 438 + pp, byte: 7 + bb, options: modSrcOptions)
      p[[.osc, .i(osc), .mod, .cross, .mod, .amt]] = RangeParam(parm: 439 + pp, byte: 8 + bb, range: -99...99)
      p[[.osc, .i(osc), .mod, .sync, .wave]] = OptionsParam(parm: 440 + pp, byte: 9 + bb, options: ["Saw", "Tri"])
      p[[.osc, .i (osc), .mod, .sync, .edge]] = RangeParam(parm: 441 + pp, byte: 10 + bb, maxVal: 99)
      
      // brass osc
      p[[.osc, .i(osc), .brass, .type]] = OptionsParam(parm: 442 + pp, byte: 0 + bb, options: ["Trumpet 1", "Trumpet 2", "Trombone", "Horn"])
      p[[.osc, .i(osc), .brass, .bend, .ctrl]] = OptionsParam(parm: 443 + pp, byte: 1 + bb, options: modSrcOptions)
      p[[.osc, .i(osc), .brass, .bend, .amt]] = RangeParam(parm: 444 + pp, byte: 2 + bb, bits: 0...5, maxVal: 12)
      p[[.osc, .i(osc), .brass, .bend, .direction]] = OptionsParam(parm: 445 + pp, byte: 2 + bb, bits: 6...7, options: ["Up", "Down", "Both"])
      p[[.osc, .i(osc), .brass, .pressure, .env]] = OptionsParam(parm: 446 + pp, byte: 3 + bb, options: envSelectOptions)
      p[[.osc, .i(osc), .brass, .pressure, .env, .amt]] = RangeParam(parm: 447 + pp, byte: 4 + bb, range: -99...99)
      p[[.osc, .i(osc), .brass, .pressure, .env, .mod, .src]] = OptionsParam(parm: 448 + pp, byte: 5 + bb, options: modSrcOptions)
      p[[.osc, .i(osc), .brass, .pressure, .env, .mod, .amt]] = RangeParam(parm: 449 + pp, byte: 6 + bb, range: -99...99)
      p[[.osc, .i(osc), .brass, .pressure, .lfo]] = OptionsParam(parm: 450 + pp, byte: 7 + bb, options: lfoSelectOptions)
      p[[.osc, .i(osc), .brass, .pressure, .lfo, .amt]] = RangeParam(parm: 451 + pp, byte: 8 + bb, range: -99...99)
      p[[.osc, .i(osc), .brass, .pressure, .mod, .src]] = OptionsParam(parm: 452 + pp, byte: 9 + bb, options: modSrcOptions)
      p[[.osc, .i(osc), .brass, .pressure, .mod, .amt]] = RangeParam(parm: 453 + pp, byte: 10 + bb, range: -99...99)
      p[[.osc, .i(osc), .brass, .lip, .character]] = RangeParam(parm: 456 + pp, byte: 13 + bb, maxVal: 99)
      p[[.osc, .i(osc), .brass, .lip, .mod, .src]] = OptionsParam(parm: 457 + pp, byte: 14 + bb, options: modSrcOptions)
      p[[.osc, .i(osc), .brass, .lip, .mod, .amt]] = RangeParam(parm: 458 + pp, byte: 15 + bb, range: -99...99)
      p[[.osc, .i(osc), .brass, .bell, .type]] = OptionsParam(parm: 461 + pp, byte: 18 + bb, options: ["Open", "Mute"])
      p[[.osc, .i(osc), .brass, .bell, .tone]] = RangeParam(parm: 462 + pp, byte: 19 + bb, maxVal: 99)
      p[[.osc, .i(osc), .brass, .bell, .reson]] = RangeParam(parm: 463 + pp, byte: 20 + bb, maxVal: 99)
      p[[.osc, .i(osc), .brass, .noise]] = RangeParam(parm: 464 + pp, byte: 21 + bb, maxVal: 99)

      // reed osc
      p[[.osc, .i(osc), .reed, .type]] = OptionsParam(parm: 477 + pp, byte: 0 + bb, options: ["Soprano Sax", "Alto Sax 1", "Alto Sax 2", "Tenor Sax 1", "Tenor Sax 2", "Bari Sax", "Flute", "Single Reed", "Double Reed", "Recorder", "Bottle", "Glass Bottle", "Monster"])
      p[[.osc, .i(osc), .reed, .bend, .ctrl]] = OptionsParam(parm: 478 + pp, byte: 1 + bb, options: modSrcOptions)
      p[[.osc, .i(osc), .reed, .bend, .amt]] = RangeParam(parm: 479 + pp, byte: 2 + bb, bits: 0...5, maxVal: 12)
      p[[.osc, .i(osc), .reed, .bend, .direction]] = OptionsParam(parm: 480 + pp, byte: 2 + bb, bits: 6...7, options: ["Up", "Down", "Both"])
      p[[.osc, .i(osc), .reed, .pressure, .env]] = OptionsParam(parm: 481 + pp, byte: 3 + bb, options: envSelectOptions)
      p[[.osc, .i(osc), .reed, .pressure, .env, .amt]] = RangeParam(parm: 482 + pp, byte: 4 + bb, maxVal: 99)
      p[[.osc, .i(osc), .reed, .pressure, .env, .mod, .src]] = OptionsParam(parm: 483 + pp, byte: 5 + bb, options: modSrcOptions)
      p[[.osc, .i(osc), .reed, .pressure, .env, .mod, .amt]] = RangeParam(parm: 484 + pp, byte: 6 + bb, range: -99...99)
      p[[.osc, .i(osc), .reed, .pressure, .lfo]] = OptionsParam(parm: 485 + pp, byte: 7 + bb, options: lfoSelectOptions)
      p[[.osc, .i(osc), .reed, .pressure, .lfo, .amt]] = RangeParam(parm: 486 + pp, byte: 8 + bb, range: -99...99)
      p[[.osc, .i(osc), .reed, .pressure, .mod, .src]] = OptionsParam(parm: 487 + pp, byte: 9 + bb, options: modSrcOptions)
      p[[.osc, .i(osc), .reed, .pressure, .mod, .amt]] = RangeParam(parm: 488 + pp, byte: 10 + bb, range: -99...99)
      p[[.osc, .i(osc), .reed, .mod, .src]] = OptionsParam(parm: 491 + pp, byte: 13 + bb, options: modSrcOptions)
      p[[.osc, .i(osc), .reed, .mod, .amt]] = RangeParam(parm: 492 + pp, byte: 14 + bb, range: -99...99)
      p[[.osc, .i(osc), .reed, .noise]] = RangeParam(parm: 496 + pp, byte: 18 + bb, maxVal: 99)

//      p[[.osc, .i(osc), .reed, .extra, .i(0)]] = RangeParam(parm: 495 + pp, byte: 17 + bb, maxVal: 99)
//      p[[.osc, .i(osc), .reed, .extra, .i(1)]] = RangeParam(parm: 497 + pp, byte: 19 + bb, maxVal: 99)
//      p[[.osc, .i(osc), .reed, .extra, .i(2)]] = RangeParam(parm: 498 + pp, byte: 20 + bb, maxVal: 99)
      
      // pluck osc
      p[[.osc, .i(osc), .pluck, .attack, .level]] = RangeParam(parm: 512 + pp, byte: 0 + bb, maxVal: 99)
      p[[.osc, .i(osc), .pluck, .attack, .level, .velo]] = RangeParam(parm: 513 + pp, byte: 1 + bb, range: -99...99)
      p[[.osc, .i(osc), .pluck, .noise, .level]] = RangeParam(parm: 514 + pp, byte: 2 + bb, maxVal: 99)
      p[[.osc, .i(osc), .pluck, .noise, .level, .velo]] = RangeParam(parm: 515 + pp, byte: 3 + bb, range: -99...99)
      p[[.osc, .i(osc), .pluck, .noise, .filter, .type]] = OptionsParam(parm: 516 + pp, byte: 4 + bb, options: ["LPF", "HPF", "BPF"])
      p[[.osc, .i(osc), .pluck, .noise, .filter, .cutoff]] = RangeParam(parm: 517 + pp, byte: 5 + bb, maxVal: 99)
      p[[.osc, .i(osc), .pluck, .noise, .filter, .velo]] = RangeParam(parm: 518 + pp, byte: 6 + bb, range: -99...99)
      p[[.osc, .i(osc), .pluck, .noise, .filter, .reson]] = RangeParam(parm: 519 + pp, byte: 7 + bb, maxVal: 99)
      p[[.osc, .i(osc), .pluck, .curve, .up]] = RangeParam(parm: 520 + pp, byte: 8 + bb, maxVal: 99)
      p[[.osc, .i(osc), .pluck, .curve, .up, .velo]] = RangeParam(parm: 521 + pp, byte: 9 + bb, range: -99...99)
      p[[.osc, .i(osc), .pluck, .curve, .down]] = RangeParam(parm: 522 + pp, byte: 10 + bb, maxVal: 99)
      p[[.osc, .i(osc), .pluck, .curve, .down, .velo]] = RangeParam(parm: 523 + pp, byte: 11 + bb, range: -99...99)
      p[[.osc, .i(osc), .pluck, .attack, .edge]] = RangeParam(parm: 524 + pp, byte: 12 + bb, maxVal: 99)
      p[[.osc, .i(osc), .pluck, .string, .position]] = RangeParam(parm: 525 + pp, byte: 13 + bb, maxVal: 99)
      p[[.osc, .i(osc), .pluck, .string, .position, .velo]] = RangeParam(parm: 526 + pp, byte: 14 + bb, range: -99...99)
      p[[.osc, .i(osc), .pluck, .string, .position, .mod, .src]] = OptionsParam(parm: 527 + pp, byte: 15 + bb, options: modSrcOptions)
      p[[.osc, .i(osc), .pluck, .string, .position, .mod, .amt]] = RangeParam(parm: 528 + pp, byte: 16 + bb, range: -99...99)
      p[[.osc, .i(osc), .pluck, .string, .damp]] = RangeParam(parm: 529 + pp, byte: 17 + bb, maxVal: 99)
      p[[.osc, .i(osc), .pluck, .string, .damp, .key]] = RangeParam(parm: 530 + pp, byte: 18 + bb, range: -99...99)
      p[[.osc, .i(osc), .pluck, .string, .damp, .mod, .src]] = OptionsParam(parm: 531 + pp, byte: 19 + bb, options: modSrcOptions)
      p[[.osc, .i(osc), .pluck, .string, .damp, .mod, .amt]] = RangeParam(parm: 532 + pp, byte: 20 + bb, range: -99...99)
      p[[.osc, .i(osc), .pluck, .off, .harmonic, .amt]] = RangeParam(parm: 533 + pp, byte: 21 + bb, maxVal: 99)
      p[[.osc, .i(osc), .pluck, .off, .harmonic, .key]] = RangeParam(parm: 534 + pp, byte: 22 + bb, range: -99...99)
      p[[.osc, .i(osc), .pluck, .decay]] = RangeParam(parm: 535 + pp, byte: 23 + bb, maxVal: 99)
      p[[.osc, .i(osc), .pluck, .decay, .key]] = RangeParam(parm: 536 + pp, byte: 24 + bb, range: -99...99)
      p[[.osc, .i(osc), .pluck, .release]] = RangeParam(parm: 537 + pp, byte: 25 + bb, maxVal: 99)
      p[[.osc, .i(osc), .pluck, .release, .key]] = RangeParam(parm: 538 + pp, byte: 26 + bb, range: -99...99)
    }

    p[[.sub, .pitch, .src]] = OptionsParam(parm: 204, byte: 254, bit: 7, options: ["Osc1", "Osc2"])
    p[[.sub, .coarse]] = RangeParam(parm: 205, byte: 254, bits: 0...6, range: -24...24)
    p[[.sub, .fine]] = RangeParam(parm: 206, byte: 255, range: -50...50)
    p[[.sub, .wave]] = OptionsParam(parm: 207, byte: 256, options: ["Sin", "Saw", "Squ", "Tri"])

    p[[.noise, .cutoff]] = RangeParam(parm: 208, byte: 257, maxVal: 99)
    p[[.noise, .cutoff, .key]] = RangeParam(parm: 209, byte: 258, range: -99...99)

    (0..<2).forEach { osc in
      let poff = osc * 14
      let boff = osc * 13
      p[[.osc, .i(osc), .input, .gain]] = RangeParam(parm: 210 + poff, byte: 259 + boff, maxVal: 99)
      p[[.osc, .i(osc), .input, .mod, .src]] = OptionsParam(parm: 211 + poff, byte: 260 + boff, options: modSrcOptions)
      p[[.osc, .i(osc), .input, .mod, .amt]] = RangeParam(parm: 212 + poff, byte: 261 + boff, range: -99...99)
      p[[.osc, .i(osc), .input, .offset]] = RangeParam(parm: 213 + poff, byte: 262 + boff, range: -99...99)
      p[[.osc, .i(osc), .feedback]] = RangeParam(parm: 216 + poff, byte: 265 + boff, maxVal: 99)
      p[[.osc, .i(osc), .cross]] = RangeParam(parm: 217 + poff, byte: 266 + boff, maxVal: 99)
      p[[.osc, .i(osc), .shape, .select]] = OptionsParam(parm: 218 + poff, byte: 267 + boff, bit: 7, options: ["Clip", "Reso"])
      p[[.osc, .i(osc), .shape, .amt]] = RangeParam(parm: 219 + poff, byte: 267 + boff, bits: 0...6, maxVal: 99)
      p[[.osc, .i(osc), .shape, .mod, .src]] = OptionsParam(parm: 220 + poff, byte: 268 + boff, options: modSrcOptions)
      p[[.osc, .i(osc), .shape, .mod, .amt]] = RangeParam(parm: 221 + poff, byte: 269 + boff, range: -99...99)
      p[[.osc, .i(osc), .out, .gain]] = RangeParam(parm: 222 + poff, byte: 270 + boff, maxVal: 99)
      p[[.osc, .i(osc), .thru, .gain]] = RangeParam(parm: 223 + poff, byte: 271 + boff, maxVal: 99)
    }
    
    let mixPres: [SynthPath] = [
      [.osc, .i(0)], [.osc, .i(1)], [.sub], [.noise], [.feedback]
    ]
    mixPres.enumerated().forEach {
      let off = $0.offset * 6
      let pre = $0.element
      p[[.mix, .i(0)] + pre + [.level]] = RangeParam(parm: 238 + off, byte: 285 + off, maxVal: 99)
      p[[.mix, .i(0)] + pre + [.mod, .src]] = OptionsParam(parm: 239 + off, byte: 286 + off, options: modSrcOptions)
      p[[.mix, .i(0)] + pre + [.mod, .amt]] = RangeParam(parm: 240 + off, byte: 287 + off, range: -99...99)

      p[[.mix, .i(1)] + pre + [.level]] = RangeParam(parm: 241 + off, byte: 288 + off, maxVal: 99)
      p[[.mix, .i(1)] + pre + [.mod, .src]] = OptionsParam(parm: 242 + off, byte: 289 + off, options: modSrcOptions)
      p[[.mix, .i(1)] + pre + [.mod, .amt]] = RangeParam(parm: 243 + off, byte: 290 + off, range: -99...99)
    }

    p[[.filter, .routing]] = OptionsParam(parm: 268, byte: 315, options: ["Seri1", "Seri2", "Para"])

    (0..<2).forEach { f in
      let off = f * 16
      p[[.filter, .i(f), .type]] = OptionsParam(parm: 269 + off, byte: 316 + off, options: ["Thru", "LPF", "HPF", "BPF", "BRF"])
      p[[.filter, .i(f), .input, .gain]] = RangeParam(parm: 270 + off, byte: 317 + off, maxVal: 99)
      p[[.filter, .i(f), .cutoff]] = RangeParam(parm: 271 + off, byte: 318 + off, maxVal: 99)
      p[[.filter, .i(f), .cutoff, .key, .lo]] = MisoParam.make(parm: 272 + off, byte: 319 + off, iso: noteIso)
      p[[.filter, .i(f), .cutoff, .key, .hi]] = MisoParam.make(parm: 273 + off, byte: 320 + off, iso: noteIso)
      p[[.filter, .i(f), .cutoff, .amt, .lo]] = RangeParam(parm: 274 + off, byte: 321 + off, range: -99...99)
      p[[.filter, .i(f), .cutoff, .amt, .hi]] = RangeParam(parm: 275 + off, byte: 322 + off, range: -99...99)
      p[[.filter, .i(f), .cutoff, .env]] = OptionsParam(parm: 276 + off, byte: 323 + off, options: envSelectOptions)
      p[[.filter, .i(f), .cutoff, .env, .amt]] = RangeParam(parm: 277 + off, byte: 324 + off, range: -99...99)
      p[[.filter, .i(f), .cutoff, .lfo]] = OptionsParam(parm: 278 + off, byte: 325 + off, options: lfoSelectOptions)
      p[[.filter, .i(f), .cutoff, .lfo, .amt]] = RangeParam(parm: 279 + off, byte: 326 + off, range: -99...99)
      p[[.filter, .i(f), .cutoff, .mod, .src]] = OptionsParam(parm: 280 + off, byte: 327 + off, options: modSrcOptions)
      p[[.filter, .i(f), .cutoff, .mod, .amt]] = RangeParam(parm: 281 + off, byte: 328 + off, range: -99...99)
      p[[.filter, .i(f), .reson]] = RangeParam(parm: 282 + off, byte: 329 + off, maxVal: 99)
      p[[.filter, .i(f), .reson, .mod, .src]] = OptionsParam(parm: 283 + off, byte: 330 + off, options: modSrcOptions)
      p[[.filter, .i(f), .reson, .mod, .amt]] = RangeParam(parm: 284 + off, byte: 331 + off, range: -99...99)
    }

    (0..<2).forEach { amp in
      let off = amp * 9
      p[[.amp, .i(amp), .level]] = RangeParam(parm: 301 + off, byte: 348 + off, maxVal: 99)
      p[[.amp, .i(amp), .key, .lo]] = MisoParam.make(parm: 302 + off, byte: 349 + off, iso: noteIso)
      p[[.amp, .i(amp), .key, .hi]] = MisoParam.make(parm: 303 + off, byte: 350 + off, iso: noteIso)
      p[[.amp, .i(amp), .amt, .lo]] = RangeParam(parm: 304 + off, byte: 351 + off, range: -99...99)
      p[[.amp, .i(amp), .amt, .hi]] = RangeParam(parm: 305 + off, byte: 352 + off, range: -99...99)
      p[[.amp, .i(amp), .env]] = OptionsParam(parm: 306 + off, byte: 353 + off, options: envSelectOptions)
      p[[.amp, .i(amp), .env, .amt]] = RangeParam(parm: 307 + off, byte: 354 + off, range: -99...99)
      p[[.amp, .i(amp), .mod, .src]] = OptionsParam(parm: 308 + off, byte: 355 + off, options: modSrcOptions)
      p[[.amp, .i(amp), .mod, .amt]] = RangeParam(parm: 309 + off, byte: 356 + off, range: -99...99)
    }
    
    p[[.amp, .env, .start, .level]] = RangeParam(parm: 319, byte: 366, maxVal: 99)
    p[[.amp, .env, .attack, .time]] = RangeParam(parm: 320, byte: 367, maxVal: 99)
    p[[.amp, .env, .attack, .level]] = RangeParam(parm: 321, byte: 368, maxVal: 99)
    p[[.amp, .env, .decay, .time]] = RangeParam(parm: 322, byte: 369, maxVal: 99)
    p[[.amp, .env, .decay, .level]] = RangeParam(parm: 323, byte: 370, maxVal: 99)
    p[[.amp, .env, .sustain, .time]] = RangeParam(parm: 324, byte: 371, maxVal: 99)
    p[[.amp, .env, .sustain, .level]] = RangeParam(parm: 325, byte: 372, maxVal: 99)
    p[[.amp, .env, .release, .time]] = RangeParam(parm: 326, byte: 373, maxVal: 99)

    p[[.amp, .env, .key, .attack]] = RangeParam(parm: 328, byte: 375, range: -99...99)
    p[[.amp, .env, .key, .decay]] = RangeParam(parm: 329, byte: 376, range: -99...99)
    p[[.amp, .env, .key, .slop]] = RangeParam(parm: 330, byte: 377, range: -99...99)
    p[[.amp, .env, .key, .release]] = RangeParam(parm: 331, byte: 378, range: -99...99)
    
    p[[.amp, .env, .velo, .level]] = RangeParam(parm: 332, byte: 379, range: -99...99)
    p[[.amp, .env, .velo, .attack]] = RangeParam(parm: 333, byte: 380, range: -99...99)
    p[[.amp, .env, .velo, .decay]] = RangeParam(parm: 334, byte: 381, range: -99...99)
    p[[.amp, .env, .velo, .slop]] = RangeParam(parm: 335, byte: 382, range: -99...99)
    p[[.amp, .env, .velo, .release]] = RangeParam(parm: 336, byte: 383, range: -99...99)

    p[[.dist, .gain]] = RangeParam(parm: 337, byte: 384, maxVal: 99)
    p[[.dist, .tone]] = RangeParam(parm: 340, byte: 387, maxVal: 99)
    p[[.dist, .level]] = RangeParam(parm: 341, byte: 388, maxVal: 99)
    p[[.dist, .balance]] = RangeParam(parm: 342, byte: 389, maxVal: 100)
    p[[.dist, .balance, .mod, .src]] = OptionsParam(parm: 343, byte: 390, options: modSrcOptions)
    p[[.dist, .balance, .mod, .amt]] = RangeParam(parm: 344, byte: 391, range: -99...99)

    p[[.wah, .reson]] = RangeParam(parm: 345, byte: 392, maxVal: 99)
    p[[.wah, .freq, .lo]] = RangeParam(parm: 346, byte: 393, maxVal: 99)
    p[[.wah, .freq, .hi]] = RangeParam(parm: 347, byte: 394, maxVal: 99)
    p[[.wah, .swing, .src]] = OptionsParam(parm: 348, byte: 395, options: modSrcOptions)
    p[[.wah, .swing, .direction]] = OptionsParam(parm: 349, byte: 396, options: ["+", "-"])
    p[[.wah, .level]] = RangeParam(parm: 350, byte: 397, maxVal: 99)
    p[[.wah, .balance]] = RangeParam(parm: 351, byte: 398, maxVal: 100)
    p[[.wah, .balance, .mod, .src]] = OptionsParam(parm: 352, byte: 399, options: modSrcOptions)
    p[[.wah, .balance, .mod, .amt]] = RangeParam(parm: 353, byte: 400, range: -99...99)

    p[[.fx, .select]] = OptionsParam(parm: 354, byte: 401, options: ["Chorus/Delay", "Reverb"])

    p[[.chorus, .delay]] = MisoParam.make(parm: 355, byte: 402, maxVal: 99, iso: Miso.a(1) >>> Miso.unitFormat("ms"))
    p[[.chorus, .feedback]] = RangeParam(parm: 356, byte: 403, range: -99...99)
    p[[.chorus, .lfo]] = OptionsParam(parm: 357, byte: 404, options: lfoSelectOptions)
    p[[.chorus, .lfo, .amt]] = RangeParam(parm: 358, byte: 405, maxVal: 99)
    p[[.chorus, .mod, .src]] = OptionsParam(parm: 359, byte: 406, options: modSrcOptions)
    p[[.chorus, .mod, .amt]] = RangeParam(parm: 360, byte: 407, maxVal: 99)
    p[[.chorus, .balance]] = RangeParam(parm: 361, byte: 408, maxVal: 100)
    p[[.chorus, .balance, .mod, .src]] = OptionsParam(parm: 362, byte: 409, options: modSrcOptions)
    p[[.chorus, .balance, .mod, .amt]] = RangeParam(parm: 363, byte: 410, range: -99...99)

    p[[.delay, .time]] = MisoParam.make(parm: 364, byte: 411, maxVal: 99, iso: Miso.a(1) >>> Miso.m(12) >>> Miso.unitFormat("ms"))
    p[[.delay, .feedback]] = RangeParam(parm: 365, byte: 412, maxVal: 99)
    p[[.delay, .hi]] = RangeParam(parm: 366, byte: 413, maxVal: 99)
    p[[.delay, .balance]] = RangeParam(parm: 367, byte: 414, maxVal: 100)
    p[[.delay, .balance, .mod, .src]] = OptionsParam(parm: 368, byte: 415, options: modSrcOptions)
    p[[.delay, .balance, .mod, .amt]] = RangeParam(parm: 369, byte: 416, range: -99...99)

    p[[.reverb, .delay]] = RangeParam(parm: 370, byte: 417, maxVal: 99)
    p[[.reverb, .time]] = RangeParam(parm: 371, byte: 418, maxVal: 99)
    p[[.reverb, .hi]] = RangeParam(parm: 372, byte: 419, maxVal: 99)
    p[[.reverb, .balance]] = RangeParam(parm: 373, byte: 420, maxVal: 100)
    p[[.reverb, .balance, .mod, .src]] = OptionsParam(parm: 374, byte: 421, options: modSrcOptions)
    p[[.reverb, .balance, .mod, .amt]] = RangeParam(parm: 375, byte: 422, range: -99...99)

    p[[.eq, .hi, .freq]] = MisoParam.make(parm: 376, byte: 423, maxVal: 49, iso: Miso.exponReg(a: 1.0003157588738856, b: 0.05775285614799131, c: -0.00016634797948438855) >>> Miso.round(2) >>> Miso.unitFormat("kHz"))
    p[[.eq, .hi, .q]] = RangeParam(parm: 377, byte: 424, maxVal: 29)
    p[[.eq, .hi, .gain]] = RangeParam(parm: 378, byte: 425, range: -18...18)
    p[[.eq, .lo, .freq]] = MisoParam.make(parm: 379, byte: 426, maxVal: 49, iso: Miso.exponReg(a: 50.2962999890187, b: 0.09890607401716418, c: -0.8994057765699203) >>> Miso.round() >>> Miso.unitFormat("Hz"))
    p[[.eq, .lo, .q]] = RangeParam(parm: 380, byte: 427, maxVal: 29)
    p[[.eq, .lo, .gain]] = RangeParam(parm: 381, byte: 428, range: -18...18)

    p[[.pan]] = RangeParam(parm: 382, byte: 429, displayOffset: -64)
    p[[.pan, .mod, .src]] = OptionsParam(parm: 383, byte: 430, options: modSrcOptions)
    p[[.pan, .mod, .amt]] = RangeParam(parm: 384, byte: 431, range: -99...99)
    p[[.out, .level]] = RangeParam(parm: 385, byte: 432)

    p[[.modWheel, .i(0)]] = OptionsParam(parm: 542, byte: 435, options: ctrlOptions)
    p[[.modWheel, .i(1)]] = OptionsParam(parm: 543, byte: 436, options: ctrlOptions)
    p[[.modWheel, .i(2), .up]] = OptionsParam(parm: 544, byte: 437, options: ctrlOptions)
    p[[.modWheel, .i(2), .down]] = OptionsParam(parm: 545, byte: 438, options: ctrlOptions)
    p[[.ctrl, .x]] = OptionsParam(parm: 546, byte: 439, options: ctrlOptions)
    p[[.ctrl, .z]] = OptionsParam(parm: 547, byte: 440, options: ctrlOptions)
    p[[.foot, .pedal]] = OptionsParam(parm: 548, byte: 441, options: ctrlOptions)
    p[[.foot, .mode]] = OptionsParam(parm: 549, byte: 442, options: ["Off", "Sustain", "Oct Up", "Oct Down", "Porta", "Dist Sw", "Wah Sw", "Delay Sw", "Chorus Sw", "Reverb Sw", "Arp Sw", "Wh3 Hold"])
    p[[.ctrl, .x, .brk]] = RangeParam(parm: 550, byte: 443, maxVal: 1)

    (0..<4).forEach { perf in
      (0..<5).forEach { knob in
        let off = perf * 20 + knob * 4
        p[[.perf, .i(perf), .knob, .i(knob), .param]] = OptionsParam(parm: 551 + off, byte: 444 + off, options: knobOptions)
        p[[.perf, .i(perf), .knob, .i(knob), .lo]] = RangeParam(parm: 552 + off, byte: 445 + off, maxVal: 100)
        p[[.perf, .i(perf), .knob, .i(knob), .hi]] = RangeParam(parm: 553 + off, byte: 446 + off, maxVal: 100)
        p[[.perf, .i(perf), .knob, .i(knob), .curve]] = OptionsParam(parm: 554 + off, byte: 447 + off, options: ["Linear", "Exp", "Log"])
      }
      
      p[[.perf, .i(perf), .on]] = RangeParam(parm: 631 + perf, byte: 524, bit: perf)
    }

    (0..<5).forEach { knob in
      p[[.knob, .i(knob), .amt]] = RangeParam(parm: 635 + knob, byte: 525 + knob)
    }

    p[[.porta, .on]] = RangeParam(parm: 640, byte: 530, maxVal: 1)
          
    return p
  }()

  static let octaveOptions = OptionsParam.makeOptions(["32\"", "16\"", "8\"", "4\""])
  
  static let modSrcOptions = OptionsParam.makeOptions({
    var opts = ["Off"]
    opts += (1...4).map { "EG\($0)" }
    opts += ["Pitch EG", "Amp EG"]
    opts += (1...4).map { "LFO\($0)" }
    opts += ["Portamento", "Note No.", "Velocity", "Pitch Bender", "After Touch"]
    opts += (0...95).map { "CC\($0)" }
    return opts
  }())
  
  static let lfoSelectOptions: [Int:String] = [7 : "LFO1", 8 : "LFO2", 9 : "LFO3", 10 : "LFO4"]
 
  static let envSelectOptions: [Int:String] = {
    var map = [Int:String]()
    ["EG1", "EG2", "EG3", "EG4", "Pitch", "Amp"].enumerated().forEach {
      map[$0.offset + 1] = $0.element
    }
    return map
  }()
  
  static let noteIso = Miso.noteName(zeroNote: "C-1")
  
  static let pitchIntIso = Miso.m(0.02) >>> Miso.round(2)
  
  static let categoryOptions = OptionsParam.makeOptions(["HardLead", "SoftLead", "SynthBass", "RealBass", "GtrPluck", "Brass", "Reed", "Wind", "Bell", "Keyboard", "Perc", "Motion", "SFX/etc", "Arpeggio", "UserGrp1", "UserGrp2"])
  
  static let ctrlOptions = OptionsParam.makeOptions({
    var opts = ["Off", "PBend+/-", "PBend+", "PBend-", "After Touch", ]
    opts += (0...95).map { "CC\($0)" }
    return opts
  }())
  
  static let knobOptions = OptionsParam.makeOptions(["Off", "PEG_StartLevel", "PEG_AttackTime", "PEG_AttackLevel", "PEG_DecayTime", "PEG_BreakLevel", "PEG_SlopeTime", "PEG_ReleaseTime", "PEG_ReleasLevel", "PortaFingerMode", "PortamentoTime", "PortaTimeVel", "OSC1_Octave", "OSC1_SemiTone", "OSC1_FineTune", "OSC1_FreqOffset", "OSC1PitchLFOInt", "OSC1PitchModInt", "OSC2_Octave", "OSC2_SemiTone", "OSC2_FineTune", "OSC2_FreqOffset", "OSC2PitchLFOInt", "OSC2PitchModInt", "SUBOSC_SemiTone", "SUBOSC_FineTune", "SUBOSC_Wave", "Noise_LPF_Fc", "Filter1_Fc", "Filter1FcEGInt", "Filter1FcLFOInt", "Filter1FcModInt", "Filt1_Resonance", "Filt1ResoModInt", "Filter2_Fc", "Filter2FcEGInt", "Filter2FcLFOInt", "Filter2FcModInt", "Filt2_Resonance", "Filt2ResoModInt", "Amp1_Amplitude", "Amp1_ModInt", "Amp2_Amplitude", "Amp2_ModInt", "AEG_StartLevel", "AEG_AttackTime", "AEG_AttackLevel", "AEG_DecayTime", "AEG_BreakLevel", "AEG_SlopeTime", "AEG_SustanLevel", "AEG_ReleaseTime", "AEG_VelCtlLevel", "AEG_VelAtckTime", "AEG_VelDcayTime", "AEG_VelSlopTime", "AEG_VelRlsTime", "Distortion_Gain", "Distortion_Tone", "Distortion_Bal", "Wah_Resonance", "Wah_Balance", "Chorus_Feedback", "Chorus_Depth", "Chorus_Balance", "Delay_DelayTime", "Delay_Feedback", "Delay_HighDamp", "Delay_Balance", "Reverb_Time", "Reverb_HighDamp", "Reverb_Balance", "Panpot", "EG1_StartLevel", "EG1_AttackTime", "EG1_AttackLevel", "EG1_DecayTime", "EG1_BreakLevel", "EG1_SlopeTime", "EG1_SustanLevel", "EG1_ReleaseTime", "EG1_ReleasLevel", "EG1_VelCtlLevel", "EG1_VelAtckTime", "EG1_VelDcayTime", "EG1_VelSlopTime", "EG1_VelRlsTime", "EG2_StartLevel", "EG2_AttackTime", "EG2_AttackLevel", "EG2_DecayTime", "EG2_BreakLevel", "EG2_SlopeTime", "EG2_SustanLevel", "EG2_ReleaseTime", "EG2_ReleasLevel", "EG2_VelCtlLevel", "EG2_VelAtckTime", "EG2_VelDcayTime", "EG2_VelSlopTime", "EG2_VelRlsTime", "EG3_StartLevel", "EG3_AttackTime", "EG3_AttackLevel", "EG3_DecayTime", "EG3_BreakLevel", "EG3_SlopeTime", "EG3_SustanLevel", "EG3_ReleaseTime", "EG3_ReleasLevel", "EG3_VelCtlLevel", "EG3_VelAtckTime", "EG3_VelDcayTime", "EG3_VelSlopTime", "EG3_VelRlsTime", "EG4_StartLevel", "EG4_AttackTime", "EG4_AttackLevel", "EG4_DecayTime", "EG4_BreakLevel", "EG4_SlopeTime", "EG4_SustanLevel", "EG4_ReleaseTime", "EG4_ReleasLevel", "EG4_VelCtlLevel", "EG4_VelAtckTime", "EG4_VelDcayTime", "EG4_VelSlopTime", "EG4_VelRlsTime", "LFO1_WaveForm", "LFO1_Frequency", "LFO1_AmpOffset", "LFO1_AmpModInt", "LFO1_Fade_In", "LFO2_WaveForm", "LFO2_Frequency", "LFO2_AmpOffset", "LFO2_AmpModInt", "LFO2_Fade_In", "LFO3_WaveForm", "LFO3_Frequency", "LFO3_AmpOffset", "LFO3_AmpModInt", "LFO3_Fade_In", "LFO4_WaveForm", "LFO4_Frequency", "LFO4_AmpOffset", "LFO4_AmpModInt", "LFO4_Fade_In", "Mix_OSC1O1Level", "MixOSC1O1ModInt", "Mix_OSC1O2Level", "MixOSC1O2ModInt", "Mix_OSC2O1Level", "MixOSC2O1ModInt", "Mix_OSC2O2Level", "MixOSC2O2ModInt", "Mix_Sub_O1Level", "Mix_SubO1ModInt", "Mix_Sub_O2Level", "Mix_SubO2ModInt", "Mix_Noi_O1Level", "Mix_NoiO1ModInt", "Mix_Noi_O2Level", "Mix_NoiO2ModInt", "Mix_Fbk_O1Level", "Mix_FbkO1ModInt", "Mix_Fbk_O2Level", "Mix_FbkO2ModInt", "WS1_InputGain", "WS1InGainModInt", "WS1_ShapeTblSel", "WS1_Shape", "WS1_ShapeModInt", "WS1_OutputGain", "WS1_ThruGain", "WS2_InputGain", "WS2InGainModInt", "WS2_ShapeTblSel", "WS2_Shape", "WS2_ShapeModInt", "WS2_OutputGain", "WS2_ThruGain", "TriggerMode", "RetrigThresVel", "RetrigAbvBelw", "ScaleKey", "ScaleType", "RandomPitchInt", "Std1_Wave", "Std1_WaveLevel", "Std1_RampLevel", "Std1_WaveForm", "Std1_WaveLFOInt", "Std1_WaveModInt", "Std2_Wave", "Std2_WaveLevel", "Std2_RampLevel", "Std2_WaveForm", "Std2_WaveLFOInt", "Std2_WaveModInt", "Comb1_NoiseLvl", "Comb1_InWaveLvl", "Comb1_Feedback", "Comb1_FbkEGInt", "Comb1_FbkModInt", "Comb1_LoopLPF", "Comb2_NoiseLvl", "Comb2_InWaveLvl", "Comb2_Feedback", "Comb2_FbkEGInt", "Comb2_FbkModInt", "Comb2_LoopLPF", "VPM1Cr_Wave", "VPM1Cr_Level", "VPM1Cr_LvlEGInt", "VPM1CrLvlModInt", "VPM1_WaveShape", "VPM1WavShLFOInt", "VPM1WavShModInt", "VPM1Cr_Feedback", "VPM1MdPitModInt", "VPM1Md_Wave", "VPM1Md_Level", "VPM1Md_LvlEGInt", "VPM1MdLvlModInt", "VPM2Cr_Wave", "VPM2Cr_Level", "VPM2Cr_LvlEGInt", "VPM2CrLvlModInt", "VPM2_WaveShape", "VPM2WavShLFOInt", "VPM2WavShModInt", "VPM2Cr_Feedback", "VPM2MdPitModInt", "VPM2Md_Wave", "VPM2Md_Level", "VPM2Md_LvlEGInt", "VPM2MdLvlModInt", "Mod_RingCarria", "Mod_CrosCarria", "Mod_CrosDepth", "Mod_SyncWave", "BrassPressEGInt", "BrassLipCharact", "BrassBellTone", "BrassBellReso", "BrassNoiseLevel", "ReedPressEGInt", "ReedReedModInt", "ReedNoiseLevel", "PluckNoiseLevel", "PluckNoiseFc", "PluckStringPosi", "PluckStringLoss", "PluckInharmo"])

    
  // std osc
  static let stdDefaults: [SynthPath:Int] = [
    [.normal, .wave] : 0,
    [.normal, .edge] : 99,
    [.normal, .wave, .level] : 99,
    [.normal, .ramp, .level] : 0,
    [.normal, .form] : 0,
    [.normal, .lfo] : 7,
    [.normal, .lfo, .amt] : 0,
    [.normal, .mod, .src] : 0,
    [.normal, .mod, .amt] : 0,
  ]

  // comb filter osc
  static let combDefaults: [SynthPath:Int] = [
    [.filter, .noise] : 99,
    [.filter, .wave] : 1,
    [.filter, .wave, .level] : 30,
    [.filter, .gain] : 30,
    [.filter, .feedback] : 76,
    [.filter, .env] : 4,
    [.filter, .env, .amt] : -40,
    [.filter, .mod, .src] : 18,
    [.filter, .mod, .amt] : -41,
    [.filter, .cutoff] : 99
    ,]
  
  // vpm
  static let vpmDefaults: [SynthPath:Int] = [
    [.fm, .carrier, .wave] : 2,
    [.fm, .carrier, .level] : 99,
    [.fm, .carrier, .env] : 1,
    [.fm, .carrier, .env, .amt] : 0,
    [.fm, .carrier, .mod, .src] : 0,
    [.fm, .carrier, .mod, .amt] : 0,
    [.fm, .table] : 19,
    [.fm, .table, .lfo] : 8,
    [.fm, .table, .lfo, .amt] : 18,
    [.fm, .table, .mod, .src] : 2,
    [.fm, .table, .mod, .amt] : 14,
    [.fm, .carrier, .feedback] : 3,
    [.fm, .mod, .coarse] : -12,
    [.fm, .mod, .fine] : 0,
    [.fm, .mod, .pitch, .key] : 0,
    [.fm, .mod, .pitch, .mod, .src] : 0,
    [.fm, .mod, .pitch, .mod, .amt] : 0,
    [.fm, .mod, .wave] : 0,
    [.fm, .mod, .level] : 20,
    [.fm, .mod, .env] : 2,
    [.fm, .mod, .env, .amt] : 46,
    [.fm, .mod, .env, .key] : -26,
    [.fm, .mod, .mod, .src] : 18,
    [.fm, .mod, .mod, .amt] : -50,
  ]
  
  // mod osc
  static let modDefaults: [SynthPath:Int] = [
    [.mod, .type] : 2,
    [.mod, .input] : 0,
    [.mod, .ringMod] : 0,
    [.mod, .cross, .carrier] : 0,
    [.mod, .cross, .depth] : 20,
    [.mod, .cross, .env] : 1,
    [.mod, .cross, .env, .amt] : 0,
    [.mod, .cross, .mod, .src] : 0,
    [.mod, .cross, .mod, .amt] : 0,
    [.mod, .sync, .wave] : 0,
    [.mod, .sync, .edge] : 99,
  ]
  
  // brass osc
  static let brassDefaults: [SynthPath:Int] = [
    [.brass, .type] : 0,
    [.brass, .bend, .ctrl] : 14,
    [.brass, .bend, .amt] : 0,
    [.brass, .bend, .direction] : 0,
    [.brass, .pressure, .env] : 2,
    [.brass, .pressure, .env, .amt] : 15,
    [.brass, .pressure, .env, .mod, .src] : 17,
    [.brass, .pressure, .env, .mod, .amt] : 50,
    [.brass, .pressure, .lfo] : 7,
    [.brass, .pressure, .lfo, .amt] : 20,
    [.brass, .pressure, .mod, .src] : 1,
    [.brass, .pressure, .mod, .amt] : 95,
    [.brass, .lip, .character] : 39,
    [.brass, .lip, .mod, .src] : 17,
    [.brass, .lip, .mod, .amt] : 61,
    [.brass, .bell, .type] : 0,
    [.brass, .bell, .tone] : 80,
    [.brass, .bell, .reson] : 50,
    [.brass, .noise] : 30,
  ]

  // reed osc
  static let reedDefaults: [SynthPath:Int] = [
    [.reed, .type] : 10,
    [.reed, .bend, .ctrl] : 0,
    [.reed, .bend, .amt] : 0,
    [.reed, .bend, .direction] : 0,
    [.reed, .pressure, .env] : 1,
    [.reed, .pressure, .env, .amt] : 99,
    [.reed, .pressure, .env, .mod, .src] : 1,
    [.reed, .pressure, .env, .mod, .amt] : 99,
    [.reed, .pressure, .lfo] : 10,
    [.reed, .pressure, .lfo, .amt] : 15,
    [.reed, .pressure, .mod, .src] : 2,
    [.reed, .pressure, .mod, .amt] : 99,
    [.reed, .mod, .src] : 3,
    [.reed, .mod, .amt] : 42,
    [.reed, .noise] : 80,
  ]
  
  // pluck osc
  static let pluckDefaults: [SynthPath:Int] = [
    [.pluck, .attack, .level] : 99,
    [.pluck, .attack, .level, .velo] : 55,
    [.pluck, .noise, .level] : 15,
    [.pluck, .noise, .level, .velo] : 80,
    [.pluck, .noise, .filter, .type] : 2,
    [.pluck, .noise, .filter, .cutoff] : 85,
    [.pluck, .noise, .filter, .velo] : 0,
    [.pluck, .noise, .filter, .reson] : 40,
    [.pluck, .curve, .up] : 50,
    [.pluck, .curve, .up, .velo] : 92,
    [.pluck, .curve, .down] : 10,
    [.pluck, .curve, .down, .velo] : -99,
    [.pluck, .attack, .edge] : 99,
    [.pluck, .string, .position] : 80,
    [.pluck, .string, .position, .velo] : 20,
    [.pluck, .string, .position, .mod, .src] : 32,
    [.pluck, .string, .position, .mod, .amt] : 30,
    [.pluck, .string, .damp] : 12,
    [.pluck, .string, .damp, .key] : -99,
    [.pluck, .string, .damp, .mod, .src] : 19,
    [.pluck, .string, .damp, .mod, .amt] : 60,
    [.pluck, .off, .harmonic, .amt] : 72,
    [.pluck, .off, .harmonic, .key] : -50,
    [.pluck, .decay] : 92,
    [.pluck, .decay, .key] : -1,
    [.pluck, .release] : 84,
    [.pluck, .release, .key] : -50,
  ]
  
  //  p[[.osc, .select]] = OptionsParam(parm: 154, byte: 138, options: ["Std/Std", "Std/Comb", "Std/VPM", "Std/Mod", "Comb/Comb", "Comb/VPM", "Comb/Mod", "VPM/VPM", "VPM/Mod", "Brass", "Reed", "Pluck"])

    static let oscPairs: [[SynthPathItem?]] = [
      [.normal, .normal],
      [.normal, .filter],
      [.normal, .fm],
      [.normal, .mod],
      [.filter, .filter],
      [.filter, .fm],
      [.filter, .mod],
      [.fm, .fm],
      [.fm, .mod],
      [.brass, nil],
      [.reed, nil],
      [.pluck, nil],
    ]

  static let oscDefaults: [SynthPathItem:[SynthPath:Int]] = [
    .normal : stdDefaults,
    .filter : combDefaults,
    .fm : vpmDefaults,
    .mod : modDefaults,
    .brass : brassDefaults,
    .reed : reedDefaults,
    .pluck : pluckDefaults,
  ]
  
}

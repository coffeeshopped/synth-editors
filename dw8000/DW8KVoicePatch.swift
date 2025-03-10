
class DW8KVoicePatch : ByteBackedSysexPatch, BankablePatch, VoicePatch {

  static let bankType: SysexPatchBank.Type = DW8KVoiceBank.self
  static func location(forData data: Data) -> Int { return Int(data[62] & 0x3f) }
    
  static let initFileName = "dw8k-voice-init"
  static let fileDataCount = 57
  
  var bytes: [UInt8]
  var name = ""
  
  required init(data: Data) {
    bytes = [UInt8](data[5..<56])
  }

  // normal, or with write request
  static func isValid(sysex: Data) -> Bool {
    return sysex.count == fileDataCount || sysex.count == 64
  }

  func sysexData(channel: Int, location: Int) -> [Data] {
    // patch data
    var datas = [sysexData(channel: channel)]
    // write request
    datas.append(Data([0xf0, 0x42, 0x30 + UInt8(channel), 0x03, 0x11, UInt8(location), 0xf7]))
    return datas
  }
    
  func sysexData(channel: Int) -> Data {
    var data = Data([0xf0, 0x42, 0x30 + UInt8(channel), 0x03, 0x40])
    data.append(contentsOf: bytes)
    data.append(0xf7)
    return data
  }
  
  func fileData() -> Data {
    return sysexData(channel: 0)
  }

    func randomize() {
      randomizeAllParams()
  //    self[[.structure]] = (0...10).random()!
    }
    
    static let params: SynthPathParam = {
      var p = SynthPathParam()

      p[[.osc, .i(0), .octave]] = OptionsParam(parm: 11, byte: 0, options: ["16'", "8'", "4'"])
      p[[.osc, .i(0), .wave]] = OptionsParam(parm: 12, byte: 1, options: waveOptions)
      p[[.osc, .i(0), .level]] = RangeParam(parm: 13, byte: 2, maxVal: 31)
      p[[.auto, .bend, .select]] = OptionsParam(parm: 14, byte: 3, options: ["Off", "Osc 1", "Osc 2", "Both"])
      p[[.auto, .bend, .mode]] = OptionsParam(parm: 15, byte: 4, options: ["Up", "Down"])
      p[[.auto, .bend, .time]] = RangeParam(parm: 16, byte: 5, maxVal: 31)
      p[[.auto, .bend, .amt]] = RangeParam(parm: 17, byte: 6, maxVal: 31)
      p[[.osc, .i(1), .octave]] = OptionsParam(parm: 21, byte: 7, options: ["16'", "8'", "4'"])
      p[[.osc, .i(1), .wave]] = OptionsParam(parm: 22, byte: 8, options: waveOptions)
      p[[.osc, .i(1), .level]] = RangeParam(parm: 23, byte: 9, maxVal: 31)
      p[[.interval]] = OptionsParam(parm: 24, byte: 10, options: ["Unison", "Minor 3rd", "Major 3rd", "4th", "5th"])
      p[[.detune]] = RangeParam(parm: 25, byte: 11, maxVal: 6)
      p[[.noise]] = RangeParam(parm: 26, byte: 12, maxVal: 31)
      p[[.assign, .mode]] = OptionsParam(parm: 0, byte: 13, options: ["Poly", "Poly 2", "Unison", "Unison 2"])
      p[[.param, .number]] = RangeParam(parm: 0, byte: 14)
      p[[.cutoff]] = RangeParam(parm: 31, byte: 15, maxVal: 63)
      p[[.reson]] = RangeParam(parm: 32, byte: 16, maxVal: 31)
      p[[.filter, .keyTrk]] = OptionsParam(parm: 33, byte: 17, options: ["Off", "1/4", "1/2", "Full"])
      p[[.filter, .env, .polarity]] = OptionsParam(parm: 34, byte: 18, options: ["Normal", "Invert"])
      p[[.filter, .env, .amt]] = RangeParam(parm: 35, byte: 19, maxVal: 31)
      p[[.filter, .env, .attack]] = RangeParam(parm: 41, byte: 20, maxVal: 31)
      p[[.filter, .env, .decay]] = RangeParam(parm: 42, byte: 21, maxVal: 31)
      p[[.filter, .env, .brk]] = RangeParam(parm: 43, byte: 22, maxVal: 31)
      p[[.filter, .env, .slop]] = RangeParam(parm: 44, byte: 23, maxVal: 31)
      p[[.filter, .env, .sustain]] = RangeParam(parm: 45, byte: 24, maxVal: 31)
      p[[.filter, .env, .release]] = RangeParam(parm: 46, byte: 25, maxVal: 31)
      p[[.filter, .velo]] = RangeParam(parm: 47, byte: 26, maxVal: 7)
      p[[.amp, .env, .attack]] = RangeParam(parm: 51, byte: 27, maxVal: 31)
      p[[.amp, .env, .decay]] = RangeParam(parm: 52, byte: 28, maxVal: 31)
      p[[.amp, .env, .brk]] = RangeParam(parm: 53, byte: 29, maxVal: 31)
      p[[.amp, .env, .slop]] = RangeParam(parm: 54, byte: 30, maxVal: 31)
      p[[.amp, .env, .sustain]] = RangeParam(parm: 55, byte: 31, maxVal: 31)
      p[[.amp, .env, .release]] = RangeParam(parm: 56, byte: 32, maxVal: 31)
      p[[.amp, .velo]] = RangeParam(parm: 57, byte: 33, maxVal: 7)
      p[[.lfo, .wave]] = OptionsParam(parm: 61, byte: 34, options: ["Tri", "Saw", "Rev Saw", "Square"])
      p[[.lfo, .freq]] = RangeParam(parm: 62, byte: 35, maxVal: 31)
      p[[.lfo, .delay]] = RangeParam(parm: 63, byte: 36, maxVal: 31)
      p[[.lfo, .pitch]] = RangeParam(parm: 64, byte: 37, maxVal: 31)
      p[[.lfo, .filter]] = RangeParam(parm: 65, byte: 38, maxVal: 31)
      p[[.bend, .pitch]] = RangeParam(parm: 66, byte: 39, maxVal: 12)
      p[[.bend, .filter]] = RangeParam(parm: 67, byte: 40, maxVal: 1)
      p[[.delay, .time]] = RangeParam(parm: 71, byte: 41, maxVal: 7)
      p[[.delay, .scale]] = RangeParam(parm: 72, byte: 42, maxVal: 15)
      p[[.delay, .feedback]] = RangeParam(parm: 73, byte: 43, maxVal: 15)
      p[[.delay, .mod, .freq]] = RangeParam(parm: 74, byte: 44, maxVal: 31)
      p[[.delay, .mod, .amt]] = RangeParam(parm: 75, byte: 45, maxVal: 31)
      p[[.delay, .level]] = RangeParam(parm: 76, byte: 46, maxVal: 15)
      p[[.porta]] = RangeParam(parm: 77, byte: 47, maxVal: 31)
      p[[.aftertouch, .vib]] = RangeParam(parm: 81, byte: 48, maxVal: 3)
      p[[.aftertouch, .filter]] = RangeParam(parm: 82, byte: 49, maxVal: 3)
      p[[.aftertouch, .amp]] = RangeParam(parm: 83, byte: 50, maxVal: 3)

      return p
    }()

  static let waveOptions = OptionsParam.makeOptions(["1: Saw", "2: Square", "3: Ac Piano", "4: Elec Piano", "5: Elec Piano 2", "6: Clavi", "7: Organ", "8: Brass", "9: Sax", "10: Violin", "11: Ac Guitar", "12: Dist Guitar", "13: Elec Bass", "14: Digi Bass", "15: Bell", "16: Sine"])
}

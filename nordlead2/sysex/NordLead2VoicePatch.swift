
class NordLead2VoicePatch : NordLead2Patch, BankablePatch {
  
  static var bankType: SysexPatchBank.Type = NordLead2VoiceBank.self
  static func bank(forData data: Data) -> Int { return Int(data[4]) }
  static func location(forData data: Data) -> Int { return Int(data[5]) }

  static let fileDataCount = 139
  static let initFileName = "Nord-Lead-init"

  var name = ""
  var bytes: [UInt8]

  required init(data: Data) {
    bytes = type(of: self).combinedBytes(forData: data[6..<138])
  }
  
  init(rawBytes: ArraySlice<UInt8>) {
    bytes = [UInt8](rawBytes)
  }
  
  // bank: 0 = temp, 1...4 = bank 1-4
  // location: temp: 0...3 (A-D)
  
  func fileData() -> Data {
    return sysexData(deviceId: 0, bank: 0, location: 0)
  }
  
  static let params: SynthPathParam = {
    var p = SynthPathParam()
    
    p[[.osc, .i(1), .pitch]] = RangeParam(parm: 78, byte: 0, maxVal: 120, displayOffset: -60)
    p[[.osc, .i(1), .fine]] = RangeParam(parm: 33, byte: 1, displayOffset: -64)
    p[[.mix]] = OptionsParam(parm: 8, byte: 2, options: mixOptions)
    p[[.filter, .cutoff]] = RangeParam(parm: 74, byte: 3)
    p[[.filter, .reson]] = RangeParam(parm: 42, byte: 4)
    p[[.filter, .env, .amt]] = RangeParam(parm: 43, byte: 5)
    p[[.pw]] = RangeParam(parm: 79, byte: 6)
    p[[.fm, .amt]] = RangeParam(parm: 70, byte: 7)
    p[[.filter, .env, .attack]] = RangeParam(parm: 38, byte: 8)
    p[[.filter, .env, .decay]] = RangeParam(parm: 39, byte: 9)
    p[[.filter, .env, .sustain]] = RangeParam(parm: 40, byte: 10)
    p[[.filter, .env, .release]] = RangeParam(parm: 41, byte: 11)
    p[[.amp, .env, .attack]] = RangeParam(parm: 73, byte: 12)
    p[[.amp, .env, .decay]] = RangeParam(parm: 36, byte: 13)
    p[[.amp, .env, .sustain]] = RangeParam(parm: 37, byte: 14)
    p[[.amp, .env, .release]] = RangeParam(parm: 72, byte: 15)
    p[[.porta]] = RangeParam(parm: 5, byte: 16)
    p[[.amp, .gain]] = RangeParam(parm: 7, byte: 17)
    p[[.mod, .env, .attack]] = RangeParam(parm: 26, byte: 18)
    p[[.mod, .env, .decay]] = RangeParam(parm: 27, byte: 19)
    p[[.mod, .env, .amt]] = RangeParam(parm: 29, byte: 20, displayOffset: -64)
    p[[.lfo, .i(0), .rate]] = RangeParam(parm: 19, byte: 21)
    p[[.lfo, .i(0), .amt]] = RangeParam(parm: 22, byte: 22)
    p[[.lfo, .i(1), .rate]] = RangeParam(parm: 23, byte: 23)
    p[[.arp, .range]] = RangeParam(parm: 25, byte: 24)
    p[[.osc, .i(1), .pitch, .sens]] = RangeParam(byte: 25)
    p[[.osc, .i(1), .fine, .sens]] = RangeParam(byte: 26)
    p[[.mix, .sens]] = RangeParam(byte: 27)
    p[[.cutoff, .sens]] = RangeParam(byte: 28)
    p[[.reson, .sens]] = RangeParam(byte: 29)
    p[[.filter, .env, .amt, .sens]] = RangeParam(byte: 30)
    p[[.pw, .sens]] = RangeParam(byte: 31)
    p[[.fm, .amt, .sens]] = RangeParam(byte: 32)
    p[[.filter, .env, .attack, .sens]] = RangeParam(byte: 33)
    p[[.filter, .env, .decay, .sens]] = RangeParam(byte: 34)
    p[[.filter, .env, .sustain, .sens]] = RangeParam(byte: 35)
    p[[.filter, .env, .release, .sens]] = RangeParam(byte: 36)
    p[[.amp, .env, .attack, .sens]] = RangeParam(byte: 37)
    p[[.amp, .env, .decay, .sens]] = RangeParam(byte: 38)
    p[[.amp, .env, .sustain, .sens]] = RangeParam(byte: 39)
    p[[.amp, .env, .release, .sens]] = RangeParam(byte: 40)
    p[[.porta, .sens]] = RangeParam(byte: 41)
    p[[.gain, .sens]] = RangeParam(byte: 42)
    p[[.mod, .env, .attack, .sens]] = RangeParam(byte: 43)
    p[[.mod, .env, .decay, .sens]] = RangeParam(byte: 44)
    p[[.mod, .env, .amt, .sens]] = RangeParam(byte: 45)
    p[[.lfo, .i(0), .rate, .sens]] = RangeParam(byte: 46)
    p[[.lfo, .i(0), .amt, .sens]] = RangeParam(byte: 47)
    p[[.lfo, .i(1), .rate, .sens]] = RangeParam(byte: 48)
    p[[.arp, .range, .sens]] = RangeParam(byte: 49)
    p[[.osc, .i(0), .wave]] = OptionsParam(parm: 30, byte: 50, options: osc1WaveOptions)
    p[[.osc, .i(1), .wave]] = OptionsParam(parm: 31, byte: 51, options: osc2WaveOptions)
    p[[.sync]] = RangeParam(parm: 35, byte: 52, bit: 0)
    p[[.ringMod]] = RangeParam(byte: 52, bit: 1)
    p[[.filter, .dist]] = RangeParam(parm: 80, byte: 52, bit: 4)
    p[[.filter, .type]] = OptionsParam(parm: 44, byte: 53, options: filterTypeOptions)
    p[[.osc, .i(1), .keyTrk]] = RangeParam(parm: 34, byte: 54, maxVal: 1)
    p[[.filter, .keyTrk]] = OptionsParam(parm: 46, byte: 55, options: filterKeyTrackOptions)
    p[[.lfo, .i(0), .wave]] = OptionsParam(parm: 20, byte: 56, options: lfo1WaveOptions)
    p[[.lfo, .i(0), .dest]] = OptionsParam(parm: 21, byte: 57, options: lfo1DestOptions)
    p[[.voice, .mode]] = OptionsParam(parm: 15, byte: 58, options: voiceModeOptions)
    p[[.modWheel, .dest]] = OptionsParam(parm: 18, byte: 59, options: modWheelDestOptions)
    p[[.unison]] = RangeParam(parm: 16, byte: 60, maxVal: 1)
    p[[.mod, .env, .dest]] = OptionsParam(parm: 28, byte: 61, options: mEnvDestOptions)
    p[[.auto]] = RangeParam(parm: 65, byte: 62, maxVal: 1)
    p[[.filter, .velo]] = RangeParam(parm: 45, byte: 63, maxVal: 1)
    p[[.octave, .shift]] = RangeParam(parm: 17, byte: 64, maxVal: 4)
    p[[.lfo, .i(1), .dest]] = OptionsParam(parm: 24, byte: 65, options: lfo2DestOptions)
    
    return p
  }()
  
  static let osc1WaveOptions = OptionsParam.makeOptions(["Square","Saw","Triangle","Sine"])

  static let osc2WaveOptions = OptionsParam.makeOptions(["Square","Saw","Triangle","Noise"])
  
  static let filterTypeOptions = OptionsParam.makeOptions(["Lo-Pass 12dB","Lo-Pass 24dB", "Hi-Pass","Bandpass","Notch + LP", "Secret"])
  
  static let filterKeyTrackOptions = OptionsParam.makeOptions(["Off","1/3","2/3","Full"])

  static let lfo1WaveOptions = OptionsParam.makeOptions(["Random","Saw","Triangle","Square","Smooth Random"])

  static let lfo1DestOptions = OptionsParam.makeOptions(["PW","Filter","Osc 2","Osc 1+2","FM"])

  static let voiceModeOptions = OptionsParam.makeOptions(["Mono","Legato","Poly"])

  static let modWheelDestOptions = OptionsParam.makeOptions(["Filter","FM","Osc 2","LFO 1","Morph"])
  
  static let mEnvDestOptions = OptionsParam.makeOptions(["Osc 2","FM","PW","Off"])

  static let lfo2DestOptions = OptionsParam.makeOptions(["Arp: Down","Arp: Up","Arp: Up & Down","LFO: Amp","LFO: Osc 1+2","Arp: Random","Arp: Echo","LFO: Filter"])

  static let mixOptions = OptionsParam.makeOptions(
    (0...63).map { "+\(64-$0) O1" } + ["0"] +
    (65...127).map { "+\($0-64) O2" })


}

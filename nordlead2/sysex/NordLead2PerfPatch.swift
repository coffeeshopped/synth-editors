
class NordLead2PerfPatch : NordLead2Patch, PerfPatch {
  
  static let fileDataCount = 715
  static let initFileName = "Nord-Lead-perf-init"
  
  var bytes: [UInt8]
  var name: String = ""
  var subnames = [SynthPath:String]()
  
  func name(forPath path: SynthPath) -> String? {
    if path == [] {
      return name
    }
    return subnames[path]
  }
  
  func set(name n: String, forPath path: SynthPath) {
    if path == [] {
      name = n
    }
    else {
      subnames[path] = n
    }
  }
  
  required init(data: Data) {
    bytes = type(of: self).combinedBytes(forData: data[6..<714])
  }
  
  static let tempBuffer = 0x1e
  static let cardBank = 0x1f
  
  func fileData() -> Data {
    return sysexData(deviceId: 0, bank: type(of: self).tempBuffer, location: 0)
  }
  
  /// Gives temp buffer sysex set data for a slot
  func patchSysexData(deviceId: Int, location: Int) -> Data {
    var data = type(of: self).dataSetHeader(deviceId: deviceId, bank: 0, location: location)
    data.append(contentsOf: type(of: self).split(bytes: patchBytes(location: location)))
    data.append(0xf7)
    return data
  }
  
  func patch(location: Int) -> NordLead2VoicePatch {
    let p = NordLead2VoicePatch(rawBytes: patchBytes(location: location))
    // Name isn't stored in sysex, so set it based on what we have in subnames
    p.name = subnames[[.patch, .i(location)]] ?? "Untitled"
    return p
  }
  
  private func patchBytes(location: Int) -> ArraySlice<UInt8> {
    let patchByteSize = 66
    let offset = location * patchByteSize // size in raw bytes of one patch's data
    return bytes[offset..<(offset+patchByteSize)]
  }

  static let params: SynthPathParam = {
    var p = SynthPathParam()
    
    (0..<4).forEach { part in
      let patchPre: SynthPath = [.patch, .i(part)]
      let voiceParams = NordLead2VoicePatch.params
      voiceParams.forEach {
        let newByte = $0.value.byte + (part * 66)
        if let rp = $0.value as? RangeParam {
          p[patchPre + $0.key] = RangeParam(parm: rp.parm, byte: newByte, range: rp.range, displayOffset: rp.displayOffset)
        }
        else if let op = $0.value as? OptionsParam {
          p[patchPre + $0.key] = OptionsParam(parm: op.parm, byte: newByte, options: op.options)
        }
      }
      
      let partPre: SynthPath = [.part, .i(part)]
      p[partPre + [.channel]] = RangeParam(byte: 264 + part, maxVal: 15, displayOffset: 1)
      p[partPre + [.lfo, .i(0), .sync]] = OptionsParam(byte: 268 + part, options: lfoSyncOptions)
      p[partPre + [.lfo, .i(1), .sync]] = OptionsParam(byte: 272 + part, options: lfoSyncOptions)
      p[partPre + [.filter, .env, .trigger]] = RangeParam(byte: 276 + part, maxVal: 1)
      p[partPre + [.filter, .env, .trigger, .channel]] = RangeParam(byte: 280 + part, maxVal: 15, displayOffset: 1)
      p[partPre + [.filter, .env, .trigger, .note]] = OptionsParam(byte: 284 + part, options: trigNoteOptions)
      p[partPre + [.amp, .env, .trigger]] = RangeParam(byte: 288 + part, maxVal: 1)
      p[partPre + [.amp, .env, .trigger, .channel]] = RangeParam(byte: 292 + part, maxVal: 15, displayOffset: 1)
      p[partPre + [.amp, .env, .trigger, .note]] = OptionsParam(byte: 296 + part, options: trigNoteOptions)
      p[partPre + [.morph, .trigger]] = RangeParam(byte: 300 + part, maxVal: 1)
      p[partPre + [.morph, .trigger, .channel]] = RangeParam(byte: 304 + part, maxVal: 15, displayOffset: 1)
      p[partPre + [.morph, .trigger, .note]] = OptionsParam(byte: 308 + part, options: trigNoteOptions)
      
      p[partPre + [.on]] = RangeParam(byte: 324 + part, maxVal: 1)
      p[partPre + [.pgm]] = RangeParam(byte: 328 + part, maxVal: 98)
      p[partPre + [.bank]] = OptionsParam(byte: 332 + part, options: ["Int","1 (Card)","2 (Card)","3 (Card)"])
      p[partPre + [.channel, .pressure, .amt]] = RangeParam(byte: 336 + part, maxVal: 7)
      p[partPre + [.channel, .pressure, .dest]] = OptionsParam(byte: 340 + part, options: destOptions)
      p[partPre + [.foot, .amt]] = RangeParam(byte: 344 + part, maxVal: 7)
      p[partPre + [.foot, .dest, .note]] = OptionsParam(byte: 348 + part, options: destOptions)
    }

    p[[.bend]] = OptionsParam(byte: 312, options: ["1","2","3","4","7","10","12","24","48"])
    p[[.unison, .detune]] = RangeParam(byte: 313, maxVal: 8)
    p[[.out, .mode, .i(0)]] = OptionsParam(byte: 314, bits: 0...3, options: ["ab1","ab2","ab3","ab4"])
    p[[.out, .mode, .i(1)]] = OptionsParam(byte: 314, bits: 4...7, options: ["cd-","cd1","cd2","cd3","cd4"])
    p[[.deviceId]] = RangeParam(byte: 315, maxVal: 15, displayOffset: 1)
    p[[.pgmChange]] = RangeParam(byte: 316, maxVal: 1)
    p[[.midi, .ctrl]] = RangeParam(byte: 317, maxVal: 1)
//    p[[.tune]] = RangeParam(byte: 318, range: -99...99)
    p[[.pedal, .type]] = RangeParam(byte: 319, maxVal: 2)
    p[[.local, .ctrl]] = RangeParam(byte: 320, maxVal: 1)
    p[[.key, .octave, .shift]] = RangeParam(byte: 321, maxVal: 4)
    p[[.select, .channel]] = RangeParam(byte: 322, maxVal: 3)
    p[[.arp, .out]] = RangeParam(byte: 323, maxVal: 1)
    
    p[[.split]] = RangeParam(byte: 352, maxVal: 1)
    p[[.split, .pt]] = RangeParam(byte: 353, maxVal: 127)
    
    return p
  }()
  
  static let lfoSyncOptions = OptionsParam.makeOptions(["2 bar","1 bar","1/2","1/4","1/8","1/8 triplet","1/16"])
  
  static let trigNoteOptions: [Int:String] = OptionsParam.makeOptions((23...127).map {
    $0 == 23 ? "Off" : "\($0)"
  })
  
  static let destOptions = OptionsParam.makeOptions(["LFO 1 Amt","LFO 2 Amt","Cutoff","FM Amt","Osc 2 Pitch"])
  
}

  // name is in separate msg in banks

class EvolverVoicePatch : ByteBackedSysexPatch, BankablePatch {
  
  /// Includes 2nd sysex msg for name data
  func sysexData(bank: Int, location: Int) -> [Data] {
    var data = Data([0xf0, 0x01, 0x20, 0x01, 0x02, UInt8(bank), UInt8(location)])
    data.append78(bytes: bytes, count: type(of: self).dataByteCount)
    data.append(0xf7)
    
    // append name bytes
    var nameData = Data([0xf0, 0x01, 0x20, 0x01, 0x11, UInt8(bank), UInt8(location)])
    let n = String(name.unicodeScalars.filter { return $0.isASCII }) as NSString
    let nameBytes = (16).map(i =>  $0 < n.length ? UInt8(n.character(at: $0)) & 0x7f : 32 )
    nameData.append(contentsOf: nameBytes)
    nameData.append(0xf7)
    return [data, nameData]
  }
  
  func randomize() {
    randomizeAllParams()
    self["trigger"] = 0
    self["amp/level"] = 0
    self["extAudio"] = 0
    self["extAudio/volume"] = 0
    self["transpose"] = 37
    self["hi/cutoff"] = 0
    self["amp/volume"] = ([50, 100]).random()!
    self["osc/0/semitone"] = 0
    self["osc/1/semitone"] = 0
    self["osc/2/semitone"] = 0
    self["osc/3/semitone"] = 0
  }
  

}

const noteIso = Miso.noteName(zeroNote: "C-2")

const seqFrmt: ParamValueFormatter = {
  switch $0 {
  case 101: return "Reset"
  case 102: return "Off"
  default: return `${$0}`
  }
}

const waveOptions = ["Saw","Tri","Saw/Tri","Pulse"]

const glideFrmt: ParamValueFormatter = {
  switch $0 {
  case [0, 100]:
    return `${$0}`
  case [101, 199]:
    return `F${$0 - 99}`
  default:
    return "Off"
  }
}

const keyAssignOptions = ["Low Note","Low Note w/ retrig","High Note","High Note w/ retrig","Last Note","Last Note w/ retrig"]

const lfoFreqOptions = ["Unsynced","32 steps","16 steps","8 steps","4 steps","2 steps","1 step","1/2 step","1/4 step","1/8 step","1/16 step"]

const lfoWaveOptions = ["Tri","Rev Saw","Saw","Square","Random"]

const clockDivOptions = ["1/2","1/4","1/8","1/8 half swing","1/8 full swing","1/8 triplets","1/16","1/16 half swing","1/16 full swing","1/16 triplets","1/32","1/32 triplets","1/64 triplets"]

const syncDelayOptions = ["Unsynced","32 steps","16 steps","8 steps","4 steps","2 steps","1 step","1/2 step","1/4 step","1/8 step","1/16 step","6 steps","3 steps","1.5 steps","2/3 step","1/3 step","1/6 step"]

const modDestOptions = ["Off", "Osc 1 Freq", "Osc 2 Freq", "Osc 3 Freq", "Osc 4 Freq", "Osc All Freq", "Osc 1 Level", "Osc 2 Level", "Osc 3 Level", "Osc 4 Level", "Osc All Level", "Noise Level", "Ext In Level", "Osc 1 PW", "Osc 2 PW", "Osc All PW", "FM Osc 4 -> 3", "FM Osc 3 -> 4", "Ring Osc 4 -> 3", "Ring Osc 3 -> 4", "Filt Freq", "Filt Split", "Resonance", "Highpass Freq", "VCA Amt", "Pan", "Feedback Freq", "Feedback Amt", "Delay Time 1", "Delay Time 2", "Delay Time 3", "Delay Time All", "Delay Amt 1", "Delay Amt 2", "Delay Amt 3", "Delay Amt All", "Delay Feedbk 1", "Delay Feedbk 2", "LFO 1 Freq", "LFO 2 Freq", "LFO 3 Freq", "LFO 4 Freq", "LFO All Freq", "LFO 1 Amt", "LFO 2 Amt", "LFO 3 Amt", "LFO 4 Amt", "LFO A Amt", "Env 1 Amt", "Env 2 Amt", "Env 3 Amt", "Env A Amt", "Env 1 Attack", "Env 2 Attack", "Env 3 Attack", "Env A Attack", "Env 1 Decay", "Env 2 Decay", "Env 3 Decay", "Env A Decay", "Env 1 Rel", "Env 2 Rel", "Env 3 Rel", "Env A Rel", "Filt 1 (L) Cutoff", "Filt 2 (R) Cutoff", "Filt 1 (L) Reson", "Filt 2 (R) Reson", "Distortion"]

const seqDestOptions = ["Off", "Osc 1 Freq", "Osc 2 Freq", "Osc 3 Freq", "Osc 4 Freq", "Osc All Freq", "Osc 1 Level", "Osc 2 Level", "Osc 3 Level", "Osc 4 Level", "Osc All Level", "Noise Level", "Ext In Level", "Osc 1 PW", "Osc 2 PW", "Osc All PW", "FM Osc 4 -> 3", "FM Osc 3 -> 4", "Ring Osc 4 -> 3", "Ring Osc 3 -> 4", "Filt Freq", "Filt Split", "Resonance", "Highpass Freq", "VCA Amt", "Pan", "Feedback Freq", "Feedback Amt", "Delay Time 1", "Delay Time 2", "Delay Time 3", "Delay Time All", "Delay Amt 1", "Delay Amt 2", "Delay Amt 3", "Delay Amt All", "Delay Feedbk 1", "Delay Feedbk 2", "LFO 1 Freq", "LFO 2 Freq", "LFO 3 Freq", "LFO 4 Freq", "LFO All Freq", "LFO 1 Amt", "LFO 2 Amt", "LFO 3 Amt", "LFO 4 Amt", "LFO A Amt", "Env 1 Amt", "Env 2 Amt", "Env 3 Amt", "Env A Amt", "Env 1 Attack", "Env 2 Attack", "Env 3 Attack", "Env A Attack", "Env 1 Decay", "Env 2 Decay", "Env 3 Decay", "Env A Decay", "Env 1 Rel", "Env 2 Rel", "Env 3 Rel", "Env A Rel", "Filt 1 (L) Cutoff", "Filt 2 (R) Cutoff", "Filt 1 (L) Reson", "Filt 2 (R) Reson", "Distortion", "Clock Mult", "Note Out", "Velo Out", "Mod Wh Out", "Pressure Out", "Breath Out", "Foot Out"]

const modSrcOptions = ["None", "Seq 1", "Seq 2", "Seq 3", "Seq 4", "LFO 1", "LFO 2", "LFO 3", "LFO 4", "Filter Env", "Amp Env", "Env 3", "Ext In Peak", "Ext In Env Follow", "Pitch Bend", "Mod Wheel", "Pressure", "Breath", "Foot", "Note Velo", "Note #", "Expr", "Noise", "Osc 3", "Osc 4", ]


const parms = [
  ["osc/0/semitone", { b: 0, max: 120, iso: noteIso }],
  ["osc/0/detune", { b: 1, max: 100, dispOff: -50 }],
  ["osc/0/shape", { b: 2, max: 102 }],
  ["osc/0/level", { b: 3, max: 100 }],
  ["osc/1/semitone", { b: 4, max: 120, iso: noteIso }],
  ["osc/1/detune", { b: 5, max: 100, dispOff: -50 }],
  ["osc/1/shape", { b: 6, max: 102 }],
  ["osc/1/level", { b: 7, max: 100 }],
  ["osc/2/semitone", { b: 8, max: 120, iso: noteIso }],
  ["osc/2/detune", { b: 9, max: 100, dispOff: -50 }],
  ["osc/2/shape", { b: 10, dispOff: 1 }],
  ["osc/2/level", { b: 11, max: 100 }],
  ["osc/3/semitone", { b: 12, max: 120, iso: noteIso }],
  ["osc/3/detune", { b: 13, max: 100, dispOff: -50 }],
  ["osc/3/shape", { b: 14, dispOff: 1 }],
  ["osc/3/level", { b: 15, max: 100 }],
  
  ["filter/cutoff", { b: 16, max: 164 }],
  ["filter/env/amt", { b: 17, max: 198, dispOff: -99 }],
  ["filter/env/attack", { b: 18, max: 110 }],
  ["filter/env/decay", { b: 19, max: 110 }],
  ["filter/env/sustain", { b: 20, max: 100 }],
  ["filter/env/release", { b: 21, max: 110 }],
  ["filter/reson", { b: 22, max: 100 }],
  ["filter/keyTrk", { b: 23, max: 100 }],
  
  ["amp/level", { b: 24, max: 100 }],
  ["amp/env/amt", { b: 25, max: 100 }],
  ["amp/env/attack", { b: 26, max: 110 }],
  ["amp/env/decay", { b: 27, max: 110 }],
  ["amp/env/sustain", { b: 28, max: 100 }],
  ["amp/env/release", { b: 29, max: 110 }],
  ["pan", { b: 30, opts: ["Full Wide", "Mostly Wide", "Lil Wide", "Mono", "Lil Cross", "Mostly Cross", "Full Cross"] }],
  ["amp/volume", { b: 31, max: 100 }],
  
  ["feedback/freq", { b: 32, max: 48 }],
  ["feedback/amt", { b: 33, max: 100 }],
  ["grunge", { b: 34, max: 1 }],
  ["delay/0/time", { b: 35, max: 166 }],
  ["delay/0/level", { b: 36, max: 100 }],
  ["delay/feedback/delay", { b: 37, max: 100 }],
  ["delay/feedback/filter", { b: 38, max: 100 }],
  ["out/hack", { b: 39, max: 14 }],
  
  ["lfo/0/freq", { b: 40, max: 160 }],
  ["lfo/0/shape", { b: 41, opts: lfoWaveOptions }],
  ["lfo/0/amt", { b: 42, max: 200 }],
  ["lfo/0/sync", { b: 42, max: 200 }],
  ["lfo/0/dest", { b: 43, opts: modDestOptions }],
  ["lfo/1/freq", { b: 44, max: 160 }],
  ["lfo/1/shape", { b: 45, opts: lfoWaveOptions }],
  ["lfo/1/amt", { b: 46, max: 200 }],
  ["lfo/1/sync", { b: 46, max: 200 }],
  ["lfo/1/dest", { b: 47, opts: modDestOptions }],
  
  ["env/2/amt", { b: 48, max: 198, dispOff: -99 }],
  ["env/2/dest", { b: 49, opts: modDestOptions }],
  ["env/2/env/attack", { b: 50, max: 110 }],
  ["env/2/env/decay", { b: 51, max: 110 }],
  ["env/2/env/sustain", { b: 52, max: 100 }],
  ["env/2/env/release", { b: 53, max: 110 }],
  
  ["trigger", { b: 54, opts: ["All", "Seq Only", "MIDI Only", "MIDI Reset", "Combo", "Combo Reset", "Ext In Env", "Ext In Env Reset", "Ext In Seq", "Ext In Seq Reset", "Seq Once", "Seq Reset", "Ext Trig", "Seq 1 Step"] }],
  p["transpose"] = RangeParam(byte: 55, maxVal: 73, formatter: {
    $0 == 0 ? "Key Off" : `${$0 - 37}`
  })
  
  ["seq/0/dest", { b: 56, opts: seqDestOptions }],
  ["seq/1/dest", { b: 57, opts: seqDestOptions }],
  ["seq/2/dest", { b: 58, opts: seqDestOptions }],
  ["seq/3/dest", { b: 59, opts: seqDestOptions }],
  ["noise", { b: 60, max: 100 }],
  ["extAudio", { b: 61, max: 100 }],
  ["extAudio/volume", { b: 62, opts: ["Stereo", "Left", "Right", "L Audio/R Ctrl"] }],
  ["extAudio/hack", { b: 63, max: 14 }],
  
  ["osc/0/glide", { b: 64, max: 200, formatter: glideFrmt }],
  ["osc/0/sync", { b: 65, max: 1 }],
  ["tempo", { b: 66, rng: [30, 250] }],
  ["clock/divide", { b: 67, opts: clockDivOptions }],
  ["osc/1/glide", { b: 68, max: 200, formatter: glideFrmt }],
  ["slop", { b: 69, max: 5 }],
  ["bend", { b: 70, max: 12 }],
  ["key/mode", { b: 71, opts: keyAssignOptions }],
  ["osc/2/glide", { b: 72, max: 200, formatter: glideFrmt }],
  ["osc/2/fm", { b: 73, max: 100 }],
  ["osc/2/shape/mod", { b: 74, opts: ["Off", "Seq 1", "Seq 2", "Seq 3", "Seq 4"] }],
  ["osc/2/ringMod", { b: 75, max: 100 }],
  ["osc/3/glide", { b: 76, max: 200, formatter: glideFrmt }],
  ["osc/3/fm", { b: 77, max: 100 }],
  ["osc/3/shape/mod", { b: 78, opts: ["Off", "Seq 1", "Seq 2", "Seq 3", "Seq 4"] }],
  ["osc/3/ringMod", { b: 79, max: 100 }],
  
  ["filter/fourPole", { b: 80, max: 1 }],
  ["filter/env/velo", { b: 81, max: 100 }],
  ["filter/mod", { b: 82, max: 100 }],
  ["filter/split", { b: 83, max: 100 }],
  ["hi/cutoff", { b: 84, max: 199 }],
  ["mod/0/src", { b: 85, opts: modSrcOptions }],
  ["mod/0/amt", { b: 86, max: 198, dispOff: -99 }],
  ["mod/0/dest", { b: 87, opts: modDestOptions }],
  ["env/mode", { b: 88, opts: ["Exp", "Lin"] }],
  ["amp/env/velo", { b: 89, max: 100 }],
  ["mod/1/src", { b: 90, opts: modSrcOptions }],
  ["mod/1/amt", { b: 91, max: 198, dispOff: -99 }],
  ["mod/1/dest", { b: 92, opts: modDestOptions }],
  ["mod/2/src", { b: 93, opts: modSrcOptions }],
  ["mod/2/amt", { b: 94, max: 198, dispOff: -99 }],
  ["mod/2/dest", { b: 95, opts: modDestOptions }],
  ["mod/3/src", { b: 96, opts: modSrcOptions }],
  ["mod/3/amt", { b: 97, max: 198, dispOff: -99 }],
  ["mod/3/dest", { b: 98, opts: modDestOptions }],
  
  ["delay/1/time", { b: 99, max: 166 }],
  ["delay/1/level", { b: 100, max: 100 }],
  ["delay/2/time", { b: 101, max: 166 }],
  ["delay/2/level", { b: 102, max: 100 }],
  
  ["dist", { b: 103, max: 199 }],
  
  ["lfo/2/freq", { b: 104, max: 160 }],
  ["lfo/2/shape", { b: 105, opts: lfoWaveOptions }],
  ["lfo/2/amt", { b: 106, max: 200 }],
  ["lfo/2/sync", { b: 106, max: 200 }],
  ["lfo/2/dest", { b: 107, opts: modDestOptions }],
  ["lfo/3/freq", { b: 108, max: 160 }],
  ["lfo/3/shape", { b: 109, opts: lfoWaveOptions }],
  ["lfo/3/amt", { b: 110, max: 200 }],
  ["lfo/3/sync", { b: 110, max: 200 }],
  ["lfo/3/dest", { b: 111, opts: modDestOptions }],
  
  ["env/2/delay", { b: 112, max: 100 }],
  ["env/2/velo", { b: 113, max: 100 }],
  ["extAudio/peak/amt", { b: 114, max: 198, dispOff: -99 }],
  ["extAudio/peak/dest", { b: 115, opts: modDestOptions }],
  ["extAudio/follow/amt", { b: 116, max: 198, dispOff: -99 }],
  ["extAudio/follow/dest", { b: 117, opts: modDestOptions }],
  ["velo/amt", { b: 118, max: 198, dispOff: -99 }],
  ["velo/dest", { b: 119, opts: modDestOptions }],
  ["modWheel/amt", { b: 120, max: 198, dispOff: -99 }],
  ["modWheel/dest", { b: 121, opts: modDestOptions }],
  ["pressure/amt", { b: 122, max: 198, dispOff: -99 }],
  ["pressure/dest", { b: 123, opts: modDestOptions }],
  ["breath/amt", { b: 124, max: 198, dispOff: -99 }],
  ["breath/dest", { b: 125, opts: modDestOptions }],
  ["foot/amt", { b: 126, max: 198, dispOff: -99 }],
  ["foot/dest", { b: 127, opts: modDestOptions }],
  
  (0..<4).forEach { seq in
    (0..<16).forEach { step in
      let poff = seq * 16 + step
      ["seq/seq/step/step", { b: 128 + poff, max: 102, formatter: seqFrmt }],
    }
  }
]


  static func location(forData data: Data) -> Int { return Int(data[6]) }

// 226 for edit buffer; 228 for pgm; 252 for pgm with name; 24 is for just name sysex
const fileDataCount = 226
const dataByteCount = 220 // number of data bytes in packed format


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

  /// Saved as edit buffer, no name.
const sysexData = {
  var data = Data([0xf0, 0x01, 0x20, 0x01, 0x03])
  data.append78(bytes: bytes, count: .dataByteCount)
  data.append(0xf7)
  return data
}

const patchTruss = {
  parms: parms,
  initFile: "evolver-voice-init",
  validSizes: ['auto', 228, 252, 24],
}

const patchTransform = {
  throttle: 200,
  param: (path, parm, value) => {
    if path.first == .seq && path.last != .dest {
      guard let seq = path.i(1), let step = path.i(3) else { return nil }
      let lNib = UInt8(value) & 0x0f
      let mNib = (UInt8(value) >> 4) & 0x0f
      return [Data([0xf0, 0x01, 0x20, 0x01, 0x08, UInt8(seq * 16 + step), lNib, mNib, 0xf7])]
    }
    else {
      // use byte instead of passed value bc some params are 2-in-1-byte
      let lNib = patch.bytes[param.byte] & 0x0f
      let mNib = (patch.bytes[param.byte] >> 4) & 0x0f
      return [Data([0xf0, 0x01, 0x20, 0x01, 0x01, UInt8(param.byte), lNib, mNib, 0xf7])]
    }

  },
  singlePatch: [[sysexData, 10]], 
}

const bankTransform = bank => ({
  throttle: 0,
  singleBank: loc => [[sysexData(bank, loc), 50]],
})

class EvolverTypeVoiceBank<T:EvolverVoicePatch> : TypicalTypedSysexPatchBank<T> {
  
  override class var patchCount: Int { return 128 }
  override class var initFileName: String { return "evolver-voice-bank-init" }
  override class var fileDataCount: Int { return patchCount * 252 }
  
  override class func isValid(fileSize: Int) -> Bool {
    return [fileDataCount, 29184].contains(fileSize)
  }

  override func fileData() -> Data {
    return sysexData(transform: { (patch, location) -> Data in
      return Data(patch.sysexData(bank: 0, location: location).joined())
    })
  }
}

class EvolverVoiceBank : EvolverTypeVoiceBank<EvolverVoicePatch> { }

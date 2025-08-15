



const keyRangeIso = Miso.noteName(zeroNote: "C-1")

const ctrlSrcOptions = ["Mod", "After", "Exp", "Breath", "P Bend", "Foot"]

const ctrlDestOptions = ["FX Bal", "Ds Drv", "Ph Man", "Ph Rat", "Ph Res", "Ph Mix", "En Mix", "Ch Rat", "Ch Fdb", "Ch Lvl", "Dl Fdb", "Dl Lvl", "Rv Tim", "Rv Lvl"]

const phaseFreqIso = Miso.switcher([
  .range([0, 25], Miso.m(10.0000000282265) >>> Miso.a(49.9999997692986)),
  .range([26, 49], Miso.m(29.9999999865915) >>> Miso.a(-459.999999813094)),
  .range([50, 85], Miso.m(199.999999966054) >>> Miso.a(-8899.99999766912)),
  .range([86, 99], Miso.m(499.999999906003) >>> Miso.a(-34499.9999910922)),
]) >>> Miso.hzKhz(round: 1)

const chorusRateMiso = Miso.a(1) >>> Miso.m(0.1) >>> Miso.round(1) >>> Miso.unitFormat("Hz")

const chorusDelayIso = Miso.switcher([
  .range([0, 49], Miso.m(0.100000047696406) >>> Miso.a(0.0999992368571603)),
  .range([50, 58], Miso.m(0.500000509605718) >>> Miso.a(-19.5000313438840)),
  .range([59, 99], Miso.m(0.999999950677264) >>> Miso.a(-48.9999957582447)),
]) >>> Miso.round(1) >>> Miso.unitFormat("ms")

const delayModeOptions = ["Normal", "MIDI Tempo", "Manual Tempo"]

const delayTimeIso = Miso.switcher([
  .int(246, "16th"),
  .int(247, "trip 8th"),
  .int(248, "8th"),
  .int(249, "trip 1/4"),
  .int(250, "dot 8th"),
  .int(251, "1/4"),
  .int(252, "trip 1/2"),
  .int(253, "dot 1/4"),
  .int(254, "1/2"),
  .int(255, "1/1"),
], default: Miso.switcher([
  .range([0, 49], Miso.m(0.100000440891873) >>> Miso.a(0.0999929456811404)),
  .range([50, 59], Miso.m(0.500019596432311) >>> Miso.a(-19.5010737172579)),
  .range([60, 89], Miso.m(1.00000080721755) >>> Miso.a(-49.0000649504459)),
  .range([90, 104], Miso.m(9.99999969893828) >>> Miso.a(-849.999969616484)),
  .range([105, 245], Miso.m(20.0000000010745) >>> Miso.a(-1900.00000021346)),
]) >>> Miso.msSec(round: 2))

const feedBackIso = Miso.a(-49) >>> Miso.m(2) >>> Miso.unitFormat("%")
  
const reverbTimeIso = Miso.switcher([
  .range([0, 79], Miso.m(0.100000008277927) >>> Miso.a(0.0999997847738637)),
  .range([80, 95], Miso.m(0.500000533235464) >>> Miso.a(-31.5000463392955)),
  .range([96, 99], Miso.m(1.00000702039767) >>> Miso.a(-79.0006879990425)),
]) >>> Miso.round(1) >>> Miso.unitFormat("s")


const commonParms = [
  ["level", { b: 0x10, max: 100 }],
  ["pan", { b: 0x11, max: 100, dispOff: -50 }],
  ["analogFeel", { b: 0x12, max: 100 }],
  ["priority", { b: 0x13, opts: ["Last", "Loudest"] }],
  ["bend/down", { b: 0x14, max: 48 }],
  ["bend/up", { b: 0x15, max: 12 }],
  ["ctrl/src/0", { b: 0x16, opts: ctrlSrcOptions }],
  ["ctrl/src/1", { b: 0x17, opts: ctrlSrcOptions }],
  ["tone/0/on", { b: 0x18, bit: 0 }],
  ["tone/1/on", { b: 0x18, bit: 1 }],
  ["tone/2/on", { b: 0x18, bit: 2 }],
  ["tone/3/on", { b: 0x18, bit: 3 }],
  ["tone/0/active", { b: 0x19, bit: 0 }],
  ["tone/1/active", { b: 0x19, bit: 1 }],
  ["tone/2/active", { b: 0x19, bit: 2 }],
  ["tone/3/active", { b: 0x19, bit: 3 }],
  ["porta", { b: 0x1a, max: 1 }],
  ["porta/mode", { b: 0x1b, opts: JD800CommonPatch.portaModeOptions }],
  ["porta/type", { b: 0x1c, opts: ["Time", "Rate"] }],
  ["porta/time", { b: 0x1d, max: 100 }],
  ["solo", { b: 0x1e, max: 1 }],
  ["solo/legato", { b: 0x1f, max: 1 }],
  ["solo/sync", { b: 0x20, opts: ["Off", "A", "B", "C", "D"] }],
  ["lo/freq", { b: 0x21, opts: JD800CommonPatch.loFreqOptions }],
  ["lo/gain", { b: 0x22, max: 30, dispOff: -15 }],
  ["mid/freq", { b: 0x23, opts: JD800CommonPatch.midFreqOptions }],
  ["mid/q", { b: 0x24, opts: JD800CommonPatch.midQOptions }],
  ["mid/gain", { b: 0x25, max: 30, dispOff: -15 }],
  ["hi/freq", { b: 0x26, opts:JD800CommonPatch.hiFreqOptions }],
  ["hi/gain", { b: 0x27, max: 30, dispOff: -15 }],
  ["structure/0", { b: 0x28, max: 5 }],
  ["structure/1", { b: 0x29, max: 5 }],
  (0..<4).forEach {
    ["tone/$0/key/lo", { b: 0x2a + $0, iso: keyRangeIso }],
    ["tone/$0/key/hi", { b: 0x2e + $0, iso: keyRangeIso }],
    ["velo/range/$0", { b: 0x32 + $0, opts: ["All", "Low", "High"] }],
    ["velo/pt/$0", { b: 0x36 + $0, rng: [1, 127] }],
    ["velo/fade/$0", { b: 0x3a + $0 }],
  }
  
  ["fx/1/balance", { b: 0x3e, max: 100 }],
  ["fx/ctrl/src/0", { b: 0x3f, opts: ctrlSrcOptions }],
  ["fx/ctrl/dest/0", { b: 0x40, opts: ctrlDestOptions }],
  ["fx/ctrl/depth/0", { b: 0x41, max: 100, dispOff: -50 }],
  ["fx/ctrl/src/1", { b: 0x42, opts: ctrlSrcOptions }],
  ["fx/ctrl/dest/1", { b: 0x43, opts: ctrlDestOptions }],
  ["fx/ctrl/depth/1", { b: 0x44, max: 100, dispOff: -50 }],
  ["fx/0/seq", { b: 0x45, opts: JD800FXPatch.fxBlockASeqOptions }],
  ["fx/0/part/0/on", { b: 0x46, max: 1 }],
  ["fx/0/part/1/on", { b: 0x47, max: 1 }],
  ["fx/0/part/2/on", { b: 0x48, max: 1 }],
  ["fx/0/part/3/on", { b: 0x49, max: 1 }],
  ["dist/type", { b: 0x4a, opts: JD800FXPatch.distTypeOptions }],
  ["dist/drive", { b: 0x4b, max: 100 }],
  ["dist/level", { b: 0x4c, max: 100 }],
  ["phase/freq", { b: 0x4d, max: 99, iso: phaseFreqIso }],
  ["phase/rate", { b: 0x4e, max: 99, iso: chorusRateMiso }],
  ["phase/depth", { b: 0x4f, max: 100 }],
  ["phase/reson", { b: 0x50, max: 100 }],
  ["phase/mix", { b: 0x51, max: 100 }],
  (0..<6).forEach {
    ["spectral/$0", { b: 0x52 + $0, max: 30, dispOff: -15 }],
  }
  ["spectral/skirt", { b: 0x58, max: 4, dispOff: 1 }],
  ["extra/sens", { b: 0x59, max: 100 }],
  ["extra/mix", { b: 0x5a, max: 100 }],
  ["fx/1/seq", { b: 0x5b, opts: JD800FXPatch.fxBlockBSeqOptions }],
  ["fx/1/part/0/on", { b: 0x5c, max: 1 }],
  ["fx/1/part/1/on", { b: 0x5d, max: 1 }],
  ["fx/1/part/2/on", { b: 0x5e, max: 1 }],
  ["chorus/rate", { b: 0x5f, max: 99, iso: chorusRateMiso }],
  ["chorus/depth", { b: 0x60, max: 100 }],
  ["chorus/delay", { b: 0x61, max: 99, iso: chorusDelayIso }],
  ["chorus/feedback", { b: 0x62, max: 98, iso: feedBackIso }],
  ["chorus/level", { b: 0x63, max: 100 }],
  ["delay/mode", { b: 0x64, opts: delayModeOptions }],
  ["delay/mid/time", { p: 2, b: 0x65, max: 255, iso: delayTimeIso }],
  ["delay/mid/level", { b: 0x67, max: 100 }],
  ["delay/left/time", { p: 2, b: 0x68, max: 255, iso: delayTimeIso }],
  ["delay/left/level", { b: 0x6a, max: 100 }],
  ["delay/right/time", { p: 2, b: 0x6b, max: 255, iso: delayTimeIso }],
  ["delay/right/level", { b: 0x6d, max: 100 }],
  ["delay/feedback", { b: 0x6e, max: 98, iso: feedBackIso }],
  ["reverb/type", { b: 0x6f, opts: JD800FXPatch.reverbTypeOptions }],
  ["reverb/pre", { b: 0x70, max: 120 }],
  ["reverb/early", { b: 0x71, max: 100 }],
  ["reverb/hi/cutoff", { b: 0x72, opts: JD800FXPatch.reverbHiCutoffOptions }],
  ["reverb/time", { b: 0x73, max: 100, iso: reverbTimeIso }],
  ["reverb/level", { b: 0x74, max: 100 }],
  ["octave", { b: 0x75, opts: ["-1", "0", "+1"] }],
]

const commonWerk = {
  single: 'voice.common',
  namePack: [0, 0x0f],
  size: 0x76,
  parms: commonParms,
  // func randomize() {
  //   self["level"] = 100
  //   self["pan"] = 50
  // 
  //   (0..<4).forEach {
  //     self["tone/$0/on"] = 1
  //     self["velo/range/$0"] = 0
  //     self["velo/pt/$0"] = 64
  //     self["velo/fade/$0"] = 0
  //     self["tone/$0/key/lo"] = 0
  //     self["tone/$0/key/hi"] = 127
  //   }
}

// TONE

const waveOptions = ["Syn Saw 1", "Syn Saw 2", "FAT Saw", "FAT Square", "Syn Pulse 1", "Syn Pulse2", "Syn Pulse3", "Syn Pulse4", "Syn Pulse5", "Pulse Mod", "Triangle", "Syn Sine", "Soft Pad", "Wire Str", "MIDI Clav", "Spark Vox1", "Spark Vox2", "Syn Sax", "Clav Wave", "Cello Wave", "Bright Digi", "Cutters", "Syn Bass", "Rad Hose", "Vocal Wave", "Wally Wave", "Brusky Ip", "Digiwave", "Can Wave 1", "Can Wave 2", "EML 5th", "Wave Scan", "Nasty ", "Wave Table", "Fine Wine", "Funk Bass 1", "Funk Bass 2", "Strat Sust", "Harp Harm", "Full Organ", "Full Draw", "Doo", "Zzz Vox", "Org Vox", "Male Vox", "Kalimba", "Xylo", "Marim Wave", "Log Drum", "AgogoBells", "Bottle Hit", "Gamelan 1", "Gamelan 2", "Gamelan 3", "Tabla", "Pole lp", "Pluck Harp", "Nylon Str", "Hooky", "Muters", "Klack Wave", "Crystal", "Digi Bell", "FingerBell", "Digi Chime", "Bell Wave", "Org Bell", "Scrape Gut", "Strat Atk", "Hellow Bs", "Piano Atk", "EP Hard", "Clear Keys", "EP Distone", "Flute Push", "Shami", "Wood Crak", "Kimba Atk", "Block", "Org Atk 1", "Org Atk 2", "Cowbell", "Sm Metal", "StrikePole", "Pizz", "Switch", "Tuba Slap", "Plink", "Plunk", "EP Atk", "TVF Trig", "Flute Tone", "Pan Pipe", "Bottle Blow", "Shaku Atk", "FlugelWave", "French", "White Noise", "Pink Noise", "Pitch Wind", "Vox Noise 1", "Vox Noise2", "Crunch Wind", "ThroatWind", "Metal Wind", "Windago", "Anklungs", "Wind Chime 1", "Ac Piano 1", "SA Rhodes 1", "SA Rhodes 2", "E.Piano 1", "E.Piano 2", "Clav 1", "Organ 1", "Jazz Organ", "Pipe Organ", "Nylon GTR", "6STR GTR", "GTR HARM", "Mute GTR 1", "Pop Strat", "Stratus", "SYN GTR", "Harp 1", "Pick Bass", "E.Bass", "Fretless 1", "Upright BS", "Slap Bass 1", "Slap & Pop", "Slap Bass 2", "Slap Bass 3", "Flute 1", "Trumpet 1", "Trombone 1", "Harmon Mute 1", "Alto Sax 1", "Tenor Sax 1", "Blow Pipe", "Trumpet SECT", "Strings", "SYN VOX 1", "SYN VOX 2", "Org Vox 2", "Pop Voice", "Fantasynth", "Fanta Bell", "Vibes", "Steel Drums", "MMM VOX", "Lead Wave", "Feedbackwave", "Rattles", "Tin Wave", "Spectrum 1", "Solid Kick", "Room Kick", "808 K", "Long Hard SN", "808 SN", "90's SN", "Bigshot SN", "Power SN", "Power Tom", "Closed HH1", "Closed HH2", "Open HH", "Crash Cym", "Ride Cym", "808 Claps", "Maraca", "Cabasa Up", "Cabasa Down", "Slap Cga", "Mute Cga 1", "Mute Cga 2", "Hi Conga", "Lo Conga", "Snaps", "Tambourine", "Cowbell 2", "Saw +DC", "Sqr +DC", "Pulse 1 +DC", "Pulse2 +DC", "Pulse3 +DC", "Pulse4 +DC", "Pulse5 +DC", "Triangle +DC", "Sine +DC", "Loop 1", "Loop 2", "Loop 3", "Loop 4"]

const toneDelayTimeFrmt: ParamValueFormatter = {
  return `${$0}`
}

const cutoffKeyTrkFrmt: ParamValueFormatter = {
  return `${$0}`
}

const ctrlDestOptions = ["Pitch", "Cutoff", "Reson", "Level", "P-LFO1", "P-LFO2", "F-LFO1", "F-LFO2", "A-LFO1", "A-LFO2", "LFO1-R", "LFO2-R"]

const toneParms = [
  ["wave/group", { b: 0x00, opts: ["Int", "Card", "Exp"] }],
  ["wave/number", { p: 2, b: 0x01, opts: waveOptions }],
  ["fxm/color", { b: 0x03, max: 7, dispOff: 1 }],
  ["fxm/depth", { b: 0x04, max: 100 }],
  ["sync/on", { b: 0x05, max: 1 }],
  ["tone/delay/mode", { b: 0x06, opts: ["Normal", "Hold", "K-Off N", "K-Off D", "Playmate"] }],
  ["tone/delay/time", { b: 0x07, max: 127, formatter: toneDelayTimeFrmt }],
  ["pitch/coarse", { b: 0x08, max: 96, dispOff: -48 }],
  ["pitch/fine", { b: 0x09, max: 100, dispOff: -50 }],
  ["pitch/random", { b: 0x0a, max: 100 }],
  ["pitch/keyTrk", { b: 0x0b, opts: ["-100", "-50", "-20", "-10", "-5", "0", "5", "10", "20", "50", "98", "99", "100", "101", "102", "150", "200"] }],
  ["pitch/env/depth", { b: 0x0c, max: 24, dispOff: -12 }],
  ["bend/on", { b: 0x0d, max: 1 }],
  ["pitch/env/velo", { b: 0x0e, max: 100, dispOff: -50 }],
  ["pitch/env/time/velo", { b: 0x0f, max: 100, dispOff: -50 }],
  ["pitch/env/time/keyTrk", { b: 0x10, max: 20, dispOff: -10 }],
  ["pitch/env/level/-1", { b: 0x11, max: 100, dispOff: -50 }],
  ["pitch/env/time/0", { b: 0x12, max: 100 }],
  ["pitch/env/level/0", { b: 0x13, max: 100, dispOff: -50 }],
  ["pitch/env/time/1", { b: 0x14, max: 100 }],
  ["pitch/env/level/1", { b: 0x15, max: 100, dispOff: -50 }],
  ["pitch/env/time/2", { b: 0x16, max: 100 }],
  ["pitch/env/level/2", { b: 0x17, max: 100, dispOff: -50 }],
  ["filter/type", { b: 0x18, opts: ["HPF", "BPF", "LPF"] }],
  ["cutoff", { b: 0x19, max: 100 }],
  ["reson", { b: 0x1a, max: 100 }],
  ["cutoff/keyTrk", { b: 0x1b, formatter: cutoffKeyTrkFrmt }],
  ["filter/env/depth", { b: 0x1c, max: 100, dispOff: -50 }],
  ["filter/env/velo", { b: 0x1d, max: 100, dispOff: -50 }],
  ["filter/env/time/velo", { b: 0x1e, max: 100, dispOff: -50 }],
  ["filter/env/time/keyTrk", { b: 0x1f, max: 20, dispOff: -10 }],
  ["filter/env/time/0", { b: 0x20, max: 100 }],
  ["filter/env/level/0", { b: 0x21, max: 100 }],
  ["filter/env/time/1", { b: 0x22, max: 100 }],
  ["filter/env/level/1", { b: 0x23, max: 100 }],
  ["filter/env/time/2", { b: 0x24, max: 100 }],
  ["filter/env/level/2", { b: 0x25, max: 100 }],
  ["filter/env/time/3", { b: 0x26, max: 100 }],
  ["filter/env/level/3", { b: 0x27, max: 100 }],
  ["level", { b: 0x28, max: 100 }],
  ["bias/direction", { b: 0x29, opts: ["Upper", "Lower", "Up & Low"] }],
  ["bias/pt", { b: 0x2a }],
  ["bias/level", { b: 0x2b, max: 20, dispOff: -10 }],
  p["pan"] = RangeParam(byte: 0x2c, maxVal: 103, formatter: {
    switch $0 {
    case 101: return "Rnd"
    case 102: return "Alt-L"
    case 103: return "Alt-R"
    default:
      return `${$0-50}`
    }
  })
  ["pan/keyTrk", { b: 0x2d, opts: ["-100", "-70", "-50", "-40", "-30", "-20", "-10", "0", "10", "20", "30", "40", "50", "70", "100"] }],
  ["amp/env/velo", { b: 0x2e, max: 100, dispOff: -50 }],
  ["amp/env/time/velo", { b: 0x2f, max: 100, dispOff: -50 }],
  ["amp/env/time/keyTrk", { b: 0x30, max: 20, dispOff: -10 }],
  ["amp/env/time/0", { b: 0x31, max: 100 }],
  ["amp/env/level/0", { b: 0x32, max: 100 }],
  ["amp/env/time/1", { b: 0x33, max: 100 }],
  ["amp/env/level/1", { b: 0x34, max: 100 }],
  ["amp/env/time/2", { b: 0x35, max: 100 }],
  ["amp/env/level/2", { b: 0x36, max: 100 }],
  ["amp/env/time/3", { b: 0x37, max: 100 }],
  ["velo/curve", { b: 0x38, max: 6, dispOff: 1 }],
  ["hold/ctrl", { b: 0x39, max: 1 }],
  (0..<2).forEach { lfo in
    let off = lfo * 9
    ["lfo/lfo/wave", { b: 0x3a + off, opts: ["Tri", "Sin", "Saw", "Squ", "Trp", "S&H", "Rnd", "CHS"] }],
    ["lfo/lfo/rate", { b: 0x3b + off, max: 100 }],
    p["lfo/lfo/delay"] = RangeParam(byte: 0x3c + off, maxVal: 101, formatter: {
      return $0 == 101 ? "Rel" : `${$0}`
    })
    ["lfo/lfo/fade", { b: 0x3d + off, max: 100, dispOff: -50 }],
    ["lfo/lfo/offset", { b: 0x3e + off, opts: ["+", "0", "-"] }],
    ["lfo/lfo/key/trigger", { b: 0x3f + off, max: 1 }],
    ["lfo/lfo/pitch", { b: 0x40 + off, max: 100, dispOff: -50 }],
    ["lfo/lfo/filter", { b: 0x41 + off, max: 100, dispOff: -50 }],
    ["lfo/lfo/amp", { b: 0x42 + off, max: 100, dispOff: -50 }],
  }
  (0..<2).forEach { ctrl in
    (0..<4).forEach { dest in
      let off = ctrl * 8 + dest * 2
      ["ctrl/ctrl/dest/dest", { b: 0x4c + off, opts: ctrlDestOptions }],
      ["ctrl/ctrl/depth/dest", { b: 0x4d + off, max: 100, dispOff: -50 }],
    }
  }
]

const toneWerk = {
  single: 'voice.tone',
  parms: toneParms,
  size: 0x5c,
  initFile: "jd990-tone-init",
    // func randomize() {
    //   self["wave/group"] = 0
    //   self["level"] = ([80, 100]).random()!
    //   self["bias/level"] = 10
    //   self["amp/env/time/0"] = ([0, 50]).random()!
    //   self["tone/delay/mode"] = 0
    //   self["tone/delay/time"] = 0
    //   self["pitch/keyTrk"] = ([10, 14]).random()!
    //   self["pitch/coarse"] = 48
    //   self["pitch/fine"] = 50
    //   self["pitch/random"] = 0  
}

  static func location(forData data: Data) -> Int {
  return Int(addressBytes(forSysex: data)[1])
}

// Synth saves this as common message + tone msgs compacted!
func sysexData(deviceId: Int, address: RolandAddress) -> [Data] {
  // save common as one sysex msg
  var data = [Data]()
  if let common = addressables["common"] {
    data.append(contentsOf: common.sysexData(deviceId: deviceId, address: address))
  }

  // then tones as 2 more sysex msgs, compacted
  let toneData: [[Data]] = (0..<4).compactMap {
    let path: SynthPath = "tone/$0"
    guard let a = Self.subpatchAddresses[path] else { return nil }
    return addressables[path]?.sysexData(deviceId: deviceId, address: a)
  }
  let rData = RolandData(sysexData: [Data](toneData.joined()), addressableType: type(of: self))
  data.append(contentsOf: rData.sysexMsgs(deviceId: deviceId, offsetAddress: address))

  return data
}
const patchTruss = {
  multi: 'voice',
  map: [
    ["common", 0x0000, commonWerk],
    ["tone/0", 0x0076, toneWerk],
    ["tone/1", 0x0152, toneWerk],
    ["tone/2", 0x022e, toneWerk],
    ["tone/3", 0x030a, toneWerk],
  ],
  initFile: "jd990-voice-init",
  validSizes: [519, 'auto'],
}


// Note that although voice patches are semi-compact (tones are compacted, common is not),
//   the bank itself is just saved as all of the patches one after another, like a non-compact bank.
class JD990Bank<Patch:JD990MultiPatch & BankablePatch> : TypicalTypedRolandAddressableBank<Patch> {
  
  override class func offsetAddress(location: Int) -> RolandAddress {
    return RolandAddress([UInt8(location), 0, 0])
  }
  
}




const LSB = 0
const NRPN = 1
const AFX = 2
  
const oscWaveOptions = ["Sine", "Triangle", "Saw", "Pulse"]

const oscOctaveOptions = [
  63: "16'",
  64: "8'",
  65: "4'",
  66: "2'",
]

const subOscOctaveOptions: [Int:String] = {
  var opts = oscOctaveOptions
  opts[67] = "1'"
  return opts
}()

const coarseIso = Miso.options(coarseValues) >>> Miso.str()

// https://github.com/francoisgeorgy/BS2-Web/blob/master/src/bass-station-2/constants.js
const coarseValues = [-12.0, -11.9, -11.8, -11.7, -11.6, -11.5, -11.4, -11.3, -11.2, -11.1, -11.0, -10.9, -10.8, -10.7, -10.6, -10.5, -10.4, -10.2, -10.1, -10.0, -10.0, -9.9, -9.8, -9.7, -9.6, -9.5, -9.4, -9.3, -9.2, -9.1, -9.0, -9.0, -8.9, -8.8, -8.7, -8.6, -8.5, -8.4, -8.3, -8.2, -8.1, -8.0, -8.0, -7.9, -7.8, -7.7, -7.6, -7.5, -7.4, -7.3, -7.2, -7.1, -7.0, -7.0, -6.8, -6.7, -6.6, -6.5, -6.4, -6.3, -6.2, -6.1, -6.0, -6.0, -5.9, -5.8, -5.7, -5.6, -5.5, -5.4, -5.3, -5.2, -5.1, -5.0, -5.0, -4.9, -4.8, -4.7, -4.6, -4.5, -4.4, -4.3, -4.2, -4.1, -4.0, -4.0, -3.9, -3.8, -3.7, -3.6, -3.5, -3.3, -3.2, -3.1, -3.0, -3.0, -2.9, -2.8, -2.7, -2.6, -2.5, -2.4, -2.3, -2.2, -2.1, -2.0, -2.0, -1.9, -1.8, -1.7, -1.6, -1.5, -1.4, -1.3, -1.2, -1.1, -1.0, -1.0, -0.9, -0.8, -0.7, -0.6, -0.5, -0.4, -0.3, -0.2, -0.1,   0,   0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0, 1.0, 1.1, 1.2, 1.3, 1.4, 1.5, 1.6, 1.7, 1.8, 1.9, 2.0, 2.0, 2.1, 2.2, 2.3, 2.4, 2.5, 2.6, 2.7, 2.8, 2.9, 3.0, 3.0, 3.1, 3.2, 3.3, 3.5, 3.6, 3.7, 3.8, 3.9, 4.0, 4.0, 4.1, 4.2, 4.3, 4.4, 4.5, 4.6, 4.7, 4.8, 4.9, 5.0, 5.0, 5.1, 5.2, 5.3, 5.4, 5.5, 5.6, 5.7, 5.8, 5.9, 6.0, 6.0, 6.1, 6.2, 6.3, 6.4, 6.5, 6.6, 6.7, 6.8, 7.0, 7.0, 7.1, 7.2, 7.3, 7.4, 7.5, 7.6, 7.7, 7.8, 7.9, 8.0, 8.0, 8.1, 8.2, 8.3, 8.4, 8.5, 8.6, 8.7, 8.8, 8.9, 9.0, 9.0, 9.1, 9.2, 9.3, 9.4, 9.5, 9.6, 9.7, 9.8, 9.9, 10.0, 10.0, 10.1, 10.2, 10.4, 10.5, 10.6, 10.7, 10.8, 10.9, 11.0, 11.1, 11.2, 11.3, 11.4, 11.5, 11.6, 11.7, 11.8, 11.9, 12.0]

const fineIso = Miso.switcher([
  .range([27, 127], Miso.a(-127)),
  .range([128, 228], Miso.a(-128)),
]) >>> Miso.str()

const lfoWaveOptions = ["Triangle", "Saw", "Square", "S&H"]

const envTriggerOptions = ["Multi", "Single", "Autoglide"]

const retriggerCountIso = Miso.switcher([
  .int(0, "Loop")
], default: Miso.str())

const lfoSpeedSyncOptions = ["Speed", "Sync"]

const lfoSyncOptions = ["64", "48", "42", "36", "32", "30", "28", "24", "21 ⅔", "20", "18 ⅔", "18", "16", "13 ⅓", "12", "10 ⅔", "8", "6", "5 ⅓", "4", "3", "2 ⅔", "1/2", "1/4.", "1 ⅓", "1/4", "1/8.", "1/4 tr", "1/8", "1/16.", "1/8tr", "1/16", "1/16tr", "1/32", "1/32tr"]

const arpNoteModeOptions = ["Up", "Down", "Up-Down", "Up-Down 2", "Played", "Random", "Play", "Record"]

const arpOctaveOptions = [
  1 : "1",
  2 : "2",
  3 : "3",
  4 : "4",
]

const filterTrackOptions = ["Full", "1", "2", "3", "4", "5", "6", "None"]

const pwIso = Miso.switcher([
  .range([0, 63], Miso.lerp(in: [0, 63], out: [5, 50])),
  .range([64, 127], Miso.lerp(in: [64, 127], out: [50, 95])),
]) >>> Miso.round() >>> Miso.str()

const pwModOptions = [-90, -88, -86, -85, -84, -82, -80, -78, -76, -75, -74, -73, -71, -70, -68, -66, -65, -64, -63, -61, -60, -59, -57, -56, -55, -53, -51, -50, -49, -47, -46, -45, -44, -42, -40, -39, -38, -36, -35, -34, -32, -30, -28, -26, -25, -24, -23, -22, -20, -19, -17, -16, -15, -14, -12, -10, -9, -7, -5, -4, -3, -2, -1, 0, 0, 1, 2, 3, 4, 5, 7, 9, 10, 12, 14, 15, 16, 17, 19, 20, 22, 23, 24, 25, 26, 28, 30, 32, 34, 35, 36, 38, 39, 40, 42, 44, 45, 46, 47, 49, 50, 51, 53, 55, 56, 57, 59, 60, 61, 63, 64, 65, 66, 68, 70, 71, 73, 74, 75, 76, 78, 80, 82, 84, 85, 86, 88, 90]
const pwModIso = Miso.lookupFunction(pwModOptions) >>> Miso.round() >>> Miso.str()

const bipolar63Iso = Miso.switcher([
  .range([0, 63], Miso.a(-63)),
  .range([64, 127], Miso.a(-64))
]) >>> Miso.str()

const bipolar127Iso = Miso.switcher([
  .range([0, 127], Miso.a(-127)),
  .range([128, 255], Miso.a(-128))
]) >>> Miso.str()

const parms = [
  ["porta", { p: 5, b: 4 }],
  ["bend", { p: 107, b: 6, rng: [40, 88], dispOff: -64 }],
  ["sync", { p: 110, b: 7, bit: 0, ext: { AFX:1 } }],
  ["osc/0/wave", { p: 0, b: 8, ext: { NRPN:72, AFX:2 }, opts: oscWaveOptions }],
  ["osc/0/pw", { p: 74, b: 9, ext: { AFX:3 }, iso: pwIso }],
  ["osc/0/octave", { p: 70, b: 10, ext: { AFX:4 }, opts: oscOctaveOptions }],
  ["osc/0/coarse", { p: 27, b: 11, ext: { LSB:59, AFX: 5 }, max: 255, dispOff: -128, iso: coarseIso }],
  ["osc/0/fine", { p: 26, b: 12, ext: { LSB:58, AFX: 6 }, rng: [27, 228], dispOff: -128, iso: fineIso }],
  ["osc/1/wave", { p: 0, b: 13, ext: { NRPN:82, AFX: 7 }, opts: oscWaveOptions }],
  ["osc/1/pw", { p: 79, b: 14, ext: { AFX:8 }, iso: pwIso }],
  ["osc/1/octave", { p: 75, b: 15, ext: { AFX:9 }, opts: oscOctaveOptions }],
  ["osc/1/coarse", { p: 30, b: 16, ext: { LSB:62, AFX:10 }, max: 255, dispOff: -128, iso: coarseIso }],
  ["osc/1/fine", { p: 29, b: 17, ext: { LSB:61, AFX:11 }, rng: [27, 228], dispOff: -128, iso: fineIso }],
  
  ["sub/wave", { p: -1, b: 18, bits: [0, 1], ext: { NRPN:21, AFX:12 }, opts: oscWaveOptions }],
  ["sub/mode", { p: -1, b: 18, bit: 2, ext: { NRPN:21, AFX:12 }, opts: ["Classic", "Osc 3"] }],
  ["sub/pw", { p: -1, b: 19, ext: { NRPN:22, AFX:13 }, iso: pwIso }],
  ["sub/octave", { p: -1, b: 20, ext: { NRPN:23, AFX:14 }, opts: subOscOctaveOptions }],
  
  ["sub/coarse", { p: 0, b: 21, ext: { NRPN:84, AFX:15 }, max: 255, dispOff: -128, iso: coarseIso }],
  ["sub/fine", { p: 0, b: 22, ext: { NRPN:77, AFX:16 }, rng: [27, 228], dispOff: -128, iso: fineIso }],
  ["sub/sub/wave", { p: 80, b: 23, ext: { AFX:17 }, opts: ["Sine", "Pulse", "Square"] }],
  ["sub/sub/octave", { p: 81, b: 24, ext: { AFX:18 }, opts: [62: "-2", 63: "-1"] }],
  ["osc/0/level", { p: 20, b: 25, ext: { LSB:52, AFX:19 }, max: 255 }],
  ["osc/1/level", { p: 21, b: 26, ext: { LSB:53, AFX:20 }, max: 255 }],
  ["sub/level", { p: 22, b: 27, ext: { LSB:54, AFX:21 }, max: 255 }],
  ["noise/level", { p: 23, b: 28, ext: { LSB:55, AFX:22 }, max: 255 }],
  ["ringMod/level", { p: 24, b: 29, ext: { LSB:56, AFX:23 }, max: 255 }],
  ["ext/level", { p: 25, b: 30, ext: { LSB:57, AFX:24 }, max: 255 }],
  ["filter/cutoff", { p: 16, b: 31, ext: { LSB:48, AFX: 25 }, max: 255 }],
  ["filter/reson", { p: 82, b: 32, ext: { AFX:26 } }],
  ["filter/drive", { p: 114, b: 33, ext: { AFX:27 } }],
  ["filter/slop", { p: 106, b: 34, bit: 3, ext: { AFX:28 }, opts: ["12dB", "24dB"] }],
  ["filter/type", { p: 83, b: 34, bit: 2, ext: { AFX:28 }, opts: ["Classic", "Acid"] }],
  ["filter/shape", { p: 84, b: 34, bits: [0, 1], ext: { AFX:28 }, opts: ["LP", "BP", "HP"] }],
  ["amp/env/velo", { p: 112, b: 35, ext: { AFX:29 }, rng: [1, 127], dispOff: -64 }],
  ["amp/env/attack", { p: 90, b: 36, ext: { AFX:30 } }],
  ["amp/env/decay", { p: 91, b: 37, ext: { AFX:31 } }],
  ["amp/env/sustain", { p: 92, b: 38, ext: { AFX:32 } }],
  ["amp/env/release", { p: 93, b: 39, ext: { AFX:33 } }],
  ["amp/env/trigger", { p: 0, b: 40, ext: { NRPN:73, AFX:34 }, opts: envTriggerOptions }],
  ["mod/env/velo", { p: 113, b: 41, ext: { AFX:35 }, rng: [1, 127], dispOff: -64 }],
  ["mod/env/attack", { p: 102, b: 42, ext: { AFX:36 } }],
  ["mod/env/decay", { p: 103, b: 43, ext: { AFX:37 } }],
  ["mod/env/sustain", { p: 104, b: 44, ext: { AFX:38 } }],
  ["mod/env/release", { p: 105, b: 45, ext: { AFX:39 } }],
  ["mod/env/trigger", { p: 0, b: 46, ext: { NRPN:105, AFX:40 }, opts: envTriggerOptions }],
  ["lfo/0/wave", { p: 88, b: 47, ext: { AFX:41 }, opts: lfoWaveOptions }],
  ["lfo/0/delay", { p: 86, b: 48, ext: { AFX:42 } }],
  ["lfo/0/slew", { p: 0, b: 49, ext: { NRPN:86, AFX:43 } }],
  ["lfo/0/speed", { p: 18, b: 50, ext: { LSB:50, AFX:44 }, max: 255 }],
  ["lfo/0/sync", { p: 0, b: 51, ext: { NRPN:87, AFX:45 }, opts: lfoSyncOptions }],
  ["lfo/0/time/sync", { p: 0, b: 52, bit: 0, ext: { NRPN:88, AFX:46 }, opts: lfoSpeedSyncOptions }],
  ["lfo/0/key/sync", { p: 0, b: 52, bit: 1, ext: { NRPN:89, AFX:46 } }],
  ["lfo/1/wave", { p: 89, b: 53, ext: { AFX:47 }, opts: lfoWaveOptions }],
  ["lfo/1/delay", { p: 87, b: 54, ext: { AFX:48 } }],
  ["lfo/1/slew", { p: 0, b: 55, ext: { NRPN:90, AFX:49 } }],
  ["lfo/1/speed", { p: 19, b: 56, ext: { LSB:51, AFX:50 }, max: 255 }],
  ["lfo/1/sync", { p: 0, b: 57, ext: { NRPN: 91, AFX:51 }, opts: lfoSyncOptions }],
  ["lfo/1/time/sync", { p: 0, b: 58, bit: 0, ext: { NRPN:92, AFX:52 }, opts: lfoSpeedSyncOptions }],
  ["lfo/1/key/sync", { p: 0, b: 58, bit: 1, ext: { NRPN:93, AFX:52 } }],
  ["arp/on", { p: 108, b: 59, bit: 0 }],
  ["arp/latch", { p: 109, b: 59, bit: 1 }],
  ["arp/seq/retrigger", { p: 0, b: 59, bit: 2, ext: { NRPN:106 } }],
  ["arp/octave", { p: 111, b: 60, bits: [0, 3], opts: arpOctaveOptions }],
  ["arp/note/mode", { p: 118, b: 61, opts: arpNoteModeOptions }],
  ["arp/rhythm", { p: 119, b: 62, max: 31, dispOff: 1 }],
  ["arp/swing", { p: 116, b: 63, rng: [3, 97] }],
  ["mod/filter/cutoff", { p: 0, b: 64, ext: { NRPN:94 }, dispOff: -64 }],
  ["mod/lfo/0/pitch", { p: 0, b: 65, ext: { NRPN:70 }, dispOff: -64 }],
  ["mod/lfo/1/filter/cutoff", { p: 0, b: 66, ext: { NRPN:71 }, dispOff: -64 }],
  ["mod/osc/1/pitch", { p: 0, b: 67, ext: { NRPN:78 }, dispOff: -64 }],
  ["aftertouch/filter/cutoff", { p: 0, b: 68, ext: { NRPN:74, AFX:53 }, dispOff: -64 }],
  ["aftertouch/lfo/0/pitch", { p: 0, b: 69, ext: { NRPN:75, AFX:54 }, dispOff: -64 }],
  ["aftertouch/lfo/1/speed", { p: 0, b: 70, ext: { NRPN:76, AFX:55 }, dispOff: -64 }],
  
  ["osc/0/lfo/0/pitch/amt", { p: 28, b: 71, ext: { LSB:60, AFX:56 }, max: 255, dispOff: -128, iso: bipolar127Iso }],
  ["osc/1/lfo/0/pitch/amt", { p: 31, b: 72, ext: { LSB:63, AFX:57 }, max: 255, dispOff: -128, iso: bipolar127Iso }],
  ["sub/lfo/0/pitch/amt", { p: -1, b: 73, ext: { NRPN:83, AFX:58 }, max: 255, dispOff: -128, iso: bipolar127Iso }],
  
  ["osc/0/lfo/1/pw/amt", { p: 73, b: 74, ext: { AFX:59 }, dispOff: -64, iso: pwModIso }],
  ["osc/1/lfo/1/pw/amt", { p: 78, b: 75, ext: { AFX:60 }, dispOff: -64, iso: pwModIso }],
  ["sub/lfo/1/pw/amt", { p: -1, b: 76, ext: { NRPN:86, AFX:61 }, dispOff: -64, iso: pwModIso }],
  
  ["filter/lfo/1/cutoff/amt", { p: 17, b: 77, ext: { LSB:49, AFX:62 }, max: 255, dispOff: -128, iso: bipolar127Iso }],
  
  ["osc/0/mod/env/pitch/amt", { p: 71, b: 78, ext: { AFX:63 }, dispOff: -64, iso: bipolar63Iso }],
  ["osc/1/mod/env/pitch/amt", { p: 76, b: 79, ext: { AFX:64 }, dispOff: -64, iso: bipolar63Iso }],
  ["sub/mod/env/pitch/amt", { p: -1, b: 80, ext: { NRPN:90, AFX:65 }, dispOff: -64, iso: bipolar63Iso }],
  
  ["osc/0/mod/env/pw/amt", { p: 72, b: 81, ext: { AFX:66 }, dispOff: -64, iso: pwModIso }],
  ["osc/1/mod/env/pw/amt", { p: 77, b: 82, ext: { AFX:67 }, dispOff: -64, iso: pwModIso }],
  ["sub/mod/env/pw/amt", { p: -1, b: 83, ext: { NRPN:94, AFX:68 }, dispOff: -64, iso: pwModIso }],
  
  ["filter/mod/env/cutoff/amt", { p: 85, b: 84, ext: { AFX:69 }, dispOff: -64, iso: bipolar63Iso }],
  ["osc/filter/mod", { p: 115, b: 85, ext: { AFX:70 } }],
  ["dist", { p: 94, b: 86, ext: { AFX:71 } }],
  ["limiter", { p: 95, b: 87, ext: { AFX:72 } }],
  ["paraphonic", { p: 0, b: 89, bit: 0, ext: { NRPN:107 } }],
  ["filter/trk", { p: 0, b: 90, ext: { NRPN:108 }, opts: filterTrackOptions }],
  ["amp/env/retrigger", { p: 0, b: 91, bit: 0, ext: { NRPN:109, AFX:73 } }],
  ["mod/env/retrigger", { p: 0, b: 92, bit: 0, ext: { NRPN:110, AFX:74 } }],
  ["micro/tune", { p: -1, b: 93, ext: { NRPN:0 }, max: 8 }],
  // on overlay, these next two are pitch/outlevel
  // pitch? 94
  // outlevel? 95
  ["osc/slop", { p: 0, b: 94, ext: { NRPN:111, AFX:75 } }],
  ["glide/split", { p: 0, b: 95, ext: { NRPN:113, AFX:76 }, max: 15 }],
  ["amp/env/fixed", { p: 0, b: 96, bit: 0, ext: { NRPN:114, AFX:77 } }],
  ["mod/env/fixed", { p: 0, b: 97, bit: 0, ext: { NRPN:115, AFX:78 } }],
  ["amp/env/retrigger/number", { p: 0, b: 98, ext: { NRPN:117, AFX:79 }, max: 16, iso: retriggerCountIso }],
  ["mod/env/retrigger/number", { p: 0, b: 99, ext: { NRPN:118, AFX:80 }, max: 16, iso: retriggerCountIso }],
  // afx overlay
  ["extra", { p: 0, b: 101, ext: { NRPN:112 }, max: 8 }],
]

function sysexData(save, location) {
  return [BSII.sysexHeader, save ? 1 : 0, location || 0, 
    // param bytes are the first 112, transformed to sysex bytes (128)
    ['>', ['bytes', { start: 0, count: 112 }], '7to8straight'], 
    // name bytes are the last 16, as-is
    ['bytes', { start: 112, count: 16} ], 0xf7]
}

const patchTruss = {
  single: 'bsii.voice',
  parms: parms,
  initFile: "bassstationii-voice-init",
  bodyDataCount: 128,
  parseBody: [
    // each 8 consecutive sysex bytes form 7 "full" bytes
    // each sysex byte only have 7 bits of actual info
    // each 7-bit chunk is lined up end to end and parsed as 7 bytes
    // so, 137-9 (128) sysex bytes yields 112 bytes
    // then 16 more bytes for name
    // bytes = [UInt8](data[9..<137]).sevenToEightStraight()
    ['>', ['bytes', { start: 9, count: 128}], '8to7straight'],  
    // nameBytes = [UInt8](data[137..<153])
    ['bytes', { start: 137, count: 16 }]
  ]
}

class BassStationIIVoicePatch : BassStationIIPatch, BankablePatch {

  static func location(forData data: Data) -> Int { return Int(data[8]) }
  
  const fileDataCount = 154
  
  static func fromOverlay(_ overlay: BassStationIIOverlayKeyPatch) -> BassStationIIVoicePatch {
    let patch = BassStationIIVoicePatch()
    patch.name = overlay.name
    BassStationIIOverlayKeyPatch.params.forEach { (path, param) in
      switch path {
      case "pitch":
        patch["osc/slop"] = overlay["pitch"]
      case "level":
        patch["glide/split"] = overlay["level"]
      default:
        patch[path] = overlay[path]
      }
    }
    return patch
  }
    
  func fileData() -> Data {
    return sysexData(save: false)
  }

  func randomize() {
    randomizeAllParams()
    
    self["extra"] = 0
    self["micro/tune"] = 0
    self["arp/on"] = 0
  }

  

}


class BassStationIIVoiceBank : TypicalTypedSysexPatchBank<BassStationIIVoicePatch> {
  
  override class var patchCount: Int { return 128 }
  // TODO: need actual init file
  override class var initFileName: String { return "bassstationii-voice-bank-init" }
  
  required public init(data: Data) {
    if data.count > 6 && data[6] == 0x00 {
      // cmd = set temp patch -> this is from a fetch
      let sysex = SysexData(data: data)
      if sysex.count == 128 {
        super.init(patches: sysex.map { Patch(data: $0) })
        return
      }
    }
    super.init(data: data)
  }
  
  required init(patches p: [Patch]) {
    super.init(patches: p)
  }
  
  override func fileData() -> Data {
    return sysexData { $0.sysexData(save: true, location: $1) }
  }

}

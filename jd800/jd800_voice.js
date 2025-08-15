


// COMMON

const portaModeOptions = ["Normal", "Legato"]

const loFreqOptions = ["200", "400Hz"]

const midFreqOptions = ["200", "250", "315", "400", "500", "630", "800", "1k", "1.25k", "1.6k", "2k", "2.5k", "3.15k", "4k", "5k", "6.3k", "8kHz"]

const midQOptions = ["0.5", "1.0", "2.0", "4.0", "9.0"]

const hiFreqOptions = ["4k", "8kHz"]

const noteIso = ['noteName', 'C-1']

const commonParms = [
  { inc: 1, b: 0x10, block: [
    ["level", { max: 100 }],
    ["tone/0/key/lo", { iso: noteIso }],
    ["tone/0/key/hi", { iso: noteIso }],
    ["tone/1/key/lo", { iso: noteIso }],
    ["tone/1/key/hi", { iso: noteIso }],
    ["tone/2/key/lo", { iso: noteIso }],
    ["tone/2/key/hi", { iso: noteIso }],
    ["tone/3/key/lo", { iso: noteIso }],
    ["tone/3/key/hi", { iso: noteIso }],
    ["bend/down", { max: 48 }],
    ["bend/up", { max: 12 }],
    ["aftertouch/bend", { max: 26 }],
    ["solo", { max: 1 }],
    ["solo/legato", { max: 1 }],
    ["porta", { max: 1 }],
    ["porta/mode", { opts: portaModeOptions }],
    ["porta/time", { max: 100 }],
  ] },
  ["tone/0/on", { b: 0x21, bit: 0 }],
  ["tone/1/on", { b: 0x21, bit: 1 }],
  ["tone/2/on", { b: 0x21, bit: 2 }],
  ["tone/3/on", { b: 0x21, bit: 3 }],
  ["tone/0/active", { b: 0x22, bit: 0 }],
  ["tone/1/active", { b: 0x22, bit: 1 }],
  ["tone/2/active", { b: 0x22, bit: 2 }],
  ["tone/3/active", { b: 0x22, bit: 3 }],
  { inc: 1, b: 0x23, block: [
    ["lo/freq", { opts: loFreqOptions }],
    ["lo/gain", { max: 30, dispOff: -15 }],
    ["mid/freq", { opts: midFreqOptions }],
    ["mid/q", { opts: midQOptions }],
    ["mid/gain", { max: 30, dispOff: -15 }],
    ["hi/freq", { opts: hiFreqOptions }],
    ["hi/gain", { max: 30, dispOff: -15 }],
    ["key/mode", { opts: ["Whole", "Split", "Dual"] }],
    ["split/pt", { max: 85, iso: ['noteName', 'C1']],
    ["channel/lo", { max: 15, dispOff: 1 }],
    ["channel/hi", { max: 15, dispOff: 1 }],
    ["pgmChange/lo", { dispOff: 1 }],
    ["pgmChange/hi", { dispOff: 1 }],
    ["hold", { opts: ["Upper", "Lower", "Both"] }],
  ] },
]

const commonWerk = {
  single: 'voice.common',
  namePack: [0, 0xe],
  size: 0x32,
  parms: commonParms,
}

  // func randomize() {
  // self["tone/0/on"] = 1
  // self["tone/1/on"] = 1
  // self["tone/2/on"] = 1
  // self["tone/3/on"] = 1
// 
  // self["level"] = 100
// 
  // self["tone/0/key/lo"] = 0
  // self["tone/0/key/hi"] = 127
  // self["tone/1/key/lo"] = 0
  // self["tone/1/key/hi"] = 127
  // self["tone/2/key/lo"] = 0
  // self["tone/2/key/hi"] = 127
  // self["tone/3/key/lo"] = 0
  // self["tone/3/key/hi"] = 127
// }

// FX

const fxA = [
  "dist/phase/spectral/extra",
  "dist/phase/extra/spectral",
  "dist/spectral/extra/phase",
  "dist/spectral/phase/extra",
  "dist/extra/phase/spectral",
  "dist/extra/spectral/phase",
  "phase/dist/spectral/extra",
  "phase/dist/extra/spectral",
  "phase/spectral/extra/dist",
  "phase/spectral/dist/extra",
  "phase/extra/dist/spectral",
  "phase/extra/spectral/dist",
  "spectral/phase/dist/extra",
  "spectral/phase/extra/dist",
  "spectral/dist/extra/phase",
  "spectral/dist/phase/extra",
  "spectral/extra/phase/dist",
  "spectral/extra/dist/phase",
  "extra/phase/spectral/dist",
  "extra/phase/dist/spectral",
  "extra/spectral/dist/phase",
  "extra/spectral/phase/dist",
  "extra/dist/phase/spectral",
  "extra/dist/spectral/phase",
]

const fxB = [
  "chorus/delay/reverb",
  "chorus/reverb/delay",
  "delay/chorus/reverb",
  "delay/reverb/chorus",
  "reverb/chorus/delay",
  "reverb/delay/chorus",
]

const fxBlockASeqOptions = ["DS-PH-SP-EN", "DS-PH-EN-SP", "DS-SP-EN-PH", "DS-SP-PH-EN", "DS-EN-PH-SP", "DS-EN-SP-PH", "PH-DS-SP-EN", "PH-DS-EN-SP", "PH-SP-EN-DS", "PH-SP-DS-EN", "PH-EN-DS-SP", "PH-EN-SP-DS", "SP-PH-DS-EN", "SP-PH-EN-DS", "SP-DS-EN-PH", "SP-DS-PH-EN", "SP-EN-PH-DS", "SP-EN-DS-PH", "EN-PH-SP-DS", "EN-PH-DS-SP", "EN-SP-DS-PH", "EN-SP-PH-DS", "EN-DS-PH-SP", "EN-DS-SP-PH"]

const fxBlockBSeqOptions = ["CHO-DLY-REV", "CHO-REV-DLY", "DLY-CHO-REV", "DLY-REV-CHO", "REV-CHO-DLY", "REV-DLY-CHO"]
const distTypeOptions = ["MELLOW DRIVE", "OVERDRIVE", "CRY DRIVE", "MELLOW DIST", "LIGHT DIST", "FAT DIST", "FUZZ DIST"]

const reverbTypeOptions = ["ROOM1", "ROOM2", "HALL1", "HALL2", "HALL3", "HALL4", "GATE", "REVERSE", "FLYING1", "FLYING2"]

const reverbHiCutoffOptions = ["500", "630", "800", "1k", "1.25k", "1.6k", "2k", "2.5k", "3.15k", "4k", "5k", "6.3k", "8k", "10k", "12.5k", "16kHz", "Bypass"]

const fxParms = [
  { inc: 1, b: 0x00, block: [
    ["0/seq", { opts: fxBlockASeqOptions }],
    ["1/seq", { opts: fxBlockBSeqOptions }],
    ["0/part/0/on", { max: 1 }],
    ["0/part/1/on", { max: 1 }],
    ["0/part/2/on", { max: 1 }],
    ["0/part/3/on", { max: 1 }],
    ["1/part/0/on", { max: 1 }],
    ["1/part/1/on", { max: 1 }],
    ["1/part/2/on", { max: 1 }],
    ["1/balance", { max: 100 }],
    ["dist/type", { opts: distTypeOptions }],
    ["dist/drive", { max: 100 }],
    ["dist/level", { max: 100 }],
    ["phase/manual", { max: 99 }],
    ["phase/rate", { max: 99 }],
    ["phase/depth", { max: 100 }],
    ["phase/reson", { max: 100 }],
    ["phase/mix", { max: 100 }],
    ["spectral/0", { max: 30, dispOff: -15 }],
    ["spectral/1", { max: 30, dispOff: -15 }],
    ["spectral/2", { max: 30, dispOff: -15 }],
    ["spectral/3", { max: 30, dispOff: -15 }],
    ["spectral/4", { max: 30, dispOff: -15 }],
    ["spectral/5", { max: 30, dispOff: -15 }],
    ["spectral/skirt", { max: 4, dispOff: 1 }],
    ["extra/sens", { max: 100 }],
    ["extra/mix", { max: 100 }],
    ["delay/mid/time", { max: 125 }],
    ["delay/mid/level", { max: 100 }],
    ["delay/left/time", { max: 125 }],
    ["delay/left/level", { max: 100 }],
    ["delay/right/time", { max: 125 }],
    ["delay/right/level", { max: 100 }],
    ["delay/feedback", { max: 98 }],
    ["chorus/rate", { max: 99 }],
    ["chorus/depth", { max: 100 }],
    ["chorus/delay", { max: 99 }],
    ["chorus/feedback", { max: 98 }],
    ["chorus/level", { max: 100 }],
    ["reverb/type", { opts: reverbTypeOptions }],
    ["reverb/pre", { max: 121 }],
    ["reverb/early", { max: 100 }],
    ["reverb/hi/cutoff", { opts: reverbHiCutoffOptions }],
    ["reverb/time", { max: 100 }],
    ["reverb/level", { max: 100 }],
  ] } 
]

const fxWerk = {
  single: 'voice.fx',
  parms: fxParms,
  size: 0x2e,
}

// TONE

const internalWaveNames = ["Syn Saw 1", "Syn Saw 2", "FAT Saw", "FAT Square", "Syn Pulse 1", "Syn Pulse2", "Syn Pulse3", "Syn Pulse4", "Syn Pulse5", "Pulse Mod", "Triangle", "Syn Sine", "Soft Pad", "Wire Str", "MIDI Clav", "Spark Vox1", "Spark Vox2", "Syn Sax", "Clav Wave", "Cello Wave", "Bright Digi", "Cutters", "Syn Bass", "Rad Hose", "Vocal Wave", "Wally Wave", "Brusky Ip", "Digiwave", "Can Wave 1", "Can Wave 2", "EML 5th", "Wave Scan", "Nasty", "Wave Table", "Fine Wine", "Funk Bass 1", "Funk Bass 2", "Strat Sust", "Harp Harm", "Full Organ", "Full Draw", "Doo", "Zzz Vox", "Org Vox", "Male Vox", "Kalimba", "Xylo", "Marim Wave", "Log Drum", "AgogoBells", "Bottle Hit", "Gamelan 1", "Gamelan 2", "Gamelan 3", "Tabla", "Pole lp", "Pluck Harp", "Nylon Str", "Hooky", "Muters", "Klack Wave", "Crystal", "Digi Bell", "FingerBell", "Digi Chime", "Bell Wave", "Org Bell", "Scrape Gut", "Strat Atk", "Hellow Bs", "Piano Atk", "EP Hard", "Clear Keys", "EP Distone", "Flute Push", "Shami", "Wood Crak", "Kimba Atk", "Block", "Org Atk 1", "Org Atk 2", "Cowbell", "Sm Metal", "StrikePole", "Pizz", "Switch", "Tuba Slap", "Plink", "Plunk", "EP Atk", "TVF Trig", "Flute Tone", "Pan Pipe", "Bottle Blow", "Shaku Atk", "FlugelWave", "French", "White Noise", "Pink Noise", "Pitch Wind", "Vox Noise1", "Vox Noise2", "Crunch Wind", "ThroatWind", "Metal Wind", "Windago", "Anklungs", "Wind Chime"]
  
const internalWaveOptions = internalWaveNames
  
const toneParms = [
  { inc: 1, b: 0x00, block: [
    ["velo/curve", { max: 3, dispOff: 1 }],
    ["hold/ctrl", { max: 1 }],
    ["lfo/0/rate", { max: 100 }],
    ["lfo/0/delay", { max: 101 }],
    ["lfo/0/fade", { max: 100, dispOff: -50 }],
    ["lfo/0/wave", { opts: ["TRI", "SAW", "SQU", "S/H", "RND"] }],
    ["lfo/0/offset", { opts: ["+", "0", "-"] }],
    ["lfo/0/key/sync", { max: 1 }],
    ["lfo/1/rate", { max: 100 }],
    ["lfo/1/delay", { max: 101 }],
    ["lfo/1/fade", { max: 100, dispOff: -50 }],
    ["lfo/1/wave", { opts: ["TRI", "SAW", "SQU", "S/H", "RND"] }],
    ["lfo/1/offset", { opts: ["+", "0", "-"] }],
    ["lfo/1/key/sync", { max: 1 }],
    ["wave/group", { opts: ["INT", "CARD"] }],
    ["wave/number", { p: 2, opts: internalWaveOptions }],
  ] },
  { inc: 1, b: 0x11, block: [
    ["pitch/coarse", { max: 96, dispOff: -48 }],
    ["pitch/fine", { max: 100, dispOff: -50 }],
    ["pitch/random", { max: 100 }],
    ["pitch/keyTrk", { opts: ["-100", "-50", "-20", "-10", "-5", "0", "+5", "+10", "+20", "+50", "+98", "+99", "+100", "+101", "+102", "+150", "+200"] }],
    ["bend", { max: 1 }],
    ["pitch/aftertouch", { max: 1 }],
    ["pitch/lfo/0/depth", { max: 100, dispOff: -50 }],
    ["pitch/lfo/1/depth", { max: 100, dispOff: -50 }],
    ["pitch/ctrl/depth", { max: 100 }],
    ["pitch/aftertouch/mod", { max: 100 }],
    ["pitch/env/velo", { max: 100, dispOff: -50 }],
    ["pitch/env/time/velo", { max: 100, dispOff: -50 }],
    ["pitch/env/time/keyTrk", { max: 20, dispOff: -10 }],
    ["pitch/env/level/-1", { max: 100, dispOff: -50 }],
    ["pitch/env/time/0", { max: 100 }],
    ["pitch/env/level/0", { max: 100, dispOff: -50 }],
    ["pitch/env/time/1", { max: 100 }],
    ["pitch/env/time/2", { max: 100 }],
    ["pitch/env/level/1", { max: 100, dispOff: -50 }],
    ["filter/type", { opts: ["HPF", "BPF", "LPF"] }],
    ["cutoff", { max: 100 }],
    ["reson", { max: 100 }],
    ["filter/keyTrk", { max: 40 }],
    ["filter/aftertouch/depth", { max: 100, dispOff: -50 }],
    ["filter/lfo", { opts: ["LFO 1", "LFO 2"] }],
    ["filter/lfo/depth", { max: 100, dispOff: -50 }],
    ["filter/env/depth", { max: 100, dispOff: -50 }],
    ["filter/env/velo", { max: 100, dispOff: -50 }],
    ["filter/env/time/velo", { max: 100, dispOff: -50 }],
    ["filter/env/time/keyTrk", { max: 20, dispOff: -10 }],
    ["filter/env/time/0", { max: 100 }],
    ["filter/env/level/0", { max: 100 }],
    ["filter/env/time/1", { max: 100 }],
    ["filter/env/level/1", { max: 100 }],
    ["filter/env/time/2", { max: 100 }],
    ["filter/env/level/2", { max: 100 }],
    ["filter/env/time/3", { max: 100 }],
    ["filter/env/level/3", { max: 100 }],
    ["bias/direction", { opts: ["UP", "LOW", "U&L"] }],
    ["bias/pt", { iso: noteIso }],
    ["bias/level", { max: 20, dispOff: -10 }],
    ["level", { max: 100 }],
    ["amp/aftertouch/depth", { max: 100, dispOff: -50 }],
    ["amp/lfo", { opts: ["LFO 1", "LFO 2"] }],
    ["amp/lfo/depth", { max: 100, dispOff: -50 }],
    ["amp/env/velo", { max: 100, dispOff: -50 }],
    ["amp/env/time/velo", { max: 100, dispOff: -50 }],
    ["amp/env/time/keyTrk", { max: 20, dispOff: -10 }],
    ["amp/env/time/0", { max: 100 }],
    ["amp/env/level/0", { max: 100 }],
    ["amp/env/time/1", { max: 100 }],
    ["amp/env/level/1", { max: 100 }],
    ["amp/env/time/2", { max: 100 }],
    ["amp/env/level/2", { max: 100 }],
    ["amp/env/time/3", { max: 100 }],
  ] }
]

const toneWerk = {
  single: 'voice.tone',
  parms: toneParms,
  size: 0x0048,
  initFile: "jd800-tone-init",
}
 
  // func randomize() {
  //   self["wave/group"] = 0
// }


  // TODO: requires some byte math. Check the D-10 or something for a solution
// static func location(forData data: Data) -> Int {
  // return 0// Int(addressBytes(forSysex: data)[1])
// }
  //   
// required init(data: Data) {
  // if data.count == JD800VoicePartPatch.fileDataCount {
  //   addressables = JD800VoicePartPatch.addressables(forData: data)
  //   addressables["fx"] = JD800FXPatch()
  // }
// }
// 
// // render the sysex for this patch as a voice part
// func partSysexData(deviceId: Int, address: RolandAddress) -> [Data] {
  // return JD800VoicePartPatch.addressableTypes.compactMap { (path, addressableType) -> [Data]? in
  //   guard let subAdd = JD800VoicePartPatch.subpatchAddresses[path] else { return nil }
  //   return addressables[path]?.sysexData(deviceId: deviceId, address: address + subAdd)
  // }.joined().map { $0 }
// }

const partPatchWerk = {
  multi: 'voice.part',
  map: [
    ["common", 0x0000, commonWerk,
    ["tone/0", 0x0032, toneWerk,
    ["tone/1", 0x007a, toneWerk,
    ["tone/2", 0x0142, toneWerk,
    ["tone/3", 0x020a, toneWerk,
  ],
  initFile: "jd800-voice-init",
}

const patchWerk = {
  multi: 'voice',
  map: [
    ["common", 0x0000, commonWerk,
    ["fx", 0x0032, fxWerk,
    ["tone/0", 0x0060, toneWerk,
    ["tone/1", 0x0128, toneWerk,
    ["tone/2", 0x0170, toneWerk,
    ["tone/3", 0x0238, toneWerk,
  ],
  initFile: "jd800-voice-init",
  // TODO: API-way to specify "same size as this other truss"
  validSizes: ['auto', JD800VoicePartPatch.fileDataCount],
}


class JD800VoiceBank : TypicalTypedRolandCompactAddressableBank<JD800VoicePatch>, VoiceBank {
  
  override class func offsetAddress(location: Int) -> RolandAddress {
    return RolandAddress(0x0300) * location
  }
  
  override class var initFileName: String { return "jd800-voice-bank-init" }
  override class var patchCount: Int { return 64 }
  
}

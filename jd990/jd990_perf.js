

const commonParms = [
  p["sync/part"] = OptionsParam(byte: 0x10, options: ([0, 7].map {
    return $0 == 0 ? "None" : `Part ${$0}`
  }))
  (0..<8).forEach {
    ["voice/reserve/$0", { b: 0x11 + $0, max: 24 }],
  }
  ["chorus/rate", { b: 0x19, max: 99, iso: JD990CommonPatch.chorusRateMiso }],
  ["chorus/depth", { b: 0x1a, max: 100 }],
  ["chorus/delay", { b: 0x1b, max: 99, iso: JD990CommonPatch.chorusDelayIso }],
  ["chorus/feedback", { b: 0x1c, max: 98, iso: JD990CommonPatch.feedBackIso }],
  ["chorus/level", { b: 0x1d, max: 100 }],
  ["delay/mode", { b: 0x1e, opts: JD990CommonPatch.delayModeOptions }],
  ["delay/mid/time", { p: 2, b: 0x1f, max: 255, iso: JD990CommonPatch.delayTimeIso }],
  ["delay/mid/level", { b: 0x21, max: 100 }],
  ["delay/left/time", { p: 2, b: 0x22, max: 255, iso: JD990CommonPatch.delayTimeIso }],
  ["delay/left/level", { b: 0x24, max: 100 }],
  ["delay/right/time", { p: 2, b: 0x25, max: 255, iso: JD990CommonPatch.delayTimeIso }],
  ["delay/right/level", { b: 0x27, max: 100 }],
  ["delay/feedback", { b: 0x28, max: 98, iso:  JD990CommonPatch.feedBackIso }],
  ["reverb/type", { b: 0x29, opts: JD800FXPatch.reverbTypeOptions }],
  ["reverb/pre", { b: 0x2a, max: 120 }],
  ["reverb/early", { b: 0x2b, max: 100 }],
  ["reverb/hi/cutoff", { b: 0x2c, opts: JD800FXPatch.reverbHiCutoffOptions }],
  ["reverb/time", { b: 0x2d, iso: JD990CommonPatch.reverbTimeIso }],
  ["reverb/level", { b: 0x2e, max: 100 }],
]

const commonWerk = {
  single: 'perf.common',
  parms: commonParms,
  namePack: [0x00, 0x0f],
  size: 0x30,
}


const presetsA = ["Killer Pad", "Pulse Pad", "Lovely Vox Pad", "Tempest", "Deep Breath Pad", "Pure Glass", "Cherish", "GlassVoices", "Ac.Piano 2", "Ac.Piano Hybrid", "Crystal Rhodes 2", "E.Piano 1", "E.Piano 2", "Agogo Rhodes", "Seq E.Piano", "Whispery Piano", "Pipe Organ", "Choir Organ", "CLS 222 (Mod) 1", "Ring Organ", "CLS 222 (Mod) 2", "Jazz Organ", "Dist.Organ", "French New Organ", "Authentic Harp", "Harmo Harpo", "Authentic Clav", "Digital Clav", "Nylon Guitar", "String Guitar", "Electric Guitar", "Velo Harmonics", "12 String Guitar", "Clang Guitar", "Stratomaster PJ", "That's Funky", "ChinaGuitar", "Reso Strat", "Big Country", "Velo-Crunch", "Fretless Bass", "Woody Bass", "Velo-Switch Bass", "Slap Bass", "Pick Bass", "Fingered Bass", "Flubber Bass", "House Bass", "Rubber Bass", "Stick Bass", "Wiry Sync Bass", "A Funk Bass 1", "A Funk Bass 2", "Techno Bass", "Structure Bass", "Mega Mono Bass", "Warm Vibe", "Marimba", "Night Kalimba", "Perc Stab", "Harlequin 990", "Cow Vibes", "Ethnic", "AfricaMetals"].enumerated().map {
  return `A${($0.offset / 8} + 1)\(($0.offset % 8) + 1): \($0.element)`
}

const presetsB = ["JD-T.Chimes", "Wave Bells", "Tria Bells", "Lite Delay", "Like Dee", "Reincarnate", "Fantasy Bell", "Ring Chimes", "Brass Section", "Brass Mix", "French Horn", "Bad Wolf Horn", "Wagner Chorale", "Analog Brass 2", "Brass Vel.Fall", "Sax Tpt Tbn", "Trumpet Solo", "Harmon Mute", "Trombone Solo", "Alto Sax", "Tenor Sax", "Intimate Flute", "Mellowtron Flute", "Panhandler", "Fusion Solo", "Tap Sequence", "Wavy Flutone", "KoreanTongPoo", "Lyric Flute Solo", "BendSaxVoice", "Saw Lead", "Bubbly Lead", "990 Strings", "Pizzicato", "Soaring Strings", "Silky Strings", "Carry on it", "B-V's Oooze", "Dreaming Time", "Waveola Vox Rize", "Tangerine", "Twinkling String", "Strat'O'Dreams", "Euro E.Piano", "Betazoid Harp", "Glory", "Orgatoron", "Oasis", "WinterVox", "From Far East", "Macho Swell", "R-Mod Brass Pad", "The Pad", "Story Pad", "Hybrid Poly Syn", "JX Sweepee", "Let's Dance !!", "GreatExpectation", "Letting Go", "Aqueous Strings", "CyberneticEmpire", "Kalahari", "Passing Asteroid", "Pink Bomb"].enumerated().map {
  return `B${($0.offset / 8} + 1)\(($0.offset % 8) + 1): \($0.element)`
}

const presetOptions = (presetsA).concat(presetsB)

const presetRhythmOptions = [
  "A: Drum Set A",
  "B: Drum Set B",
]

const partParms = [
  ["on", { b: 0x00, max: 1 }],
  ["channel", { b: 0x01, max: 15, dispOff: 1 }],
  ["bank", { b: 0x02, opts: ["Int/Card", "Preset A/B"] }],
  ["pgm/number", { b: 0x03, dispOff: 1 }],
  ["level", { b: 0x04, max: 100 }],
  ["pan", { b: 0x05, max: 100, dispOff: -50 }],
  ["coarse", { b: 0x06, max: 96, dispOff: -48 }],
  ["fine", { b: 0x07, max: 100, dispOff: -50 }],
  ["out/assign", { b: 0x08, opts: ["Mix", "Dir-1", "Dir-2", "Dir-3"] }],
  ["fx/mode", { b: 0x09, opts: ["Dry", "Rev", "C+R", "D+R"] }],
  ["fx/level", { b: 0x0a, max: 100 }],
]

const partWerk = {
  single: 'perf.part',
  parms: partParms,
  size: 0x0c,
}


  // Synth saves this as common message + part msgs compacted!
func sysexData(deviceId: Int, address: RolandAddress) -> [Data] {
  // save common as one sysex msg
  var data = [Data]()
  if let common = addressables["common"] {
    data.append(contentsOf: common.sysexData(deviceId: deviceId, address: address))
  }

  // then parts as 1 more sysex msg, compacted
  let partData: [[Data]] = (0..<8).compactMap {
    let path: SynthPath = "part/$0"
    guard let a = type(of: self).subpatchAddresses[path] else { return nil }
    return addressables[path]?.sysexData(deviceId: deviceId, address: a)
  }
  let rData = RolandData(sysexData: [Data](partData.joined()), addressableType: type(of: self))
  data.append(contentsOf: rData.sysexMsgs(deviceId: deviceId, offsetAddress: address))

  return data
}

  static func location(forData data: Data) -> Int {
  return Int(addressBytes(forSysex: data)[1])
}

const patchTruss = {
  multi: 'perf',
  map: ([
    ['common', 0x0000, commonWerk],
  ]).concat((8).map(i => 
    [['part', i], 0x30 + i * 0x0c, partWerk]
  )),
  initFile: "jd990-perf-init",
  validSizes: ['auto', 166],
}

class JD990PerfBank: JD990Bank<JD990PerfPatch>, PerfBank {

  override class func startAddress(_ path: SynthPath?) -> RolandAddress {
    // internal, or card
    return path?.endex == 0 ? 0x05000000 : 0x09000000
  }
  
  override class var patchCount: Int { return 16 }
  override class var initFileName: String { return "jd990-perf-bank-init" }
  
  override class func isValid(fileSize: Int) -> Bool {
    return fileSize == 2656 || fileSize == fileDataCount
  }

}

const randomPitches = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "20", "30", "40", "50", "60", "70", "80", "90", "100", "200", "300", "400", "500", "600", "700", "800", "900", "1000", "1100", "1200"]

const veloTSens = ["-100", "-70", "-50", "-40", "-30", "-20", "-10", "0", "10", "20", "30", "40", "50", "70", "100"]

//      static func isValid(fileSize: Int) -> Bool {
//        return fileSize == fileDataCount || fileSize == fileDataCount + 1 // allow for JV-880 patches
//      }

const noteParms = [
  ['wave/group', { b: 0x00, opts: ["Int","Exp","PCM"] }],
  ['wave/number', { b: 0x01, packIso: JV8X.multiPack(0x01), max: 254 }],
  ['on', { b: 0x03, max: 1 }],
  ['coarse', { b: 0x04, .iso(Miso.noteName(zeroNote: "C-1")) }],
  ['mute/group', { b: 0x5, max: 31 }],
  ['env/sustain', { b: 0x6, max: 1 }],
  ['fine', { b: 0x07, rng: [14, 114], dispOff: -64 }],
  ['random/pitch', { b: 0x08, opts: randomPitches }],
  ['bend/range', { b: 0x9, max: 12 }],

  ['pitch/env/velo/sens', { b: 0x0a, rng: [1, 127], dispOff: -64 }],
  ['pitch/env/velo/time', { b: 0x0b, opts: veloTSens }],
  ['pitch/env/depth', { b: 0x0c, rng: [52, 76], dispOff: -64 }],
  ['pitch/env/time/0', { b: 0x0d }],
  ['pitch/env/level/0', { b: 0x0e, rng: [1, 127], dispOff: -64 }],
  ['pitch/env/time/1', { b: 0x0f }],
  ['pitch/env/level/1', { b: 0x10, rng: [1, 127], dispOff: -64 }],
  ['pitch/env/time/2', { b: 0x11 }],
  ['pitch/env/level/2', { b: 0x12, rng: [1, 127], dispOff: -64 }],
  ['pitch/env/time/3', { b: 0x13 }],
  ['pitch/env/level/3', { b: 0x14, rng: [1, 127], dispOff: -64 }],

  ['filter/type', { b: 0x15, opts: ["Off","LPF","HPF"] }],
  ['cutoff', { b: 0x16 }],
  ['reson', { b: 0x17 }],
  ['reson/mode', { b: 0x18, opts: ["Soft", "Hard"] }],
  ['filter/env/velo/sens', { b: 0x19, rng: [1, 127], dispOff: -64 }],
  ['filter/env/velo/time', { b: 0x1a, opts: veloTSens }],
  ['filter/env/depth', { b: 0x1b, rng: [1, 127], dispOff: -64 }],
  ['filter/env/time/0', { b: 0x1c }],
  ['filter/env/level/0', { b: 0x1d }],
  ['filter/env/time/1', { b: 0x1e }],
  ['filter/env/level/1', { b: 0x1f }],
  ['filter/env/time/2', { b: 0x20 }],
  ['filter/env/level/2', { b: 0x21 }],
  ['filter/env/time/3', { b: 0x22 }],
  ['filter/env/level/3', { b: 0x23 }],

  ['level', { b: 0x24 }],
  ['pan', { b: 0x25, packIso: JV8X.multiPack(0x25), max: 128, dispOff: -64 }],
  ['amp/env/velo/sens', { b: 0x27, rng: [1, 127], dispOff: -64 }],
  ['amp/env/velo/time', { b: 0x28, opts: veloTSens }],
  ['amp/env/time/0', { b: 0x29 }],
  ['amp/env/level/0', { b: 0x2a }],
  ['amp/env/time/1', { b: 0x2b }],
  ['amp/env/level/1', { b: 0x2c }],
  ['amp/env/time/2', { b: 0x2d }],
  ['amp/env/level/2', { b: 0x2e }],
  ['amp/env/time/3', { b: 0x2f }],

  ['out/level', { b: 0x30 }],
  ['reverb', { b: 0x31 }],
  ['chorus', { b: 0x32 }],
]


const werks = (config) => {
  const note = {
    single: "Rhythm Note", 
    parms: noteParms.concat(config.extraParms), 
    size: config.size,
  }
  
  const patch = {
    multi: "Rhythm", 
    map: (61).map(i =>
      [['note', i], [i, 0x00], note]
    ),
    initFile: "jv880-rhythm",
  }
  
  return {
    patch: patch,
    bank: {
      multiBank: patchWerk, 
      patchCount: 1, 
      initFile: "jv880-rhythm-bank",
    },
  }
}


//      override class func startAddress(_ path: SynthPath?) -> RolandAddress {
//        return (path?.endex ?? 0) == 0 ? 0x017f4000 : 0x027f4000
//      }
//    static func location(forData data: Data) -> Int {
//      return 0 // rhythm banks are just 1 patch
//    }

module.exports = {
  werks,
}
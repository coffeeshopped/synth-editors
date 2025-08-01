
const commonParms = [
  { inc: 1, b: 0x000d, block: [
    ["lfo/shape", { opts: ["Tri", "Sin", "Saw", "Square", "S&H", "Random"] }],
    ["lfo/rate", { }],
    ["lfo/fade", { }],
    ["lfo/tempo/sync", { max: 1 }],
    ["lfo/sync/note", { opts: ["16", "12", "8", "4", "2", "1", "3/4", "2/3", "1/2", "3/8", "1/3", "1/4", "3/16", "1/6", "1/8", "3/32", "1/12", "1/16", "1/24", "1/32"] }],
    ["lfo/pitch/depth", { range: [1, 127], dispOff: -64 }],
    ["lfo/filter/depth", { range: [1, 127], dispOff: -64 }],
    ["lfo/amp/depth", { range: [1, 127], dispOff: -64 }],
    ["lfo/key/sync", { max: 1 }],
    ["osc/wave", { opts: ["Saw", "Tri", "Square"] }],
    ["coarse", { range: [40, 88], dispOff: -64 }],
    ["fine", { range: [14, 114], dispOff: -64 }],
    ["pw", {  }],
    ["pw/mod/depth", {  }],
    ["pitch/env/velo", { range: [1, 127], dispOff: -64 }],
    ["pitch/env/attack", {  }],
    ["pitch/env/decay", {  }],
    ["pitch/env/depth", { range: [1, 127], dispOff: -64 }],
    ["sub/osc/type", { opts: ["Off", "Oct -1", "Oct -2"] }],
    ["filter/on", { max: 1 }],
    ["cutoff", {  }],
    ["filter/key/trk", { range: [54, 74], dispOff: -64 }],
    ["reson", {  }],
    ["filter/env/velo", { range: [1, 127], dispOff: -64 }],
    ["filter/env/attack", {  }],
    ["filter/env/decay", {  }],
    ["filter/env/sustain", {  }],
    ["filter/env/release", {  }],
    ["filter/env/depth", { range: [1, 127], dispOff: -64 }],
    ["amp/level", {  }],
    ["amp/key/trk", { range: [54, 74], dispOff: -64 }],
    ["amp/velo", { range: [1, 127], dispOff: -64 }],
    ["amp/env/attack", {  }],
    ["amp/env/decay", {  }],
    ["amp/env/sustain", {  }],
    ["amp/env/release", {  }],
    ["porta", { max: 1 }],
    ["porta/time", {  }],
    ["legato", { max: 1 }],
    ["octave/shift", { range: [61, 67], dispOff: -64 }],
    ["bend/up", { max: 24 }],
    ["bend/down", { max: 24 }],
  ]}
  ["lfo/pitch/mod", { b: 0x0038, range: [1, 127], dispOff: -64 }],
  ["lfo/filter/mod", { b: 0x0039, range: [1, 127], dispOff: -64 }],
  ["lfo/amp/mod", { b: 0x003a, range: [1, 127], dispOff: -64 }],
  ["lfo/rate/mod", { b: 0x003b, range: [1, 127], dispOff: -64 }],
]

const commonPatchWerk = {
  single: 'Analog Common',
  parms: commonParms,
  size: 0x40, 
  name: [0, 0x0b],
}

const extraPatchWerk = {
  single: "Analog Extra",
  size: 0x111,
}

const patchWerk = {
  multi: "Analog",
  map: [
    ["common", 0x0000, commonPatchWerk],
    ["extra", 0x0200, extraPatchWerk],
  ],
}

  //  static func location(forData data: Data) -> Int {
//    return Int(addressBytes(forSysex: data)[1])
//  }
  
//  const fileDataCount = 513
  
// 354: what it *should* be based on the size of the subpatches
// 513: what is *is* bc the JD-Xi sends an extra sysex msg. undocumented
//  static func isValid(fileSize: Int) -> Bool {
//    return fileSize == fileDataCount || fileSize == 354
//  }

const bankWerk = {
  multiBank: patchWerk, 
  patchCount: 128,
  initFile: "jdxi-analog-bank-init",
  // let iso = iso ?? .init(address: {
  //   RolandAddress(0x010000) * Int($0)
  // }, location: {
  //   $0.sysexBytes(count: 4)[1]
  // })
}

module.exports = {
  patchWerk,
  bankWerk,
}
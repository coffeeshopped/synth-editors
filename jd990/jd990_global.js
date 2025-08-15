
const parms = [
  ["mode", { b: 0x00, opts: ["Patch", "Performance", "Rhythm"] }],
  ["tune", { b: 0x01, max: 100, dispOff: -50 }],
  ["contrast", { b: 0x02, max: 7, dispOff: 1 }],
  ["text/style", { b: 0x03, opts: ["Type 1", "Type 2"] }],
  ["rhythm/out", { b: 0x04, opts: ["Key Out", "All Mix"] }],
  ["patch/remain", { b: 0x05, max: 1 }],
  ["start/mode", { b: 0x06, opts: ["Last Set", "Default"] }],
  ["tone/ctrl/src/0", { b: 0x07, max: 1 }],
  ["tone/ctrl/src/1", { b: 0x08, max: 1 }],
  ["fx/ctrl/src/0", { b: 0x09, max: 1 }],
  ["fx/ctrl/src/1", { b: 0x0a, max: 1 }],
  ["fx/chorus/on", { b: 0x0b, max: 1 }],
  ["fx/delay/on", { b: 0x0c, max: 1 }],
  ["fx/reverb/on", { b: 0x0d, max: 1 }],
  ["fx/0/on", { b: 0x0e, max: 1 }],
  ["patch/channel", { b: 0x0f, max: 17, formatter: {
    switch $0 {
    case 16: return "Part"
    case 17: return "Off"
    default:
      return `${$0+1}`
    }
  }],
  ["rhythm/channel", { b: 0x10, max: 18, formatter: {
    switch $0 {
    case 16: return "Patch"
    case 17: return "Part 8"
    case 18: return "Off"
    default:
      return `${$0+1}`
    }
  }],
  ["ctrl/channel", { b: 0x11, max: 16, formatter: {
    return $0 == 16 ? "Off" : `${$0+1}`
  }],
  ["rcv/pgmChange", { b: 0x12, max: 1 }],
  ["rcv/volume", { b: 0x13, max: 1 }],
  ["rcv/bend", { b: 0x14, max: 1 }],
  ["rcv/aftertouch", { b: 0x15, max: 1 }],
  ["rcv/mod", { b: 0x16, max: 1 }],
  ["rcv/breath", { b: 0x17, max: 1 }],
  ["rcv/expression", { b: 0x18, max: 1 }],
  ["rcv/foot", { b: 0x19, max: 1 }],
  ["eq/hi", { b: 0x1a, max: 10, dispOff: -5 }],
  ["eq/mid", { b: 0x1b, max: 10, dispOff: -5 }],
  ["eq/lo", { b: 0x1c, max: 10, dispOff: -5 }],
  ["preview/mode", { b: 0x1d, opts: ["Single", "Chord"] }],
  { prefix: 'preview/note', count: 4, bx: 1, block: [
    ["", { b: 0x1e, max: 88, formatter: {
      return $0 == 0 ? "Off" : ParamHelper.noteName($0 + 20)
    }],
  ] },
  { prefix: 'preview/velo', count: 4, bx: 1, block: [
    ["", { b: 0x22, rng: [1, 127] }],
  ] },
]

const patchWerk = {
  single: 'global',
  parms: parms,
  initFile: "jd990-system-init",
  size: 0x26,
}
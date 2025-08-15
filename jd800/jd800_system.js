

const parms = [
  { inc: 1, b: 0x00, block: [
    ["tune", { max: 100, dispOff: -50 }],
    ["hi", { max: 10, dispOff: -5 }],
    ["mid", { max: 10, dispOff: -5 }],
    ["lo", { max: 10, dispOff: -5 }],
    ["chorus/on", { max: 1 }],
    ["delay/on", { max: 1 }],
    ["reverb/on", { max: 1 }],
    ["delay/mid/time", { max: 125 }],
    ["delay/mid/level", { max: 100 }],
    ["delay/left/time", { max: 125 }],
    ["delay/left/level", { max: 100 }],
    ["delay/right/time", { max: 125 }],
    ["delay/right/level", { max: 100 }],
    ["delay/feedback", { max: 98, dispOff: -48 }],
    ["chorus/rate", { max: 99 }],
    ["chorus/depth", { max: 100 }],
    ["chorus/delay", { max: 99 }],
    ["chorus/feedback", { max: 98 }],
    ["chorus/level", { max: 100 }],
    ["reverb/type", { opts: ["ROOM1", "ROOM2", "HALL1", "HALL2", "HALL3", "HALL4", "GATE", "REVERSE", "FLYING1", "FLYING2"] }],
    ["reverb/pre", { max: 121 }],
    ["reverb/early", { max: 100 }],
    ["reverb/hi/cutoff", { opts: ["500", "630", "800", "1k", "1.25k", "1.6k", "2k", "2.5k 3.15k", "4k", "5k", "6.3k 8k", "10k 12.5k", "16kHz", "BYPASS"] }],
    ["reverb/time", { max: 100 }],
    ["reverb/level", { max: 100 }],
  ] },
]

const patchWerk = {
  single: 'system',
  initFile: "jd800-system-init",
  size: 0x19,
  parms: parms,
}
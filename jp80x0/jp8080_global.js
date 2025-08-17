

const metroIso = Miso.switcher([
  .range(0...3, Miso.m(-1) >>> Miso.a(4) >>> Miso.str("Beep %g")),
  .int(4, "Off"),
  .range(5...8, Miso.a(-4) >>> Miso.str("Click %g")),
])

const parameterParms = [
  { inc: 1, b: 0x00, block: [ 
    ["perf/bank", { rng: [1, 3], iso: Miso.options(["User", "Preset", "Card"], startIndex: 1) }],
    ["perf/number", { max: 63 }],
    ["perf/ctrl/channel", { max: 16, iso: Miso.switcher([
      .range(0...15, Miso.a(1) >>> Miso.str()),
      .int(16, "Off"),
    ]) }],
    ["on/mode", { opts: ["Perf U-11", "Last-Set"] }],
    ["midi/sync", { opts: ["Off", "MIDI In", "Remote KBD In"] }],
    ["local", { max: 1 }],
    ["send/rcv/edit/mode", { opts: ["Mode 1", "Mode 2"] }],
    ["send/rcv/edit/on", { max: 1 }],
    ["send/rcv/pgmChange/mode", { opts: ["Off", "PC", "Bank Sel+PC"] }],
  ] },
  { inc: 1, b: 0x0a, block: [
    ["tune", { max: 100, dispOff: -50 }],
    ["pattern/trigger/quantize", { opts: ["Off", "Beat", "Measure"] }],
    ["motion/reset", { max: 1 }],
    ["motion/preset", { opts: ["A", "B"] }],
    [("gate/time/ratio", { opts: ["Real", "Staccato", "33%", "50%", "66%", "100%"] }],
    ["input/quantize", { opts: ["Off", "1/16(3)", "1/16", "1/8(3)", "1/8", "1/4(3)", "1/4"] }],
    ["pattern/metro", { max: 8, dispOff: -4, iso: metroIso }],
    ["motion/metro", { max: 8, dispOff: -4, iso: metroIso }],
  ] },
  ["perf/group", { b: 0x17, max: 63, dispOff: 1 }],
  ["ext/key/channel", { b: 0x18, max: 16, iso: Miso.switcher([
    .range(0...15, Miso.a(1) >>> Miso.str()),
    .int(16, "All"),
  ]) }],
]

const parameterWerk = {
  single: 'perf.parameter',
  initFile: "jp8080-global-parameter-init",
  size: 0x19,
}


const lenIso = ['switch', [
  [0, "Play Once"],
  [[1, 8], ['unitFormat' ,"-bar"]],
 ]]

const motionParms = [
 ["0/0/length", { max: 8, iso: lenIso }],
 ["0/1/length", { max: 8, iso: lenIso }],
 ["1/0/length", { max: 8, iso: lenIso }],
 ["1/1/length", { max: 8, iso: lenIso, }] 
]

const motionWerk = {
  single: 'global.motion',
  initFile: "jp8080-global-motion-init",
  size: 0x04,
  parms: motionParms,
}


const ctrlIso = ['switch', [
  [0, "Off"],
  [[1, 31], []],
  [32, "After"],
  [[33, 95], []],
  [96, "Sysex"],
])

const txp(path) => [path, {max: 96, iso: ctrlIso}]

const txRxParms = [
  { inc: 1, b: 0x00, block: [
    txp("lfo/0/rate"),
    txp("lfo/0/fade"),
    txp("lfo/1/rate"),
    txp("cross"),
    txp("osc/balance"),
    txp("pitch/lfo/0/depth"),
    txp("pitch/lfo/1/depth"),
    { prefix: "pitch/env", block: [
      txp("depth"),
      txp("attack"),
      txp("decay"),
    ] },
    { prefix: "osc/0", block: [
      txp("ctrl/0"),
      txp("ctrl/1"),
    ] },
    { prefix: "osc/1", block: [
      txp("range"),
      txp("fine"),
      txp("ctrl/0"),
      txp("ctrl/1"),
    ] },
    { prefix: "filter", block: [
      txp("cutoff"),
      txp("reson"),
      txp("key/trk"),
      txp("lfo/0/depth"),
      txp("lfo/1/depth"),
      { prefix: "env", block: [
        txp("depth"),
        txp("attack"),
        txp("decay"),
        txp("sustain"),
        txp("release"),
      ] },         
    ] },
    { prefix: "amp", block: [
      txp("level"),
      txp("lfo/0/depth"),
      txp("lfo/1/depth"),
      { prefix: "env", block: [
        txp("attack"),
        txp("decay"),
        txp("sustain"),
        txp("release"),
      ] },
    ] },
    txp("eq/lo"),
    txp("eq/hi"),
    txp("fx/level"),
    txp("delay/time"),
    txp("delay/feedback"),
    txp("delay/level"),
    txp("porta/time"),
  ] }, 
  ["morph/ctrl/up", { b: 0x28, max: 95, iso: ctrlIso }],
  ["morph/ctrl/down", { b: 0x29, max: 95, iso: ctrlIso }],
] 

const txrxWerk = {
  single: 'global.txrx',
  initFile: "jp8080-global-txrx-init",
  size: 0x2a,
  parms: txRxParms,
}

const patchWerk = {
  multi: 'global',
  map: [
    ["param", 0x0000, parameterWerk],
    ["motion", 0x2000, motionWerk],
    ["rcv", 0x3000, txrxWerk],
  ],
  initFile: "jp8080-global-init",
}
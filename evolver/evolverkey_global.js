
const footCtrlOptions = ["Foot Ctrl", "Breath", "Expression", "Volume", "LpFilter", "LpF Half"]

const polyChainOptions = (0..<20.map {
  return $0 == 0 ? "None" : `${$0+1} voices`
})

const patchTruss = EvolverGlobal.patchTruss
patchTruss.parms = patchTruss.parms.concat([
  // different options
  ["poly/chain", { b: 9, opts: polyChainOptions }],
  
  ["pgmChange", { b: 18, max: 1 }],
  ["pressure", { b: 19, max: 1 }],
  ["ctrl", { b: 20, max: 1 }],
  ["sysex", { b: 21, max: 1 }],
  ["foot/0/dest", { b: 22, opts: footCtrlOptions }],
  ["foot/1/dest", { b: 23, opts: footCtrlOptions }],
  ["velo/curve", { b: 24, max: 3 }],
  ["pressure/curve", { b: 25, max: 3 }],
  ["local", { b: 26, max: 1 }],
  ["redamper/polarity", { b: 27, opts: ["Open", "Closed"] }],
])
patchTruss.initFile = "evolver-global-key-init"
patchTruss.parseBody = ['>',
  ['bytes', { start: 5, count: 56 }],
  ['denibblizeLSB'],
]


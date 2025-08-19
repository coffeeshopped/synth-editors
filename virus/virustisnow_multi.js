
const outOptions = ["Out1 L", "Out1 L+R", "Out1 R"]

const patchTruss = VirusTIMulti.patchTruss
patchTruss.parms = patchTruss.parms.concat([
  {prefix: 'part', count: 16, bx: 1, block: [
    ["out", { p: 0x29, b: 176, opts: outOptions }],    
  ] },
])
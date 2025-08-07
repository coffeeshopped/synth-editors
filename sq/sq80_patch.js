const ESQPatch = require('./esq_patch.js')

const extendedWaves = ["Saw", "Bell", "Sine", "Square", "Pulse", "Noise 1", "Noise 2", "Noise 3", "Bass", "Piano", "Electric Piano", "Voice 1", "Voice 2", "Kick", "Reed", "Organ", "Synth 1", "Synth 2", "Synth 3", "Formant 1", "Formant 2", "Formant 3", "Formant 4", "Formant 5", "Pulse 2", "Square 2", "Four Octaves", "Prime", "Bass 2", "Electric Piano 2", "Octave", "Octave +5", "Saw 2", "Triangle", "Reed 2", "Reed 3", "Grit 1", "Grit 2", "Grit 3", "Glint 1", "Glint 2", "Glint 3", "Clav", "Brass", "String", "Digit 1", "Digit 2", "Bell 2", "Alien", "Breath", "Voice3", "Steam", "Metal", "Chime", "Bowing", "Pick 1", "Pick 2", "Mallet", "Slap", "Plink", "Pluck", "Plunk", "Click", "Chiff", "Thump", "Logdrm", "Kick2", "Snare", "Tomtom", "Hihat", "Drums 1", "Drums 2", "Drums 3", "Drums 4", "Drums 5"]
  
const patchTruss = ESQPatch.patchTruss
patchTruss.parms = patchTruss.parms.concat([
  { prefix: 'osc', count: 3, bx: 10, px: 8, block: [
    ["wave", { p: 67, b: 63, opts: extendedWaves }],
  ] },  
  { prefix: 'env', count: 4, bx: 10, px: 10, block: [
    ["velo/extra", { p: 3, b: 13, bit: 0, opts: ["Lin", "Exp"])
    ["release/extra", { p: 8, b: 12, bit: 7)
  ] },
])

const bankTruss = ESQPatch.bankTruss
bankTruss.patchTruss = patchTruss

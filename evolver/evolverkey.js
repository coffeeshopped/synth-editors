const Global = require('./evolverkey_global.js')
const Voice = require('./evolverkey_voice.js')
const Wave = require('./evolver_wave.js')

const editor = {
  name: "",
  trussMap: ([
    ["global", Global.patchTruss],
    ['patch', Voice.patchTruss],
    ['wave', Wave.patchTruss],
    ['bank/wave', Wave.bankTruss],
  ]).concat(
    (4).map(i => [['bank', i], Voice.bankTruss])
  ),
  fetchTransforms: ([
    ["global", fetch([0x0e])],
    ['patch', fetch([0x06])],
    ['wave', fetch([0x0b, waveNumber])],
    ['bank/wave', ['bankTruss', fetchBytes([0x0b, ['+', 'b', 96]])]],
  ]).concat(
    // 1 request should return both patch and name data
    (4).map(i => [['bank', i], ['bankTruss', fetchBytes([0x05, i, 'b'])]])
  )

  midiOuts: ([
    ["global", Global.patchTransform],
    ['patch', Voice.patchTransform],
    ['wave', Wave.patchTransform],
    ['bank/wave', Wave.bankTransform],
  ]).concat(
    (4).map(i => [['bank', i], Voice.bankTransform(i)])
  ),
    
  midiChannels: [
    ["voice", "basic"],
  ],
  slotTransforms: [
  ],
}

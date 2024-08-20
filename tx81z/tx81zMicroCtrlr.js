
const ccFn = (state, locals) =>
  noteFine(locals['note'] || 0, locals['fine'] || 0)

const noteLabel = i => (["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"])[i % 12]

const noteController = showOctave => ({
  prefix: ['index', []],
  builders: [
    ['grid', {color: 1}, [[
      {l: "?", id: 'id'},
      [{knob: "Note", id: 'note'}],
      [{knob: "Fine", id: 'fine'}],
    ]]]
  ], 
  effects: [
    ['indexChange', i => [
      ['dimPanel', i > 127, null, 0],
      ['setCtrlLabel', 'id', noteLabel(i) + (showOctave ? `${Math.floor(i / 12) - 2}` : "")],
    ]],
    ['patchChange', {
      paths: ['note', 'fine'], 
      fn: values => {
        const n = values['note'] || 0
        const f = values['fine'] || 0
        return [
          ['setValue', 'note', f > 32 ? n + 1 : n],
          ['setValue', 'fine', f > 32 ? f - 64 : f],
        ]
      }
    }],
    ['controlChange', 'note', ccFn],
    ['controlChange', 'fine', ccFn],
    ['setup', [
      ['configCtrl', 'note', {max: 109}],
      ['configCtrl', 'fine', {range: [-31, 33]}],
    ]],
  ]
})

const noteFine = (n, f) => [
  ['note', f < 0 ? n - 1 : n],
  ['fine', f < 0 ? f + 64 : f],
]


module.exports = {
  octController: ['oneRow', 12, noteController(false)],
  fullController: {
    builders: [
      ['children', 12, "p", noteController(true), (parentI, off) => 12 * parentI + off],
      ['switcher', (11).map(i => `${i-2}`), {l: "Octave", color: 1}],
    ], 
    gridLayout: [
      {row: [["switch", 11]], h: 1},
      {row: (12).map(i => [`p${i}`, 1]), h: 3},
    ],
  },
}

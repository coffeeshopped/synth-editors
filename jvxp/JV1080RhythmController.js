const VoiceCtrlr = require('./JV1080VoiceController.js')
const Rhythm = require('./JV1080Rhythm.js')

const pitch = {
  builders: [
    ['grid', [[
      ['Key', 'src/key'],
      ['Fine', 'fine'],
      ['Random', 'random/pitch'],
      ['Velo→Env Time', 'pitch/env/velo/time'],
    ],[
      VoiceCtrlr.pitchEnvs.env,
      ['Env→Pitch', 'pitch/env/depth'],
      ['Velo→Env D', 'pitch/env/velo/sens'],
    ],
    (4).map(i => [`T${i}`, `pitch/env/time/${i}`]),
    (4).map(i => [`L${i}`, `pitch/env/level/${i}`]),
    ]],
  ],
  effects: [VoiceCtrlr.pitchEnvs.effect],
}

const filter = {
  builders: [
    ['grid', [[
      [{ select: 'Filter' }, 'filter/type'],
      ['Cutoff', 'cutoff'],
      ['Reson', 'reson'],
      ['Velo→Reson', 'reson/velo/sens'],
    ],[
      VoiceCtrlr.filterEnvs.env,
      ['Env→Cutoff', 'filter/env/depth'],
      ['Velo→Env D', 'filter/env/velo/sens'],
      ['Velo→Env Time', 'filter/env/velo/time'],
    ],
    (4).map(i => [`T${i}`, `filter/env/time/${i}`]),
    (4).map(i => [`L${i}`, `filter/env/level/${i}`]),
    ]],
  ],
  effects: [VoiceCtrlr.filterEnvs.effect],
}

const amp = {
  builders: [
    ['grid', [[
      ['Level', 'tone/level'],
      ['Pan', 'pan'],
      ['Random Pan', 'random/pan'],
      ['Alt Pan', 'alt/pan'],
    ],[
      VoiceCtrlr.ampEnvs.env,
      ['Velo→Env D', 'amp/env/velo/sens'],
      ['Velo→Env Time', 'amp/env/velo/time'],
    ],
    (4).map(i => [`T${i}`, `amp/env/time/${i}`]),
    (3).map(i => [`L${i}`, `amp/env/level/${i}`]),
    ]],
  ],
  effects: [VoiceCtrlr.ampEnvs.effect],
}


const allPaths = Rhythm.noteParms

const controller = {
  prefix: {index: 'note'},
  builders: [
    ['child', VoiceCtrlr.wave, 'wave', { color: 1 }],
    ['child', pitch, 'pitch', { color: 1 }],
    ['child', filter, 'filter', { color: 2 }],
    ['child', amp, 'amp', { color: 3 }],
    ['switcher', (64).map(i => {
      const noteNum = i + 35
      const noteName = '?' // ParamHelper.noteName(noteNum)
      return `${noteName}: ${noteNum}`
    }), { cols: 12, color: 1 }],
    ['panel', 'ctrl', { color: 1 }, [[
      ['Bend Range', 'bend/range'],
      ['Mute Group', 'mute/group'],
      [{ checkbox: 'Env Sustain' }, 'env/sustain'],
      [{ checkbox: 'Vol Ctrl' }, 'volume/ctrl'],
      [{ checkbox: 'Hold-1 Ctrl' }, 'hold/ctrl'],
      [{ switch: 'Pan Ctrl' }, 'pan/ctrl'],
    ]]],
    ['button', 'Note', { color: 1 }],
    ['panel', 'output', { color: 3 }, [[
      [{ select: 'Output' }, 'out/assign'],
      ['Level', 'out/level'],
      ['Chorus', 'chorus'],
      ['Reverb', 'reverb'],
    ]]],
  ],
  effects: [
    ['editMenu', 'button', { paths: allPaths, type: 'JV1080RhythmNote' }],
    ['indexChange', index => [
      ['midiNote', { chan: 0, note: 35 + index, velo: 100, len: 500 }],
    ]],
  ],
  layout: [
    ['row', [['switch', 1]]],
    ['row', [['wave', 5], ['ctrl', 6.5], ['button', 1.5]]],
    ['row', [['pitch', 4], ['filter', 5], ['amp', 4], ['output', 1.5]]],
    ['col', [['switch', 4], ['wave', 1], ['pitch', 4]]],
  ],
}

module.exports = {
  controller,
  pitch,
  filter,
  amp,
}


const GlobalCtrlr = require('./jv1080_global_controller.js')
const VoiceCtrlr = require('./jv1080_voice_controller.js')
const RhythmCtrlr = require('./jv1080_rhythm_controller.js')

const moduleTruss = (editorTruss, subid, sections) => ({
  editor: editorTruss,
  manu: "Roland", 
  model: editorTruss.displayId, 
  subid: subid, 
  sections: sections, 
  dirMap: [
    ['part', "Patch"],
  ], 
  colorGuide: [
    "#093aba",
    "#a9dd36",
    "#0303fd",
    "#03ff0d",
  ], 
  indexPath: [2, 0],
})

const sections = cfg => {
  const voice = perfPart => VoiceCtrlr.controller(cfg, perfPart)
  
  return [
    ['first', [
      'deviceId',
      ['global', GlobalCtrlr.controller],
      ['voice', "Patch", voice(null)],
    ]],
    ['basic', "Tones", [
      ['perf', cfg.perf],
    ].concat(
      (9).map(i => ['voice', `Buffer ${i + 1}`, voice(i), `part/${i}`])
    ).concat([
      ['custom', "Rhythm", "rhythm", RhythmCtrlr.controller],
    ]).concat(
      (6).map(i => ['voice', `Buffer ${i + 11}`, voice(i + 10), `part/${i + 10}`])
    )],
    ['banks', [
      ['bank', "Patch Bank", "bank/patch/0"],
      ['bank', "Perf Bank", "bank/perf/0"],
      ['bank', "Rhythm Bank", "bank/rhythm/0"],
    ]],
  ]
}

module.exports = {
  sections: sections,
  moduleTruss: moduleTruss,
}
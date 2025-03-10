const Editor = require('./BlofeldEditor.js')
const GlobalCtrlr = require('./BlofeldGlobalController.js')
const VoiceCtrlr = require('./BlofeldVoiceController.js')
const PerfCtrlr = require('./BlofeldMultiController.js')

module.exports = {
  module: {
    editor: Editor.editor,
    manu: "Waldorf",
    model: Editor.editor.displayId,
    subid: 'blofeld',
    sections: [
      ['first', [
        ['global', GlobalCtrlr.controller],
        ['voice', "Temp Voice", 'voice', VoiceCtrlr.controller],
      ]],
      ['basic', "Multi Mode", [
        // .fullRef(title: "Full Multi"),
        ['perf', PerfCtrlr.controller, "Multi"],
        ['perfParts', 16, i => `Part ${i + 1}`, VoiceCtrlr.controller],
      ]]
      ['banks', [
        ['banks', 8, i => `Bank ${Voice.bankLetter(i)}`, 'bank'], 
        ['bank', "Multi Bank", 'perf/bank'],
      ]],
      // .backup,
    ],
    dirMap: [
      ['perf', "MultiMode*"],
      ['perf/bank', "Multi Bank"],
      ['part', "Patch"],
      ['bank', "Voice Bank"],
    ],
    colorGuide: [
      "#3975d7",
      "#e49031",
      "#e43190",
      "#34f190",
    ],
  }
}

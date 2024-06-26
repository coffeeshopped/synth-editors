const MoEd = require('editor.js')
const MophoEditor = MoEd.MophoEditor
const MophoKeyEditor = MoEd.MophoKeyEditor

const GlobalCtrlr = require('./controller/global.js')
const VoiceCtrlr = require('./controller/main.js')

const createModuleTruss = (name, subid, globalCtrlr, mainCtrlr) => {
  return {
    editor: createEditorTruss(name),
    manu: "DSI",
    subId: subid,
    sections: [
      ['first', [
        ["global", global],
        ["patch", "Voice", main],
      ]],
      ['basic', "Voice Bank", [
        ['bank', "Bank 1", ["bank", 0]],
        ['bank', "Bank 2", ["bank", 1]],
        ['bank', "Bank 3", ["bank", 2]],
      ]],
      'backup',
    ],
    dirMap: [
    ], 
    colorGuide: [
      "#FDC63F",
      "#4080ff",
      "#a3e51e",
      "#ff6347",
    ],
  } 
} 

// class MophoKeyModule {
//   static EditorTemplate = MophoKeyEditor
// 
//   static colorGuide = MophoModule.colorGuide
//   
//   static sections = makeSections(function() { MophoKeysGlobalController() }, function() { MophoKeysMainController.controller() })
//   
// }

module.exports = {
  createModuleTruss: createModuleTruss,
  module: createModuleTruss("Mopho", "mopho")
}

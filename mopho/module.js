const MoEd = require('editor.js')
const MophoEditor = MoEd.MophoEditor
const MophoKeyEditor = MoEd.MophoKeyEditor
const { bankCtrlr, backupCtrlr } = require('/core/Controller.js')

function makeSections(global, main) {
  return [
    [null, [
      ["Global", ["global"], global],
      ["Voice", ["patch"], () => KeyController.controller(main(), {})],
    ]],
    ["Voice Bank", [
      ["Bank 1", ["bank", 0], bankCtrlr],
      ["Bank 2", ["bank", 1], bankCtrlr],
      ["Bank 3", ["bank", 2], bankCtrlr],
    ]],
    ["Backup", [
      ["Backup", ["backup"], backupCtrlr], 
    ]]
  ]
}


const MophoModule = {
  EditorTemplate: MophoEditor,
  
  colorGuide: [
    "#FDC63F",
    "#4080ff",
    "#a3e51e",
    "#ff6347",
    ],
      
  sections: makeSections(require('./controller/global.js'), require('./controller/main.js')),
}


class MophoKeyModule {
  static EditorTemplate = MophoKeyEditor

  static colorGuide = MophoModule.colorGuide
  
  static sections = makeSections(function() { MophoKeysGlobalController() }, function() { MophoKeysMainController.controller() })
  
}

module.exports = MophoModule

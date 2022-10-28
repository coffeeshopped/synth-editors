const MoEd = require('editor.js')
const MophoEditor = MoEd.MophoEditor
const MophoKeyEditor = MoEd.MophoKeyEditor

function defaultBankEditorBlock() {
  return BankController.controller()
}

function defaultBackupEditorBlock() {
  return BackupController.controller()
}

function makeSections(global, main) {
  return [
    [null, [
      ["Global", ["global"], global],
      ["Voice", ["patch"], () => KeyController.controller(main(), {})],
    ]],
    ["Voice Bank", [
      ["Bank 1", ["bank", 0], defaultBankEditorBlock],
      ["Bank 2", ["bank", 1], defaultBankEditorBlock],
      ["Bank 3", ["bank", 2], defaultBankEditorBlock],
    ]],
    ["Backup", [
      ["Backup", ["backup"], defaultBackupEditorBlock], 
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

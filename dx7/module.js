const { bankCtrlr, backupCtrlr } = require('/core/Controller.js')

module.exports = {
  EditorTemplate: require('editor.js'),

  colorGuide: [
    "#FDC63F",
    "#4080ff",
    "#a3e51e",
    "#ff6347",
  ],
  
  sections: [
    [null, [
      // ["Global", ["global"], global],
      ["Voice", ["patch"], () => KeyController.controller(require('./controller/voice.js')(), {})],
      // ["Voice Bank", ["bank"], bankCtrlr],
    ]],
  ],
}

const { bankCtrlr } = require('/core/Controller.js')

module.exports = {
  EditorTemplate: require('./editor.js'),

  colorGuide: [
    "#FDC63F",
    "#4080ff",
    "#a3e51e",
    "#ff6347",
  ],
  
  sections: [
    [null, [
      ["Global", ["global"], () => require('./controller/channel.js')()],
      ["Voice", ["patch"], () => KeyController.controller(require('./controller/voice.js')(), {})],
      ["Voice Bank", ["bank"], bankCtrlr],
    ]],
  ],
}

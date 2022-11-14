# module.js

Your module.js file should export a single object that represents an implemented editor Module. The following describes the properties that object should have in order to properly represent a Module.

### EditorTemplate

An Editor template object (described elsewhere).

### colorGuide

An array of strings representing the colors used by this module. e.g. ["#FDC63F", "#4080ff", "#a3e51e"]

### sections

A multi-dimensional array describing the sections of this module, and the title, path, and controller for each part. Example:

    [null, [
      ["Global", ["global"], () => require('./controller/channel.js')()],
      ["Voice", ["patch"], () => KeyController.controller(require('./controller/voice.js')(), {})],
      ["Voice Bank", ["bank"], bankCtrlr],
    ]],

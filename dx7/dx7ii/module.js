const { bankCtrlr } = require('/core/Controller.js')

module.exports = {
  EditorTemplate: require('editor.js'),

  colorGuide: [
    "#4acd7d",
    "#22bdff",
    "#fd4f45",
  ],
  
  sections: [
    [null, [
      ["Global", ["global"], () => require('controller/global.js')()],
      ["Voice", ["patch"], () => KeyController.controller(require('controller/voice.js')(), {})],
      ["Voice Bank", ["bank"], bankCtrlr],
    ]],
    ["Bank", [
      ["Voices (1-32)", ["bank", 0], bankCtrlr],
      ["Voices (33-64)", ["bank", 1], bankCtrlr],
    ]],
  ],
}

//   public func path(forSysexType sysexType: Sysexible.Type) -> String? {
//     switch sysexType {
//     case is DX7Patch.Type, is TX802VoicePatch.Type, is VoicePatch.Type:
//       return "Patches"
//     case is DX7VoiceBank.Type, is VoiceBank.Type:
//       return "Voice Banks"
//     case is TX802PerfPatch.Type:
//       return "Performances"
//     case is TX802PerfBank.Type:
//       return "Perf Banks"
//     default:
//       return nil
//     }
//   }

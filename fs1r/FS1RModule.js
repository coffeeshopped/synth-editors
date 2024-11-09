const Editor = require('./FS1REditor.js')
const GlobalCtrlr = require('./FS1RGlobalController.js')
const VoiceCtrlr = require('./FS1RVoiceController.js')
const PerfCtrlr = require('./FS1RPerfController.js')

//    public static func onEditorLoad(_ module: TemplatedModule) {
//      module.templatedEditor.patchChangesOutput(forPath: [.global])?.subscribe(onNext: { [unowned module] (change, patch) in
//        let memory: Int
//        switch change {
//        case .replace(let p):
//          memory = p[[.memory]] ?? 0
//        case .paramsChange(let values):
//          guard let mem = values[[.memory]] else { return }
//          memory = mem
//        case .noop: // load!
//          guard let p = patch else { return }
//          memory = p[[.memory]] ?? 0
//        default:
//          return
//        }
//
//        guard memory != module.templatedEditor.getExtra([.memory]) else { return }
//
//        module.templatedEditor.setExtra([.memory], value: memory)
//
//        let paths: [SynthPath] = [[.bank, .voice], [.backup]]
//        paths.forEach {
//          module.reinitWindowController(forSynthPath: $0)
//        }
//
//      }).disposed(by: module.templatedEditor.disposeBag)
//    }

module.exports = {
  module: {
    editor: Editor.editor,
    manu: "Yamaha", 
    model: Editor.editor.displayId, 
    subid: 'fs1r', 
    sections: [
      ['first', [
        ['global', GlobalCtrlr.controller],
        ['perf', PerfCtrlr.controller],
        // ['voice', "Fseq", path: [.fseq], PatchController.patch([])],
        // ['fullRef'],
        ]],
      ['basic', "Parts", ['perfParts', 4, i => `Part ${i + 1}`, VoiceCtrlr.controller]],
      ['banks', [
        ['bank', "Voice Bank", 'bank/voice'],
        ['bank', "Perf Bank", 'bank/perf'],
        ['bank', "Fseq Bank", 'bank/fseq'],
      ]],
      // .backup,
    ], 
    dirMap: [
      ['part', "Patch"],
      ['bank/voice/extra', "Voice Bank"],
    ], 
    colorGuide: [
      "#009f63",
      "#ec421e",
      "#717efe",
      "#79f11e",
    ], 
    indexPath: [0, 1],
  },
}
const Editor = require('./fs1r_editor.js')
const GlobalCtrlr = require('./fs1r_global_ctrlr.js')
const VoiceCtrlr = require('./fs1r_voice_ctrlr.js')
const PerfCtrlr = require('./fs1r_perf_ctrlr.js')

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
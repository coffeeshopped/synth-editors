const JVXP = require('./JVXP.js')

const editor = JVXP.editorTruss("JV-1080", Global.patchWerk, Perf.patchWerk, Voice.patchWerk, Rhythm.patchWerk, Voice.bankWerk, Perf.bankWerk, Rhythm.bankWerk)

const perf = PerfController.controller(showXP: false, show2080: false, config: PerfPart.config)
const sections = JVXP.sections(perf: perf, clkSrc: false, cat: true)
  
//  override func onSave(toBankPath bankPath: SynthPath, index: Int, fromPatchPath patchPath: SynthPath) {
//    // side effect: if saving from a part editor, update performance patch
//    guard patchPath[0] == .part else { return }
//    let params: [SynthPath:Int] = [
//      patchPath + [.patch, .group] : 0,
//      patchPath + [.patch, .group, .id] : 1,
//      patchPath + [.patch, .number] : index
//    ]
//    changePatch(forPath: [.perf], MakeParamsChange(params), transmit: true)
//  }
}

module.exports = {
  module: JVXP.moduleTruss(editor, subid: "jv1080", sections: sections),
}
const JVXP = require('./jvxp.js')
const JVXPModule = require('./jvxp_module.js')
const Voice = require('./jv1080_voice.js')
const Global = require('./jv1080_global.js')
const Perf = require('./jv1080_perf.js')
const Rhythm = require('./jv1080_rhythm.js')

const PerfCtrlr = require('./jv1080_perf_controller.js')

const editor = JVXP.editorTruss("JV-1080", null, Global.patchWerk, Perf.patchWerk, Voice.patchWerk, Rhythm.patchWerk, Voice.bankWerk, Perf.bankWerk, Rhythm.bankWerk)

const perf = PerfCtrlr.controller({ showXP: false, show2080: false, config: Perf.config })
const sections = JVXPModule.sections({ perf: perf, clkSrc: false, cat: true })
  
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
// }

module.exports = {
  module: JVXPModule.moduleTruss(editor, "jv1080", sections),
}

const JVXP = require('./JVXP.js')
const Voice = require('./JV1080Voice.js')
const Global = require('./JV1080Global.js')
const Perf = require('./JV1080Perf.js')
const Rhythm = require('./JV1080Rhythm.js')

const PerfCtrlr = require('./JV1080PerfController.js')

const editor = JVXP.editorTruss("JV-1080", null, Global.patchWerk, Perf.patchWerk, Voice.patchWerk, Rhythm.patchWerk, Voice.bankWerk, Perf.bankWerk, Rhythm.bankWerk)

const perf = PerfCtrlr.controller({ showXP: false, show2080: false, config: PerfPart.config })
const sections = JVXP.sections({ perf: perf, clkSrc: false, cat: true })
  
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
  module: JVXP.moduleTruss(editor, "jv1080", sections),
}

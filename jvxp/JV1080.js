const JVXP = require('./jvxp.js')
const JVXPModule = require('./jvxp_module.js')
const Perf = require('./jv1080_perf.js')

const editor = JVXP.editorTruss("JV-1080", null, {
  global: 'jv1080',
  perf: 'jv1080',
  voice: 'jv1080',
})
  
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
  module: JVXPModule.moduleTruss(editor, "jv1080", { 
    perf: { 
      showXP: false, 
      show2080: false, 
      config: Perf.config 
    }, 
    clkSrc: false, 
    cat: true,
  }),
}

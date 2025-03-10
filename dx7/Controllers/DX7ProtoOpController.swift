
//class DX7ProtoOpController : NewPatchEditorController {
//  
//  override open var prefix: SynthPath? { return [.op, .i(index)] }
//
//  let envControl = PBRateLevelEnvelopeControl(label: "")
//
//  func addEnvCtrlBlocks() {
//    let envControl = self.envControl
//    envControl.sustainPoint = 2
//    (0..<4).forEach { step in
//      addPatchChangeBlock(path: [.rate, .i(step)]) {
//        envControl.set(rate: 1 - CGFloat($0) / 99, forIndex: step)
//      }
//      addPatchChangeBlock(path: [.level, .i(step)]) {
//        envControl.set(level: CGFloat($0) / 99, forIndex: step)
//      }
//    }
//  }
//    
//}
//

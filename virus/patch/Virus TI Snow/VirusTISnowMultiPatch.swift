
class VirusTISnowMultiPatch : VirusTIMultiPatch {
  
  private static let _params: SynthPathParam = {
    var p = VirusTIMultiPatch.params
    
    (0..<16).forEach { part in
      let pre: SynthPath = [.part, .i(part)]
      let boff = part
      p[pre + [.out]] = MisoParam.make(parm: 0x29, byte: boff + 176, options: outOptions)
    }
    
    return p
  }()
  
  override class var params: SynthPathParam { return _params }

  private static let outOptions = ["Out1 L", "Out1 L+R", "Out1 R"]

}

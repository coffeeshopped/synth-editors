
//open class DX7IIVoicePatch : TX802VoicePatch {
//
//  open override class var bankType: SysexPatchBank.Type { DX7IIVoiceBank.self }
//  
//  private static let _subpatchTypes: [SynthPath : SysexPatch.Type] = [
//    [.voice] : DX7Patch.self,
//    [.extra] : DX7IIACEDPatch.self,
//    ]
//  open override class var subpatchTypes: [SynthPath : SysexPatch.Type] { _subpatchTypes }
//  
//  required public init(data: Data) {
//    super.init(data: data)
//  }
//  
//  required public init(vced: DX7Patch, aced: TX802ACEDPatch) {
//    super.init(vced: vced, aced: aced)
//  }
//    
//}
//
//open class DX7IIACEDPatch : TX802ACEDPatch {
//  
//  public class override var bankType: SysexPatchBank.Type { DX7IIACEDBank.self }
//  
//  required public init(data: Data) {
//    super.init(data: data)
//  }
//  
//  required public init(bankData: Data) {
//    super.init(bankData: bankData)
//  }
//  
//  private static let _params: SynthPathParam = {
//    var p = TX802ACEDPatch.params
//    p[[.mono]] = OptionsParam(byte: 15, options: ["Poly","Mono", "Uni Poly", "Uni Mono"])
//    return p
//  }()
//  
//  open override class var params: SynthPathParam { _params }
//}

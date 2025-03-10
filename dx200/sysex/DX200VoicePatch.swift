
class DX200VoicePatch : TX802VoicePatch {
  
  override class var bankType: SysexPatchBank.Type { return DX200VoiceBank.self }
  
  private static let _subpatchTypes: [SynthPath : SysexPatch.Type] = [
    [.voice] : DX7Patch.self,
    [.extra] : DX200ACEDPatch.self,
    ]
  override class var subpatchTypes: [SynthPath : SysexPatch.Type] { return _subpatchTypes }

}

class DX200ACEDPatch : TX802ACEDPatch {

  private static let _params: SynthPathParam = {
    var p = TX802ACEDPatch.params
    p[[.mono]] = OptionsParam(byte: 15, options: ["Poly","Mono", "Poly Uni", "Mono Uni"])
    return p
  }()
  
  override class var params: SynthPathParam { return _params }
  
}

class DX200VoiceBank : TX802ishVoiceBank {
  typealias ACEDBank = DX200ACEDBank

  var patches: [DX200VoicePatch]
  var name = ""
  
  required init(data: Data) {
    patches = type(of: self).patchArray(fromData: data)
  }
  
  required init(patches p: [DX200VoicePatch]) {
    patches = p
  }
  
  func copy() -> Self {
    Self.init(patches: patches.map { $0.copy() })
  }

}

class DX200ACEDBank : TX802ACEDishBank {
  
  var patches: [DX200ACEDPatch]
  var name = ""
  
  required init(data: Data) {
    patches = type(of: self).patchArray(fromData: data)
  }
  
  required init(patches p: [DX200ACEDPatch]) {
    patches = p.map { $0.copy() }
  }
  
  func copy() -> Self {
    Self.init(patches: patches.map { $0.copy() })
  }

}

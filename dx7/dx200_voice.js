
class DX200VoicePatch : TX802VoicePatch {
  
  private const _subpatchTypes: [SynthPath : SysexPatch.Type] = [
    "voice" : DX7Patch.self,
    "extra" : DX200ACEDPatch.self,
    ]
}

const acedTruss = TX802.acedTruss
acedTruss.parms = acedTruss.parms.concat([
  ["mono", { b: 15, opts: ["Poly","Mono", "Poly Uni", "Mono Uni"] }],
])

class DX200VoiceBank : TX802ishVoiceBank {
  typealias ACEDBank = DX200ACEDBank
  var patches: [DX200VoicePatch]
}

class DX200ACEDBank : TX802ACEDishBank {
  var patches: [DX200ACEDPatch]
}

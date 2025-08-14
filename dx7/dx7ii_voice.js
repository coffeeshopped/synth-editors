
const acedTruss = TX802Voice.acedTruss
acedTruss.parms = acedTruss.parms.concat([
  ["mono", { b: 15, opts: ["Poly","Mono", "Uni Poly", "Uni Mono"] }],
])

const patchTruss = {
  multi: 'voice',
  map: [
    ["voice", DX7Voice.patchTruss,
    ["extra", acedTruss,
  ]
}


public class DX7IIVoiceBank : TX802ishVoiceBank, DX7IIishVoiceBank {
 
 public typealias ACEDBank = DX7IIACEDBank
 
 public var patches: [DX7IIVoicePatch]
}
 
public class DX7IIACEDBank : TX802ACEDishBank {
 
 public var patches: [DX7IIACEDPatch]

}


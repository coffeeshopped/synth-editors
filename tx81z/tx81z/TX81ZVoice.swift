
extension TX81Z {

  public enum Voice {
    
    public static let patchTruss = Op4.createVoicePatchTruss(synth, map: map, initFile: "tx81z-init", validSizes: [])
        
    static let map: [(SynthPath, Op4.PatchWerk)] = [
      ([.extra], Op4.ACED.patchWerk),
      ([.voice], Op4.VCED.patchWerk),
    ]
        
    static let bankTruss = Op4.createVoiceBankTruss(patchTruss, patchCount: 32, initFile: "tx81z-voice-bank-init", map: map)
    
    static let bankTransform = Op4.patchBankTransform(map: map)
        
  }
  
}

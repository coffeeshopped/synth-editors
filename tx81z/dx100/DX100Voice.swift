
extension DX100 {
  
  public enum Voice {

    public static let patchTruss = Op4.createVoicePatchTruss(synth, map: map, initFile: "dx100-init", validSizes: [])
        
    static let map: [(SynthPath, Op4.PatchWerk)] = [
      ([.voice], Op4.VCED.patchWerk),
    ]

    static let bankTruss = Op4.createVoiceBankTruss(patchTruss, patchCount: 24, initFile: "dx100-voice-bank-init", map: map)

  }
  
}

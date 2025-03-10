
extension DX21 {
  
  enum Voice {
    static let patchTruss = Op4.createVoicePatchTruss(synth, map: map, initFile: "dx21-voice-init", validSizes: [])
    static let bankTruss = Op4.createVoiceBankTruss(patchTruss, patchCount: 32, initFile: "dx21-voice-bank-init", map: map)
    
    static let map: [(SynthPath, Op4.PatchWerk)] = [
      ([.voice], Op4.VCED.patchWerk),
    ]
  }
  
}

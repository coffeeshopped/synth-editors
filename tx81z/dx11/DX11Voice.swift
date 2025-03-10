
extension DX11 {
  
  enum Voice {
    
    static let patchTruss = Op4.createVoicePatchTruss(synth, map: map, initFile: "dx11-voice-init", validSizes: [TX81Z.Voice.patchTruss.fileDataCount])
        
    static let map: [(SynthPath, Op4.PatchWerk)] = [
      ([.aftertouch], ACED2.patchWerk),
      ([.extra], Op4.ACED.patchWerk),
      ([.voice], Op4.VCED.patchWerk),
    ]
            
    static let patchCount = 32

    static let bankTruss = Op4.createVoiceBankTruss(patchTruss, patchCount: 32, initFile: "dx11-voice-bank-init", map: map)
    
    static let bankTransform = Op4.patchBankTransform(map: map)

  }
  
  enum ACED2 {
    
    static let patchWerk = Op4.PatchWerk(synth, "aced2", 10, params: parms.params(), initFile: "dx11-aced2-patch-init", cmdByte: 0x13, sysexData: {
      Yamaha.sysexData(channel: $1, cmdBytes: [0x7e, 0x00, 0x21], bodyBytes: "LM  8023AE".sysexBytes() + $0)
    }, parseOffset: 16, compact: (body: 128, namePack: nil, parms: compactParms))

    static let parms: [Parm] = .inc(b: 0) { [
      .p([.aftertouch, .pitch], .max(99)),
      .p([.aftertouch, .amp], .max(99)),
      .p([.aftertouch, .pitch, .bias], .max(100, dispOff:  -50)),
      .p([.aftertouch, .env, .bias], .max(99)),
    ] }

    static let compactParms: [Parm] = .inc(b: 84) { [
      .p([.aftertouch, .pitch]),
      .p([.aftertouch, .amp]),
      .p([.aftertouch, .pitch, .bias], packIso: pitchBiasPack),
      .p([.aftertouch, .env, .bias]),
    ] }

    static let pitchBiasPack: PackIso = {
      let iso = Iso<Int,Int>(forward: {
        $0 < 0 ? $0 + 51 : $0 - 50
      }, backward: {
        $0 > 50 ? $0 - 51 : $0 + 50
      })
      return iso >>> PackIso.byte(86)
    }()
  }
  
}

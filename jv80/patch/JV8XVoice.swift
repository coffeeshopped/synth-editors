
extension JV8X {
  
  enum Voice {
  
    static func patchWerk(tone: RolandSinglePatchTrussWerk) -> RolandMultiPatchTrussWerk {
      JV8X.sysexWerk.multiPatchWerk("Voice", [
        ([.common], 0x0000, JV80.Voice.Common.patchWerk),
      ] + 4.map {
        ([.tone, .i($0)], RolandAddress([0x08 + UInt8($0), 0x00]), tone)
      }, start: 0x00082000, initFile: "jv880-voice")
    }
    
    static func bankWerk(_ patchWerk: RolandMultiPatchTrussWerk) -> RolandMultiBankTrussWerk {
      sysexWerk.multiBankWerk(patchWerk, 64, start: 0x01402000, initFile: "jv880-voice-bank", iso: .init(address: {
        RolandAddress([$0, 0, 0])
      }, location: {
        // have to do this because the address passed here is an absolute address, not an offset
        // whereas above in "address:", we are creating an offset address
        $0.sysexBytes(count: 4)[1] - 0x40
      }))
    }

  }
  
}

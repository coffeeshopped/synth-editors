
extension JV8X {
  
  enum Rhythm {
    
    static func patchWerk(note: RolandSinglePatchTrussWerk) -> RolandMultiPatchTrussWerk {
      sysexWerk.multiPatchWerk("Rhythm", 61.map {
        ([.note, .i($0)], RolandAddress([UInt8($0), 0x00]), note)
      }, start: 0x00074000, initFile: "jv880-rhythm")
    }

    static func bankWerk(_ patchWerk: RolandMultiPatchTrussWerk) -> RolandMultiBankTrussWerk {
      sysexWerk.multiBankWerk(patchWerk, 1, start: 0x017f4000, initFile: "jv880-rhythm-bank")
    }

  }
}

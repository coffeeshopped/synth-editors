
extension JV8X {
  
  enum Perf {
  
    static func patchWerk(part: RolandSinglePatchTrussWerk) -> RolandMultiPatchTrussWerk {
      sysexWerk.multiPatchWerk("Perf", [
        ([.common], 0x0000, JV80.Perf.Common.patchWerk),
      ] + 8.map {
        ([.part, .i($0)], RolandAddress([0x08 + UInt8($0), 0x00]), part)
      }, start: 0x00001000, initFile: "jv880-perf")
    }
    
    static func bankWerk(_ patchWerk: RolandMultiPatchTrussWerk) -> RolandMultiBankTrussWerk {
      sysexWerk.multiBankWerk(patchWerk, 16, start: 0x01001000, initFile: "jv880-perf-bank")
    }

    
  }
  
}

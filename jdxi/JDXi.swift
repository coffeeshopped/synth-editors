
public enum JDXi {
  
  static let sysexWerk = RolandSysexTrussWerk(modelId: [0x00, 0x00, 0x00, 0x0e], addressCount: 4)

  static func multiPack(_ byte: RolandAddress) -> PackIso {
    Roland.msbMultiPackIso(4)(byte)
  }

  static func singlePatchWerk(_ displayId: String, _ params: SynthPathParam, size: RolandAddress, start: RolandAddress, name: NamePackIso? = nil, sysexDataFn: RolandSinglePatchTrussWerk.SysexDataFn? = nil) -> RolandSinglePatchTrussWerk {
    try! RolandSinglePatchTrussWerk(sysexWerk, displayId, params, size: size, start: start, name: name, sysexDataFn: sysexDataFn)
  }

  static func multiPatchWerk(_ displayId: String, _ map: [RolandMultiPatchTrussWerk.MapItem], start: RolandAddress, initFile: String = "", sysexDataFn: RolandMultiPatchTrussWerk.SysexDataFn? = nil, validBundle: MultiPatchTruss.ValidBundle? = nil) -> RolandMultiPatchTrussWerk {
    RolandMultiPatchTrussWerk(sysexWerk, displayId, map, start: start, initFile: initFile, sysexDataFn: sysexDataFn, validBundle: validBundle)
  }
  
  static func multiBankWerk(_ patchWerk: RolandMultiPatchTrussWerk, startOffset: UInt8, initFile: String? = nil, iso: RolandOffsetAddressIso? = nil, validBundle: MultiBankTruss.ValidBundle? = nil) -> RolandMultiBankTrussWerk {
    let patchCount = 128
    let start = RolandAddress([startOffset, 0x00, 0x00, 0x00])
    let iso = iso ?? .init(address: {
      RolandAddress(0x010000) * Int($0)
    }, location: {
      $0.sysexBytes(count: 4)[1]
    })
    return RolandMultiBankTrussWerk(patchWerk, patchCount, start: start, iso: iso, validBundle: validBundle)
  }

}

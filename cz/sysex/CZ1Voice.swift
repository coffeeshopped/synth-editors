
extension CZ1 {
  
  enum Voice {
    
    // I THINK that the patch location numbering starts from 0 with the CZ-1
    // Edit: I THINK actually maybe not.
    // Edit: Nope, it is.
//    override class func location(forData data: Data) -> Int { Int(data[6]) }
    
    // CZ-1 has 32 bytes more per patch (combined to be the 16 bytes for name)
    static let patchTruss = try! SinglePatchTruss("cz1.voice", 288, namePackIso: namePackIso, params: CZ101.Voice.parms.params(), initFile: "CZ-init", createFileData: {
      CZ101.Voice.sysexData($0, channel: 0, location: 0x60, cz1: true)
    }, parseBodyData: {
      let contentByteCount = 288
      switch $0.count {
      case 296:
        // cz-1 style
        return Array($0[7..<(7+contentByteCount)])
      case 264:
        // cz-101 style
        return Array($0[7..<263]) + [UInt8](repeating: 0, count: 32)
      case 295:
        // cz-1 style, fetch
        return Array($0[6..<(6+contentByteCount)])
      case 263:
        // cz-101 style, fetch
        return Array($0[6..<262]) + [UInt8](repeating: 0, count: 32)
      default:
        return [UInt8](repeating: 0, count: contentByteCount)
      }
    }, validBundle: CZ101.Voice.validBundle)
    
    
    //18944
    static let patchCount = 64
    static let bankTruss: SingleBankTruss = {
      let fileDataCount = 295 * patchCount
      let defaultParse = SingleBankTrussWerk.sortAndParseBodyDataWithLocationIndex(6, patchTruss: patchTruss, patchCount: patchCount)
      let validBundle = SingleBankTruss.Core.validBundle(counts: [fileDataCount, fileDataCount + patchCount])
      
      // I THINK that the patch location numbering starts from 0 with the CZ-1
      // Edit: I think not
      // Edit again: Now I think so again!
      return SingleBankTruss(patchTruss: patchTruss, patchCount: patchCount, createFileData: SingleBankTrussWerk.createFileDataWithLocationMap {
        CZ101.Voice.sysexData($0, channel: 0, location: $1, cz1: true)
      }, parseBodyData: {
        switch $0.count {
        case fileDataCount + patchCount:
          return try defaultParse($0)
        default:
          // from fetch. order of msgs determines locations
          let sysex = SysexData(data: Data($0))
          return try (0..<patchCount).map {
            guard $0 < sysex.count else { return [UInt8](repeating: 0, count: patchTruss.bodyDataCount) }
            return try patchTruss.parseBodyData(sysex[$0].bytes())
          }
        }

      }, validBundle: validBundle)
    }()

    static let namePackIso = NamePackIso(pack: { bytes, name in
      guard bytes.count >= 288 else {
        return debugPrint("not enough bytes in CZ1 voice patch!")
      }

      let sizedName = NamePackIso.filtered(name: name, count: 16)
      let byteArr = sizedName.bytes(forCount: 16)
      // transform into bytes
      for i in 0..<16 {
        CZ101.Voice.setByte(&bytes, i + 128, v: byteArr[i])
      }

    }, unpack: { bytes in
      guard bytes.count >= 288 else {
        debugPrint("nameByteRange falls outside of patch byte range")
        return ""
      }

      let nameBytes = 16.map { CZ101.Voice.byte(bytes, $0 + 128) }
      return NamePackIso.trimmed(name: NamePackIso.cleanBytesToString(nameBytes))
    }, byteRange: 128..<144) // byteRange is just used to calc maxNameCount AFAICT
    
  }

}

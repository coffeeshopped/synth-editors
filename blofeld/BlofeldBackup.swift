
extension Blofeld {

  static let backupTruss: BackupTruss = {
    let map: [(SynthPath, any SysexTruss)] = [
      ([.global], Global.patchTruss),
    ] + 8.map {
      ([.bank, .i($0)], Voice.bankTruss)
    } + [
      ([.perf, .bank], MultiMode.bankTruss),
    ]

    let createFileData: BackupTruss.Core.CreateFileDataFn = { bodyData in
      // map over the types to ensure ordering of data
      try map.compactMap { path, truss in
        switch truss.displayId {
        case Voice.bankTruss.displayId:
          // voice banks have multiple locations
          guard let bankData = bodyData[path]?.data() as? SingleBankTruss.BodyData else { return nil }
          let bank = UInt8(path.endex)
          return bankData.enumerated().flatMap { location, bodyData in
            sysexData(bodyData, deviceId: 0x7f, dumpByte: Voice.dumpByte, bank: bank, location: UInt8(location)).bytes()
          }

        default:
          guard let data = bodyData[path] else { return [] }
          return try truss.createFileData(anyBodyData: data)
        }
      }.reduce([], +)
    }
    
    return BackupTruss("Blofeld", map: map, pathForData: {
        guard $0.count > 6 else { return nil }
        switch $0[4] {
        case 0x14:
          return [.global]
        case 0x11:
          return [.perf, .bank]
        case 0x10:
          return [.bank, .i(Int($0[5]))]
        default:
          return nil
        }
    }, createFileData: createFileData)
  }()
  
}

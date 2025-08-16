
//struct JP8080Backup : RolandBackupTemplate, JP8080SysexTemplate {
//  
//  static let rolandMap: [RolandSysexMapItem] = [
//      ([.global], 0x00000000, JP8080GlobalPatch.self),
//      mapItem(bankType: JP8080PerfBank.self, prefix: .perf),
//      mapItem(bankType: JP8080VoiceBank.self, prefix: .patch),
//    ]
//  
//  static func mapItem(bankType: RolandBankTemplate.Type, prefix: SynthPathItem) -> RolandSysexMapItem {
//    let path = [.bank, prefix]
//    return (path, bankType.startAddress(path) - startAddress(nil), bankType)
//  }
//  
//  static func startAddress(_ path: SynthPath?) -> RolandAddress {
//    JP8080GlobalPatch.startAddress(path)
//  }
//  
//  static let initFileName: String = "jp8080-backup-init"
//  
//  static func isValid(fileSize: Int) -> Bool {
//    fileSize == 75755 || fileSize >= fileDataCount
//  }
//}
//

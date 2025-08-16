
//struct JP8080PerfBank : RolandMultiBankTemplate, PerfBank {
//  typealias Template = JP8080PerfPatch
//  static let patchCount: Int = 64
//  static let initFileName: String = "jp8080-perf-bank-init"
//  
//  static func startAddress(_ path: SynthPath?) -> RolandAddress { 0x03000000 }
//  static func offsetAddress(location: UInt8) -> RolandAddress { 0x010000 * Int(location) }
//
//  static func patchArray(fromData data: Data) -> [FnMultiPatch<Template>] {
//    patches(fromData: data) {
//      Int(Template.addressBytes(forSysex: $0)[1])
//    }
//  }
//  
//  static func isValid(fileSize: Int) -> Bool {
//    [fileDataCount, 686 * patchCount].contains(fileSize)
//  }
//}
//
//struct JP8080VoiceBank : RolandSingleBankTemplate, VoiceBank {
//  typealias Template = JP8080VoicePatch
//  static let patchCount: Int = 128
//  static var fileDataCount: Int = 272 * patchCount
//  static let initFileName: String = "jp8080-voice-bank-init"
//
//  static func startAddress(_ path: SynthPath?) -> RolandAddress { 0x02000000 }
//  static func offsetAddress(location: UInt8) -> RolandAddress { 0x0200 * Int(location) }
//
//  static func patchArray(fromData data: Data) -> [FnSinglePatch<Template>] {
//    patches(fromData: data) {
//      let addressBytes = Template.addressBytes(forSysex: $0)
//      guard addressBytes.first == 0x02 else { return nil }
//      return Int((addressBytes[2] >> 1) + (64 * addressBytes[1])) // TODO: might be wrong
//    }
//  }
//  
//  // 31684 will be the size of patches stored as single msgs
//  // my unit is sending extra control change sysex sometimes, so this.
//  static func isValid(fileSize: Int) -> Bool {
//    fileSize == 33280 || fileSize >= fileDataCount
//  }
//
//  static func bankIndexToPrefix(_ i: Int) -> String {
//    let letter = ["A", "B"][(i / 64) % 2]
//    let bank = ((i % 64) / 8) + 1
//    let patch = (i % 8) + 1
//    return "\(letter)\(bank)\(patch)"
//  }
//}

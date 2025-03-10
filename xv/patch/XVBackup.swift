
//public protocol XVBackup : RolandBackupTemplate, XVSysexTemplate {
//  associatedtype GlobalPatch: XVMultiPatchTemplate
//  associatedtype PerfBank: XVPerfBank
//  associatedtype VoiceBank: XVVoiceBank
//  associatedtype RhythmBank: XVRhythmBank
//}
//
//public extension XVBackup {
//  static var initFileName: String { return "" }
//
//  static func startAddress(_ path: SynthPath?) -> RolandAddress { GlobalPatch.startAddress(path) }
//  
//  // addresses must be specified as relative to the lowest address that will be found in the sysex.
//  static var rolandMap: [RolandSysexMapItem] {
//    let start = startAddress(nil)
//    return [
//      ([.global], 0x00000000, GlobalPatch.self),
//      ([.bank, .perf, .i(0)], 0x20000000 - start, PerfBank.self),
//      ([.bank, .patch, .i(0)], 0x30000000 - start, VoiceBank.self),
//      ([.bank, .rhythm, .i(0)], 0x40000000 - start, RhythmBank.self),
//    ]
//  }
//}
//
//public struct XV5050Backup : XVBackup {
//  public typealias GlobalPatch = XV5050GlobalPatch
//  public typealias PerfBank = XV5050PerfBank
//  public typealias VoiceBank = XV5050VoiceBank
//  public typealias RhythmBank = XV5050RhythmBank
//}
//
//public struct XV3080Backup : XVBackup {
//  public typealias GlobalPatch = XV3080GlobalPatch
//  public typealias PerfBank = XV3080PerfBank
//  public typealias VoiceBank = XV3080VoiceBank
//  public typealias RhythmBank = XV3080RhythmBank
//}
//
//public struct XV5080Backup : XVBackup {
//  public typealias GlobalPatch = XV5080GlobalPatch
//  public typealias PerfBank = XV5080PerfBank
//  public typealias VoiceBank = XV5080VoiceBank
//  public typealias RhythmBank = XV5080RhythmBank
//}
//
//public struct XV2020Backup : XVBackup {
//  public typealias GlobalPatch = XV2020GlobalPatch
//  public typealias PerfBank = XV2020PerfBank
//  public typealias VoiceBank = XV2020VoiceBank
//  public typealias RhythmBank = XV2020RhythmBank
//}

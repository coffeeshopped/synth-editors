
//protocol JP80X0Editor : RolandEditorTemplate {
//  
//}
//
//extension JP80X0Editor {
//
//  public static func deviceId(_ editor: TemplatedEditor) -> UInt8 {
//    UInt8(editor.patch(forPath: [.deviceId])?[[.deviceId]] ?? RolandDefaultDeviceId)
//  }
//
//  public static func requestHeader(_ editor: TemplatedEditor) -> [UInt8] {
//    [0xf0, 0x41, deviceId(editor), 0x00, 0x06, 0x11]
//  }
//  
//  public static func extraParamsOutput(_ editor: TemplatedEditor, forPath path: SynthPath) -> Observable<SynthPathParam>? {
//    guard path == [.perf] else { return nil }
//    return mapBankNameParams(editor, bankPath: [.bank, .patch], toParamPath: [.patch, .name]) {
//      "\(JP8080VoiceBank.bankIndexToPrefix($0)): \($1)"
//    }
//  }
//
//  public static func bankInfo(forPatchTemplate templateType: PatchTemplate.Type) -> [(SynthPath, String)] {
//    switch templateType {
//    case is PerfPatch.Type:
//      return [([.bank, .perf], "Perf Bank")]
//    case is VoicePatch.Type:
//      return [([.bank, .patch], "Patch Bank")]
//    default:
//      return []
//    }
//  }
//  
//  public static func bankIndexLabelBlock(forPath path: SynthPath) -> ((Int) -> String)? {
//    switch path {
//    case [.bank, .perf]:
//      return {
//        let bank = ($0 / 8) + 1
//        let patch = ($0 % 8) + 1
//        return "\(bank)\(patch)"
//      }
//    case [.bank, .patch]:
//      return { JP8080VoiceBank.bankIndexToPrefix($0) }
//    default:
//      return nil
//    }
//  }
//}
//
//public struct JP8080Editor : JP80X0Editor {
//  
//  public static let sysexMap: [SynthPath : SysexTemplate.Type] =  [
//    [.deviceId] : RolandDeviceIdSettings.self,
//    [.global] : JP8080GlobalPatch.self,
//    [.perf] : JP8080PerfPatch.self,
//    [.bank, .perf] : JP8080PerfBank.self,
//    [.bank, .patch] : JP8080VoiceBank.self,
//  ]
//
//  public static let migrationMap: [SynthPath:String]? = nil
//  
//  public static var compositeMap: [SynthPath : MultiSysexTemplate.Type] = [
//      [.backup] : JP8080Backup.self,
//    ]
//      
//  public static func midiChannel(_ editor: TemplatedEditor, forPath path: SynthPath) -> Int {
//    0
//  }
//  
//}
//

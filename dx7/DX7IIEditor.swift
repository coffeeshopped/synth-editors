
//public class DX7IIEditor : TX802Editor {
//  
//  required init(baseURL: URL) {
//    let map: [SynthPath:Sysexible.Type] = [
//      [.global] : ChannelSettingsPatch.self,
//      [.patch] : DX7IIVoicePatch.self,
//      [.perf] : TX802PerfPatch.self,
//      [.bank, .i(0)] : DX7IIVoiceBank.self,
//      [.bank, .i(1)] : DX7IIVoiceBank.self,
//      [.perf, .bank] : TX802PerfBank.self,
//    ]
//
//    let migrationMap: [SynthPath:String] = [
//      [.global] : "Global.json",
//      [.patch] : "Voice.syx",
//      [.perf] : "Performance.syx",
//      [.bank, .i(0)] : "Voice Bank 1.syx",
//      [.bank, .i(1)] : "Voice Bank 2.syx",
//      [.perf, .bank] : "Perf Bank.syx",
//    ]
//
//    super.init(baseURL: baseURL, sysexMap: map, migrationMap: migrationMap)
//  }
//}

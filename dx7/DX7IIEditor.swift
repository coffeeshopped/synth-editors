
public class DX7IIEditor : TX802Editor {
 
 required init(baseURL: URL) {
   let map: [SynthPath:Sysexible.Type] = [
     [.global] : ChannelSettingsPatch.self,
     [.patch] : DX7IIVoicePatch.self,
     [.perf] : TX802PerfPatch.self,
     [.bank, .i(0)] : DX7IIVoiceBank.self,
     [.bank, .i(1)] : DX7IIVoiceBank.self,
     [.perf, .bank] : TX802PerfBank.self,
   ]

}

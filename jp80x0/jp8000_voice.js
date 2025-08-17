
const patchWerk = {
  multi: 'voice',
  size: 0x016f,
  initFile: "jp8000-voice-init",
  // no noise wave on osc 2
  // chorus types: no distortion
  // end after velo offsets
  parms: JP8080Voice.parms(false),
  // single patch files seem to be 251 but in Perfs they're 252
  validSizes: ['auto', 252],
}

struct JP8000VoiceBank : RolandSingleBankTemplate, VoiceBank {
 typealias Template = JP8000VoicePatch
 static let patchCount: Int = 128
 static var fileDataCount: Int = 272 * patchCount
 static let initFileName: String = "jp8000-voice-bank-init"

 static func startAddress(_ path: SynthPath?) -> RolandAddress { 0x02000000 }
 static func offsetAddress(location: UInt8) -> RolandAddress { 0x0200 * Int(location) }

 static func patchArray(fromData data: Data) -> [FnSinglePatch<Template>] {
   patches(fromData: data) {
     let addressBytes = Template.addressBytes(forSysex: $0)
     guard addressBytes.first == 0x02 else { return nil }
     return Int((addressBytes[2] >> 1) + (64 * addressBytes[1])) // TODO: might be wrong
   }
 }
 
 // 31684 will be the size of patches stored as single msgs
 // my unit is sending extra control change sysex sometimes, so this.
 static func isValid(fileSize: Int) -> Bool {
   fileSize == 33280 || fileSize >= fileDataCount
 }
}

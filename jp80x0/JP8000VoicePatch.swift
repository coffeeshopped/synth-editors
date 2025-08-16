
//struct JP8000VoicePatch : JP80X0VoicePatch, BankedPatchTemplate, VoicePatch {
//  typealias Bank = JP8000VoiceBank
//  
//  static let size: RolandAddress = 0x016f
//  static let initFileName: String = "jp8000-voice-init"
//      
//  // no noise wave on osc 2
//  // chorus types: no distortion
//  // end after velo offsets
//  static let params: SynthPathParam = paramsFromOpts(JP8080VoicePatch.paramOptions(isJP8080: false))
//  
//  // single patch files seem to be 251 but in Perfs they're 252
//  static func isValid(fileSize: Int) -> Bool {
//    [fileDataCount, 252].contains(fileSize)
//  }
//
//}

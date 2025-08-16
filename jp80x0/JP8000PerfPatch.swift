
//struct JP8000PerfPatch : JP80X0PerfPatch {
//  typealias Bank = JP8000PerfBank
//  
//  static let initFileName: String = "jp8000-perf-init"
//
//  static var rolandMap: [RolandMapItem] = [
//    ([.common], 0x0000, CommonPatch.self),
//    ([.part, .i(0)], 0x1000, PartPatch.self),
//    ([.part, .i(1)], 0x1100, PartPatch.self),
//    ([.patch, .i(0)], 0x4000, JP8000VoicePatch.self),
//    ([.patch, .i(1)], 0x4200, JP8000VoicePatch.self),
//  ]
//  
//  static func isValid(fileSize: Int) -> Bool {
//    [fileDataCount, 686].contains(fileSize)
//  }
//
//  
//  struct CommonPatch : JP8080SinglePatchTemplate {
//    static let initFileName: String = "jp8000-perf-common-init"
//    static let size: RolandAddress = 0x24
//    static func startAddress(_ path: SynthPath?) -> RolandAddress { 0x0000 }
//    static var nameByteRange: CountableRange<Int>? = 0..<0x10
//
//    // no randomize
//    static func randomize(patch: ByteBackedSysexPatch) { return }
//
//    // voice assign: diff opts
//    // add pedal assign
//    // no input param
//    static let params: SynthPathParam = paramsFromOpts(JP8080PerfPatch.CommonPatch.paramOptions(isJP8080: false))
//
//  }
//    
//  struct PartPatch : JP8080SinglePatchTemplate {
//    static let initFileName: String = "jp8000-perf-part-init"
//    static let size: RolandAddress = 0x07
//    static func startAddress(_ path: SynthPath?) -> RolandAddress {
//      0x1000 + (path?.endex ?? 0) * 0x100
//    }
//
//    // no randomize
//    static func randomize(patch: ByteBackedSysexPatch) { return }
//
//    // no card
//    // diff size
//    // no group
//    static let params: SynthPathParam = paramsFromOpts(JP8080PerfPatch.PartPatch.paramOptions(isJP8080: false))
//  }
//}

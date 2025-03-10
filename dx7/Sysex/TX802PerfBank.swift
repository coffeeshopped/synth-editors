
//class TX802PerfBank : TypicalTypedSysexPatchBank<TX802PerfPatch>, ChannelizedSysexible {
//  
//  override public class var patchCount: Int { return 64 }
//  override public class var initFileName: String { return "tx802-perf-bank-init" }
//  override public class var fileDataCount: Int { return 11589 }
//  
//  public func sysexData(channel: Int) -> Data {
//    var data = Data([0xf0, 0x43, UInt8(channel), 0x7e])
//    data.append(contentsOf: patches.map { $0.bankSysexData() }.joined())
//    data.append(0xf7)
//    return data
//  }
//  
//  override public func fileData() -> Data {
//    return sysexData(channel: 0)
//  }
//  
//  required public init(data: Data) {
//    // 84 + 3 + 10 = PMEM data + 2 header bytes + 10 ascii bytes + checksum
//    let p = type(of: self).compactPatches(fromData: data, offset: 4, patchByteCount: 181)
//    super.init(patches: p)
//  }
//
//  // why do we need this? Without it, TX802VoiceBank says this init doesn't exist.
//  public required init(patches p: [Patch]) {
//    super.init(patches: p)
//  }
//  
//}

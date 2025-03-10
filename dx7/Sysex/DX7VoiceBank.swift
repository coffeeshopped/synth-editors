
//public class DX7VoiceBank : TypicalTypedSysexPatchBank<DX7Patch>, ChannelizedSysexible, VoiceBank {
//  
//  override public class var patchCount: Int { 32 }
//  override public class var initFileName: String { "dx7-voice-bank-init" }
//  override public class var fileDataCount: Int { 4104 }
//  
//  public func sysexData(channel: Int) -> Data {
//    var data = Data([0xf0, 0x43, UInt8(channel), 0x09, 0x20, 0x00])
//    let patchData = [UInt8](patches.map{ $0.bankSysexData() }.reduce(Data(), +))
//    data.append(contentsOf: patchData)
//    data.append(DX7Patch.checksum(bytes: patchData))
//    data.append(0xf7)
//    return data
//  }
//  
//  override public func fileData() -> Data {
//    return sysexData(channel: 0)
//  }
//  
//  required public init(data: Data) {
//    let p = type(of: self).compactPatches(fromData: data, offset: 6, patchByteCount: 128)
//    super.init(patches: p)
//  }
//
//  // why do we need this? Without it, TX802VoiceBank says this init doesn't exist.
//  public required init(patches p: [Patch]) {
//    super.init(patches: p)
//  }
//  
//}


//public class DX7IIVoiceBank : TX802ishVoiceBank, DX7IIishVoiceBank {
//  
//  public required init(patches p: [DX7IIVoicePatch]) {
//    patches = p
//  }
//  
//  public func copy() -> Self {
//    Self.init(patches: patches.map { $0.copy() })
//  }
//  
//  public typealias ACEDBank = DX7IIACEDBank
//  
//  public var patches: [DX7IIVoicePatch]
//  public var name = ""
//  
//  required public init(data: Data) {
//    patches = Self.patchArray(fromData: data)
//  }
//}
//  
//public class DX7IIACEDBank : TX802ACEDishBank {
//  
//  public var patches: [DX7IIACEDPatch]
//  public var name = ""
//  
//  required public init(data: Data) {
//    patches = Self.patchArray(fromData: data)
//  }
//  
//  required public init(patches p: [DX7IIACEDPatch]) {
//    patches = p.map { $0.copy() }
//  }
//    
//  public func copy() -> Self {
//    Self.init(patches: patches.map { $0.copy() })
//  }
//
//}
//

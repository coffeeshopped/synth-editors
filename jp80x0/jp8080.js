
public protocol JP8080SysexTemplate : Roland2ByteIdSysexTemplate { }
public extension JP8080SysexTemplate {
 static var modelId: [UInt8] { [0x00, 0x06] }
}

public protocol JP8080SinglePatchTemplate : JP8080SysexTemplate, RolandSinglePatchTemplate { }
public extension JP8080SinglePatchTemplate {
 // 7 bits used in multi-byte params! The default in RolandSinglePatchTemplate is 4 bits (which is what newer synths use
 
 /// Compose Int value from bytes (MSB first)
 static func multiByteParamInt(from: [UInt8]) -> Int {
   guard from.count > 1 else { return Int(from[0]) }
   return (1...from.count).reduce(0) {
     let shift = (from.count - $1) * 7
     return $0 + (Int(from[$1 - 1]) << shift)
   }
 }

 /// Decompose Int to bytes (7! bits at a time)
 static func multiByteParamBytes(from: Int, count: Int) -> [UInt8] {
   guard count > 0 else { return [UInt8(from)] }
   return (1...count).map {
     let shift = (count - $0) * 7
     return UInt8((from >> shift) & 0x7f)
   }
 }
}

public protocol JP8080MultiPatchTemplate : JP8080SysexTemplate, RolandMultiPatchTemplate { }
public protocol JP8080MultiSysexTemplate : JP8080SysexTemplate, RolandMultiSysexTemplate { }

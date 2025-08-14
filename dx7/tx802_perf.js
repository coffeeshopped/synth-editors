const channelOptions = ([0, 16].map {
  $0 < 16 ? `${$0+1}` : "Omni"
})
 
const bankOptions = ["Int","Cart","A","B"]
 
const numberOptions = ([1, 64]).map { `${$0}` }
 
const outOptions = ["Off","I","II","I+II"]

const parms = [
  { prefix: 'part', count: 8, bx: 1, block: [
    ["channel/offset", { b: 0, max: 7 }],
    ["channel", { b: 8, opts: channelOptions }],
    ["voice/bank", { b: 16, bits: [6, 7], opts: bankOptions }],
    ["voice/number", { b: 16, bits: [0, 5], opts: numberOptions }],
    ["detune", { b: 24, max: 14, dispOff: -7 }],
    ["volume", { b: 32, max: 99 }],
    ["out/assign", { b: 40, opts: outOptions }],
    ["note/lo", { b: 48 }],
    ["note/hi", { b: 56 }],
    ["note/shift", { b: 64, max: 48, dispOff: -24 }],
    ["env/redamper", { b: 72, max: 1 }],
    ["key/assign/group", { b: 80, max: 1 }], // alt assign
    ["micro/tune", { b: 88, max: 254 }],
  ] },
]

const compactParms = [
  { prefix: 'part', count: 8, bx: 1, block: [
    ["channel/offset", { b: 0, bits: [5, 7] }],
    ["channel", { b: 0, bits: [0, 4] }],
    ["voice/bank", { b: 8, bits: [6, 7] }],
    ["voice/number", { b: 8, bits: [0, 5] }],
    ["detune", { b: 32, bits: [3, 6] }],
    ["volume", { b: 24, bits: [0, 6] }],
    ["out/assign", { b: 32, bits: [0, 1] }],
    ["key/assign/group", { b: 32, bit: 2 }], // alt assign
    ["note/lo", { b: 40, bits: [0, 6] }],
    ["note/hi", { b: 48, bits: [0, 6] }],
    ["note/shift", { b: 56, bits: [0, 5] }],
    ["env/redamper", { b: 56, bit: 6 }],
    ["micro/tune", { b: 16 }],
  ] },
]

const patchTruss = {
  single: 'perf',
  parms: parms,
  namePack: [96, 115],
  initFile: "tx802-perf-init",
}

class TX802PerfPatch : YamahaSinglePatch, BankablePatch, CompactBankablePatch, PerfPatch {
 
 const fileDataCount = 250
 
 required init(data: Data) {
   // 116 bytes, split into nibbles
   bytes = type(of: self).bytes(fromAsciiHex: [UInt8](data[16..<248]))
 }
 
 required init(bankData: Data) {
   // create empty bytes to pack into
   bytes = [UInt8](repeating: 0, count: 116)

   // un-ascii-ize the data
   // skip 12 bytes (0x01, 0x28, LM  8952PM), and grab 168 bytes (84 x 2)
   let b = type(of: self).bytes(fromAsciiHex: [UInt8](bankData[12..<180]))

   // unpack the name
   name = type(of: self).name(forRange: type(of: self).bankNameByteRange, bytes: b)

   type(of: self).bankParams.forEach {
     self[$0.key] = type(of: self).defaultUnpack(param: $0.value, forBytes: b)
   }
 }
 
 private const hexString = "0123456789ABCDEF"
 
 private static func bytes(fromAsciiHex b: [UInt8]) -> [UInt8] {
   return (0..<(b.count/2)).map {
     let i = 2 * $0
     var hiVal = 0
     var loVal = 0
     if let index = hexString.firstIndex(of: Character(UnicodeScalar(b[i]))) {
       hiVal = hexString.distance(from: hexString.startIndex, to: index)
     }
     if let index = hexString.firstIndex(of: Character(UnicodeScalar(b[i+1]))) {
       loVal = hexString.distance(from: hexString.startIndex, to: index)
     }
     return UInt8((hiVal << 4) + loVal)
   }
 }
 
 private static func asciiHex(fromBytes b: [UInt8]) -> [UInt8] {
   // crazy ascii hex formatting
   return [UInt8](b.map { String(format:"%02X", $0).bytes(forCount: 2) }.joined())
 }
 
 /// Transform internal bytes to ASCII hexadecimal
 private func asciiHexBytes() -> [UInt8] {
   return type(of: self).asciiHex(fromBytes: bytes)
 }

 /// 0x01, 0x28, LM 8952PM, PMEM data, checksum
 func bankSysexData() -> Data {
   var b = [UInt8](repeating: 0, count: 84)

   // pack the name
   let nameByteRange = type(of: self).bankNameByteRange
   let n = nameSetFilter(name) as NSString
   let nameBytes = (0..<nameByteRange.count).map { $0 < n.length ? UInt8(n.character(at: $0)) : 32 }
   b.replaceSubrange(nameByteRange, with: nameBytes)

   // pack the params
   type(of: self).bankParams.forEach {
     let param = $0.value
     b[param.byte] = type(of: self).defaultPackedByte(value: self[$0.key] ?? 0, forParam: param, byte: b[param.byte])
   }

   let outbytes = "LM  8952PM".unicodeScalars.map { UInt8($0.value) } + type(of: self).asciiHex(fromBytes: b)
   var data = Data([0x01, 0x28])
   data.append(contentsOf: outbytes)
   data.append(type(of: self).checksum(bytes: outbytes))
   return data
 }
 
 // channel should be 0-15
 func sysexData(channel: Int) -> Data {
   // this is part of the data! part of the checksum
   let outbytes = "LM  8952PE".unicodeScalars.map { UInt8($0.value) } + asciiHexBytes()
   var data = Data([0xf0, 0x043, UInt8(channel), 0x7e, 0x01, 0x68])
   data.append(contentsOf: outbytes)
   data.append(type(of: self).checksum(bytes: outbytes))
   data.append(0xf7)
   return data
 }
   
 private const bankNameByteRange = 64..<84
 
}

const bankTruss = {
  compactSingleBank: patchTruss,
  patchCount: 64,
  initFile: "tx802-perf-bank-init",
}

class TX802PerfBank : TypicalTypedSysexPatchBank<TX802PerfPatch>, ChannelizedSysexible {
 
 override public class var fileDataCount: Int { return 11589 }
 
 public func sysexData(channel: Int) -> Data {
   var data = Data([0xf0, 0x43, UInt8(channel), 0x7e])
   data.append(contentsOf: patches.map { $0.bankSysexData() }.joined())
   data.append(0xf7)
   return data
 }
  
 required public init(data: Data) {
   // 84 + 3 + 10 = PMEM data + 2 header bytes + 10 ascii bytes + checksum
   let p = type(of: self).compactPatches(fromData: data, offset: 4, patchByteCount: 181)
   super.init(patches: p)
 }
 
}

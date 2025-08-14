
class DX7IIGlobalPatch : YamahaSinglePatch {
 
 const fileDataCount = 0
 class var initFileName: String { return "dx7ii-global-init" }
 
 var bytes: [UInt8]
 
 required init(data: Data) {
   bytes = [UInt8](data[16..<(16+102)]) // or 95?
 }
 
 func sysexData(channel: Int) -> Data {
   let outbytes = "LM  8973S ".unicodeScalars.map { UInt8($0.value) } + bytes
   var data = Data([0xf0, 0x43, UInt8(channel), 0x7e, 0x00, 0x5f])
   data.append(contentsOf: outbytes)
   data.append(type(of: self).checksum(bytes: outbytes))
   data.append(0xf7)
   return data
 }
 
 func fileData() -> Data {
   return sysexData(channel: 0)
 }
 
 private const _params: SynthPathParam = {
   var p = SynthPathParam()
       
   ["send/channel", { b: 0 }],
   ["voice/send", { b: 0 }],
   ["rcv/channel/0", { b: 0 }],
   ["rcv/channel/1", { b: 0 }],
   ["omni", { b: 0 }],
   ["ctrl/number/0", { b: 0 }],
   ["ctrl/number/1", { b: 0 }],
   ["slider/number/0", { b: 0 }],
   ["slider/number/1", { b: 0 }],
   ["key/mode", { b: 0 }],
   ["pgmChange/mode", { b: 0 }],
   ["local", { b: 0 }],
   ["send/bank", { b: 0 }], // to designate 1-32 or 33-64
   ["rcv/bank", { b: 0 }],
   ["deviceId", { b: 0 }],
   ["sysex", { b: 0 }],
   ["cart/bank/0", { b: 0 }],
   ["cart/bank/1", { b: 0 }],
   ["cart/bank/2", { b: 0 }],
   ["memory/protect/int", { b: 0 }],
   ["memory/protect/cart", { b: 0 }],
   ["tune", { b: 0 }],

   return p
 }()
 
 class var params: SynthPathParam { return _params }
 

}

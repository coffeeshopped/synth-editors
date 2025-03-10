
//class DX7IIGlobalPatch : YamahaSinglePatch {
//  
//  static let fileDataCount = 0
//  class var initFileName: String { return "dx7ii-global-init" }
//  
//  var bytes: [UInt8]
//  
//  required init(data: Data) {
//    bytes = [UInt8](data[16..<(16+102)]) // or 95?
//  }
//  
//  func sysexData(channel: Int) -> Data {
//    let outbytes = "LM  8973S ".unicodeScalars.map { UInt8($0.value) } + bytes
//    var data = Data([0xf0, 0x43, UInt8(channel), 0x7e, 0x00, 0x5f])
//    data.append(contentsOf: outbytes)
//    data.append(type(of: self).checksum(bytes: outbytes))
//    data.append(0xf7)
//    return data
//  }
//  
//  func fileData() -> Data {
//    return sysexData(channel: 0)
//  }
//  
//  private static let _params: SynthPathParam = {
//    var p = SynthPathParam()
//        
//    p[[.send, .channel]] = RangeParam(byte: 0)
//    p[[.voice, .send]] = RangeParam(byte: 0)
//    p[[.rcv, .channel, .i(0)]] = RangeParam(byte: 0)
//    p[[.rcv, .channel, .i(1)]] = RangeParam(byte: 0)
//    p[[.omni]] = RangeParam(byte: 0)
//    p[[.ctrl, .number, .i(0)]] = RangeParam(byte: 0)
//    p[[.ctrl, .number, .i(1)]] = RangeParam(byte: 0)
//    p[[.slider, .number, .i(0)]] = RangeParam(byte: 0)
//    p[[.slider, .number, .i(1)]] = RangeParam(byte: 0)
//    p[[.key, .mode]] = RangeParam(byte: 0)
//    p[[.pgmChange, .mode]] = RangeParam(byte: 0)
//    p[[.local]] = RangeParam(byte: 0)
//    p[[.send, .bank]] = RangeParam(byte: 0) // to designate 1-32 or 33-64
//    p[[.rcv, .bank]] = RangeParam(byte: 0)
//    p[[.deviceId]] = RangeParam(byte: 0)
//    p[[.sysex]] = RangeParam(byte: 0)
//    p[[.cart, .bank, .i(0)]] = RangeParam(byte: 0)
//    p[[.cart, .bank, .i(1)]] = RangeParam(byte: 0)
//    p[[.cart, .bank, .i(2)]] = RangeParam(byte: 0)
//    p[[.memory, .protect, .int]] = RangeParam(byte: 0)
//    p[[.memory, .protect, .cart]] = RangeParam(byte: 0)
//    p[[.tune]] = RangeParam(byte: 0)
//
//    return p
//  }()
//  
//  class var params: SynthPathParam { return _params }
//  
//
//}

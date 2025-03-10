
class DX200SystemPatch : DX200SynthPatch, GlobalPatch {
  
  var name = ""
  
  static func tempAddress(forSynthPath synthPath: SynthPath) -> RolandAddress {
    return 0x000000
  }
  
  static func bankAddress(forSynthPath synthPath: SynthPath, index: Int) -> RolandAddress {
    return 0x000000
  }
  
  //  class var bankType: SysexPatchBank.Type { return DX7VoiceBank.self }
  static let dataByteCount: Int = 0x0a
  class var initFileName: String { return "DX-init" }
  
  var bytes: [UInt8]
  
  required init(data: Data) {
    bytes = type(of: self).bytes(forData: data)
  }
  
  func sysexData(deviceId: Int) -> Data {
    return sysexData(deviceId: deviceId, address: type(of: self).tempAddress(forSynthPath: []))
  }
  
  func fileData() -> Data {
    return sysexData(deviceId: 0)
  }

  static let params: SynthPathParam = [
    [.voice, .channel] : OptionsParam(byte: 0x00, options: channelOptions),
    [.rhythm, .i(0), .channel] : OptionsParam(byte: 0x01, options: channelOptions),
    [.rhythm, .i(1), .channel] : OptionsParam(byte: 0x02, options: channelOptions),
    [.rhythm, .i(2), .channel] : OptionsParam(byte: 0x03, options: channelOptions),
//    [.velo, .curve] : OptionsParam(byte: 0x05, options: veloCurveOptions),
    [.fx, .gate] : RangeParam(parm: 2, byte: 0x07, range: 1...200),
    [.loop, .type] : OptionsParam(byte: 0x09, options: loopOptions),
  ]
  
  static let channelOptions = OptionsParam.makeOptions((0...16).map {
    return $0 == 16 ? "Off" : "\($0+1)"
  })

  static let loopOptions = OptionsParam.makeOptions(["Forward", "Backward"])
  // Docs list these 2 also, but they don't seem to work
  //, "Alternate A", "Alternate B"])

  static let veloCurveOptions = OptionsParam.makeOptions(["DX", "Normal", "Soft 1", "Soft 2", "Easy", "Wide", "Hard"])
}

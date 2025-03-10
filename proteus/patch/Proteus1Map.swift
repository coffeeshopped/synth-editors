
extension Proteus1 {
  
  enum Map {
    
    static let patchTruss = try! SinglePatchTruss("proteus1.map", 256, params: parms.params(), initFile: "proteus1-map-init", createFileData: {
      sysexData($0, deviceId: 0)
    }, parseOffset: 5, pack: { bodyData, param, value in
      Proteus.pack(&bodyData, parm: param.p! - 512, value: value)
    }, unpack: { bodyData, param in
      Proteus.unpack(bodyData, parm: param.p! - 512)
    })
    
    static let patchTransform: MidiTransform = .single(throttle: 100, Proteus.deviceId, .patch( param: { editorVal, bodyData, parm, value in
      return [(.sysex(Proteus.paramData(parm: parm.p!, value: value)), 10)]
    }, patch: { editorVal, bodyData in
      [(.sysex(sysexData(bodyData, deviceId: UInt8(editorVal))), 10)]
    }, name: nil))

    static func sysexData(_ bytes: [UInt8], deviceId: UInt8) -> [UInt8] {
      Proteus.sysex(deviceId: deviceId, [0x07] + bytes)
    }

    static let params = parms.params()
    
    static let parms: [Parm] = .prefix([], count: 128, bx: 1) { _ in
      [.p([], p: 512, .max(191))]
    }
  }
  
}

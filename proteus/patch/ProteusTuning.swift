
extension Proteus {
  
  enum Tuning {

//    static let fileDataCount = 262 // 256 data bytes

    static let patchTruss = try! SinglePatchTruss("proteus.tuning", 256, params: parms.params(), initFile: "proteus1-tuning-init", createFileData: {
      sysexData($0, deviceId: 0)
    }, parseOffset: 5, pack: { bodyData, param, value in
      Proteus.pack(&bodyData, parm: param.p!, value: value)
    }, unpack: { bodyData, param in
      Proteus.unpack(bodyData, parm: param.p!)
    })
    
    static let patchTransform: MidiTransform = .single(throttle: 300, deviceId, .wholePatch({ editorVal, bodyData in
      [(.sysex(sysexData(bodyData, deviceId: UInt8(editorVal))), 100)]
    }))
    
    static func sysexData(_ bytes: [UInt8], deviceId: UInt8) -> [UInt8] {
      [0xf0, 0x18, 0x04, deviceId, 0x05] + bytes + [0xf7]
    }
    
    static let parms: [Parm] = 128.map {
      .p([.octave, .i($0 / 12), .note, .i($0 % 12)], p: $0, .max(8192))
    }


  }
}

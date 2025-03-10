
extension Proteus {
  
  enum Global {
    
    static let patchTruss = try! SinglePatchTruss("proteus.global", 352, params: parms.params(), initFile: "proteus1-global-init", createFileData: {
      sysexData($0, deviceId: 0).flatMap { $0 }
    }, parseBodyData: {
      var bytes = [UInt8](repeating: 0, count: 352)
      SysexData(data: $0.data()).forEach { msg in
        guard msg.count > 8 else { return }
        let off = Int(msg[5]) + (Int(msg[6]) << 7) - 256
        guard off >= 0 && off * 2 + 1 < bytes.count else { return }
        bytes[off * 2] = msg[7]
        bytes[off * 2 + 1] = msg[8]
      }
      return bytes
    }, validSizes: [1760], includeFileDataCount: true, pack: { bodyData, param, value in
      let off = (param.p! - 256) * 2
      guard off + 1 < bodyData.count else { return }
      bodyData[off] = UInt8(value.bits(0...6))
      bodyData[off + 1] = UInt8(value.bits(7...13))
    }, unpack: { bodyData, param in
      let off = (param.p! - 256) * 2 // OFFSET by -256
      guard off + 1 < bodyData.count else { return nil }
      let v = 0.set(bits: 0...6, value: bodyData[off].bits(0...6)).set(bits: 7...13, value: bodyData[off + 1].bits(0...6))
      return v.signedBits(0...13)
    })
    
    static let patchTransform: MidiTransform = .single(throttle: 100, deviceId, .patch(param: { editorVal, bodyData, parm, value in
      return [(.sysex(Proteus.paramData(parm: parm.p!, value: value)), 10)]

    }, patch: { editorVal, bodyData in
      sysexData(bodyData, deviceId: UInt8(editorVal)).map { (.sysex($0), 10) }
    }, name: nil))
    
    static func sysexData(_ bytes: [UInt8], deviceId: UInt8) -> [[UInt8]] {
      return (256...431).map {
        let off = ($0 - 256) * 2
        return Proteus.paramSetData(deviceId: deviceId, parm: $0, byte0: bytes[off], byte1: bytes[off + 1])
      }
    }
    
    static let params = parms.params()
    
    static let parms: [Parm] = {
      var p: [Parm] = [
        .p([.channel], p: 256, .rng(dispOff: 1)),
        .p([.volume], p: 257),
        .p([.pan], p: 258),
        .p([.preset], p: 259),
        .p([.tune], p: 260, .rng(-64...64)),
        .p([.transpose], p: 261, .rng(-12...12)),
        .p([.bend], p: 262, .rng(0...12)),
        .p([.velo, .curve], p: 263, .opts(5.map { $0 == 0 ? "Off" : "\($0)" })),
        .p([.midi, .mode], p: 264, .opts(["Omni", "Poly", "Multi", "Mono"])),
        .p([.midi, .extra], p: 265, .max(1)), // midi overflow
      ] 
      p += .prefix([.ctrl], count: 4, bx: 1, block: { _ in
        [.p([], p: 266, .max(31))]
      }) 
      p += .prefix([.foot], count: 3, bx: 1, block: { _ in
        [.p([], p: 270, .rng(64...79))]
      }) 
      p += [
        .p([.mode, .change, .on], p: 273, .max(1)),
        .p([.deviceId], p: 274, .max(15)),
      ] 
      p += .prefix([], count: 16, bx: 1, block: { _ in [
        .p([.midi, .on], p: 384, .max(1)),
        .p([.pgmChange, .on], p: 400, .max(1)),
        .p([.mix], p: 416, .opts(["Main", "Sub 1", "Sub 2", "Patch"])),
      ] })
      return p
    }()

  }
  
}


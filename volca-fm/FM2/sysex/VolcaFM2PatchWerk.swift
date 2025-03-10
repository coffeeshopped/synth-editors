
extension VolcaFM2 {

  struct PatchWerk {
    
    let storeHeaderByte: UInt8
    let tempHeaderByte: UInt8
    let bodyDataCount: Int
    let patchFileDataCount: Int
        
    func createFileData(_ bodyData: SinglePatchTruss.BodyData) throws -> [UInt8] {
      sysexData(bodyData, channel: 0).bytes()
    }

    func sysexData(_ bytes: [UInt8], channel: UInt8, headerBytes: [UInt8]) -> MidiMessage {
      let data = sysexHeader(channel) + headerBytes + bytes.pack78(count: patchFileDataCount - 8) + [0xf7]
      return .sysex(data)
    }

    func sysexData(_ bytes: [UInt8], channel: UInt8, location: UInt8) -> MidiMessage {
      sysexData(bytes, channel: channel, headerBytes: [storeHeaderByte, location])
    }

    func sysexData(_ bytes: [UInt8], channel: UInt8) -> MidiMessage {
      sysexData(bytes, channel: channel, headerBytes: [tempHeaderByte])
    }
    
    func parseNative(bodyData: [UInt8]) -> [UInt8] {
      let start = bodyData.count - (patchFileDataCount - 7)
      guard start >= 0 else { return [] }
      return bodyData.unpack87(count: bodyDataCount, inRange: start..<(start + (patchFileDataCount - 8)))
    }
    
    func isValidNative(fileSize: Int) -> Bool {
      // fileDataCount 168
      [patchFileDataCount, patchFileDataCount + 1].contains(fileSize)
    }

    
    func bankTransform() -> MidiTransform {
      return .single(.basicChannel, .bank({ editorVal, bodyData, location in
        [(sysexData(bodyData, channel: UInt8(editorVal), location: UInt8(location)), 200)]
      }))
    }
  }

}

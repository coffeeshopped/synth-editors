
extension FB01 {
  
  enum Perf {
    
    static let patchTruss = try! SinglePatchTruss("perf", 160, namePackIso: .basic(0..<8), params: parms.params(), initFile: "fb01-perf-init", createFileData: { sysexData($0, channel: 0) }, parseOffset: 9)
        
    static func sysexData(_ bodyData: [UInt8], channel: Int) -> [UInt8] {
      sysexData(bodyData, channel: channel, temp: true, location: 0)
    }
    
    static func sysexData(_ bodyData: [UInt8], channel: Int, location: Int) -> [UInt8] {
      sysexData(bodyData, channel: channel, temp: false, location: location)
    }
    
    private static func sysexData(_ bodyData: [UInt8], channel: Int, temp: Bool, location: Int) -> [UInt8] {
      let cmdBytesWithChannel = [0x75, UInt8(channel), 0,
                                 temp ? 1 : 2,
                                 temp ? 0 : UInt8(location),
                                 0x01, 0x20]
      return Yamaha.sysexData(cmdBytesWithChannel: cmdBytesWithChannel, bodyBytes: bodyData)

    }

    static func paramTransform() -> MidiTransform.Fn<SinglePatchTruss,Int>.Param {
      { (editorVal, bodyData, parm, value) in
        let data: [UInt8]
        if parm.path[0] == .part {
          guard let part = parm.path.i(1) else { return nil }
          data = paramData(channel: editorVal, instrument: part, paramAddress: parm.b! % 0x10, value: bodyData[parm.b!])
        }
        else if parm.p! > 0 {
          data = paramData(channel: editorVal, instrument: 0, paramAddress: parm.p!, value: bodyData[parm.b!])
        }
        else {
          data = sysexData(bodyData, channel: editorVal)
        }
        return [(.sysex(data), 100)]
      }
    }
    
    static func patchTransform() -> MidiTransform.Fn<SinglePatchTruss,Int>.Whole {
      { (editorVal, bodyData) in
        [(.sysex(sysexData(bodyData, channel: editorVal)), 100)]
      }
    }

    static func nameTransform() -> MidiTransform.Fn<SinglePatchTruss,Int>.Name {
      { (editorVal, bodyData, path, name) in
        [(.sysex(sysexData(bodyData, channel: editorVal)), 100)]
        // seems like sending by individual parameter changes puts the synth in an unknown state.
//        return patchTruss.namePackIso?.byteRange.map {
//          let msg = paramData(channel: editorVal, instrument: 0, paramAddress: $0, value: bodyData[$0])
//          return (.sysex(msg), 0.1)
//        }
      }
    }
    
    static func patchChangeTransform() -> MidiTransform {
      .single(throttle: 30, sysexChannel, .patch(param: paramTransform(), patch: patchTransform(), name: nameTransform()))
    }
    
    static func paramData(channel: Int, instrument: Int, paramAddress: Int, value: UInt8) -> [UInt8] {
      FB01.paramData(channel: channel, instrument: instrument, bodyBytes: [
        UInt8(paramAddress), UInt8(value),
      ])
    }
    

    enum Bank {
      
      static let bankTruss = SingleBankTruss(patchTruss: patchTruss, patchCount: 16, fileDataCount: 2616, createFileData: {
        sysexData($0, channel: 0)
      }, parseBodyData: {
        SingleBankTruss.compactData(fileData: $0, offset: 7, patchByteCount: 163).map {
          $0.safeBytes(offset: 2, count: 160)
        }
      })
                  
      static func sysexData(_ bodyData: [[UInt8]], channel: Int) -> [UInt8] {
        Yamaha.sysex([0x75, UInt8(channel), 0x00, 0x03, 0x00] + bodyData.flatMap {
          [0x01, 0x20] + $0 + [Yamaha.checksum(bytes: $0)]
        })
      }
      
      static func transform() -> MidiTransform {
        .single(throttle: 30, sysexChannel, .wholeBank({ editorVal, bodyData in
          [(.sysex(sysexData(bodyData, channel: editorVal)), 10)]
        }))
      }

    }
    
    static let parms: [Parm] = [
      .p([.voice, .load, .mode], 0x08, p: 0x14, .max(1)),
      .p([.lfo, .speed], 0x09, p: 0x10),
      .p([.amp, .mod, .depth], 0x0a, p: 0x11),
      .p([.pitch, .mod, .depth], 0x0b, p: 0x12),
      .p([.lfo, .wave], 0x0c, p: 0x13, .opts(Voice.lfoWaveOptions)),
      .p([.key, .rcv, .mode], 0x0d, .opts(["All","Even","Odd"])),
    ] <<< .prefix([.part], count: 8, bx: 0x10, block: { _ in
        .offset(b: 0x20) { [
          .p([.voice, .reserve], 0, .max(8)),
          .p([.channel], 0x01, .max(15, dispOff: 1)),
          .p([.key, .hi], 0x02),
          .p([.key, .lo], 0x03),
          .p([.bank], 0x04, .opts((1...7).map { "\($0)" })),
          .p([.pgm], 0x05, .max(47)),
          .p([.detune], 0x06, .rng(-64...63)),
          .p([.octave], 0x07, .max(4, dispOff: -2)),
          .p([.level], 0x08),
          .p([.pan], 0x09, .options([
            0 : "Left",
            64 : "L+R",
            127 : "Right"
          ])),
          .p([.lfo, .on], 0x0a, .max(1)),
          .p([.porta], 0x0b),
          .p([.bend], 0x0c, .max(12)),
          .p([.mono], 0x0d, .max(1)),
          .p([.pitch, .mod, .depth, .ctrl], 0x0e, .opts(Voice.ctrlOptions)),
        ] }
    })
    
  }
  
}


extension Op4 {
  
  enum Micro {
    
    struct Werk {
      
      let sysexIndex: Int
      let subCmdByte: UInt8
      let patchWerk: PatchWerk
      
      init(_ displayType: String, _ bodyDataCount: Int, params: SynthPathParam, initFile: String = "", subCmdByte: UInt8, sysexIndex: Int) {
        self.sysexIndex = sysexIndex
        self.subCmdByte = subCmdByte
        self.patchWerk = PatchWerk(synth, displayType, bodyDataCount, params: params, initFile: initFile, cmdByte: 0x10, sysexData: {
          let bodyBytes = "LM  MCRTE\(sysexIndex)".sysexBytes() + $0
          return Yamaha.sysexData(channel: $1, cmdBytes: [0x7e, 0x00, 0x22], bodyBytes: bodyBytes)
        }, parseOffset: 16, compact: nil)
      }
      
      func paramData(key: UInt8, note: UInt8, fine: UInt8, channel: Int) -> [UInt8] {
        patchWerk.paramData(channel: channel, cmdBytes: [subCmdByte, key, note, fine])
      }

      func patchChangeTransform() -> MidiTransform {
        return .single(throttle: 100, sysexChannel, .patch(coalesce: 10, param: { editorVal, bodyData, parm, value in
          let key = parm.path.i(0) ?? 0
          let note: UInt8
          let fine: UInt8
          if parm.path.last == .note {
            note = UInt8(max(0, value))
            fine = UInt8(patchWerk.truss.getValue(bodyData, path: [.i(key), .fine]) ?? 0)
          }
          else {
            note = UInt8(patchWerk.truss.getValue(bodyData, path: [.i(key), .note]) ?? 0)
            fine = UInt8(max(0, value))
          }
          let data = paramData(key: UInt8(key), note: note, fine: fine, channel: editorVal)
          return [(.sysex(data), 0)]
        }, patch: patchWerk.patchTransform, name: nil))
      }
    }

    enum Oct {

      static let werk = Werk("micro.oct", 24, params: parms.params(), initFile: "", subCmdByte: 0x7d, sysexIndex: 0)

      static let parms: [Parm] = .prefix([], count: 12, bx: 2, block: { i in [
        .p([.note], 0, .iso(noteIso, 13...108)),
        .p([.fine], 1, .max(63)),
      ]})
    }
    
    enum Full {
      
      static let werk = Werk("micro.full", 256, params: parms.params(), initFile: "", subCmdByte: 0x7e, sysexIndex: 1)
      
      static let parms: [Parm] = .prefix([], count: 128, bx: 2, block: { i in [
        .p([.note], 0, .iso(noteIso, 13...108)),
        .p([.fine], 1, .max(63)),
      ]})
    }
    
    static let noteIso = Miso.noteName(zeroNote: "C-2")
  }
  
}

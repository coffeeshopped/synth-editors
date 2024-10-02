extension FS1R.Fseq {
  
  static let presets = ["ShoobyDo", "2BarBeat", "D&B", "D&B Fill", "4BarBeat", "YouCanG", "EBSayHey", "RtmSynth", "VocalRtm", "WooWaPa", "UooLha", "FemRtm", "ByonRole", "WowYeah", "ListenVo", "YAMAHAFS", "Laugh", "Laugh2", "AreYouR", "Oiyai", "Oiaiuo", "UuWaUu", "Wao", "RndArp1", "FiltrArp", "RndArp2", "TechArp", "RndArp3", "Voco-Seq", "PopTech", "1BarBeat", "1BrBeat2", "Undo", "RndArp4", "VoclRtm2", "Reiyowha", "RndArp5", "VocalArp", "CanYouGi", "Pu-Yo", "Yaof", "MyaOh", "ChuckRtm", "ILoveYou", "Jan-On", "Welcome", "One-Two", "Edokko", "Everybdy", "Uwau", "YEEAAH", "4-3-2-1", "Test123", "CheckSnd", "ShavaDo", "R-M-H-R", "HiSchool", "M.Blastr", "L&G MayI", "Hellow", "ChowaUu", "Everybd2", "Dodidowa", "Check123", "BranNewY", "BoomBoom", "Hi=Woo", "FreeForm", "FreqPad", "YouKnow", "OldTech", "B/M", "MiniJngl", "EveryB-S", "IYaan", "Yeah", "ThankYou", "Yes=No", "UnWaEDon", "MouthPop", "Fire", "TBLine", "China", "Aeiou", "YaYeYiYo", "C7Seq", "SoundLib", "IYaan2", "Relax", "PSYAMAHA"]

}

extension FS1R {
  
  enum Fseq {
    
    static let patchTruss = try! SinglePatchTruss("fseq", 6443 - 11, namePackIso: .basic(0..<8), params: params, initFile: "fs1r-fseq-init", createFileData: {
      sysexData($0, deviceId: 0).bytes()
    }, parseBodyData: {
      // variable data length - 50 bytes per frame
      guard $0.count > 11 else { return [] }
      return [UInt8]($0.safeBytes(9..<($0.count - 2)))
    }, validBundle: SinglePatchTruss.Core.validBundle(counts: [6443, 12843, 19243, 25643]))
    
    static func sysexData(_ bytes: [UInt8], deviceId: UInt8) -> MidiMessage {
      FS1R.sysexData(bytes, deviceId: deviceId, address: [0x60, 0x00, 0x00])
    }

    /// sysex bytes for patch as stored in memory location
    static func sysexData(_ bytes: [UInt8], deviceId: UInt8, location: Int) -> MidiMessage {
      FS1R.sysexData(bytes, deviceId: deviceId, address: [0x61, 0x00, UInt8(location)])
    }

    
    static let patchChangeTransform: MidiTransform = .single(throttle: 30, deviceId, .patch(param: { editorVal, bodyData, path, value in
        return nil
        //      guard let param = FS1RFseqPatch.params[path] else { return nil }
        //      if let part = path[0] == .part ? path.i(1) : nil {
        //        return [(perfPartParamData(editor, patch: patch, part: part, param: param), 0.03)]
        //      }
        //      else {
        //        // common params have param address stored in .byte
        //        var byte = param.byte
        //        let byteCount = param.parm > 0 ? param.parm : 1
        //        if (0x30..<0x40).contains(byte) {
        //          // special treatment for src bits
        //          byte = byte - (byte % 2)
        //        }
        //        return [(perfCommonParamData(editor, patch: patch, paramAddress: byte, byteCount: byteCount), 0.03)]
        //      }
    }, patch: { editorVal, bodyData in
      [(sysexData(bodyData, deviceId: deviceIdMap(editorVal)), 30)]
    }, name: { editorVal, bodyData, path, name in
      let deviceId = deviceIdMap(editorVal)
      return patchTruss.namePackIso?.byteRange.map {
        (headerParamData(deviceId, bodyData: bodyData, paramAddress: $0, byteCount: 1), 30)
      }
    }))

    private static func headerParamData(_ deviceId: UInt8, bodyData: [UInt8], paramAddress: Int, byteCount: Int) -> MidiMessage {
      // instead of sending <value>, we send the byte from the bytes array, because some params share bytes with others
      let v = byteCount == 1 ? Int(bodyData[paramAddress]) : (Int(bodyData[paramAddress]) << 7) + Int(bodyData[paramAddress+1])
      let paramBytes = RolandAddress(intValue: paramAddress).sysexBytes(count: 2)
      return dataSetMsg(deviceId: deviceId, address: [0x70] + paramBytes, value: v)
    }
    
    static let bankChangeTransform: MidiTransform = .single(throttle: 0, deviceId, .bank({
      [(sysexData($1, deviceId: deviceIdMap($0), location: $2), 100)]
    }))

    
    enum Bank {
      
      static let bankTruss = SingleBankTruss(patchTruss: patchTruss, patchCount: 6, createFileData: bankCreateFileData(sysexData), parseBodyData: bankParseBodyData(patchTruss: patchTruss, patchCount: 128), validBundle: (
        validSize: {
          // there are so many possibilities of valid file sizes, we're fudging.
          $0 >= 6443 * 6
        },
        validData: isValid,
        completeFetch: isValid
      ))
      
      static func isValid(sysex: [UInt8]) -> Bool {
        // smallest possible
        guard sysex.count >= 6443 * 6 else { return false }

        let s = SysexData(data: Data(sysex))
        guard s.count == 6 else { return false }
        for msg in s {
          guard patchTruss.isValidSize(msg.count) else { return false }
        }
        return true
      }

    }
  
    
    // TODO: get/set needs to take into account 2-byte params but also those bytes aren't contiguous in the frames!
    // Same with param sends on this stuff!

    static let params: SynthPathParam = {
      var p = SynthPathParam()
      
      p[[.loop, .start]] = RangeParam(parm: 0x10, byte: 0x10, extra: [0:2], maxVal: 511)
      p[[.loop, .end]] = RangeParam(parm: 0x12, byte: 0x12, extra: [0:2], maxVal: 511)
      p[[.loop, .mode]] = OptionsParam(parm: 0x14, byte: 0x14, options: ["1-way", "Round"])
      p[[.speed]] = RangeParam(parm: 0x15, byte: 0x15)
      p[[.speed, .velo]] = RangeParam(parm: 0x16, byte: 0x16, maxVal: 7)
      p[[.pitch, .mode]] = OptionsParam(parm: 0x17, byte: 0x17, options: ["Pitch", "Non-pitch"])
      p[[.note, .assign]] = RangeParam(parm: 0x18, byte: 0x18)
      p[[.detune]] = RangeParam(parm: 0x19, byte: 0x19, maxVal: 126, displayOffset: -63)
      p[[.delay]] = RangeParam(parm: 0x1a, byte: 0x1a, maxVal: 99)
      p[[.form]] = OptionsParam(parm: 0x1b, byte: 0x1b, options: ["128", "256", "384", "512"])
      p[[.end]] = RangeParam(parm: 0x1e, byte: 0x1e, extra: [0:2], maxVal: 511)
      
      (0..<512).forEach { step in
        let off = 16 + (50 * step) // another 16 will be added basically by parm in byte

        p[[.pitch, .step, .i(step)]] = RangeParam(parm: 0x10, byte: 0x10 + off, extra: [0:2], maxVal: 16383)

        (0..<8).forEach { trk in
          let offTrk = off + trk
          p[[.trk, .i(trk), .voiced, .freq, .step, .i(step)]] = RangeParam(parm: 0x12 + trk, byte: 0x12 + offTrk, extra: [0:2], maxVal: 16383)
          p[[.trk, .i(trk), .voiced, .level, .step, .i(step)]] = RangeParam(parm: 0x22 + trk, byte: 0x22 + offTrk)
          p[[.trk, .i(trk), .unvoiced, .freq, .step, .i(step)]] = RangeParam(parm: 0x2a + trk, byte: 0x2a + offTrk, extra: [0:2], maxVal: 16383)
          p[[.trk, .i(trk), .unvoiced, .level, .step, .i(step)]] = RangeParam(parm: 0x3a + trk, byte: 0x3a + offTrk)
        }
      }

      return p
    }()

  }
  
}


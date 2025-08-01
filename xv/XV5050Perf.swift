
extension XV5050 {
  
  enum Perf {
    
    static let patchWerk = XV.Perf.patchWerk(16, common: Common.patchWerk, part: Part.patchWerk, fx: FX.patchWerk, chorus: Chorus.patchWerk, reverb: Reverb.patchWerk, other: [
      ([.fx, .i(1)], 0x0800, XV5050.FX.patchWerk),
      ([.fx, .i(2)], 0x0a00, XV5050.FX.patchWerk),
    ], initFile: "xv5050-perf-init")
    
    static let bankWerk = XV.Perf.bankWerk(patchWerk, initFile: "xv5050-perf-bank-init")
    
    static let fullRefTruss = XV.Perf.Full.refTruss(16, perf: patchWerk, voice: Voice.patchWerk, rhythm: rhythmPatchWerk)
    
    enum Common {
      static let patchWerk = XV.Perf.Common.patchWerk(params: params)
      
      static let parms: [Parm] = [
        .p([.solo], 0x0c, .options(soloOptions)),
        .p([.fx, .ctrl, .channel], 0x0d, .options(fxCtrlChannelOptions)),
        .p([.fx, .ctrl, .midi, .i(0)], 0x0e, .max(1)),
        .p([.fx, .ctrl, .midi, .i(1)], 0x0f, .max(1)),
      ] + .prefix([.voice, .reserve], count: 32, bx: 1, block: { index, offset in
        [
          .p([], 0x10, .options(voiceReserveOptions)),
        ]
      }) + [
        .p([.fx, .i(0), .src], 0x30, .options(srcOptions)),
        .p([.fx, .i(1), .src], 0x31, .options(srcOptions)),
        .p([.fx, .i(2), .src], 0x32, .options(srcOptions)),
        .p([.chorus, .src], 0x33, .options(srcOptions)),
        .p([.reverb, .src], 0x34, .options(srcOptions)),
      ]
      
      static let params = parms.params()
        
      static let soloOptions = OptionsParam.makeOptions((17.map { $0 == 0 ? "Off" : "\($0)" }))

      static let fxCtrlChannelOptions = OptionsParam.makeOptions((17.map {
        $0 == 16 ? "Off" : "\($0 + 1)"
      }))

      static let voiceReserveOptions = OptionsParam.makeOptions((65.map { $0 == 64 ? "Full" : "\($0)" }))

      static let srcOptions = OptionsParam.makeOptions((17.map { $0 == 0 ? "Perform" : "\($0)" }))
    }

    enum Midi {
      
      static let patchWerk = try! XV.sysexWerk.singlePatchWerk("Perf Midi", params, size: 0x0c, start: 0x1000)
      
      static let parms: [Parm] = [
        .p([.rcv, .pgmChange], 0x00, .max(1)),
        .p([.rcv, .bank], 0x01, .max(1)),
        .p([.rcv, .bend], 0x02, .max(1)),
        .p([.rcv, .poly, .pressure], 0x03, .max(1)),
        .p([.rcv, .channel, .pressure], 0x04, .max(1)),
        .p([.rcv, .mod], 0x05, .max(1)),
        .p([.rcv, .volume], 0x06, .max(1)),
        .p([.rcv, .pan], 0x07, .max(1)),
        .p([.rcv, .expression], 0x08, .max(1)),
        .p([.rcv, .hold], 0x09, .max(1)),
        .p([.phase, .lock], 0x0a, .max(1)),
        .p([.velo, .curve], 0x0b, .options(veloCurveOptions)),
      ]
      
      static let params = parms.params()
      
      static let veloCurveOptions = OptionsParam.makeOptions((5.map { $0 == 0 ? "Off" : "\($0)" }))
    }

    enum Part {
      static let patchWerk = XV.Perf.Part.patchWerk(params: params, size: 0x31)
      
      static let parms: [Parm] = XV3080.Perf.Part.parms + [
        .p([.out, .assign], 0x1f, .options(outAssignOptions)),
        .p([.decay], 0x21, .rng(dispOff: -64)),
        .p([.vib, .rate], 0x22, .rng(dispOff: -64)),
        .p([.vib, .depth], 0x23, .rng(dispOff: -64)),
        .p([.vib, .delay], 0x24, .rng(dispOff: -64)),
      ] + .prefix([.scale, .tune], count: 12, bx: 1, block: { index, offset in
        [
          .p([], 0x25, .rng(dispOff: -64)),
        ]
      })

      static let params = parms.params()
      
      static var outAssignOptions = XV5050.Voice.Tone.outAssignOptions
        <<< [13 : "Patch"]
      
      static let internalPartGroupOptions: [Int:String] = {
        let ids: [SynthPath] = [
          [],
          [.int, .user],
          [.int, .preset, .i(0)],
          [.int, .preset, .i(1)],
          [.int, .preset, .i(2)],
          [.int, .preset, .i(3)],
          [.int, .preset, .i(4)],
          [.int, .preset, .i(5)],
          [.int, .preset, .i(6)],
          [.int, .preset, .i(7)],
          [.int, .gm2],
        ]
        return ids.dict {
          [XV.Perf.Part.value(forSynthPath: $0) : XV.Perf.Part.internalGroupsMap[$0] ?? ""]
        }
      }()

      static let config: XV.Perf.Part.Config = {
        var config = XV3080.Perf.Part.config
        config.voicePartGroups = internalPartGroupOptions <<< XV.Perf.Part.srxPartGroupOptions
        config.rhythmPartGroups = internalPartGroupOptions <<< XV.Perf.Part.srxPartGroupOptions
        return config
      }()
    }
  }
  
}

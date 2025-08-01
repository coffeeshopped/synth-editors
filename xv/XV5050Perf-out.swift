
extension XV5050 {
  
  enum Perf {
    
    const patchWerk = XV.Perf.patchWerk(16, common: Common.patchWerk, part: Part.patchWerk, fx: FX.patchWerk, chorus: Chorus.patchWerk, reverb: Reverb.patchWerk, other: [
      ("fx/1", 0x0800, XV5050.FX.patchWerk),
      ("fx/2", 0x0a00, XV5050.FX.patchWerk),
    ], initFile: "xv5050-perf-init")
    
    const bankWerk = XV.Perf.bankWerk(patchWerk, initFile: "xv5050-perf-bank-init")
    
    const fullRefTruss = XV.Perf.Full.refTruss(16, perf: patchWerk, voice: Voice.patchWerk, rhythm: rhythmPatchWerk)
    
    enum Common {
      const patchWerk = XV.Perf.Common.patchWerk(params: params)
      
      const parms: [Parm] = [
        ['solo', { b: 0x0c, opts: soloOptions }],
        ['fx/ctrl/channel', { b: 0x0d, opts: fxCtrlChannelOptions }],
        ['fx/ctrl/midi/0', { b: 0x0e, max: 1 }],
        ['fx/ctrl/midi/1', { b: 0x0f, max: 1 }],
      ] + .prefix("voice/reserve", count: 32, bx: 1, block: { index, offset in
        [
          .p([], 0x10, .options(voiceReserveOptions)),
        ]
      }) + [
        ['fx/0/src', { b: 0x30, opts: srcOptions }],
        ['fx/1/src', { b: 0x31, opts: srcOptions }],
        ['fx/2/src', { b: 0x32, opts: srcOptions }],
        ['chorus/src', { b: 0x33, opts: srcOptions }],
        ['reverb/src', { b: 0x34, opts: srcOptions }],
      ]
      
      const params = parms.params()
        
      const soloOptions = (17.map { $0 == 0 ? "Off" : "\($0)" })

      const fxCtrlChannelOptions = OptionsParam.makeOptions((17.map {
        $0 == 16 ? "Off" : "\($0 + 1)"
      }))

      const voiceReserveOptions = (65.map { $0 == 64 ? "Full" : "\($0)" })

      const srcOptions = (17.map { $0 == 0 ? "Perform" : "\($0)" })
    }

    enum Midi {
      
      const patchWerk = try! XV.sysexWerk.singlePatchWerk("Perf Midi", params, size: 0x0c, start: 0x1000)
      
      const parms: [Parm] = [
        ['rcv/pgmChange', { b: 0x00, max: 1 }],
        ['rcv/bank', { b: 0x01, max: 1 }],
        ['rcv/bend', { b: 0x02, max: 1 }],
        ['rcv/poly/pressure', { b: 0x03, max: 1 }],
        ['rcv/channel/pressure', { b: 0x04, max: 1 }],
        ['rcv/mod', { b: 0x05, max: 1 }],
        ['rcv/volume', { b: 0x06, max: 1 }],
        ['rcv/pan', { b: 0x07, max: 1 }],
        ['rcv/expression', { b: 0x08, max: 1 }],
        ['rcv/hold', { b: 0x09, max: 1 }],
        ['phase/lock', { b: 0x0a, max: 1 }],
        ['velo/curve', { b: 0x0b, opts: veloCurveOptions }],
      ]
      
      const params = parms.params()
      
      const veloCurveOptions = (5.map { $0 == 0 ? "Off" : "\($0)" })
    }

    enum Part {
      const patchWerk = XV.Perf.Part.patchWerk(params: params, size: 0x31)
      
      const parms: [Parm] = XV3080.Perf.Part.parms + [
        ['out/assign', { b: 0x1f, opts: outAssignOptions }],
        ['decay', { b: 0x21, dispOff: -64 }],
        ['vib/rate', { b: 0x22, dispOff: -64 }],
        ['vib/depth', { b: 0x23, dispOff: -64 }],
        ['vib/delay', { b: 0x24, dispOff: -64 }],
      ] + .prefix("scale/tune", count: 12, bx: 1, block: { index, offset in
        [
          .p([], 0x25, .rng(dispOff: -64)),
        ]
      })

      const params = parms.params()
      
      static var outAssignOptions = XV5050.Voice.Tone.outAssignOptions
        <<< [13 : "Patch"]
      
      const internalPartGroupOptions: [Int:String] = {
        let ids: [SynthPath] = [
          [],
          "int/user",
          "int/preset/0",
          "int/preset/1",
          "int/preset/2",
          "int/preset/3",
          "int/preset/4",
          "int/preset/5",
          "int/preset/6",
          "int/preset/7",
          "int/gm2",
        ]
        return ids.dict {
          [XV.Perf.Part.value(forSynthPath: $0) : XV.Perf.Part.internalGroupsMap[$0] ?? ""]
        }
      }()

      const config: XV.Perf.Part.Config = {
        var config = XV3080.Perf.Part.config
        config.voicePartGroups = internalPartGroupOptions <<< XV.Perf.Part.srxPartGroupOptions
        config.rhythmPartGroups = internalPartGroupOptions <<< XV.Perf.Part.srxPartGroupOptions
        return config
      }()
    }
  }
  
}


extension XV5080 {
  
  enum Perf {
    
    const patchWerk = XV.Perf.patchWerk(32, common: Common.patchWerk, part: Part.patchWerk, fx: FX.patchWerk, chorus: Chorus.patchWerk, reverb: Reverb.patchWerk, other: [], initFile: "xv5050-perf-init")
    
    const bankWerk = XV.Perf.bankWerk(patchWerk, initFile: "xv3080-perf-bank-init")

    const fullRefTruss = XV.Perf.Full.refTruss(32, perf: patchWerk, voice: Voice.patchWerk, rhythm: rhythmPatchWerk)

    enum Common {
      const patchWerk = XV.Perf.Common.patchWerk(params: parms.params())
      
      const parms = XV5050.Perf.Common.parms + [
        ['solo', { b: 0x0c, opts: soloOptions }],
        ['fx/0/src', { b: 0x30, opts: srcOptions }],
        ['fx/1/src', { b: 0x31, opts: srcOptions }],
        ['fx/2/src', { b: 0x32, opts: srcOptions }],
        ['chorus/src', { b: 0x33, opts: srcOptions }],
        ['reverb/src', { b: 0x34, opts: srcOptions }],
      ]
      
      const soloOptions = (33.map { $0 == 0 ? "Off" : "\($0)" })
      const srcOptions = (33.map { $0 == 0 ? "Perform" : "\($0)" })
    }

    enum Part {
      const patchWerk = XV.Perf.Part.patchWerk(params: parms.params(), size: 0x21)
      
      const parms = XV3080.Perf.Part.parms + [
        ['out/assign', { b: 0x1f, opts: outAssignOptions }],
        ['out/fx', { b: 0x20, opts: ["A","B","C"] }],
      ]
      
      const config: XV.Perf.Part.Config = {
        var config = XV3080.Perf.Part.config
        config.voicePartGroups = internalPartGroupOptions <<< XV.Perf.Part.srjvPartGroupOptions <<< XV.Perf.Part.srxPartGroupOptions
        return config
      }()

      const outAssignOptions = Voice.Tone.outAssignOptions <<<
        [13 : "Patch"]
      
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
          "int/gm2",
        ]
        return ids.dict {
          [XV.Perf.Part.value(forSynthPath: $0) : XV.Perf.Part.internalGroupsMap[$0] ?? ""]
        }
      }()
      

    }
  }
  
}

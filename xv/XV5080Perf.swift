
extension XV5080 {
  
  enum Perf {
    
    static let patchWerk = XV.Perf.patchWerk(32, common: Common.patchWerk, part: Part.patchWerk, fx: FX.patchWerk, chorus: Chorus.patchWerk, reverb: Reverb.patchWerk, other: [], initFile: "xv5050-perf-init")
    
    static let bankWerk = XV.Perf.bankWerk(patchWerk, initFile: "xv3080-perf-bank-init")

    static let fullRefTruss = XV.Perf.Full.refTruss(32, perf: patchWerk, voice: Voice.patchWerk, rhythm: rhythmPatchWerk)

    enum Common {
      static let patchWerk = XV.Perf.Common.patchWerk(params: parms.params())
      
      static let parms = XV5050.Perf.Common.parms + [
        .p([.solo], 0x0c, .options(soloOptions)),
        .p([.fx, .i(0), .src], 0x30, .options(srcOptions)),
        .p([.fx, .i(1), .src], 0x31, .options(srcOptions)),
        .p([.fx, .i(2), .src], 0x32, .options(srcOptions)),
        .p([.chorus, .src], 0x33, .options(srcOptions)),
        .p([.reverb, .src], 0x34, .options(srcOptions)),
      ]
      
      static let soloOptions = OptionsParam.makeOptions((33.map { $0 == 0 ? "Off" : "\($0)" }))
      static let srcOptions = OptionsParam.makeOptions((33.map { $0 == 0 ? "Perform" : "\($0)" }))
    }

    enum Part {
      static let patchWerk = XV.Perf.Part.patchWerk(params: parms.params(), size: 0x21)
      
      static let parms = XV3080.Perf.Part.parms + [
        .p([.out, .assign], 0x1f, .options(outAssignOptions)),
        .p([.out, .fx], 0x20, .opts(["A","B","C"])),
      ]
      
      static let config: XV.Perf.Part.Config = {
        var config = XV3080.Perf.Part.config
        config.voicePartGroups = internalPartGroupOptions <<< XV.Perf.Part.srjvPartGroupOptions <<< XV.Perf.Part.srxPartGroupOptions
        return config
      }()

      static let outAssignOptions = Voice.Tone.outAssignOptions <<<
        [13 : "Patch"]
      
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
          [.int, .gm2],
        ]
        return ids.dict {
          [XV.Perf.Part.value(forSynthPath: $0) : XV.Perf.Part.internalGroupsMap[$0] ?? ""]
        }
      }()
      

    }
  }
  
}

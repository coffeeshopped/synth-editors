
extension FB01.Perf {
  
  enum Controller {
    
    static var controller: PatchController {
      return .patch([
        .children(8, "p", partController),
        .panel("voice", color: 1, [[
          .checkbox("Voice F Combi", [.voice, .load, .mode]),
          .switsch("Key Rcv", [.key, .rcv, .mode]),
        ]]),
        .panel("lfo", color: 1, [[
          .select("LFO Wave", [.lfo, .wave]),
          .knob("Speed", [.lfo, .speed]),
          .knob("AMD", [.amp, .mod, .depth]),
          .knob("PMD", [.pitch, .mod, .depth]),
        ]]),
      ], effects: [], layout: [
        .row([("voice",3),("lfo",5)]),
        .row(8.map { ("p\($0)", 1)}),
        .col([("voice",1),("p0",8)]),
      ])
    }
    
    static var partController: PatchController {
      return .index([.part], label: [.part], { "\($0 + 1)" }, color: 2, [
        .grid([[
          .knob("MIDI Ch", [.channel]),
          .knob("Note Rsrv", [.voice, .reserve]),
        ],[
          .knob("Low N", [.key, .lo]),
          .knob("Hi N", [.key, .hi]),
        ],[
          .select([.bank]),
          .select([.pgm], width: 5),
        ],[
          .knob([.octave]),
          .knob([.detune]),
        ],[
          .knob([.level]),
          .switsch([.pan]),
        ],[
          .checkbox("LFO", [.lfo, .on]),
          .knob([.porta]),
        ],[
          .knob([.bend]),
          .checkbox([.mono]),
        ],[
          .select("Pitch Ctrl", [.pitch, .mod, .depth, .ctrl]),
          .label("?", id: [.part], width: 1),
        ]])
      ], effects: .patchSelector(id: [.pgm], bankValue: [.bank], paramMap: { bank in
        if bank < 2 {
          return .fullPath([.patch, .name, .i(bank)])
        }
        else {
          return .opts(ParamOptions(optArray: FB01.voiceRamBanks[bank - 2]))
        }
      }))
    }
    
  }
  
}


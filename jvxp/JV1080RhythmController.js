
extension JV1080.Rhythm {
  
  enum Controller {
    
    static func controller() -> PatchController {
      let allPaths = [SynthPath](JV1080.Rhythm.Note.params.keys)

      return .patch(prefix: .index([.note]), [
        .child(JV1080.Voice.Controller.wave(), "wave", color: 1),
        .child(pitch(), "pitch", color: 1),
        .child(filter(), "filter", color: 2),
        .child(amp(), "amp", color: 3),
        .switcher(label: "", 64.map {
          let noteNum = $0 + 35
          let noteName = ParamHelper.noteName(noteNum)
          return "\(noteName): \(noteNum)"
        }, cols: 12, color: 1),
        .panel("ctrl", color: 1, [[
          .knob("Bend Range", [.bend, .range]),
          .knob("Mute Group", [.mute, .group]),
          .checkbox("Env Sustain", [.env, .sustain]),
          .checkbox("Vol Ctrl", [.volume, .ctrl]),
          .checkbox("Hold-1 Ctrl", [.hold, .ctrl]),
          .switsch("Pan Ctrl", [.pan, .ctrl]),
        ]]),
        .button("Note", color: 1),
        .panel("output", color: 3, [
          [.select("Output", [.out, .assign])],
          [.knob("Level", [.out, .level])],
          [.knob("Chorus", [.chorus])],
          [.knob("Reverb", [.reverb])],
          ]),
      ], effects: [
        .editMenu([.button], paths: allPaths, type: "JV1080RhythmNote", init: nil, rand: nil),
        .indexChange({ index in
          return [
            .midiNote(chan: 0, note: 35 + index, velo: 100, len: 500),
          ]
        }),
      ], layout: [
        .row([("switch",1)]),
        .row([("wave",5), ("ctrl",6.5), ("button",1.5)]),
        .row([("pitch",4), ("filter",5), ("amp",4), ("output",1.5)]),
        .col([("switch",4), ("wave",1), ("pitch",4)]),
      ])
      
//      override func randomize(_ sender: Any?) {
//        pushPatchChange(.replace(JV1080RhythmNotePatch.random()))
//      }
    }

    static func pitch() -> PatchController {
      let env = JV1080.Voice.Controller.pitchEnvs()

      return .patch([
        .grid([[
          .knob("Key", [.src, .key]),
          .knob("Fine", [.fine]),
          .knob("Random", [.random, .pitch]),
          .knob("Velo→Env Time", [.pitch, .env, .velo, .time]),
        ],[
          env.env,
          .knob("Env→Pitch", [.pitch, .env, .depth]),
          .knob("Velo→Env D", [.pitch, .env, .velo, .sens]),
        ]] + [
          4.map { .knob("T\($0)", [.pitch, .env, .time, .i($0)]) },
          4.map { .knob("L\($0)", [.pitch, .env, .level, .i($0)]) },
        ])
      ], effects: [env.effect])
    }
    
    static func filter() -> PatchController {
      let env = JV1080.Voice.Controller.filterEnvs()

      return .patch([
        .grid([[
          .select("Filter", [.filter, .type]),
          .knob("Cutoff", [.cutoff]),
          .knob("Reson", [.reson]),
          .knob("Velo→Reson", [.reson, .velo, .sens]),
        ],[
          env.env,
          .knob("Env→Cutoff", [.filter, .env, .depth]),
          .knob("Velo→Env D", [.filter, .env, .velo, .sens]),
          .knob("Velo→Env Time", [.filter, .env, .velo, .time]),
        ]] + [
          4.map { .knob("T\($0)", [.filter, .env, .time, .i($0)]) },
          4.map { .knob("L\($0)", [.filter, .env, .level, .i($0)]) },
        ])
      ], effects: [env.effect])
    }

    static func amp() -> PatchController {
      let env = JV1080.Voice.Controller.ampEnvs()

      return .patch([
        .grid([[
          .knob("Level", [.tone, .level]),
          .knob("Pan", [.pan]),
          .knob("Random Pan", [.random, .pan]),
          .knob("Alt Pan", [.alt, .pan]),
        ],[
          env.env,
          .knob("Velo→Env D", [.amp, .env, .velo, .sens]),
          .knob("Velo→Env Time", [.amp, .env, .velo, .time]),
        ]] + [
          4.map { .knob("T\($0)", [.amp, .env, .time, .i($0)]) },
          3.map { .knob("L\($0)", [.amp, .env, .level, .i($0)]) },
        ])
      ], effects: [env.effect])
    }
  }
  
}


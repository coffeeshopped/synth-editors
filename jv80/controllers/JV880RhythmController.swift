
extension JV880.Rhythm {
  
  enum Controller {

    static func controller(hideOut: Bool) -> PatchController {
      let noteMiso = Miso.noteName(zeroNote: "C2")

      return .patch([
        .child(note(hideOut: hideOut), "note"),
        .switcher(label: "", 61.map { noteMiso.forward(Float($0)) }, cols: 16, color: 1)
      ], effects: [
        .indexChange({ [
          .midiNote(chan: 0, note: 36 + $0, velo: 100, len: 500),
          .setIndex("note", $0)
        ] })
      ], layout: [
        .row([("switch",1)]),
        .row([("note",1)]),
        .col([("switch",3),("note",6)]),
      ])
    }
    
    static func note(hideOut: Bool) -> PatchController {
      return .patch(prefix: .index([.note]), [
        .child(JV880.Voice.Controller.wave(), "wave"),
        .child(pitch(), "pitch"),
        .child(filter(), "filter"),
        .child(amp(), "amp"),
        .panel("on", color: 1, [[
          .checkbox("On", [.on]),
          ]]),
        .panel("mute", color: 1, [[
          .knob("Mute Group", [.mute, .group]),
          .checkbox("Env Sustain", [.env, .sustain]),
          .knob("Bend", [.bend, .range]),
          ]]),
        .panel("outs", color: 1, [[
          .knob("Dry", [.out, .level]),
          .knob("Reverb", [.reverb]),
          .knob("Chorus", [.chorus]),
          .switsch("Output", [.out, .assign]),
          ]]),
        .button("Note", color: 1),
        .panel("space", [[]]),
      ], effects: [
        .editMenu([.button], paths: JV880.Rhythm.Note.patchWerk.truss.paramKeys(), type: "JV880RhythmNote", init: nil, rand: nil),
        .setup([
          .dimItem(hideOut, [.out, .assign], dimAlpha: 0),
        ]),
      ], layout: [
        .row([("on", 1), ("wave",2.5),("mute",3), ("outs",4), ("button", 2)]),
        .row([("pitch",4),("filter",5),("amp",4)]),
        .row([("space",1)]),
        .col([("on",1),("pitch",4),("space",1)]),
      ])
    }
    
    static func pitch() -> PatchController {
      return .patch(color: 1, [
        .grid([[
          .knob("Coarse", [.coarse]),
          .knob("Fine", [.fine]),
          .knob("Random Pitch", [.random, .pitch]),
          .knob("Velo→T1", [.pitch, .env, .velo, .time]),
        ],[
          JV880.Voice.Controller.pitchEnv.env,
          .knob("Env Depth", [.pitch, .env, .depth]),
          .knob("Velo→Env", [.pitch, .env, .velo, .sens]),
        ],[
          .knob("T1", [.pitch, .env, .time, .i(0)]),
          .knob("T2", [.pitch, .env, .time, .i(1)]),
          .knob("T3", [.pitch, .env, .time, .i(2)]),
          .knob("T4", [.pitch, .env, .time, .i(3)]),
        ],[
          .knob("L1", [.pitch, .env, .level, .i(0)]),
          .knob("L2", [.pitch, .env, .level, .i(1)]),
          .knob("L3", [.pitch, .env, .level, .i(2)]),
          .knob("L4", [.pitch, .env, .level, .i(3)]),
        ]])
      ], effects: [JV880.Voice.Controller.pitchEnv.menu])
    }
    
    static func filter() -> PatchController {
      return .patch(color: 2, [
        .grid([[
          .switsch("Filter", [.filter, .type]),
          .knob("Cutoff", [.cutoff]),
          .knob("Reson", [.reson]),
          .switsch("Reson Mode", [.reson, .mode]),
          .knob("Velo→Time", [.filter, .env, .velo, .time]),
        ],[
          JV880.Voice.Controller.filterEnv.env,
          .knob("Env Depth", [.filter, .env, .depth]),
          .knob("Velo→Env", [.filter, .env, .velo, .sens]),
        ],[
          .knob("T1", [.filter, .env, .time, .i(0)]),
          .knob("T2", [.filter, .env, .time, .i(1)]),
          .knob("T3", [.filter, .env, .time, .i(2)]),
          .knob("T4", [.filter, .env, .time, .i(3)]),
        ],[
          .knob("L1", [.filter, .env, .level, .i(0)]),
          .knob("L2", [.filter, .env, .level, .i(1)]),
          .knob("L3", [.filter, .env, .level, .i(2)]),
          .knob("L4", [.filter, .env, .level, .i(3)]),
        ]])
      ], effects: [
        JV880.Voice.Controller.filterEnv.menu,
        .dimsOn([.filter, .type], id: nil),
      ])
    }
    
    static func amp() -> PatchController {
      return .patch(color: 1, [
        .grid([[
          .knob("Level", [.level]),
          .knob("Pan", nil, id: [.pan]),
          .checkbox("Random Pan", nil, id: [.random, .pan]),
          .knob("Velo→Time", [.amp, .env, .velo, .time]),
        ],[
          JV880.Voice.Controller.ampEnv.env,
          .knob("Velo", [.amp, .env, .velo, .sens]),
        ],[
          .knob("T1", [.amp, .env, .time, .i(0)]),
          .knob("T2", [.amp, .env, .time, .i(1)]),
          .knob("T3", [.amp, .env, .time, .i(2)]),
          .knob("T4", [.amp, .env, .time, .i(3)]),
        ],[
          .knob("L1", [.amp, .env, .level, .i(0)]),
          .knob("L2", [.amp, .env, .level, .i(1)]),
          .knob("L3", [.amp, .env, .level, .i(2)]),
        ]])
      ], effects: JV880.Voice.Controller.ampEffects)
    }
    
  }
  
}

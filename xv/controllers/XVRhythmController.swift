
extension XV.Rhythm {
  
  enum Controller {
    
    static func controller(config: XV.CtrlConfig) -> PatchController {
      return .paged([
        .switcher(["FX"] + 9.map { "\($0)" }, color: 1),
        .panel("level", prefix: [.common], color: 1, [[
          .knob("Level", [.level]),
          .switsch("Clock Src", [.clock, .src]),
          .knob("Tempo", [.tempo]),
          .select("Out Assign", [.out, .assign]),
        ]]),
      ], effects: [
      ], layout: [
        .row([("switch",12),("level",4.5)]),
        .row([("page",1)]),
        .col([("switch",1),("page",8)]),
      ], pages: .map([[.fx]] + 9.map { [.tone, .i($0)] }, [
        [.fx] : XV.Voice.Controller.fxController(-1, config: config),
        [.tone] : tones(config: config),
      ]))
    }
    
    // See JD-Xi about this one.
    static func tones(config: XV.CtrlConfig) -> PatchController {
      let segCount = 12

      return .patch([
        .panel("grid", color: 1, clearBG: true, [[
          .grid("", nil, cols: segCount, id: [.note, .ctrl], width: 12),
        ]]),
        .child(tone(config: config), "tone"),
        .child(name, "name"),
      ], effects: [
        .indexChange(fn: { state, locals in
          let indexOffset = state.index * segCount
          let toneIndex = (locals[[.note, .ctrl]] ?? 0) + indexOffset - 9
          let noteOpts: PatchController.ConfigParam = .opts(ParamOptions(optArray: segCount.map {
            let noteNumber = indexOffset + $0 + 12
            return noteNumber < 21 || noteNumber > 108 ? "--" : ParamHelper.noteName(noteNumber)
          }))

          return [
            .configCtrl([.note, .ctrl], noteOpts),
            .setIndex("tone", toneIndex),
            .setIndex("name", toneIndex),
          ]
        }),
        .controlCommand([.note, .ctrl], latestValues: [], { value, latestValues, index in
          let i = value + (index * segCount) - 9
          return [
            .setIndex("tone", i),
            .setIndex("name", i),
            .midiNote(chan: 0, note: 21 + i, velo: 100, len: 500),
          ]
        })

      ], layout: [
        .row([("name", 2.5), ("grid",13.5)]),
        .row([("tone",1)]),
        .col([("name",1),("tone",7)]),
      ])
    }
    
    static let name: PatchController = .patch(prefix: .index([.tone]), color: 2, [
      .grid([[.name("Tone Name", [])]])
    ])
    
    
    static func tone(config: XV.CtrlConfig) -> PatchController {
      let t: PatchController = .paged([
        .switcher(label: nil, ["Main","WMT"], color: 2),
        .panel("single", color: 2, [[
          .checkbox("WMT 1", [.wave, .i(0), .on]),
          .checkbox("WMT 2", [.wave, .i(1), .on]),
          .checkbox("WMT 3", [.wave, .i(2), .on]),
          .checkbox("WMT 4", [.wave, .i(3), .on]),
          .checkbox("Single", [.assign, .type]),
          .switsch("WMT Velo", [.wave, .velo]),
          .checkbox("Rx Expr", [.rcv, .expression]),
          .checkbox("Rx Hold-1", [.rcv, .hold]),
          .switsch("Rx Pan", [.rcv, .pan]),
          ]]),
        .button("Tone", color: 2),
      ], effects: [
        .editMenu([.button], paths: Array(XV.Rhythm.Tone.params.keys), type: "XV5050RhythmTone", init: nil, rand: nil),
      ], layout: [
        .grid([
          (row: [("page", 1)], height: 6),
          (row: [("switch", 3), ("single",10.5), ("button",2.5)], height: 1),
        ])
      ], pages: .controllers([
        main(config: config),
        wmts(config: config),
      ]))
      
      return .patch(prefix: .index([.tone]), [
        .child(t, "t"),
      ], layout: [
        .simpleGrid([[("t", 1)]])
      ])

    }
    
    static func main(config: XV.CtrlConfig) -> PatchController {
      return .patch([
        .child(wmt(config: config), "wmt"),
        .panel("pitch", color: 2, [[
          .knob("Coarse", [.coarse]),
          .knob("Fine", [.fine]),
          .knob("Rand Pitch", [.random, .pitch]),
          .knob("Bend", [.bend]),
        ],[
          XV.Voice.Controller.pitchEnv.env,
          .knob("Env Depth", [.pitch, .env, .depth]),
          .knob("← Velo", [.pitch, .env, .velo]),
          .knob("Velo→T4", [.pitch, .env, .time, .i(3), .velo]),
        ],[
          .knob("Velo→T1", [.pitch, .env, .time, .i(0), .velo]),
          .knob("T1", [.pitch, .env, .time, .i(0)]),
          .knob("T2", [.pitch, .env, .time, .i(1)]),
          .knob("T3", [.pitch, .env, .time, .i(2)]),
          .knob("T4", [.pitch, .env, .time, .i(3)]),
        ],[
          .knob("L0", [.pitch, .env, .level, .i(-1)]),
          .knob("L1", [.pitch, .env, .level, .i(0)]),
          .knob("L2", [.pitch, .env, .level, .i(1)]),
          .knob("L3", [.pitch, .env, .level, .i(2)]),
          .knob("L4", [.pitch, .env, .level, .i(3)]),
        ]]),
        .panel("filter", color: 2, [[
          .select("Filter", [.filter, .type]),
          .knob("Cutoff", [.cutoff]),
          .knob("← Velo", [.cutoff, .velo]),
          .knob("Velo Crv", [.cutoff, .velo, .curve]),
          .knob("Reson", [.reson]),
          .knob("← Velo", [.reson, .velo]),
        ],[
          XV.Voice.Controller.filterEnv.env,
          .knob("Env Depth", [.filter, .env, .depth]),
          .knob("Velo→Env", [.filter, .env, .velo]),
          .knob("Velo→T4", [.filter, .env, .time, .i(3), .velo]),
        ],[
          .knob("Velo→T1", [.filter, .env, .time, .i(0), .velo]),
          .knob("T1", [.filter, .env, .time, .i(0)]),
          .knob("T2", [.filter, .env, .time, .i(1)]),
          .knob("T3", [.filter, .env, .time, .i(2)]),
          .knob("T4", [.filter, .env, .time, .i(3)]),
          .knob("Env Velo Crv", [.filter, .env, .velo, .curve]),
        ],[
          .knob("L0", [.filter, .env, .level, .i(-1)]),
          .knob("L1", [.filter, .env, .level, .i(0)]),
          .knob("L2", [.filter, .env, .level, .i(1)]),
          .knob("L3", [.filter, .env, .level, .i(2)]),
          .knob("L4", [.filter, .env, .level, .i(3)]),
        ]]),
        .panel("amp", color: 2, [[
          .knob("Level", [.level]),
          .knob("Pan", [.pan]),
          .knob("Rand Pan", [.random, .pan]),
          .knob("Alt Pan", [.alt, .pan]),
          .checkbox("Env Sustain", [.env, .mode]),
        ],[
          XV.Voice.Controller.ampEnv.env,
          .knob("← Velo", [.amp, .env, .velo]),
          .knob("Velo Curve", [.level, .velo, .curve]),
          .knob("Velo→T4", [.amp, .env, .time, .i(3), .velo]),
        ],[
          .knob("Velo→T1", [.amp, .env, .time, .i(0), .velo]),
          .knob("T1", [.amp, .env, .time, .i(0)]),
          .knob("T2", [.amp, .env, .time, .i(1)]),
          .knob("T3", [.amp, .env, .time, .i(2)]),
          .knob("T4", [.amp, .env, .time, .i(3)]),
        ],[
          .knob("Mute Group", [.mute, .group]),
          .knob("L1", [.amp, .env, .level, .i(0)]),
          .knob("L2", [.amp, .env, .level, .i(1)]),
          .knob("L3", [.amp, .env, .level, .i(2)]),
        ]]),
        .panel("out", color: 2, [[
          .select("Out Assign", [.out, .assign]),
          .knob("Dry", [.dry]),
        ],[
          .knob("Chorus", nil, id: [.chorus]),
          .knob("Reverb", nil, id: [.reverb]),
        ]])

      ], effects: [
        XV.Voice.Controller.pitchEnv.effect,
        XV.Voice.Controller.filterEnv.effect,
        XV.Voice.Controller.ampEnv.effect,
        .dimsOn([.filter, .type], id: "filter"),
      ] + XV.Tone.Controller.fxSetup, layout: [
        .row([("wmt",13.5),("out",2.5)]),
        .row([("pitch",5),("filter",6),("amp",5)]),
        .col([("wmt",2),("pitch",4)]),
      ])
    }
    
    static func wmt(config: XV.CtrlConfig) -> PatchController {
      let paths = XV.Rhythm.Tone.params.keys.filter { $0.starts(with: [.wave, .i(0)]) }.map {
        SynthPath($0.suffix(from: 2))
      }

      return .patch(prefix: .index([.wave]), border: 3, [
        .switcher(label: "WMT", ["1","2","3","4"], color: 3),
        .panel("on", color: 3, [[
          .checkbox("On", [.on]),
          .select("Wave Group", nil, id: [.wave, .group]),
          .select("Wave L", nil, id: [.wave, .number, .i(0)]),
          .select("Wave R", nil, id: [.wave, .number, .i(1)]),
          .knob("Gain", [.wave, .gain]),
        ]]),
        .panel("fxm", color: 3, [[
          .checkbox("FXM", [.fxm, .on]),
          .knob("Color", [.fxm, .color]),
          .knob("Depth", [.fxm, .depth]),
        ]]),
        .button("WMT", color: 3),
        .panel("level", color: 3, [[
          .knob("Level", [.level]),
          .knob("Coarse", [.coarse]),
          .knob("Fine", [.fine]),
          .knob("Pan", [.pan]),
          .checkbox("Rand Pan", [.random, .pan]),
          .switsch("Alt Pan", [.alt, .pan]),
          .checkbox("Tempo Sync", [.tempo, .sync]),
        ]]),
        .panel("velo", color: 3, [[
          .knob("Fade→", [.velo, .fade, .lo]),
          .knob("Velo Lo", [.velo, .range, .lo]),
          .knob("Velo Hi", [.velo, .range, .hi]),
          .knob("←Fade", [.velo, .fade, .hi]),
        ]]),
      ], effects: [
        .dimsOn([.fxm, .on], id: "fxm"),
        .editMenu([.button], paths: paths, type: "JDXiDrWMT", init: nil, rand: nil),
        .dimsOn([.on], id: "on"),
        .dimsOn([.on], id: "fxm"),
        .dimsOn([.on], id: "level"),
        .dimsOn([.on], id: "velo"),
      ] + XV.Tone.Controller.wavesSetup(waveGroupOptions: config.waveGroupOptions), layout: [
        .simpleGrid([
          [("switch",4),("on",6),("fxm",3)],
          [("level",7), ("velo",4), ("button",2)],
        ])
      ])
    }
    
    
    static func wmts(config: XV.CtrlConfig) -> PatchController {
      .oneRow(4, child: paletteWmt(config: config))
    }
    
    static func paletteWmt(config: XV.CtrlConfig) -> PatchController {
      .index([.wave], label: [.on], { "WMT \($0 + 1)" }, border: 3, [
        .panel("on", color: 3, [[
          .checkbox("WMT", [.on]),
          .select("Wave Group", nil, id: [.wave, .group]),
          .knob("Gain", [.wave, .gain]),
        ],[
          .select("Wave L", nil, id: [.wave, .number, .i(0)]),
          .select("Wave R", nil, id: [.wave, .number, .i(1)]),
        ]]),
        .panel("fxm", color: 3, [[
          .checkbox("FXM", [.fxm, .on]),
          .knob("Color", [.fxm, .color]),
          .knob("Depth", [.fxm, .depth]),
        ]]),
        .panel("level", color: 3, [[
          .knob("Level", [.level]),
          .knob("Coarse", [.coarse]),
          .knob("Fine", [.fine]),
        ],[
          .knob("Pan", [.pan]),
          .checkbox("Rand Pan", [.random, .pan]),
          .switsch("Alt Pan", [.alt, .pan]),
          .checkbox("Tempo Sync", [.tempo, .sync]),
        ]]),
        .panel("velo", color: 3, [[
          .knob("Fade→", [.velo, .fade, .lo]),
          .knob("Velo Lo", [.velo, .range, .lo]),
          .knob("Velo Hi", [.velo, .range, .hi]),
          .knob("←Fade", [.velo, .fade, .hi]),
        ]]),
      ], effects: [
        .dimsOn([.fxm, .on], id: "fxm"),
        .dimsOn([.on], id: nil),
      ] + XV.Tone.Controller.wavesSetup(waveGroupOptions: config.waveGroupOptions), layout: [
        .grid([
          (row: [("on", 1)], height: 2),
          (row: [("fxm", 1)], height: 1),
          (row: [("level", 1)], height: 2),
          (row: [("velo", 1)], height: 1),
        ])
      ])
    }
    
  }
  
}

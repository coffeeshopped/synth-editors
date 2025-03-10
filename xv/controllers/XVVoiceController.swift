
extension XV.Voice {

  enum Controller {
    
    static func controller(config: XV.CtrlConfig) -> PatchController {
      
      return .paged([
        .switcher(label: nil, ["Common","FX","Ctrls","1","2","3","4", "Pitch", "Filter", "Amp", "LFO", "Extra"], color: 1),
        .panel("on", prefix: [.mix, .tone], color: 1, [[
          .checkbox("Tone 1", [.i(0), .on]),
          .checkbox("2", [.i(1), .on]),
          .checkbox("3", [.i(2), .on]),
          .checkbox("4", [.i(3), .on])
        ]]),
        
      ], effects: [
      ], layout: [
        .grid([
          (row: [("switch", 12), ("on", 4)], height: 1),
          (row: [("page", 1)], height: 8),
        ])
      ], pages: .map([
        [.common], [.fx], [.ctrl],
      ] + 4.map { [.tone, .i($0)] } + [
        [.pitch], [.filter], [.amp], [.lfo], [.extra]
      ], [
        [.common] : common(),
        [.fx] : fxController(-1, config: config),
        [.ctrl] : control(),
        [.tone] : toneAndRange(waveGroupOptions: config.waveGroupOptions, tonePaths: config.voiceTruss.paramKeys()),
        [.pitch] : fourPalettes(pasteType: "PitchPal", pal: palettePitch(waveGroupOptions: config.waveGroupOptions)),
        [.filter] : fourPalettes(pasteType: "FilterPal", pal: paletteFilter()),
        [.amp] : fourPalettes(pasteType: "AmpPal", pal: paletteAmp()),
        [.lfo] : fourPalettes(pasteType: "LFOPal", pal: paletteLFO()),
        [.extra] : fourPalettes(pasteType: "ExtraPal", pal: paletteExtra(), addPrefix: false),
      ]))
    }
    
    static func common() -> PatchController {
      return .patch(color: 1, [
        .panel("cat", prefix: [.common], [[
          .select("Category", [.category]),
        ]]),
        .panel("level", prefix: [.common], [[
          .knob("Level", [.level]),
          .knob("Pan", [.pan]),
          .switsch("Priority", [.priority]),
        ]]),
        .panel("coarse", prefix: [.common], [[
          .knob("Coarse", [.coarse]),
          .knob("Fine", [.fine]),
          .knob("Oct Shift", [.octave, .shift]),
        ]]),
        .panel("stretch", prefix: [.common], [[
          .knob("Stretch Tune", [.stretchTune]),
          .checkbox("Analog Feel", [.analogFeel]),
          .switsch("Mono/Poly", [.poly]),
        ]]),
        .panel("legato", prefix: [.common, .legato], [[
          .checkbox("Legato", []),
          .checkbox("Retrigger", [.retrigger]),
        ]]),
        .panel("clock", prefix: [.common], [[
          .switsch("Clock Src", [.clock, .src]),
          .knob("Tempo", [.tempo]),
        ]]),
        .panel("porta", prefix: [.common, .porta], [[
          .checkbox("Porta", []),
          .switsch("Mode", [.mode]),
          .switsch("Type", [.type]),
          .switsch("Start", [.start]),
          .knob("Time", [.time])
        ]]),
        .panel("out", prefix: [.common], [[
          .select("Out Assign", [.out, .assign]),
        ]]),
        .panel("tmt", [[
          .checkbox("TMT Ctrl", [.common, .tone, .mix]),
          .knob("Bend Up", [.common, .bend, .up]),
          .knob("Bend Down", [.common, .bend, .down]),
          .switsch("TMT Velo", [.mix, .velo])
        ]]),
        .panel("cutoff", prefix: [.common], [[
          .knob("Cutoff", [.cutoff]),
          .knob("Reson", [.reson]),
          .knob("Attack", [.attack]),
          .knob("Release", [.release]),
          .knob("Velo", [.velo])
        ]]),
        .panel("struct1", [[
          .imgSelect("Structure 1/2", [.mix, .structure, .i(0)], w: 200, h: 70, spacing: 12),
          .switsch("Boost", [.mix, .booster, .i(0)]),
        ]]),
        .panel("struct2", [[
          .imgSelect("Structure 3/4", [.mix, .structure, .i(1)], w: 200, h: 70, spacing: 12),
          .switsch("Boost", [.mix, .booster, .i(1)])
        ]])
      ], effects: [
      ], layout: [
        .simpleGrid([
          [("cat", 1.5), ("level", 3), ("coarse", 3), ("stretch", 3)],
          [("legato", 2), ("clock", 3), ("porta", 5), ("out", 1.5)],
          [("tmt", 4), ("cutoff", 5)],
          [("struct1", 1), ("struct2", 1)],
        ])
      ])
    }
    
    static func fxController(_ index: Int, config: XV.CtrlConfig) -> PatchController {
      return .patch([
        .child(XV.FX.Controller.mfx(index: index, config: config), "mfx"),
        .child(XV.FX.Controller.chorus(), "chorus"),
        .child(XV.FX.Controller.reverb(), "reverb"),
      ], layout: [
        .grid([
          (row: [("mfx", 1)], height: 4),
          (row: [("chorus", 1)], height: 1),
          (row: [("reverb", 1)], height: 1),
        ]),
      ])
    }
    
    static func control() -> PatchController {
      let subs: [PatchController] = 4.map { subControl($0) }
      return .patch(4.map {
        .child(subs[$0], "sub\($0)")
      }, layout: [
        .simpleGrid(4.map { [("sub\($0)", 1)] }),
      ])
    }
    
    static func subControl(_ ctrl: Int) -> PatchController {
      let ctrlPrefix: SynthPath = [.common, .mtrx, .ctrl, .i(ctrl)]
      
      let dims: [PatchController.Effect] = 4.flatMap { dest in
        let panelKey = "dest\(dest)"
        let destPath: SynthPath = ctrlPrefix + [.dest, .i(dest)]
        return [.dimsOn(destPath, id: panelKey)] + 4.map { tone in
          let tonePath: SynthPath = [.tone, .i(tone), .ctrl, .i(ctrl), .on, .i(dest)]
          return .dimsOn(tonePath, id: tonePath)
        }
      }
      
      let destPanels: [PatchController.Builder] = 4.map { dest in
        let destPath: SynthPath = ctrlPrefix + [.dest, .i(dest)]
        let onSuffix: SynthPath = [.ctrl, .i(ctrl), .on, .i(dest)]
        let panelKey = "dest\(dest)"
        return .panel(panelKey, [[
          .select("Dest \(dest + 1)", destPath),
          .switsch("Tone 1", [.tone, .i(0)] + onSuffix),
          .switsch("Tone 2", [.tone, .i(1)] + onSuffix),
        ],[
          .knob("Amount", ctrlPrefix + [.amt, .i(dest)]),
          .switsch("Tone 3", [.tone, .i(2)] + onSuffix),
          .switsch("Tone 4", [.tone, .i(3)] + onSuffix)
        ]])
      }
      
      return .patch(color: 1, border: 1, [
        .panel("src", [[
          .select("Src \(ctrl + 1)", ctrlPrefix + [.src]),
        ]]),
      ] + destPanels, effects: dims, layout: [
        .simpleGrid([
          [("src", 1.5), ("dest0", 3.5),("dest1", 3.5), ("dest2", 3.5), ("dest3", 3.5)],
        ]),
      ])
    }
    
    static func toneAndRange(waveGroupOptions: [Int:String], tonePaths: [SynthPath]) -> PatchController {
      return .patch([
        .child(tone(waveGroupOptions: waveGroupOptions, tonePaths: tonePaths), "tone"),
        .child(toneRange(), "range"),
        .panel("space", [[]]),
      ], effects: [
        .indexChange({ [
          .setIndex("tone", $0),
          .setIndex("range", $0),
        ] }),
        .dimsOn(fullPath: { [.mix, .tone, .i($0), .on] }, id: nil),
      ], layout: [
        .grid([
          (row: [("tone",1)], height: 7),
          (row: [("range", 8), ("space", 8)], height: 1),
        ])
      ])
    }
    
    static func toneRange() -> PatchController {
      return .patch(prefix: .index([.mix, .tone]), color: 2, [
        .panel("key", [[
          .knob("Fade→", [.key, .fade, .lo]),
          .knob("Key Lo", [.key, .lo]),
          .knob("Key Hi", [.key, .hi]),
          .knob("←Fade", [.key, .fade, .hi]),
        ]]),
        .panel("velo", [[
          .knob("Fade→", [.velo, .fade, .lo]),
          .knob("Velo Lo", [.velo, .lo]),
          .knob("Velo Hi", [.velo, .hi]),
          .knob("←Fade", [.velo, .fade, .hi])
        ]]),
      ], layout: [
        .simpleGrid([[("key", 4), ("velo", 4)]]),
      ])
    }
    
    
    static func lfo() -> PatchController {
      return .patch(prefix: .index([.lfo]), color: 2, [
        .grid([[
          .switcher(label: "LFO", ["1","2"]),
          .select("Wave", [.wave]),
          .knob("Rate", [.rate]),
          .switsch("Offset", [.offset]),
          .knob("Rate Detune", [.rate, .detune]),
          .knob("Delay Time", [.delay]),
          .knob("Delay Keyfollow", [.delay, .keyTrk]),
          .switsch("Fade Mode", [.fade, .mode]),
          .knob("Fade Time", [.fade, .time]),
          .checkbox("Key Trigger", [.key, .trigger]),
          .knob("Pitch", [.pitch]),
          .knob("Filter", [.filter]),
          .knob("Amp", [.amp]),
          .knob("Pan", [.pan])
        ]])
      ])
    }
    
    static let pitchEnv = XV.Tone.Controller.envSetup("Pitch", prefix: [.pitch, .env], bipolar: true, levelSteps: 4, startLevel: true)
    static let filterEnv = XV.Tone.Controller.envSetup("Filter", prefix: [.filter, .env], bipolar: false, levelSteps: 4, startLevel: true)
    static let ampEnv = XV.Tone.Controller.envSetup("Amp", prefix: [.amp, .env], bipolar: false, levelSteps: 3, startLevel: false)
    
    static func tone(waveGroupOptions: [Int:String], tonePaths: [SynthPath]) -> PatchController {      
      return .patch(prefix: .index([.tone]), [
        .child(lfo(), "lfo"),
        .panel("wave", color: 1, [[
          .select("Wave Group", nil, id: [.wave, .group]),
          .select("Wave L", nil, id: [.wave, .number, .i(0)]),
          .select("Wave R", nil, id: [.wave, .number, .i(1)]),
          .knob("Gain", [.wave, .gain]),
          .checkbox("Tempo Sync", [.tempo, .sync]),
        ]]),
        .panel("fxm", color: 1, [[
          .checkbox("FXM", [.fxm, .on]),
          .knob("Color", [.fxm, .color]),
          .knob("Depth", [.fxm, .depth])
        ]]),
        .panel("send", color: 1, [[
          .knob("Dry", [.dry]),
          .knob("Chorus", nil, id: [.chorus]),
          .knob("Reverb", nil, id: [.reverb]),
          .select("Out Assign", [.out, .assign])
        ]]),
        .panel("pitch", color: 1, [[
          .knob("Coarse", [.coarse]),
          .knob("Fine", [.fine]),
          .knob("Random Pitch", [.random, .pitch]),
          .knob("Key→Pitch", [.pitch, .keyTrk]),
          .knob("Key→Env T", [.pitch, .env, .time, .keyTrk]),
        ],[
          pitchEnv.env,
          .knob("Env Depth", [.pitch, .env, .depth]),
          .knob("Velo→Env", [.pitch, .env, .velo]),
          .knob("Velo→T4", [.pitch, .env, .velo, .time, .i(3)]),
        ],[
          .knob("Velo→T1", [.pitch, .env, .velo, .time, .i(0)]),
        ] + 4.map { .knob("T\($0 + 1)", [.pitch, .env, .time, .i($0)])},
                                   5.map { .knob("L\($0)", [.pitch, .env, .level, .i($0 - 1)])},
        ]),
        .panel("filter", color: 1, [[
          .select("Type", [.filter, .type]),
          .knob("Cutoff", [.cutoff]),
          .knob("← Key", [.cutoff, .keyTrk]),
          .knob("← Velo", [.cutoff, .velo]),
          .knob("Velo Curve", [.cutoff, .velo, .curve]),
          .knob("Reson", [.reson]),
        ],[
          filterEnv.env,
          .knob("Env Depth", [.filter, .env, .depth]),
          .knob("Velo→Env", [.filter, .env, .velo]),
          .knob("Velo→T4", [.filter, .env, .velo, .time, .i(3)]),
          .knob("Velo ↑", [.reson, .velo]),
        ],[
          .knob("Velo→T1", [.filter, .env, .velo, .time, .i(0)]),
        ] + 4.map { .knob("T\($0 + 1)", [.filter, .env, .time, .i($0)]) } + [
          .knob("Env Velo Crv", [.filter, .env, .velo, .curve]),
        ],
                                    5.map { .knob("L\($0)", [.filter, .env, .level, .i($0 - 1)]) } +
                                    [
                                      .knob("Key→Env T", [.filter, .env, .time, .keyTrk]),
                                    ]]),
        .panel("amp", color: 1, [[
          .knob("Level", [.level]),
          .switsch("Bias Dir", [.bias, .direction]),
          .knob("Bias Pt", [.bias, .pt]),
          .knob("Bias Level", [.bias, .level]),
        ],[
          ampEnv.env,
          .knob("Velo", [.amp, .env, .velo]),
          .knob("Velo Curve", [.amp, .env, .velo, .curve]),
          .knob("Velo→T4", [.amp, .env, .velo, .time, .i(3)]),
        ],[
          .knob("Velo→T1", [.amp, .env, .velo, .time, .i(0)]),
        ] + 4.map { .knob("T\($0 + 1)", [.amp, .env, .time, .i($0)]) }, [
          .spacer(2),
        ] + 3.map { .knob("L\($0 + 1)", [.amp, .env, .level, .i($0)]) } + [
          .knob("Key→Env T", [.amp, .env, .time, .keyTrk]),
        ]]),
        .panel("delay", color: 1, [[
          .switsch("Delay", [.delay, .mode]),
          .knob("Time", [.delay, .time])
        ]]),
        .panel("rcv", color: 1, [[
          .checkbox("Rx Bend", [.rcv, .bend]),
          .checkbox("Rx Express", [.rcv, .expression]),
          .checkbox("Rx Hold-1", [.rcv, .hold]),
          .checkbox("Rx Pan", [.rcv, .pan]),
          .checkbox("Redamper", [.rcv, .redamper])
        ]]),
        .panel("pan", color: 1, [[
          .knob("Pan", [.pan]),
          .knob("Key→Pan", [.pan, .keyTrk]),
          .knob("Random Pan", [.pan, .random]),
          .knob("Alt Pan", [.pan, .alt])
        ]]),
        .button("Tone"),
      ], effects: [
        pitchEnv.effect,
        filterEnv.effect,
        ampEnv.effect,
        .editMenu([.button], paths: tonePaths, type: "XV5050VoiceTone", init: nil, rand: nil),
        .dimsOn([.filter, .type], id: "filter"),
      ] + XV.Tone.Controller.wavesSetup(waveGroupOptions: waveGroupOptions) + XV.Tone.Controller.fxSetup, layout: [
        .row([("wave", 6.5), ("fxm", 3), ("send", 4.5), ("button", 2)]),
        .row([("pitch", 5), ("filter", 6), ("amp", 5)]),
        .row([("delay", 2.5), ("rcv", 5), ("pan", 4)]),
        .row([("lfo", 1)]),
        .col([("wave",1),("pitch",4),("delay",1),("lfo",1)]),
      ])
    }
    
    static func palettePitch(waveGroupOptions: [Int:String]) -> PatchController {
      return .patch(color: 1, [
        .panel("wave", [[
          .select("Wave Group", nil, id: [.wave, .group]),
          .knob("Gain", [.wave, .gain]),
        ],[
          .select("Wave L", nil, id: [.wave, .number, .i(0)]),
          .select("Wave R", nil, id: [.wave, .number, .i(1)]),
        ]]),
        .panel("lfo", [[
          .knob("LFO 1", [.lfo, .i(0), .pitch]),
        ],[
          .knob("LFO 2", [.lfo, .i(1), .pitch]),
        ]]),
        .panel("pitch", [[
          .knob("Coarse", [.coarse]),
          .knob("Fine", [.fine]),
          .knob("Random", [.random, .pitch]),
          .knob("Key→Pitch", [.pitch, .keyTrk]),
        ],[
          pitchEnv.env,
          .knob("Env Depth", [.pitch, .env, .depth]),
          .knob("← Velo", [.pitch, .env, .velo]),
        ],
                         4.map { .knob("T\($0 + 1)", [.pitch, .env, .time, .i($0)])},
                         4.map { .knob("L\($0 + 1)", [.pitch, .env, .level, .i($0)])},
                         [
                          .knob("L0", [.pitch, .env, .level, .i(-1)]),
                          .knob("Velo→T1", [.pitch, .env, .velo, .time, .i(0)]),
                          .knob("Velo→T4", [.pitch, .env, .velo, .time, .i(3)]),
                          .knob("Key→Env T", [.pitch, .env, .time, .keyTrk]),
                         ]])
      ], effects: XV.Tone.Controller.wavesSetup(waveGroupOptions: waveGroupOptions) + [
        pitchEnv.effect,
      ], layout: [
        .grid([
          (row: [("wave", 3), ("lfo", 1)], height: 2),
          (row: [("pitch", 1)], height: 5),
        ])
      ])
    }
    
    static func paletteFilter() -> PatchController {
      return .patch(color: 1, [
        .panel("filter", [[
          .select("Type", [.filter, .type]),
          .knob("Reson", [.reson]),
          .knob("← Velo", [.reson, .velo]),
        ],[
          .knob("Cutoff", [.cutoff]),
          .knob("← Key", [.cutoff, .keyTrk]),
          .knob("← Velo", [.cutoff, .velo]),
          .knob("Velo Crv", [.cutoff, .velo, .curve]),
        ],[
          .knob("LFO 1", [.lfo, .i(0), .filter]),
          .knob("LFO 2", [.lfo, .i(1), .filter]),
          .knob("Env Velo Crv", [.filter, .env, .velo, .curve]),
        ],[
          filterEnv.env,
          .knob("Env Depth", [.filter, .env, .depth]),
          .knob("← Velo", [.filter, .env, .velo]),
        ],
                          4.map { .knob("T\($0 + 1)", [.filter, .env, .time, .i($0)]) },
                          4.map { .knob("L\($0 + 1)", [.filter, .env, .level, .i($0)]) },
                          [
                            .knob("L0", [.filter, .env, .level, .i(-1)]),
                            .knob("Velo→T1", [.filter, .env, .velo, .time, .i(0)]),
                            .knob("Velo→T4", [.filter, .env, .velo, .time, .i(3)]),
                            .knob("Key→Env T", [.filter, .env, .time, .keyTrk]),
                          ]]),
      ], effects: [
        filterEnv.effect,
        .dimsOn([.filter, .type], id: "filter"),
      ], layout: [
        .grid([
          (row: [("filter", 1)], height: 2),
        ])
      ])
    }
    
    static func paletteAmp() -> PatchController {
      
      return .patch([
        .panel("con", color: 1, [[]]),
        .panel("amp", color: 1, [[
          .knob("Level", [.level]),
          .switsch("Bias Dir", [.bias, .direction]),
          .knob("Bias Pt", [.bias, .pt]),
          .knob("Bias Level", [.bias, .level]),
        ],[
          ampEnv.env,
          .knob("Velo", [.amp, .env, .velo]),
          .knob("Velo Curve", [.amp, .env, .velo, .curve]),
        ],
                                 4.map { .knob("T\($0 + 1)", [.amp, .env, .time, .i($0)]) },
                                 3.map { .knob("L\($0 + 1)", [.amp, .env, .level, .i($0)]) }
                                 + [
                                  .spacer(2),
                                 ],[
                                  .knob("Velo→T1", [.amp, .env, .velo, .time, .i(0)]),
                                  .knob("Velo→T4", [.amp, .env, .velo, .time, .i(3)]),
                                  .knob("Key→Env T", [.amp, .env, .time, .keyTrk])
                                 ]]),
        .panel("lfo", color: 1, [[
          .knob("LFO 1", [.lfo, .i(0), .amp]),
        ],[
          .knob("LFO 2", [.lfo, .i(1), .amp]),
        ]]),
        .panel("pan", color: 2, [[
          .knob("Pan", [.pan]),
          .knob("Key→Pan", [.pan, .keyTrk]),
          .knob("Random Pan", [.pan, .random]),
        ],[
          .knob("Alt Pan", [.pan, .alt]),
          .knob("LFO 1", [.lfo, .i(0), .pan]),
          .knob("LFO 2", [.lfo, .i(1), .pan]),
        ]]),
      ], effects: [
        ampEnv.effect,
      ], layout: [
        .grid([
          (row: [("amp", 1)], height: 5),
          (row: [("lfo", 1), ("pan", 3)], height: 2),
        ]),
        .eq(["con", "amp"], .leading),
        .eq(["con", "amp"], .top),
        .eq(["con", "lfo"], .trailing),
        .eq(["con", "lfo"], .bottom),
      ])
    }
    
    static func paletteLFO() -> PatchController {
      let lfo: PatchController = .index([.lfo], label: [.wave], { "LFO \($0 + 1)" }, [
        .grid([[
          .select("LFO", [.wave]),
          .knob("Rate", [.rate]),
          .switsch("Offset", [.offset]),
          .knob("Rate Detune", [.rate, .detune]),
        ],[
          .knob("Delay Time", [.delay]),
          .knob("Delay Keyfollow", [.delay, .keyTrk]),
          .switsch("Fade Mode", [.fade, .mode]),
          .knob("Fade Time", [.fade, .time]),
          .checkbox("Key Trigger", [.key, .trigger]),
        ],[
          .knob("Pitch", [.pitch]),
          .knob("Filter", [.filter]),
          .knob("Amp", [.amp]),
          .knob("Pan", [.pan]),
        ]])
      ])
      
      return .patch(color: 1, border: 1, [
        .children(2, "lfo", lfo)
      ], layout: [
        .simpleGrid([
          [("lfo0", 1)],
          [("lfo1", 1)],
        ])
      ])
    }
    
    static func paletteExtra() -> PatchController {
      
      let tone: PatchController = .patch(prefix: .index([.tone]), color: 1, [
        .panel("fxm", [[
          .checkbox("FXM", [.fxm, .on]),
          .knob("Color", [.fxm, .color]),
          .knob("Depth", [.fxm, .depth])
        ]]),
        .panel("send", [[
          .knob("Dry", [.dry]),
          .knob("Chorus", nil, id: [.chorus]),
          .knob("Reverb", nil, id: [.reverb]),
        ],[
          .select("Out Assign", [.out, .assign]),
        ]]),
        .panel("delay", [[
          .switsch("Delay", [.delay, .mode]),
          .knob("Time", [.delay, .time])
        ]]),
      ], effects: XV.Tone.Controller.fxSetup, layout: [
        .grid([
          (row: [("fxm", 1)], height: 1),
          (row: [("send", 1)], height: 2),
          (row: [("delay", 1)], height: 1),
        ])
      ])
      
      let range: PatchController = .patch(prefix: .index([.mix, .tone]), color: 2, [
        .panel("key", [[
          .knob("Fade→", [.key, .fade, .lo]),
          .knob("Key Lo", [.key, .lo]),
          .knob("Key Hi", [.key, .hi]),
          .knob("←Fade", [.key, .fade, .hi]),
        ]]),
        .panel("velo", [[
          .knob("Fade→", [.velo, .fade, .lo]),
          .knob("Velo Lo", [.velo, .lo]),
          .knob("Velo Hi", [.velo, .hi]),
          .knob("←Fade", [.velo, .fade, .hi])
        ]]),
      ], effects: [
      ], layout: [
        .simpleGrid([[("key", 4)],[("velo", 4)]])
      ])
      
      return .patch(border: 1, [
        .child(tone, "tone"),
        .child(range, "range")
      ], effects: [
        .indexChange({ [
          .setIndex("tone", $0),
          .setIndex("range", $0),
        ] })
      ], layout: [
        .grid([
          (row: [("tone", 1)], height: 3),
          (row: [("range", 1)], height: 2),
        ])
      ])
    }
    
    static func fourPalettes(pasteType: String, pal: PatchController, addPrefix: Bool = true) -> PatchController {
      .palettes(pal, 4, addPrefix ? [.tone] : nil, "Tone", pasteType: pasteType, effects: [.dimsOn(fullPath: { [.mix, .tone, .i($0), .on] }, id: nil)])
    }
    
  }
  
}

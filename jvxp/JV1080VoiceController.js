
extension JV1080.Voice {
  
  enum Controller {
    
    static func controller(showClockSource: Bool = false, showCategory: Bool = false, perfPart: Int? = nil) -> PatchController {
      
      return .paged([
        .switcher(label: nil, ["Common","1","2","3","4", "Pitch", "Filter", "Amp", "LFO", "Pan/Out"], color: 1),
        .panel("on", color: 1, [[
          .checkbox("Tone 1", [.tone, .i(0), .on]),
          .checkbox("2", [.tone, .i(1), .on]),
          .checkbox("3", [.tone, .i(2), .on]),
          .checkbox("4", [.tone, .i(3), .on]),
        ]]),
      ], effects: [
      ], layout: [
        .row([("switch", 12), ("on", 4)]),
        .row([("page",1)]),
        .col([("switch",1),("page",8)]),
      ], pages: .map([
        [.common],
        [.tone, .i(0)],
        [.tone, .i(1)],
        [.tone, .i(2)],
        [.tone, .i(3)],
        [.pitch],
        [.filter],
        [.amp],
        [.lfo],
        [.pan],
      ], [
        [.common] : common(showClockSource: showClockSource, showCategory: showCategory, perfPart: perfPart),
        [.tone] : tone(),
        [.pitch] : fourPalettes(pasteType: "JVPitch", pal: palettePitchWave()),
        [.filter] : fourPalettes(pasteType: "JVFilter", pal: paletteFilter()),
        [.amp] : fourPalettes(pasteType: "JVAmp", pal: paletteAmp()),
        [.lfo] : fourPalettes(pasteType: "JVLFO", pal: paletteLFO()),
        [.pan] : fourPalettes(pasteType: "JVPan", pal: palettePanOut()),
      ]))
    }
    
    static func common(showClockSource: Bool = false, showCategory: Bool = false, perfPart: Int? = nil) -> PatchController {
      
      var effects = [PatchController.Effect]()
      
      if !showClockSource {
        effects.append(.setup([.dimPanel(true, "clock", dimAlpha: 0)]))
      }
      
      if let perfPart = perfPart {
        effects.append(.setup([
          .dimPanel(true, "chorus"),
          .dimPanel(true, "reverb"),
        ]))
        effects.append(.paramChange([.common, .fx, .src], fnWithContext: { param, state, locals in
          [.dimPanel(param.parm - 1 != perfPart, "fx")]
        }))
      }
            
      return .patch(prefix: .fixed([.common]), [
        .child(fx(), "fx"),
        .panel("tempo", color: 1, [[
          .knob("Tempo", [.tempo]),
          .knob("Level", [.level]),
          .knob("Pan", [.pan]),
          .checkbox("Mono", [.mono]),
          .checkbox("Legato", [.legato]),
          .knob("Analog Feel", [.analogFeel]),
        ],[
          .knob("Oct Shift", [.octave, .shift]),
          .knob("Stretch Tune", [.stretchTune]),
          .switsch("Voice Priority", [.voice, .priority]),
          .checkbox("Velo Range", [.velo, .range, .on]),
          .knob("Bend Up", [.bend, .up]),
          .knob("Bend Down", [.bend, .down]),
        ]]),
        .panel("porta", color: 1, [[
          .checkbox("Porta", [.porta]),
          .knob("Time", [.porta, .time]),
          .checkbox("Legato", [.porta, .legato]),
        ],[
          .switsch("Type", [.porta, .type]),
          .switsch("Start", [.porta, .start]),
        ]]),
        .panel("ctrl", color: 1, [[
          .select("Ctrl Src 2", [.patch, .ctrl, .src, .i(1)]),
        ],[
          .select("Ctrl Src 3", [.patch, .ctrl, .src, .i(2)]),
        ]]),
        .panel("hold", color: 1, [[
          .label("Hold/Peak"),
          .switsch("FX Ctrl", [.fx, .ctrl, .holdPeak]),
        ],[
          .switsch("Ctrl 1", [.ctrl, .i(0), .holdPeak]),
          .switsch("Ctrl 2", [.ctrl, .i(1), .holdPeak]),
          .switsch("Ctrl 3", [.ctrl, .i(2), .holdPeak]),
        ]]),
        .panel("struct", color: 1, [[
          .imgSelect("Structure 1/2", [.structure, .i(0)], w: 200, h: 70),
          .knob("Boost 1/2", [.booster, .i(0)]),
        ],[
          .imgSelect("Structure 3/4", [.structure, .i(1)], w: 200, h: 70),
          .knob("Boost 3/4", [.booster, .i(1)]),
        ]]),
        .panel("chorus", color: 1, [[
          .knob("Chorus Level", [.chorus, .level]),
          .knob("Rate", [.chorus, .rate]),
          .knob("Depth", [.chorus, .depth]),
          .knob("Pre-Delay", [.chorus, .predelay]),
          .knob("Feedback", [.chorus, .feedback]),
          .switsch("Output", [.chorus, .out, .assign]),
        ]]),
        .panel("reverb", color: 1, [[
          .select("Reverb", [.reverb, .type]),
          .knob("Level", [.reverb, .level]),
          .knob("Time", [.reverb, .time]),
          .select("HF Damp", [.reverb, .hfdamp]),
          .knob("Feedback", [.reverb, .feedback]),
        ]]),
        .panel("clock", color: 1, [
          (showCategory ? [.select("Category", [.category])] : []) +
          [.switsch("Clock Src", [.clock, .src])]
        ]),
      ], effects: effects, layout: [
        .row([("tempo",6),("porta",3),("ctrl",1),("hold",5)]),
        .row([("fx",12), ("struct",4)], opts: [.alignAllTop]),
        .rowPart([("clock", 3), ("chorus",6),("reverb",5)]),
        .col([("tempo",2),("fx",2),("clock",1)]),
        .eq(["reverb","struct"], .bottom),
        .eq(["fx","reverb"], .trailing),
      ])
    }
    
    static func fx() -> PatchController {
      return .patch(prefix: .fixed([.fx]), color: 2, [
        .panel("fx", [
          [.select("FX Type", [.type])] + 5.map { .knob("\($0)", nil, id: [.param, .i($0)]) },
          (5..<12).map { .knob("\($0)", nil, id: [.param, .i($0)]) }
        ]),
        .panel("fxOut", [[
          .switsch("FX Output", [.out, .assign]),
          .knob("FX Level", [.out, .level]),
          .knob("→Chorus", [.chorus]),
          .knob("→Reverb", [.reverb]),
        ],[
          .select("Ctrl Src 1", [.ctrl, .src, .i(0)]),
          .knob("Amt 1", [.ctrl, .depth, .i(0)]),
          .select("Ctrl Src 2", [.ctrl, .src, .i(1)]),
          .knob("Amt 2", [.ctrl, .depth, .i(1)]),
        ]]),
      ], effects: 12.flatMap { [
        .basicControlChange([.param, .i($0)]),
        .basicPatchChange([.param, .i($0)]),
      ] } + [
        .patchChange([.type], { value in
          let info = JV1080.Voice.Common.fxParams[value]
          return 12.flatMap {
            let path: SynthPath = [.param, .i($0)]
            guard let pair = info[$0] else {
              return [.dimItem(true, path, dimAlpha: 0)]
            }
            return [
              .setCtrlLabel(path, pair.0),
              .configCtrl(path, .param(pair.1)),
              .dimItem(false, path),
            ]
          }
        })
      ], layout: [
        .simpleGrid([[("fx", 7), ("fxOut", 5)]]),
      ])
    }
    
    static func tone() -> PatchController {
      let allPaths = [SynthPath](JV1080.Voice.Tone.params.keys)
      
      return .patch(prefix: .index([.tone]), [
        .child(wave(), "wave", color: 1),
        .child(pitch(), "pitch", color: 1),
        .child(filter(), "filter", color: 2),
        .child(amp(), "amp", color: 3),
        .child(lfo, "lfo", color: 1),
        .child(control, "ctrl", color: 1),
        .panel("fxm", color: 1, [[
          .checkbox("FXM", [.fxm, .on]),
          .knob("Color", [.fxm, .color]),
          .knob("Depth", [.fxm, .depth]),
        ]]),
        .panel("delay", color: 1, [[
          .select("Delay", [.delay, .mode]),
          .knob("Time", [.delay, .time]),
        ]]),
        .button("Tone", color: 1),
        .panel("range", color: 1, [[
          .knob("Velo X Depth", [.velo, .fade, .depth]),
          .knob("Velo Range L", [.velo, .range, .lo]),
          .knob("Velo Range U", [.velo, .range, .hi]),
          .knob("Key Range L", [.key, .range, .lo]),
          .knob("Key Range U", [.key, .range, .hi]),
        ]]),
        .panel("rcv", color: 1, [[
          .knob("Redamp Ctl", [.redamper, .ctrl]),
          .checkbox("Volume Ctl", [.volume, .ctrl]),
          .checkbox("Hold-1 Ctl", [.hold, .ctrl]),
          .checkbox("Bender Ctl", [.bend, .ctrl]),
          .checkbox("Pan Ctl", [.pan, .ctrl])]
        ]),
        .panel("pan", color: 3, [[
          .knob("Pan", [.pan]),
          .knob("Key→Pan", [.pan, .keyTrk]),
          .knob("Random Pan", [.random, .pan]),
        ],[
          .knob("Alt Pan", [.alt, .pan]),
          .knob("LFO 1", [.lfo, .i(0), .pan]),
          .knob("LFO 2", [.lfo, .i(1), .pan]),
        ]]),
        .panel("out", color: 3, [[
          .select("Output", [.out, .assign]),
          .knob("Level", [.out, .level]),
        ],[
          .knob("Chorus", [.chorus]),
          .knob("Reverb", [.reverb]),
        ]]),
      ], effects: [
        .dimsOn([.on], id: nil),
        .editMenu([.button], paths: allPaths, type: "JV1080Tone", init: nil, rand: nil),
      ], layout: [
        .row([("wave",5),("fxm",3),("delay",2),("button",1)]),
        .row([("pitch",5),("filter",6),("amp",5)]),
        .row([("lfo",5),("range",5),("pan",3),("out",2)], opts: [.alignAllTop]),
        .row([("ctrl",13)]),
        .col([("wave",1),("pitch",4),("lfo",2),("ctrl",1)]),
        .colPart([("range",1),("rcv",1)], opts: [.alignAllLeading,.alignAllTrailing]),
        .eq(["lfo","rcv","pan","out"], .bottom),
      ])
      
//      override func randomize(_ sender: Any?) {
//        pushPatchChange(.replace(JV1080TonePatch.random()))
//      }
    }
    
    static func wave() -> PatchController {
      
      return .patch([
        .grid([[
          .select("Wave Group", nil, id: [.wave, .group]),
          .select("Wave Number", nil, id: [.wave, .number]),
          .knob("Wave Gain", [.wave, .gain]),
        ]]),
      ], effects: [
        // wave group
        .setup([
          .configCtrl([.wave, .group], .param(OptionsParam(options: SRJVBoard.boardNameOptions <<< [
            -1 : "Int-A",
             0 : "Int-B",
          ]))),
        ]),
        .controlChange([.wave, .group], { state, locals in
          let v = locals[[.wave, .group]] ?? 0
          return [
            [.wave, .group] : v < 1 ? 0 : 2,
            // int-a is 1, int-b is 2
            [.wave, .group, .id] : v < 1 ? v + 2 : v
          ]
        }),
        .patchChange(paths: [[.wave, .group], [.wave, .group, .id]], { values in
          guard let group = values[[.wave, .group]],
            let groupId = values[[.wave, .group, .id]] else { return [] }
          let options: [Int:String]
          if group == 0 {
            options = groupId == 1 ? JV1080.Voice.Tone.intAWaveOptions : JV1080.Voice.Tone.intBWaveOptions
          }
          else if let waves = SRJVBoard.boards[groupId]?.waves {
            options = OptionsParam.makeOptions(waves)
          }
          else {
            options = JV1080.Voice.Tone.blankWaveOptions
          }
          
          return [
            .configCtrl([.wave, .number], .param(OptionsParam(options: options))),
            .setValue([.wave, .group], group == 0 ? groupId - 2 : groupId),
          ]
        }),
        // wave number
        .basicControlChange([.wave, .number]),
        .basicPatchChange([.wave, .number]),
      ])
    }
    
    static func pitch() -> PatchController {
      let env = pitchEnvs()
      return .patch([
        .grid([[
          .knob("Coarse", [.coarse]),
          .knob("Fine", [.fine]),
          .knob("Random Amt", [.random, .pitch]),
          .knob("Key→Pitch", [.pitch, .keyTrk]),
          .knob("LFO 1", [.lfo, .i(0), .pitch]),
          .knob("LFO 2", [.lfo, .i(1), .pitch]),
        ],[
          env.env,
          .knob("Env→Pitch", [.pitch, .env, .depth]),
          .knob("Key→Env Time", [.pitch, .env, .time, .keyTrk]),
          .knob("Velo→Env", [.pitch, .env, .velo, .sens]),
        ],[
          .knob("T1", [.pitch, .env, .time, .i(0)]),
          .knob("T2", [.pitch, .env, .time, .i(1)]),
          .knob("T3", [.pitch, .env, .time, .i(2)]),
          .knob("T4", [.pitch, .env, .time, .i(3)]),
          .knob("Velo→T1", [.pitch, .env, .velo, .time, .i(0)]),
        ],[
          .knob("L1", [.pitch, .env, .level, .i(0)]),
          .knob("L2", [.pitch, .env, .level, .i(1)]),
          .knob("L3", [.pitch, .env, .level, .i(2)]),
          .knob("L4", [.pitch, .env, .level, .i(3)]),
          .knob("Velo→T4", [.pitch, .env, .velo, .time, .i(3)]),
        ]])
      ], effects: [env.effect])
    }
    
    static func pitchEnvs() -> (env: PatchController.PanelItem, effect: PatchController.Effect) {
      let env: PatchController.PanelItem = .display(.timeLevelEnv(pointCount: 4, sustain: 2, bipolar: true), "Pitch", 4.map { .unit([.pitch, .env, .time, .i($0)], dest: [.time, .i($0)]) } + 4.map { .src([.pitch, .env, .level, .i($0)], dest: [.level, .i($0)], { ($0 - 63) / 63 }) }, id: [.env])
      let effect: PatchController.Effect = .editMenu([.env], paths: [
        [.pitch, .env, .time, .i(0)],
       [.pitch, .env, .time, .i(1)],
       [.pitch, .env, .time, .i(2)],
       [.pitch, .env, .time, .i(3)],
       [.pitch, .env, .level, .i(0)],
       [.pitch, .env, .level, .i(1)],
       [.pitch, .env, .level, .i(2)],
       [.pitch, .env, .level, .i(3)],
      ], type: "JV1080RateLevelEnvelope", init: nil, rand: nil)
      return (env, effect)
    }
    
    
    static func filter() -> PatchController {
      let env = filterEnvs()
      
      return .patch([
        .grid([[
          .select("Filter", [.filter, .type]),
          .knob("Cutoff", [.cutoff]),
          .knob("Reson", [.reson]),
          .knob("LFO 1", [.lfo, .i(0), .filter]),
          .knob("LFO 2", [.lfo, .i(1), .filter]),
        ],[
          env.env,
          .knob("Env→Cutoff", [.filter, .env, .depth]),
          .knob("Key→Env Time", [.filter, .env, .time, .keyTrk]),
          .knob("Velo→Env", [.filter, .env, .velo, .sens]),
          .knob("Key→Cutoff", [.cutoff, .keyTrk]),
        ],[
          .knob("T1", [.filter, .env, .time, .i(0)]),
          .knob("T2", [.filter, .env, .time, .i(1)]),
          .knob("T3", [.filter, .env, .time, .i(2)]),
          .knob("T4", [.filter, .env, .time, .i(3)]),
          .knob("Velo→T1", [.filter, .env, .velo, .time, .i(0)]),
          .knob("Velo→Reson", [.reson, .velo, .sens]),
        ],[
          .knob("L1", [.filter, .env, .level, .i(0)]),
          .knob("L2", [.filter, .env, .level, .i(1)]),
          .knob("L3", [.filter, .env, .level, .i(2)]),
          .knob("L4", [.filter, .env, .level, .i(3)]),
          .knob("Velo→T4", [.filter, .env, .velo, .time, .i(3)]),
          .knob("Env Velo Crv", [.filter, .env, .velo, .curve]),
        ]]),
      ], effects: [env.effect])
    }
    
    static func filterEnvs() -> (env: PatchController.PanelItem, effect: PatchController.Effect) {
      let env: PatchController.PanelItem = .display(.timeLevelEnv(pointCount: 4, sustain: 2, bipolar: false), "Filter", 4.map { .unit([.filter, .env, .time, .i($0)], dest: [.time, .i($0)]) } + 4.map { .unit([.filter, .env, .level, .i($0)], dest: [.level, .i($0)]) }, id: [.env])
      let effect: PatchController.Effect = .editMenu([.env], paths: [
        [.filter, .env, .time, .i(0)],
       [.filter, .env, .time, .i(1)],
       [.filter, .env, .time, .i(2)],
       [.filter, .env, .time, .i(3)],
       [.filter, .env, .level, .i(0)],
       [.filter, .env, .level, .i(1)],
       [.filter, .env, .level, .i(2)],
       [.filter, .env, .level, .i(3)],
      ], type: "JV1080RateLevelEnvelope", init: nil, rand: nil)
      return (env, effect)
    }
    
    static func amp() -> PatchController {
      let env = ampEnvs()

      return .patch([
        .grid([[
          .switsch("Bias Dir", [.bias, .direction]),
          .knob("Bias Pt", [.bias, .pt]),
          .knob("Bias Level", [.bias, .level]),
          .knob("LFO 1", [.lfo, .i(0), .amp]),
          .knob("LFO 2", [.lfo, .i(1), .amp]),
        ],[
          env.env,
          .knob("Env Velo Crv", [.amp, .env, .velo, .curve]),
          .knob("Key→Env Time", [.amp, .env, .time, .keyTrk]),
          .knob("Velo→Env", [.amp, .env, .velo, .sens]),
        ],[
          .knob("T1", [.amp, .env, .time, .i(0)]),
          .knob("T2", [.amp, .env, .time, .i(1)]),
          .knob("T3", [.amp, .env, .time, .i(2)]),
          .knob("T4", [.amp, .env, .time, .i(3)]),
          .knob("Velo→T1", [.amp, .env, .velo, .time, .i(0)]),
        ],[
          .knob("L1", [.amp, .env, .level, .i(0)]),
          .knob("L2", [.amp, .env, .level, .i(1)]),
          .knob("L3", [.amp, .env, .level, .i(2)]),
          .knob("Tone Level", [.tone, .level]),
          .knob("Velo→T4", [.amp, .env, .velo, .time, .i(3)]),
        ]])
      ], effects: [env.effect])
    }
    
    static func ampEnvs() -> (env: PatchController.PanelItem, effect: PatchController.Effect) {
      let env: PatchController.PanelItem = .display(.timeLevelEnv(pointCount: 4, sustain: 2, bipolar: false), "Amp", 4.map { .unit([.amp, .env, .time, .i($0)], dest: [.time, .i($0)]) } + 3.map { .unit([.amp, .env, .level, .i($0)], dest: [.level, .i($0)]) }, id: [.env])
      let effect: PatchController.Effect = .editMenu([.env], paths: [
        [.amp, .env, .time, .i(0)],
       [.amp, .env, .time, .i(1)],
       [.amp, .env, .time, .i(2)],
       [.amp, .env, .time, .i(3)],
       [.amp, .env, .level, .i(0)],
       [.amp, .env, .level, .i(1)],
       [.amp, .env, .level, .i(2)],
      ], type: "JV1080RateLevelEnvelope", init: nil, rand: nil)
      return (env, effect)
    }
    
    static let lfo: PatchController = .patch(prefix: .index([.lfo]), [
      .grid([[
        .switcher(label: "LFO", ["1","2"]),
        .select("Wave", [.wave]),
        .knob("Rate", [.rate]),
        .checkbox("Key Trig", [.key, .trigger]),
      ],[
        .knob("Delay", [.delay]),
        .select("Fade Mode", [.fade, .mode]),
        .knob("Fade Time", [.fade, .time]),
        .select("Level Offset", [.level, .offset]),
        .switsch("Ext Sync", [.ext, .sync]),
      ]]),
    ])
    
    static let control: PatchController = .patch(prefix: .index([.ctrl]), [
      .grid([[
        .switcher(label: "Controller", ["1","2","3"]),
        .select("Dest 1", [.dest, .i(0)]),
        .knob("Amt 1", [.depth, .i(0)]),
        .select("Dest 2", [.dest, .i(1)]),
        .knob("Amt 2", [.depth, .i(1)]),
        .select("Dest 3", [.dest, .i(2)]),
        .knob("Amt 3", [.depth, .i(2)]),
        .select("Dest 4", [.dest, .i(3)]),
        .knob("Amt 4", [.depth, .i(3)]),
      ]]),
    ])
    
    
    
    // MARK: Palettes
    
    static func fourPalettes(pasteType: String, pal: PatchController) -> PatchController {
      .palettes(pal, 4, [.tone], "Tone", pasteType: pasteType)
    }
    
    static func palettePitchWave() -> PatchController {
      return .patch(color: 1, [
        .child(wave(), "wave"),
        .child(palettePitch(), "pitch"),
      ], layout: [
        .grid([
          (row: [("wave", 1)], height: 1),
          (row: [("pitch", 1)], height: 6),
        ]),
      ])
    }
    
    static func palettePitch() -> PatchController {
      let env = pitchEnvs()
      return .patch([
        .grid([[
          .knob("Coarse", [.coarse]),
          .knob("Fine", [.fine]),
          .knob("Random Amt", [.random, .pitch]),
          .knob("Key→Pitch", [.pitch, .keyTrk]),
        ],[
          env.env,
          .knob("Env→Pitch", [.pitch, .env, .depth]),
          .knob("Key→Env T", [.pitch, .env, .time, .keyTrk]),
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
        ],[
          .knob("Velo→Env", [.pitch, .env, .velo, .sens]),
          .knob("Velo→T1", [.pitch, .env, .velo, .time, .i(0)]),
          .knob("Velo→T4", [.pitch, .env, .velo, .time, .i(3)]),
        ],[
          .knob("LFO 1", [.lfo, .i(0), .pitch]),
          .knob("LFO 2", [.lfo, .i(1), .pitch]),
        ]]),
      ], effects: [env.effect])
    }
    
    static func paletteFilter() -> PatchController {
      let env = filterEnvs()
      return .patch(color: 2, [
        .grid([[
          .select("Filter", [.filter, .type]),
          .knob("Cutoff", [.cutoff]),
          .knob("Reson", [.reson]),
        ],[
          env.env,
          .knob("Env→Cutoff", [.filter, .env, .depth]),
          .knob("Key→Env Time", [.filter, .env, .time, .keyTrk]),
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
        ],[
          .knob("Velo→Env", [.filter, .env, .velo, .sens]),
          .knob("Velo→T1", [.filter, .env, .velo, .time, .i(0)]),
          .knob("Velo→T4", [.filter, .env, .velo, .time, .i(3)]),
        ],[
          .knob("Key→Cutoff", [.cutoff, .keyTrk]),
          .knob("Velo→Reson", [.reson, .velo, .sens]),
          .knob("Env Velo Crv", [.filter, .env, .velo, .curve]),
        ],[
          .knob("LFO 1", [.lfo, .i(0), .filter]),
          .knob("LFO 2", [.lfo, .i(1), .filter]),
        ]])
      ], effects: [env.effect])
    }
    
    static func paletteAmp() -> PatchController {
      let env = ampEnvs()
      return .patch(color: 3, [
        .grid([[
          .knob("Level", [.tone, .level]),
          .switsch("Bias Dir", [.bias, .direction]),
          .knob("Bias Pt", [.bias, .pt]),
          .knob("Bias Level", [.bias, .level]),
        ],[
          env.env,
          .knob("Velo Crv", [.amp, .env, .velo, .curve]),
          .knob("Key→Env T", [.amp, .env, .time, .keyTrk]),
        ],[
          .knob("T1", [.amp, .env, .time, .i(0)]),
          .knob("T2", [.amp, .env, .time, .i(1)]),
          .knob("T3", [.amp, .env, .time, .i(2)]),
          .knob("T4", [.amp, .env, .time, .i(3)]),
        ],[
          .knob("L1", [.amp, .env, .level, .i(0)]),
          .knob("L2", [.amp, .env, .level, .i(1)]),
          .knob("L3", [.amp, .env, .level, .i(2)]),
          .spacer(2),
        ],[
          .knob("Velo→Env", [.amp, .env, .velo, .sens]),
          .knob("Velo→T1", [.amp, .env, .velo, .time, .i(0)]),
          .knob("Velo→T4", [.amp, .env, .velo, .time, .i(3)]),
        ],[
          .knob("LFO 1", [.lfo, .i(0), .amp]),
          .knob("LFO 2", [.lfo, .i(1), .amp]),
        ]]),
      ], effects: [env.effect])
    }
    
    
    static func palettePanOut() -> PatchController {
      return .patch(color: 3, [
        .panel("pan", [[
          .knob("Pan", [.pan]),
          .knob("Key→Pan", [.pan, .keyTrk]),
          .knob("Random Pan", [.random, .pan]),
        ],[
          .knob("Alt Pan", [.alt, .pan]),
          .knob("LFO 1", [.lfo, .i(0), .pan]),
          .knob("LFO 2", [.lfo, .i(1), .pan]),
        ]]),
        .panel("fxm", [[
          .checkbox("FXM", [.fxm, .on]),
          .knob("Color", [.fxm, .color]),
          .knob("Depth", [.fxm, .depth]),
        ]]),
        .panel("out", [[
          .select("Output", [.out, .assign]),
          .knob("Level", [.out, .level]),
        ],[
          .knob("Chorus", [.chorus]),
          .knob("Reverb", [.reverb]),
        ]]),
        .panel("delay", [[
          .select("Delay", [.delay, .mode]),
          .knob("Time", [.delay, .time]),
        ]]),
      ], effects: [
      ], layout: [
        .grid([
          (row: [("pan", 1)], height: 2),
          (row: [("fxm", 1)], height: 1),
          (row: [("out", 1)], height: 2),
          (row: [("delay", 1)], height: 1),
        ])
      ])
    }
    
    static func paletteLFO() -> PatchController {
      let lfo: PatchController = .index([.lfo], label: [.wave], { "LFO \($0 + 1)" }, color: 1, [
        .grid([[
          .select("Wave", [.wave]),
          .knob("Rate", [.rate]),
          .checkbox("Key Trig", [.key, .trigger]),
          .switsch("Ext Sync", [.ext, .sync]),
        ],[
          .knob("Delay", [.delay]),
          .select("Fade Mode", [.fade, .mode]),
          .knob("Fade Time", [.fade, .time]),
          .select("Level Offset", [.level, .offset]),
        ],[
          .knob("Pitch", [.pitch]),
          .knob("Filter", [.filter]),
          .knob("Amp", [.amp]),
          .knob("Pan", [.pan]),
        ]])
      ])
      
      return .patch([
        .children(2, "lfo", lfo),
      ], effects: [
      ], layout: [
        .simpleGrid([[("lfo0", 1)], [("lfo1", 1)]])
      ])
    }
  }
  
}

  

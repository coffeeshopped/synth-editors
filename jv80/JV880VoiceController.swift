
extension JV880.Voice {
  
  enum Controller {
    
    static func ctrlr(perf: Bool, hideOut: Bool) -> PatchController {
      
      return .paged([
        .switcher(["Common","1","2","3","4", "Pitch", "Filter", "Amp", "LFO", "FX/Other"], color: 1),
        .panel("on", color: 1, [[
          .checkbox("1", [.tone, .i(0), .on]),
          .checkbox("2", [.tone, .i(1), .on]),
          .checkbox("3", [.tone, .i(2), .on]),
          .checkbox("4", [.tone, .i(3), .on]),
          ]]),
      ], effects: [
      ], layout: [
        .row([("switch", 12), ("on", 4)]),
        .row([("page", 1)]),
        .col([("switch", 1), ("page", 8)]),
      ], pages: .map([[.common]] + 4.map { [.tone, .i($0)] } + [
        [.pitch], [.filter], [.amp], [.lfo], [.extra]
      ], [
        [.common] : common(perf: perf),
        [.tone] : tone(hideOut: hideOut),
        [.pitch] : fourPalettes(pasteType: "JV8XPitch", pal: palettePitchWave()),
        [.filter] : fourPalettes(pasteType: "JV8XFilter", pal: paletteFilter()),
        [.amp] : fourPalettes(pasteType: "JV8XAmp", pal: paletteAmp()),
        [.lfo] : fourPalettes(pasteType: "JV8XLFO", pal: paletteLFO()),
        [.extra] : fourPalettes(pasteType: "JV8XExtra", pal: paletteOther(hideOut: hideOut)),
      ]))
    }
    
    static func fourPalettes(pasteType: String, pal: PatchController) -> PatchController {
      .palettes(pal, 4, [.tone], "Tone", pasteType: pasteType)
    }
    
    // MARK: Palette
    
    static func palettePitchWave() -> PatchController {
      return .patch(color: 1, [
        .child(wave(), "wave"),
        .child(palettePitch(), "pitch"),
      ], effects: [
      ], layout: [
        .grid([
          (row: [(key: "wave", width: 1)], height: 1),
          (row: [(key: "pitch", width: 1)], height: 6),
        ])
      ])
    }

    static func palettePitch() -> PatchController {
      return .patch(color: 1, [
        .grid([[
          .knob("Coarse", [.coarse]),
          .knob("Fine", [.fine]),
          .knob("Random Amt", [.random, .pitch]),
          .knob("Key→Pitch", [.pitch, .keyTrk]),
        ],[
          pitchEnv.env,
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
        ]])
      ], effects: [pitchEnv.menu])
    }
    
    static func paletteFilter() -> PatchController {
      return .patch(color: 1, [
        .grid([[
          .switsch("Filter", [.filter, .type]),
          .knob("Cutoff", [.cutoff]),
          .knob("Reson", [.reson]),
          .switsch("Reson Mode", [.reson, .mode]),
        ],[
          filterEnv.env,
          .knob("Env→Cutoff", [.filter, .env, .depth]),
          .knob("Key→Env T", [.filter, .env, .time, .keyTrk]),
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
          .knob("Env Velo Crv", [.filter, .env, .velo, .curve]),
        ],[
          .knob("LFO 1", [.lfo, .i(0), .filter]),
          .knob("LFO 2", [.lfo, .i(1), .filter]),
        ]])
      ], effects: [
        filterEnv.menu,
        .dimsOn([.filter, .type], id: nil),
      ])
    }

    static func paletteAmp() -> PatchController {
      return .patch(color: 1, [
        .grid([[
          .knob("Level", [.tone, .level]),
          .knob("Key→Level", [.bias, .level]),
        ],[
          ampEnv.env,
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
          .knob("Pan", nil, id: [.pan]),
          .checkbox("Random Pan", nil, id: [.random, .pan]),
          .knob("Key→Pan", [.pan, .keyTrk]),
        ],[
          .knob("LFO 1", [.lfo, .i(0), .amp]),
          .knob("LFO 2", [.lfo, .i(1), .amp]),
        ]])
      ], effects: ampEffects)
    }

    static func paletteLFO() -> PatchController {
      let lfo: PatchController = .index([.lfo], label: [.wave], { "LFO \($0 + 1)" }, [
        .grid([[
          .select("LFO", [.wave]),
          .knob("Rate", [.rate]),
          .checkbox("Sync", [.key, .trigger]),
        ],[
          .knob("Delay", [.delay]),
          .switsch("Fade", [.fade, .mode]),
          .knob("Fade Time", [.fade, .time]),
          .switsch("Offset", [.level, .offset]),
        ],[
          .knob("Pitch", [.pitch]),
          .knob("Filter", [.filter]),
          .knob("Amp", [.amp]),
        ]])
      ])
      
      return .patch(color: 1, [
        .children(2, "vc", lfo),
      ], layout: [
        .simpleGrid([[("vc0", 1)], [("vc1", 1)]]),
      ])
    }

    static func paletteOther(hideOut: Bool) -> PatchController {
      return .patch(color: 1, [
        .panel("fxm", [[
          .checkbox("FXM", [.fxm, .on]),
          .knob("Depth", [.fxm, .depth]),
        ]]),
        .panel("range", [[
          .knob("Velo Lo", [.velo, .range, .lo]),
          .knob("Velo Hi", [.velo, .range, .hi]),
        ]]),
        .panel("volume", [[
          .checkbox("Volume", [.volume, .ctrl]),
          .checkbox("Hold", [.hold, .ctrl]),
        ]]),
        .panel("delay", [[
          .switsch("Delay Mode", [.delay, .mode]),
          .knob("Time", [.delay, .time]),
        ]]),
        .panel("outs", [[
          .knob("Dry", [.out, .level]),
          .knob("Reverb", [.reverb]),
          .knob("Chorus", [.chorus]),
          .switsch("Output", [.out, .assign]),
        ]]),
        .panel("mod", [[
          .select("Mod Dest 1", [.mod, .dest, .i(0)]),
          .knob("Amt", [.mod, .depth, .i(0)]),
          .select("Mod Dest 2", [.mod, .dest, .i(1)]),
          .knob("Amt", [.mod, .depth, .i(1)]),
        ]]),
        .panel("after", [[
          .select("After Dest 1", [.aftertouch, .dest, .i(0)]),
          .knob("Amt", [.aftertouch, .depth, .i(0)]),
          .select("After Dest 2", [.aftertouch, .dest, .i(1)]),
          .knob("Amt", [.aftertouch, .depth, .i(1)]),
        ]]),
        .panel("expr", [[
          .select("Expr Dest 1", [.expression, .dest, .i(0)]),
          .knob("Amt", [.expression, .depth, .i(0)]),
          .select("Expr Dest 2", [.expression, .dest, .i(1)]),
          .knob("Amt", [.expression, .depth, .i(1)]),
        ]]),
      ], effects: [
        .setup([
          .dimItem(hideOut, [.out, .assign], dimAlpha: 0),
        ]),
      ], layout: [
        .simpleGrid([
          [("fxm", 2), ("range", 2)],
          [("volume", 2), ("delay", 2)],
          [("outs", 4)],
          [("mod", 4)],
          [("after", 4)],
          [("expr", 4)],
        ])
      ])
    }

    static func common(perf: Bool) -> PatchController {
      let setup: [PatchController.Effect] = perf ? [
        .setup([
          .dimPanel(true, "chorus"),
          .dimPanel(true, "reverb"),
        ])
      ] : []
      return .patch(prefix: .fixed([.common]), color: 1, [
        .panel("velo", [[
          .checkbox("Velo", [.velo]),
          .knob("Analog Feel", [.analogFeel]),
          .knob("Level", [.level]),
          .knob("Pan", [.pan]),
          .knob("Bend Down", [.bend, .down]),
          .knob("Bend Up", [.bend, .up]),
          .checkbox("Mono", [.mono]),
          .checkbox("Legato", [.legato]),
          ]]),
        .panel("reverb", [[
          .select("Reverb", [.reverb, .type]),
          .knob("Level", [.reverb, .level]),
          .knob("Time", [.reverb, .time]),
          .knob("Feedback", [.reverb, .feedback]),
          ]]),
        .panel("porta", [[
          .checkbox("Porta", [.porta]),
          .switsch("Mode", [.porta, .legato]),
          .switsch("Type", [.porta, .type]),
          .knob("Time", [.porta, .time]),
          ]]),
        .panel("chorus", [[
          .switsch("Chorus", [.chorus, .type]),
          .knob("Level", [.chorus, .level]),
          .knob("Depth", [.chorus, .depth]),
          .knob("Rate", [.chorus, .rate]),
          .knob("Feedback", [.chorus, .feedback]),
          .switsch("Output", [.chorus, .out, .assign]),
          ]]),
      ], effects: setup, layout: [
        .row([("velo",1)]),
        .row([("reverb",4.5), ("porta", 4)]),
        .row([("chorus",1)]),
        .col([("velo",1), ("reverb",1), ("chorus",1)]),
      ])
    }

    static func tone(hideOut: Bool) -> PatchController {
      return .patch(prefix: .index([.tone]), [
        .child(wave(), "wave", color: 1),
        .child(pitch(), "pitch", color: 1),
        .child(filter(), "filter", color: 2),
        .child(amp(), "amp", color: 1),
        .children(2, "lfo", color: 1, lfo()),
        .child(toneCtrl(), "ctrl", color: 1),
        .panel("fxm", color: 1, [[
          .checkbox("FXM", [.fxm, .on]),
          .knob("Depth", [.fxm, .depth]),
        ]]),
        .panel("range", color: 1, [[
          .knob("Velo Lo", [.velo, .range, .lo]),
          .knob("Velo Hi", [.velo, .range, .hi]),
        ]]),
        .panel("volume", color: 1, [[
          .checkbox("Volume", [.volume, .ctrl]),
          .checkbox("Hold", [.hold, .ctrl]),
        ]]),
        .panel("delay", color: 1, [[
          .switsch("Delay Mode", [.delay, .mode]),
          .knob("Time", [.delay, .time]),
        ]]),
        .panel("outs", color: 1, [[
          .knob("Dry", [.out, .level]),
          .knob("Reverb", [.reverb]),
          .knob("Chorus", [.chorus]),
          .switsch("Output", [.out, .assign]),
        ]]),
        .button("Tone", color: 1),
        .panel("space", [[]]),
      ], effects: [
        .editMenu([.button], paths: JV880.Voice.Tone.patchWerk.truss.paramKeys(), type: "JV880Tone", init: nil, rand: nil),
        .setup([
          .dimItem(hideOut, [.out, .assign], dimAlpha: 0),
        ]),
        .dimsOn([.on], id: nil),
      ], layout: [
        .row([("wave",2.5), ("fxm", 2), ("range", 2), ("volume", 2), ("delay", 2), ("outs", 4), ("button", 2)]),
        .row([("pitch",5), ("filter", 6), ("amp", 5)]),
        .row([("lfo0",11), ("ctrl", 5)], opts: [.alignAllTop]),
        .col([("wave",1), ("pitch",4), ("lfo0",1), ("lfo1",1), ("space",1)]),
        .eq(["lfo0","lfo1","space"], .trailing),
        .eq(["ctrl","space"], .bottom),
      ])
    }
    
    static func wave() -> PatchController {
      let patchSel: [PatchController.Effect] = .patchSelector(id: [.wave, .number], bankValues: [[.wave, .group]]) { values, state, locals in
        let group = values[[.wave, .group]] ?? 0
        let options: [Int:String]
        switch group {
        case 0:
          options = JV80.Voice.Tone.waveOptions
        case 1:
          let internalCard = (state.params[[.pcm]] as? RangeParam)?.parm ?? 0
          let card = SRJVBoard.boards[internalCard] ?? SRJVBoard.pop
          options = OptionsParam.makeOptions(card.waves)
        default:
          options = JV80.Voice.Tone.blankWaveOptions
        }
        return .opts(ParamOptions(opts: options))
      }
      return .patch(color: 1, [
        .grid([[
          .switsch("Group", [.wave, .group]),
          .select("Wave", nil, id: [.wave, .number]),
          ]])
      ], effects: [
        .basicPatchChange([.wave, .number]),
        .basicControlChange([.wave, .number]),
      ] + patchSel)
    }

    
    static let pitchEnv = env("Pitch", pre: [.pitch, .env], bipolar: true)
    static let filterEnv = env("Filter", pre: [.filter, .env], bipolar: false)
    static let ampEnv = env("Amp", pre: [.amp, .env], bipolar: false)

    static func pitch() -> PatchController {
      return .patch([
        .grid([[
          .knob("Coarse", [.coarse]),
          .knob("Fine", [.fine]),
          .knob("Random Pitch", [.random, .pitch]),
          .knob("Key→Pitch", [.pitch, .keyTrk]),
        ],[
          pitchEnv.env,
          .knob("Env Depth", [.pitch, .env, .depth]),
          .knob("Key→Env T", [.pitch, .env, .time, .keyTrk]),
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
      ], effects: [pitchEnv.menu])
    }
    
    static func filter() -> PatchController {
      return .patch([
        .grid([[
          .switsch("Filter", [.filter, .type]),
          .knob("Cutoff", [.cutoff]),
          .knob("Reson", [.reson]),
          .switsch("Reson Mode", [.reson, .mode]),
          .knob("Key→Cutoff", [.cutoff, .keyTrk]),
        ],[
          filterEnv.env,
          .knob("Env Depth", [.filter, .env, .depth]),
          .knob("Key→Env T", [.filter, .env, .time, .keyTrk]),
          .knob("Velo→Env", [.filter, .env, .velo, .sens]),
          .knob("Velo Crv", [.filter, .env, .velo, .curve]),
        ],[
          .knob("T1", [.filter, .env, .time, .i(0)]),
          .knob("T2", [.filter, .env, .time, .i(1)]),
          .knob("T3", [.filter, .env, .time, .i(2)]),
          .knob("T4", [.filter, .env, .time, .i(3)]),
          .knob("Velo→T1", [.filter, .env, .velo, .time, .i(0)]),
        ],[
          .knob("L1", [.filter, .env, .level, .i(0)]),
          .knob("L2", [.filter, .env, .level, .i(1)]),
          .knob("L3", [.filter, .env, .level, .i(2)]),
          .knob("L4", [.filter, .env, .level, .i(3)]),
          .knob("Velo→T4", [.filter, .env, .velo, .time, .i(3)]),
        ]])
      ], effects: [
        filterEnv.menu,
        .dimsOn([.filter, .type], id: nil),
      ])
    }
          
    static let ampEffects: [PatchController.Effect] = [
      .patchChange([.pan], {
        var changes: [PatchController.AttrChange] = [
          .dimItem($0 == 128, [.pan], dimAlpha: 0),
          .setValue([.random, .pan], $0 == 128 ? 1 : 0),
        ]
        if $0 < 128 {
          changes.append(.setValue([.pan], $0))
        }
        return changes
      }),
      .basicControlChange([.pan]),
      .controlChange([.random, .pan], { state, locals in
        let rp = locals[[.random, .pan]] ?? 0
        let p = locals[[.pan]] ?? 0
        return [[.pan] : rp == 1 ? 128 : p]
      }),
      ampEnv.menu
    ]
    
    static func amp() -> PatchController {
      return .patch([
        .grid([[
          .knob("Level", [.tone, .level]),
          .knob("Key→Level", [.bias, .level]),
          .knob("Pan", nil, id: [.pan]),
          .checkbox("Random Pan", nil, id: [.random, .pan]),
          .knob("Key→Pan", [.pan, .keyTrk]),
        ],[
          ampEnv.env,
          .knob("Key→Env T", [.amp, .env, .time, .keyTrk]),
          .knob("Velo→Env", [.amp, .env, .velo, .sens]),
          .knob("Velo Crv", [.amp, .env, .velo, .curve]),
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
          .knob("Velo→T4", [.amp, .env, .velo, .time, .i(3)]),
        ]])
      ], effects: ampEffects)
    }
          
    static func lfo() -> PatchController {
      return .index([.lfo], label: [.wave], { "LFO \($0 + 1)" }, [
        .grid([[
          .select("LFO", [.wave]),
          .switsch("Offset", [.level, .offset]),
          .checkbox("Sync", [.key, .trigger]),
          .knob("Rate", [.rate]),
          .knob("Delay", [.delay]),
          .switsch("Fade", [.fade, .mode]),
          .knob("Fade Time", [.fade, .time]),
          .knob("Pitch", [.pitch]),
          .knob("Filter", [.filter]),
          .knob("Amp", [.amp]),
        ]])
      ])
    }
    
    static func env(_ label: String, pre: SynthPath, bipolar: Bool) -> (env: PatchController.PanelItem, menu: PatchController.Effect) {
      let paths: [SynthPath] = (4.map { [.time, .i($0)] } + 4.map { [.level, .i($0)] }).map { pre + $0 }
      let menu: PatchController.Effect = .editMenu([.env], paths: paths, type: "JV880RateLevelEnvelope", init: nil, rand: nil)
      let maps: [PatchController.DisplayMap] = 4.map { .unit([.time, .i($0)]) } + 4.map { bipolar ? .src([.level, .i($0)], { ($0 - 63) / 63 }) : .unit([.level, .i($0)]) }
      let env: PatchController.PanelItem = .display(.timeLevelEnv(pointCount: 4, sustain: 2, bipolar: bipolar), label, maps.map { $0.srcPrefix(pre) }, id: [.env])
      
      return (env, menu)
    }
    
    static func toneCtrl() -> PatchController {
      return .patch(prefix: .select([[.mod], [.aftertouch], [.expression]]), [
        .grid([[
          .switcher(["Mod","Aftertouch","Expression"]),
        ], [
          .select("Dest 1", [.dest, .i(0)]),
          .knob("Amt 1", [.depth, .i(0)]),
          .select("Dest 2", [.dest, .i(1)]),
          .knob("Amt 2", [.depth, .i(1)]),
        ], [
          .select("Dest 3", [.dest, .i(2)]),
          .knob("Amt 3", [.depth, .i(2)]),
          .select("Dest 4", [.dest, .i(3)]),
          .knob("Amt 4", [.depth, .i(3)]),
        ]])
      ])
    }
  }
  
}


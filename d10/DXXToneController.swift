
extension DXX.Tone {
  
  enum Controller {
    
    static func ctrlr() -> PatchController {
      
      return .paged([
        .switcher(["1","2","3","4", "Pitch", "Filter", "Amp"], color: 1),
        .panel("struct", color: 1, [[
          .imgSelect("Structure 1/2", [.common, .structure, .i(0)], w: 160, h: 60),
          .imgSelect("Structure 3/4", [.common, .structure, .i(1)], w: 160, h: 60),
          .checkbox("Partial 1", [.common, .tone, .i(0), .on]),
          .checkbox("2", [.common, .tone, .i(1), .on]),
          .checkbox("3", [.common, .tone, .i(2), .on]),
          .checkbox("4", [.common, .tone, .i(3), .on]),
          .switsch("Env Mode", [.common, .env, .sustain]),
          ]]),
      ], effects: [
      ], layout: [
        .row([("switch",7),("struct",9)]),
        .row([("page",1)]),
        .col([("switch",1),("page", 6)]),
      ], pages: .map([
        [.partial, .i(0)],
        [.partial, .i(1)],
        [.partial, .i(2)],
        [.partial, .i(3)],
        [.pitch],
        [.filter],
        [.amp],
      ], [
        [.partial] : partial(),
        [.pitch] : fourPalettes(pasteType: "DXXPitch", pal: pitch()),
        [.filter] : fourPalettes(pasteType: "DXXFilter", pal: paletteFilter()),
        [.amp] : fourPalettes(pasteType: "DXXAmp", pal: paletteAmp()),
      ]))
    }
    
    static func fourPalettes(pasteType: String, pal: PatchController) -> PatchController {
      .palettes(pal, 4, [.tone], "Tone", pasteType: pasteType, effects: [.dimsOn(fullPath: { [.common, .tone, .i($0), .on] }, id: nil)])
    }
    
    
    static func partial() -> PatchController {
      let AllPaths = Array(DXX.Tone.Partial.parms.params().keys)

      return .patch(prefix: .index([.tone]), [
        .child(pitch(), "pitch"),
        .child(filter(), "filter"),
        .child(amp(), "amp"),
        .button("Partial", color: 1),
        .panel("space", [[]]),
      ], effects: [
        .editMenu([.button], paths: AllPaths, type: "D110Partial", init: nil, rand: nil),
        .dimsOn(fullPath: { [.common, .tone, .i($0), .on] }, id: nil),
      ], layout: [
        .row([("pitch",5), ("button", 10)], opts: [.alignAllTop]),
        .rowPart([("filter", 5), ("amp", 5)], opts: [.alignAllTop, .alignAllBottom]),
        .col([("button", 1), ("filter", 4), ("space", 1)]),
        .eq(["button", "amp", "space"], .trailing),
        .eq(["pitch", "space"], .bottom),
      ])
    }
    
//    class D110PartialController : NewPatchEditorController {
//      override func randomize(_ sender: Any?) {
//        pushPatchChange(.replace(D110PartialPatch.random()))
//      }
//    }

    
    static let pitchEnv = env("Pitch", [.pitch, .env], pointCount: 4, bipolar: true, withStart: true)
    
    static func pitch() -> PatchController {
      
      return .patch(color: 1, [
        .grid([[
          .switsch("Wave", nil, id: [.wave]),
          .select("PCM", nil, id: [.pcm, .wave]),
          .knob("Pitch", [.coarse]),
          .knob("Fine", [.fine]),
          ],[
          .knob("Keyfollow", [.pitch, .keyTrk]),
          .knob("PW", [.pw]),
          .knob("Velo→PW", [.pw, .velo]),
          .checkbox("Bender", [.bend]),
        ],[
          pitchEnv.env,
          .knob("Env Depth", [.pitch, .env, .depth]),
          .knob("Velo→Env D", [.pitch, .env, .velo]),
          .knob("Key→Env T", [.pitch, .env, .time, .keyTrk]),
        ],[
          .spacer(2),
          .knob("T1", [.pitch, .env, .time, .i(0)]),
          .knob("T2", [.pitch, .env, .time, .i(1)]),
          .knob("T3", [.pitch, .env, .time, .i(2)]),
          .knob("T4", [.pitch, .env, .time, .i(3)]),
        ],[
          .knob("L0", [.pitch, .env, .level, .i(-1)]),
          .knob("L1", [.pitch, .env, .level, .i(0)]),
          .knob("L2", [.pitch, .env, .level, .i(1)]),
          .knob("Sus L", [.pitch, .env, .level, .i(2)]),
          .knob("End L", [.pitch, .env, .level, .i(3)]),
        ],[
          .knob("LFO Rate", [.pitch, .lfo, .rate]),
          .knob("Depth", [.pitch, .lfo, .depth]),
          .knob("Mod Sens", [.pitch, .lfo, .mod, .sens]),
        ]])
      ], effects: [
        pitchEnv.menu,
        isSynth({ isSynth in [
          .dimItem(!isSynth, [.pw], dimAlpha: 0),
          .dimItem(!isSynth, [.pw, .velo], dimAlpha: 0),
          .dimItem(isSynth, [.pcm, .wave], dimAlpha: 0),
          .setCtrlLabel([.wave], isSynth ? "Wave" : "Bank"),
          .configCtrl([.wave], .span(isSynth ? .opts(DXX.Tone.Partial.waveOptions) : .options(DXX.Tone.Partial.bankOptions))),
        ] }),
        .basicControlChange([.wave]),
        .patchChange([.wave], {
          [.configCtrl([.pcm, .wave], .span(.opts($0 > 1 ? DXX.Tone.Partial.pcmOptions2 : DXX.Tone.Partial.pcmOptions1)))]
        }),
        .basicControlChange([.pcm, .wave]),
        .basicPatchChange([.pcm, .wave]),
        .change({ state, locals in
          if let wave = state.updatedValue(path: [.wave]) {
            // wave updated
            let isSynth = isSynth(state, updatedOnly: false) ?? false
            return [.setValue([.wave], isSynth ? wave : (wave / 2) * 2)]
          }
          else if let isSynth = isSynth(state, updatedOnly: true) {
            // structure updated
            let wave = state.prefixedValue([.wave]) ?? 0
            return [.setValue([.wave], isSynth ? wave : (wave / 2) * 2)]
          }
          else {
            return []
          }
        })
      ])
    }
        
    
    static let filterEnv = env("Filter", [.filter, .env], pointCount: 5, bipolar: false, withStart: false)

    static func filter() -> PatchController {
      return .patch(color: 2, [
        .grid([[
          .knob("Cutoff", [.cutoff]),
          .knob("Reson", [.reson]),
          .knob("Bias Pt", [.filter, .bias, .pt]),
          .knob("Bias L", [.filter, .bias, .level]),
          .knob("Keyfollow", [.filter, .keyTrk]),
        ],[
          filterEnv.env,
          .knob("Env Depth", [.filter, .env, .depth]),
          .knob("Velo→Env D", [.filter, .env, .velo]),
          .knob("Key→Env T", [.filter, .env, .time, .keyTrk]),
        ],[
          .knob("T1", [.filter, .env, .time, .i(0)]),
          .knob("T2", [.filter, .env, .time, .i(1)]),
          .knob("T3", [.filter, .env, .time, .i(2)]),
          .knob("T4", [.filter, .env, .time, .i(3)]),
          .knob("T5", [.filter, .env, .time, .i(4)]),
        ],[
          .knob("L1", [.filter, .env, .level, .i(0)]),
          .knob("L2", [.filter, .env, .level, .i(1)]),
          .knob("L3", [.filter, .env, .level, .i(2)]),
          .knob("Sus L", [.filter, .env, .level, .i(3)]),
          .knob("Key→Env D", [.filter, .env, .depth, .keyTrk]),
        ]])
      ], effects: [
        filterEnv.menu,
        isSynth({ isSynth in [.dimPanel(!isSynth, nil, dimAlpha: 0.2)] }),
      ])
    }

    // only triggers when structure is actually updated
    static func isSynth(_ block: @escaping (_ isSynth: Bool) -> [PatchController.AttrChange]) -> PatchController.Effect {
      .change({ state, locals in
        guard let isSynth = isSynth(state, updatedOnly: true) else { return [] }
        return block(isSynth)
      })
    }
    
    static func isSynth(_ state: PatchControllerState, updatedOnly: Bool) -> Bool? {
      guard let index = state.prefix?.i(1) else { return nil }
      let structIndex = index < 2 ? 0 : 1
      let structPath: SynthPath = [.common, .structure, .i(structIndex)]
      let structure: Int?
      if updatedOnly {
        structure = state.updatedValueForFullPath(structPath)
      }
      else {
        structure = state.values[structPath]
      }
      guard let structure = structure else { return nil }
      return !DXX.Tone.isPCM(forStructure: structure, partial: index)
    }
    
    static func paletteFilter() -> PatchController {
      return .patch([
        .panel("main", color: 2, [[
          .knob("Cutoff", [.cutoff]),
          .knob("Reson", [.reson]),
          .knob("Bias Pt", [.filter, .bias, .pt]),
          .knob("Bias L", [.filter, .bias, .level]),
          .knob("Keyfollow", [.filter, .keyTrk]),
        ],[
          filterEnv.env,
          .knob("Env Depth", [.filter, .env, .depth]),
          .knob("Velo→Env D", [.filter, .env, .velo]),
          .knob("Key→Env T", [.filter, .env, .time, .keyTrk]),
          ],[
          .knob("T1", [.filter, .env, .time, .i(0)]),
          .knob("T2", [.filter, .env, .time, .i(1)]),
          .knob("T3", [.filter, .env, .time, .i(2)]),
          .knob("T4", [.filter, .env, .time, .i(3)]),
          .knob("T5", [.filter, .env, .time, .i(4)]),
          ],[
          .knob("L1", [.filter, .env, .level, .i(0)]),
          .knob("L2", [.filter, .env, .level, .i(1)]),
          .knob("L3", [.filter, .env, .level, .i(2)]),
          .knob("Sus L", [.filter, .env, .level, .i(3)]),
          .knob("Key→Env D", [.filter, .env, .depth, .keyTrk]),
          ]]),
        .panel("space", [[]]),
      ], effects: [
        filterEnv.menu,
        isSynth({ isSynth in [.dimPanel(!isSynth, nil, dimAlpha: 0.2)] }),
      ], layout: [
        .grid([
          (row: [("main", 1)], height: 4),
          (row: [("space", 1)], height: 1),
        ])
      ])
    }
    
    
    static let ampEnv = env("Amp", [.env], pointCount: 5, bipolar: false, withStart: false)
    
    static func amp() -> PatchController {
      
      return .patch(prefix: .fixed([.amp]), color: 1, [
        .grid([[
          .knob("Level", [.level]),
          .knob("Bias Pt1", [.bias, .pt, .i(0)]),
          .knob("Bias L1", [.bias, .level, .i(0)]),
          .knob("Bias Pt2", [.bias, .pt, .i(1)]),
          .knob("Bias L2", [.bias, .level, .i(1)]),
        ],[
          ampEnv.env,
          .knob("Velo", [.velo, .sens]),
          .knob("Velo→Env T", [.env, .time, .velo]),
          .knob("Key→Env T", [.env, .time, .keyTrk]),
        ],[
          .knob("T1", [.env, .time, .i(0)]),
          .knob("T2", [.env, .time, .i(1)]),
          .knob("T3", [.env, .time, .i(2)]),
          .knob("T4", [.env, .time, .i(3)]),
          .knob("T5", [.env, .time, .i(4)]),
        ],[
          .knob("L1", [.env, .level, .i(0)]),
          .knob("L2", [.env, .level, .i(1)]),
          .knob("L3", [.env, .level, .i(2)]),
          .knob("Sus L", [.env, .level, .i(3)]),
          .spacer(2),
        ]])
      ], effects: [
        ampEnv.menu,
      ])
    }
    
    static func paletteAmp() -> PatchController {
      return .patch(prefix: .fixed([.amp]), [
        .panel("main", color: 2, [[
          .knob("Level", [.level]),
          .knob("Bias Pt1", [.bias, .pt, .i(0)]),
          .knob("Bias L1", [.bias, .level, .i(0)]),
          .knob("Bias Pt2", [.bias, .pt, .i(1)]),
          .knob("Bias L2", [.bias, .level, .i(1)]),
        ],[
          ampEnv.env,
          .knob("Velo", [.velo, .sens]),
          .knob("Velo→Env T", [.env, .time, .velo]),
          .knob("Key→Env T", [.env, .time, .keyTrk]),
        ],[
          .knob("T1", [.env, .time, .i(0)]),
          .knob("T2", [.env, .time, .i(1)]),
          .knob("T3", [.env, .time, .i(2)]),
          .knob("T4", [.env, .time, .i(3)]),
          .knob("T5", [.env, .time, .i(4)]),
        ],[
          .knob("L1", [.env, .level, .i(0)]),
          .knob("L2", [.env, .level, .i(1)]),
          .knob("L3", [.env, .level, .i(2)]),
          .knob("Sus L", [.env, .level, .i(3)]),
          .spacer(2),
        ]]),
        .panel("space", [[]]),
      ], effects: [
        ampEnv.menu,
      ], layout: [
        .grid([
          (row: [("main", 1)], height: 4),
          (row: [("space", 1)], height: 1),
        ]),
      ])
    }
    
    static func env(_ label: String, _ pre: SynthPath, pointCount: Int, bipolar: Bool, withStart: Bool) -> (env: PatchController.PanelItem, menu: PatchController.Effect) {
      let paths: [SynthPath] = (0..<4).map { [.level, .i($0)] } + (0..<5).map { [.time, .i($0)] }
      let menu: PatchController.Effect = .editMenu([.env], paths: paths.prefixed(pre), type: "D110Envelope", init: nil, rand: nil)
      
      var maps: [PatchController.DisplayMap] = pointCount.map { .unit([.time, .i($0)], max: 100) } + pointCount.map { bipolar ? .src([.level, .i($0)], { ($0 - 50) / 50 }) : .unit([.level, .i($0)], max: 100) }
      
      if withStart {
        maps += [
          .src([.level, .i(-1)], dest: [.start, .level], { ($0 - 50) / 50 })
        ]
      }
      let env: PatchController.PanelItem = .display(.timeLevelEnv(pointCount: pointCount, sustain: pointCount - 2, bipolar: bipolar), label, maps.map { $0.srcPrefix(pre) }, id: [.env])
      
      return (env, menu)

    }
    
    
  }
}

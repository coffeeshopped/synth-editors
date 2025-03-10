
extension JDXi.Digital {
  
  enum Controller {
    
    static var controller: PatchController {
      return .paged([
        .switcher(["Pitch/Filter/Amp", "LFO", "Common", "P1","P2","P3"], color: 1),
        .panel("on", prefix: [.common, .partial], color: 1, [[
          .checkbox("Partial 1", [.i(0), .on]),
          .checkbox("Partial 2", [.i(1), .on]),
          .checkbox("Partial 3", [.i(2), .on]),
        ]]),
        .panel("level", color: 1, [[
          .knob("Level", [.common, .tone, .level]),
        ]]),
      ], effects: [
      ], layout: [
        .grid([
          (row: [("switch",12), ("on", 3), ("level", 1) ], height: 1),
          (row: [("page",1),], height: 8),
        ])
      ], pages: .map([[.pitch], [.lfo], [.common]] + 3.map { [.partial, .i($0)]}, [
        [.common] : common,
        [.partial] : partial,
        [.pitch] : threePalettes(pasteType: "PFAPal", pal: palettePitchFilterAmp),
        [.lfo] : threePalettes(pasteType: "LFO", pal: paletteLFO),
      ]))
    }
    
    static var common: PatchController {
      return .patch(color: 1, [
        .panel("level", [[
          .knob("Level", [.common, .tone, .level]),
        ]]),
        .panel("cat", [[
          .select("Category", [.common, .category]),
        ]]),
        .panel("ring", prefix: [.common], [[
          .switsch("Ring Mod", [.ringMod]),
          .knob("Waveshape", [.wave, .shape]),
          .knob("Analog Feel", [.analogFeel]),
        ]]),
        .panel("bend", prefix: [.common], [[
          .knob("Octave", [.octave, .shift]),
          .knob("Bend Up", [.bend, .up]),
          .knob("Bend Down", [.bend, .down]),
        ]]),
        .panel("unison", prefix: [.common], [[
          .checkbox("Unison", [.unison]),
          .knob("Unison Size", [.unison, .number]),
          .checkbox("Mono", [.mono]),
          .checkbox("Legato", [.legato]),
        ]]),
        .panel("porta", [[
          .checkbox("Porta", [.common, .porta]),
          .knob("Time", [.common, .porta, .time]),
          .checkbox("Legato", [.common, .porta, .legato]),
          .checkbox("Chroma", [.mod, .chromatic, .porta]),
        ]]),
        .panel("misc", prefix: [.mod], [[
          .knob("Attack Int Sens", [.attack, .interval, .sens]),
          .knob("Release Int Sens", [.release, .interval, .sens]),
          .knob("Porta Int Sens", [.porta, .interval, .sens]),
          .switsch("Env Loop", [.env, .loop, .mode]),
          .knob("Env Sync Note", [.env, .loop, .sync, .note]),
        ]]),
      ], layout: [
        .simpleGrid([
          [("level", 1), ("cat", 1.5), ("ring", 3), ],
          [("bend", 3), ("unison", 4), ],
          [("porta", 4), ("misc", 5), ],
        ])
      ])
    }
    
    static var partial: PatchController {
      return .patch(prefix: .index([.partial]), [
        .child(filter, "filter", color: 3),
        .child(amp, "amp", color: 2),
        .button("Partial", color: 1),
        .panel("wave", color: 1, [[
          .select("Wave", [.osc, .wave]),
          .switsch("Variation", [.osc, .wave, .mod]),
          .select("PCM Wave", [.wave, .number]),
          .knob("PCM Gain", [.wave, .gain]),
        ],[
          .knob("PW Mod", [.pw, .mod, .depth]),
          .knob("Pulsewidth", [.pw]),
          .knob("PW Shift", [.pw, .shift]),
          .knob("SSaw Detune", [.saw, .detune]),
        ],[
          .knob("Pitch", [.coarse]),
          .knob("Detune", [.fine]),
          .knob("Attack", [.pitch, .env, .attack]),
          .knob("Decay", [.pitch, .env, .decay]),
          .knob("Env Amt", [.pitch, .env, .depth]),
        ]]),
        .panel("lfo", prefix: [.lfo], color: 1, [[
          .knob("Fade Time", [.fade]),
          .knob("Pitch", [.pitch, .depth]),
          .knob("Filter", [.filter, .depth]),
          .knob("Amp", [.amp, .depth]),
          .knob("Pan", [.pan, .depth]),
        ],[
          .select("LFO", [.shape]),
          .knob("Rate", [.rate]),
          .checkbox("Tempo Sync", [.tempo, .sync]),
          .knob("Sync Note", [.sync, .note]),
          .checkbox("Key Sync", [.key, .sync]),
        ]]),
        .panel("mod", prefix: [.mod, .lfo], color: 1, [[
          .knob("Rate Mod", [.rate, .ctrl]),
          .knob("Pitch", [.pitch, .depth]),
          .knob("Filter", [.filter, .depth]),
          .knob("Amp", [.amp, .depth]),
          .knob("Pan", [.pan, .depth]),
        ],[
          .select("Mod LFO", [.shape]),
          .knob("Rate", [.rate]),
          .checkbox("Tempo Sync", [.tempo, .sync]),
          .knob("Sync Note", [.sync, .note]),
        ]]),
        .panel("pSpace", [[]]),
        .panel("aSpace", [[]]),
      ], effects: [
        waveEffect,
        .editMenu([.button], paths: [SynthPath](Partial.parms.params().keys), type: "JDXiDigitalPartial", init: nil, rand: nil),
        .dimsOn(fullPath: { [.common, .partial, .i($0), .on] }, id: nil),
      ] + lfoEffects, layout: [
        .row([("wave", 5), ("filter", 5), ("aSpace", 5)], opts: [.alignAllTop]),
        .row([("lfo", 5), ("mod", 5), ("button", 2)]),
        .col([("wave", 3), ("pSpace", 1), ("lfo", 2)]),
        .colPart([("aSpace", 1), ("amp", 3)], opts: [.alignAllLeading, .alignAllTrailing]),
        .eq(["pSpace", "filter", "amp"], .bottom),
        .eq(["pSpace", "wave"], .trailing),
      ])

        // TODO: this
  //      override func randomize(_ sender: Any?) {
  //        pushPatchChange(.replace(JDXiDigitalPatch.PartialPatch.templatedPatchType.random()))
  //      }
    }
    
    static var waveEffect: PatchController.Effect {
      return .patchChange([.osc, .wave]) {
        let hidePW = $0 != 2
        return [
          .dimItem($0 > 5, [.osc, .wave, .mod], dimAlpha: 0),
          .dimItem($0 != 7, [.wave, .number], dimAlpha: 0),
          .dimItem($0 != 7, [.wave, .gain], dimAlpha: 0),
          .dimItem(hidePW, [.pw], dimAlpha: 0),
          .dimItem(hidePW, [.pw, .mod, .depth], dimAlpha: 0),
          .dimItem(hidePW, [.pw, .shift], dimAlpha: 0),
          .dimItem($0 != 6, [.saw, .detune], dimAlpha: 0),
        ]
      }
    }
    
    static var lfoEffects: [PatchController.Effect] {
      return [
        .patchChange([.lfo, .tempo, .sync], { [
          .dimItem($0 == 1, [.lfo, .rate], dimAlpha: 0),
          .dimItem($0 != 1, [.lfo, .sync, .note], dimAlpha: 0),
        ] }),
        .patchChange([.mod, .lfo, .tempo, .sync], { [
          .dimItem($0 == 1, [.mod, .lfo, .rate], dimAlpha: 0),
          .dimItem($0 != 1, [.mod, .lfo, .sync, .note], dimAlpha: 0),
        ]})
      ]
    }
    
    static var filter: PatchController {
      let env = RolandEnvController.adsr(prefix: [.filter, .env], label: "Filter")
      return .patch([
        .grid([[
          .select("Filter", [.filter, .mode]),
          .switsch("Slope", [.filter, .curve]),
          .knob("Cutoff", [.cutoff]),
          .knob("Aftertouch", [.cutoff, .aftertouch, .sens]),
          .knob("Reson", [.reson]),
        ],[
          .knob("Velo", [.filter, .env, .velo]),
          .knob("Key Follow", [.filter, .key, .trk]),
          .knob("HPF", [.hi, .pass, .cutoff]),
          .knob("Env Amt", [.filter, .env, .depth]),
        ],[
          env.0,
        ],[
          .knob("Attack", [.filter, .env, .attack]),
          .knob("Decay", [.filter, .env, .decay]),
          .knob("Sustain", [.filter, .env, .sustain]),
          .knob("Release", [.filter, .env, .release]),
        ]])
      ], effects: [
        env.1,
        .dimsOn([.filter, .mode], id: nil),
      ])
    }
    
    static var amp: PatchController {
      let env = RolandEnvController.adsr(prefix: [.amp, .env], label: "Amp")
      return .patch([
        .grid([[
          .knob("Amp", [.amp, .level]),
          .knob("Velo", [.amp, .velo]),
          .knob("Pan", [.pan]),
          .knob("Key Follow", [.amp, .key, .trk]),
          .knob("Aftertouch", [.level, .aftertouch, .sens]),
        ],[
          env.0,
        ],[
          .knob("Attack", [.amp, .env, .attack]),
          .knob("Decay", [.amp, .env, .decay]),
          .knob("Sustain", [.amp, .env, .sustain]),
          .knob("Release", [.amp, .env, .release]),
        ]])
      ], effects: [
        env.1
      ])
    }
    
    static var palettePitchFilterAmp: PatchController {
      let filterEnv = RolandEnvController.adsr(prefix: [.filter, .env], label: "Filter", envId: [.filter, .env])
      let ampEnv = RolandEnvController.adsr(prefix: [.amp, .env], label: "Amp", envId: [.amp, .env])

      return .patch(border: 1, [
        .panel("pitch", color: 1, [[
          .select("Wave", [.osc, .wave]),
          .switsch("Variation", [.osc, .wave, .mod]),
          .select("PCM Wave", [.wave, .number]),
        ],[
          .knob("PW Mod", [.pw, .mod, .depth]),
          .knob("Pulsewidth", [.pw]),
          .knob("PW Shift", [.pw, .shift]),
          .knob("SSaw Detune", [.saw, .detune]),
          .knob("PCM Gain", [.wave, .gain]),
        ],[
          .knob("Pitch", [.coarse]),
          .knob("Detune", [.fine]),
          .knob("Attack", [.pitch, .env, .attack]),
          .knob("Decay", [.pitch, .env, .decay]),
          .knob("Env Amt", [.pitch, .env, .depth]),
        ]]),
        .panel("filter", color: 3, [[
          .select("Filter", [.filter, .mode]),
          .switsch("Slope", [.filter, .curve]),
          .knob("Cutoff", [.cutoff]),
          .knob("Reson", [.reson]),
        ],[
          .knob("Env Amt", [.filter, .env, .depth]),
          .knob("Velo", [.filter, .env, .velo]),
          .knob("HPF", [.hi, .pass, .cutoff]),
          .knob("Key Fol", [.filter, .key, .trk]),
          .knob("Aftert", [.cutoff, .aftertouch, .sens]),
        ],[
          .knob("A", [.filter, .env, .attack]),
          .knob("D", [.filter, .env, .decay]),
          .knob("S", [.filter, .env, .sustain]),
          .knob("R", [.filter, .env, .release]),
          filterEnv.0,
        ]]),
        .panel("amp", color: 2, [[
          .knob("Amp", [.amp, .level]),
          .knob("Velo", [.amp, .velo]),
          .knob("Pan", [.pan]),
          .knob("Key Fol", [.amp, .key, .trk]),
          .knob("Aftert", [.level, .aftertouch, .sens]),
        ],[
          .knob("A", [.amp, .env, .attack]),
          .knob("D", [.amp, .env, .decay]),
          .knob("S", [.amp, .env, .sustain]),
          .knob("R", [.amp, .env, .release]),
          ampEnv.0,
        ]])
      ], effects: [
        .dimsOn([.filter, .mode], id: "filter"),
        filterEnv.1,
        ampEnv.1,
        waveEffect,
      ], layout: [
        .grid([
          (row: [("pitch", 5)], height: 3),
          (row: [("filter", 5)], height: 3),
          (row: [("amp", 5)], height: 2),
        ])
      ])
    }
    
    static var paletteLFO: PatchController {
      return .patch(color: 2, border: 2, [
        .panel("lfo", prefix: [.lfo], [[
          .select("LFO", [.shape]),
          .knob("Rate", [.rate]),
          .checkbox("Tempo Sync", [.tempo, .sync]),
          .knob("Sync Note", [.sync, .note]),
        ],[
          .knob("Pitch", [.pitch, .depth]),
          .knob("Filter", [.filter, .depth]),
          .knob("Amp", [.amp, .depth]),
          .knob("Pan", [.pan, .depth]),
        ],[
          .knob("Fade Time", [.fade]),
          .checkbox("Key Sync", [.key, .sync]),
        ]]),
        .panel("mod", prefix: [.mod, .lfo], [[
          .select("Mod LFO", [.shape]),
          .knob("Rate", [.rate]),
          .checkbox("Tempo Sync", [.tempo, .sync]),
          .knob("Sync Note", [.sync, .note]),
        ],[
          .knob("Pitch", [.pitch, .depth]),
          .knob("Filter", [.filter, .depth]),
          .knob("Amp", [.amp, .depth]),
          .knob("Pan", [.pan, .depth]),
        ],[
          .knob("Rate Mod", [.rate, .ctrl]),
        ]]),
      ], effects: lfoEffects, layout: [
        .grid([
          (row: [("lfo", 5)], height: 3),
          (row: [("mod", 5)], height: 3),
        ])
      ])
    }
    
    
    static func threePalettes(pasteType: String, pal: PatchController) -> PatchController {
      .palettes(pal, 3, [.partial], "Partial", pasteType: pasteType)
    }
          
  }
  
}

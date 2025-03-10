
extension JDXi.Analog {
  
  enum Controller {
    
    static var controller: PatchController {
      return .patch(prefix: .fixed([.common]), [
        .child(filter, "filter", color: 1),
        .child(amp, "amp", color: 1),
        .panel("porta", color: 1, [[
          .checkbox("Legato", [.legato]),
          .checkbox("Portamento", [.porta]),
          .knob("Porta Time", [.porta, .time]),
          .knob("Octave", [.octave, .shift]),
          .knob("Bend Up", [.bend, .up]),
          .knob("Bend Down", [.bend, .down]),
        ]]),
        .panel("pitch", color: 1, [[
          .switsch("Wave", [.osc, .wave]),
          .knob("Pitch", [.coarse]),
          .knob("Detune", [.fine]),
        ],[
          .knob("Pulsewidth", [.pw]),
          .knob("PW Mod", [.pw, .mod, .depth]),
          .switsch("Sub Osc", [.sub, .osc, .type]),
        ],[
          .knob("Attack", [.pitch, .env, .attack]),
          .knob("Decay", [.pitch, .env, .decay]),
          .knob("Env Amt", [.pitch, .env, .depth]),
          .knob("Pitch Velo", [.pitch, .env, .velo]),
        ]]),
        .panel("lfo", prefix: [.lfo], color: 1, [[
          .select("LFO", [.shape]),
          .knob("Rate", [.rate]),
          .knob("Fade Time", [.fade]),
          .knob("Pitch", [.pitch, .depth]),
          .knob("Filter", [.filter, .depth]),
          .knob("Amp", [.amp, .depth]),
        ],[
          .checkbox("Tempo Sync", [.tempo, .sync]),
          .select("Sync Note", [.sync, .note]),
          .checkbox("Key Sync", [.key, .sync]),
          .knob("Rate Mod", [.rate, .mod]),
          .knob("Pitch Mod", [.pitch, .mod]),
          .knob("Filter Mod", [.filter, .mod]),
          .knob("Amp Mod", [.amp, .mod]),
        ]]),
      ], effects: [
        .patchChange([.lfo, .tempo, .sync], {
          let sync = $0 == 1
          return [
            .dimItem(sync, [.rate], dimAlpha: 0),
            .dimItem(!sync, [.sync, .note], dimAlpha: 0),
          ]
        })
      ], layout: [
        .row([("porta",1)]),
        .row([("pitch", 4), ("filter",4),("amp",4)]),
        .row([("lfo",1)]),
        .col([("porta",1),("pitch", 3),("lfo",2)]),
      ])
    }
    
    static var filter: PatchController {
      let env = RolandEnvController.adsr(prefix: [.filter, .env], label: "Filter")
      return .patch([
        .grid([[
          .checkbox("Filter", [.filter, .on]),
          .knob("Cutoff", [.cutoff]),
          .knob("Reson", [.reson]),
          .knob("Key Follow", [.filter, .key, .trk]),
        ],[
          .knob("Velocity", [.filter, .env, .velo]),
          env.0,
          .knob("Env Amt", [.filter, .env, .depth]),
        ],[
          .knob("Attack", [.filter, .env, .attack]),
          .knob("Decay", [.filter, .env, .decay]),
          .knob("Sustain", [.filter, .env, .sustain]),
          .knob("Release", [.filter, .env, .release]),
        ]])
      ], effects: [
        env.1,
        .dimsOn([.filter, .on], id: nil),
      ])
    }
    

    static var amp: PatchController {
      let env = RolandEnvController.adsr(prefix: [.amp, .env], label: "Amp")
      return .patch([
        .grid([[
          .knob("Amp", [.amp, .level]),
          .knob("Key Follow", [.amp, .key, .trk]),
        ],[
          .knob("Velocity", [.amp, .velo]),
          env.0,
        ],[
          .knob("Attack", [.amp, .env, .attack]),
          .knob("Decay", [.amp, .env, .decay]),
          .knob("Sustain", [.amp, .env, .sustain]),
          .knob("Release", [.amp, .env, .release]),
        ]])
      ], effects: [
        env.1,
      ])
    }
  }
  
}

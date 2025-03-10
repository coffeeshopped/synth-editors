
//struct JP8080GlobalController {
//  
//  static func controller() -> FnPatchEditorController {
//    ActivatedFnEditorController { vc in
//      
//      vc.addChild(txrxController(), withPanel: "txrx")
//      
//      vc.grid(panel: "channel", prefix: [.param], items: [[
//        (PBKnob("Perf Ctrl Ch"), [.perf, .ctrl, .channel]),
//        (PBSwitch("PwrUp Mode"), [.on, .mode]),
//        (PBCheckbox("Local"), [.local]),
//        (PBKnob("Tune"), [.tune]),
//        (PBKnob("Remote Kbd Ch"), [.ext, .key, .channel]),
//        (PBSwitch("MIDI Sync"), [.midi, .sync]),
//      ]])
//      
//      
//      vc.grid(panel: "txrxEdit", prefix: [.param, .send, .rcv], items: [[
//        (PBCheckbox("Tx/Rx Edit"), [.edit, .on]),
//        (PBSwitch("Edit Mode"), [.edit, .mode]),
//        (PBSwitch("Pgm Ch"), [.pgmChange, .mode]),
//      ]])
//
//      let motionLabel = LabelItem(text: "Motion", gridWidth: 3, textAlignment: .center)
//      vc.grid(panel: "motion", prefix: [.param, .motion], items: [[
//        (motionLabel, nil),
//        (PBCheckbox("Restart"), [.reset]),
//        (PBSwitch("Preset"), [.preset]),
//        (PBKnob("Metronome"), [.metro]),
//      ]])
//
//      vc.grid(panel: "loop", prefix: [.motion], items: [[
//        (PBKnob("A1 Loop"), [.i(0), .i(0), .length]),
//        (PBKnob("B1 Loop"), [.i(1), .i(0), .length]),
//        (PBKnob("A2 Loop"), [.i(0), .i(1), .length]),
//        (PBKnob("B1 Loop"), [.i(1), .i(1), .length]),
//      ]])
//      
//      let ptnLabel = LabelItem(text: "Pattern", gridWidth: 3, textAlignment: .center)
//      vc.grid(panel: "ptn", prefix: [.param], items: [[
//        (ptnLabel, nil),
//        (PBSwitch("Trig Qtz"), [.pattern, .trigger, .quantize]),
//        (PBSelect("Quantize"), [.input, .quantize]),
//        (PBSelect("Gate Time"), [.gate, .time, .ratio]),
//        (PBKnob("Metronome"), [.pattern, .metro]),
//      ]])
//            
//      vc.addColor(panels: ["channel", "ptn"])
//      vc.addColor(panels: ["txrxEdit"], level: 2)
//      vc.addColor(panels: ["motion", "loop"], level: 3)
//
//      vc.addLayoutConstraints { layout in
//        layout.addGridConstraints([
//          (row: [("channel", 6), ("ptn", 6.5)], height: 1),
//          (row: [("txrxEdit", 3), ("motion", 4.5), ("loop", 4)], height: 1),
//          (row: [("txrx", 14),], height: 4),
//        ], spacing: "-s1-")
//      }
//    }
//  }
//  
//  static func txrxController() -> FnPatchEditorController {
//    ActivatedFnEditorController { vc in
//      vc.prefixBlock = { _ in [.rcv] }
//      
//      vc.grid(panel: "morph", prefix: [.morph, .ctrl], items: [[
//        (PBKnob("Ctrl Up"), [.up]),
//        (PBKnob("Ctrl Down"), [.down]),
//      ]])
//
//      vc.grid(panel: "lfo0", prefix: [.lfo, .i(0)], items: [[
//        (PBKnob("LFO 1 Rate"), [.rate]),
//        (PBKnob("Fade"), [.fade]),
//      ]])
//
//      vc.grid(panel: "lfo1", items: [[
//        (PBKnob("LFO 2 Rate"), [.lfo, .i(1), .rate]),
//      ]])
//      
//      vc.grid(panel: "osc0", prefix: [.osc, .i(0)], items: [[
//        (PBKnob("Osc 1 Ctrl 1"), [.ctrl, .i(0)]),
//        (PBKnob("Ctrl 2"), [.ctrl, .i(1)]),
//      ]])
//
//      vc.grid(panel: "osc1", prefix: [.osc, .i(1)], items: [[
//        (PBKnob("Osc 2 Ctrl 1"), [.ctrl, .i(0)]),
//        (PBKnob("Ctrl 2"), [.ctrl, .i(1)]),
//        (PBKnob("Range"), [.range]),
//        (PBKnob("Fine"), [.fine]),
//      ]])
//
//      vc.grid(panel: "osc", items: [[
//        (PBKnob("Osc Bal"), [.osc, .balance]),
//        (PBKnob("X-Mod"), [.cross]),
//        (PBKnob("LFO1 Depth"), [.pitch, .lfo, .i(0), .depth]),
//      ]])
//
//      vc.grid(panel: "pitch", items: [[
//        (PBKnob("Pitch Env"), [.pitch, .env, .depth]),
//        (PBKnob("A"), [.pitch, .env, .attack]),
//        (PBKnob("D"), [.pitch, .env, .decay]),
//        (PBKnob("LFO 2"), [.pitch, .lfo, .i(1), .depth]),
//      ]])
//      
//      vc.grid(panel: "filter", prefix: [.filter], items: [[
//        (PBKnob("Filter Cutoff"), [.cutoff]),
//        (PBKnob("Reson"), [.reson]),
//        (PBKnob("Key Follow"), [.key, .trk]),
//        ],[
//        (PBKnob("Env Depth"), [.env, .depth]),
//        (PBKnob("LFO 1"), [.lfo, .i(0), .depth]),
//        (PBKnob("LFO 2"), [.lfo, .i(1), .depth]),
//        ],[
//        (PBKnob("A"), [.env, .attack]),
//        (PBKnob("D"), [.env, .decay]),
//        (PBKnob("S"), [.env, .sustain]),
//        (PBKnob("R"), [.env, .release]),
//      ]])
//
//      vc.grid(panel: "amp", prefix: [.amp], items: [[
//        (PBKnob("Amp Level"), [.level]),
//        (PBKnob("LFO 1"), [.lfo, .i(0), .depth]),
//        (PBKnob("LFO 2"), [.lfo, .i(1), .depth]),
//      ],[
//        (PBKnob("A"), [.env, .attack]),
//        (PBKnob("D"), [.env, .decay]),
//        (PBKnob("S"), [.env, .sustain]),
//        (PBKnob("R"), [.env, .release]),
//      ]])
//
//      vc.grid(panel: "eq", prefix: [.eq], items: [[
//        (PBKnob("Bass"), [.lo]),
//        (PBKnob("Treble"), [.hi]),
//      ]])
//
//      vc.grid(panel: "fx", prefix: [.fx], items: [[
//        (PBKnob("FX Level"), [.level]),
//      ]])
//
//      vc.grid(panel: "delay", prefix: [.delay], items: [[
//        (PBKnob("Delay Time"), [.time]),
//        (PBKnob("Feedback"), [.feedback]),
//        (PBKnob("Level"), [.level]),
//      ]])
//
//      vc.grid(panel: "porta", prefix: [.porta], items: [[
//        (PBKnob("Porta Time"), [.time]),
//      ]])
//
//      vc.addLayoutConstraints { layout in
//        layout.addRowConstraints([("lfo0", 2), ("eq", 2), ("fx", 1), ("delay", 3), ("morph", 4)], pinned: true, pinMargin: "", spacing: "-s1-")
//        layout.addRowConstraints([("lfo1", 2), ("osc0", 2), ("filter", 4), ("pitch", 4)], options: [.alignAllTop], pinned: true, pinMargin: "", spacing: "-s1-")
//        layout.addRowConstraints([("porta", 1), ("osc", 3), ], pinned: false, spacing: "-s1-")
//        layout.addColumnConstraints([("lfo0", 1), ("lfo1", 1), ("osc1", 1), ("porta", 1)], pinned: true, pinMargin: "", spacing: "-s1-")
//        layout.addColumnConstraints([("pitch", 1), ("amp", 2)], options: [.alignAllLeading, .alignAllTrailing], pinned: false, spacing: "-s1-")
//        layout.addEqualConstraints(forItemKeys: ["osc0", "osc1", "osc"], attribute: .trailing)
//        layout.addEqualConstraints(forItemKeys: ["porta", "filter", "amp"], attribute: .bottom)
//        layout.addEqualConstraints(forItemKeys: ["lfo1", "osc0"], attribute: .bottom)
//      }
//      
//      vc.addColorToAll(level: 2)
//    }
//  }
//}

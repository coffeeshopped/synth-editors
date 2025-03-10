
extension JDXi.Drum {
  
  enum Controller {
    
    static var controller: PatchController {
      return .paged([
        .switcher(4.map { "\($0 + 2)" }, color: 1),
        .panel("level", color: 1, [[
          .knob("Level", [.common, .level]),
        ]]),
      ], effects: [
      ], layout: [
        .row([("switch",12),("level",4.5)]),
        .row([("page",1)]),
        .col([("switch",1),("page",8)]),
      ], pages: .map(4.map { [.tone, .i($0)] }, [[.tone] : tones]))
    }
    
    static var tones: PatchController {
      let drumLabels = ["BD1", "Rim", "BD2", "Clap", "BD3", "SD1", "CHH", "SD2", "PHH", "SD3", "OHH", "SD4", "Tom1", "Prc1", "Tom2", "Prc2", "Tom3", "Prc3", "Cym1", "Prc4", "Cym2", "Prc5", "Cym3", "Hit", "Oth1", "Oth2"]
      let segCount = 12

      return .patch([
        .panel("grid", color: 1, clearBG: true, [[
          .grid("", nil, cols: segCount, id: [.note, .ctrl], width: 12),
        ]]),
        .child(tone, "tone"),
      ], effects: [
        .indexChange(fn: { state, locals in
          let indexOffset = state.index * segCount
          let toneIndex = (locals[[.note, .ctrl]] ?? 0) + indexOffset
          let noteOpts: PatchController.ConfigParam = .opts(ParamOptions(optArray: segCount.map {
            let noteNumber = indexOffset + $0 + 36
            var name = ParamHelper.noteName(noteNumber)
            if noteNumber - 36 < drumLabels.count {
              name = "\(name) \(drumLabels[noteNumber - 36])"
            }
            return noteNumber < 36 || noteNumber > 72 ? "--" : "\(name)"
          }))
          
          return [
            .configCtrl([.note, .ctrl], noteOpts),
            .setIndex("tone", toneIndex),
          ]
        }),
        .controlCommand([.note, .ctrl], latestValues: [], { value, latestValues, index in
          let i = value + (index * segCount)
          return [
            .setIndex("tone", i),
            .midiNote(chan: 0, note: 36 + i, velo: 100, len: 500),
          ]
        })
      ], layout: [
        .row([("grid",13.5)]),
        .row([("tone",1)]),
        .col([("grid",1),("tone",7)]),
      ])
    }
    
    static var tone: PatchController {
      let paths = [SynthPath](Partial.parms.params().keys)
      let t: PatchController = .paged([
        .switcher(["Main","WMT"], color: 2),
        .panel("single", color: 2, [[
          .checkbox("WMT 1", [.wave, .i(0), .on]),
          .checkbox("WMT 2", [.wave, .i(1), .on]),
          .checkbox("WMT 3", [.wave, .i(2), .on]),
          .checkbox("WMT 4", [.wave, .i(3), .on]),
          .checkbox("Single", [.assign, .type]),
          .switsch("WMT Velo", [.wave, .velo]),
          .checkbox("Rx Expr", [.rcv, .expression]),
          .checkbox("Rx Hold-1", [.rcv, .hold]),
          .checkbox("1-shot", [.oneShot]),
        ]]),
        .button("Partial", color: 2),
      ], effects: [
        .editMenu([.button], paths: paths, type: "JDXiDrumPartial", init: nil, rand: nil, items: [
          .filePopover("Load/Save...", [.rhythm, .partial]),
        ]),
      ], layout: [
        .grid([
          (row: [("page", 1)], height: 6),
          (row: [("switch", 3), ("single",10.5), ("button",2.5)], height: 1),
        ]),
      ], pages: .controllers([main, wmts]))
      
      return .patch(prefix: .index([.partial]), [
        .child(t, "t"),
      ], layout: [
        .simpleGrid([[("t", 1)]])
      ])

  
      // TODO: this
//  randomize: {
//    var patch = try! Partial.patchWerk.truss.createPatch()
//    patch.randomize()
//    return paths.map { patch[$0] ?? 0 }
//  }
    }
    
    static func envSetup(_ label: String, prefix: SynthPath, bipolar: Bool, levelSteps: Int, startLevel: Bool) -> (PatchController.PanelItem, PatchController.Effect) {
      let env: PatchController.Display = .timeLevelEnv(pointCount: 4, sustain: 2, bipolar: bipolar)
      var maps: [PatchController.DisplayMap] = 4.map {
        .unit([.time, .i($0)])
      } + levelSteps.map {
        .src([.level, .i($0)], { bipolar ? ($0 - 64) / 63 : $0 / 127 })
      }
      if startLevel {
        maps.append(.src([.level, .i(-1)], dest: [.start, .level], { bipolar ? ($0 - 64) / 63 : $0 / 127 }))
      }

      let paths: [SynthPath] = 4.map { [.time, .i($0)] } + levelSteps.map { [.level, .i($0)] } + [(startLevel ? [.level, .i(-1)] : [])]

      return (
        .display(env, label, maps.map { $0.srcPrefix(prefix) }, id: prefix),
        .editMenu(prefix, paths: paths.prefixed(prefix), type: "JDXiRateLevelEnvelope", init: nil, rand: nil)
      )
    }
    
    static var main: PatchController {
      let pitchEnv = envSetup("Pitch", prefix: [.pitch, .env], bipolar: true, levelSteps: 4, startLevel: true)
      let filterEnv = envSetup("Filter", prefix: [.filter, .env], bipolar: false, levelSteps: 4, startLevel: true)
      let ampEnv = envSetup("Amp", prefix: [.amp, .env], bipolar: false, levelSteps: 3, startLevel: false)

      return .patch([
        .child(wmt, "wmt"),
        .panel("pitch", color: 2, [[
          .knob("Coarse", [.coarse]),
          .knob("Fine", [.fine]),
          .knob("Rand Pitch", [.random, .pitch]),
          .knob("Bend", [.bend]),
        ],[
          pitchEnv.0,
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
          filterEnv.0,
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
          ampEnv.0,
          .knob("← Velo", [.level, .velo]),
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
          .knob("Rltv Lvl", [.level, .adjust]),
        ]]),
        .panel("out", color: 2, [[
          .name("Name", []),
          .select("Output", [.out, .assign]),
        ],[
          .knob("Direct", [.out, .level]),
          .knob("Delay", [.chorus]),
          .knob("Reverb", [.reverb]),
        ]]),
      ], effects: [
        pitchEnv.1,
        filterEnv.1,
        ampEnv.1,
      ], layout: [
        .row([("out", 4), ("wmt", 12)]),
        .row([("pitch",5),("filter",6),("amp",5)]),
        .col([("out", 2), ("pitch", 4)]),
      ])
    }
    
    static var wmt: PatchController {
      let paths = Partial.parms.params().keys.filter { $0.starts(with: [.wave, .i(0)]) }.map {
        $0.subpath(from: 2)
      }

      return .patch(prefix: .index([.wave]), [
        .switcher(label: "WMT", ["1","2","3","4"], color: 3),
        .panel("on", color: 3, [[
          .checkbox("On", [.on]),
          .select("Wave L", [.number, .i(0)]),
          .select("Wave R", [.number, .i(1)]),
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
        .dimsOn([.number, .i(0)], id: [.number, .i(0)]),
        .dimsOn([.number, .i(1)], id: [.number, .i(1)]),
        .dimsOn([.fxm, .on], id: "fxm"),
        .editMenu([.button], paths: paths, type: "JDXiDrWMT", init: nil, rand: nil),
      ] + ["on", "fxm", "level", "velo"].map { .dimsOn([.on], id: $0) }, layout: [
        .simpleGrid([
          [("switch",4),("on",6), ("fxm", 3)],
          [("level",7), ("velo",4), ("button", 1.5)],
        ]),
      ])
        
//      vc.addBorder(level: 3)
    }
    
    
    static var wmts: PatchController {
      return .oneRow(4, child: .patch(prefix: .index([.wave]), [
        .panel("on", color: 3, [[
          .checkbox("WMT", [.on]),
          .switsch("Gain", [.wave, .gain]),
        ],[
          .select("Wave L", [.number, .i(0)]),
          .select("Wave R", [.number, .i(1)]),
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
        .indexChange({ [.setCtrlLabel([.on], "WMT \($0 + 1)")] }),
        .dimsOn([.number, .i(0)], id: [.number, .i(0)]),
        .dimsOn([.number, .i(1)], id: [.number, .i(1)]),
        .dimsOn([.fxm, .on], id: "fxm"),
        .dimsOn([.on], id: nil),
      ], layout: [
        .grid([
          (row: [("on", 1)], height: 2),
          (row: [("fxm", 1)], height: 1),
          (row: [("level", 1)], height: 2),
          (row: [("velo", 1)], height: 1),
        ])
      ]))
      

//      subVC.addBorder(level: 3)
    }
    
  }
}

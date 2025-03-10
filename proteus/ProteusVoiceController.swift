
extension Proteus {
  
  enum Voice {
    
    enum Controller {

      static func ctrlr(chorusMax: Int) -> PatchController {
        
        return .patch([
          .children(2, "inst", color: 1, inst(chorusMax: chorusMax)),
          .children(6, "kv", color: 3, kv()),
          .children(8, "mod", color: 2, mod()),
          .children(2, "lfo", color: 2, lfo()),
          .child(extra(), "extra", color: 2),
          .panel("xfade", color: 1, [[
            .switsch("XFade", [.cross, .mode]),
            .switsch("Dir", [.cross, .direction]),
            .knob("Balance", [.cross, .balance]),
            .knob("Amount", [.cross, .amt]),
            .knob("Switch Pt", [.cross, .pt]),
          ]]),
          .panel("bend", color: 1, [[
            .knob("Bend", [.bend]),
            .knob("Pressure", [.pressure, .amt]),
            .select("Tuning", [.tune]),
          ]]),
          .panel("key", color: 1, [[
            .knob("Key Lo", [.key, .lo, .i(0)]),
            .knob("Key Hi", [.key, .hi, .i(0)]),
          ]]),
          .panel("velo", color: 1, [[
            .knob("Velo Crv", [.velo, .curve]),
            ],[
            .switsch("Mix Out", [.mix]),
          ]]),
          .panel("center", color: 3, [[
            .knob("Key Center", [.key, .mid]),
          ]]),
          .panel("ctrl", color: 2, [[
            .knob("Ctrl A", [.ctrl, .i(0), .amt]),
            .knob("Ctrl B", [.ctrl, .i(1), .amt]),
            ],[
            .knob("Ctrl C", [.ctrl, .i(2), .amt]),
            .knob("Ctrl D", [.ctrl, .i(3), .amt]),
          ]]),
          .panel("foot", color: 1, [[
            .select("Foot 1", [.foot, .i(0), .dest]),
            .select("Foot 2", [.foot, .i(1), .dest]),
            .select("Foot 3", [.foot, .i(2), .dest]),
          ]]),
          .panel("link", color: 1, [[
            .select("Link 1", [.link, .i(0)]),
            .knob("Key Lo", [.key, .lo, .i(1)]),
            .knob("Key Hi", [.key, .hi, .i(1)]),
            ],[
            .select("Link 2", [.link, .i(1)]),
            .knob("Key Lo", [.key, .lo, .i(2)]),
            .knob("Key Hi", [.key, .hi, .i(2)]),
            ],[
            .select("Link 3", [.link, .i(2)]),
            .knob("Key Lo", [.key, .lo, .i(3)]),
            .knob("Key Hi", [.key, .hi, .i(3)]),
            ]])
        ], effects: [
          .dimsOn([.cross, .mode], id: "xfade"),
          .paramChange([.patch, .name], { param in
            3.map { .configCtrl([.link, .i($0)], .param(param)) }
          })
        ] + 3.map { link in
            .patchChange([.link, .i(link)]) { value in
              let dim = value == -1
              return [
                .dimItem(dim, [.link, .i(link)]),
                .dimItem(dim, [.key, .lo, .i(link + 1)]),
                .dimItem(dim, [.key, .hi, .i(link + 1)]),
              ]
            }
          }, layout: [
          .row([("inst0",10.5), ("xfade",5.5)], opts: [.alignAllTop]),
          .rowPart([("bend",3.5), ("key", 2)]),
          .row([("inst1",10.5), ("velo",2), ("link", 3.5)], opts: [.alignAllTop]),
          .rowPart([("kv0",3.5), ("kv1",3.5), ("kv2",3.5), ("center",1)]),
          .rowPart([("ctrl",2), ("lfo0",5), ("extra",5)], opts: [.alignAllTop]),
          .rowPart([("mod0",3), ("mod1",3), ("mod2",3), ("mod3",3),]),
          .rowPart([("mod4",3), ("mod5",3), ("mod6",3), ("mod7",3),]),
          .col([("inst0",2), ("inst1",2), ("kv0",1), ("kv3",1), ("kv4",1), ("kv5",1), ("foot",1)]),
          .colPart([("xfade", 1), ("bend", 1)]),
          .colPart([("lfo0",1), ("lfo1",1)], opts: [.alignAllLeading, .alignAllTrailing]),
          .colPart([("ctrl",2), ("mod0",1), ("mod4",1)]),
          .eq(["xfade", "key", "extra", "mod3", "mod7"], .trailing),
          .eq(["inst0", "bend"], .bottom),
          .eq(["inst1", "velo"], .bottom),
          .eq(["center", "link"], .bottom),
          .eq(["velo", "center"], .trailing),
          .eq(["ctrl", "lfo1", "extra"], .bottom),
          .eq(["kv0", "kv3", "kv4", "kv5", "foot"], .trailing),
          .eq(["foot", "mod4"], .bottom),
          .eq(["kv1", "ctrl"], .leading),
          .eq(["kv3", "ctrl"], .top),
        ])
        
      }
      
      static func inst(chorusMax: Int) -> PatchController {
        let envCtrls = envPaths + [[.env]]

        return .patch(prefix: .index([]), [
          .grid([[
            .select("Wave", [.wave]),
            .knob("Start", [.start]),
            .knob("Volume", [.volume]),
            .knob("Delay", [.delay]),
            env.env,
            .checkbox("Env On", [.env, .on]),
            .checkbox("Solo", [.solo]),
            (chorusMax == 1 ? .checkbox("Chorus", [.chorus]) : .knob("Chorus", [.chorus])),
            .checkbox("Reverse", [.reverse]),
            ],[
            .knob("Coarse", [.coarse]),
            .knob("Fine", [.fine]),
            .knob("Pan", [.pan]),
            .knob("Attack", [.attack]),
            .knob("Hold", [.hold]),
            .knob("Decay", [.decay]),
            .knob("Sustain", [.sustain]),
            .knob("Release", [.release]),
            .knob("Key Lo", [.key, .lo]),
            .knob("Key Hi", [.key, .hi]),
          ]])
        ], effects: [
          .indexChange({ [.setCtrlLabel([.wave], $0 == 0 ? "Primary" : "Secondary")]}),
          .dimsOn([.wave], id: nil),
          env.menu,
        ] + envCtrls.map {
          .dimsOn([.env, .on], id: $0)
        })
      }
      
      
      static let envPaths: [SynthPath] = [
        [.attack],
        [.hold],
        [.decay],
        [.sustain],
        [.release],
      ]
      
      static let env: (env: PatchController.PanelItem, menu: PatchController.Effect) = {
        let maps: [PatchController.DisplayMap] = envPaths.map { .unit($0, max: 99) }
        let env: PatchController.PanelItem = .display(.ahdsrEnv(), "", maps, id: [.env])
        return (env: env, menu: .editMenu([.env], paths: envPaths, type: "ProteusEnvelope", init: [0, 0, 72, 50, 12], rand: { 5.map { _ in (0...99).rand() } }))
      }()
      
      static func extra() -> PatchController {
        return .patch(prefix: .fixed([.extra]), [
          .grid([[
            .knob("Delay", [.delay]),
            env.env,
            .knob("Amount", [.amt]),
            ],[
            .knob("Attack", [.attack]),
            .knob("Hold", [.hold]),
            .knob("Decay", [.decay]),
            .knob("Sustain", [.sustain]),
            .knob("Release", [.release]),
          ]])
        ], effects: [env.menu])
      }

      static func kv() -> PatchController {
        return .patch(prefix: .index([.key, .velo]), [
          .grid([[
            .switsch("Src", [.src]),
            .knob("Amount", [.amt]),
            .select("Dest", [.dest]),
          ]])
        ], effects: [
          .indexChange({ [.setCtrlLabel([.src], "K/V Src \($0 + 1)")] }),
          .patchChange(paths: [[.amt], [.dest]], { values in
            [.dimPanel(values[[.amt]] == 0 || values[[.dest]] == 0, nil)]
          })
        ])
      }

      static func lfo() -> PatchController {
        return .patch(prefix: .index([.lfo]), [
          .grid([[
            .switsch("LFO", [.shape]),
            .knob("Rate", [.freq]),
            .knob("Amount", [.amt]),
            .knob("Delay", [.delay]),
            .knob("Vari", [.mod]),
          ]])
        ], effects: [
          .indexChange({ [.setCtrlLabel([.shape], "LFO \($0 + 1)")] }),
        ])
      }

      static func mod() -> PatchController {
        return .patch(prefix: .index([.mod]), [
          .grid([[
            .select("Src", [.src]),
            .select("Dest", [.dest]),
          ]])
        ], effects: [
          .indexChange({ [.setCtrlLabel([.src], "RT Src \($0 + 1)")] }),
          .dimsOn([.dest], id: nil),
        ])
      }

    }
    
  }
}

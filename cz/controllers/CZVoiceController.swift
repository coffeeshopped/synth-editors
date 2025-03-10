
extension CZ101.Voice {
  
  enum Controller {
    
    static func ctrlr(cz1: Bool) -> PatchController {
      return .patch([
        .children(2, "dco", color: 1, dco(cz1: cz1)),
        .children(2, "dcw", color: 2, dcw(cz1: cz1)),
        .children(2, "dca", color: 3, dca(cz1: cz1)),
        .child(mods, "mods"),
      ], effects: [
      ], layout: [
        .row([("dco0",1),("dco1",1)]),
        .row([("dcw0",1),("dcw1",1)]),
        .row([("dca0",1),("dca1",1)]),
        .row([("mods",1)]),
        .col([("dco0",1),("dcw0",1),("dca0",1),("mods",0.4)]),
      ])
    }
    
    static let mods: PatchController = .patch(color: 1, [
      .panel("oct", [[
        .switsch("Octave", [.octave]),
        .switsch("Line Select", [.select]),
        .switsch("Modulation", [.mod]),
        ]]),
      .panel("vib", [[
        .switsch("Vibrato", [.vib, .wave]),
        .knob("Delay", [.vib, .delay]),
        .knob("Rate", [.vib, .rate]),
        .knob("Depth", [.vib, .depth]),
        ]]),
      .panel("detune", [[
        .switsch("Detune", [.detune, .direction]),
        .switsch("Octave", [.detune, .octave]),
        .knob("Note", [.detune, .note]),
        .knob("Fine", [.detune, .fine]),
        ]]),
    ], effects: [
    ], layout: [
      .simpleGrid([[("oct",1),("vib",1),("detune",1)]]),
    ])
    
    static let env: PatchController.Display = .env({ values in
      var cmds = [PBBezier.PathCommand]()
      let pointCount = 8
      let startLevel = CGFloat(values[[.start, .level]] ?? 0)
      let sustainPoint = Int(values[[.sustain]] ?? 1000)
      let endPoint = Int(values[[.end]] ?? 0)
      
      let segWidth = (sustainPoint >= pointCount ? 1 / CGFloat(pointCount) : 1 / CGFloat(pointCount+1) )
      let offscreenDelta: CGFloat = 0.05
      
      var x: CGFloat = 0
      var y: CGFloat = startLevel

      cmds.append(.move(to: CGPoint(x: -offscreenDelta, y: -offscreenDelta)))
      cmds.append(.addLine(to: CGPoint(x: x, y: y)))
      
      for index in 0..<pointCount {
        x += (values[[.rate, .i(index)]] ?? 0) * segWidth
        y = index < endPoint ? (values[[.level, .i(index)]] ?? 0) : 0

        cmds.append(.addLine(to: CGPoint(x: x, y: y)))
        if sustainPoint == index {
          x += segWidth
          cmds.append(.addLine(to: CGPoint(x: x, y: y)))
        }
      }
      
      cmds.append(.addLine(to: CGPoint(x: 1, y: y)))
      cmds.append(.addLine(to: CGPoint(x: 1 + offscreenDelta, y: -offscreenDelta)))
      
      return cmds
    })
    
    
    static func dc(_ prefix: SynthPath, label: String, rightItems: [[PatchController.PanelItem]], cz1: Bool, color: Int) -> PatchController {
      
      let maps: [PatchController.DisplayMap] = 8.flatMap { [
        .src([.rate, .i($0)], { (99 - $0) / 99 }),
        .unit([.level, .i($0)], max: 99),
      ] } + [
        .ident([.sustain]),
        .ident([.end]),
      ]
      
      let paths: [SynthPath] = {
        return 8.map { [.env, .rate, .i($0)] } +
          8.map { [.env, .level, .i($0)] } +
          [[.env, .sustain], [.env, .end]]
      }()

      let menu: PatchController.Effect = .editMenu([.env], paths: paths, type: "CZEnvelope", init: [
        99, 99, 99, 99, 99, 99, 99, 99,
        0, 0, 0, 0, 0, 0, 0, 0,
        7, 0
      ], rand: {
        16.map { _ in (0..<100).rand() } +
          [8.rand(), 8.rand()]
      })
      
      let dim: PatchController.Effect = .patchChange(fullPath: [.select]) { value, state, locals in
        let off: Bool
        switch value {
        case 0: // 1
          off = state.index > 0
        case 1: // 2
          off = state.index == 0
        case 2: // 1+1'
          off = state.index > 0
        default: // both
          off = false
        }
        return [.dimPanel(off, nil)]
      }
      
      return .patch(prefix: .index(prefix), color: color, [
        .panel("env", [[
          .display(env, "?", maps.map { $0.srcPrefix([.env]) }, id: [.env]),
        ]]),
        .panel("rateLevels", [
          [.label("Rates", width: 3)] + 8.map { .knob("", [.env, .rate, .i($0)]) },
          [.label("Levels", width: 3)] + 8.map { .knob("", [.env, .level, .i($0)]) }
        ]),
        .panel("left", [[
          .knob("Sus Pt",[.env, .sustain]),
          .knob("End Pt",[.env, .end]),
        ] + (cz1 ? [.knob("Velocity", [.velo])] : [])]),
        .panel("right", rightItems),
      ], effects: [
        .indexChange({ [.setCtrlLabel([.env], "\(label)\($0 + 1)")] }),
        .patchChange([.env, .end], { value in
          8.flatMap { [
            .dimItem($0 > value, [.env, .rate, .i($0)], dimAlpha: 0.25),
            .dimItem($0 >= value, [.env, .level, .i($0)], dimAlpha: 0.25),
          ] }
        }),
        .patchChange(paths: [[.env, .sustain], [.env, .end]], { values in
          guard let sus = values[[.env, .sustain]] else { return [] }
          let end = values[[.env, .end]] ?? 7
          return 8.map {
            .setCtrlLabel([.env, .level, .i($0)], $0 == sus && $0 < end ? "Sus" : "")
          }
        }),
        menu, dim,
      ], layout: [
        .row([("left",3),("env",3),("right",3)]),
        .row([("rateLevels",8)]),
        .col([("left",1.4),("rateLevels",2)]),
      ])
    }
    
    static func dco(cz1: Bool) -> PatchController {
      return dc([.osc], label: "DCO", rightItems: [[
        .imgSelect("Wave 1", [.wave, .i(0)], w: 150, h: 60),
        .imgSelect("Wave 2", [.wave, .i(1)], w: 150, h: 60),
      ]], cz1: cz1, color: 1)
    }

    static func dcw(cz1: Bool) -> PatchController {
      return dc([.filter], label: "DCW", rightItems: [[
        .knob("Key Follow", [.keyTrk]),
      ]], cz1: cz1, color: 2)
    }

    static func dca(cz1: Bool) -> PatchController {
      return dc([.amp], label: "DCA", rightItems: [[
        .knob("Key Follow", [.keyTrk]),
      ] + (cz1 ? [.knob("Level", [.level])] : [])], cz1: cz1, color: 3)
    }

  }
  
}

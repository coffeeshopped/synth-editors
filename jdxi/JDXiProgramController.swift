
extension JDXi.Program {

  enum Controller {
    
    static var controller: PatchController {
      return .paged([
        .switcher(["Parts", "FX/Arp"], color: 1),
        .panel("tempo", color: 1, [[
          .knob("Tempo", nil, id: [.common, .tempo]),
          .knob("Level", [.common, .level]),
          .knob("D1 Level", [.digital, .i(0), .level]),
          .knob("D2 Level", [.digital, .i(1), .level]),
          .knob("Drum Level", [.rhythm, .level]),
          .knob("Ana Level", [.analog, .level]),
          .switsch("D1 Out", [.digital, .i(0), .out, .assign]),
          .switsch("D2 Out", [.digital, .i(1), .out, .assign]),
          .switsch("Drum Out", [.rhythm, .out, .assign]),
          .switsch("Ana Out", [.analog, .out, .assign]),
        ]])

      ], effects: [
      ] + .ctrlBlocks([.common, .tempo], value: { $0 / 100 }, cc: { $0 * 100 }, param: .opts(ParamOptions(range: 50...300))), layout: [
        .grid([
          (row: [("switch", 4), ("tempo", 12)], height: 1),
          (row: [("page", 8)], height: 8),
        ])
      ], pages: .controllers([parts, fx]))
    }
    
    static var fx: PatchController {
      return .patch([
        .child(delay, "delay", color: 1),
        .child(reverb, "reverb", color: 1),
        .child(fx1, "fx1", color: 1),
        .child(fx2, "fx2", color: 1),
        .child(arp, "arp", color: 1),
        .child(autoPitch, "autoPitch", color: 1),
        .child(vocoder, "vocoder", color: 1),
        .panel("vocalFX", color: 1, [[
          .switsch("Vocal FX", [.common, .voice, .fx]),
          .switsch("Part", [.common, .voice, .fx, .part]),
          .knob("FX Number", [.common, .voice, .fx, .number]),
          .knob("Level", [.voice, .fx, .level]),
          .knob("Pan", [.voice, .fx, .pan]),
          .knob("Delay", [.voice, .fx, .delay]),
          .knob("Reverb", [.voice, .fx, .reverb]),
          .switsch("Out Assign", [.voice, .fx, .out, .assign]),
        ]]),
      ], effects: [
        .patchChange([.common, .voice, .fx], { [
          .dimItem($0 == 0, [.common, .voice, .fx, .number]),
          .dimPanel($0 == 0, "vocalFX"),
        ] })
      ], layout: [
        .simpleGrid([
          [("fx1", 10.5)],
          [("fx2", 10.5)],
          [("delay",10), ("reverb",5.5)],
          [("vocalFX",8), ("vocoder",6)],
          [("autoPitch",8), ("arp",9.5)],
        ])
      ])
    }
    
    static var vocoder: PatchController {
      .patch(prefix: .fixed([.voice, .fx]), [
        .grid([[
          .switsch("Vocod Env", [.vocoder, .env]),
          .knob("Mic Sens", [.vocoder, .mic, .sens]),
          .knob("Synth", [.vocoder, .synth, .level]),
          .knob("Mic Mix", [.vocoder, .mic, .mix]),
          .knob("Mic HPF", [.vocoder, .mic, .hi, .pass]),
        ]])
      ])
    }

    static var autoPitch: PatchController {
      .patch(prefix: .fixed([.voice, .fx, .auto, .pitch]), [
        .grid([[
          .checkbox("AutoPitch", [.on]),
          .switsch("Type", [.type]),
          .switsch("Scale", [.scale]),
          .knob("Key", [.key]),
          .knob("Note", [.note]),
          .knob("Gender", [.gender]),
          .knob("Octave", [.octave]),
          .knob("Balance", [.balance]),
        ]])
      ])
    }

    static var delay: PatchController {
      return .patch(prefix: .fixed([.delay]), [
        .grid([[
          .checkbox("Delay", [.on]),
          .switsch("Type", [.param, .i(0)]),
          .switsch("T Sync", [.param, .i(1)]),
          .knob("Time", [.param, .i(2)]),
          .knob("Sync Note", [.param, .i(3)]),
          .knob("Tap Time", [.param, .i(4)]),
          .knob("Feedbk", [.param, .i(5)]),
          .knob("HF Damp", [.param, .i(6)]),
          .knob("Level", [.param,. i(7)]),
          .knob("Reverb", [.reverb]),
        ]]),
      ], effects: [
        .dimsOn([.on], id: nil),
        .patchChange([.param, .i(1)], {
          let isFree = $0 == 32768
          return [
            .dimItem(!isFree, [.param, .i(2)], dimAlpha: 0),
            .dimItem(isFree, [.param, .i(3)], dimAlpha: 0),
          ]
        })
      ])
    }

    static var reverb: PatchController {
      return .patch(prefix: .fixed([.reverb]), [
        .grid([[
          .checkbox("Reverb", [.on]),
          .select("Type", [.param, .i(0)]),
          .knob("Time", [.param, .i(1)]),
          .knob("HF Damp", [.param, .i(2)]),
          .knob("Level", [.param, .i(3)]),
        ]])
      ], effects: [
        .dimsOn([.on], id: nil),
      ])
    }

    static func fxController(knobCount: Int, paramMap: [Int:[(String, Parm.Span)]]) -> [PatchController.Effect] {
      
      return [
        .patchChange([.type], { v in
          guard let params = paramMap[v] else {
            return knobCount.map { .dimItem(true, [.param, .i($0)], dimAlpha: 0) }
          }

          return knobCount.flatMap { index in
            let id: SynthPath = [.param, .i(index)]
            guard index < params.count else {
              return [.dimItem(true, id, dimAlpha: 0)]
            }
            let (label, span) = params[index]
            guard label != "" else {
              return [.dimItem(true, id, dimAlpha: 0)]
            }
            return [
              .setCtrlLabel(id, label),
              .configCtrl(id, .span(span)),
              .dimItem(false, id),
            ]
          }
        }),
        .dimsOn([.type], id: nil),
      ]
    }
    
    static var fx1: PatchController {
      return .patch(prefix: .fixed([.fx, .i(0)]), [
        .grid([[
          .select("FX 1", [.type]),
        ] + 11.map { .knob("\($0)", [.param, .i($0)]) } + [
          .switsch("Output", [.out, .assign]),
          .knob("Delay", [.delay]),
          .knob("Reverb", [.reverb]),
        ]])
      ], effects: fxController(knobCount: 11, paramMap: Effect1.paramMap))
    }

    static var fx2: PatchController {
      return .patch(prefix: .fixed([.fx, .i(1)]), [
        .grid([[
          .select("FX 2", [.type]),
        ] + 8.map { .knob("\($0)", [.param, .i($0)]) } + [
          .knob("Delay", [.delay]),
          .knob("Reverb", [.reverb]),
        ]])
      ], effects: fxController(knobCount: 8, paramMap: Effect2.paramMap))
    }

    static var arp: PatchController {
      return .patch([
        .grid([[
          .select("Arp", nil, id: [.arp]),
          .select("Style", [.ctrl, .style]),
          .knob("Grid", [.ctrl, .resolution]),
          .knob("Duration", [.ctrl, .length]),
          .select("Motif", [.ctrl, .motif]),
          .knob("Velocity", [.ctrl, .velo]),
          .knob("Range", [.ctrl, .octave, .range]),
          .knob("Accent", [.ctrl, .accent, .rate]),
        ]]),
      ], effects: [
        .setup([.configCtrl([.arp], .opts(ParamOptions(optArray: ["Off", "Digital 1", "Digital 2", "Drums", "Analog"])))]),
        .controlChange([.arp], { state, locals in
          let value = locals[[.arp]]
          return [
            [.ctrl, .on] : value == 0 ? 0 : 1,
            [.zone, .digital, .i(0), .arp] : value == 1 ? 1 : 0,
            [.zone, .digital, .i(1), .arp] : value == 2 ? 1 : 0,
            [.zone, .analog, .arp] : value == 3 ? 1 : 0,
            [.zone, .rhythm, .arp] : value == 4 ? 1 : 0,
          ]
        }),
        .patchChange(paths: [
          [.ctrl, .on],
          [.zone, .digital, .i(0), .arp],
          [.zone, .digital, .i(1), .arp],
          [.zone, .analog, .arp],
          [.zone, .rhythm, .arp],
        ], { values in
          let value: Int
          if values[[.ctrl, .on]] == 0 {
            value = 0
          }
          else if values[[.zone, .digital, .i(0), .arp]] == 1 {
            value = 1
          }
          else if values[[.zone, .digital, .i(1), .arp]] == 1 {
            value = 2
          }
          else if values[[.zone, .analog, .arp]] == 1 {
            value = 3
          }
          else if values[[.zone, .rhythm, .arp]] == 1 {
            value = 4
          }
          else {
            value = 5 // shouldn't happen.
          }
          return [.setValue([.arp], value)]
        })
      ])
    }
        
    static var parts: PatchController {
      return .patch([
        .child(digitalPart(index: 0), "p0"),
        .child(digitalPart(index: 1), "p1"),
        .child(rhythmPart, "p2"),
        .child(analogPart, "p3"),
      ], layout: [
        .simpleGrid([4.map { ("p\($0)", 1) }])
      ])
    }
    
    static func partController(label: String, prefix: SynthPath, pathPrefix: SynthPathItem, partType: JDXiPartPatchBuilder.Type) -> PatchController {
      let bankBlocks: [PatchController.Effect] = .ctrlBlocks([.bank, .lo], param: .opts(ParamOptions(opts: partType.bankOptions)))
      let patchSel = patchSelector(pathPrefix: pathPrefix, partType: partType)
      
      return .patch(prefix: .fixed(prefix), [
        .panel("on", color: 2, [[
          .checkbox(label, [.on]),
          .select("Bank", nil, id: [.bank, .lo]),
          .select("Program", [.pgm]),
        ]]),
        .panel("level", color: 2, [[
          .knob("Level", [.level]),
          .knob("Delay", [.delay]),
          .knob("Reverb", [.reverb]),
          .select("Output", [.out, .assign]),
        ]]),
        .panel("mute", color: 2, [[
          .knob("Channel", [.channel]),
          .checkbox("Mute", [.mute]),
          .switsch("Mono/Poly", [.poly]),
          .switsch("Legato", [.legato]),
        ]]),
        .panel("pitch", color: 2, [[
          .knob("Octave", [.octave, .shift]),
          .knob("Coarse", [.coarse]),
          .knob("Fine", [.fine]),
          .knob("Bend", [.bend]),
        ]]),
        .panel("filter", color: 2, [[
          .knob("Cutoff", [.cutoff]),
          .knob("Reson", [.reson]),
        ]]),
        .panel("porta", color: 2, [[
          .switsch("Porta", [.porta]),
          .knob("Time", [.porta, .time]),
        ]]),
        .panel("env", color: 2, [[
          .knob("Attack", [.attack]),
          .knob("Decay", [.decay]),
          .knob("Release", [.release]),
          .knob("Velo", [.velo]),
        ]]),
        .panel("vib", prefix: [.vib], color: 2, [[
          .knob("Vib Speed", [.rate]),
          .knob("Depth", [.depth]),
          .knob("Delay", [.delay]),
        ]]),
        .panel("pan", color: 2, [[
          .knob("Pan", [.pan]),
        ]]),
        .panel("velo", prefix: [.velo], color: 2, [[
          .knob("Fade L", [.fade, .lo]),
          .knob("Velo Rng L", [.range, .lo]),
          .knob("Velo Rng U", [.range, .hi]),
          .knob("Fade U", [.fade, .hi]),
        ]]),

      ], effects: [
        .dimsOn([.on], id: nil),
        .patchChange([.bank, .lo], { [.dimItem($0 == 127, [.pgm], dimAlpha: 0)] }),
      ] + bankBlocks + patchSel, layout: [
        .simpleGrid([
          [("on", 4)],
          [("level", 4)],
          [("mute", 4)],
          [("pitch", 4)],
          [("filter", 2), ("porta", 2)],
          [("env", 4)],
          [("vib", 3), ("pan", 1)],
          [("velo", 4)],
        ])
      ])
            
//      vc.addBorder(level: 2)
    }
    
    static func patchSelector(pathPrefix: SynthPathItem, partType: JDXiPartPatchBuilder.Type) -> [PatchController.Effect] {

      let isDigital = pathPrefix == .digital
      let opts64 = ParamOptions(optArray: isDigital ? Digital1Part.patchOptions : partType.patchOptions)
      let opts65 = ParamOptions(optArray: isDigital ? Digital2Part.patchOptions : partType.patchOptions)

      return .patchSelector(id: [.pgm], bankValue: [.bank, .lo]) { value in
        switch value {
        case 64:
          return .opts(opts64)
        case 65:
          return .opts(opts65)
        default:
          return .fullPath([pathPrefix, .i(value), .name])
        }
      }
    }

    static func digitalPart(index: Int) -> PatchController {
      let partType: JDXiPartPatchBuilder.Type = index == 0 ? Digital1Part.self : Digital2Part.self
      return partController(label: "Digital \(index + 1)", prefix: [.digital, .i(index)], pathPrefix: .digital, partType: partType)
    }
      
    static var analogPart: PatchController {
      partController(label: "Analog", prefix: [.analog], pathPrefix: .analog, partType: AnalogPart.self)
    }
    
    static var rhythmPart: PatchController {
      partController(label: "Drums", prefix: [.rhythm], pathPrefix: .rhythm, partType: DrumPart.self)
    }
    
  }
}

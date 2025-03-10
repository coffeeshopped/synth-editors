
extension XV.Perf {
    
  enum Controller {
    
    static func controller(config: XV.CtrlConfig) -> PatchController {
      let hasFX2 = config.is5050
      let items = ["Common", "FX"] + (hasFX2 ? ["FX2"] : []) + (config.partCount / 2).map {
        "\($0 * 2 + 1)/\($0 * 2 + 2)"
      }

      var paths: [SynthPath] = [[.common], [.fx]]
      if hasFX2 {
        paths.append([.fx, .extra])
      }

      return .paged([
        .switcher(items, color: 1),
      ], effects: [
      ], layout: [
        .grid([
          (row: [("switch", 1)], height: 1),
          (row: [("page", 1)], height: 8),
        ])
      ], pages: .map(paths + (config.partCount / 2).map { [.part, .i($0)] }, [
        [.common] : common(is5080: config.is5080),
        [.fx] : XV.Voice.Controller.fxController(0, config: config),
        [.part] : parts(config: config),
        [.fx, .extra] : fx2(config: config),
      ]))
    }
    
    static func common(is5080: Bool = false) -> PatchController {
      var soloItems: [PatchController.PanelItem] = [
        .select("Solo Part", [.solo]),
        .select("MFX Ctrl Ch", [.fx, .ctrl, .channel]),
      ]
      if is5080 {
        soloItems += [
          .checkbox("MFX Rcv MIDI 1", [.fx, .ctrl, .midi, .i(0)]),
          .checkbox("MFX Rcv MIDI 2", [.fx, .ctrl, .midi, .i(1)]),
        ]
      }
      soloItems += [.select("MFXA Src", [.fx, .i(0), .src])]
      if is5080 {
        soloItems += [
          .select("MFXB Src", [.fx, .i(1), .src]),
          .select("MFXC Src", [.fx, .i(2), .src]),
        ]
      }
      soloItems += [
        .select("Chorus Src", [.chorus, .src]),
        .select("Reverb Src", [.reverb, .src])
      ]
      
      var reserve: [PatchController.Builder] = [
        .panel("reserve0", [8.map {
          .knob($0 == 0 ? "Voice Rsrv 1" : "\($0 + 1)", [.voice, .reserve, .i($0)])
        }]),
        .panel("reserve1", [(8..<16).map {
          .knob("\($0 + 1)", [.voice, .reserve, .i($0)])
        }]),
      ]
      if is5080 {
        reserve += [
          .panel("reserve2", [(16..<24).map {
            .knob("\($0 + 1)", [.voice, .reserve, .i($0)])
          }]),
          .panel("reserve3", [(24..<32).map {
            .knob("\($0 + 1)", [.voice, .reserve, .i($0)])
          }]),
        ]
      }

      return .patch(prefix: .fixed([.common]), color: 1, [
        .panel("solo", [soloItems]),
      ] + reserve, effects: [
      ], layout: [
        .simpleGrid([
          [("solo", 1)],
          [("reserve0",1)],
          [("reserve1",1)],
        ] + (is5080 ? [
          [("reserve2",1)],
          [("reserve3",1)],
        ] : []))
      ])
    }
    
    static func fx2(config: XV.CtrlConfig) -> PatchController {
      return .patch([
        .child(XV.FX.Controller.mfx(index: 1, config: config), "b"),
        .child(XV.FX.Controller.mfx(index: 2, config: config), "c"),
      ], layout: [
        .simpleGrid([
          [("b", 1)],
          [("c", 1)],
        ])
      ])
    }
    
    static func corePart(config: XV.CtrlConfig) -> PatchController {

      var builders: [PatchController.Builder] = [
        .panel("on", color: 2, [[
          .checkbox("On", [.on]),
          .switsch("Type", nil, id: [.bank, .hi]),
          .select("Group", nil, id: [.bank, .lo]),
          .select("Program", nil, id: [.pgm, .number]),
          .knob("Channel", [.channel]),
          .knob("Level", [.level]),
          .checkbox("Mute", [.mute]),
        ]]),
        .panel("poly", color: 2, [[
          .switsch("Poly", [.poly]),
          .checkbox("Legato", [.legato]),
          .switsch("Porta", [.porta]),
          .knob("Porta T", [.porta, .time]),
          .knob("Pan", [.pan]),
        ]]),
        .panel("oct", color: 2, [[
          .knob("Octave", [.octave, .shift]),
          .knob("Coarse", [.coarse]),
          .knob("Fine", [.fine]),
        ]]),
        .panel("attack", color: 2, [[
          .knob("Attack", [.attack]),
        ] + (config.hasVibAndDecay ? [
            .knob("Decay", [.decay]),
          ] : []) + [
          .knob("Release", [.release]),
        ]]),
        .panel("velo", color: 2, [[
          .knob("Velo", [.velo]),
          .knob("Bend", [.bend]),
        ]]),
        .panel("filter", color: 2, [[
          .knob("Cutoff", [.cutoff]),
          .knob("Reson", [.reson]),
        ]]),
        .panel("out", color: 2, [[
          .knob("Dry", [.dry]),
          .knob("Chorus", [.chorus]),
          .knob("Reverb", [.reverb]),
          .switsch("MFX", [.out, .fx]),
          .select("Out Assign", [.out, .assign]),
        ]]),
        .panel("key", color: 2, [[
          .knob("Fade→", [.key, .fade, .lo]),
          .knob("Key Lo", [.key, .lo]),
          .knob("Key Hi", [.key, .hi]),
          .knob("←Fade", [.key, .fade, .hi]),
          ]]),
        .nav("Edit", [], color: 2),
      ]
      
      if config.hasVibAndDecay {
        builders += [.panel("vib", color: 2, [[
          .knob("Vib Rate", [.vib, .rate]),
          .knob("Vib Depth", [.vib, .depth]),
          .knob("Vib Delay", [.vib, .delay]),
        ]])]
      }
      
      var effects: [PatchController.Effect] = [
        .indexChange({ [
          .setCtrlLabel([.nav], "Edit Part \($0 + 1)"),
          .setNavPath([.part, .i($0)]),
        ] }),
        .setup([
          .configCtrl([.bank, .hi], .opts(ParamOptions(optArray: ["Patch", "Rhythm"]))),
        ]),
        .patchChange([.bank, .hi], {
          let partType = XV.Perf.partType(forHi: $0)
          return [
            .setValue([.bank, .hi], partType == .patch ? 0 : 1),
            .configCtrl([.bank, .lo], .opts(ParamOptions(opts: partType == .patch ? config.partConfig.voicePartGroups : config.partConfig.rhythmPartGroups))),
          ]
        }),
        .controlChange([.bank, .hi], { state, locals in
          let hi = state.prefixedValue([.bank, .hi]) ?? 0
          let modded = hi - (hi % 2)
          return [
            [.bank, .hi] : modded + (1 - (locals[[.bank, .hi]] ?? 0)),
          ]
        }),
        .patchChange(paths: [[.bank, .hi], [.bank, .lo]], { values in
          guard let hi = values[[.bank, .hi]],
            let lo = values[[.bank, .lo]] else { return [] }
          let synthPath = XV.Perf.partGroup(forHi: hi, lo: lo)
          return [
            .setValue([.bank, .lo], XV.Perf.Part.value(forSynthPath: synthPath)),
          ]
        }),
        .controlChange([.bank, .lo], { state, locals in
          let hi = state.prefixedValue([.bank, .hi]) ?? 0
          let synthPath = XV.Perf.Part.synthPath(forValue: locals[[.bank, .lo]] ?? 0)
          let newPair = XV.Perf.hiLo(forSynthPath: synthPath)
          let partType = XV.Perf.partType(forHi: hi)
          return [
            [.bank, .hi] : newPair.0 + (partType == .patch ? 1 : 0),
            [.bank, .lo] : newPair.1,
          ]
        }),
        .patchChange(paths: [[.bank, .hi], [.bank, .lo], [.pgm, .number]], { values in
          guard let hi = values[[.bank, .hi]],
                let lo = values[[.bank, .lo]],
                let pgmNumber = values[[.pgm, .number]] else { return [] }
          let partGroup = XV.Perf.partGroup(forHi: hi, lo: lo)
          let baseLo = XV.Perf.hiLo(forSynthPath: partGroup).1
          return [.setValue([.pgm, .number], pgmNumber + (128 * (lo - baseLo)))]
        }),
        .controlChange([.pgm, .number], { state, locals in
          let hi = state.prefixedValue([.bank, .hi]) ?? 0
          let lo = state.prefixedValue([.bank, .lo]) ?? 0
          let synthPath = XV.Perf.partGroup(forHi: hi, lo: lo)
          // have to get newPair because lo might not be the "base" low value
          let newPair = XV.Perf.hiLo(forSynthPath: synthPath)
          let v = locals[[.pgm, .number]] ?? 0
          return [
            [.pgm, .number] : v % 128,
            [.bank, .lo] : newPair.1 + (v / 128),
          ]
        }),
        .dimsOn([.on], id: nil),
      ]
      
      effects += .patchSelector(id: [.pgm, .number], bankValues: [[.bank, .hi], [.bank, .lo]]) { values, state, locals in
        guard let hi = values[[.bank, .hi]],
              let lo = values[[.bank, .lo]] else { return .fullPath([]) }
        
        let partType = XV.Perf.partType(forHi: hi)
        let partGroup = XV.Perf.partGroup(forHi: hi, lo: lo)
        let isPatchPart = partType == .patch
        
        let opts: [Int:String]
        switch partGroup.first {
        case .int:
          let subId = partGroup.subpath(from: 1)
          switch subId {
          case [.user]:
            return .fullPath(isPatchPart ? [.patch, .name] : [.rhythm, .name])
          default:
            let presets = isPatchPart ? config.partConfig.voicePresets : config.partConfig.rhythmPresets
            opts = presets[subId]?.numPrefix() ?? [:]
          }
        case .srx:
          guard let board = SRXBoard.boards[partGroup.i(1) ?? 0] else { return .fullPath([]) }
          opts = (isPatchPart ? board.patchOptions : board.rhythmOptions).numPrefix()
        case .srjv:
          guard let board = SRJVBoard.boards[partGroup.i(1) ?? 0] else { return .fullPath([]) }
          opts = (isPatchPart ? board.patchOptions : board.rhythmOptions).numPrefix()
        default:
          opts = [:]
        }
        return .opts(ParamOptions(opts: opts))
      }

      return .index([.part], label: [.on], { "Part \($0 + 1)" }, builders, effects: effects, layout: [
        .simpleGrid([
          [("on", 8)],
          [("poly", 5), ("oct", 3)],
          [("attack", 3)] + (config.hasVibAndDecay ? [("vib", 3)] : []) + [("velo", 2)],
          [("filter", 2), ("out", 5.5)],
          [("key", 4), ("nav", 4)],
        ])
      ])
    }
    
    static func scale() -> PatchController {
      .patch(prefix: .index([.part]), color: 2, [
        .grid(prefix: [.scale, .tune], [[
          .knob("C", [.i(0)]),
          .knob("C#", [.i(1)]),
          .knob("D", [.i(2)]),
          .knob("D#", [.i(3)]),
        ],[
          .knob("E", [.i(4)]),
          .knob("F", [.i(5)]),
          .knob("F#", [.i(6)]),
          .knob("G", [.i(7)]),
        ],[
          .knob("G#", [.i(8)]),
          .knob("A", [.i(9)]),
          .knob("A#", [.i(10)]),
          .knob("B", [.i(11)]),
        ]])
      ])
    }
    
    static func receives() -> PatchController {
      .patch(prefix: .index([.midi]), color: 3, [
        .grid([[
          .checkbox("Pgm Ch", [.rcv, .pgmChange]),
          .checkbox("Bank Select", [.rcv, .bank]),
          .checkbox("Bend", [.rcv, .bend]),
          .checkbox("Poly Key Press", [.rcv, .poly, .pressure]),
        ],[
          .checkbox("Ch Press", [.rcv, .channel, .pressure]),
          .checkbox("Mod", [.rcv, .mod]),
          .checkbox("Volume", [.rcv, .volume]),
          .checkbox("Pan", [.rcv, .pan]),
        ],[
          .checkbox("Expr", [.rcv, .expression]),
          .checkbox("Hold-1", [.rcv, .hold]),
          .checkbox("Phase Lock", [.phase, .lock]),
          .switsch("Velo Crv", [.velo, .curve]),
        ]]),
      ])
    }
    
    static func part(config: XV.CtrlConfig) -> PatchController {
      let scale: PatchController.Builder = config.hasScaleTune ? .child(scale(), "scale") : .panel("scale", [[]])

      return .patch(border: 1, [
        .child(corePart(config: config), "core"),
        .child(receives(), "rcv"),
        scale,
      ], effects: [
        .indexChange({ [
          .setIndex("core", $0),
          .setIndex("rcv", $0),
          .dimPanel($0 > 15, "rcv", dimAlpha: 0),
        ] + (config.hasScaleTune ? [.setIndex("scale", $0)] : []) })
      ], layout: [
        .row([("core",1)]),
        .row([("scale",4), ("rcv",4)]),
        .col([("core",5), ("scale",3)]),
      ])
    }
    
    static func parts(config: XV.CtrlConfig) -> PatchController {
      .oneRow(2, child: part(config: config)) { parentIndex, offset in
        parentIndex * 2 + offset
      }
    }
    
  }
  
}

//
//  FS1RPerfController.swift
//  Patch Base
//
//  Created by Chadwick Wood on 8/12/18.
//  Copyright © 2018 Coffeeshopped LLC. All rights reserved.
//

import PBAPI

extension FS1R.Perf {
  
  enum Controller {
    
    static var controller: PatchController {
      return .paged([
        .switcher(["Part 1","Part 2","Part 3","Part 4","Fseq", "FX/EQ","Ctrl 1-4","Ctrl 5-8"], color: 1),
        .panel("cat", color: 1, [[
          .select("Category", [.category]),
          .knob("Volume", [.volume]),
          .knob("Pan", [.pan]),
          .knob("Note Shift", [.note, .shift]),
          .switsch("Indiv Out", [.part, .out]),
        ]])

      ], effects: [
      ], layout: [
        .grid([
          ([("switch", 10.5), ("cat", 5.5)], height: 1),
          ([("page", 1)], height: 6),
        ])
      ], pages: .map(4.map { [.part, .i($0)] } + [[.fseq], [.fx]] + 2.map { [.ctrl, .i($0)] }, [
        [.part] : part,
        [.fx] : fx,
        [.fseq] : fseq,
        [.ctrl] : quadVC,
      ]))
    }
    
    static var fseq: PatchController {
      
      let ccBlock: PatchController.ControlChangeFn = { state, locals in
        let speedType = locals[[.speed, .type]] ?? 0
        let coarse = locals[[.coarse]] ?? 0
        let fine = locals[[.fine]] ?? 0
        let value = speedType < 5 ? speedType : min(5000, coarse * 10 + fine)
        return [.paramsChange([[.speed] : value])]
      }

      let patchSel: [PatchController.Effect] = .patchSelector(id: [.number], bankValue: [.bank]) { bank in
        switch bank {
        case 0:
          return .fullPath([.fseq, .name])
        default:
          return .opts(ParamOptions(opts: presetFseqOptions))
        }
      }

      return .patch(prefix: .fixed([.fseq]), [
        .panel("part", color: 1, [[
          .switsch("Fseq Part", [.part]),
          .switsch("Bank", [.bank]),
          .select("Number", [.number]),
        ]]),
        .panel("speed", color: 1, [[
          .select("Speed", nil, id: [.speed, .type]),
          .knob("Coarse", nil, id: [.coarse]),
          .knob("Fine", nil, id: [.fine]),
          .switsch("Speed", nil, id: [.speed]),
          .knob("Velo > Speed", [.speed, .velo]),
        ]]),
        .panel("delay", color: 1, [[
          .knob("Delay", [.formant, .seq, .delay]),
          .knob("Start", [.start]),
          .knob("Loop St", [.loop, .start]),
          .knob("Loop End", [.loop, .end]),
          .switsch("Lp Mode", [.loop]),
        ]]),
        .panel("mode", color: 1, [[
          .switsch("Play Mode", [.mode]),
          .switsch("Fmt Pitch", [.formant, .pitch]),
          .switsch("Trigger", [.trigger]),
          .knob("Velo > Level", [.level, .velo]),
        ]]),
      ], effects: [
        .patchChange([.speed], { value in
          var changes = [PatchController.AttrChange]()
          let percsHidden: Bool
          switch value {
          case 0...4:
            percsHidden = true
            changes.append(.setValue([.speed, .type], value))
          default:
            percsHidden = false
            changes += [
              .setValue([.speed, .type], 5),
              .setValue([.coarse], max(10, value / 10)),
              .setValue([.fine], value < 100 ? 0 : value % 10),
              .configCtrl([.speed], .opts(ParamOptions(optArray: [value < 100 ? "10%" : "\(Float(value)/10)%"])))
            ]
          }
          return changes + [
            .dimItem(percsHidden, [.coarse], dimAlpha: 0),
            .dimItem(percsHidden, [.fine], dimAlpha: 0),
            .dimItem(percsHidden, [.speed], dimAlpha: 0),
          ]
        }),
        .dimsOn([.part], id: nil),
        .controlChange([.speed, .type], fn: ccBlock),
        .controlChange([.coarse], fn: ccBlock),
        .controlChange([.fine], fn: ccBlock),
        .setup([
          .configCtrl([.speed, .type], .opts(ParamOptions(optArray: fseqMidiSpeedOptions + ["%"]))),
          .configCtrl([.coarse], .opts(ParamOptions(range: 10...500))),
          .configCtrl([.fine], .opts(ParamOptions(range: 0...9))),
        ])
      ] + patchSel, layout: [
        .simpleGrid([
          [("part", 3.5), ("speed", 5.5)],
          [("delay", 5), ("mode", 4)],
        ])
      ])
    }
    
    static var perfVC: PatchController {
      return .index([.ctrl], label: [.part], { "VC \($0 + 1)" }, [
        .panel("part", color: 1, [[
          .checkbox("Part 1", [.part, .i(0)]),
          .checkbox("2", [.part, .i(1)]),
          .checkbox("3", [.part, .i(2)]),
          .checkbox("4", [.part, .i(3)]),
        ]]),
        .panel("label", [[.label("?", size: 15, id: [.part])]]),
        .panel("dest", color: 1, [[
          .select("Destination", [.dest]),
          .knob("Depth", [.depth]),
        ]]),
        .panel("knob", color: 1, [[
          .checkbox("Knob 1", [.knob, .i(0)]),
          .checkbox("2", [.knob, .i(1)]),
          .checkbox("3", [.knob, .i(2)]),
          .checkbox("4", [.knob, .i(3)]),
        ]]),
        .panel("mc", color: 1, [[
          .checkbox("MC 1", [.midi, .ctrl, .i(0)]),
          .checkbox("2", [.midi, .ctrl, .i(1)]),
          .checkbox("3", [.midi, .ctrl, .i(2)]),
          .checkbox("4", [.midi, .ctrl, .i(3)]),
        ]]),
        .panel("foot", color: 1, [[
          .checkbox("Foot", [.foot]),
          .checkbox("Breath", [.breath]),
          .checkbox("Mod Wh", [.modWheel]),
        ]]),
        .panel("after", color: 1, [[
          .checkbox("Chan Aftert", [.channel, .aftertouch]),
          .checkbox("Poly Aftert", [.poly, .aftertouch]),
          .checkbox("P Bend", [.bend]),
        ]]),
      ], effects: [
      ], layout: [
        .simpleGrid([
          [("part", 1)],
          [("label", 3),("dest", 5)],
          [("knob", 1)],
          [("mc", 1)],
          [("foot", 1)],
          [("after", 1)],
        ])
      ])
//      vc.addBorder()
    }
      

    static var quadVC: PatchController {
      return .oneRow(4, child: perfVC) { parentIndex, offset in
        4 * parentIndex + offset
      }
    }

    static var fx: PatchController {
      return .patch([
        .child(reverb, "reverb", color: 3),
        .child(vary, "vary", color: 3),
        .child(insert, "insert", color: 3),
        .panel("eq", color: 3, [[
          .knob("Lo Gain", [.lo, .gain]),
          .knob("Lo Freq", [.lo, .freq]),
          .knob("Lo Q", [.lo, .q]),
          .switsch("Lo Shape", [.lo, .shape]),
        ],[
          .knob("Mid Gain", [.mid, .gain]),
          .knob("Mid Freq", [.mid, .freq]),
          .knob("Mid Q", [.mid, .q]),
        ],[
          .knob("Hi Gain", [.hi, .gain]),
          .knob("Hi Freq", [.hi, .freq]),
          .knob("Hi Q", [.hi, .q]),
          .switsch("Hi Shape", [.hi, .shape]),
        ]]),
      ], effects: [
      ], layout: [
        .row([("reverb",12),("eq",4)], opts: [.alignAllTop]),
        .col([("reverb",2),("vary",2),("insert",2)]),
        .eq(["reverb","vary","insert"], .trailing),
        .eq(["vary","eq"], .bottom),
      ])
    }
    
    
    static func fxTypeEffect(params: [[Int:(String,Param)]]) -> PatchController.Effect {
      return .patchChange([.type]) { value in
        guard value < params.count else { return [] }
        let info = params[value]
        return 16.flatMap { i in
          let id: SynthPath = [.i(i)]
          guard let pair = info[i] else { return [.dimItem(true, id, dimAlpha: 0)] }
          return [
            .setCtrlLabel(id, pair.0),
            .configCtrl(id, .param(pair.1)),
            .dimItem(false, id),
          ]
        }
      }
    }

    static var reverb: PatchController {
      return .patch(prefix: .fixed([.reverb]), [
        .grid([
          [
            .select("Reverb", [.type]),
            .knob("Pan", [.pan]),
            .knob("Return", [.level]),
          ] + 6.map { .knob("\($0)", [.i($0)]) },
          (6..<16).map { .knob("\($0)", [.i($0)]) },
        ]),
      ], effects: [fxTypeEffect(params: reverbParams)])
    }

    static var vary: PatchController {
      return .patch(prefix: .fixed([.vary]), [
        .grid([
          [
            .select("Variation", [.type]),
            .knob("Pan", [.pan]),
            .knob("Return", [.level]),
            .knob("> Verb", [.reverb]),
          ] + 5.map { .knob("\($0)", [.i($0)]) },
          (5..<16).map { .knob("\($0)", [.i($0)]) },
        ]),
      ], effects: [fxTypeEffect(params: varyParams)])
    }

    static var insert: PatchController {
      return .patch(prefix: .fixed([.insert]), [
        .grid([
          [
            .select("Insert", [.type]),
            .knob("Pan", [.pan]),
            .knob("Return", [.level]),
            .knob("> Verb", [.reverb]),
            .knob("> Vari", [.vary]),
          ] + 5.map { .knob("\($0)", [.i($0)]) },
          (5..<16).map { .knob("\($0)", [.i($0)]) },
        ]),
      ], effects: [fxTypeEffect(params: insertParams)])
    }
    
    static var part: PatchController {
      
      let portaEffects: [PatchController.Effect] = .ctrlBlocks([.porta], value: {
        $0 == 2 ? 0 : $0 // value of 2 is off (as is 0)
      })
      let chanMaxEffects: [PatchController.Effect] = .ctrlBlocks([.channel, .hi]) {
        $0 < 16 ? $0 : 0x7f // sometimes fs1r sends out of range values, so clamp
      }
      let patchSel: [PatchController.Effect] = .patchSelector(id: [.pgm], bankValue: [.bank]) {
        if $0 == 1 {
          return .fullPath([.patch, .name])
        }
        else {
          let ramIndex = min(max(0, $0 - 2), FS1R.Voice.ramBanks.count - 1)
          return .opts(ParamOptions(optArray: FS1R.Voice.ramBanks[ramIndex]))
        }
      }
      let effects: [PatchController.Effect] = portaEffects + chanMaxEffects + patchSel
      
      let AllPaths: [SynthPath] = patchTruss.params.keys.compactMap {
        guard $0.starts(with: [.part, .i(0)]) else { return nil }
        return $0.subpath(from: 2)
      }

      return .patch(prefix: .index([.part]), [
        .button("Part", color: 2),
        .nav("Edit Voice", [], color: 2),
        .panel("reserve", color: 2, [[
          .select("Bank", [.bank]),
          .select("Program", [.pgm]),
          .select("Chan", [.channel]),
          .select("Chan Max", nil, id: [.channel, .hi]),
          .knob("Note Reserve", [.note, .reserve]),
          .switsch("Mono", [.poly]),
          .switsch("Priority", [.mono, .priority]),
          .knob("Note Shift", [.note, .shift]),
          .knob("Detune", [.detune]),
          .knob("V/N Balance", [.voiced, .unvoiced]),
        ]]),
        .panel("velo", color: 2, [[
          .knob("Velo Depth", [.velo, .depth]),
          .knob("Velo Offset", [.velo, .offset]),
        ]]),
        .panel("pan", color: 2, [[
          .knob("Pan", [.pan]),
          .knob("LFO Depth", [.pan, .lfo, .depth]),
          .knob("Pan Scale", [.pan, .scale]),
        ]]),
        .panel("bend", color: 2, [[
          .knob("Bend Lo", [.bend, .lo]),
          .knob("Bend Hi", [.bend, .hi]),
        ]]),
        .panel("send", color: 2, [[
          .knob("Volume", [.volume]),
          .knob("Dry", [.level]),
          .knob("Variation", [.vary]),
          .knob("Reverb", [.reverb]),
          .checkbox("Insert", [.insert]),
        ]]),
        .panel("filter", color: 2, [[
          .checkbox("Filter", [.filter, .on]),
          .knob("Cutoff", [.cutoff]),
          .knob("Reson", [.reson]),
          .knob("Filter Env", [.filter, .env, .depth]),
        ]]),
        .panel("lfo1", color: 2, [[
          .knob("LFO 1 Rate", [.lfo, .i(0), .rate]),
          .knob("Delay", [.lfo, .i(0), .delay]),
          .knob("Pitch Mod", [.lfo, .i(0), .pitch, .mod]),
        ]]),
        .panel("lfo2", color: 2, [[
          .knob("LFO2 Rate", [.lfo, .i(1), .rate]),
          .knob("LFO2 Depth", [.lfo, .i(1), .depth]),
        ]]),
        .panel("env", color: 2, [[
          .knob("Attack", [.env, .attack]),
          .knob("Decay", [.env, .decay]),
          .knob("Release", [.env, .release]),
        ]]),
        .panel("knob", color: 2, [[
          .knob("Formant", [.formant]),
          .knob("FM", [.fm]),
        ]]),
        .panel("pitch", color: 2, [[
          .knob("Pitch Env Init", [.pitch, .env, .innit]),
          .knob("Attack", [.pitch, .env, .attack]),
          .knob("Release L", [.pitch, .env, .release, .level]),
          .knob("Rel Time", [.pitch, .env, .release, .time]),
        ]]),
        .panel("porta", color: 2, [[
          .switsch("Porta", nil, id: [.porta]),
          .knob("Time", [.porta, .time]),
        ]]),
        .panel("limit", color: 2, [[
          .knob("Note Lo", [.note, .lo]),
          .knob("Note Hi", [.note, .hi]),
          .knob("Velo Lo", [.velo, .lo]),
          .knob("Velo Hi", [.velo, .hi]),
          .knob("Expr Lo Limit", [.pedal, .lo]),
          .checkbox("Rx Sustain", [.sustain, .rcv]),
        ]]),
      ], effects: [
        .patchChange(paths: [[.bank], [.channel]], { values in
          [
            .dimPanel(values[[.bank]] == 0 || (values[[.channel]] ?? 0) > 16, nil),
            .dimItem(values[[.bank]] == 0, [.pgm], dimAlpha: 0),
          ]
        }),
        .patchChange([.filter, .on], { [
          .dimItem($0 == 0, [.cutoff]),
          .dimItem($0 == 0, [.reson]),
          .dimItem($0 == 0, [.filter, .env, .depth]),
        ] }),
        .patchChange([.insert], { [
          .dimItem($0 != 0, [.level]),
          .dimItem($0 != 0, [.vary]),
          .dimItem($0 != 0, [.reverb]),
        ] }),
        .patchChange([.channel], { [.dimItem($0 > 15, [.channel, .hi], dimAlpha: 0)] }),
        .editMenu([.button], paths: AllPaths, type: "FS1RPart", init: nil, rand: nil),
        .indexChange({ [
          .setCtrlLabel([.button], "Part \($0 + 1)"),
          // Might be better without this?
//          .setCtrlLabel([.nav], "Edit Part \($0 + 1)"),
          .setNavPath([.part, .i($0)]),
        ] })
      ] + effects, layout: [
        .simpleGrid([
          [("button", 2), ("reserve", 12), ("nav", 2)],
          [("send", 5), ("velo", 2), ("pan", 3), ("bend", 2)],
          [("filter", 4), ("lfo1", 3), ("lfo2", 2), ("env", 3),("knob", 2)],
          [("pitch", 4), ("porta", 2), ("limit", 6)],
        ])
      ])
    }
    
  }
  
}

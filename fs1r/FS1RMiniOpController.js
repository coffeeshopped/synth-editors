
let AllPaths: [SynthPath] = patchTruss.params.keys.compactMap {
    guard $0.starts(with: "op/0") else { return nil }
    return $0.subpath(from: 2)
  }

const env = prefix => {
    let prefix = prefix + "amp/env"
    let env: PatchController.Display = .timeLevelEnv(pointCount: 5, sustain: 3)
    let maps: [PatchController.DisplayMap] = [
      .src("level", dest: "gain", { $0 / 99 }),
      .src("hold", dest: "time/0", { $0 / 99 }),
    ] + 3.flatMap { [
      .src("time/$0", dest: "time/$0 + 1", { $0 / 99 }),
      .src("level/$0", dest: "level/$0 + 1", { $0 / 99 }),
    ] } + [
      .src("time/3", dest: "time/4", { $0 / 99 }),
      .src("level/3", dest: "level/4", { $0 / 99 }),
      .src("level/3", dest: "level/0", { $0 / 99 }),
    ]
    return .display(env, nil, maps.map { $0.srcPrefix(prefix) }, id: prefix)
  }
  
  const ctrlr = ['index', "op", "op", i => `${i + 1}`, {
    builders: [
      ['items', {}, [
        [env("voiced"), "env"],
        [env("unvoiced"), "nenv"],
        [{ l: "?", align: 'leading', size: 11, id: "op"}, "op"],
        [{ l: "x", align: 'trailing', size: 11, bold: false, id: "osc/mode"}, "freq"],
      ]]
    ],
    effects: [
      ['patchChange', {
        paths: ["voiced/osc/mode", "voiced/spectral/form", "voiced/coarse", "voiced/fine", "voiced/detune"], 
        fn: values => {
          const oscMode = values["voiced/osc/mode"]
          const specForm = values["voiced/spectral/form"]
          const coarse = values["voiced/coarse"]
          const fine = values["voiced/fine"]
          const detune = values["voiced/detune"]
          const ratioMode = oscMode == 0 && specForm < 7
          const valText = voicedFreq(oscMode, specForm, coarse, fine)
          // const valText = String(String(format: "%5.3f", voicedFreq(oscMode, specForm, coarse, fine)).prefix(5))
          const detuneOff = detune - 15
          const detuneString = (detuneOff == 0 ? "" : detuneOff < 0 ? detuneOff : `+${detuneOff}`)

          return [
            ['setCtrlLabel', "osc/mode", ratioMode ? `x ${valText}${detuneString}` : `${valText} Hz`]
          ]
        }
      }],
      ['setup', [
        ['colorItem', "voiced/amp/env", 2],
        ['colorItem', "unvoiced/amp/env", 3, true],
        ['colorItem', "op", 1],
        ['colorItem', "osc/mode", 1],
      ]],
      // on-click for the VC's view, send an event up.
      ['click', null, (state, locals) => ['event', "op", state, locals]],
      // .editMenu(nil, paths: AllPaths, type: "Op", init: {
      //   let bd = try! patchTruss.createInitBodyData()
      //   return AllPaths.map { patchTruss.getValue(bd, path: "op/0" + $0) ?? 0 }
      // }(), rand: {
      //   let patch = patchTruss.randomize()
      //   return AllPaths.map { patch["op/0" + $0] ?? 0 }
      // })
    ],
    layout: [
      ['row', [["op",1],["freq",4]]],
      ['row', [["env", 1]]],
      ['colFixed', ["op", "env"], { fixed: "op", height: 11, spacing: 2 }],
      ['row', [["nenv", 1]]],
      ['colFixed', ["op", "nenv"], { fixed: "op", height: 11, spacing: 2 }],
    ]
  }
}

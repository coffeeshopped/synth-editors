
let AllPaths: [SynthPath] = patchTruss.params.keys.compactMap {
    guard $0.starts(with: "op/0") else { return nil }
    return $0.subpath(from: 2)
  }

const env = prefix => ({
  display: 'timeLevelEnv',
  pointCount: 5, 
  sustain: 3,
  maps: ([
    ['u', "level", "gain", 99],
    ['u', "hold", "time/0", 99],
    ['u', "time/3", "time/4", 99],
    ['u', "level/3", "level/4", 99],
    ['u', "level/3", "level/0", 99],
  ]).concat((3).flatMap(i => [
    ['u', ["time", i], ["time", i + 1], 99],
    ['u', ["level", i], ["level", i + 1], 99],
  ])),
  srcPrefix: [prefix, "amp/env"],
  id: [prefix, "amp/env"],
})
  
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
        const oscMode = values["voiced/osc/mode"] || 0
        const specForm = values["voiced/spectral/form"] || 0
        const coarse = values["voiced/coarse"] || 0
        const fine = values["voiced/fine"] || 0
        const detune = values["voiced/detune"] || 0
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

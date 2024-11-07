
const opAmpController = {
  prefix: ['fixed', "amp/env"], 
  builders: [
    ['grid', [[
      {
        display: 'timeLevelEnv',
        pointCount: 5, 
        sustain: 3,
        l: "Amp EG",
        maps: [
          ['u', "hold", "time/0", 99],
          ['u', "level/3", "start/level", 99],
          ['u', "level/3", "level/0", 99],
        ] + (4).flatMap(i => [
          ['u', ["time", i], ["time", i + 1, 99],
          ['u', ["level", i], ["level", i + 1, 99],
        ]), 
        id: "env",
      },
      ["T1", "time/0"],
      ["T2", "time/1"],
      ["T3", "time/2"],
      ["T4", "time/3"],
      ["Velo", "velo"],
      ["Amp Mod", "mod/sens"],
      ],[
      ["T Scale", "time/scale"],
      ["Hold", "hold"],
      ["L1", "level/0"],
      ["L2", "level/1"],
      ["L3", "level/2"],
      ["L4", "level/3"],
      ["EG Bias", "bias/sens"],
      ["Level", "level"],
      [{checkbox: "Mute", id: "mute"}, null],
    ]]]
  ], 
  effects: [
    ['patchChange', "level", v => [['setValue', "mute", v == 0 ? 1 : 0)]]],
    ['controlChange', "mute", (state, locals) => {
      const value = locals["mute"] || 0
      var level = 0
      var changes = []
      if (value > 0) {
        const newLastLevel = state.prefixedValue("level") || 90
        changes.push(['setValue', "extra/level", newLastLevel == 0 ? 90 : newLastLevel])
        level = 0
      }
      else {
        level = locals["extra/level"] || 90
      }
      return changes.concat(['paramsChange', [["level", level]]])
    }],
    ['editMenu', "env", {
      paths: (4).map(i => ["time", i]).concat(
        (4).map(i => ["level", i])
      ).concat(["hold"]), 
      type: "FS1RAmpEnvelope", 
      init: [0, 20, 20, 0, 99, 99, 99, 0, 0], 
      rand: { 9.map { $0 > 6 ? 0 : (0..<100).random()! } }],
    }]
  ]
}

const opFreqController = {
  builders: [
    ['grid', [[
      Controller.freqEnv,
      ["Initial", "freq/env/innit"],
      ["A Level", "freq/env/attack/level"],
      ["Attack", "freq/env/attack"],
      ["Decay", "freq/env/decay"],
    ]]],
  ], 
  effects: [
    Controller.freqEnvMenu,
  ],
}


const opControllerEffects = [
  ['patchChange', "amp/env/level", v => ['dimPanel', v == 0, null]],
  ['paramChange', "fseq/on", parm => [
    ['dimItem', parm.p == 0, "fseq"],
    ['dimItem', parm.p == 0, "fseq/trk"],
  ] }],
]

const voicedPaths: [SynthPath] = patchTruss.params.keys.compactMap {
  guard $0.starts(with: "op/0/voiced") else { return nil }
  return $0.subpath(from: 3)
}

const voicedOp = {
  prefix: ['fixed', "voiced"], 
  border: 2, 
  builders: [
    ['child', opAmpController, "amp", {color: 2}],
    ['child', opFreqController, "freq", {color: 2}],
    ['child', levelScale, "levelScale", {color: 2}],
    ['button', "Op", {color: 2}],
    ['panel', 'osc', { color: 2 }, [[
      [{switch: "Mode"}, "osc/mode"],
      "Ratio", nil, id: "ratio",
      ["Coarse", "coarse"],
      ["Fine", "fine"],
      ["Detune", "detune"],
      ["Transpose", "transpose"],
      ["P Mod", "pitch/mod/sens"],
    ], [
      [{select: "Spectral Form"}, "spectral/form"],
      ["Skirt", "spectral/skirt"],
      ["BW", "freq/ratio/spectral"],
      ["BW Bias", "bw/bias/sens"],
      [{checkbox: "Key Sync"}, "key/sync"],
      ["Freq Scaling", "note/scale"],
      [{checkbox: "Fseq"}, "fseq"],
      ["Fseq Trk", "fseq/trk"],
    ]]],
    ['panel', 'freq2', { color: 2, }, [[
      ["Fr Velo", "freq/velo"],
      ["Fr Mod", "freq/mod/sens"],
      ["Fr Bias", "freq/bias/sens"],
    ]]],
  ], 
  effects: ([
    Controller.spectralFormEffect,
    Controller.oscModeEffect,
    ['indexChange', i => ['setCtrlLabel', "button", `Op ${i + 1} - Voiced`]],
    ['editMenu', "button", {
      paths: voicedPaths, 
      type: "FS1RVoicedOp", 
      init: {
        let bd = patchTruss.createInitBodyData()
        return voicedPaths.map { patchTruss.getValue(bd, path: "op/0/voiced" + $0) ?? 0 }
      }(), 
      rand: {
        let patch = patchTruss.randomize()
        return voicedPaths.map { patch["op/0/voiced" + $0] ?? 0 }
      }
    }],
  ]).concat(opControllerEffects), 
  layout: [
    ['row', [["freq", 6], ["freq2", 3]]],
    ['row', [["button", 3], ["levelScale", 7.5]]],
    ['col', [["osc", 2], ["freq", 1], ["amp", 2], ["button", 1]]],
    ['eq', ["osc","freq2","amp","levelScale"], 'trailing'],
  ])
}

const levelScale = {
  prefix: ['fixed', "level/scale"], 
  builders: [
    ['grid', [[
      {
        display: 'levelScaling',
        maps: [
          ['ident', "left/curve"],
          ['ident', "right/curve"],
          ['u', "left/depth", 99],
          ['u', "right/depth", 99],
          ['u', "brk/pt", 99],
        ],
        id: "level/scale", 
        width: 4,
      },
      ["L Depth", "left/depth"],
      [{switch: "L Curve"}, "left/curve"],
      ["Break Pt", "brk/pt"],
      ["R Depth", "right/depth"],
      [{switch: "R Curve"}, "right/curve"],
    ]]]
  ], 
  effects: [
    ['editMenu', "level/scale", {
      paths: [
        "left/depth",
        "left/curve",
        "right/depth",
        "right/curve",
        "brk/pt",
      ], 
      type: "FS1RRateLevel", 
      init: [0, 3, 0, 0, 39], 
      rand: {
        5.map { $0 % 2 == 1 ? (0..<4).random()! : (0..<100).random()! }
      },
    }],
  ],
}

const unvoicedPaths = patchTruss.params.keys.compactMap {
  guard $0.starts(with: "op/0/unvoiced") else { return nil }
  return $0.subpath(from: 3)
}

const unvoicedOp = {
  prefix: ['fixed', "unvoiced"], 
  border: 3, 
  builders: [
    ['child', opAmpController, "amp", {color: 3}],
    ['child', opFreqController, "freq", {color: 3}],
    ['button', "Op", {color: 3}],
    ['panel', 'osc', { color: 3 }, [[
      [{switch: "Mode"}, "mode"],
      [{switch: "Ratio"}, "ratio"],
      ["Coarse", "coarse"],
      ["Fine", "fine"],
      ["Transpose", "transpose"],
      ["Freq Scale", "note/scale"],
    ],[
      ["Skirt", "skirt"],
      ["BW", "bw"],
      ["BW Bias", "bw/bias/sens"],
      ["Reson", "reson"],
      ["Fr Velo", "freq/velo"],
      ["Fr Mod", "freq/mod/sens"],
      ["Fr Bias", "freq/bias/sens"],
    ]]],
    ['panel', 'freq2', { color: 3 }, [[
      [{checkbox: "Fseq"}, "fseq"],
    ]]],
    ['panel', 'amp2', { color: 3 }, [[
      ["Level Scale", "level/key/scale"],
    ]]]
  ], 
  effects: ([
    ['indexChange', i => ['setCtrlLabel', "button", `Op ${i + 1} - Unvoiced`],
    ['editMenu', "button", {
      paths: unvoicedPaths, 
      type: "FS1RUnvoicedOp", 
      init: {
        let bd = patchTruss.createInitBodyData()
        return voicedPaths.map { patchTruss.getValue(bd, path: "op/0/unvoiced" + $0) ?? 0 }
      }(), 
      rand: {
        let patch = patchTruss.randomize()
        return voicedPaths.map { patch["op/0/unvoiced" + $0] ?? 0 }
      }
    }],
    Controller.unvoicedRatioEffect,
    Controller.unvoicedModeEffect,
  ]).concat(opControllerEffects), 
  layout: [
    ['row', [["freq", 6], ["freq2", 1]]],
    ['row', [["button", 3], ["amp2", 4]]],
    ['col', [["osc", 2], ["freq", 1], ["amp", 2], ["button", 1]]],
    ['eq', ["osc","freq2","amp","amp2"], 'trailing'],
  ])
}


const controller = {
  prefix: ['index', "op"],
  builders: [
    ['child', voicedOp, "v"],
    ['child', unvoicedOp, "n"],
  ], 
  effects: [
    ['indexChange', i => [
      ['setIndex', "v", i],
      ['setIndex', "n", i],
    ]],
  ], 
  simpleGridLayout: [
    [[["v", 8.5],["n", 7.5]]],
  ],
}

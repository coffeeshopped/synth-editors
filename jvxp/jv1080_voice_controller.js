require('./utils.js')

const Voice = require('./jv1080_voice.js')
const SRJVBoard = require('./srjv_board.js')
const FX = require('./jvfx.js')

const structures = (10).map(i => `assets/xv-struct-${i + 1}.svg`)

const common = (cfg) => {
  var effects = []
  
  if (!cfg.showClockSource) {
    effects.push(['setup', [['hidePanel', true, "clock"]]])
  }
  
  if (cfg.perfPart >= 0) {
    effects.push(['setup', [
      ['dimPanel', true, "chorus"],
      ['dimPanel', true, "reverb"],
    ]])
    effects.push(['paramChange', "common/fx/src", { fnWithContext: (parm, state, locals) => 
      [['dimPanel', parm.p - 1 != cfg.perfPart, "fx"]] }
    ])
  }
        
  return {
    prefix: {fixed: "common"}, 
    builders: [
      ['child', fx, "fx"],
      ['panel', 'tempo', { color: 1 }, [[
        ["Tempo", "tempo"],
        ["Level", "level"],
        ["Pan", "pan"],
        ["Mono", "mono"],
        ["Legato", "legato"],
        ["Analog Feel", "analogFeel"],
      ],[
        ["Oct Shift", "octave/shift"],
        ["Stretch Tune", "stretchTune"],
        ["Voice Priority", "voice/priority"],
        ["Velo Range", "velo/range/on"],
        ["Bend Up", "bend/up"],
        ["Bend Down", "bend/down"],
      ]]],
      ['panel', 'porta', { color: 1 }, [[
        ["Porta", "porta"],
        ["Time", "porta/time"],
        ["Legato", "porta/legato"],
      ],[
        ["Type", "porta/type"],
        ["Start", "porta/start"],
      ]]],
      ['panel', 'ctrl', { color: 1 }, [[
        ["Ctrl Src 2", "patch/ctrl/src/1"],
      ],[
        ["Ctrl Src 3", "patch/ctrl/src/2"],
      ]]],
      ['panel', 'hold', { color: 1 }, [[
        { l: "Hold/Peak" },
        ["FX Ctrl", "fx/ctrl/holdPeak"],
      ],[
        ["Ctrl 1", "ctrl/0/holdPeak"],
        ["Ctrl 2", "ctrl/1/holdPeak"],
        ["Ctrl 3", "ctrl/2/holdPeak"],
      ]]],
      ['panel', 'struct', { color: 1 }, [[
        [{imgSelect: "Structure 1/2", w: 200, h: 70, images: structures}, "structure/0"],
        ["Boost 1/2", "booster/0"],
      ],[
        [{imgSelect: "Structure 3/4", w: 200, h: 70, images: structures}, "structure/1"],
        ["Boost 3/4", "booster/1"],
      ]]],
      ['panel', 'chorus', { color: 1 }, [[
        ["Chorus Level", "chorus/level"],
        ["Rate", "chorus/rate"],
        ["Depth", "chorus/depth"],
        ["Pre-Delay", "chorus/predelay"],
        ["Feedback", "chorus/feedback"],
        ["Output", "chorus/out/assign"],
      ]]],
      ['panel', 'reverb', { color: 1 }, [[
        ["Reverb", "reverb/type"],
        ["Level", "reverb/level"],
        ["Time", "reverb/time"],
        ["HF Damp", "reverb/hfdamp"],
        ["Feedback", "reverb/feedback"],
      ]]],
      ['panel', "clock", {color: 1}, [
        (cfg.showCategory ? [["Category", 'category']] : []).concat(
          [["Clock Src", 'clock/src']]
        )
      ]],
    ], 
    effects: effects, 
    layout: [
      ['row', [["tempo",6],["porta",3],["ctrl",1],["hold",5]] ],
      ['row', [["fx",12], ["struct",4]], { opts: ['alignAllTop'] }],
      ['rowPart', [["clock", 3], ["chorus",6],["reverb",5]] ],
      ['col', [["tempo",2],["fx",2],["clock",1]] ],
      ['eq', ["reverb","struct"], 'bottom'],
      ['eq', ["fx","reverb"], 'trailing'],
    ],
  }
}

const fx = {
  prefix: { fixed: "fx" }, 
  color: 2, 
  builders: [
    ['panel', "fx", [
      ([["FX Type", 'type']]).concat((5).map(i => [{x: `${i}`, id: `param/${i}`}, null])),
      ([5, 12]).rangeMap(i => [{x: `${i}`, id: `param/${i}`}, null])
    ]],
    ['panel', 'fxOut', { }, [[
      ["FX Output", "out/assign"],
      ["FX Level", "out/level"],
      ["→Chorus", "chorus"],
      ["→Reverb", "reverb"],
    ],[
      ["Ctrl Src 1", "ctrl/src/0"],
      ["Amt 1", "ctrl/depth/0"],
      ["Ctrl Src 2", "ctrl/src/1"],
      ["Amt 2", "ctrl/depth/1"],
    ]]],
  ], 
  effects: (12).flatMap(i => [
    ['basicControlChange', `param/${i}`],
    ['basicPatchChange', `param/${i}`],
  ]).concat([
    ['patchChange', "type", value => {
      let info = FX.fxParams[value]
      return (12).flatMap(i => {
        const path = `param/${i}`
        
        const pair = info[i]
        if (!pair) { return [['hideItem', true, path]] }
        return [
          ['setCtrlLabel', path, pair[0]],
          ['configCtrl', path, pair[1]],
          ['hideItem', false, path],
        ]
      })
    }]
  ]), 
  simpleGridLayout: [
    [["fx", 7], ["fxOut", 5]],
  ],
}

const allPaths = Voice.toneParms

const wave = {
  builders: [
    ['grid', [[
      [{ select: "Wave Group", id: "wave/group" }, null],
      [{ select: "Wave Number", id: "wave/number"}, null],
      ["Wave Gain", "wave/gain"],
    ]]],
  ], 
  effects: [
    // wave group
    ['setup', [
      ['configCtrl', "wave/group", { opts: (["Int-A", "Int-B"]).concat(SRJVBoard.boardNames) }],
    ]],
    ['controlChange', "wave/group", (state, locals) => {
      const v = locals["wave/group"] || 0
      const opts = [
        ["wave/group", v < 2 ? 0 : 2],
        // int-a is 1, int-b is 2
        ["wave/group/id", v < 2 ? v + 1 : v - 2],
      ]
      return opts
    }],
    ['patchChange', {
      paths: ["wave/group", "wave/group/id"], 
      fn: values => {
        const internal = (values["wave/group"] || 0) == 0
        const groupId = values["wave/group/id"] || 0
        var options = []
        if (internal) {
          options = groupId == 1 ? Voice.intAWaves : Voice.intBWaves
        }
        else {
          const board = SRJVBoard.boards[groupId]
          options = board ? board.waves : Voice.blankWaves
        }
        
        return [
          ['configCtrl', "wave/number", { opts: options }],
          ['setValue', "wave/group", internal ? groupId - 1 : groupId + 2],
        ]
      },
    }],
    // wave number
    ['basicControlChange', "wave/number"],
    ['basicPatchChange', "wave/number"],
  ],
}

const pitchEnvs = {
  env: {
    display: ['timeLevelEnv', 4, 2, true],
    l: "Pitch",
    maps: (4).map(i => ['u', `pitch/env/time/${i}`, `time/${i}`]).concat((4).map(i => ['src', `pitch/env/level/${i}`, v => (v - 63) / 63, `level/${i}`])),
    id: "env",
  },
  effect: ['editMenu', "env", {
    paths: [
      "pitch/env/time/0",
      "pitch/env/time/1",
      "pitch/env/time/2",
      "pitch/env/time/3",
      "pitch/env/level/0",
      "pitch/env/level/1",
      "pitch/env/level/2",
      "pitch/env/level/3",
    ], 
    type: "JV1080RateLevelEnvelope",
  }],
}

const pitch = {
  builders: [
    ['grid', [[
      ["Coarse", "coarse"],
      ["Fine", "fine"],
      ["Random Amt", "random/pitch"],
      ["Key→Pitch", "pitch/keyTrk"],
      ["LFO 1", "lfo/0/pitch"],
      ["LFO 2", "lfo/1/pitch"],
    ],[
      pitchEnvs.env,
      ["Env→Pitch", "pitch/env/depth"],
      ["Key→Env Time", "pitch/env/time/keyTrk"],
      ["Velo→Env", "pitch/env/velo/sens"],
    ],[
      ["T1", "pitch/env/time/0"],
      ["T2", "pitch/env/time/1"],
      ["T3", "pitch/env/time/2"],
      ["T4", "pitch/env/time/3"],
      ["Velo→T1", "pitch/env/velo/time/0"],
    ],[
      ["L1", "pitch/env/level/0"],
      ["L2", "pitch/env/level/1"],
      ["L3", "pitch/env/level/2"],
      ["L4", "pitch/env/level/3"],
      ["Velo→T4", "pitch/env/velo/time/3"],
    ]]]
  ], 
  effects: [pitchEnvs.effect],
}


const filterEnvs = {
  env: {
    display: ['timeLevelEnv', 4, 2, false],
    l: "Filter",
    maps: (4).map(i => ['u', `filter/env/time/${i}`, `time/${i}`]).concat((4).map(i => ['u', `filter/env/level/${i}`, `level/${i}`])),
    id: "env",
  },
  effect: ['editMenu', "env", {
    paths: [
      "filter/env/time/0",
      "filter/env/time/1",
      "filter/env/time/2",
      "filter/env/time/3",
      "filter/env/level/0",
      "filter/env/level/1",
      "filter/env/level/2",
      "filter/env/level/3",
    ], 
    type: "JV1080RateLevelEnvelope",
  }],
}

const filter = {
  builders: [
    ['grid', [[
      ["Filter", "filter/type"],
      ["Cutoff", "cutoff"],
      ["Reson", "reson"],
      ["LFO 1", "lfo/0/filter"],
      ["LFO 2", "lfo/1/filter"],
    ],[
      filterEnvs.env,
      ["Env→Cutoff", "filter/env/depth"],
      ["Key→Env Time", "filter/env/time/keyTrk"],
      ["Velo→Env", "filter/env/velo/sens"],
      ["Key→Cutoff", "cutoff/keyTrk"],
    ],[
      ["T1", "filter/env/time/0"],
      ["T2", "filter/env/time/1"],
      ["T3", "filter/env/time/2"],
      ["T4", "filter/env/time/3"],
      ["Velo→T1", "filter/env/velo/time/0"],
      ["Velo→Reson", "reson/velo/sens"],
    ],[
      ["L1", "filter/env/level/0"],
      ["L2", "filter/env/level/1"],
      ["L3", "filter/env/level/2"],
      ["L4", "filter/env/level/3"],
      ["Velo→T4", "filter/env/velo/time/3"],
      ["Env Velo Crv", "filter/env/velo/curve"],
    ]]],
  ], 
  effects: [filterEnvs.effect].concat([
    ['dimsOn', 'filter/type'],
  ]),
}


const ampEnvs = {
  env: {
    display: ['timeLevelEnv', 4, 2, false],
    l: "Amp",
    maps: (4).map(i => ['u', `amp/env/time/${i}`, `time/${i}`]).concat((3).map(i => ['u', `amp/env/level/${i}`, `level/${i}`])),
    id: "env",
  },
  effect: ['editMenu', "env", {
    paths: [
      "amp/env/time/0",
      "amp/env/time/1",
      "amp/env/time/2",
      "amp/env/time/3",
      "amp/env/level/0",
      "amp/env/level/1",
      "amp/env/level/2",
    ], 
    type: "JV1080RateLevelEnvelope",
  }],
}

const amp = {
  builders: [
    ['grid', [[
      ["Bias Dir", "bias/direction"],
      ["Bias Pt", "bias/pt"],
      ["Bias Level", "bias/level"],
      ["LFO 1", "lfo/0/amp"],
      ["LFO 2", "lfo/1/amp"],
    ],[
      ampEnvs.env,
      ["Env Velo Crv", "amp/env/velo/curve"],
      ["Key→Env Time", "amp/env/time/keyTrk"],
      ["Velo→Env", "amp/env/velo/sens"],
    ],[
      ["T1", "amp/env/time/0"],
      ["T2", "amp/env/time/1"],
      ["T3", "amp/env/time/2"],
      ["T4", "amp/env/time/3"],
      ["Velo→T1", "amp/env/velo/time/0"],
    ],[
      ["L1", "amp/env/level/0"],
      ["L2", "amp/env/level/1"],
      ["L3", "amp/env/level/2"],
      ["Tone Level", "tone/level"],
      ["Velo→T4", "amp/env/velo/time/3"],
    ]]]
  ], 
  effects: [ampEnvs.effect],
}


const lfo = { 
  prefix: {index: "lfo"}, 
  builders: [
    ['grid', [[
      ['switcher', ["1","2"], { l: "LFO" }],
      ["Wave", "wave"],
      ["Rate", "rate"],
      ["Key Trig", "key/trigger"],
    ],[
      ["Delay", "delay"],
      ["Fade Mode", "fade/mode"],
      ["Fade Time", "fade/time"],
      ["Level Offset", "level/offset"],
      ["Ext Sync", "ext/sync"],
    ]]],
  ],
}

const control = {
  prefix: {index: "ctrl"}, 
  builders: [
    ['grid', [[
      ['switcher', ["1","2","3"], { l: "Controller" }],
      ["Dest 1", "dest/0"],
      ["Amt 1", "depth/0"],
      ["Dest 2", "dest/1"],
      ["Amt 2", "depth/1"],
      ["Dest 3", "dest/2"],
      ["Amt 3", "depth/2"],
      ["Dest 4", "dest/3"],
      ["Amt 4", "depth/3"],
    ]]],
  ],
}



// MARK: Palettes

const fourPalettes = (pasteType, pal) => ['palettes', pal, 4, "tone", "Tone", pasteType]

const palettePitch = {
  builders: [
    ['grid', [[
      ["Coarse", "coarse"],
      ["Fine", "fine"],
      ["Random Amt", "random/pitch"],
      ["Key→Pitch", "pitch/keyTrk"],
    ],[
      pitchEnvs.env,
      ["Env→Pitch", "pitch/env/depth"],
      ["Key→Env T", "pitch/env/time/keyTrk"],
    ],[
      ["T1", "pitch/env/time/0"],
      ["T2", "pitch/env/time/1"],
      ["T3", "pitch/env/time/2"],
      ["T4", "pitch/env/time/3"],
    ],[
      ["L1", "pitch/env/level/0"],
      ["L2", "pitch/env/level/1"],
      ["L3", "pitch/env/level/2"],
      ["L4", "pitch/env/level/3"],
    ],[
      ["Velo→Env", "pitch/env/velo/sens"],
      ["Velo→T1", "pitch/env/velo/time/0"],
      ["Velo→T4", "pitch/env/velo/time/3"],
    ],[
      ["LFO 1", "lfo/0/pitch"],
      ["LFO 2", "lfo/1/pitch"],
    ]]],
  ], 
  effects: [pitchEnvs.effect],
}

const palettePitchWave = {
  color: 1, 
  builders: [
    ['child', wave, "wave"],
    ['child', palettePitch, "pitch"],
  ], 
  gridLayout: [
    {row: [["wave", 1]], h: 1},
    {row: [["pitch", 1]], h: 6},
  ],
}

const paletteFilter = {
  color: 2, 
  builders: [
    ['grid', [[
      ["Filter", "filter/type"],
      ["Cutoff", "cutoff"],
      ["Reson", "reson"],
    ],[
      filterEnvs.env,
      ["Env→Cutoff", "filter/env/depth"],
      ["Key→Env Time", "filter/env/time/keyTrk"],
    ],[
      ["T1", "filter/env/time/0"],
      ["T2", "filter/env/time/1"],
      ["T3", "filter/env/time/2"],
      ["T4", "filter/env/time/3"],
    ],[
      ["L1", "filter/env/level/0"],
      ["L2", "filter/env/level/1"],
      ["L3", "filter/env/level/2"],
      ["L4", "filter/env/level/3"],
    ],[
      ["Velo→Env", "filter/env/velo/sens"],
      ["Velo→T1", "filter/env/velo/time/0"],
      ["Velo→T4", "filter/env/velo/time/3"],
    ],[
      ["Key→Cutoff", "cutoff/keyTrk"],
      ["Velo→Reson", "reson/velo/sens"],
      ["Env Velo Crv", "filter/env/velo/curve"],
    ],[
      ["LFO 1", "lfo/0/filter"],
      ["LFO 2", "lfo/1/filter"],
    ]]]
  ], 
  effects: [filterEnvs.effect],
}

const paletteAmp = {
  color: 3, 
  builders: [
    ['grid', [[
      ["Level", "tone/level"],
      ["Bias Dir", "bias/direction"],
      ["Bias Pt", "bias/pt"],
      ["Bias Level", "bias/level"],
    ],[
      ampEnvs.env,
      ["Velo Crv", "amp/env/velo/curve"],
      ["Key→Env T", "amp/env/time/keyTrk"],
    ],[
      ["T1", "amp/env/time/0"],
      ["T2", "amp/env/time/1"],
      ["T3", "amp/env/time/2"],
      ["T4", "amp/env/time/3"],
    ],[
      ["L1", "amp/env/level/0"],
      ["L2", "amp/env/level/1"],
      ["L3", "amp/env/level/2"],
      '-',
    ],[
      ["Velo→Env", "amp/env/velo/sens"],
      ["Velo→T1", "amp/env/velo/time/0"],
      ["Velo→T4", "amp/env/velo/time/3"],
    ],[
      ["LFO 1", "lfo/0/amp"],
      ["LFO 2", "lfo/1/amp"],
    ]]],
  ], 
  effects: [ampEnvs.effect],
}


const palettePanOut = {
  color: 3, 
  builders: [
    ['panel', 'pan', { }, [[
      ["Pan", "pan"],
      ["Key→Pan", "pan/keyTrk"],
      ["Random Pan", "random/pan"],
    ],[
      ["Alt Pan", "alt/pan"],
      ["LFO 1", "lfo/0/pan"],
      ["LFO 2", "lfo/1/pan"],
    ]]],
    ['panel', 'fxm', { }, [[
      ["FXM", "fxm/on"],
      ["Color", "fxm/color"],
      ["Depth", "fxm/depth"],
    ]]],
    ['panel', 'out', { }, [[
      ["Output", "out/assign"],
      ["Level", "out/level"],
    ],[
      ["Chorus", "chorus"],
      ["Reverb", "reverb"],
    ]]],
    ['panel', 'delay', { }, [[
      ["Delay", "delay/mode"],
      ["Time", "delay/time"],
    ]]],
  ], 
  gridLayout: [
    {row: [["pan", 1]], h: 2},
    {row: [["fxm", 1]], h: 1},
    {row: [["out", 1]], h: 2},
    {row: [["delay", 1]], h: 1},
  ],
}

const paletteLFO = {
  builders: [
    ['children', 2, "lfo", ['index', "lfo", "wave", i => `LFO ${i + 1}`, { 
      color: 1, 
      builders: [
        ['grid', [[
          ["Wave", "wave"],
          ["Rate", "rate"],
          ["Key Trig", "key/trigger"],
          ["Ext Sync", "ext/sync"],
        ],[
          ["Delay", "delay"],
          ["Fade Mode", "fade/mode"],
          ["Fade Time", "fade/time"],
          ["Level Offset", "level/offset"],
        ],[
          ["Pitch", "pitch"],
          ["Filter", "filter"],
          ["Amp", "amp"],
          ["Pan", "pan"],
        ]]]
      ],
    }]],
  ], 
  simpleGridLayout: [[
    ["lfo0", 1],
  ],[
    ["lfo1", 1],
  ]],
}

const tone = {
  prefix: { index: "tone" }, 
  builders: [
    ['child', wave, "wave", {color: 1}],
    ['child', pitch, "pitch", {color: 1}],
    ['child', filter, "filter", {color: 2}],
    ['child', amp, "amp", {color: 3}],
    ['child', lfo, "lfo", {color: 1}],
    ['child', control, "ctrl", {color: 1}],
    ['panel', 'fxm', { color: 1 }, [[
      ["FXM", "fxm/on"],
      ["Color", "fxm/color"],
      ["Depth", "fxm/depth"],
    ]]],
    ['panel', 'delay', { color: 1 }, [[
      ["Delay", "delay/mode"],
      ["Time", "delay/time"],
    ]]],
    ['button', "Tone", {color: 1}],
    ['panel', 'range', { color: 1 }, [[
      ["Velo X Depth", "velo/fade/depth"],
      ["Velo Range L", "velo/range/lo"],
      ["Velo Range U", "velo/range/hi"],
      ["Key Range L", "key/range/lo"],
      ["Key Range U", "key/range/hi"],
    ]]],
    ['panel', 'rcv', { color: 1 }, [[
      ["Redamp Ctl", "redamper/ctrl"],
      ["Volume Ctl", "volume/ctrl"],
      ["Hold-1 Ctl", "hold/ctrl"],
      ["Bender Ctl", "bend/ctrl"],
      ["Pan Ctl", "pan/ctrl"]]
    ]],
    ['panel', 'pan', { color: 3 }, [[
      ["Pan", "pan"],
      ["Key→Pan", "pan/keyTrk"],
      ["Random Pan", "random/pan"],
    ],[
      ["Alt Pan", "alt/pan"],
      ["LFO 1", "lfo/0/pan"],
      ["LFO 2", "lfo/1/pan"],
    ]]],
    ['panel', 'out', { color: 3 }, [[
      ["Output", "out/assign"],
      ["Level", "out/level"],
    ],[
      ["Chorus", "chorus"],
      ["Reverb", "reverb"],
    ]]],
  ], 
  effects: [
    ['dimsOn', "on"],
    ['editMenu', "button", {
      paths: allPaths, 
      type: "JV1080Tone", 
    }],
  ], 
  layout: [
    ['row', [["wave",5],["fxm",3],["delay",2],["button",1]] ],
    ['row', [["pitch",5],["filter",6],["amp",5]] ],
    ['row', [["lfo",5],["range",5],["pan",3],["out",2]], { opts: ['alignAllTop'] }],
    ['row', [["ctrl",13]] ],
    ['col', [["wave",1],["pitch",4],["lfo",2],["ctrl",1]] ],
    ['colPart', [["range",1],["rcv",1]], { opts: ['alignAllLeading', 'alignAllTrailing'] }],
    ['eq', ["lfo","rcv","pan","out"], 'bottom'],
  ]
}
//      override func randomize(_ sender: Any?) {
//        pushPatchChange(.replace(JV1080TonePatch.random()))
//      }

const controller = cfg => ({
  builders: [
    ['switcher', ["Common","1","2","3","4", "Pitch", "Filter", "Amp", "LFO", "Pan/Out"], {color: 1}],
    ['panel', 'on', { color: 1, }, [[
      ["Tone 1", "tone/0/on"],
      ["2", "tone/1/on"],
      ["3", "tone/2/on"],
      ["4", "tone/3/on"],
    ]]],
  ], 
  layout: [
    ['row', [["switch", 12], ["on", 4]] ],
    ['row', [["page",1]] ],
    ['col', [["switch",1],["page",8]] ],
  ], 
  pages: ['map', [
    "common",
    "tone/0",
    "tone/1",
    "tone/2",
    "tone/3",
    "pitch",
    "filter",
    "amp",
    "lfo",
    "pan",
  ], [
    ["common", common(cfg)],
    ["tone", tone],
    ["pitch", fourPalettes("JVPitch", palettePitchWave)],
    ["filter", fourPalettes("JVFilter", paletteFilter)],
    ["amp", fourPalettes("JVAmp", paletteAmp)],
    ["lfo", fourPalettes("JVLFO", paletteLFO)],
    ["pan", fourPalettes("JVPan", palettePanOut)],
  ]],
})

module.exports = {
  controller: controller,
  fx: fx,
  pitchEnvs: pitchEnvs,
  filterEnvs: filterEnvs,
  ampEnvs: ampEnvs,
  wave: wave,
}
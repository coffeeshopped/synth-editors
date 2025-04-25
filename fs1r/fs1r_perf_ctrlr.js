require('./utils.js')
const Perf = require('./fs1r_perf.js')
const Voice = require('./fs1r_voice.js')

const ccBlock = (state, locals) => {
  const speedType = locals["speed/type"] || 0
  const coarse = locals["coarse"] || 0
  const fine = locals["fine"] || 0
  const value = speedType < 5 ? speedType : Math.min(5000, coarse * 10 + fine)
  return [["speed", value]]
}

const fseqMidiSpeedOptions = ["Midi 1/4","Midi 1/2","Midi","Midi 2/1","Midi 4/1"]

const fseq = {
  prefix: {fixed: "fseq"}, 
  builders: [
    ['panel', 'part', { color: 1, }, [[
      [{switch: "Fseq Part"}, "part"],
      [{switch: "Bank"}, "bank"],
      [{select: "Number"}, "number"],
    ]]],
    ['panel', 'speed', { color: 1, }, [[
      [{select: "Speed", id: "speed/type"}, null],
      [{knob: "Coarse", id: "coarse"}, null],
      [{knob: "Fine", id: "fine"}, null],
      [{switch: "Speed", id: "speed"}, null],
      ["Velo > Speed", "speed/velo"],
    ]]],
    ['panel', 'delay', { color: 1, }, [[
      ["Delay", "formant/seq/delay"],
      ["Start", "start"],
      ["Loop St", "loop/start"],
      ["Loop End", "loop/end"],
      [{switch: "Lp Mode"}, "loop"],
    ]]],
    ['panel', 'mode', { color: 1, }, [[
      [{switch: "Play Mode"}, "mode"],
      [{switch: "Fmt Pitch"}, "formant/pitch"],
      [{switch: "Trigger"}, "trigger"],
      ["Velo > Level", "level/velo"],
    ]]],
  ], 
  effects: [
    ['patchChange', "speed", value => {
      var changes = []
      var percsHidden = false
      if (value >= 0 && value < 5) {
        percsHidden = true
        changes.push(['setValue', "speed/type", value])
      }
      else {
        percsHidden = false
        changes = [
          ['setValue', "speed/type", 5],
          ['setValue', "coarse", Math.max(10, Math.floor(value / 10))],
          ['setValue', "fine", value < 100 ? 0 : value % 10],
          ['configCtrl', "speed", { opts: [value < 100 ? "10%" : `${value/10}%`] }]
        ]
      }
      return changes.concat([
        ['hideItem', percsHidden, "coarse"],
        ['hideItem', percsHidden, "fine"],
        ['hideItem', percsHidden, "speed"],
      ])
    }],
    ['dimsOn', "part"],
    ['controlChange', "speed/type", ccBlock],
    ['controlChange', "coarse", ccBlock],
    ['controlChange', "fine", ccBlock],
    ['setup', [
      ['configCtrl', "speed/type", { opts: fseqMidiSpeedOptions.concat(["%"]) }],
      ['configCtrl', "coarse", { rng: [10, 501] }],
      ['configCtrl', "fine", { rng: [0, 10] }],
    ]],
    ['patchSelector', "number", {
      bankValue: "bank",
      paramMap: bank => {
        switch (bank) {
        case 0:
          return ['fullPath', "fseq/name"]
        default:
          return { opts: Perf.presetFseqOptions }
        }
      }
    }],
  ], 
  simpleGridLayout: [
    [["part", 3.5], ["speed", 5.5]],
    [["delay", 5], ["mode", 4]],
  ],
}

const perfVC = ['index', "ctrl", "part", i => `VC ${i + 1}`, { 
  builders: [
    ['panel', 'part', { color: 1, }, [[
      [{checkbox: "Part 1"}, "part/0"],
      [{checkbox: "2"}, "part/1"],
      [{checkbox: "3"}, "part/2"],
      [{checkbox: "4"}, "part/3"],
    ]]],
    ['panel', "label", [[
      {l: "?", size: 15, id: 'part'}
    ]]],
    ['panel', 'dest', { color: 1, }, [[
      [{select: "Destination"}, "dest"],
      ["Depth", "depth"],
    ]]],
    ['panel', 'knob', { color: 1, }, [[
      [{checkbox: "Knob 1"}, "knob/0"],
      [{checkbox: "2"}, "knob/1"],
      [{checkbox: "3"}, "knob/2"],
      [{checkbox: "4"}, "knob/3"],
    ]]],
    ['panel', 'mc', { color: 1, }, [[
      [{checkbox: "MC 1"}, "midi/ctrl/0"],
      [{checkbox: "2"}, "midi/ctrl/1"],
      [{checkbox: "3"}, "midi/ctrl/2"],
      [{checkbox: "4"}, "midi/ctrl/3"],
    ]]],
    ['panel', 'foot', { color: 1, }, [[
      [{checkbox: "Foot"}, "foot"],
      [{checkbox: "Breath"}, "breath"],
      [{checkbox: "Mod Wh"}, "modWheel"],
    ]]],
    ['panel', 'after', { color: 1, }, [[
      [{checkbox: "Chan Aftert"}, "channel/aftertouch"],
      [{checkbox: "Poly Aftert"}, "poly/aftertouch"],
      [{checkbox: "P Bend"}, "bend"],
    ]]],
  ], 
  simpleGridLayout: [
    [["part", 1]],
    [["label", 3],["dest", 5]],
    [["knob", 1]],
    [["mc", 1]],
    [["foot", 1]],
    [["after", 1]],
  ],
//      vc.addBorder()
}]
  

const fxTypeEffect = params => ['patchChange', "type", value => {
  if (value >= params.length) { return [] }
  const info = params[value]
  return (16).flatMap(i => {
    const id = i
    const pair = info[i]
    if (!pair) { return [['hideItem', true, id]] }
    return [
      ['setCtrlLabel', id, pair[0]],
      ['configCtrl', id, pair[1]],
      ['hideItem', false, id],
    ]
  })
}]

const reverb = {
  prefix: {fixed: "reverb"}, 
  builders: [
    ['grid', [
      [
        [{select: "Reverb"}, "type"],
        ["Pan", "pan"],
        ["Return", "level"],
      ].concat((6).map(i => [`${i}`, i])),
      (10).map(i => [`${i + 6}`, i + 6]),
    ]],
  ], 
  effects: [fxTypeEffect(Perf.reverbParams)],
}

const vary = {
  prefix: {fixed: "vary"}, 
  builders: [
    ['grid', [
      [
        [{select: "Variation"}, "type"],
        ["Pan", "pan"],
        ["Return", "level"],
        ["> Verb", "reverb"],
      ].concat((5).map(i => [`${i}`, i])),
      (11).map(i => [`${i + 5}`, i + 5]),
    ]],
  ], 
  effects: [fxTypeEffect(Perf.varyParams)],
}

const insert = {
  prefix: {fixed: "insert"}, 
  builders: [
    ['grid', [
      [
        [{select: "Insert"}, "type"],
        ["Pan", "pan"],
        ["Return", "level"],
        ["> Verb", "reverb"],
        ["> Vari", "vary"],
      ].concat((5).map(i => [`${i}`, i])),
      (11).map(i => [`${i + 5}`, i + 5]),
    ]],
  ], 
  effects: [fxTypeEffect(Perf.insertParams)],
}

const fx = {
  builders: [
    ['child', reverb, "reverb", {color: 3}],
    ['child', vary, "vary", {color: 3}],
    ['child', insert, "insert", {color: 3}],
    ['panel', 'eq', { color: 3, }, [[
      ["Lo Gain", "lo/gain"],
      ["Lo Freq", "lo/freq"],
      ["Lo Q", "lo/q"],
      [{switch: "Lo Shape"}, "lo/shape"],
    ],[
      ["Mid Gain", "mid/gain"],
      ["Mid Freq", "mid/freq"],
      ["Mid Q", "mid/q"],
    ],[
      ["Hi Gain", "hi/gain"],
      ["Hi Freq", "hi/freq"],
      ["Hi Q", "hi/q"],
      [{switch: "Hi Shape"}, "hi/shape"],
    ]]],
  ], 
  layout: [
    ['row', [["reverb",12],["eq",4]], { opts: ['alignAllTop'] }],
    ['col', [["reverb",2],["vary",2],["insert",2]]],
    ['eq', ["reverb","vary","insert"], 'trailing'],
    ['eq', ["vary","eq"], 'bottom'],
  ],
}

const part = {
  prefix: {index: "part"}, 
  builders: [
    ['button', "Part", {color: 2}],
    ['nav', "Edit Voice", [], {color: 2}],
    ['panel', 'reserve', { color: 2, }, [[
      [{select: "Bank"}, "bank"],
      [{select: "Program"}, "pgm"],
      [{select: "Chan"}, "channel"],
      [{select: "Chan Max", id: "channel/hi"}, null],
      ["Note Reserve", "note/reserve"],
      [{switch: "Mono"}, "poly"],
      [{switch: "Priority"}, "mono/priority"],
      ["Note Shift", "note/shift"],
      ["Detune", "detune"],
      ["V/N Balance", "voiced/unvoiced"],
    ]]],
    ['panel', 'velo', { color: 2, }, [[
      ["Velo Depth", "velo/depth"],
      ["Velo Offset", "velo/offset"],
    ]]],
    ['panel', 'pan', { color: 2, }, [[
      ["Pan", "pan"],
      ["LFO Depth", "pan/lfo/depth"],
      ["Pan Scale", "pan/scale"],
    ]]],
    ['panel', 'bend', { color: 2, }, [[
      ["Bend Lo", "bend/lo"],
      ["Bend Hi", "bend/hi"],
    ]]],
    ['panel', 'send', { color: 2, }, [[
      ["Volume", "volume"],
      ["Dry", "level"],
      ["Variation", "vary"],
      ["Reverb", "reverb"],
      [{checkbox: "Insert"}, "insert"],
    ]]],
    ['panel', 'filter', { color: 2, }, [[
      [{checkbox: "Filter"}, "filter/on"],
      ["Cutoff", "cutoff"],
      ["Reson", "reson"],
      ["Filter Env", "filter/env/depth"],
    ]]],
    ['panel', 'lfo1', { color: 2, }, [[
      ["LFO 1 Rate", "lfo/0/rate"],
      ["Delay", "lfo/0/delay"],
      ["Pitch Mod", "lfo/0/pitch/mod"],
    ]]],
    ['panel', 'lfo2', { color: 2, }, [[
      ["LFO2 Rate", "lfo/1/rate"],
      ["LFO2 Depth", "lfo/1/depth"],
    ]]],
    ['panel', 'env', { color: 2, }, [[
      ["Attack", "env/attack"],
      ["Decay", "env/decay"],
      ["Release", "env/release"],
    ]]],
    ['panel', 'knob', { color: 2, }, [[
      ["Formant", "formant"],
      ["FM", "fm"],
    ]]],
    ['panel', 'pitch', { color: 2, }, [[
      ["Pitch Env Init", "pitch/env/innit"],
      ["Attack", "pitch/env/attack"],
      ["Release L", "pitch/env/release/level"],
      ["Rel Time", "pitch/env/release/time"],
    ]]],
    ['panel', 'porta', { color: 2, }, [[
      [{ switch: "Porta", id: "porta"}, null],
      ["Time", "porta/time"],
    ]]],
    ['panel', 'limit', { color: 2, }, [[
      ["Note Lo", "note/lo"],
      ["Note Hi", "note/hi"],
      ["Velo Lo", "velo/lo"],
      ["Velo Hi", "velo/hi"],
      ["Expr Lo Limit", "pedal/lo"],
      [{checkbox: "Rx Sustain"}, "sustain/rcv"],
    ]]],
  ], 
  effects: [
    ['patchChange', {
      paths: ["bank", "channel"], 
      fn: values => [
        ['dimPanel', values["bank"] == 0 || (values["channel"] || 0) > 16, null],
        ['hideItem', values["bank"] == 0, "pgm"],
      ],
    }],
    ['patchChange', "filter/on", v => [
      ['dimItem', v == 0, "cutoff"],
      ['dimItem', v == 0, "reson"],
      ['dimItem', v == 0, "filter/env/depth"],
    ] ],
    ['patchChange', "insert", v => [
      ['dimItem', v != 0, "level"],
      ['dimItem', v != 0, "vary"],
      ['dimItem', v != 0, "reverb"],
    ] ],
    ['patchChange', "channel", v => ['hideItem', v > 15, "channel/hi"]],
    ['editMenu', "button", {
      paths: ['>', Perf.patchTruss.parms,
        ['removePrefix', 'part/0'],
      ], 
      type: "FS1RPart",
    }],
    ['indexChange', i => [
      ['setCtrlLabel', "button", `Part ${i + 1}`],
      // Might be better without this?
//          ['setCtrlLabel', "nav", "Edit Part \($0 + 1)"],
      ['setNavPath', ["part", i]],
    ] ],
    ['ctrlBlocks', "porta", { 
      value: v => v == 2 ? 0 : v // value of 2 is off (as is 0)
    }],
    ['ctrlBlocks', "channel/hi", {
      value: v => v < 16 ? v : 0x7f // sometimes fs1r sends out of range values, so clamp
    }],
    ['patchSelector', "pgm", { 
      bankValue: "bank",
      paramMap: bank => {
        if (bank == 1) {
          return ['fullPath', "patch/name"]
        }
        else {
          const ramBanks = Voice.ramBanks
          const ramIndex = Math.min(Math.max(0, bank - 2), ramBanks.length - 1)
          return { opts: ramBanks[ramIndex] }
        }
      }
    }],
  ],
  simpleGridLayout: [
    [["button", 2], ["reserve", 12], ["nav", 2]],
    [["send", 5], ["velo", 2], ["pan", 3], ["bend", 2]],
    [["filter", 4], ["lfo1", 3], ["lfo2", 2], ["env", 3],["knob", 2]],
    [["pitch", 4], ["porta", 2], ["limit", 6]],
  ],
}

module.exports = {
  controller: {
    builders: [
      ['switcher', ["Part 1","Part 2","Part 3","Part 4","Fseq", "FX/EQ","Ctrl 1-4","Ctrl 5-8"], {color: 1}],
      ['panel', 'cat', { color: 1, }, [[
        [{select: "Category"}, "category"],
        ["Volume", "volume"],
        ["Pan", "pan"],
        ["Note Shift", "note/shift"],
        [{switch: "Indiv Out"}, "part/out"],
      ]]]
    ], 
    gridLayout: [
      { row: [["switch", 10.5], ["cat", 5.5]], h: 1 },
      { row: [["page", 1]], h: 6 },
    ], 
    pages: ['map', (4).map(i => ["part", i]).concat(["fseq", "fx"]).concat((2).map(i => ["ctrl", i])), [
      ["part", part],
      ["fx", fx],
      ["fseq", fseq],
      ["ctrl", ['oneRow', 4, perfVC, (parentIndex, offset) => 4 * parentIndex + offset]],
    ]],
  }
}

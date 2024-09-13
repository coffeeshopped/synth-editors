const VoiceCtrlr = require('./JV1080VoiceController.js')
const SRJVBoard = require('./SRJVBoard.js')

//    let showXP = PerfPart.self is XP50PerfPartPatch.Type
//    let show2080 = PerfPart.self is JV2080PerfPartPatch.Type
const controller = (config) => {
  
  const hides = []
  if (!config.showXP) {
    hides.push(
      ['hideItem', true, "key/mode"],
      ['hideItem', true, "clock/src"]
    )
  }
  if (!config.show2080) {
    hides.push(
      ['hideItem', true, "fx/1/src"],
      ['hideItem', true, "fx/2/src"]
    )
  }
  
  return {
    paged: true,
    builders: [
      ['switcher', ["Common","Parts 1–8","Parts 9–16"], {color: 1}],
      ['panel', 'tempo', { prefix: "common", color: 1 }, [[
        ["Tempo", "tempo"],
        [{checkbox: "Key Range"}, "key/range"],
        [{switsch: "Key Mode"}, "key/mode"],
        [{switsch: "Clock Src"}, "clock/src"],
        [{select: config.show2080 ? "FX A Src" : "FX Src"}, "fx/src"],
        [{select: "FX B Src"}, "fx/1/src"],
        [{select: "FX C Src"}, "fx/2/src"],
      ]]],
    ], 
    effects: [
      ['setup', hides],
    ], 
    layout: [
      ['row', [["switch",8],["tempo",8]]],
      ['row', [["page", 1]]],
      ['col', [["switch",1],["page",8]]],
    ], 
    pages: ['map', [
      "common",
      "part/0",
      "part/1",
    ], {
      "common" : common(config.show2080),
      "part" : parts(config.config),
    }],
  }
}


const parts = config => ['oneRow', 8, part(config), (parentIndex, offset) => offset + (parentIndex * 8)]


const common = show2080 => {
  var fxDim = null
  if (show2080) {
    fxDim = ['patchChange', {
      paths: ["common/fx/src", "common/fx/1/src", "common/fx/2/src"], 
      fn: values => {
        const v = Object.values(values)
        return [['dimPanel', v.reduce((a, b) => a && b > 0, true), "fx"]]
      }
    }]
  }
  else {
    fxDim = ['dimsOn', "common/fx/src", { 
      id: "fx", 
      dimWhen: i => i > 0 
    }]
  }
  return {
    builders: [
      ['child', {
        prefix: ['fixed', "common"], 
        builders: [
          ['child', VoiceCtrlr.fx, "p"],
        ], 
        simpleGridLayout: [
          [["p", 1]],
        ]
      }, "fx"],
      ['child', reserve, "reserve"],
      ['panel', 'chorus', { prefix: "common/chorus", color: 1, }, [[
        ["Chorus", "level"],
        ["Rate", "rate"],
        ["Depth", "depth"],
        ["Pre-Delay", "predelay"],
        ["Feedback", "feedback"],
        [{switsch: "Output"}, "out/assign"],
      ]]],
      ['panel', 'reverb', { prefix: "common/reverb", color: 1, }, [[
        [{select: "Reverb"}, "type"],
        ["Level", "level"],
        ["Time", "time"],
        [{select: "HF Damp"}, "hfdamp"],
        ["Feedback", "feedback"],
      ]]],
      ['panel', "range", {prefix: "part", color: 1}, [
        (16).map(i => 
          [i == 0 ? "Key Lo" : `${i + 1}`, `${i}/key/range/lo`]),
        (16).map(i => 
          [i == 0 ? "Key Hi" : `${i + 1}`, `${i}/key/range/hi`]),
      ]],
      ['panel', "midi", {prefix: "part", color: 1}, [
        (16).map(i => 
          [i == 0 ? "Midi Ch" : `${i + 1}`, `${i}/channel`]),
        (16).map(i => 
          [i == 0 ? "Midi Rcv" : `${i + 1}`, `${i}/midi/rcv`]),
      ]],
    ], 
    effects: [
      ['dimsOn', "common/key/range", {id: "range"}],
      fxDim,
    ], 
    layout: [
      ['row', [["fx", 1]]],
      ['row', [["chorus", 1],["reverb", 1]]],
      ['row', [["reserve", 1]]],
      ['row', [["range", 1]]],
      ['row', [["midi", 1]]],
      ['col', [["fx", 2], ["chorus", 1], ["reserve", 1], ["range", 2], ["midi", 2]]],
    ]
  }
}

const reserve = (() => {
  const ctrls = (16).map(i => `${i}/voice/reserve`)
  const reservePaths = ctrls.map(c => `common/part/${c}`)
  return {
    prefix: ['fixed', "common/part"],
    color: 1, 
    builders: [
      ['grid', [
        (16).map(i => [{ 
          knob: i == 0 ? "Voice Resrv" : `${i + 1}`,
          id: ctrls[i],
        }, null])
      ]],
    ], 
    effects: [
      ['voiceReserve', reservePaths, 64, ctrls],
    ]
  }
})()
    
// JV-2080 = hasOutSelect
const part = config => {

  // Out Assign options/handling
  var outEffects = [['ctrlBlocks', "out/assign"]]
  if (config.hasOutSelect) {
    outEffects = [
      ['setup', [
        ['configCtrl', "out/assign", { opts: ["Mix", "EFX A", "EFX B", "EFX C", "Dir 1", "Dir 2", "Patch A", "Patch B", "Patch C"] }]
      ]],
      ['patchChange', {
        paths: ["out/assign", "out/select"], 
        fn: values => {
          const assign = values["out/assign"] || 0
          const sel = values["out/select"] || 0
          var v = 0
          switch (assign) {
          case 0:
            v = 0
            break
          case 1:
            v = 1 + sel // fx
            break
          case 2:
          case 3:
            v = assign + 2
            break
          default:
            v = 6 + sel // patch
          }
          return [['setValue', "out/assign", v]]
        }
      }],
      ['controlChange', "out/assign", (state, locals) => {
        const v = locals["out/assign"] || 0
        var assign = 0
        var sel = 0
        switch (v) {
        case 0:
          assign = 0
          sel = 0
          break
        case 1:
        case 2:
        case 3:
          assign = 1
          sel = v - 1
          break
        case 4:
        case 5:
          assign = v - 2
          sel = 0
          break
        default:
          assign = 4
          sel = v - 6
          break
        }
        return {
          "out/assign" : assign,
          "out/select" : sel,
        }
      }]
    ]
  }
  
  return {
    index: "part", 
    label: "part", 
    fn: i => `${i + 1}`, 
    color: 1, 
    builders: [
      ['grid', [[
        {l: "Part", align: 'center', id: "part", w: 1},
        [{knob: "Patch Group", id: "patch/group"}, null],
      ],[
        [{knob: "Patch", id: "patch/number"}, null],
      ],[
        ["Level", "level"],
        ["Pan", "pan"],
      ],[
        ["Tune", "coarse"],
        ["Fine", "fine"],
      ],[
        [{knob: "Out Assign", id: "out/assign"}, null],
        ["Out Level", "out/level"],
      ],[
        ["Chorus", "chorus"],
        ["Reverb", "reverb"],
      ],[
        [{checkbox: "Pgm Change"}, "rcv/pgmChange"],
        [{checkbox: "Volume"}, "rcv/volume"],
      ],[
        [{checkbox: "Hold"}, "rcv/hold"],
      ]]],
    ], 
    effects: outEffects.concat([
      // patch group
      ['setup', [
        ['configCtrl', "patch/group", {opts: config.patchGroups}],
      ]],
      ['patchChange', {
        paths: ["patch/group", "patch/group/id"], 
        fn: values => {
          const group = values["patch/group"] || 0
          const groupId = values["patch/group/id"] || 0
          return [['setValue', "patch/group", group == 0 ? groupId - 100 : groupId]]
        }
      }],
      ['controlChange', "patch/group", (state, locals) => {
        const v = locals["patch/group"] || 0
        return {
          "patch/group" : v < 0 ? 0 : 2,
          "patch/group/id" : (v < 0 ? v + 100 : v),
        }
      }],
      // patchNumber
      ['basicPatchChange', "patch/number"],
      ['basicControlChange', "patch/number"],
      ['patchSelector', {
        id: "patch/number", 
        bankValues: ["patch/group", "patch/group/id"], 
        paramMapWithContext: (values, state, locals) => {
          const group = values["patch/group"] || 0
          const groupId = values["patch/group/id"] || 0
          const isRhythm = state.index == 9
          if (group == 0) {
            if (groupId == 1) {
              return ['fullPath', isRhythm ? "rhythm/name" : "patch/name"]
            }
            else {
              const presets = isRhythm ? config.rhythmPresets : config.voicePresets
              return {opts: presets[groupId]}
            }
          }
          else if (SRJVBoard.boards[groupId]) {
            const board = SRJVBoard.boards[groupId]
            return {opts: isRhythm ? board.rhythms : board.patches}
          }
          else {
            return {opts: config.blank}
          }
        }
      }]
    ])
  }
}

module.exports = {
  controller: controller
}
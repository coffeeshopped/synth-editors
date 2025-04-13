const VoiceCtrlr = require('./jv8x_voice_ctrlr.js')

const pitch = {
  color: 1, 
  builders: [
    ['grid', [[
      ["Coarse", "coarse"],
      ["Fine", "fine"],
      ["Random Pitch", "random/pitch"],
      ["Velo→T1", "pitch/env/velo/time"],
    ],[
      VoiceCtrlr.pitchEnv.env,
      ["Env Depth", "pitch/env/depth"],
      ["Velo→Env", "pitch/env/velo/sens"],
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
    ]]]
  ], 
  effects: [VoiceCtrlr.pitchEnv.menu],
}

const filter = {
  color: 2,
  builders: [
    ['grid', [[
      [{switsch: "Filter"}, "filter/type"],
      ["Cutoff", "cutoff"],
      ["Reson", "reson"],
      [{switsch: "Reson Mode"}, "reson/mode"],
      ["Velo→Time", "filter/env/velo/time"],
    ],[
      VoiceCtrlr.filterEnv.env,
      ["Env Depth", "filter/env/depth"],
      ["Velo→Env", "filter/env/velo/sens"],
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
    ]]]
  ], 
  effects: [
    VoiceCtrlr.filterEnv.menu,
    ['dimsOn', "filter/type"],
  ],
}

const amp = {
  color: 1, 
  builders: [
    ['grid', [[
      ["Level", "level"],
      ["Pan", nil, id: "pan"],
      "Random Pan", nil, id: "random/pan",
      ["Velo→Time", "amp/env/velo/time"],
    ],[
      VoiceCtrlr.ampEnv.env,
      ["Velo", "amp/env/velo/sens"],
    ],[
      ["T1", "amp/env/time/0"],
      ["T2", "amp/env/time/1"],
      ["T3", "amp/env/time/2"],
      ["T4", "amp/env/time/3"],
    ],[
      ["L1", "amp/env/level/0"],
      ["L2", "amp/env/level/1"],
      ["L3", "amp/env/level/2"],
    ]]]
  ], 
  effects: VoiceCtrlr.ampEffects,
}

const note = hideOut => {
  prefix: {index: "note"}, 
  builders: [
    ['child', VoiceCtrlr.wave, "wave"],
    ['child', pitch(), "pitch"],
    ['child', filter(), "filter"],
    ['child', amp(), "amp"],
    ['panel', 'on', { color: 1, }, [[
      [{checkbox: "On"}, "on"],
      ]]],
    ['panel', 'mute', { color: 1, }, [[
      ["Mute Group", "mute/group"],
      [{checkbox: "Env Sustain"}, "env/sustain"],
      ["Bend", "bend/range"],
      ]]],
    ['panel', 'outs', { color: 1, }, [[
      ["Dry", "out/level"],
      ["Reverb", "reverb"],
      ["Chorus", "chorus"],
      [{switsch: "Output"}, "out/assign"],
      ]]],
    ['button', "Note", color: 1],
    ['panel', 'space', { }, [[]]],
  ], effects: [
    ['editMenu', "button", paths: JV880.Rhythm.Note.patchWerk.truss.paramKeys(), type: "JV880RhythmNote", init: nil, rand: nil],
    .setup([
      ['dimItem', hideOut, "out/assign", dimAlpha: 0],
    ]),
  ], layout: [
    ['row', [["on", 1], ["wave",2.5],["mute",3], ["outs",4], ["button", 2]]],
    ['row', [["pitch",4],["filter",5],["amp",4]]],
    ['row', [["space",1]]],
    ['col', [["on",1],["pitch",4],["space",1]]],
  ])
}

let noteMiso = Miso.noteName(zeroNote: "C2")

const controller = hideOut => ({
  builders: [
    ['child', note(hideOut), "note"],
    ['switcher', "", 61.map { noteMiso.forward(Float($0)) }, cols: 16, color: 1]
  ], 
  effects: [
    .indexChange({ [
      .midiNote(chan: 0, note: 36 + $0, velo: 100, len: 500),
      .setIndex("note", $0)
    ] })
  ], 
  layout: [
    ['row', [["switch",1]]],
    ['row', [["note",1]]],
    ['col', [["switch",3],["note",6]]],
  ])
})
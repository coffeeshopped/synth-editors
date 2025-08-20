

const pathFn = values => {
  const time0 = values['time/0'] || 0
  const time1 = values['time/1'] || 0
  const time2 = values['time/2'] || 0
  const time3 = values['time/3'] || 0
  const level0 = values['level/0'] || 0
  const level1 = values['level/1'] || 0
  const level2 = values['level/2'] || 0

  var cmds = []

  const segWidth = 0.25
  var x = 0
  
  cmds.push(['move', 0, 0])
  
  // attack
  x += time0 * segWidth
  cmds.push(['line', x, level0])

  // decay
  x += time1 * segWidth
  cmds.push(['line', x, level1])
  
  x += time2 * segWidth
  cmds.push(['curve', x, level2])

  // sustain
  x += segWidth
  cmds.push(['line', x, level2])

  // release
  x += time3 * segWidth
  cmds.push(['curve', x, 0])
  
  return cmds
}


const envItem = {
  env: pathFn,
  l: "Envelope",
  maps: (4).map(i => ['u', ['time', i]]).concat(
    (3).map(i => ['u', ['level', i]])
  )
}

const envCtrlr = {
  prefix: { fixed: 'env' },
  builders: [
    ['panel', 'env', { color: 2 }, [[
      env,
    ]]],
    ['panel', 'knobs', { color: 2 }, [[
      ["T1", "time/0"],
      ["T2", "time/1"],
      ["T3", "time/2"],
      ["T4", "time/3"],
    ],[
      ["L1", "level/0"],
      ["L2", "level/1"],
      ["L3", "level/2"],
      ["Key Trk", "keyTrk"],
    ]]],
  ],
  simpleGridLayout: [
    [['env', 4], ['knobs', 4]],
  ]
}

const ctrlr = {
  builders: [
    ['child', envCtrlr, "env"],
    ['panel', 'osc', { }, [[
      [{imgSelect: "Pulse Wave"}, "osc/wave/pulse"],
      ["PW(M)", "osc/pw/depth"],
      [{switch: "Range"}, "osc/range"],
    ],[
      [{imgSelect: "Saw Wave"}, "osc/wave/saw"],
      ["PWM Rate", "osc/pw/rate"],
      ["Bend", "bend"],
    ],[
      [{imgSelect: "Sub Wave"}, "osc/wave/sub"],
      ["Sub Lvl", "osc/sub/level"],
      ["Noise", "osc/noise/level"],
    ],[
      ["LFO Amt", "pitch/lfo"],
      ["Env Amt", "pitch/env"],
      [{switch: "Env Mode"}, "pitch/env/mode"],
      ["Aftertouch", "pitch/aftertouch"],
    ]]],
    ['panel', 'filter', { color: 3 }, [[
      [{switch: "HPF"}, "hi/cutoff"],
      ["Key Trk", "filter/keyTrk"],
    ],[
      ["Filter Cutoff", "cutoff"],
      ["Reson", "reson"],
    ],[
      [{switch: "Env Mode"}, "filter/env/mode"],
      ["Env Amt", "filter/env"],
    ],[
      ["LFO Amt", "filter/lfo"],
      ["Aftertouch", "filter/aftertouch"],
    ]]],
    ['panel', 'amp', { }, [[
      ["Amp Level", "amp/level"],
    ],[
      [{switch: "Env Mode"}, "amp/env/mode"],
    ],[
      ["Aftertouch", "amp/aftertouch"],
    ]]],
    ['panel', 'lfo', { }, [[
      ["LFO Rate", "lfo/rate"],
    ],[
      ["Delay", "lfo/delay"],
    ]]],
    ['panel', 'chorus', { }, [[
      [{checkbox: "Chorus"}, "chorus"],
    ],[
      ["Rate", "chorus/rate"],
    ]]],
  ],
  effects: [
    ['patchChange', { 
      paths: ["osc/wave/pulse", "osc/wave/saw"], 
      fn: values => {
        const isHidden = values["osc/wave/saw"] != 3 && values["osc/wave/pulse"] != 3
        return [
          ['hideItem', isHidden, 'osc/pw/depth'],
          ['hideItem', isHidden, 'osc/pw/rate'],
        ]
      }, 
    }],
  ],
  layout: [
    ['row', [["osc",4], ["filter",2], ["amp",1], ["lfo",1]], {opts: "alignAllTop"}],
    ['row', [["env",1]]],
    ['col', [["osc",4], ["env",2]]],
    ['colPart', [["lfo",2], ["chorus",2]], {opts: ["alignAllLeading", "alignAllTrailing"]}],
    ['eq', ["osc","filter","amp","chorus"], 'bottom'],
  ]
}



const mod1Lbl = "Mod 1"
const mod2Lbl = "Mod 2"
const amtLbl = "←Amt"

const srcAmtEffect(prefix) => {
  const src = `${prefix}/src`
  const amt = `${prefix}/amt`
  return ['patchChange', {
    paths: [src, amt],
    fn: values => {
      const dim = values[src] == 15 || values[amt] == 0
      return [
        ['dimItem', dim, src],
        ['dimItem', dim, amt],
      ]
    }
  }]
}

const oscController = ['index', 'osc', 'wave', i => `Osc ${i + 1}`, {
  gridBuilder: [[
    [{select: "Osc"}, "wave"],
    ["Octave", "octave"],
    ["Semi", "semitone"],
    ["Fine", "fine"],
  ],[
    [mod1Lbl, "mod/0/src"],
    [amtLbl, "mod/0/amt"],
    [mod2Lbl, "mod/1/src"],
    [amtLbl, "mod/1/amt"],
  ]],
  effects: [
    srcAmtEffect('mod/0'),
    srcAmtEffect('mod/1'),
  ],
}]

const ampController = ['index', 'amp', 'on', i => `Amp ${i + 1}`, {
  gridBuilder: [[
    [{checkbox: "Amp"), "on"],
    [mod1Lbl, "mod/0/src"],
    [amtLbl, "mod/0/amt"],
  ],[
    ["Level", "level"],
    [mod2Lbl, "mod/1/src"],
    [amtLbl, "mod/1/amt"],
  ]],
  effects: [
    srcAmtEffect('mod/0'),
    srcAmtEffect('mod/1'),
    ['dimsOn', 'on']
  ],
}]

const lfoController = ['index', 'lfo', 'wave', i => `LFO ${i + 1}`, {
  color: 2,
  gridBuilder: [[
    [{switch: "LFO"}, "wave"],
    ["Freq", "freq"],
    [{checkbox: "Reset"}, "reset"],
    [{checkbox: "Humanize"}, "analogFeel"],
  ],[
    ["Level 1", "level/0"],
    ["Delay", "delay"],
    ["Level 2", "level/1"],
    [{select: "Mod Source"}, "mod/src"],
  ]],
}]


const envController = (extra) => {
  
  const paths = ([]).concat(
    (3).map(i => `level/${i}`),
    (4).map(i => `time/${i}`)
  )
  const env = {
    display: 'timeLevelEnv',
    pointCount: 4,
    sustain: 2,
    bipolar: true,
    l: "Env",
    id: 'env',
    maps: paths.map(p => ['u', p, 63]), 
  }

  return ['index', 'env', 'env', i => `Env ${i + 1}`, {
    color: 2,
    gridBuilder: [[
      env,
      ["T1 Velo", "time/0/velo"],
      ["T Key", "time/key"],
    ],[
      ["L1", "level/0"],
      ["L2", "level/1"],
      ["L3", "level/2"],
      ["L Velo", "level/velo"],
    ].concat(extra ? [[{switch: "←LV"}, "velo/extra"]] : []), [
      ["T1", "time/0"],
      ["T2", "time/1"],
      ["T3", "time/2"],
      ["T4", "time/3"],
    ].concat(extra ? [[{checkbox: "2nd R"}, "release/extra"]] : [])],
    effects: [
      ['editMenu', 'env', {
        paths: paths,
        type: "ESQEnvelope",
        initialize: [63, 63, 63, 0, 63, 0 ,0],
        // randomize: { 3.map { _ in (-63...63).random()! } + 4.map { _ in (0...63).random()! } }
      }],
    ],
  }]
}

const controller = (sq80) => ({
  builders: [
    ['children', 4, "env", envController(sq80)],
    ['children', 3, "osc", oscController],
    ['children', 3, "amp", ampController],
    ['children', 3, "lfo", lfoController],
    ['panel', 'mods', { }, [[
      ["Glide", "glide"],
      [{checkbox: "AM"}, "am"],
      [{checkbox: "Rotate"}, "rotate"],
    ],[
      [{checkbox: "Wave Reset"}, "wave/reset"],
      [{checkbox: "Cycle"}, "cycle"],
      [{checkbox: "Env Reset"}, "env/reset"],
    ]]],
    ['panel', 'filter', { color: 0 }, [[
      ["Cutoff", "cutoff"],
      ["Reson", "reson"],
      [mod1Lbl, "filter/mod/0/src"],
      [amtLbl, "filter/mod/0/amt"],
    ],[
      { l: 'Filter' },
      ["Key Track", "filter/mod/2/amt"],
      [mod2Lbl, "filter/mod/1/src"],
      [amtLbl, "filter/mod/1/amt"],
    ]]],
    ['panel', 'amp', { }, [[
      ["Env 4 > Amp 4", "amp/3/mod/amt"],
      ["Pan", "pan"],
      [{checkbox: "Mono"}, "mono"],
    ],[
      ["Pan Mod", "pan/mod/src"],
      [amtLbl, "pan/mod/amt"],
      [{checkbox: "Sync"}, "sync"],
    ]]],
    ['panel', 'splits', { }, [
      [[{checkbox: "Split/Layer"}, "split/layer"]],
      [[{select: "S/L Pgm"}, "split/layer/pgm"]],
      [[{checkbox: "Layer"}, "layer"]],
      [[{select: "Layer Pgm"}, "layer/pgm"]],
      [[{switch: "Split"}, "split/direction"]],
      [[{select: "Split Pgm"}, "split/pgm"]],
      [["Split Key", "split/pt"]],
    ]],
  ],
  effects: [
    srcAmtEffect('filter/mod/0'),
    srcAmtEffect('filter/mod/1'),
    srcAmtEffect('pan/mod'),
    // TODO: prob need to not do the default param change mapping on the affected split/layer ctrls
    ['paramChange', 'patch/name', parm => [
      ['configCtrl', 'split/layer/pgm', { opts: parm.opts }]
      ['configCtrl', 'layer/pgm', { opts: parm.opts }]
      ['configCtrl', 'split/pgm', { opts: parm.opts }]
    ]],
  ],
  layout: [
    ['row', [
      ["osc0",9],["amp0",7],["mods",8],["splits",3],["lfo0",8],
    ], {opts: "alignAllTop"}],
    ['rowPart', [["osc1",9],["amp1",7],["filter",8]]],
    ['rowPart', [["osc2",9],["amp2",7],["amp",8]]],
    ['row', [["env0",8],["env1",8],["env2",8],["env3",8]]],
    ['col', [["osc0",2],["osc1",2],["osc2",2],["env0",3]]],
    ['col', [
      ["lfo0",2],["lfo1",2],["lfo2",2],["env3",3],
    ], {opts: "alignAllTrailing"}],
    ['eq', ["osc0","amp0","mods"], 'bottom'],
    ['eq', ["mods","filter","amp"], 'trailing'],
    ['eq', ["lfo0","lfo1","lfo2"], 'leading'],
    ['eq', ["amp","splits","lfo2"], 'bottom'],
  ],
})
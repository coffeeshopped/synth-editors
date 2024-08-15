const Algorithms = require('./algorithms.js')

const opPathFn = i => (p => 
  p.startsWith('extra/') ? `extra/op/${i}/` + p.substring(6) : `voice/op/${i}/` + p
)

const opPath = (index, path) => opPathFn(index)(path)

const opPaths = (index, paths) => {
  const p = opPathFn(index)
  return paths.map(path => p(path))
}

const opItems = (index, items) => {
  const p = opPathFn(index)
  return items.map(item => item.map(x => {
    // don't process env display
    if (x.env) { return x }
    
    var cfg = x[0]
    const path = x[1]
    cfg.id = path
    return [cfg, p(path)]
  }))
}

const envItem = i => {
  const opp = opPathFn(i)
  return {
    env: envPathFn,
    l: "", 
    maps: [
      ['u', opp('attack'), 31, 'attack'],
      ['u', opp('decay/0'), 31, 'decay/0'],
      ['u', opp('decay/1'), 31, 'decay/1'],
      ['u', opp('decay/level'), 15, 'decay/level'],
      ['u', opp('release'), 15, 'release'],
      ['u', opp('level'), 99, 'level'],
      ['u', opp('extra/shift'), 4, 'shift'],
    ], 
    id: 'env',
  }
}

const envPathFn = values => {
  // must set default values as not all values may be present.
  const shft = values['shift'] || 0
  const a = values['attack'] || 0
  const d1 = values['decay/0'] || 0
  const d2 = values['decay/1'] || 0
  const s = values['decay/level'] || 0
  const r = values['release'] || 0
  const level = values['level'] || 0

  var cmds = []

  const segWidth = 1 / 5
  const shftHeight = shft // TODO: make it log not lin
  var x = 0
  
  // move to 0 , shftHeight
  cmds.push(
    ['move', x, 0],
    ['line', x, shftHeight]
  )
  
  // ar
  x += a == 1 ? 0 : 1 / Math.tan((0.25 + 0.25 * a) * Math.PI)
  cmds.push(['line', x, 1])
  
  // d1r
  x += d1 == 1 ? 0 : 1 / Math.tan((0.25 + 0.25 * d1) * Math.PI)
  cmds.push(['line', x, shftHeight + s])
  
  // d2r
  x += (1 - d2) * segWidth
  const y = shftHeight + (d2 == 0 ? 1 : 0.5) * s
  cmds.push(['line', x, y])
  
  // sustain
  x += (1 - r) * segWidth
  cmds.push(
    ['line', x, shftHeight],
    ['line', 1, shftHeight],
    ['line', 1, 0],
    ['scale', 1, level]
  )
  
  
  return cmds
}

module.exports = {
  opPath: opPath,
  opPaths: opPaths,
  opItems: opItems,
  envItem: envItem,
  algoCtrlr: miniOp => ['fm', Algorithms.algorithms, miniOp, {
    algo: 'voice/algo',
  }],
  miniOpController: (index, ratioEffect, opType, allPaths) => ({
    builders: [
      ['items', { color: 2 }, [
        [envItem(index), "env"],
        [{l: "?", align: 'leading', size: 11, id: "op"}, "op"],
        [{l: "x", align: 'trailing', size: 11, bold: false, id: "osc/mode"}, "freq"],
      ]]
    ],
    effects: [
      ratioEffect,
      ['dimsOn', opPath(index, "on")],
      ['indexChange', v => ['setCtrlLabel', 'op', `${v + 1}`]],
      ['editMenu', "env", { 
        paths: opPaths(index, allPaths),
        type: opType,
      }],
    ], 
    layout: [
      ['row', [["op",1],["freq",4]]],
      ['row', [["env",1]]],
      ['colFixed', ["op", "env"], { fixed: "op", height: 11, spacing: 2 }],
    ]
  })
}

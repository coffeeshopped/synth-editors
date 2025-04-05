const VCED = require('./vced.js')
const ACED = require('./aced.js')

const patchChangeTransform = werkMap => ({
  type: 'multiDictPatch',
  throttle: 100,
  editorVal: opOns,
  param: (path, parm, value) => {
    const first = pathPart(path, 0)
    const isOpOn = first == 'voice' && path[path.length - 1] == 'on'
    const parmByte = isOpOn ? 93 : parm.b
    var data = [first, ['byte', parmByte]]
    switch (first) {
      case 'voice':
        // TODO: opOn stuff
        // const v = isOpOn ? opOnByte(editorVal, path[2], value) : subval
        data.push(VCED.patchWerk.paramData([parmByte, 'b']))
        break
      case 'extra':
        data.push(ACED.patchWerk.paramData([parmByte, 'b']))
        break
      case 'aftertouch':
        // offset byte by 23 to get param address
        data.push(ACED.patchWerk.paramData([parmByte + 23, 'b']))
        break
      default:
        return null
    }
    return [[data, 0]]
  }, 
  patch: werkMap.map(pair => [[pair[0], pair[1].sysexData], 100]),
  name: VCED.patchTruss.namePack.rangeMap(i => [
    ['voice', VCED.patchWerk.paramData([i, ['byte', i]])], 10
  ]),
})

const voiceBankTransform = (voiceBankTruss) => ({
  type: 'wholeBank',
  throttle: 0,
  multiBankTruss: voiceBankTruss,
  waitInterval: 100,
})

// 
// const backupTruss = {
//   type: 'backup',
//   name: synth,
//   map: [
//     ["micro/octave", Op4micro.octWerk.truss],
//     ["micro/key", Op4micro.fullWerk.truss],
//     ["bank", Voice.bankTruss],
//     ["bank/perf", Perf.bankTruss],
//   ], 
//   pathForData: (d) => {
//     switch (d.length) {
//     case 42:
//       return "micro/octave"
//     case 274:
//       return "micro/key"
//     case 4104:
//       return "bank"
//     case 2450:
//       return "bank/perf"
//     default:
//       return null
//     }
//   }
// }

const opOns = (4).map(i => ['extra', 'patch', ['voice', 'op', i, 'on']])

// calc based on stored editor values and new incoming value
const opOnByte = (dict, newOp, value) => {
  (4).map(i => {
    const isOn = i == newOp ? value > 0 : dict[transform] == 1
    return isOn ? 1 << ((4 - 1) - i) : 0
  }).sum()
}


module.exports = {
  patchChangeTransform,
  voiceBankTransform,
}
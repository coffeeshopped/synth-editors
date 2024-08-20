const Matrix = require('./matrix.js')
const Matrix6Voice = require('./matrix6voice.js')

const tempSysexData = Matrix6Voice.sysexDataWithHeader(0x0d, 0x00)

const patchOut = [[tempSysexData, 100]]

const patchTruss = Matrix6Voice.createPatchTruss(tempSysexData)

const negMap = value => value < 0 ? value + 128 : value

module.exports = {
  patchTruss: patchTruss,
  patchTransform: {
    type: 'singlePatch',
    throttle: 200,
    param: (path, parm, value) => {
      if (!parm) { return null }

      if (parm.p < 0) {
        // MATRIX MOD SEND
        // mod number is encoded in params as negative parm value (1...10)
        const mod = (-parm.p) - 1
        
        return [[[
          '>', 
          ['e.values', 'patch', [
            ["mod", mod, "src"],
            ["mod", mod, "amt"],
            ["mod", mod, "dest"],
          ], negMap],
          [0xf0, 0x10, 0x06, 0x0b, mod, "b", 0xf7]
        ], 10]]
      }
      else if (value < 0 || pathEq(path, "env/0/sustain") || pathEq(path, "amp/1/env/1/amt")) {
        return patchOut
      }
      else {
        // NORMAL PARAM SEND
        return [[Matrix.sysex([0x06, parm.p, negMap(v)]), 10]]
      } 
    }, 
    patch: patchOut,
    name: patchOut,
  },
  bankTruss: Matrix6Voice.createBankTruss(patchTruss),
  bankTransform: bank => ({
    type: 'singleBank',
    throttle: 0,
    bank: (location) => [
      [Matrix.bankSelect(bank), 100],
      [Matrix6Voice.sysexDataWithLocation(location), 50],
    ],
  })
}

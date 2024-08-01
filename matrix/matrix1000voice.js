const Matrix = require('./matrix.js')
const Matrix6Voice = require('./matrix6voice.js')

const tempSysexData = Matrix6Voice.sysexDataWithHeader([0x0d, 0x00])

const patchOut = [[tempSysexData, 100]]

const patchTruss = Matrix6Voice.createPatchTruss(tempSysexData)

module.exports = {
  patchTruss: patchTruss,
  tempSysexData: tempSysexData,
  patchTransform: {
    type: 'singlePatch',
    throttle: 200,
    param: (editorVal, bodyData, parm, value) => {
      if (!parm) { return null }

      if (parm.p < 0) {
        // MATRIX MOD SEND
        // mod number is encoded in params as negative parm value (1...10)
        let mod = (-parm.p) - 1
        
        return [
          [[
            ['trussValues', patchTruss, [
              ["mod", mod, "src"],
              ["mod", mod, "amt"],
              ["mod", mod, "dest"],
            ], (amt) => amt < 0 ? amt + 128 : amt],
            ['wrap', [0xf0, 0x10, 0x06, 0x0b, mod], [0xf7]]
          ], 10]
        ]
      }
      else {
        // NORMAL PARAM SEND
        if (value < 0 || pathEq(parm.path, "env/0/sustain") || pathEq(parm.path, "amp/1/env/1/amt")) {
          return patchOut
        }
        else {
          // if value is negative, do some bit twiddling
          let v = value < 0 ? value + 128 : value
          return [[Matrix.sysex([0x06, parm.p, v]), 10]]
        }
      }
    
    }, 
    patch: (editorVal, bodyData) => patchOut,
    name: (editorVal, bodyData, path, name) => patchOut,
  },
  bankTruss: Matrix6Voice.createBankTruss(patchTruss),
  bankTransform: (bank) => ({
    type: 'singleBank',
    throttle: 0,
    bank: (editorVal, bodyData, location) => [
      [Matrix.bankSelect(bank), 100],
      [Matrix6Voice.sysexDataWithLocation(location), 50],
    ],
  })
}

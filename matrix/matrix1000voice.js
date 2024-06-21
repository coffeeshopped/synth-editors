const Matrix = require('./matrix.js')
const Matrix6Voice = require('./matrix6voice.js')

const tempSysexData = (bodyData) => Matrix6Voice.sysexDataWithHeader(bodyData, [0x0d, 0x00])

const patchOut = (bodyData) => [[["syx", tempSysexData(bodyData)], 100]]

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
        let src = trussValue(patchTruss, bodyData, ["mod", mod, "src"])
        let amt = trussValue(patchTruss, bodyData, ["mod", mod, "amt"])
        let dest = trussValue(patchTruss, bodyData, ["mod", mod, "dest"])
        const v = amt < 0 ? amt + 128 : amt
    
        const cmdBytes = [0x0b, mod, src, v, dest]
        return [[["syx", Matrix.sysex(cmdBytes)], 10]]
      }
      else {
        // NORMAL PARAM SEND
        if (value < 0 || pathEq(parm.path, "env/0/sustain") || pathEq(parm.path, "amp/1/env/1/amt")) {
          return patchOut(bodyData)
        }
        else {
          // if value is negative, do some bit twiddling
          let v = value < 0 ? value + 128 : value
          return [[["syx", Matrix.sysex([0x06, parm.p, v])], 10]]
        }
      }
    
    }, 
    patch: (editorVal, bodyData) => patchOut(bodyData),
    name: (editorVal, bodyData, path, name) => patchOut(bodyData),
  },
  bankTruss: Matrix6Voice.createBankTruss(patchTruss),
  bankTransform: (bank) => {
    return {
      type: 'singleBank',
      throttle: 0,
      bank: (editorVal, bodyData, location) => [
        [["syx", Matrix.bankSelect(bank)], 100],
        [Matrix6Voice.sysex(bodyData, location), 50],
      ],
    }
  }
}

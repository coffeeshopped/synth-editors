const Matrix6 = require('./matrix6.js')
const Matrix1000 = require('./matrix1000.js')

module.exports = {
  modules: [
    Matrix6.createModuleTruss("Matrix-6", "matrix6"),
    Matrix6.createModuleTruss("Matrix-6r", "matrix6r"),
    Matrix1000.module,
  ]
}


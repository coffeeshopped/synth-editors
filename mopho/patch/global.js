require('/core/ArrayUtils.js')

module.exports = {
  bytes(data, byteRange) {
    let b = data.safeBytes(byteRange)
    return (byteRange.rangeLength() / 2).map((i) => b[2 * i] + (b[2 * i + 1] << 4))
  },
  
  fileData(bytes, idByte) {
    return ([0xf0, 0x01, idByte, 0x0f]).concat(bytes.map((b) => [b & 0x0f, (b >> 4) & 0x0f]).flat()).concat([0xf7])
  },
}
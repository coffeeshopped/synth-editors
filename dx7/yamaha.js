const checksum = bytes => (-1 * bytes.sum()) & 0x7f

module.exports = {
  checksum: checksum,

  patchSysex: function(bytes, channel, cmdBytes) {
    return ([0xf0, 0x043, channel]).concat(cmdBytes).concat(bytes).concat([checksum(bytes), 0xf7])
  },

  paramSysex: (channel, bytes) => ([0xf0, 0x43, 0x10 + channel]).concat(bytes).concat([0xf7]),

}
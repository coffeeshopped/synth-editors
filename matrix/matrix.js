

const sysex = cmdBytes => ['+', [0xf0, 0x10, 0x06], cmdBytes, 0xf7]
  
module.exports = {
  sysex: sysex,
  fetchPatch: location => sysex(['+', [0x04, 0x01], location]),
  tempPatch: ['e', 'global', 'patch'],
  bankSelect: bank => sysex([0x0a, bank]),
}


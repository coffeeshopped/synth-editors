
const sysexCmd = (bytes) => [0xf0, 0x00, 0x20, 0x33, 0x01, 'deviceId', bytes, 0xf7]
const fetchCmd = (bytes) => ['truss', sysexCmd(bytes)]

const = embMultiFetchCmd = (loc) => ['sequence', ([
  Virus.fetchCmd([0x31, loc, 0x00])
]).concat(
  (16).map(i => Virus.fetchCmd([0x30, loc, i]))
)]

module.exports = {
  sysexCmd,
  fetchCmd,
  embMultiFetchCmd,
}
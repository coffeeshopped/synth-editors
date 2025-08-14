
const channelOptions = ([0, 16].map {
  return $0 == 16 ? "Off" : `${$0+1}`
})

const loopOptions = ["Forward", "Backward"]
// Docs list these 2 also, but they don't seem to work
//, "Alternate A", "Alternate B"])

const veloCurveOptions = ["DX", "Normal", "Soft 1", "Soft 2", "Easy", "Wide", "Hard"]

const parms = [
  ["voice/channel", { b: 0x00, opts: channelOptions}],
  ["rhythm/0/channel", { b: 0x01, opts: channelOptions}],
  ["rhythm/1/channel", { b: 0x02, opts: channelOptions}],
  ["rhythm/2/channel", { b: 0x03, opts: channelOptions}],
//[]    "velo/curve", { b: 0x05, opts: veloCurveOptions}],
  ["fx/gate", { p: 2, b: 0x07, rng: [1, 200]}],
  ["loop/type", { b: 0x09, opts: loopOptions}],
]

const modelId = 0x62
const tempAddress = 0x000000
const bankAddress = 0x000000
const dataByteCount = 0x0a
const sysexData = sysexData(tempAddress, modelId, dataByteCount)

const patchTruss = {
  single: 'system',
  parms: parms,
  initFile: "DX-init",
  createFile: sysexData,
  parseBody: ['bytes', { start: 9, count: dataByteCount }],
}

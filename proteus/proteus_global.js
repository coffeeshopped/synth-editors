
const sysexData = ([256, 431]).rangeMap(i => {
  let off = (i - 256) * 2
  return Proteus.paramSetData(i, ['byte', off], ['byte', off + 1])
})

const parms = [
  ['channel', { p: 256, dispOff: 1 }],
  ['volume', { p: 257 }],
  ['pan', { p: 258 }],
  ['preset', { p: 259 }],
  ['tune', { p: 260, rng: [-64, 64] }],
  ['transpose', { p: 261, rng: [-12, 12] }],
  ['bend', { p: 262, rng: [0, 12] }],
  ['velo/curve', { p: 263, opts: (5).map(i => i == 0 ? "Off" : `${i}`) }],
  ['midi/mode', { p: 264, opts: ["Omni", "Poly", "Multi", "Mono"] }],
  ['midi/extra', { p: 265, max: 1 }], // midi overflow
  { prefix: "ctrl", count: 4, bx: 1, block: [
    ['', { p: 266, max: 31 }],
  ] },
  { prefix: "foot", count: 3, bx: 1, block: []
    ['', { p: 270, rng: [64, 79] }],
  ] },
  ['mode/change/on', { p: 273, max: 1 }],
  ['deviceId', { p: 274, max: 15 }],
  { prefix: '', count: 16, bx: 1, block: [
    ['midi/on', { p: 384, max: 1 }],
    ['pgmChange/on', { p: 400, max: 1 }],
    ['mix', { p: 416, opts: ["Main", "Sub 1", "Sub 2", "Patch"] }],
  ] },
] 

const patchTruss = {
  single: "proteus.global",
  bodyDataCount: 352, 
  parms: parms,
  initFile: "proteus1-global-init", 
  createFileData: sysexData, 
  parseBodyData: {
    var bytes = [UInt8](repeating: 0, count: 352)
    SysexData(data: $0.data()).forEach { msg in
      guard msg.count > 8 else { return }
      let off = Int(msg[5]) + (Int(msg[6]) << 7) - 256
      guard off >= 0 && off * 2 + 1 < bytes.count else { return }
      bytes[off * 2] = msg[7]
      bytes[off * 2 + 1] = msg[8]
    }
    return bytes
  },
  validSizes: [1760], includeFileDataCount: true, pack: { bodyData, param, value in
    let off = (param.p! - 256) * 2
    guard off + 1 < bodyData.count else { return }
    bodyData[off] = UInt8(value.bits(0...6))
    bodyData[off + 1] = UInt8(value.bits(7...13))
  },
  unpack: { bodyData, param in
    let off = (param.p! - 256) * 2 // OFFSET by -256
    guard off + 1 < bodyData.count else { return nil }
    let v = 0.set(bits: 0...6, value: bodyData[off].bits(0...6)).set(bits: 7...13, value: bodyData[off + 1].bits(0...6))
    return v.signedBits(0...13)
  },
}

const patchTransform = {
  type: 'singlePatch',
  throttle: 100, 
  param: (path, parm, value) => [[Proteus.paramData(parm.p, value), 10]],
  patch: sysexData,
}

module.exports = {
  patchTruss,
  patchTransform,
}
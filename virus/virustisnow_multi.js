
const outOptions = ["Out1 L", "Out1 L+R", "Out1 R"]

const patchTruss = VirusTIMulti.patchTruss
patchTruss.parms = patchTruss.parms.concat([
  {prefix: 'part', count: 16, bx: 1, block: [
    ["out", { p: 0x29, b: 176, opts: outOptions }],    
  ] },
])

const patchTransform = {
  throttle: 100,
  param: (path, parm, value) => {
    let cmdByte: UInt8
    let part: Int
    let parm: Int
    switch path[0] {
    case .common:
      let subpath = path.subpath(from: 1)
      guard let param = VirusTIMultiPatch.params[subpath] else { return nil }
      part = subpath.i(1) ?? 0
      cmdByte = 0x72
      parm = param.parm
    default:
      let subpath = path.subpath(from: 2)
      guard let param = VirusTIVoicePatch.params[subpath] else { return nil }
      part = path.i(1) ?? 0
      let section = param.byte / 128 // should be 0...3
      cmdByte = [0x70, 0x71, 0x6e, 0x6f][section]
      parm = param.byte % 128
    }
    
    let cmdBytes = self.sysexCommand([cmdByte, UInt8(part), UInt8(parm), UInt8(value)])
    return [Data(cmdBytes)]
  },
  singlePatch: [[tempMultiData(patch: patch), 10]],
  name: { (patch, path, name) -> [Data]? in
    let cmdByte: UInt8
    let part: Int
    let parm: Int
    switch path.first {
    case nil:
      part = 0
      cmdByte = 0x72
      parm = 0x04
    default:
      part = path.i(1) ?? 0
      cmdByte = 0x71
      parm = 0x70
    }
    
    // both voice and multi have 10-char names
    return [Data(name.bytes(forCount: 10).enumerated().map {
      Data(self.sysexCommand([cmdByte, UInt8(part), UInt8(parm + $0.offset), $0.element]))
    }.joined())]
  }
}

  private func tempMultiData(patch: VirusTISnowEmbeddedMultiPatch) -> [Data] {
  return patch.sysexData(deviceId: deviceId, location: -1)
}

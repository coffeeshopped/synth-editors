
  func unpack(param: Param) -> Int? {
  guard let p = param as? ParamWithRange,
        p.range.lowerBound < 0 else { return defaultUnpack(param: param) }
  
  // handle negative values
  guard let bits = p.bits else { return Int(Int8(bitPattern: bytes[p.byte])) }
  return bytes[p.byte].signedBits(bits)
}
    
const keyIso = Miso.noteName(zeroNote: "C-1")

const veloIso = Miso.switcher([
  .int(128, "Key"),
  .int(129, "Step"),
], default: Miso.str())

const gateIso = Miso.switcher([
  .int(101, "Step")
], default: Miso.unitFormat("%"))

const toneIso = Miso.switcher([
  .int(13, "Loop"),
], default: Miso.str())

const stepGateIso = Miso.switcher([
  .int(0, "Off"),
], default: Miso.unitFormat("%"))

const parms = [
  ["step/time", { p: 18, b: 17, opts: ["4", "4T", "8", "8T", "16", "16T"] }],
  ["sortOrder", { p: 19, b: 18, max: 1 }],
  ["key/lo", { p: 20, b: 19, iso: keyIso }],
  ["key/hi", { p: 21, b: 20, iso: keyIso }],
  ["velo", { p: 22, b: 21, rng: [1, 129], iso: veloIso }],
  ["velo/ctrl/amt", { p: 24, b: 23, rng: [-99, 99] }],
  ["gate", { p: 25, b: 24, max: 101, iso: gateIso }],
  ["gate/ctrl/amt", { p: 27, b: 26, rng: [-99, 99] }],
  ["type", { p: 28, b: 27, opts: ["As Play", "As Play(Fill)", "Run Up", "Up&Down"] }],
  ["octave/alt", { p: 29, b: 28, opts: ["Up", "Down", "Up&Down"] }],
  { prefix: 'step', count: 24, bx: 4, px: 4, block: [
    ["offset", { p: 33, b: 32, rng: [-49, 49] }],
    ["tone", { p: 34, b: 33, rng: [1, 13], iso: toneIso }],
    ["velo", { p: 35, b: 34, rng: [1, 127] }],
    ["gate", { p: 36, b: 35, max: 100, iso: stepGateIso }],
  ] },
]

function sysexData(program) {
  return [Prophecy.sysexHeader, 0x69, program, 0x00, ['pack78'], 0xf7]
}

const patchTruss = {
  single: 'arp',
  parms: parms,
  namePack: [0, 15],
  initFile: "prophecy-arp-init",
  parseBody: ['>',
    ['bytes', { start: 7, count: 147 }],
    'unpack87',
  ],
  createFile: sysexData(0),
}


class ProphecyArpBank : TypicalTypedSysexPatchBank<ProphecyArpPatch> {

  override class var fileDataCount: Int { return 1471 }
  override class var patchCount: Int { return 10 }
  override class var initFileName: String { return "prophecy-arp-bank-init" }

  static let contentByteCount = 1463
  
  static let names = ["Up", "Down", "Alt 1", "Alt 2", "Random", "Pat1", "Pat2", "Pat3", "Pat4", "Pat5"]
  
  required init(data: Data) {
    let byteOffset = 7
    let bytesPerPatch = 128
    let rawData = Data(data.unpack87(count: bytesPerPatch * Self.patchCount, inRange: byteOffset..<(byteOffset + Self.contentByteCount)))
    let patches = Self.patches(fromData: rawData, offset: 0, bytesPerPatch: bytesPerPatch) {
      Patch(rawBytes: [UInt8]($0))
    }
    Self.names.enumerated().forEach { patches[$0.offset].name = $0.element }
    super.init(patches: patches)
  }
  
  func sysexData(channel: Int) -> Data {
    var data = Data(Prophecy.sysexHeader(deviceId: UInt8(channel)) + [0x69, 0x10, 0x00])
    let bytesToPack = [UInt8](patches.map { $0.bytes }.joined())
    data.append(Data.pack78(bytes: bytesToPack, count: Self.contentByteCount))
    data.append(0xf7)
    return data
  }
  
  override func fileData() -> Data {
    return sysexData(channel: 0)
  }
    
}

const patchTransform = {
  throttle: 50,
  param: (path, parm, value) => {
    if path == [.number] {
      return [
        Data(
          Midi.cc(99, value: 0, channel: self.channel) +
          Midi.cc(98, value: 1, channel: self.channel) +
          Midi.cc(6, value: value, channel: self.channel)
        )
      ]
    }
    
    guard let param = type(of: patch).params[path] else { return nil }
    return [Data(self.paramChange(group: 2, paramId: param.parm, value: value))]
  },
  singlePatch: [[sysexData(program: self.tempArp), 10]],
}



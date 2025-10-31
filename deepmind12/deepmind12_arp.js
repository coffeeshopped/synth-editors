
const parms = [
  ["length", { b: 0, max: 31, dispOff: 1 }],
  { prefix: '', 32, bx: 1, block: [
    ["velo", { b: 1, max: 128 }],
  ] },
  { prefix: '', 32, bx: 1, block: [
    ["gate", { b: 33, max: 128, iso: ['switch', [
      [128, "Tie"],
    ]] }],
  ] },
]

function sysexData(headerBytes) {
  return [Deepmind12.sysexHeader, headerBytes, ['pack78', 'b' 80], 0xf7]
}

/// Edit buffer sysex
const editBuffer = sysexData([0x0f, 0x07])

func sysexData(program) {
  return sysexData([0x08, 0x07, program])
}

const patchTruss = {
  single: 'arp',
  parms: parms,
  initFile: "deepmind12-arp-init",
  // 74 is edit buffer, 75 is stored program
  validSizes: ['auto', 89],
  createFile: editBuffer,
}

class Deepmind12ArpPatch : ByteBackedSysexPatch, BankablePatch {
  
  static func location(forData data: Data) -> Int { return Int(data[8]) }

  const fileDataCount = 90
      
  required init(data: Data) {
    let range = data.count == 89 ? 8..<88 : 9..<89
    bytes = data.unpack87(count: 65, inRange: range)
  }
      
}

const bankTruss = {
  singleBank: patchTruss,
  patchCount: 32,
  initFile: "deepmind12-arp-bank-init",
  namePrefix: 'Arp',
}

const patchTransform = {
  throttle: 50,
  param: (path, parm, value) => {
    guard let param = type(of: patch).params[path] else { return nil }
    let channel = UInt8(self.channel)
    
    let index = param.byte + 123
    let b1: UInt8 = index > 127 ? 7 : 6
    let b2: UInt8 = UInt8(index % 128)
    let msgs: [MidiMessage] = [
      .cc(channel: channel, number: 99, value: b1),
      .cc(channel: channel, number: 98, value: b2),
      .cc(channel: channel, number: 6, value: UInt8(value >> 7)),
      .cc(channel: channel, number: 38, value: UInt8(value & 0x7f))
    ]
    
    return msgs.map { Data($0.bytes()) }
  },
  singlePatch: [[sysexData, 10]], 
}

class Deepmind12ArpBank : TypicalTypedSysexPatchBank<Deepmind12ArpPatch> {

  override class var fileDataCount: Int { return 32 * 90 }
    
  func sysexData(deviceId: Int) -> Data {
    return sysexData { (patch, location) -> Data in
      patch.sysexData(channel: deviceId, program: location)
    }
  }
  
  override func fileData() -> Data {
    return sysexData(deviceId: 0)
  }
    
}


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

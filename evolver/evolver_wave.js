
class EvolverWavePatch : ByteBackedSysexPatch, BankablePatch {
  
  // bank locations are 0..<32. ROM locations will therefore come through as negative
  static func location(forData data: Data) -> Int { return Int(data[5]) - 96 }
  
  const fileDataCount = 300
  const dataByteCount = 293 // number of data bytes in packed format
  
  required init(data: Data) {
    let startByte = data.count - (type(of: self).dataByteCount + 1)
    bytes = data.unpack87(count: 256, inRange: startByte..<(data.count-1))
  }
  
  subscript(path: SynthPath) -> Int? {
    get {
      guard let i = path.i(1) else { return nil }
      return Int(Int16(bitPattern: UInt16(bytes[i * 2]) + (UInt16(bytes[i * 2 + 1]) << 8)))
    }
    set {
      guard let i = path.i(1),
        i < 128,
        let newValue = newValue else { return }
      let int16 = Int16(newValue)
      bytes[i * 2] = UInt8(int16 & 0xff)
      bytes[i * 2 + 1] = UInt8((int16 >> 8) & 0xff)
    }
  }
  
  // only [96, 127] are writeable
  func sysexData(location: Int) -> Data {
    var data = Data([0xf0, 0x01, 0x20, 0x01, 0x0a, UInt8(location + 96)])
    data.append78(bytes: bytes, count: type(of: self).dataByteCount)
    data.append(0xf7)
    return data
  }
  
}


const parms = [
  { prefix: 'data', count: 128, bx: 2, block: [
    ["", { b: 0, rng: [-32768, 32767] }],
  ] },
]

const patchTruss = {
  single: 'wave',
  parms: parms,
  initFile: "evolver-wave-init",
}


const bankTruss = {
  singleBank: patchTruss,
  patchCount: 32,
  initFile: "evolver-wave-bank-init",
}

class EvolverWaveBank : TypicalTypedSysexPatchBank<EvolverWavePatch> {
  
  override func fileData() -> Data {
    return sysexData(transform: { (patch, location) -> Data in
      return patch.sysexData(location: location)
    })
  }

}

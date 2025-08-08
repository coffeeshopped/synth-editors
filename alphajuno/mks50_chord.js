
const parms = [
  { prefix: 'note', count: 6, bx: 1, block: [
    ['', { b: 0, opts: noteOptions }],
  ] },
]

const noteOptions = {
  var options = [Int:String]()
  ([36, 84]).forEach {
    options[$0] = `${$0}`
  }
  options[127] = "Off"
  return options
}()

/// Chord as sysex for edit buffer - 4.1.6
const sysexData = [0xf0, 0x41, 0x35, 'channel', 0x23, 0x40, 0x01, 'b', 0xf7]

// 14 bytes - 3.1.3 All Params // transmitted when patch change on synth
// 12 bytes - 3.2.3 Bulk Dump: an entire bulk dump has 16 patches. The 12 bytes will be just the data bytes for 1 chord (as nibbles)
// 45 - 31 patch bytes then 14 chord bytes

// internal PB bytes are in 3.2.3 format (BULK)
// 6 bytes

const patchTruss = {
  single: 'mks50.chord',
  bodyDataCount: 6,
  initFile: "mks50-chord-init",
  validSizes: [14,12,45],
  createFile: sysexData,
}

class MKS50ChordPatch : ByteBackedSysexPatch, BankablePatch {
  
  static func location(forData data: Data) -> Int {
    return Int(data[8]) // this is the general block location, not specific patch
  }
  
  const fileDataCount = 14

  required init(data: Data) {
    switch data.count {
    case 45:
      bytes = [UInt8](data[38..<44])
    case 14:
      bytes = [UInt8](data[7..<13])
    case 12:
      // bulk data
      bytes = (0..<6).map {
        // LSB first
        let lsb = data[$0 * 2] & 0xf
        let msb = (data[$0 * 2 + 1] & 0xf) << 4
        let b = lsb + msb
        return b == 255 ? 127 : (b + 60) % 128
      }
    default:
      debugPrint("MKS-50 Chord: Unknown data count for init")
      bytes = [UInt8](repeating: 0, count: 6)
    }
  }
  
}


class MKS50ChordBank : TypicalTypedSysexPatchBank<MKS50ChordPatch> {
  
  override class var fileDataCount: Int { return 202 }
  override class var patchCount: Int { return 16 }
  // TODO: need actual init file
  override class var initFileName: String { return "mks50-chord-bank-init" }
    
  required init(data: Data) {
    var i = 1
    var p: [Patch] = stride(from: 9, to: data.count, by: 12).compactMap { doff in
      let endex = doff + 12
      guard endex <= data.count else { return nil }
      let sysex = data.subdata(in: doff..<endex)
      let p = Patch(data: sysex)
      p.name = "Chord \(i)"
      i += 1
      return p
    }
    
    (0..<(type(of: self).patchCount-p.count)).forEach { _ in
      p.append(Patch())
    }
    super.init(patches: p)
  }
  
  required init(patches p: [Patch]) {
    super.init(patches: p)
  }
  
  func sysexData(channel: Int) -> Data {
    var d = Data([0xf0, 0x41, 0x37, UInt8(channel), 0x23, 0x40, 0x01, 0x00, 0x00])
    patches.forEach { patch in
      d.append(contentsOf: patch.bytes.map { (byte) -> [UInt8] in
        let b: UInt8 = byte == 127 ? 255 : (byte + 68) % 128
        return [b & 0x0f, (b >> 4) & 0x0f]
      }.joined())
    }
    d.append(0xf7)
    return d
  }
  
  override open func fileData() -> Data {
    return sysexData(channel: 0)
  }

}


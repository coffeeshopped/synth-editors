
class MiniakVoiceIndexPatch : ByteBackedSysexPatch, GlobalPatch {

  static var params: SynthPathParam = [:]
  
  static let initFileName = "micron-voice-index-init"
  static let fileDataCount = 12000
  
  var name: String = ""
  
  static func isValid(fileSize: Int) -> Bool { true }
  
  
  private let originalData: Data
  var bytes: [UInt8]
  
  var count: Int { return bytes.count / 16 }

  var voices: [[String?]] = (0..<8).map { _ in [String?](repeating: nil, count: 128) }

  private subscript(i: Int) -> (name: String, bank: Int, location: Int) {
    let off = i * 16
    let name = String(bytes: bytes[(off)..<(off+14)], encoding: .ascii)?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines.union(.controlCharacters)) ?? ""
    return (name, Int(bytes[off+14]), Int(bytes[off+15]))
  }
  

  required init(data: Data) {
    originalData = data
    guard data.count >= 66 else {
      bytes = []
      return
    }
    
    let packedByteCount = (data.count - 1) - 9
    let unpackedByteCount = ((packedByteCount / 8) + 1) * 7
    let b = data.unpackR87(count: unpackedByteCount, inRange: 9..<(data.count - 1))
    bytes = [UInt8](b[56..<unpackedByteCount])
    
    (0..<count).forEach { i in
      let entry = self[i]
      voices[entry.bank][entry.location] = entry.name
    }
    
//    (0..<8).forEach { bank in
//      (0..<128).forEach { location in
//        debugPrint("Name: \(voices[bank][location]) | (\(bank), \(location))")
//      }
//    }
  }

  func fileData() -> Data { originalData }
}



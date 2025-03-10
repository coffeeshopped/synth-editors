
let D50CharLookup = " ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890-"

protocol D50Patch : RolandAddressable { }
extension D50Patch {
  static var addressCount: Int { return 3 }

  static func dataSetHeader(deviceId: Int) -> Data {
    return Data([0xf0, 0x41, UInt8(deviceId), 0x14, 0x12])
  }
}

protocol D50SinglePatch : D50Patch, RolandSingleAddressable { }
extension D50SinglePatch {
  
  func fileData() -> Data {
    // deviceID of 0, bc default MIDI channel (not deviceID like later Rolands)
    return sysexData(deviceId: 0, address: type(of: self).fileDataAddress).reduce(Data(), +)
  }

  
  var name: String {
    set {
      let nameByteRange = type(of: self).nameByteRange
      var nameBytes = [UInt8](repeating: 0, count: nameByteRange.count)
      newValue.enumerated().forEach {
        // if name is too long to encode, stop
        guard $0.offset < nameByteRange.count else { return }
        
        var index = 0
        if let lookupIndex = D50CharLookup.firstIndex(of: $0.element) {
          index = D50CharLookup.distance(from: D50CharLookup.startIndex, to: lookupIndex)
        }
        nameBytes[$0.offset] = UInt8(index)
      }
      
      bytes.replaceSubrange(nameByteRange, with: nameBytes)
    }
    get {
      let nameByteRange = type(of: self).nameByteRange
      guard nameByteRange.count > 0 else { return "" }
      var n = ""
      for byte in bytes[nameByteRange] {
        let subIndex = D50CharLookup.index(D50CharLookup.startIndex, offsetBy: Int(byte))
        n.append(D50CharLookup[subIndex])
      }
      return n.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines.union(.controlCharacters))
    }
  }
}

protocol D50MultiPatch : D50Patch, RolandMultiAddressable { }

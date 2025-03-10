
class MinilogueBank : TypedSysexPatchBank {
  
  required init(patches p: [Patch]) {
    patches = p
  }
  
  func copy() -> Self {
    Self.init(patches: patches.map { $0.copy() })
  }
  
  
  static let patchCount = 200
  
  var patches: [MiniloguePatch]
  var name = ""
  
  // TODO: need actual init file
  static let initFileName = "minilogue-bank-init"
  
  static let fileDataCount = 104400 // extra bytes for locations
  
  func sysexData(channel: Int) -> Data {
    return sysexData(transform: { (patch, location) -> Data in
      patch.sysexData(channel: channel, location: location)
    })
  }
  
  func fileData() -> Data {
    return sysexData(channel: 0)
  }
  
  required init(data: Data) {
    patches = type(of: self).patchArray(fromData: data)
  }
  
}


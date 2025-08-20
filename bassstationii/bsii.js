

  var name: String {
  set {
    nameBytes = nameSetFilter(newValue).bytes(forCount: 16)
  }
  get {
    return Self.name(forData: Data(nameBytes))
  }
}

const sysexHeader = [0xf0, 0x00, 0x20, 0x29, 0x00, 0x33, 0x00]
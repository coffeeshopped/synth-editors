
protocol BassStationIIPatch : ByteBackedSysexPatch {
  var nameBytes: [UInt8] { get set }
}

extension BassStationIIPatch {
  
  var name: String {
    set {
      nameBytes = nameSetFilter(newValue).bytes(forCount: 16)
    }
    get {
      return Self.name(forData: Data(nameBytes))
    }
  }
  
  static func sysexHeader() -> [UInt8] {
    return [0xf0, 0x00, 0x20, 0x29, 0x00, 0x33, 0x00]
  }

}

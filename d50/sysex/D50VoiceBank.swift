
class D50VoiceBank : TypicalTypedRolandAddressableBank<D50VoicePatch> {
  
  override class func offsetAddress(location: Int) -> RolandAddress {
    return RolandAddress(0x000340) * location
  }

  override class func startAddress(_ path: SynthPath?) -> RolandAddress {
    return 0x020000
  }

  override class var fileDataCount: Int { return 36048 } // this includes reverb, hm.
  override class var patchCount: Int { return 64 }
  // TODO: need actual init file
  override class var initFileName: String { return "d50-voice-bank-init" }

  // 33152: Patch Base format, just the patches
  // 36048: native, compact, 1 msg format. same as dump
  // 29958: handshake format
  override class func isValid(fileSize: Int) -> Bool {
    return [fileDataCount, 33152, 29958].contains(fileSize)
  }
  
  private let reverbData: Data
  
  required init(data: Data) {
    let rData = RolandData(data: data, addressableType: Patch.self)
    let startAddress = type(of: self).startAddress()
    let selfType = type(of: self)
    let p: [Patch] = (0..<selfType.patchCount).map {
      let address = startAddress + selfType.offsetAddress(location: $0)
      let d = selfType.sysexMsg(deviceId: 0, rolandData: rData, address: address, size: Patch.size)
      return Patch.init(data: d)
    }
    
    // save the reverb data
    let sysex = SysexData(data: data)
    let cutoffAddress: RolandAddress = 0x036000
    reverbData = sysex.compactMap {
      guard selfType.address(forSysex: $0) >= cutoffAddress else { return nil }
      return $0
    }.reduce(Data(), +)

    super.init(patches: p)
  }
  
  required init(patches p: [Patch]) {
    self.reverbData = Self.init().reverbData
    super.init(patches: p)
  }
  
  private static func sysexMsg(deviceId: Int, rolandData: RolandData, address: RolandAddress, size: RolandAddress) -> Data {
    let bytes = [UInt8](rolandData.data(forAddress: address, size: size))
    var data = D50VoicePatch.dataSetHeader(deviceId: deviceId)
    data.append(Data(address.sysexBytes(count: addressCount)))
    data.append(contentsOf: bytes)
    data.append(checksum(address: address, dataBytes: bytes))
    data.append(0xf7)
    return data
  }

  func sysexData(deviceId: Int, address: RolandAddress) -> [Data] {
    let defaultData = defaultSysexData(deviceId: deviceId, address: address).reduce(Data(), +)
    let rData = RolandData(data: defaultData, addressableType: type(of: self))
    var address = rData.startAddress
    var data = [Data]()
    while address < rData.endAddress {
      let size: RolandAddress = min((rData.endAddress - address), 0x200)
      data.append(type(of: self).sysexMsg(deviceId: deviceId, rolandData: rData, address: address, size: size))
      address = address + size
    }
    data.append(reverbData)
    return data
  }

  // need deviceId of ZERO, not 16 (as is usual for Roland)...
  override open func fileData() -> Data {
    return sysexData(deviceId: 0, address: type(of: self).fileDataAddress).reduce(Data(), +)
  }


}

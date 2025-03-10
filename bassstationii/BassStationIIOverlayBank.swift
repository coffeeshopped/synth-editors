
class BassStationIIOverlayBank : TypicalTypedSysexPatchBank<BassStationIIOverlayPatch> {
  
  override class var patchCount: Int { return 8 }
  // TODO: need actual init file
  override class var initFileName: String { return "bassstationii-overlay-bank-init" }
  // key messages + header & footer
  override class var fileDataCount: Int { return 26400 + 19 }

  required public init(data: Data) {
    // can be from fetch, or file. they are different.
    var overlayData = Data()
    var bankLocation: UInt8 = 0
    var overlays = [UInt8:BassStationIIOverlayPatch]()
    let overlayAddBlock: (Data) -> Void = {
      let overlay = BassStationIIOverlayPatch(data: $0)
      overlay.name = "Overlays \(bankLocation + 1)"
      overlays[bankLocation] = overlay
    }
    if data.count == 26400 {
      // from fetch
      // each 50 msgs should be 1 overlay set
      var msgCount = 0
      SysexData(data: data).forEach { d in
        overlayData.append(d)
        msgCount += 1
        if msgCount == 50 {
          overlayAddBlock(overlayData)
          bankLocation += 1
          msgCount = 0
          overlayData.removeAll(keepingCapacity: true)
        }
      }
    }
    else {
      // from file
      var inBank = false
      SysexData(data: data).forEach { d in
        if d.count == 10 && d[7] == 0x50 {
          inBank = true
          bankLocation = d[8] == 0 ? 0 : d[8] - 1 // index starts at 1
          overlayData.removeAll(keepingCapacity: true)
        }
        else if d.count == 9 && d[7] == 0x4a {
          inBank = false
          overlayAddBlock(overlayData)
        }
        else if inBank {
          overlayData.append(d)
        }
      }
    }
    let patches = (0..<Self.patchCount).map {
      overlays[UInt8($0)] ?? BassStationIIOverlayPatch()
    }
    super.init(patches: patches)
  }
  
  required init(patches p: [Patch]) {
    super.init(patches: p)
  }
  
  func sysexData() -> [Data] {
    return [Data](patches.enumerated().map { $0.element.sysexData(bank: $0.offset + 1) }.joined())
  }
  
  override class func isValid(fileSize: Int) -> Bool {
    return true
//    return [fileDataCount, 26400].contains(fileSize)
  }

  override func fileData() -> Data {
    return Data(sysexData().joined())
  }

}

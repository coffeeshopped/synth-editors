
class BassStationIIOverlayPatch : MultiSysexPatch, BankablePatch {
  
  static var bankType: SysexPatchBank.Type { return BassStationIIOverlayBank.self }
  
  const initFileName = "bassstationii-overlay-init"
  const maxNameCount = 32

  const keyCount = 25
  
  static func isValid(fileSize: Int) -> Bool {
    return isValid(x: fileSize, otherKeys: keyCount)
  }
  
  static func isCompleteFetch(sysex: Data) -> Bool {
    return sysex.count == 3300
  }
  
  static func isValid(x: Int, otherKeys: Int) -> Bool {
    if otherKeys == 0 && x == 0 {
      return true
    }
    else {
      if otherKeys * 10 > x { return false }
      if otherKeys * 132 < x { return false }
      
      let lessKeys = otherKeys - 1
      for size in BassStationIIOverlayKeyPatch.validFileSizes {
        if isValid(x: x - size, otherKeys: lessKeys) {
          return true
        }
      }
      return false
    }
  }

  static var subpatchTypes: [SynthPath : SysexPatch.Type] = (0..<keyCount).map {
    ($0, BassStationIIOverlayKeyPatch.self)
  }.dictionary {
    ["key/$0" : $1]
  }
    
  required init(data: Data) {
    var keyData = [Data](repeating: Data(), count: Self.keyCount)
    SysexData(data: data).forEach { d in
      guard d.count > 9 else { return }
      let location = BassStationIIOverlayKeyPatch.location(forData: d)
      guard location < Self.keyCount else { return }
      keyData[location].append(d)
    }
    (0..<Self.keyCount).forEach {
      subpatches["key/$0"] = BassStationIIOverlayKeyPatch(data: keyData[$0])
    }
  }
    
  func copy() -> Self {
    let patch = Self.init(data: fileData())
    patch.name = name
    return patch
  }

  func sysexData() -> [Data] {
    let d: [[Data]] = subpatches.compactMap {
      let key = $0.key.i(1) ?? 0
      return ($0.value as? BassStationIIOverlayKeyPatch)?.sysexData(location: key)
    }
    return d.flatMap { $0 }
  }
  
  // bank starts at 1
  func sysexData(bank: Int) -> [Data] {
    var data = [Data(BassStationIIVoicePatch.sysexHeader() + [0x50, UInt8(bank), 0xf7])]
    data.append(contentsOf: sysexData())
    data.append(Data(BassStationIIVoicePatch.sysexHeader() + [0x4a, 0xf7]))
    return data
  }
  
  func fileData() -> Data {
    return Data(sysexData().joined())
  }
    
}


const pitchIso = Miso.switcher([
  .range([0, 128], Miso.str("Key")),
  .range([129, 255], Miso.a(-128) >>> Miso.noteName(zeroNote: "C-2"))
])

const keyParms = [
  ["mute", { b: 0, ext: { BassStationIIVoicePatch.AFX:0 } }],
  BassStationIIVoicePatch.params.forEach { (key, param) in
    guard let afx = param.extra[BassStationIIVoicePatch.AFX] else { return }
    switch param.byte {
    case 94:
      ["pitch", { b: 0, ext: { BassStationIIVoicePatch.AFX:75 }, rng: [128, 255], dispOff: -128, iso: pitchIso }],
    case 95:
      ["level", { b: 0, ext: { BassStationIIVoicePatch.AFX:76 }, rng: [128, 255], dispOff: -128 }],
    default:
      p[key] = param
    }
  }
]


const keyPatchTruss = {
  single: 'bsii.overlay.key',
  initFile: "bassstationii-overlay-key-init",
  bodyDataCount: 100, // 84 body + 16 name
  parms: keyParms,
  // 10 is cleared key w/out name
  // 20 is for a "cleared" key (name + key data)
  validSizes: [106, 20, 10],
  includeFileDataCount: true,
}

class BassStationIIOverlayKeyPatch : BassStationIIPatch {
  
  static func location(forData data: Data) -> Int { return Int(data[8]) }
  
  const fileDataCount = 106 + 26
      
  required init() {
    bytes = [UInt8](repeating: 0, count: 84)
    nameBytes = "Untitled".bytes(forCount: 16)
  }
  
  required init(data: Data) {
    let d = SysexData(data: data)
    var byteData: Data?
    var nameData: Data?
    for msg in d {
      switch msg.count {
      case 106:
        byteData = msg
      case 26:
        nameData = msg
      default:
        break
      }
    }

    let muted: Bool
    if let b = byteData {
      bytes = [UInt8](b[9..<105]).sevenToEightStraight()
      muted = false
    }
    else {
      bytes = Self.fromVoicePatch(BassStationIIVoicePatch()).bytes
      // set muted
      muted = true
    }
    if let n = nameData {
      nameBytes = [UInt8](n[9..<25])
    }
    else {
      nameBytes = "Untitled".bytes(forCount: 16)
    }
    
    // do it this way bc "muted" fetch will actually look like an overlay with a non-zero first byte
    if muted {
      self["mute"] = 1
    }
  }
  
  func unpack(param: Param) -> Int? {
    guard let afx = param.extra[BassStationIIVoicePatch.AFX] else { return nil }
    return Self.defaultUnpack(byte: afx, bits: param.bits, forBytes: bytes)
  }
  
  func pack(value: Int, forParam param: Param) {
    guard let afx = param.extra[BassStationIIVoicePatch.AFX] else { return }
    bytes[afx] = Self.defaultPackedByte(value: value, forParam: param, byte: bytes[afx])
  }

  static func fromVoicePatch(_ voice: BassStationIIVoicePatch) -> BassStationIIOverlayKeyPatch {
    let patch = BassStationIIOverlayKeyPatch()
    patch.name = voice.name
    BassStationIIOverlayKeyPatch.params.forEach { (path, param) in
      switch path {
      case "pitch":
        patch["pitch"] = voice["osc/slop"]
      case "level":
        patch["level"] = voice["glide/split"]
      default:
        patch[path] = voice[path]
      }
    }
    return patch
  }

  
  var muted: Bool { self["mute"] != 0 }
  
  static func sysexHeader(_ cmdByte: UInt8, location: Int) -> [UInt8] {
    return Self.sysexHeader() + [cmdByte, UInt8(location)]
  }
  
  func paramSysexData(location: Int) -> Data {
    if muted {
      return Data(Self.sysexHeader(0x4c, location: location) + [0xf7])
    }
    else {
      return Data(Self.sysexHeader(0x4e, location: location) + bytes.eightToSevenStraight() + [0xf7])
    }
  }

  func nameSysexData(location: Int) -> Data {
    if muted {
      return Data(Self.sysexHeader(0x52, location: location) + [0xf7])
    }
    else {
      return Self.nameSysexData(location: location, nameBytes: nameBytes)
    }
  }
  
  static func nameSysexData(location: Int, nameBytes: [UInt8]) -> Data {
    return Data(Self.sysexHeader(0x53, location: location) + nameBytes + [0xf7])
  }

  func sysexData(location: Int) -> [Data] {
    return [paramSysexData(location: location), nameSysexData(location: location)]
  }
  
  func fileData() -> Data {
    return Data(sysexData(location: 0).joined())
  }

  func randomize() {
    randomizeAllParams()
    self["mute"] = 0
    self["level"] = 128 + ([90, 127]).random()!
  }
  
}


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

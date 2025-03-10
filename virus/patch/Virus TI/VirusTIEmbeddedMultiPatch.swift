
class VirusTISeriesEmbeddedMultiPatch<PartPatch:VirusTIVoicePatch, MultiPatch:VirusTIMultiPatch> : MultiSysexPatch, PerfPatch {
  
  class var initFileName: String { return "?"}
  class var partCount: Int { return 16 }
  
  class func location(forData data: Data) -> Int {
    switch data.count {
    case 267:
      return Int(data[8])
    case 524:
      return Int(data[7]) - 0x20
    default:
      return 0
    }
  }

  var name: String {
    get { return subpatches[[.common]]?.name ?? "?" }
    set { subpatches[[.common]]?.name = newValue }
  }
  
  static var maxNameCount: Int {
    return MultiPatch.maxNameCount
  }
  
  var subpatches: [SynthPath : SysexPatch]
    
  class var subpatchTypes: [SynthPath : SysexPatch.Type] {
    var types: [SynthPath : SysexPatch.Type] = [[.common] : MultiPatch.self]
    (0..<partCount).forEach { types[[.part, .i($0)]] = PartPatch.self }
    return types
  }
  
  required init(data: Data) {
    subpatches = [SynthPath:SysexPatch]()
    SysexData(data: data).forEach { d in
      if MultiPatch.isValid(sysex: d) {
        subpatches[[.common]] = MultiPatch.init(data: d)
      }
      else if PartPatch.isValid(sysex: d) {
        let part = Int(d[8])
        subpatches[[.part, .i(part)]] = PartPatch.init(data: d)
      }
    }
    for (key, type) in Self.subpatchTypes {
      guard subpatches[key] == nil else { continue }
      subpatches[key] = type.init()
    }
  }
  
  required init(subpatches: [SynthPath:SysexPatch]) {
    var copies = [SynthPath:SysexPatch]()
    subpatches.forEach { copies[$0.key] = $0.value.copy() }
    self.subpatches = copies
  }

  
  func copy() -> Self {
    return Self.init(subpatches: subpatches)
  }
  
  // location: -1 = temp, 0...63 = memory
  func sysexData(deviceId: UInt8, location: Int) -> [Data] {
    let multiBank: UInt8 = location < 0 ? 0 : 50 // undocumented. bank 50 to store.
    let multiPart: UInt8 = location < 0 ? 0 : UInt8(location)
    let patchBank: UInt8 = location < 0 ? 0 : UInt8(location) + 0x20
    var data = [(subpatches[[.common]] as? MultiPatch)?.sysexData(deviceId: deviceId, bank: multiBank, part: multiPart) ?? Data()]
    (0..<16).forEach {
      guard let p = subpatches[[.part, .i($0)]] as? PartPatch else { return }
      data.append(p.sysexData(deviceId: deviceId, bank: patchBank, part: UInt8($0)))
    }
    return data
  }

  func fileData() -> Data {
    return Data(sysexData(deviceId: 16, location: -1).joined())
  }
  
}

class VirusTIEmbeddedMultiPatch : VirusTISeriesEmbeddedMultiPatch<VirusTIVoicePatch, VirusTIMultiPatch>, BankablePatch {
  
  static let bankType: SysexPatchBank.Type = VirusTIEmbeddedMultiBank.self
  
  override class var initFileName: String { return "virusti-embedded-multi-init"}
  override class var partCount: Int { return 16 }
}

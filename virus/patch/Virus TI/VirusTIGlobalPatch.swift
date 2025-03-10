
class VirusTIGlobalPatch : JSONBackedSysexPatch, GlobalPatch {
  
  var name = ""
  
  static let initFileName = "virusti-global-init"
  
  var values: [Int:Int]
  let encoder = JSONEncoder()
  
  required init(data: Data) {
    values = Self.decodeValues(forData: data)
  }
  
  static let params: SynthPathParam = {
    var p = SynthPathParam()
    p[[.channel]] = RangeParam(byte: 0, maxVal: 15, displayOffset: 1)
    p[[.deviceId]] = MisoParam.make(byte: 1, range: 0...16, iso: deviceIdIso)
    return p
  }()
  
  static let deviceIdIso = Miso.switcher([
    .int(16, "Omni")
  ], default: Miso.a(1) >>> Miso.str())
  
}

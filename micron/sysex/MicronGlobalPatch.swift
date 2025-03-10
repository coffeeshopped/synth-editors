
class MicronGlobalPatch : JSONBackedSysexPatch, GlobalPatch {
  
  var name = ""
  
  static let initFileName = "micron-global-init"
  
  var values: [Int:Int]
  let encoder = JSONEncoder()
  
  required init(data: Data) {
    values = type(of: self).decodeValues(forData: data)
  }
  
  static let params: SynthPathParam = {
    var p = SynthPathParam()
    
    p[[.channel]] = RangeParam(byte: 0, maxVal: 15, displayOffset: 1)
    p[[.bank]] = RangeParam(byte: 1, maxVal: 7)
    p[[.location]] = RangeParam(byte: 2)
    // where we fetch from
    p[[.dump, .bank]] = RangeParam(byte: 3, maxVal: 7)
    p[[.dump, .location]] = RangeParam(byte: 4)

    return p
  }()
  
}

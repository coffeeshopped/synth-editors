
class WavestationSRGlobalPatch : JSONBackedSysexPatch, GlobalPatch {
  
  var name = ""
  
  static let initFileName = "wavestationsr-global-init"
  
  var values: [Int:Int]
  let encoder = JSONEncoder()
  
  required init(data: Data) {
    values = type(of: self).decodeValues(forData: data)
  }
  
  static let params: SynthPathParam = {
    var p = SynthPathParam()
    
    p[[.channel]] = RangeParam(byte: 0, maxVal: 15, displayOffset: 1)
    p[[.bank]] = RangeParam(byte: 1, maxVal: 10)
    p[[.location]] = RangeParam(byte: 2, maxVal: 34)
    // where we fetch from
    p[[.dump, .bank]] = RangeParam(byte: 3, maxVal: 10, displayOffset: 1)
    p[[.dump, .location]] = RangeParam(byte: 4, maxVal: 34)

    return p
  }()
  
}

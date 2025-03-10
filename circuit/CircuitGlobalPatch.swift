
class CircuitGlobalPatch : JSONBackedSysexPatch, GlobalPatch {

  var name = ""
  
  static let initFileName = "circuit-global-init"

  var values: [Int:Int]
  let encoder = JSONEncoder()

  required init(data: Data) {
    values = type(of: self).decodeValues(forData: data)
  }
  
  static let params: SynthPathParam = {
    var p = SynthPathParam()
    p[[.channel, .i(0)]] = RangeParam(byte: 0, maxVal: 14, displayOffset: 1)
    p[[.channel, .i(1)]] = RangeParam(byte: 1, maxVal: 14, displayOffset: 1)
    return p
  }()
  
}


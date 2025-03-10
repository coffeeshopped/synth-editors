
class EvolverKeyGlobalPatch : EvolverGlobalPatch {

  override class var initFileName: String { return "evolver-global-key-init" }
  override class var fileDataCount: Int { return 62 }
  override class var actualDataByteCount: Int { return 28 }

  private static let _params: SynthPathParam = {
    var p = EvolverGlobalPatch.params
    
    // different options
    p[[.poly, .chain]] = OptionsParam(byte: 9, options: polyChainOptions)

    p[[.pgmChange]] = RangeParam(byte: 18, maxVal: 1)
    p[[.pressure]] = RangeParam(byte: 19, maxVal: 1)
    p[[.ctrl]] = RangeParam(byte: 20, maxVal: 1)
    p[[.sysex]] = RangeParam(byte: 21, maxVal: 1)
    p[[.foot, .i(0), .dest]] = OptionsParam(byte: 22, options: footCtrlOptions)
    p[[.foot, .i(1), .dest]] = OptionsParam(byte: 23, options: footCtrlOptions)
    p[[.velo, .curve]] = RangeParam(byte: 24, maxVal: 3)
    p[[.pressure, .curve]] = RangeParam(byte: 25, maxVal: 3)
    p[[.local]] = RangeParam(byte: 26, maxVal: 1)
    p[[.redamper, .polarity]] = OptionsParam(byte: 27, options: ["Open", "Closed"])
    
    return p
  }()
  
  override class var params: SynthPathParam { return _params }
  
  static let footCtrlOptions = OptionsParam.makeOptions(["Foot Ctrl", "Breath", "Expression", "Volume", "LpFilter", "LpF Half"])
  
  static let polyChainOptions = OptionsParam.makeOptions((0..<20).map {
    return $0 == 0 ? "None" : "\($0+1) voices"
  })
}

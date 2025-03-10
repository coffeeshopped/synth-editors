
public protocol TG33Param : Param {
  var parm2: Int { get }
  var length: Int { get }
}

public struct TG33RangeParam : ParamWithRange, TG33Param {
  public let range: ClosedRange<Int>
  public let displayOffset: Int
  public let byte: Int
  public let extra: [Int:Int]
  public let bits: ClosedRange<Int>?
  public let parm: Int
  public let parm2: Int
  public let length: Int
  public let formatter: ParamValueFormatter?
  public let parser: ParamValueParser?
  public let packIso: PackIso? = nil

  public init(parm p: Int = 0, parm2 p2: Int = 0, byte by: Int = 0, length: Int = 1, bits bts: ClosedRange<Int>? = nil, extra x: [Int:Int] = [:], range r: ClosedRange<Int> = 0...127, displayOffset off: Int = 0, mapper: ParamValueMapper? = nil) {
    parm = p
    parm2 = p2
    byte = by
    bits = bts
    extra = x
    range = r
    displayOffset = off
    self.length = length
    self.formatter = mapper?.format
    self.parser = mapper?.parse
  }
  
  public init(parm p: Int = 0, parm2 p2: Int = 0, byte by: Int = 0, length: Int = 1, bits bts: ClosedRange<Int>? = nil, extra x: [Int:Int] = [:], maxVal: Int, displayOffset off: Int = 0) {
    self.init(parm: p, parm2: p2, byte: by, length: length, bits: bts, extra: x, range: 0...maxVal, displayOffset: off)
  }
  
  public init(parm p: Int = 0, parm2 p2: Int = 0, byte by: Int = 0, length: Int = 1, bit bt: Int, extra x: [Int:Int] = [:]) {
    parm = p
    parm2 = p2
    byte = by
    bits = bt...bt
    extra = x
    range = 0...1
    displayOffset = 0
    self.length = length
    self.formatter = nil
    self.parser = nil
  }
  
  public func randomize() -> Int {
    return range.lowerBound + Int(arc4random_uniform(UInt32(1 + range.upperBound - range.lowerBound)))
  }
}

public struct TG33OptionsParam : ParamWithOptions, ParamWithRange, TG33Param {
  public let options: [Int:String]
  public let byte: Int
  public let extra: [Int:Int]
  public let bits: ClosedRange<Int>?
  public let parm: Int
  public let parm2: Int
  public var range: ClosedRange<Int> {
    return (options.keys.min() ?? 0)...(options.keys.max() ?? 0)
  }
  public let displayOffset = 0
  public let length: Int
  public let formatter: ParamValueFormatter? = nil
  public let parser: ParamValueParser? = nil
  public let packIso: PackIso? = nil

  public init(parm p: Int = 0, parm2 p2: Int = 0, byte by: Int = 0, length: Int = 1, bits bts: ClosedRange<Int>? = nil, extra x: [Int:Int] = [:], options opts: [Int:String]) {
    parm = p
    parm2 = p2
    options = opts
    byte = by
    bits = bts
    extra = x
    self.length = length
  }
  
  public init(parm p: Int = 0, parm2 p2: Int = 0, byte by: Int = 0, length: Int = 1, bit bt: Int, extra x: [Int:Int] = [:], options opts: [Int:String]) {
    parm = p
    parm2 = p2
    options = opts
    byte = by
    bits = bt...bt
    extra = x
    self.length = length
  }
  
  public func randomize() -> Int {
    return Array(options.keys)[Int(arc4random_uniform(UInt32(options.count)))]
  }
  
}

public extension MisoParam {
  
//  public static func make(parm: Int = 0, parm2: Int = 0, byte: Int = 0, bits: ClosedRange<Int>? = nil, extra: [Int:Int] = [:], options: [String], startIndex: Int = 0) -> TG33RangeParam {
//    let iso = Miso.options(options, startIndex: startIndex)
//    let mapper = iso.pvm()
//    let r = TG33RangeParam(parm: parm, parm2: parm2, byte: byte, bits: bits, extra: extra, range: startIndex...(startIndex + options.count - 1), formatter: mapper.format, parser: mapper.parse)
//    return r
//  }
  
  static func make(parm: Int = 0, parm2: Int = 0, byte: Int = 0, bits: ClosedRange<Int>? = nil, extra: [Int:Int] = [:], range: ClosedRange<Int> = 0...127, iso: Iso<Float, String>) -> TG33RangeParam {
    let r = TG33RangeParam(parm: parm, parm2: parm2, byte: byte, bits: bits, extra: extra, range: range, mapper: iso.pvm())
    return r
  }

//  public static func make(parm: Int = 0, byte: Int = 0, bits: ClosedRange<Int>? = nil, extra: [Int:Int] = [:], maxVal: Int, iso: Iso<Float, String>) -> RangeParam {
//    let r = RangeParam(parm: parm, byte: byte, bits: bits, extra: extra, maxVal: maxVal, mapper: iso.pvm())
//    return r
//  }

}

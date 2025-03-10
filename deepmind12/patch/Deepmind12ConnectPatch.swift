
open class Deepmind12ConnectPatch : JSONBackedSysexPatch {
  
  open var name = ""
  
  public static let initFileName = "deepmind12-connect-init"
  
  open var values: [Int:Int]
  public let encoder = JSONEncoder()
  
  public required init(data: Data) {
    values = Self.decodeValues(forData: data)
  }
  
  public static let params: SynthPathParam = {
    var p = SynthPathParam()
    p[[.mode]] = OptionsParam(byte: 0, options: ["MIDI", "USB", "Wifi"])
    return p
  }()
  
}


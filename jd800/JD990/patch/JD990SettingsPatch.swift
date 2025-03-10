
class JD990SettingsPatch : JSONBackedSysexPatch {
  
  static let initFileName = "jd990-settings-init"
  
  var name = ""
  var values: [Int:Int]
  let encoder = JSONEncoder()
  
  required init(data: Data) {
    values = type(of: self).decodeValues(forData: data)
    if (values[0] ?? 0) < 16 {
      // default deviceId to 16 (displayed as 17)
      values[0] = 16
    }
  }
  
  static let params: SynthPathParam = {
    var p = SynthPathParam()
    
    p[[.deviceId]] = RangeParam(byte: 0, range: 0x10...0x1f, displayOffset: 1)
    p[[.pcm]] = OptionsParam(byte: 1, options: SOJD80Card.cardNameOptions)
    p[[.extra]] = OptionsParam(byte: 2, options: SRJVBoard.boardNameOptions)
    
    return p
  }()
  
}


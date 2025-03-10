
class EvolverKeyVoicePatch : EvolverVoicePatch {
  
  private static let _params: SynthPathParam = {
    var p = EvolverVoicePatch.params

    // "Keybd" instead of "MIDI" in a couple of options
    p[[.trigger]] = OptionsParam(byte: 54, options: ["All", "Seq Only", "Keybd Only", "Keybd Reset", "Combo", "Combo Reset", "Ext In Env", "Ext In Env Reset", "Ext In Seq", "Ext In Seq Reset", "Key Seq Once", "Key Seq Reset", "Ext Trig", "Key Seq"])
    // now contains poly/mono etc setting as well 
    p[[.key, .mode]] = RangeParam(byte: 71, maxVal: 23)

    return p
  }()
  
  override class var params: SynthPathParam { return _params }
}

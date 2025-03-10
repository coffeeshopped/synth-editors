
struct TetraComboPatch : MophoVoiceTypePatch {
    
  static var relatedBankType: SysexPatchBank.Type? = FnSingleBank<TetraComboBank>.self

  static let idByte: UInt8 = 0x26
  static let initFileName = "tetra-combo-init"
  static let fileDataCount = 1176
  
  static func bytes(data: Data) -> [UInt8] {
    let range = data.count == fileDataCount ? 4..<1175 : 5..<1176
    return data.unpack87(count: 1024, inRange: range)
  }

  static func isValid(fileSize: Int) -> Bool {
    return [fileDataCount, 1177].contains(fileSize)
  }
  
  static func sysexData(_ bytes: [UInt8], location: Int) -> MidiMessage {
    return sysexData(bytes, headerBytes: [0x22, UInt8(location)])
  }

  static func fileData(_ bytes: [UInt8]) -> [UInt8] {
    return sysexData(bytes, headerBytes: [0x37]).bytes()
  }

  static func randomize(patch: ByteBackedSysexPatch) {
    patch.randomizeAllParams()
    (0..<4).forEach { layer in
      tamedRandomVoice().prefixed([.layer, .i(layer)]).forEach {
        patch[$0.key] = $0.value
      }
    }
  }

  static let paramOptions: [ParamOptions] =
    offset(b: 0, p: 512) {
      prefix([.layer], count: 4, bx: 256, px: 256) { _ in TetraVoicePatch.layerParamOptions }
      <<< prefix([.knob], count: 4, bx: 1) { _ in
        [
          o([], 111, p: 105, opts: TetraVoicePatch.knobAssignOptions),
        ]
      }
    }

  
  static let params: SynthPathParam = paramsFromOpts(paramOptions)
          
  static let keyAssignOptions = MophoVoicePatch.keyAssignOptions
  
  static let lfoFreqOptions = MophoVoicePatch.lfoFreqOptions
  
  static let lfoWaveOptions = MophoVoicePatch.lfoWaveOptions
  
  static let pushItModeOptions = OptionsParam.makeOptions(["Normal","Toggle"])
  
  static let clockDivOptions = MophoVoicePatch.clockDivOptions
  
  static let arpModeOptions = MophoKeyVoicePatch.arpModeOptions
  
  static let seqTrigOptions: [Int:String] = MophoVoicePatch.seqTrigOptions --- [5]
  
  static let modDestOptions: [Int:String] = MophoVoicePatch.modDestOptions <<< [
    44 : "Feedbk Vol",
    47 : "Feedbk Gain",
  ]

  static let unisonModeOptions = MophoKeyVoicePatch.unisonModeOptions

  static let modDestSeq24Options: [Int:String] = modDestOptions <<< [48 : "Slew"]
  
  static let modSrcOptions: [Int:String] = MophoVoicePatch.modSrcOptions --- [21, 22]
  
  static let knobAssignOptions = TetraVoicePatch.knobAssignOptions
}


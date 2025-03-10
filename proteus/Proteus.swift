
enum Proteus {
  
  static func sysex(deviceId: UInt8, _ bytes: [UInt8]) -> [UInt8] {
    [0xf0, 0x18, 0x04, deviceId] + bytes + [0xf7]
  }
  
  static func paramSetData(deviceId: UInt8, parm: Int, byte0: UInt8, byte1: UInt8) -> [UInt8] {
    let pl = UInt8(parm.bits(0...6))
    let pm = UInt8(parm.bits(7...13))
    return sysex(deviceId: deviceId, [0x03, pl, pm, byte0, byte1])
  }
  
  static func paramData(parm: Int, value: Int) -> [UInt8] {
    let vl = UInt8(value.bits(0...6))
    let vm = UInt8(value.bits(7...13))
    return paramSetData(deviceId: 0, parm: parm, byte0: vl, byte1: vm)
  }

  
  static func pack(_ bytes: inout [UInt8], parm: Int, value: Int) {
    let off = parm * 2
    guard off + 1 < bytes.count else { return }
    bytes[off] = UInt8(value.bits(0...6))
    bytes[off + 1] = UInt8(value.bits(7...13))
  }
  
  static func unpack(_ bytes: [UInt8], parm: Int) -> Int? {
    let off = parm * 2
    guard off + 1 < bytes.count else { return nil }
    let v = 0.set(bits: 0...6, value: bytes[off].bits(0...6)).set(bits: 7...13, value: bytes[off + 1].bits(0...6))
    return v.signedBits(0...13)
  }
  
  static let deviceId: EditorValueTransform = .constant(0)

  static func createEditorTruss(_ name: String, voice: SinglePatchTruss, voiceBank: SingleBankTruss, presets: [String]) -> BasicEditorTruss {
    
    var t = BasicEditorTruss(name, truss: [
      ([.global], Global.patchTruss),
      ([.tune], Tuning.patchTruss),
      ([.preset], Proteus1.Map.patchTruss),
      ([.patch], voice),
      ([.bank], voiceBank),
    ])
    
    t.fetchTransforms = [
      [.global] : fetchTransform(forParams: 256...431),
      [.tune] : .truss(deviceId, { sysex(deviceId: UInt8($0), [0x04]) }),
      [.preset] : .truss(deviceId, { sysex(deviceId: UInt8($0), [0x06]) }),
      [.patch] : fetchTransform(forParams: 0...127),
      [.bank] : .truss(deviceId, { sysex(deviceId: UInt8($0), [0x00, 0x7f, 0x7f]) }),
    ]
    
    t.midiOuts = [
      ([.global], Global.patchTransform),
      ([.tune], Tuning.patchTransform),
      ([.preset], Proteus1.Map.patchTransform),
      ([.patch], Proteus1.Voice.patchTransform(params: voice.params)),
      ([.bank], .single(deviceId, .bank({ editorVal, bodyData, location in
        [(.sysex(Proteus1.Voice.sysexData(bodyData, deviceId: editorVal, location: location + 64)), 10)]
      })))
    ]
    
//    override func midiOuts() -> [Observable<[Data]?>]  {
//      var midiOuts = [Observable<[Data]?>]()
//      midiOuts.append(pgmChangeSubject.asObservable())
//      return midiOuts
//    }
//    private let pgmChangeSubject = PublishSubject<[Data]?>()
//    override func onSave(toBankPath bankPath: SynthPath, index: Int, fromPatchPath patchPath: SynthPath) {
//      // send a program change to the saved slot
//      // TODO: index should actually be based on program map...
//      guard index + 64 < 128 else { return }
//      pgmChangeSubject.onNext([Data([0xc0, UInt8(index + 64)])])
//    }
    
    t.extraParamOuts = [
      ([.patch], .bankOut([.bank], { change, bank in
        guard let bank = bank else { return SynthPathParam() }
        var presets = presets // there should be 192 (at least in the /2)
        bank.patchCount.forEach {
          presets[64 + $0] = bank[$0].name // replace the middle 64 with user
        }
        let numberedPatches = presets.enumerated().map { "\($0.offset): \($0.element)" }
        return [[.patch, .name] : .p([], .options(OptionsParam.makeOptions(numberedPatches) <<< [-1 : "Off"]))]
      })),
    ]

    t.slotTransforms = [
      [.bank] : .user({ "\($0 + 64)" })
    ]
    
    return t
  }
  
  static func fetchTransform(forParams parms: ClosedRange<Int>) -> FetchTransform {
    .custom([]) { values, path in
      parms.flatMap {
        [
          .requestMsg(.sysex(paramFetchData(deviceId: 0, $0)), .eq(10)),
          .wait(0.01),
        ]
      }
    }
  }
  
  static func paramFetchData(deviceId: UInt8, _ parm: Int) -> [UInt8] {
    sysex(deviceId: deviceId, [0x02, UInt8(parm.bits(0...6)), UInt8(parm.bits(7...13))])
  }
  
  static func createModuleTruss(_ editorTruss: EditorTruss, subid: String, chorusMax: Int) -> BasicModuleTruss {
    
    return BasicModuleTruss(editorTruss, manu: Manufacturer.emu, model: editorTruss.displayId, subid: subid, sections: [
      .first([
        .global(Global.Controller.ctrlr()),
        .voice("Voice", Proteus.Voice.Controller.ctrlr(chorusMax: chorusMax)),
        .perf(title: "Tuning", path: [.tune], Proteus.Tuning.Controller.ctrlr()),
        .custom("Preset Map", [.preset], Proteus1.Map.Controller.ctrlr()),
      ]),
      .banks([
        .bank("Bank", [.bank]),
      ])
    ], dirMap: [
      [.tune] : "Tuning*",
      [.bank] : "Banks*",
    ], colorGuide: ColorGuide([
      "#FDC63F",
      "#4080ff",
      "#a3e51e",
      "#ff4327",
    ]), indexPath: .init(item: 1, section: 0))
  }
  

}


const editor = {
  rolandModelId: [0x16],
  addressCount: 3,
  name: "D-110",
  map: ([
    ['deviceId'],
    ['global'], System.patchWerk.start, System.patchWerk),
    ['perf'], Patch.patchWerk.start, Patch.patchWerk),
    ['bank/tone'], toneBank.start, DXX.Tone.bankWerk),
    ['bank/perf'], Patch.bankWerk.start, Patch.bankWerk),
  ]).concat((8).map(i => 
    [['tone', i], 0x040000 + 0x0176 * i, DXX.Tone.patchWerk]
  )),
  extraParamOuts: [
    ['perf', ['bankNames', "bank/tone", 'tone/name']],
  ],
  slotTransforms: [
    ['bank/tone', ['user', i => `i${i+ 1}.zPad(2))`]],
    ['bank/perf', ['user', i => `I-${1 + i / 8}${1 + i % 8}`]],
  ],
  midiChannels: (7).map(i =>
    [['tone', i], ['patch', 'global', ['part', i, 'channel']]]
  ),
}



public enum D110 {
  
  public static let moduleTruss = BasicModuleTruss(editorTruss, manu: Manufacturer.roland, model: editorTruss.displayId, subid: "d110", sections: [
    .first([
      .deviceId("Exclu Unit #"),
      .global(Controller.systemCtrlr, title: "System"),
      .perf(title: "Patch", Patch.Controller.ctrlr()),
    ]),
    .basic("Tones", [
    ] + 8.map {
      .voice("Tone \($0 + 1)", path: [.tone, .i($0)], DXX.Tone.Controller.ctrlr())
    }),
    .banks([
      .bank("Tone Bank", [.bank, .tone]),
      .bank("Patch Bank", [.bank, .perf]),
    ]),
  ], dirMap: [
    [.global] : "System*",
    [.tone] : "Patch",
    [.perf] : "PatchPatches*",
    [.bank, .tone] : "Tone Bank",
    [.bank, .perf] : "Patch Bank",
  ], colorGuide: ColorGuide([
    "#3975d7",
    "#e49031",
    "#3190e4",
  ]), indexPath: IndexPath(item: 0, section: 1))
  
    
  static let editorTruss: BasicEditorTruss = {

    t.fetchTransforms = werk.defaultFetchTransforms() <<< [
      [.perf] : werk.multiFetchTransform(path: [.perf])!,
    ]

    // remove the default for .bank, .perf
    var midiOuts = werk.midiOuts().filter { $0.path != [.bank, .perf] }
    // then add the custom one.
    midiOuts.append((path: [.bank, .perf], transform: .multi(throttle: 0, werk.deviceId, .bank({ editorVal, bodyData, location in
      let address = Patch.bankWerk.start
      let offset = Patch.bankWerk.iso.address(UInt8(location))
      return RolandEditorTrussWerk.mm(try D110.Patch.memPatchWerk.sysexDataFn(D110.Patch.tempToMem(bodyData), UInt8(editorVal), address + offset))
    }))))
  }()
  
}

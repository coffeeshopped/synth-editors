
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
  
  
  static func mapItems() -> [RolandEditorTrussWerk.MapItem] {
    let tone = DXX.Tone.patchWerk
    let toneBank = DXX.Tone.bankWerk
    return [
      ([.global], System.patchWerk.start, System.patchWerk),
      ([.perf], Patch.patchWerk.start, Patch.patchWerk),
      ([.bank, .tone], toneBank.start, toneBank),
      ([.bank, .perf], Patch.bankWerk.start, Patch.bankWerk),
    ] + 8.map {
      ([.tone, .i($0)], 0x040000 + 0x0176 * $0, tone)
    }
  }
  
  static let editorTruss: BasicEditorTruss = {

    let map = mapItems()
    let werk = DXX.sysexWerk.editorWerk("D-110", map: map)
    var t = BasicEditorTruss(werk.displayId, truss: [([.deviceId], RolandDeviceIdSettingsTruss)] + werk.sysexMap())
    
    t.extraParamOuts = [
      ([.perf], .bankNames([.bank, .tone], [.tone, .name])),
    ]
    
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
    
    t.midiOuts = midiOuts
    
    t.slotTransforms = [
      [.bank, .tone] : .user({ "i\(($0 + 1).zPad(2))" }),
      [.bank, .perf] : .user({ "I-\(1 + $0 / 8)\(1 + $0 % 8)" }),
    ]
    
    t.midiChannels = 7.dict {
      [[.tone, .i($0)] : .patch([.global], [.part, .i($0), .channel])]
    }
    
    return t
  }()
  
}

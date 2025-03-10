
enum JV8X {
  
  static let sysexWerk = RolandSysexTrussWerk(modelId: [0x46], addressCount: 4)
  
  /// MSB first. lower 4 bits of each byte used
  static func multiPack(_ byte: RolandAddress) -> PackIso {
    Roland.msbMultiPackIso(2)(byte)
  }

  static func mapItems(global: AnyRolandSysexTrussWerk, perf: AnyRolandSysexTrussWerk, voice: AnyRolandSysexTrussWerk, rhythm: AnyRolandSysexTrussWerk, voiceBank: AnyRolandSysexTrussWerk, perfBank: AnyRolandSysexTrussWerk, rhythmBank: AnyRolandSysexTrussWerk) -> [RolandEditorTrussWerk.MapItem] {
    return [
      ([.global], global.start, global),
      ([.perf], perf.start, perf),
      ([.patch], voice.start, voice),
      ([.rhythm], rhythm.start, rhythm),
      ([.bank, .patch, .i(0)], voiceBank.start, voiceBank),
      ([.bank, .perf, .i(0)], perfBank.start, perfBank),
      ([.bank, .rhythm, .i(0)], rhythmBank.start, rhythmBank),
    ] + 7.map {
      ([.part, .i($0)], RolandAddress([0x00, UInt8($0), 0x20, 0x00]), voice)
    }
  }
  
  static func editorTruss(_ name: String, global: AnyRolandSysexTrussWerk, perf: RolandMultiPatchTrussWerk, voice: RolandMultiPatchTrussWerk, rhythm: RolandMultiPatchTrussWerk, voiceBank: AnyRolandSysexTrussWerk, perfBank: AnyRolandSysexTrussWerk, rhythmBank: AnyRolandSysexTrussWerk) -> BasicEditorTruss {

    let map = mapItems(global: global, perf: perf, voice: voice, rhythm: rhythm, voiceBank: voiceBank, perfBank: perfBank, rhythmBank: rhythmBank)
    let werk = sysexWerk.editorWerk(name, map: map)
    var t = BasicEditorTruss(werk.displayId, truss: [([.deviceId], RolandDeviceIdSettingsTruss)] + werk.sysexMap() + [([.pcm], JV880.Card.truss)])

    let pcmXform: ParamOutTransform = .patchOut([.pcm], { change, patch in
      [[.pcm] : .p([.pcm], p: patch?[[.int]] ?? 0)]
    })
    
    t.extraParamOuts = [
      ([.perf], .bankNames([.bank, .patch, .i(0)], [.patch, .name])),
      // map [.int] setting in cardpatch to a param [.pcm] whose parm value is used by ctrlr
      ([.patch], pcmXform),
      ([.rhythm], pcmXform),
    ] + 7.map {
      ([.part, .i($0)], pcmXform)
    }

    t.fetchTransforms = werk.defaultFetchTransforms()
    t.midiOuts = werk.midiOuts()
    
    let userXform: MemSlot.Transform = .user({ "I\(($0 + 1).zPad(2))" })
    t.slotTransforms = [
      [.bank, .patch, .i(0)] : userXform,
      [.bank, .perf, .i(0)] : userXform,
      [.bank, .rhythm, .i(0)] : userXform,
    ]
    
    t.midiChannels = [
      [.patch] : .patch([.global], [.patch, .channel]),
      [.rhythm] : .patch([.perf], [.part, .i(7), .channel]),
    ] <<< 7.dict {
      [[.part, .i($0)] : .patch([.perf], [.part, .i($0), .channel])]
    }
    
    return t
  }

  
//  override func onSave(toBankPath bankPath: SynthPath, index: Int, fromPatchPath patchPath: SynthPath) {
    // side effect: if saving from a part editor, update performance patch
    //    guard patchPath[0] == .part else { return }
    //    let params: [SynthPath:Int] = [
    //      patchPath + [.patch, .group] : 0,
    //      patchPath + [.patch, .group, .id] : 1,
    //      patchPath + [.patch, .number] : index
    //    ]
    //    patch(forPath: [.perf])?.patchChangesInput.value = .paramsChange(params)
//  }
  
  
  static func moduleTruss(_ editorTruss: EditorTruss, subid: String, sections: [ModuleTrussSection]) -> BasicModuleTruss {
    
    return BasicModuleTruss(editorTruss, manu: Manufacturer.roland, model: editorTruss.displayId, subid: subid, sections: sections, dirMap: [
      [.part] : "Patch",
    ], colorGuide: ColorGuide([
      "#43a6fb",
      "#ed1107",
      "#edc007",
    ]), indexPath: IndexPath(item: 3, section: 0))
    
  }
  
  static func sections(global: PatchController, perf: PatchController, hideOut: Bool) -> [ModuleTrussSection] {
    return [
      .first([
        .deviceId(),
        .custom("Cards", [.pcm], JV880.Card.Controller.ctrlr()),
        .global(global),
        .voice("Patch", JV880.Voice.Controller.ctrlr(perf: false, hideOut: hideOut)),
      ]),
      .basic("Performance", [
        .perf(perf),
      ] + 7.map {
        .voice("Part \($0 + 1)", path: [.part, .i($0)], JV880.Voice.Controller.ctrlr(perf: true, hideOut: hideOut))
      } + [
        .custom("Rhythm", [.rhythm], JV880.Rhythm.Controller.controller(hideOut: hideOut)),
      ]),
      .banks([
        .bank("Patch Bank", [.bank, .patch, .i(0)]),
        .bank("Rhythm Bank", [.bank, .rhythm, .i(0)]),
        .bank("Perf Bank", [.bank, .perf, .i(0)]),
      ]),
    ]
  }
}

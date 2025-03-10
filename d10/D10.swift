
public enum D10 {
  
  static let mapItems: [RolandEditorTrussWerk.MapItem] = {
    let tone = DXX.Tone.patchWerk
    let toneBank = DXX.Tone.bankWerk
    var map: [RolandEditorTrussWerk.MapItem] = [
      ([.global], System.patchWerk.start, System.patchWerk),
      // patch
      ([.perf], Patch.patchWerk.start, Patch.patchWerk),
      // multi-timbre
//      ([.multi], multiTimbrePatchWerk.start, multiTimbrePatchWerk),
      ([.bank, .tone], toneBank.start, toneBank),
      ([.bank, .perf], Patch.bankWerk.start, Patch.bankWerk),
      ([.bank, .timbre], Timbre.bankWerk.start, Timbre.bankWerk),
    ] 
    map += 8.map {
      ([.tone, .i($0)], 0x040000 + 0x0176 * $0, tone)
    } 
    map += 8.map {
      ([.timbre, .i($0)], 0x030000 + 0x0010 * $0, Timbre.patchWerk)
    }
    return map
  }()
  
  static func editorTruss(_ name: String) -> BasicEditorTruss {

    let map = mapItems
    let werk = DXX.sysexWerk.editorWerk(name, map: map)
    let perfBank = Patch.bankWerk
    var t = BasicEditorTruss(werk.displayId, truss: [([.deviceId], RolandDeviceIdSettingsTruss)] + werk.sysexMap())
    
    t.extraParamOuts = [
      ([.perf], .bankNames([.bank, .tone], [.tone, .name])),
    ]
    
    t.fetchTransforms = werk.defaultFetchTransforms()

    var midiOuts = werk.midiOuts()
    t.midiOuts = midiOuts
    
    t.slotTransforms = [
      [.bank, .tone] : .user({ "i\(($0 + 1).zPad(2))" }),
      [.bank, .perf] : .user({ 
        let ab = $0 < 64 ? "A" : "B"
        let x = $0 % 64
        return "I-\(ab)\(1 + x / 8)\(1 + x % 8)"
      }),
      [.bank, .timbre] : .user({
        let ab = $0 < 64 ? "A" : "B"
        let x = $0 % 64
        return "I-\(ab)\(1 + x / 8)\(1 + x % 8)"
      }),
    ]
    
    t.midiChannels = [:]
    
    return t
  }
  
  static func sections(system: PatchController, hideOut: Bool) -> [ModuleTrussSection] {
    [
      .first([
        .deviceId("Exclu Unit #"),
        .global(system, title: "System"),
        .perf(title: "Performance", Patch.Controller.ctrlr(hideReverb: hideOut)),
      ]),
      .basic("Tones", [
      ] + 8.map {
        let label = $0 == 0 ? "Tone 1 (Upper)" : $0 == 1 ? "Tone 2 (Lower)" : "Tone \($0 + 1)"
        return .voice(label, path: [.tone, .i($0)], DXX.Tone.Controller.ctrlr())
      }),
      .basic("Multi-Timbral", [
      ] + 8.map {
        .perf(title: "Timbre \($0 + 1)", path: [.timbre, .i($0)], Timbre.Controller.timbre(hideOut: hideOut))
      }),
      .banks([
        .bank("Tone Bank", [.bank, .tone]),
        .bank("Patch Bank", [.bank, .perf]),
        .bank("Timbre Bank", [.bank, .timbre]),
      ]),
    ]
  }
  
  public static let moduleTruss = createModuleTruss("D-10", subid: "d10", system: Controller.systemCtrlr, hideOut: false)
  
  static func createModuleTruss(_ name: String, subid: String, system: PatchController, hideOut: Bool) -> BasicModuleTruss {
    let editorTruss = Self.editorTruss(name)
    return BasicModuleTruss(editorTruss, manu: Manufacturer.roland, model: editorTruss.displayId, subid: subid, sections: sections(system: system, hideOut: hideOut), dirMap: [
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
    
  }
  
}

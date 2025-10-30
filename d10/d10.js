
const editor = {
  rolandModelId: [0x16],
  addressCount: 3,
  name: "D-10",
  map: ([
    ['deviceId'],
    ['global'], System.patchWerk.start, System.patchWerk),
    // patch
    ['perf'], Patch.patchWerk.start, Patch.patchWerk),
    // multi-timbre
    //      ([.multi], multiTimbrePatchWerk.start, multiTimbrePatchWerk),
    ['bank/tone'], toneBank.start, DXX.Tone.bankWerk),
    ['bank/perf'], Patch.bankWerk.start, Patch.bankWerk),
    ['bank/timbre'], Timbre.bankWerk.start, Timbre.bankWerk),
  ]).concat((8).map(i => 
    [['tone', i], 0x040000 + 0x0176 * i, DXX.Tone.patchWerk]
  )).concat((8).map(i => 
    [['timbre', i], 0x030000 + 0x0010 * i, Timbre.patchWerk]
  )),
  extraParamOuts: [
    ['perf', ['bankNames', "bank/tone", 'tone/name']],
  ],
  slotTransforms: [
    ['bank/tone', ['user', i => `i${i+ 1}.zPad(2))`]],
    ['bank/perf', ['user', i => { 
      const ab = $0 < 64 ? "A" : "B"
      const x = $0 % 64
      return `I-${ab}${1 + x / 8}${1 + x % 8}`
    }]],
    ['bank/timbre', ['user', i => {
      const ab = $0 < 64 ? "A" : "B"
      const x = $0 % 64
      return `I-${ab}${1 + x / 8}${1 + x % 8}`
    }]],
  ]

}

public enum D10 {
  
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

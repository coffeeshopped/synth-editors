

/// MSB first. lower 4 bits of each byte used
static func multiPack(_ byte: RolandAddress) -> PackIso {
  Roland.msbMultiPackIso(2)(byte)
}


const editorTruss = (name, files) => {
  
  const global = require('./'+files.global+'_global.js')
  const perf = require('./'+files.perf+'_perf.js')
  const voice = require('./'+files.voice+'_voice.js')
  const rhythm = require('./jv1080_rhythm.js')

    let pcmXform = .patchOut("pcm", { change, patch in
    ["pcm" : ['pcm', { p: patch?["int"] ?? 0 }]]
  })
  
  let userXform = .user({ "I\(($0 + 1).zPad(2))" })
  
  return {
    rolandModelId: [0x46], 
    addressCount: 4,
    name: name,
    map: ([
      ['deviceId']
      ["global", global.start, global],
      ["perf", perf.start, perf],
      ["patch", voice.start, voice],
      ["rhythm", rhythm.start, rhythm],
      ["bank/patch/0", voiceBank.start, voiceBank],
      ["bank/perf/0", perfBank.start, perfBank],
      ["bank/rhythm/0", rhythmBank.start, rhythmBank],
      [("pcm", JV880.Card.truss)],
    ]).concat((7).map(i =>
      [["part", i], [0x00, i, 0x20, 0x00], voice]
    )),
    extraParamOuts: [
      ("perf", .bankNames("bank/patch/0", "patch/name")),
      // map "int" setting in cardpatch to a param "pcm" whose parm value is used by ctrlr
      ("patch", pcmXform),
      ("rhythm", pcmXform),
    ] + 7.map {
      ("part/$0", pcmXform)
    },
    midiChannels: [
      "patch" : .patch("global", "patch/channel"),
      "rhythm" : .patch("perf", "part/7/channel"),
    ] <<< 7.dict {
      ["part/$0" : .patch("perf", "part/$0/channel")]
    },
    slotTransforms: [
      "bank/patch/0" : userXform,
      "bank/perf/0" : userXform,
      "bank/rhythm/0" : userXform,
    ]

    
  }
}


const voicePatchWerk(tone) => ({
  multi: "Voice",
  map: [
    ['common', 0x0000, JV80.Voice.Common.patchWerk],
    ['tone/0', 0x0800, tone],
    ['tone/1', 0x0900, tone],
    ['tone/2', 0x0a00, tone],
    ['tone/3', 0x0b00, tone],
  ],
  initFile: "jv880-voice",
})

const voiceBankWerk = patchWerk => ({
  multiBank: patchWerk,
  patchCount: 64,
  initFile: "jv880-voice-bank", 
  iso: .init(address: {
    RolandAddress([$0, 0, 0])
  }, location: {
    // have to do this because the address passed here is an absolute address, not an offset
    // whereas above in "address:", we are creating an offset address
    $0.sysexBytes(count: 4)[1] - 0x40
  }),
})

const perfPatchWerk = (part) => ({
  multi: "Perf", 
  map: [
    ['common', 0x0000, JV80.Perf.Common.patchWerk],
  ].concat(
    (8).map(i => [['part', i], [0x08 + i, 0x00], part])
  ),
  initFile: "jv880-perf",
})

const perfBankWerk = patchWerk => ({
  multiBank: patchWerk, 
  patchCount: 16,
  initFile: "jv880-perf-bank",
  // iso: ['lsbyte', 2],
})

const rhythmPatchWerk = (note) => ({
  multi: "Rhythm", 
  map: (61).map(i =>
    [['note', i], [i, 0x00], note]
  ),
  initFile: "jv880-rhythm",
})

const rhythmBankWerk = patchWerk => {
  multiBank: patchWerk, 
  patchCount: 1, 
  initFile: "jv880-rhythm-bank",
}


//  override func onSave(toBankPath bankPath: SynthPath, index: Int, fromPatchPath patchPath: SynthPath) {
  // side effect: if saving from a part editor, update performance patch
  //    guard patchPath[0] == .part else { return }
  //    let params: [SynthPath:Int] = [
  //      patchPath + "patch/group" : 0,
  //      patchPath + "patch/group/id" : 1,
  //      patchPath + "patch/number" : index
  //    ]
  //    patch(forPath: "perf")?.patchChangesInput.value = .paramsChange(params)
//  }


static func moduleTruss(_ editorTruss: EditorTruss, subid: String, sections: [ModuleTrussSection]) -> BasicModuleTruss {
  
  return BasicModuleTruss(editorTruss, manu: Manufacturer.roland, model: editorTruss.displayId, subid: subid, sections: sections, dirMap: [
    "part" : "Patch",
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
      .custom("Cards", "pcm", JV880.Card.Controller.ctrlr()),
      .global(global),
      .voice("Patch", JV880.Voice.Controller.ctrlr(perf: false, hideOut: hideOut)),
    ]),
    .basic("Performance", [
      .perf(perf),
    ] + 7.map {
      .voice("Part \($0 + 1)", path: "part/$0", JV880.Voice.Controller.ctrlr(perf: true, hideOut: hideOut))
    } + [
      .custom("Rhythm", "rhythm", JV880.Rhythm.Controller.controller(hideOut: hideOut)),
    ]),
    .banks([
      .bank("Patch Bank", "bank/patch/0"),
      .bank("Rhythm Bank", "bank/rhythm/0"),
      .bank("Perf Bank", "bank/perf/0"),
    ]),
  ]
}


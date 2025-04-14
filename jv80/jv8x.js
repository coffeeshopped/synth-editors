const Global = require('./jv8x_global.js')
const Voice = require('./jv8x_voice.js')
const Rhythm = require('./jv8x_rhythm.js')
const Perf = require('./jv8x_perf.js')

const SRJVBoard = require('./srjv_board.js')
const SOPCMCard = require('./sopcm_card.js')

const VoiceCtrlr = require('./jv8x_voice_ctrlr.js')
const RhythmCtrlr = require('./jv8x_rhythm_ctrlr.js')

const cardTruss = {
  json: "JV-880 Card", 
  parms: [
    ['int', {b: 0, opts: SRJVBoard.boardNames }],
    ['pcm', {b: 1, opts: SOPCMCard.cardNames }],
  ], 
  initFile: "jv880-cards",
}

const editorTruss = (name, config) => {
  
  const global = Global.patchWerk(config.global)
  const perf = Perf.werks(config.perf)
  const voice = Voice.werks(config.voice)
  const rhythm = Rhythm.werks(config.rhythm)

  const pcmXform = ['patchOut', "pcm", (change, patch) =>
    [['pcm', patch["int"] || 0]]
  ]
  
  let userXform = ['user', i => ['>', i+1, ['zPad', 2], ['f', 'I%s']]]
  
  return {
    rolandModelId: [0x46], 
    addressCount: 4,
    name: name,
    map: ([
      ['deviceId']
      ["global", 0x00000000, global],
      ["perf", 0x00001000, perf.patch],
      ["patch", 0x00082000, voice.patch],
      ["rhythm", 0x00074000, rhythm.patch],
      ["bank/patch/0", 0x01402000, voice.bank],
      ["bank/perf/0", 0x01001000, perf.bank],
      ["bank/rhythm/0", 0x017f4000, rhythm.bank],
      ["pcm", cardTruss],
    ]).concat((7).map(i =>
      [["part", i], [0x00, i, 0x20, 0x00], voice.patch]
    )),
    extraParamOuts: ([
      ["perf", 'bankNames', "bank/patch/0", "patch/name"],
      // map "int" setting in cardpatch to a param "pcm" whose parm value is used by ctrlr
      ["patch", pcmXform]
      ["rhythm", pcmXform],
    ]).concat(
      (7).map(i => [["part", i], pcmXform])
    ),
    midiChannels: ([
      ["patch", ['patch', "global", "patch/channel"]],
      ["rhythm", ['patch', "perf", "part/7/channel"]],
    ]).concat(
      (7).map(i => [["part", i], ['patch', "perf", ["part", i, "channel"]]])
    ),
    slotTransforms: [
      ["bank/patch/0", userXform],
      ["bank/perf/0", userXform],
      ["bank/rhythm/0", userXform],
    ],
  }
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

const moduleTruss = (editor, subid, globalCtrlr, perfCtrlr, hideOut) => ({
  editor: editor, 
  manu: "Roland", 
  subid: subid, 
  sections: [
    ['first', [
      'deviceId',
      ['custom', "Cards", "pcm", {
        color: 1, 
        builders: [
          ['grid', [[
            [{select: "Expansion Card"}, 'int'],
            [{select: "PCM Card"}, 'pcm'],
          ]]],
        ],
      }],
      ['global', globalCtrlr.ctrlr],
      ['voice', "Patch", VoiceCtrlr.ctrlr(false, hideOut)],
    ]],
    ['basic', "Performance", ([
      ['perf', perfCtrlr.ctrlr],
    ]).concat(
      (7).map(i => 
        ['voice', `Part ${i + 1}`, VoiceCtrlr.ctrlr(true, hideOut), ["part", i]]
      ),
      [['custom', "Rhythm", "rhythm", RhythmCtrlr.ctrlr(hideOut)]]
    )],
    ['banks', [
      ['bank', "Patch Bank", "bank/patch/0"],
      ['bank', "Rhythm Bank", "bank/rhythm/0"],
      ['bank', "Perf Bank", "bank/perf/0"],
    ]],
  ], 
  dirMap: [
    ["part", "Patch"],
  ], 
  colorGuide: [
    "#43a6fb",
    "#ed1107",
    "#edc007",
  ], 
  indexPath: [0, 3],
})

module.exports = {
  editorTruss,
  moduleTruss,
}

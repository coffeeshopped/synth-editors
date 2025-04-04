const Op4 = require('./op4.js')
const VCED = require('./vced.js')
const ACED = require('./aced.js')
const ACED2 = require('./aced2.js')
const VoiceController = require('./dx21_voice_ctrlr.js')
const TX81Z = require('./tx81z.js')

const synth = "DX11"


const voiceMap = [
  ["aftertouch", ACED2.patchTruss],
  ["extra", ACED.patchTruss],
  ["voice", VCED.patchTruss],
]

const compactMap = [
  ["aftertouch", ACED2.compactTruss],
  ["extra", ACED.compactTruss],
  ["voice", VCED.compactTruss],
]

const werkMap = [
  ["aftertouch", ACED2.patchWerk],
  ["extra", ACED.patchWerk],
  ["voice", VCED.patchWerk],
]

const voicePatchTruss = Op4.createVoicePatchTruss(synth, voiceMap, "dx11-voice-init", [TX81Z.Voice.patchTruss.fileDataCount])
const voiceBankTruss = Op4.createVoiceBankTruss(voicePatchTruss, 32, "dx11-voice-bank-init", compactMap)


  // static let backupTruss = BackupTruss("DX11", map: [
  //   ([.micro, .octave], Op4.Micro.Oct.werk.patchWerk.truss),
  //   ([.micro, .key], Op4.Micro.Full.werk.patchWerk.truss),
  //   ([.bank], Voice.bankTruss),
  //   ([.bank, .perf], Perf.bankTruss),
  // ], pathForData: TX81Z.backupPathForData)


extension DX11 {
  
  enum Editor {

    static let werk = TX81Z.EditorWerk(voiceTruss: Voice.patchTruss, voiceBankTruss: Voice.bankTruss)

    static let truss: BasicEditorTruss = {
      var t = BasicEditorTruss("DX11", truss: trussMap)
      t.fetchTransforms = TX81Z.Editor.truss.fetchTransforms <<< [
        [.patch] : Op4.fetch(header: "8023AE")
      ]
      t.midiOuts = [
        ([.patch], Op4.patchChangeTransform(truss: Voice.patchTruss, map: Voice.map)),
        ([.perf], Perf.patchTransform),
        ([.micro, .octave], Op4.Micro.Oct.werk.patchChangeTransform()),
        ([.micro, .key], Op4.Micro.Full.werk.patchChangeTransform()),
        ([.bank], Voice.bankTransform),
        ([.bank, .perf], TX81Z.Perf.wholeBankTransform(patchCount: Perf.bankTruss.patchCount, patchWerk: Perf.patchWerk))
      ]

      Op4.editorTrussSetup(&t)
      return t
    }()

    
    static let trussMap: [(SynthPath, any SysexTruss)] = werk.coreSysexMap +
    Op4.microSysexMap +
      [
        ([.perf], Perf.patchWerk.truss),
        ([.bank, .perf], Perf.bankTruss),
        ([.backup], backupTruss),
      ]
        
  }
}


extension DX11 {
  
  public enum Module {
    
    public static let truss = BasicModuleTruss(Editor.truss, manu: Manufacturer.yamaha, model: "DX11", subid: "dx11", sections: sections, dirMap: TX81Z.Module.directoryMap, colorGuide: colorGuide)
    
    static let colorGuide = ColorGuide([
      "#ca5e07",
      "#07afca",
      "#fa925f",
    ])
        
    static let sections: [ModuleTrussSection] = [
      .first([
        .channel(),
        .voice("Voice", Voice.Controller.controller),
        .perf(TX81Z.Perf.Controller.controller(Perf.presetVoices)),
        .voice("Micro Oct", path: [.micro, .octave], Op4.Micro.Controller.octController),
        .voice("Micro Full", path: [.micro, .key], Op4.Micro.Controller.fullController),
        ]),
      .banks([
        .bank("Voice Bank", [.bank]),
        .bank("Perf Bank", [.bank, .perf]),
      ]),
      .backup,
      ]
    
  }
}

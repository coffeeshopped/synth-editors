const { prefix, reduce, offset } = require('/core/ParamOptions.js')
require('/core/ArrayUtils.js')
const DX7iiVoicePatch = require('./voice.js')
const { patchSysex, paramSysex } = require('/dx7/yamaha.js')

const dx7Path = "../../dx7/"
const DX7VoiceBank = require(dx7Path + "patch/voiceBank.js")
const ACEDBank = require('acedBank.js')


const sysexData = (compactByteArrays, channel) => patchSysex(compactByteArrays.flat(), channel, [0x09, 0x20, 0x00])

const sysexData = (channel, bank) => {
  return sysexDataArray(channel: channel, bank: bank).reduce(Data(), +)
}

const bankFlagSetData = (channel, bank) => paramSysex(channel, [0x19, 0x4d, bank])

const sysexDataArray = (compactByteArrays, channel, bank) => {
  // set which bank to receive
  const bankFlag = bankFlagSetData(channel, bank)
  const aced = ACEDBank.sysexData(compactByteArrays.aced, channel)
  const vced = DX7VoiceBank.sysexData(compactByteArrays.vced, channel)
  return bankFlag.concat(aced).concat(vced)
}

const compactByteCount = 128

const trussMap = [
  [["voice"], DX7VoiceBank],
  [["extra"], ACEDBank],
]

module.exports = {
  trussType: "CompactMultiBank",
  localType: "PatchBank",
  PatchType: DX7iiVoicePatch,
  trussMap: trussMap,
  initFileName: "tx802-voice-bank-init",
  patchCount: 32,
  fileDataCount: 5232,
  compactByteCount: compactByteCount,
  
  // first 7-byte sysex msg is optional
  // 4104: A DX7 (mkI) bank
  isValidSize: fileSize => [5232, 5239, 4104].includes(fileSize),

  sysexData: sysexData,
  fileData: compactByteArrays => sysexData(compactByteArrays, 0),
  
  compactSingleBankFileData(fileData) {
    let sysex = fileData.sysex()
    switch (sysex.length) {
    case 3:
      return {
        aced: sysex[1],
        vced: sysex[2],
      }
    case 2:
      return {
        aced: sysex[0],
        vced: sysex[1],
      }
    case 1:
      // assume this is a DX7 bank
      return {
        aced: [],
        vced: sysex[0],
      }
    default:
      // assume this is a DX7 bank
      return {
        aced: [],
        vced: [],
      }
    }
    // return (0..<32).map {
    //   Patch(vced: vced.patches[$0], aced: aced.patches[$0])
    // }
  },
  
  bankAOptions: ["MellowHorn", "SilvaBrass", "ReverbBras", "Tuba", "Trombone", "HardTrumps", "Trumpet A", "SilvaTrpt", "Trumpet B", "FrenchHorn", "Strings", "HallOrch", "NewOrchest", "Analog-Str", "LiveStrg", "Bowed Bass", "EleCello A", "EleCello B", "Violins", "Bassoon", "Clarinet", "Oboe", "Flute", "Song Flute", "SpitFlute", "PanFloot", "Piccolo", "Sax", "Harmonica", "Harp", "EbonyIvory", "PianoBrite", "Piano 1", "Piano 2", "KnockRoad", "RubbaRoad", "HardRoads", "FullTines", "ClaviStuff", "Clavi", "Clavecin", "ClaviPluck", "NasalClav", "HarpsiBox", "HarpsiWire", "WireStrg A", "WireStrg B", "TouchOrgan", "ShOrgan", "TapOrgan", "BriteOrgan", "MagicOrgan", "SoftOrgan", "PipeOrgan", "PuffOrgan1", "PuffPipes", "PuffOrgan2", "Harmonium1", "Harmonium2", "Whisper A", "Choir", "LadyVox", "MaleChoir", "Whisper B"],
  
  bankBOptions: ["SuperBass", "StringBass", "SkweekBass", "SmoohBass", "BopBass", "OwlBass", "JazzBass", "HardBass", "GuitarBox", "PickGuitar", "FingaPicka", "LeadaPicka", "YesBunk", "12 Strings", "Classipika", "Shami", "Maribumba", "DX Marimba", "Nu Marimba", "StonePhone", "VibraPhone", "Celeste", "Swissnare", "Tom C4", "CongaDrum", "Tub Bells", "Gong", "Tinpani", "Claves", "Bells", "SteelCans", "Handrum", "Analog-X", "FMilters", "Phasers", "Ensemble", "MalletHorn", "FM-Growth", "ElectoComb", "ClariSolo", "PitchaPad", "ClaviBrass", "WhapSynth", "Whasers", "Fifths", "ElecBrass", "ElectroBak", "HarmoSynth", "PianoBells", "St.Elmo's", "MilkyWays", "Pluk", "TingVoice", "Plukatan", "OctiLate", "LateDown", "Glastine", "BellWahh", "RubberGong", "Wallop", "Explosion", "KoikeCycle", "Thunderon", "Science"],
  
}



public extension TX802ishVoiceBank {



  func fileData() -> Data { sysexData(channel: 0, bank: 0) }
  
}


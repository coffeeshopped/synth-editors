
open class TX802ACEDPatch : YamahaSinglePatch, BankablePatch {
 
 public const fileDataCount = 57
  
 required public init(bankData: Data) {
   // create empty bytes to pack into
   bytes = [UInt8](repeating: 0, count: 49)
   let b = [UInt8](bankData)
   type(of: self).bankParams.forEach {
     self[$0.key] = type(of: self).defaultUnpack(param: $0.value, forBytes: b)
   }
 }
 
 func bankSysexData() -> Data {
   var b = [UInt8](repeating: 0, count: 35)
   // pack the params
   type(of: self).bankParams.forEach {
     let param = $0.value
     b[param.byte] = type(of: self).defaultPackedByte(value: self[$0.key] ?? 0, forParam: param, byte: b[param.byte])
   }
   return Data(b)
 }
   
}

const pitchEnvRangeOptions = ["8 oct", "2 oct", "1 oct", "1/2 oct"]

const acedParms = [
  { prefix: 'op', count: 6, block: (op) => [
    ["scale/mode", { b: 5 - op, opts: ["Normal","Frac"] }],
    ["amp/mod", { b: (5 - op) + 6, max: 7 }],
  ] },   
  ["pitch/env/range", { b: 12, opts: pitchEnvRangeOptions }],
  ["lfo/trigger/mode", { b: 13, opts: ["Single","Multi"] }],
  ["velo/pitch/sens", { b: 14, max: 1 }],
  ["mono", { b: 15, opts: ["Poly","Mono"] }],
  ["bend/range", { b: 16, max: 12 }],
  ["bend/step", { b: 17, max: 12 }],
  ["bend/mode", { b: 18, max: 2 }],
  ["random/pitch", { b: 19, max: 7 }],
  ["porta/mode", { b: 20, opts: ["Retain","Follow"] }],
  ["porta/step", { b: 21, max: 12 }],
  ["porta/time", { b: 22, max: 99 }],
  ["modWheel/pitch", { b: 23, max: 99 }],
  ["modWheel/amp", { b: 24, max: 99 }],
  ["modWheel/env/bias", { b: 25, max: 99 }],
  ["foot/pitch", { b: 26, max: 99 }],
  ["foot/amp", { b: 27, max: 99 }],
  ["foot/env/bias", { b: 28, max: 99 }],
  ["foot/volume", { b: 29, max: 99 }],
  ["breath/pitch", { b: 30, max: 99 }],
  ["breath/amp", { b: 31, max: 99 }],
  ["breath/env/bias", { b: 32, max: 99 }],
  ["breath/pitch/bias", { b: 33, max: 100 }],
  ["aftertouch/pitch", { b: 34, max: 99 }],
  ["aftertouch/amp", { b: 35, max: 99 }],
  ["aftertouch/env/bias", { b: 36, max: 99 }],
  ["aftertouch/pitch/bias", { b: 37, max: 100 }],
  ["pitch/env/rate/scale", { b: 38, max: 7 }],
  
  // Not used on TX-802, but on DX7ii/S
  ["foot/1/pitch", { p: 64, b: 39, max: 99 }],
  ["foot/1/amp", { p: 65, b: 40, max: 99 }],
  ["foot/1/env/bias", { p: 66, b: 41, max: 99 }],
  ["foot/1/volume", { p: 67, b: 42, max: 99 }],
  ["midi/ctrl/pitch", { p: 68, b: 43, max: 99 }],
  ["midi/ctrl/amp", { p: 69, b: 44, max: 99 }],
  ["midi/ctrl/env/bias", { p: 70, b: 45, max: 99 }],
  ["midi/ctrl/volume", { p: 71, b: 46, max: 99 }],
  // TODO: DX7s manual gave me the parm (72) here. I think I guessed on the byte # (47, originally).
  //   The DX200 lists unison detune as byte 48 though. So that might be right.
  //   So I swapped byte # for these next 2. Need to test with hardware...
  ["unison/detune", { p: 72, b: 48, max: 7 }],
  ["foot/slider", { p: 73, b: 47, max: 1 }],
]

const compactAcedParms = [
  { prefix: 'op', count: 6, block: (op) => [
    ["scale/mode", { b: 0, bit: 5 - op }],
  ] },   
  ["op/5/amp/mod", { b: 1, bits: [0, 2] }],
  ["op/4/amp/mod", { b: 1, bits: [3, 5] }],
  ["op/3/amp/mod", { b: 2, bits: [0, 2] }],
  ["op/2/amp/mod", { b: 2, bits: [3, 5] }],
  ["op/1/amp/mod", { b: 3, bits: [0, 2] }],
  ["op/0/amp/mod", { b: 3, bits: [3, 5] }],
  
  ["pitch/env/range", { b: 4, bits: [0, 1] }],
  ["lfo/trigger/mode", { b: 4, bit: 2 }],
  ["velo/pitch/sens", { b: 4, bit: 3 }],
  ["mono", { b: 5, bits: [0, 1] }],
  ["bend/range", { b: 5, bits: [2, 5] }], // This was wrong in the Yamaha docs.
  ["bend/step", { b: 6, bits: [0, 3] }],
  ["bend/mode", { b: 6, bits: [4, 5] }],
  ["random/pitch", { b: 4, bits: [4, 6] }],
  ["porta/mode", { b: 7, bit: 0 }],
  ["porta/step", { b: 7, bits: [1, 4] }],
  ["porta/time", { b: 8 }],
  ["modWheel/pitch", { b: 9 }],
  ["modWheel/amp", { b: 10 }],
  ["modWheel/env/bias", { b: 11 }],
  ["foot/pitch", { b: 12 }],
  ["foot/amp", { b: 13 }],
  ["foot/env/bias", { b: 14 }],
  ["foot/volume", { b: 15 }],
  ["breath/pitch", { b: 16 }],
  ["breath/amp", { b: 17 }],
  ["breath/env/bias", { b: 18 }],
  ["breath/pitch/bias", { b: 19 }],
  ["aftertouch/pitch", { b: 20 }],
  ["aftertouch/amp", { b: 21 }],
  ["aftertouch/env/bias", { b: 22 }],
  ["aftertouch/pitch/bias", { b: 23 }],
  ["pitch/env/rate/scale", { b: 24 }],
  
  // Not used on TX-802, but on DX7ii/S
  ["foot/1/pitch", { b: 26 }],
  ["foot/1/amp", { b: 27 }],
  ["foot/1/env/bias", { b: 28 }],
  ["foot/1/volume", { b: 29 }],
  ["midi/ctrl/pitch", { b: 30 }],
  ["midi/ctrl/amp", { b: 31 }],
  ["midi/ctrl/env/bias", { b: 32 }],
  ["midi/ctrl/volume", { b: 33 }],
  ["unison/detune", { b: 34, bits: [0, 2] }],
  ["foot/slider", { b: 34, bit: 3 }],
]

const sysexData = ['yamCmd', ['channel', 0x05, 0x00, 0x31]]

const acedTruss = {
  single: 'aced',
  parms: acedParms,
  initFile: "tx802-aced-init",
  createFile: sysexData,
  parseBody: ['bytes', { start: 6, count: 49 }],
}

const patchTruss = {
  multi: 'voice',
  map: [
    ["voice", DX7Voice.patchTruss],
    ["extra", acedTruss],
  ],
  initFile: "tx802-voice-init",
  validSizes: ['auto', 163],
}

open class TX802VoicePatch : YamahaMultiPatch, Algorithmic, BankablePatch, VoicePatch {

 required public init(vced: DX7Patch, aced: TX802ACEDPatch) {
   ySubpatches = [
     "voice" : vced,
     "extra" : aced,
   ]
 }
   
 public func sysexData(channel: Int) -> Data {
   // ACED, then VCED
   var data = ySubpatches["extra"]?.sysexData(channel: channel) ?? Data()
   data += ySubpatches["voice"]?.sysexData(channel: channel) ?? Data()
   return data
 }
}


public extension TX802ishVoiceBank {

 static var patchCount: Int { 32 }
 static var fileDataCount: Int { 5232 }
 // TODO: need actual init file
 static var initFileName: String { "tx802-voice-bank-init" }

 static func isValid(fileSize: Int) -> Bool {
   // first 7-byte sysex msg is optional
   // 4104: A DX7 (mkI) bank
   return [5232, 5239, 4104].contains(fileSize)
 }

 static func bankFlagSetData(channel: Int, bank: Int) -> Data {
   Data([0xf0, 0x43 , 0x10 + UInt8(channel), 0x19, 0x4d, UInt8(bank), 0xf7])
 }

 func sysexData(channel: Int, bank: Int) -> Data {
   sysexDataArray(channel: channel, bank: bank).reduce(Data(), +)
 }
 
 func sysexDataArray(channel: Int, bank: Int) -> [Data] {
   // set which bank to receive
   var data = [Data]()
   data.append(Self.bankFlagSetData(channel: channel, bank: bank))
   
   let aceds = patches.compactMap { $0.subpatches[[.extra]] as? ACEDBank.Patch }
   let acedBank = ACEDBank(patches: aceds)
   data.append(acedBank.sysexData(channel: channel))
   
   let vceds: [DX7Patch] = patches.compactMap { $0.subpatches[[.voice]] as? DX7Patch }
   let vcedBank = DX7VoiceBank(patches: vceds)
   data.append(vcedBank.sysexData(channel: channel))
   
   return data
 }


 func fileData() -> Data { sysexData(channel: 0, bank: 0) }
 
 static func patchArray(fromData data: Data) -> [Patch] {
   let sysex = SysexData(data: data)
   
   let aced: ACEDBank
   let vced: DX7VoiceBank
   switch sysex.count {
   case 3:
     aced = ACEDBank(data: sysex[1])
     vced = DX7VoiceBank(data: sysex[2])
   case 2:
     aced = ACEDBank(data: sysex[0])
     vced = DX7VoiceBank(data: sysex[1])
   case 1:
     // assume this is a DX7 bank
     aced = ACEDBank()
     vced = DX7VoiceBank(data: sysex[0])
   default:
     // assume this is a DX7 bank
     aced = ACEDBank()
     vced = DX7VoiceBank()
   }
   return (0..<32).map {
     Patch(vced: vced.patches[$0], aced: aced.patches[$0])
   }
 }
}

public class TX802VoiceBank : TX802ishVoiceBank, DX7IIishVoiceBank {
 
 public typealias ACEDBank = TX802ACEDBank
 
 public var patches: [TX802VoicePatch]
 
const bankAOptions = OptionsParam.makeNumberedOptions(["MellowHorn", "SilvaBrass", "ReverbBras", "Tuba", "Trombone", "HardTrumps", "Trumpet A", "SilvaTrpt", "Trumpet B", "FrenchHorn", "Strings", "HallOrch", "NewOrchest", "Analog-Str", "LiveStrg", "Bowed Bass", "EleCello A", "EleCello B", "Violins", "Bassoon", "Clarinet", "Oboe", "Flute", "Song Flute", "SpitFlute", "PanFloot", "Piccolo", "Sax", "Harmonica", "Harp", "EbonyIvory", "PianoBrite", "Piano 1", "Piano 2", "KnockRoad", "RubbaRoad", "HardRoads", "FullTines", "ClaviStuff", "Clavi", "Clavecin", "ClaviPluck", "NasalClav", "HarpsiBox", "HarpsiWire", "WireStrg A", "WireStrg B", "TouchOrgan", "ShOrgan", "TapOrgan", "BriteOrgan", "MagicOrgan", "SoftOrgan", "PipeOrgan", "PuffOrgan1", "PuffPipes", "PuffOrgan2", "Harmonium1", "Harmonium2", "Whisper A", "Choir", "LadyVox", "MaleChoir", "Whisper B"], offset: 1)
 
const bankBOptions = OptionsParam.makeNumberedOptions(["SuperBass", "StringBass", "SkweekBass", "SmoohBass", "BopBass", "OwlBass", "JazzBass", "HardBass", "GuitarBox", "PickGuitar", "FingaPicka", "LeadaPicka", "YesBunk", "12 Strings", "Classipika", "Shami", "Maribumba", "DX Marimba", "Nu Marimba", "StonePhone", "VibraPhone", "Celeste", "Swissnare", "Tom C4", "CongaDrum", "Tub Bells", "Gong", "Tinpani", "Claves", "Bells", "SteelCans", "Handrum", "Analog-X", "FMilters", "Phasers", "Ensemble", "MalletHorn", "FM-Growth", "ElectoComb", "ClariSolo", "PitchaPad", "ClaviBrass", "WhapSynth", "Whasers", "Fifths", "ElecBrass", "ElectroBak", "HarmoSynth", "PianoBells", "St.Elmo's", "MilkyWays", "Pluk", "TingVoice", "Plukatan", "OctiLate", "LateDown", "Glastine", "BellWahh", "RubberGong", "Wallop", "Explosion", "KoikeCycle", "Thunderon", "Science"], offset: 1)
}

public extension TX802ACEDishBank {
 
 static var patchCount: Int { return 32 }
 static var fileDataCount: Int { return 1128 }
 static var initFileName: String { return "tx802-aced-bank-init" }

 func sysexData(channel: Int) -> Data {
   var data = Data([0xf0, 0x43, UInt8(channel), 0x06, 0x08, 0x60])
   let patchData = [UInt8](patches.map{ $0.bankSysexData() }.reduce(Data(), +))
   data.append(contentsOf: patchData)
   data.append(Patch.checksum(bytes: patchData))
   data.append(0xf7)
   return data
 }

 static func patchArray(fromData data: Data) -> [Patch] {
   let headerCount = 6 // bytes in header
   let offset = headerCount
   let patchByteCount = 35
   
   return stride(from: offset, to: data.count, by: patchByteCount).compactMap { doff in
     let endex = doff + patchByteCount
     guard endex <= data.count else { return nil }
     let sysex = data.subdata(in: doff..<endex)
     return Patch.init(bankData: sysex)
   }
 }
 
}

public class TX802ACEDBank : TX802ACEDishBank {
 
 public var patches: [TX802ACEDPatch]

}


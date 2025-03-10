
//protocol DX7IIishVoiceBank {
//  func sysexDataArray(channel: Int, bank: Int) -> [Data]
//}
//
//public protocol TX802ishVoiceBank : TypedSysexPatchBank, VoiceBank where Patch: TX802VoicePatch {
//  associatedtype ACEDBank: TX802ACEDishBank
//
//}
//
//public extension TX802ishVoiceBank {
//
//  static var patchCount: Int { 32 }
//  static var fileDataCount: Int { 5232 }
//  // TODO: need actual init file
//  static var initFileName: String { "tx802-voice-bank-init" }
//
//  static func isValid(fileSize: Int) -> Bool {
//    // first 7-byte sysex msg is optional
//    // 4104: A DX7 (mkI) bank
//    return [5232, 5239, 4104].contains(fileSize)
//  }
//
//  static func bankFlagSetData(channel: Int, bank: Int) -> Data {
//    Data([0xf0, 0x43 , 0x10 + UInt8(channel), 0x19, 0x4d, UInt8(bank), 0xf7])
//  }
//
//  func sysexData(channel: Int, bank: Int) -> Data {
//    sysexDataArray(channel: channel, bank: bank).reduce(Data(), +)
//  }
//  
//  func sysexDataArray(channel: Int, bank: Int) -> [Data] {
//    // set which bank to receive
//    var data = [Data]()
//    data.append(Self.bankFlagSetData(channel: channel, bank: bank))
//    
//    let aceds = patches.compactMap { $0.subpatches[[.extra]] as? ACEDBank.Patch }
//    let acedBank = ACEDBank(patches: aceds)
//    data.append(acedBank.sysexData(channel: channel))
//    
//    let vceds: [DX7Patch] = patches.compactMap { $0.subpatches[[.voice]] as? DX7Patch }
//    let vcedBank = DX7VoiceBank(patches: vceds)
//    data.append(vcedBank.sysexData(channel: channel))
//    
//    return data
//  }
//
//
//  func fileData() -> Data { sysexData(channel: 0, bank: 0) }
//  
//  static func patchArray(fromData data: Data) -> [Patch] {
//    let sysex = SysexData(data: data)
//    
//    let aced: ACEDBank
//    let vced: DX7VoiceBank
//    switch sysex.count {
//    case 3:
//      aced = ACEDBank(data: sysex[1])
//      vced = DX7VoiceBank(data: sysex[2])
//    case 2:
//      aced = ACEDBank(data: sysex[0])
//      vced = DX7VoiceBank(data: sysex[1])
//    case 1:
//      // assume this is a DX7 bank
//      aced = ACEDBank()
//      vced = DX7VoiceBank(data: sysex[0])
//    default:
//      // assume this is a DX7 bank
//      aced = ACEDBank()
//      vced = DX7VoiceBank()
//    }
//    return (0..<32).map {
//      Patch(vced: vced.patches[$0], aced: aced.patches[$0])
//    }
//  }
//}
//
//public class TX802VoiceBank : TX802ishVoiceBank, DX7IIishVoiceBank {
//  
//  public required init(patches p: [TX802VoicePatch]) {
//    patches = p
//  }
//  
//  public func copy() -> Self {
//    Self.init(patches: patches.map { $0.copy() })
//  }
//  
//  public typealias ACEDBank = TX802ACEDBank
//  
//  public var patches: [TX802VoicePatch]
//  public var name = ""
//  
//  required public init(data: Data) {
//    patches = Self.patchArray(fromData: data)
//  }
//  
//  static let bankAOptions = OptionsParam.makeNumberedOptions(["MellowHorn", "SilvaBrass", "ReverbBras", "Tuba", "Trombone", "HardTrumps", "Trumpet A", "SilvaTrpt", "Trumpet B", "FrenchHorn", "Strings", "HallOrch", "NewOrchest", "Analog-Str", "LiveStrg", "Bowed Bass", "EleCello A", "EleCello B", "Violins", "Bassoon", "Clarinet", "Oboe", "Flute", "Song Flute", "SpitFlute", "PanFloot", "Piccolo", "Sax", "Harmonica", "Harp", "EbonyIvory", "PianoBrite", "Piano 1", "Piano 2", "KnockRoad", "RubbaRoad", "HardRoads", "FullTines", "ClaviStuff", "Clavi", "Clavecin", "ClaviPluck", "NasalClav", "HarpsiBox", "HarpsiWire", "WireStrg A", "WireStrg B", "TouchOrgan", "ShOrgan", "TapOrgan", "BriteOrgan", "MagicOrgan", "SoftOrgan", "PipeOrgan", "PuffOrgan1", "PuffPipes", "PuffOrgan2", "Harmonium1", "Harmonium2", "Whisper A", "Choir", "LadyVox", "MaleChoir", "Whisper B"], offset: 1)
//  
//  static let bankBOptions = OptionsParam.makeNumberedOptions(["SuperBass", "StringBass", "SkweekBass", "SmoohBass", "BopBass", "OwlBass", "JazzBass", "HardBass", "GuitarBox", "PickGuitar", "FingaPicka", "LeadaPicka", "YesBunk", "12 Strings", "Classipika", "Shami", "Maribumba", "DX Marimba", "Nu Marimba", "StonePhone", "VibraPhone", "Celeste", "Swissnare", "Tom C4", "CongaDrum", "Tub Bells", "Gong", "Tinpani", "Claves", "Bells", "SteelCans", "Handrum", "Analog-X", "FMilters", "Phasers", "Ensemble", "MalletHorn", "FM-Growth", "ElectoComb", "ClariSolo", "PitchaPad", "ClaviBrass", "WhapSynth", "Whasers", "Fifths", "ElecBrass", "ElectroBak", "HarmoSynth", "PianoBells", "St.Elmo's", "MilkyWays", "Pluk", "TingVoice", "Plukatan", "OctiLate", "LateDown", "Glastine", "BellWahh", "RubberGong", "Wallop", "Explosion", "KoikeCycle", "Thunderon", "Science"], offset: 1)
//}
//
//public protocol TX802ACEDishBank : TypedSysexPatchBank where Patch: TX802ACEDPatch {
//  init(patches p: [Patch])
//  func sysexData(channel: Int) -> Data
//}
//
//public extension TX802ACEDishBank {
//  
//  static var patchCount: Int { return 32 }
//  static var fileDataCount: Int { return 1128 }
//  static var initFileName: String { return "tx802-aced-bank-init" }
//
//  func sysexData(channel: Int) -> Data {
//    var data = Data([0xf0, 0x43, UInt8(channel), 0x06, 0x08, 0x60])
//    let patchData = [UInt8](patches.map{ $0.bankSysexData() }.reduce(Data(), +))
//    data.append(contentsOf: patchData)
//    data.append(Patch.checksum(bytes: patchData))
//    data.append(0xf7)
//    return data
//  }
//
//  static func patchArray(fromData data: Data) -> [Patch] {
//    let headerCount = 6 // bytes in header
//    let offset = headerCount
//    let patchByteCount = 35
//    
//    return stride(from: offset, to: data.count, by: patchByteCount).compactMap { doff in
//      let endex = doff + patchByteCount
//      guard endex <= data.count else { return nil }
//      let sysex = data.subdata(in: doff..<endex)
//      return Patch.init(bankData: sysex)
//    }
//  }
//  
//  func fileData() -> Data {
//    return sysexData(channel: 0)
//  }
//
//}
//
//public class TX802ACEDBank : TX802ACEDishBank {
//  
//  public var patches: [TX802ACEDPatch]
//  public var name = ""
//  
//  required public init(data: Data) {
//    patches = Self.patchArray(fromData: data)
//  }
//  
//  required public init(patches p: [TX802ACEDPatch]) {
//    patches = p.map { $0.copy() }
//  }
//    
//  public func copy() -> Self {
//    Self.init(patches: patches.map { $0.copy() })
//  }
//
//}

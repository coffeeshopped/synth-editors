
class DX200PatternPatch : MultiSysexPatch, BankablePatch {
  
  /// Gives bank location for a DX200 subpatch
  static func location(forData data: Data) -> Int {
    let modelId = data[3]
    let address1 = data[6]
    let address2 = data[7]
    if modelId == 0x62 && (0x30..<0x40).contains(address1) {
      // free env
      return Int(((address1 & 0b1111) << 4) + ((address2 >> 4) & 0b111))
    }
    else {
      return Int(address2)
    }
  }

  static var initFileName: String = "dx200-pattern-init"
  static var maxNameCount: Int { return DX200VoicePatch.maxNameCount }

  var name: String {
    get { return subpatches["voice/voice"]?.name ?? "" }
    set { subpatches["voice/voice"]?.name = newValue }
  }
  
  // Specifies order to send in!
  static var subpatchMap: [(SynthPath,SysexPatch.Type)] = [
    ("scene/0", DX200VoiceScenePatch.self),
    ("scene/1", DX200VoiceScenePatch.self),
    ("common/extra", DX200VoiceCommon2Patch.self),
    ("voice/common", DX200VoiceCommon1Patch.self),
    ("voice/voice", DX200VoicePatch.self), // putting voice after common/scenes so that it sets the LFO speed and porta correctly
    ("voice/env", DX200VoiceFreeEnvPatch.self),
    ("voice/seq", DX200VoiceSeqPatch.self),
    ("voice/fx", DX200RhythmFXPatch.self),
    ("part/0", DX200RhythmMultiPartPatch.self),
    ("part/1", DX200RhythmMultiPartPatch.self),
    ("part/2", DX200RhythmMultiPartPatch.self),
    ("part/voice", DX200RhythmMultiPartPatch.self),
    ("rhythm/0", DX200RhythmSeqPatch.self),
    ("rhythm/1", DX200RhythmSeqPatch.self),
    ("rhythm/2", DX200RhythmSeqPatch.self),
  ]
    
  private static func synthPath(forData data: Data) -> SynthPath? {
    guard data.count >= 9 else { return nil }
    switch data[3] {
    case 0x00, 0x05:
      return "voice/voice"
    case 0x62: // voice
      switch data[6] {
      case 0x10: // edit buffer
        switch data[7] {
        case 0x00: return "voice/common"
        case 0x01: return "common/extra"
        case 0x02: return "voice/env"
        case 0x03: return "scene/0"
        case 0x04: return "scene/1"
        case 0x40: return "voice/seq"
        default: return nil
        }
      case 0x20: return "voice/common"
      case 0x21: return "common/extra"
      case 0x[30, 0]x3f: return "voice/env"
      case 0x40: return "scene/0"
      case 0x41: return "scene/1"
      case 0x50: return "voice/seq"
      default: return nil
      }
    case 0x6d: // rhythm
      switch data[6] {
      case 0x02: return "voice/fx" // edit buffer
      case 0x08: // edit buffer
        switch data[7] {
        case 0x00: return "part/0"
        case 0x01: return "part/1"
        case 0x02: return "part/2"
        case 0x08: return "part/voice"
        default: return nil
        }
      case 0x10: // edit buffer
        switch data[7] {
        case 0x00: return "rhythm/0"
        case 0x01: return "rhythm/1"
        case 0x02: return "rhythm/2"
        default: return nil
        }
      case 0x20: return "rhythm/0"
      case 0x21: return "rhythm/1"
      case 0x22: return "rhythm/2"
      case 0x30: return "voice/fx"
      case 0x40: return "part/0"
      case 0x41: return "part/1"
      case 0x42: return "part/2"
      case 0x48: return "part/voice"
      default: return nil
      }
    default:
      return nil
    }
  }
  
  var dxPatch: DX200VoicePatch {
    return subpatches["voice/voice"] as! DX200VoicePatch
  }
  
  static func subpatches(forData data: Data) -> [SynthPath:SysexPatch] {
    var p = [SynthPath:SysexPatch]()
    let sysex = SysexData(data: data)
    
    var voiceData = Data()
    for msg in sysex {
      guard let path = synthPath(forData: msg) else { continue }
      if path == "voice/voice" {
        voiceData.append(msg)
      }
      else {
        guard let addressableType = subpatchTypes[path] else { continue }
        guard addressableType.isValid(sysex: msg) else { continue }
        p[path] = addressableType.init(data: msg)
      }
    }
    
    // make the voice patch if we have the data
    if DX200VoicePatch.isValid(sysex: voiceData) {
      p["voice/voice"] = DX200VoicePatch(data: voiceData)
    }
    
    // for any unfilled subpatches, init them
    for (key, type) in subpatchTypes {
      guard p[key] == nil else { continue }
      p[key] = type.init()
    }
    
    return p
  }
      
  func tempSysexData(deviceId: Int) -> [Data] {
    var data = [Data]()
    type(of: self).subpatchMap.forEach { (path, _) in
      guard let subpatch = subpatches[path] else { return }
      if let subpatch = subpatch as? DX200SinglePatch {
        let address = type(of: subpatch).tempAddress(forSynthPath: path)
        data.append(subpatch.sysexData(deviceId: deviceId, address: address))
      }
      else if let subpatch = subpatch as? DX200VoicePatch {
        data.append(subpatch.sysexData(channel: deviceId))
      }
    }
    return data
  }
    
  /// Get data for writing DX200 subpatches (everything but DX voice) to memory
  func dx200BankSubpatchData(deviceId: Int, location: Int) -> [Data] {
    return type(of: self).subpatchMap.compactMap { (path, _) in
      guard let subpatch = subpatches[path] as? DX200SinglePatch else { return nil }
      return subpatch.bankSysexData(deviceId: deviceId, path: path, index: location)
    }
  }
}



class DX200PatternBank : TypedSysexPatchBank {
  
  static let patchCount = 128
  static let fileDataCount = 312208 // system dump file size
  static let fetchSize: Int = 312128 // THINK this is right...
  // 291200 = 128 patterns (without dx voice. 2275 each)
  //  20928 = 4 dx banks

  static func isValid(fileSize: Int) -> Bool {
    // first 7-byte sysex msg is optional
    // 5232: DX7ii bank (no bank set sysex msg)
    // 5239: DX7ii bank (w bank set sysex)
    // 4104: A DX7 (mkI) bank
    return [fetchSize, fileDataCount, 5232, 5239, 4104].contains(fileSize)
  }
  
  var patches: [DX200PatternPatch]
  
  // TODO: need actual init file
  static let initFileName = "dx200-pattern-bank-init"
  
  static func bankFlagSetData(channel: Int, bank: Int) -> Data {
    return  Data([0xf0, 0x43 , 0x10 + UInt8(channel), 0x62, 0x00, 0x00, 0x0e, UInt8(bank), 0xf7])
  }

  func sysexData(channel: Int) -> Data {
    return sysexDataArray(channel: channel).reduce(Data(), +)
  }
  
  func sysexDataArray(channel: Int) -> [Data] {
    /**
     DX7ii bulk set flag
     DX200 bulk set flag
     AMEM
     VMEM
     (x4)
     
     DX7ii bulk set flag
     DX200 bulk set flad back to 0
     
     Voice Common 1 x 128
     Voice Common 2
     Voice Free EG
     Voice Scene 1
     Voice Scene 2
     Voice Seq
     Rhythm 1 Seq
     Rhythm 2 Seq
     Rhythm 3 Seq
     FX
     Synth Part (note different order!)
     Rhythm 1 Part
     Rhythm 2 Part
     Rhythm 3 Part
     
     */
    var data = [Data]()
    
    (0..<4).forEach { bank in
      data.append(contentsOf: dxVoiceBankData(channel: channel, bank: bank))
    }
    
    data.append(DX200VoiceBank.bankFlagSetData(channel: channel, bank: 0))
    data.append(DX200PatternBank.bankFlagSetData(channel: channel, bank: 0))
    
    type(of: self).subpatchesMap.forEach { path in
      (0..<128).forEach { index in
        let subpatch = patches[index].subpatches[path] as! DX200SinglePatch
        let subdata = subpatch.bankSysexData(deviceId: channel, path: path, index: index)
        data.append(subdata)
      }
    }
    
    return data
  }
  
  // A Pattern Bank contains 4 DX voice banks (AMEM AND VMEM)
  // this data needs to be produced when writing to a file, or when sending partial bank updates
  func dxVoiceBankData(channel: Int, bank: Int) -> [Data] {
    var data = [Data]()
    data.append(DX200VoiceBank.bankFlagSetData(channel: channel, bank: bank))
    data.append(DX200PatternBank.bankFlagSetData(channel: channel, bank: bank))
    
    var aceds = [DX200ACEDPatch]()
    var vceds = [DX7Patch]()
    (0..<32).forEach { pi in
      let patchIndex = pi + (bank * 32)
      let aced = patches[patchIndex].dxPatch.subpatches[[.extra]] as! DX200ACEDPatch
      aceds.append(aced)
      let vced = patches[patchIndex].dxPatch.subpatches[[.voice]] as! DX7Patch
      vceds.append(vced)
    }
    data.append(DX200ACEDBank(patches: aceds).sysexData(channel: channel))
    data.append(DX7VoiceBank(patches: vceds).sysexData(channel: channel))
    return data
  }
  
  static let subpatchesMap: [SynthPath] = [
    [.voice, .common],
    [.common, .extra],
    [.voice, .env],
    [.scene, .i(0)],
    [.scene, .i(1)],
    [.voice, .seq],
    [.rhythm, .i(0)],
    [.rhythm, .i(1)],
    [.rhythm, .i(2)],
    [.voice, .fx],
    [.part, .voice],
    [.part, .i(0)],
    [.part, .i(1)],
    [.part, .i(2)],
    ]

  func fileData() -> Data {
    return sysexData(channel: 0)
  }
  
  /// Default implementation will return true when just first two sysex msgs are received (bc first two together = a TX802 bank)
  static func isCompleteFetch(sysex: Data) -> Bool {
    return sysex.count == fetchSize
  }
  
  required init(data: Data) {
    // TODO: build in support for dx banks
    // TODO: add support for bank from FETCH data which will be similar but missing
    //   the two last bulk flag commands
    
    let sysex = SysexData(data: data)
    var voicePatches = [DX200VoicePatch]()

    if data.count == type(of: self).fetchSize {
      // fetch
      // assume that first 8 msgs are the AMEM/VMEMs
      (0..<4).forEach {
        let amem = sysex[$0 * 2]
        let vmem = sysex[1 + $0 * 2]
        let dxBank = DX200VoiceBank(data: amem + vmem)
        voicePatches.append(contentsOf: dxBank.patches)
      }
    }
    else if data.count == type(of: self).fileDataCount {
      // system dump (file)
      // assume that first 18 msgs are the AMEM/VMEMs
      (0..<4).forEach {
        let amem = sysex[2 + $0 * 4]
        let vmem = sysex[3 + $0 * 4]
        let dxBank = DX200VoiceBank(data: amem + vmem)
        voicePatches.append(contentsOf: dxBank.patches)
      }
    }
    else {
      // dx bank or something
    }
    
    // first put together the data in chunks, then make patches from it
    var sysexDict = [Int:Data]()
    (18..<sysex.count).forEach {
      let d = sysex[$0]
      
      let location = Patch.location(forData: d)
      if sysexDict[location] == nil {
        sysexDict[location] = d
      }
      else {
        sysexDict[location]?.append(d)
      }
    }
    patches = (0..<type(of: self).patchCount).map {
      guard let d = sysexDict[$0] else { return Patch.init() }
      // append dx patch data, then init
      let fullD = d + voicePatches[$0].fileData()
      return Patch.init(data: fullD)
    }

  }
}


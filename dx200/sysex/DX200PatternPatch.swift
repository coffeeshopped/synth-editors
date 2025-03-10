
class DX200PatternPatch : MultiSysexPatch, BankablePatch {
  
  static var bankType: SysexPatchBank.Type = DX200PatternBank.self

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
    get { return subpatches[[.voice, .voice]]?.name ?? "" }
    set { subpatches[[.voice, .voice]]?.name = newValue }
  }
  
  // Specifies order to send in!
  static var subpatchMap: [(SynthPath,SysexPatch.Type)] = [
    ([.scene, .i(0)], DX200VoiceScenePatch.self),
    ([.scene, .i(1)], DX200VoiceScenePatch.self),
    ([.common, .extra], DX200VoiceCommon2Patch.self),
    ([.voice, .common], DX200VoiceCommon1Patch.self),
    ([.voice, .voice], DX200VoicePatch.self), // putting voice after common/scenes so that it sets the LFO speed and porta correctly
    ([.voice, .env], DX200VoiceFreeEnvPatch.self),
    ([.voice, .seq], DX200VoiceSeqPatch.self),
    ([.voice, .fx], DX200RhythmFXPatch.self),
    ([.part, .i(0)], DX200RhythmMultiPartPatch.self),
    ([.part, .i(1)], DX200RhythmMultiPartPatch.self),
    ([.part, .i(2)], DX200RhythmMultiPartPatch.self),
    ([.part, .voice], DX200RhythmMultiPartPatch.self),
    ([.rhythm, .i(0)], DX200RhythmSeqPatch.self),
    ([.rhythm, .i(1)], DX200RhythmSeqPatch.self),
    ([.rhythm, .i(2)], DX200RhythmSeqPatch.self),
  ]
  
  static var subpatchTypes: [SynthPath:SysexPatch.Type] = subpatchMap.dictionary { return [$0.0 : $0.1] }
  
  private static func synthPath(forData data: Data) -> SynthPath? {
    guard data.count >= 9 else { return nil }
    switch data[3] {
    case 0x00, 0x05:
      return [.voice, .voice]
    case 0x62: // voice
      switch data[6] {
      case 0x10: // edit buffer
        switch data[7] {
        case 0x00: return [.voice, .common]
        case 0x01: return [.common, .extra]
        case 0x02: return [.voice, .env]
        case 0x03: return [.scene, .i(0)]
        case 0x04: return [.scene, .i(1)]
        case 0x40: return [.voice, .seq]
        default: return nil
        }
      case 0x20: return [.voice, .common]
      case 0x21: return [.common, .extra]
      case 0x30...0x3f: return [.voice, .env]
      case 0x40: return [.scene, .i(0)]
      case 0x41: return [.scene, .i(1)]
      case 0x50: return [.voice, .seq]
      default: return nil
      }
    case 0x6d: // rhythm
      switch data[6] {
      case 0x02: return [.voice, .fx] // edit buffer
      case 0x08: // edit buffer
        switch data[7] {
        case 0x00: return [.part,.i(0)]
        case 0x01: return [.part, .i(1)]
        case 0x02: return [.part, .i(2)]
        case 0x08: return [.part, .voice]
        default: return nil
        }
      case 0x10: // edit buffer
        switch data[7] {
        case 0x00: return [.rhythm, .i(0)]
        case 0x01: return [.rhythm, .i(1)]
        case 0x02: return [.rhythm, .i(2)]
        default: return nil
        }
      case 0x20: return [.rhythm, .i(0)]
      case 0x21: return [.rhythm, .i(1)]
      case 0x22: return [.rhythm, .i(2)]
      case 0x30: return [.voice, .fx]
      case 0x40: return [.part, .i(0)]
      case 0x41: return [.part, .i(1)]
      case 0x42: return [.part, .i(2)]
      case 0x48: return [.part, .voice]
      default: return nil
      }
    default:
      return nil
    }
  }

  var subpatches: [SynthPath : SysexPatch]

  required init(data: Data) {
    subpatches = type(of: self).subpatches(forData: data)
  }
  
  var dxPatch: DX200VoicePatch {
    return subpatches[[.voice, .voice]] as! DX200VoicePatch
  }
  
  static func subpatches(forData data: Data) -> [SynthPath:SysexPatch] {
    var p = [SynthPath:SysexPatch]()
    let sysex = SysexData(data: data)
    
    var voiceData = Data()
    for msg in sysex {
      guard let path = synthPath(forData: msg) else { continue }
      if path == [.voice, .voice] {
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
      p[[.voice, .voice]] = DX200VoicePatch(data: voiceData)
    }
    
    // for any unfilled subpatches, init them
    for (key, type) in subpatchTypes {
      guard p[key] == nil else { continue }
      p[key] = type.init()
    }
    
    return p
  }
  
  required convenience init(patches: [SynthPath:SysexPatch]) {
    // TODO: we should technically check types here
    self.init()
    subpatches = patches.dictionary { [$0.key : $0.value.copy() ]}
  }
  
  func copy() -> Self {
    return type(of: self).init(patches: subpatches)
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
  
  func fileData() -> Data {
    return Data(tempSysexData(deviceId: 0).joined())
  }
  
  /// Get data for writing DX200 subpatches (everything but DX voice) to memory
  func dx200BankSubpatchData(deviceId: Int, location: Int) -> [Data] {
    return type(of: self).subpatchMap.compactMap { (path, _) in
      guard let subpatch = subpatches[path] as? DX200SinglePatch else { return nil }
      return subpatch.bankSysexData(deviceId: deviceId, path: path, index: location)
    }
  }
}



class DX200Editor : SingleDocSynthEditor, TX802StyleEditor {
    
  var deviceId: Int { return patch(forPath: [.global])?[[.channel]] ?? 0 }
  var channel: Int { return deviceId }

  required init(baseURL: URL) {
    let map: [SynthPath:Sysexible.Type] = [
      [.global] : ChannelSettingsPatch.self,
      [.system] : DX200SystemPatch.self,
      [.patch] : DX200PatternPatch.self,
      [.bank] : DX200PatternBank.self,
    ]
  }
  

  override func sysexible(forPath path: SynthPath) -> Sysexible? {
    guard path == [.voice] else { return super.sysexible(forPath: path) }
    return (patch(forPath: [.patch]) as? DX200PatternPatch)?.dxPatch
  }
  
  override func sysexibleType(path: SynthPath) -> Sysexible.Type? {
    guard path == [.voice] else { return super.sysexibleType(path: path) }
    return DX200VoicePatch.self
  }

  
  // MARK: MIDI I/O
  
  override func fetchCommands(forPath path: SynthPath) -> [RxMidi.FetchCommand]? {
    switch path {
    case [.system]:
      return [
        .request(fetchData(forAddress: [0x6d, 0x00, 0x00, 0x00])), // System 2
        ]
    case [.patch]:
      return [
        // ACED before VCED
        .request(fetchData(forAddress: [0x05])), // ACED
        .wait(0.10),
        .request(fetchData(forAddress: [0x00])), // VCED
        .wait(0.10),
        // Scene 1, 2, Common 2, 1 must be in that order. Rest is up to us
        .request(fetchData(forAddress: [0x62, 0x10, 0x03, 0x00])), // Scene 1
        .wait(0.10),
        .request(fetchData(forAddress: [0x62, 0x10, 0x04, 0x00])), // Scene 2
        .wait(0.10),
        .request(fetchData(forAddress: [0x62, 0x10, 0x01, 0x00])), // Common 2
        .wait(0.10),
        .request(fetchData(forAddress: [0x62, 0x10, 0x00, 0x00])), // Common 1
        .wait(0.10),
        .request(fetchData(forAddress: [0x62, 0x10, 0x02, 0x00])), // Free EG
        .wait(0.10),
        .request(fetchData(forAddress: [0x62, 0x10, 0x40, 0x00])), // Voice Seq
        .wait(0.10),
        .request(fetchData(forAddress: [0x6d, 0x02, 0x01, 0x00])), // FX
        .wait(0.10),
        .request(fetchData(forAddress: [0x6d, 0x08, 0x00, 0x00])), // Rhythm 1 Part
        .wait(0.10),
        .request(fetchData(forAddress: [0x6d, 0x08, 0x01, 0x00])), // Rhythm 2 Part
        .wait(0.10),
        .request(fetchData(forAddress: [0x6d, 0x08, 0x02, 0x00])), // Rhythm 3 Part
        .wait(0.10),
        .request(fetchData(forAddress: [0x6d, 0x08, 0x08, 0x00])), // Voice Part
        .wait(0.10),
        .request(fetchData(forAddress: [0x6d, 0x10, 0x00, 0x00])), // Rhythm 1 Seq
        .wait(0.10),
        .request(fetchData(forAddress: [0x6d, 0x10, 0x01, 0x00])), // Rhythm 2 Seq
        .wait(0.10),
        .request(fetchData(forAddress: [0x6d, 0x10, 0x02, 0x00])), // Rhythm 3 Seq
        .wait(0.10),
      ]

    case [.bank]:
      var commands = [RxMidi.FetchCommand]()
      // first fetch 4 DX banks
      (0..<4).forEach {
        commands.append(contentsOf: TX802Editor.bankFetchCommands(deviceId: deviceId, bank: $0))
      }
      // then fetch all the other shit
      (0..<128).forEach { index in
        let subpatchCommands: [RxMidi.FetchCommand] = DX200PatternBank.subpatchesMap.compactMap { path in
          guard let subpatchType = DX200PatternPatch.subpatchTypes[path] as? DX200SinglePatch.Type else { return nil }
          let address = subpatchType.bankAddress(forSynthPath: path, index: index)
          return .request(fetchData(forAddress: [subpatchType.modelId] + address.sysexBytes(count: 3)))
        }
        commands.append(contentsOf: subpatchCommands)
      }
      
      return commands
    default:
      return nil
    }
  }
  
  
  private func fetchData(forAddress bytes: [UInt8]) -> Data {
    return Data([0xf0, 0x43, 0x20 + UInt8(deviceId)] + bytes + [0xf7])
  }
  
  override func midiOuts() -> [Observable<[Data]?>] {
    var midiOuts = [Observable<[Data]?>]()

    midiOuts.append(system(input: patchStateManager([.system])!.typedChangesOutput()))

    midiOuts.append(pattern(input: patchStateManager([.patch])!.typedChangesOutput()))
    
    midiOuts.append(GenericMidiOut.pushOnlyBank(input: bankStateManager([.bank])!.output, bankTransform: { [weak self] in
      guard let self = self,
        let bank = $0 as? DX200PatternBank else { return nil }
      return bank.sysexDataArray(channel: self.deviceId)
    }))

    return midiOuts
  }
  
  override var sendInterval: TimeInterval { return 0.1 }

  override func midiChannel(forPath path: SynthPath) -> Int {
    return patch(forPath: [.system])?[[.voice, .channel]] ?? 0
  }
  
  static let baseAddresses: [SynthPath:RolandAddress] = {
    var map = [SynthPath:RolandAddress]()
    DX200PatternPatch.subpatchMap.forEach { (path,type) in
      guard let type = type as? DX200SinglePatch.Type else { return }
      map[path] = type.tempAddress(forSynthPath: path)
    }
    return map
  }()

}

extension DX200Editor {
    
  func paramData(subpatch: SysexPatch, subpatchPath: SynthPath, paramPath: SynthPath, value: Int) -> [Data]? {
    guard let baseAddress = type(of: self).baseAddresses[subpatchPath],
      let param = type(of: subpatch).param(paramPath),
      let subpatchType = type(of: subpatch) as? DX200SinglePatch.Type else { return nil }
    let paramAddressBytes = (baseAddress + RolandAddress(param.byte)).sysexBytes(count: 3)
    let valueBytes = param.parm == 0 ? [UInt8(value)] : [UInt8((value >> 7) & 0x7f), UInt8(value & 0x7f)]
    
    var paramData = Data([0xf0, 0x43, 0x10 + UInt8(deviceId), subpatchType.modelId])
    paramData.append(contentsOf: paramAddressBytes)
    paramData.append(contentsOf: valueBytes)
    paramData.append(0xf7)
    return [paramData]
  }

  func system(input: Observable<(PatchChange,DX200SystemPatch, Bool)>) -> Observable<[Data]?> {
    
    return GenericMidiOut.patchChange(throttle: .milliseconds(100), input: input, paramTransform: { [weak self] (patch, path, value) -> [Data]? in
      guard let param = type(of: patch).param(path) else { return nil }
      guard let self = self else { return nil }
      let modelId: UInt8 = path == [.velo, .curve] ? 0x62 : 0x6d
      let valueBytes = param.parm == 0 ? [UInt8(value)] : [UInt8((value >> 7) & 0x7f), UInt8(value & 0x7f)]
      var paramData = Data([0xf0, 0x43, 0x10 + UInt8(self.deviceId), modelId])
      paramData.append(contentsOf: [0x00, 0x00, UInt8(param.byte)])
      paramData.append(contentsOf: valueBytes)
      paramData.append(0xf7)
      return [paramData]

    }, patchTransform: { [weak self] (patch) -> [Data]? in
      guard let self = self else { return nil }
      return [patch.sysexData(deviceId: self.deviceId)]

    }, nameTransform: { (patch, path, name) -> [Data]? in
      return nil
      
    })
  }
  
  
  func pattern(input: Observable<(PatchChange,DX200PatternPatch, Bool)>) -> Observable<[Data]?> {
    
    return GenericMidiOut.multipatchChange(throttle: .milliseconds(100),
                                           input: input, changeThreshold: 16, paramTransform: { [weak self] (subpatch, subpatchPath, paramPath, value) -> [Data]? in
        guard let self = self else { return nil }
        if let subpatch = subpatch as? DX200SinglePatch {
          return self.paramData(subpatch: subpatch, subpatchPath: subpatchPath, paramPath: paramPath, value: value)

        }
        else if let subpatch = subpatch as? TX802VoicePatch {
          if paramPath.first == .extra {
            // ACED
            guard let patch = subpatch.subpatches[[.extra]] as? TX802ACEDPatch,
              let param = type(of: patch).params[paramPath.subpath(from: 1)] else { return nil }
            return [self.acedParamData(paramAddress: param.byte, value: patch.bytes[param.byte])]
          }
          else {
            // Assume VCED
            guard let patch = subpatch.subpatches[[.voice]] as? DX7Patch,
              let param = type(of: patch).params[paramPath.subpath(from: 1)] else { return nil }
            return [self.paramData(param: param, patch: patch)]
          }
        }
        else {
          return nil
        }

    }, patchTransform: { [weak self] (patch) -> [Data]? in
      guard let self = self else { return nil }
      return patch.tempSysexData(deviceId: self.deviceId)
      
    }, subpatchTransform: { [weak self] (subpatch, subpatchPath, patch) -> [Data]? in
      guard let self = self else { return nil }
      if let subpatch = subpatch as? DX200SinglePatch {
        return [subpatch.sysexData(deviceId: self.deviceId, address: type(of: subpatch).tempAddress(forSynthPath: subpatchPath))]
      }
      else if subpatch is TX802VoicePatch {
        // return entire patch! sending only the DX patch re-inits the rest of things (dumb DX200)
        return patch.tempSysexData(deviceId: self.deviceId)
      }
      else {
        return nil
      }
      
    }, nameTransform: { [weak self] (patch, path, name) -> [Data]? in
      guard let self = self else { return nil }
      guard let dx7Patch = patch.dxPatch.subpatches[[.voice]] as? DX7Patch else { return nil }
      return self.voiceNameData(patch: dx7Patch)

    }).map { d in
      guard let datas = d,
        datas.count == 2 &&
        datas.first?.count == 9 &&
        datas.first?[2] == 0x10 + UInt8(self.deviceId) &&
        datas.first?[4] == 0x10,
        let address2 = datas.first?[5],
        let address3 = datas.first?[6] else { return d }
      guard address2 < 0x3 || address2 == 0x40 else { return d }
      guard address3 >= 0x46 && address3 < 0x56 else { return d }
      // if this is a param set for gate bytes, ensure the right order of send
      // swap em
      return [datas[1], datas[0]]
    }

  }
  
}


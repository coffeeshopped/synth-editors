
class VirusTIEditor : SingleDocSynthEditor, VirusEditor {
  
  required init(baseURL: URL) {
    var map: [SynthPath:Sysexible.Type] = [
      [.global] : VirusTIGlobalPatch.self,
      [.patch] : VirusTIVoicePatch.self,
      [.multi] : VirusTIEmbeddedMultiPatch.self,
      [.multi, .bank] : VirusTIEmbeddedMultiBank.self,
    ]
    (0..<4).forEach { map[[.bank, .i($0)]] = VirusTIVoiceBank.self }

    super.init(baseURL: baseURL, sysexMap: map)
  }

    
  // MARK: MIDI I/O
    
  private func embMultiFetchRequest(_ bank: UInt8) -> [RxMidi.FetchCommand] {
    // get multi, then parts
    return [fetchRequest([0x31, bank, 0x00])] + (0..<16).map { fetchRequest([0x30, bank, $0]) }
  }
  
  // Time between send sysex msgs (for push)
  override var sendInterval: TimeInterval { return 0.2 }

  private let delayBetweenFetches: TimeInterval = 0.1
  
  override func fetchCommands(forPath path: SynthPath) -> [RxMidi.FetchCommand]? {
    switch path {
    case [.patch]:
      return [fetchRequest([0x30, 0x00, 0x40])]
    case [.multi]:
      return embMultiFetchRequest(0)
    case [.bank, .i(0)], [.bank, .i(1)], [.bank, .i(2)], [.bank, .i(3)]:
      guard let bankIndex = path.i(1) else { return nil }
      return (0..<128).map { fetchRequest([0x30, UInt8(bankIndex + 1), $0]) }
    case [.multi, .bank]:
      return Array((0..<16).map { embMultiFetchRequest($0 + 32) }.joined())
    default:
      return nil
    }
  }
    
  
  
  override func midiOuts() -> [Observable<[Data]?>] {
    var midiOuts = [Observable<[Data]?>]()

    midiOuts.append(voice(input: patchStateManager([.patch])!.typedChangesOutput()))
    midiOuts.append(multi(input: patchStateManager([.multi])!.typedChangesOutput()))

    (0..<4).forEach { i in
      midiOuts.append(GenericMidiOut.partiallyUpdatableBank(input: bankStateManager([.bank, .i(i)])!.output, patchTransform: {
        guard let patch = $0 as? VirusTIVoicePatch else { return nil }
        return [patch.sysexData(deviceId: self.deviceId, bank: UInt8(i + 1), part: UInt8($1))]
      }))
    }

    midiOuts.append(GenericMidiOut.partiallyUpdatableBank(input: bankStateManager([.multi, .bank])!.output, patchTransform: {
      guard let patch = $0 as? VirusTIEmbeddedMultiPatch else { return nil }
      return patch.sysexData(deviceId: self.deviceId, location: $1)
    }))

    return midiOuts
  }
  
  
  override func midiChannel(forPath path: SynthPath) -> Int {
    return channel
  }

  // MARK: Bank Support

  override func bankPaths(forPatchType patchType: SysexPatch.Type) -> [SynthPath] {
    switch patchType {
    case is VoicePatch.Type:
      return (0..<4).map { [.bank, .i($0)] }
    case is PerfPatch.Type:
      return [[.multi, .bank]]
    default:
      return []
    }
  }

  override func bankTitles(forPatchType patchType: SysexPatch.Type) -> [String] {
    switch patchType {
    case is VoicePatch.Type:
      return (0..<4).map { "Bank " + ["A", "B", "C", "D"][$0] }
    case is PerfPatch.Type:
      return ["Multi"]
    default:
      return []
    }
  }
  
  override func bankIndexLabelBlock(forPath path: SynthPath) -> ((Int) -> String)? {
    if let bankIndex = path.i(1) {
      return {
        let b = ["A", "B", "C", "D"][bankIndex]
        return "\(b)\($0)"
      }
    }
    else {
      return { "\($0)" }
    }
  }


}

extension VirusTIEditor {

  /// Transform <patchChange, patch> into MIDI out data
  func voice(input: Observable<(PatchChange, VirusTIVoicePatch, Bool)>) -> Observable<[Data]?> {
    
    return GenericMidiOut.patchChange(throttle: .milliseconds(100), input: input, paramTransform: { (patch, path, value) -> [Data]? in
      guard let param = type(of: patch).params[path] else { return nil }
      
      let section = param.byte / 128 // should be 0...3
      let cmdByte: UInt8 = [0x70, 0x71, 0x6e, 0x6f][section]
      let cmdBytes = self.sysexCommand([cmdByte, 0x40, UInt8(param.byte % 128), UInt8(value)])
      return [Data(cmdBytes)]

    }, patchTransform: { (patch) -> [Data]? in
      return self.tempPatchData(patch: patch)

    }) { (patch, path, name) -> [Data]? in
      // batch as a single data so that it doesn't get .wait()s interleaved
      return [Data(patch.nameBytes.enumerated().map {
        Data(self.sysexCommand([0x71, 0x40, UInt8(0x70 + $0.offset), $0.element]))
      }.joined())]
    }
  }
  
  private func tempPatchData(patch: VirusTIVoicePatch) -> [Data] {
    return [patch.sysexData(deviceId: deviceId, bank: 0, part: 0x40)]
  }
  
  func multi(input: Observable<(PatchChange, VirusTIEmbeddedMultiPatch, Bool)>) -> Observable<[Data]?> {
    
    return GenericMidiOut.patchChange(throttle: .milliseconds(100), input: input, paramTransform: { (patch, path, value) -> [Data]? in
      let cmdByte: UInt8
      let part: Int
      let parm: Int
      switch path[0] {
      case .common:
        let subpath = path.subpath(from: 1)
        guard let param = VirusTIMultiPatch.params[subpath] else { return nil }
        part = subpath.i(1) ?? 0
        cmdByte = 0x72
        parm = param.parm
      default:
        let subpath = path.subpath(from: 2)
        guard let param = VirusTIVoicePatch.params[subpath] else { return nil }
        part = path.i(1) ?? 0
        let section = param.byte / 128 // should be 0...3
        cmdByte = [0x70, 0x71, 0x6e, 0x6f][section]
        parm = param.byte % 128
      }
      
      let cmdBytes = self.sysexCommand([cmdByte, UInt8(part), UInt8(parm), UInt8(value)])
      return [Data(cmdBytes)]

    }, patchTransform: { (patch) -> [Data]? in
      return self.tempMultiData(patch: patch)

    }) { (patch, path, name) -> [Data]? in
      let cmdByte: UInt8
      let part: Int
      let parm: Int
      switch path.first {
      case nil:
        part = 0
        cmdByte = 0x72
        parm = 0x04
      default:
        part = path.i(1) ?? 0
        cmdByte = 0x71
        parm = 0x70
      }
      
      // both voice and multi have 10-char names
      return [Data(name.bytes(forCount: 10).enumerated().map {
        Data(self.sysexCommand([cmdByte, UInt8(part), UInt8(parm + $0.offset), $0.element]))
      }.joined())]
    }
  }
  
  private func tempMultiData(patch: VirusTIEmbeddedMultiPatch) -> [Data] {
    return patch.sysexData(deviceId: deviceId, location: -1)
  }
  
}



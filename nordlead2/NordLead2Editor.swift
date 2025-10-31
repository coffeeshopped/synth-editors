
class NordLead2Editor : SingleDocSynthEditor {
  
  static let slotNames = ["A","B","C","D"]
  
  required init(baseURL: URL) {
    var map: [SynthPath:Sysexible.Type] = [
      [.perf] : NordLead2PerfPatch.self,
    ]
    (0..<4).forEach { map[[.bank, .voice, .i($0)]] = NordLead2VoiceBank.self }
  }
  
  private var perfManager: PatchStateManager? {
    return patchStateManager([.perf])
  }
  
  private var perfPatch: NordLead2PerfPatch? {
    return patch(forPath: [.perf]) as? NordLead2PerfPatch
  }
  
  var deviceId: Int {
    return patch(forPath: [.perf])?[[.deviceId]] ?? 0
  }
  
  override func sysexible(forPath path: SynthPath) -> Sysexible? {
    guard path.first == .part,
      let part = path.i(1) else { return super.sysexible(forPath: path)}
    return perfPatch?.patch(location: part)
  }
  
  override func sysexibleType(path: SynthPath) -> Sysexible.Type? {
    guard path.first == .part else { return super.sysexibleType(path: path) }
    return NordLead2VoicePatch.self
  }

  override func changePatch(forPath path: SynthPath, _ change: PatchChange, transmit: Bool) {
    guard path.first == .part, let part = path.i(1) else {
      return super.changePatch(forPath: path, change, transmit: transmit)
    }
    
    let pc: PatchChange
    switch change {
    case .push:
      guard let patch = perfPatch?.patch(location: part) else { return }
      pc = .replace(patch)
    default:
      pc = change
    }
    perfManager?.patchChangesInput.value = (pc.prefixed([.patch, .i(part)]), true)
  }
  
  override func patchChangesOutput(forPath path: SynthPath) -> Observable<(PatchChange,SysexPatch?)>? {
    guard path.first == .part,
      let part = path.i(1) else { return super.patchChangesOutput(forPath: path) }
    return perfManager?.output.map {
      let pc = $0.0.filtered(forPrefix: [.patch, .i(part)])
      let patch = ($0.1 as? NordLead2PerfPatch)?.patch(location: part)
      return (pc, patch)
    }
  }

  // MARK: MIDI I/O
  
  fileprivate var sysexHeader: Data {
    return Data([0xf0, 0x33, UInt8(deviceId), 0x04])
  }
  
  override func fetchCommands(forPath path: SynthPath) -> [RxMidi.FetchCommand]? {
    switch path[0] {
    case .perf:
      return [.request(sysexHeader + Data([0x28, 0x00, 0xf7]))]
    case .part:
      guard let part = path.i(1) else { return nil }
      return [.request(sysexHeader + Data([0x0a, UInt8(part), 0xf7]))]
    case .bank:
      if path[1] == .voice {
        guard let i = path.i(2) else { return nil }
        return (0..<99).map { .request(sysexHeader + Data([0x0b + UInt8(i), $0, 0xf7])) }
      }
    default:
      return nil
    }
    return nil
  }
    
  private func filteredPerfDocOutput(part: Int) -> Observable<(PatchChange, NordLead2PerfPatch, Bool)> {
    return perfManager!.typedChangesOutput().filter {
      // no-param change is for priming
      guard case let .paramsChange(params) = $0.0 else { return true }
      for (path,_) in params {
        guard path.starts(with: [.patch, .i(part)]) else { return false }
      }
      return true
    }
  }
  
  override func midiOuts() -> [Observable<[Data]?>] {
    var midiOuts = [Observable<[Data]?>]()
    
    midiOuts.append(perf(input: perfManager!.typedChangesOutput().filter {
      // no-param change is for priming
      guard case let .paramsChange(params) = $0.0 else { return true }
      for (path,_) in params {
        guard !path.starts(with: [.patch]) else { return false }
      }
      return true
      }))
    
    (0..<4).forEach {
      midiOuts.append(part(location: $0, input: filteredPerfDocOutput(part: $0)))
    }
    
    (0..<4).forEach { i in
      midiOuts.append(GenericMidiOut.partiallyUpdatableBank(input: bankStateManager([.bank, .voice, .i(i)])!.output) {
        guard let patch = $0 as? NordLead2VoicePatch else { return nil }
      })
    }

    return midiOuts
  }
  
  
  override func midiChannel(forPath path: SynthPath) -> Int {
    return perfPatch?[path + [.channel]] ?? 0
  }
  
}


class NordLead2XEditor : NordLead2Editor {
  
  override func fetchCommands(forPath path: SynthPath) -> [RxMidi.FetchCommand]? {
    switch path[0] {
    case .perf:
      return [.request(sysexHeader + Data([0x28, 0x00, 0xf7]))]
    case .part:
      guard let part = path.i(1) else { return nil }
      // it's 0E(!) for Nord Lead 2X...
      return [.request(sysexHeader + Data([0x0e, UInt8(part), 0xf7]))]
    case .bank:
      if path[1] == .voice {
        guard let i = path.i(2) else { return nil }
        return (0..<99).map { .request(sysexHeader + Data([0x0b + UInt8(i), $0, 0xf7])) }
      }
    default:
      return nil
    }
    return nil
  }

}



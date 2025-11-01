
protocol NordLead2Patch : ByteBackedSysexPatch { }
extension NordLead2Patch {
  
  static func combinedBytes(forData data: Data) -> [UInt8] {
    var bytes = [UInt8]()
    let d = Data(data) // could be a slice, so copy it
    for i in (0..<d.count) where i % 2 == 0 {
      bytes.append(d[i] + (d[i+1] << 4))
    }
    return bytes
  }

  static func dataSetHeader(deviceId: Int, bank: Int, location: Int) -> Data {
    return Data([0xf0, 0x33, UInt8(deviceId), 0x04, UInt8(bank), UInt8(location)])
  }
  

  static func split(bytes: ArraySlice<UInt8>) -> [UInt8] {
    return [UInt8](bytes.map{ [UInt8($0.bits(0...3)), UInt8($0.bits(4...7))] }.joined())
  }

  static func split(bytes: [UInt8]) -> [UInt8] {
    return [UInt8](bytes.map{ [UInt8($0.bits(0...3)), UInt8($0.bits(4...7))] }.joined())
  }
  
  func sysexData(deviceId: Int, bank: Int, location: Int) -> Data {
    var data = type(of: self).dataSetHeader(deviceId: deviceId, bank: bank, location: location)
    data.append(contentsOf: type(of: self).split(bytes: bytes))
    data.append(0xf7)
    return data
  }
  
}

const fetchBytes = (bytes) => [0xf0, 0x33, 'deviceId', 0x04, bytes, 0xf7]
const fetchCmd = (bytes) => ['truss', fetchBytes(bytes)]

const editor = {
  name: "",
  trussMap: ([
    ['perf', Perf.patchTruss],
  ]).concat(
    (4).map(i => [["bank/voice", i], Voice.bankTruss])
  ),
  fetchTransforms: ([
    ['perf', fetchCmd([0x28, 0x00])],
  ]).concat(
    (4).map(i => [["bank/voice", i], ['bankTruss', fetchBytes([0x0b + i, 'b'])]]),
    (4).map(i => [["part", i], fetchCmd([0x0a, i])])
  ),
  midiOuts: [
  ],
  
  midiOuts.append(perf(input: perfManager!.typedChangesOutput().filter {
    // no-param change is for priming
    guard case let .paramsChange(params) = $0.0 else { return true }
    for (path,_) in params {
      guard !path.starts(with: "patch") else { return false }
    }
    return true
    }))
  
  (0..<4).forEach {
    midiOuts.append(part(location: $0, input: filteredPerfDocOutput(part: $0)))
  }
  
  (0..<4).forEach { i in
    midiOuts.append(GenericMidiOut.partiallyUpdatableBank(input: bankStateManager("bank/voice/i")!.output) {
      guard let patch = $0 as? NordLead2VoicePatch else { return nil }
    })
  }
  
  midiChannels: [
    ["voice", "basic"],
  ],
  slotTransforms: [
  ],
}



class NordLead2Editor : SingleDocSynthEditor {
  
  static let slotNames = ["A","B","C","D"]
  
  private var perfManager: PatchStateManager? {
    return patchStateManager("perf")
  }
  
  private var perfPatch: NordLead2PerfPatch? {
    return patch(forPath: "perf") as? NordLead2PerfPatch
  }
  
  var deviceId: Int {
    return patch(forPath: "perf")?["deviceId"] ?? 0
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
    perfManager?.patchChangesInput.value = (pc.prefixed("patch/part"), true)
  }
  
  override func patchChangesOutput(forPath path: SynthPath) -> Observable<(PatchChange,SysexPatch?)>? {
    guard path.first == .part,
      let part = path.i(1) else { return super.patchChangesOutput(forPath: path) }
    return perfManager?.output.map {
      let pc = $0.0.filtered(forPrefix: "patch/part")
      let patch = ($0.1 as? NordLead2PerfPatch)?.patch(location: part)
      return (pc, patch)
    }
  }
    
  private func filteredPerfDocOutput(part: Int) -> Observable<(PatchChange, NordLead2PerfPatch, Bool)> {
    return perfManager!.typedChangesOutput().filter {
      // no-param change is for priming
      guard case let .paramsChange(params) = $0.0 else { return true }
      for (path,_) in params {
        guard path.starts(with: "patch/part") else { return false }
      }
      return true
    }
  }
  
  override func midiChannel(forPath path: SynthPath) -> Int {
    return perfPatch?[path + "channel"] ?? 0
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



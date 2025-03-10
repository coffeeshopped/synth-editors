
class MicrokorgEditor : SingleDocSynthEditor {
    
  var channel: Int { return patch(forPath: [.global])?[[.channel]] ?? 0 }

  required init(baseURL: URL) {
    let map: [SynthPath:Sysexible.Type] = [
      [.global] : MicrokorgGlobalPatch.self,
      [.patch] : MicrokorgPatch.self,
      [.bank] : MicrokorgBank.self,
    ]

    let migrationMap: [SynthPath:String] = [
      [.patch] : "Voice.syx",
      [.bank] : "Bank.syx",
    ]

    super.init(baseURL: baseURL, sysexMap: map, migrationMap: migrationMap)
  }
    
  // MARK: MIDI I/O
  
  private func fetchCommand(functionID: UInt8) -> [RxMidi.FetchCommand] {
    return [.request(Data([0xf0, 0x42, 0x30 + UInt8(channel), 0x58, functionID, 0xf7]))]
  }
  
  override func fetchCommands(forPath path: SynthPath) -> [RxMidi.FetchCommand]? {
    switch path[0] {
    case .global:
      return fetchCommand(functionID: 0x0e)
    case .patch:
      return fetchCommand(functionID: 0x10)
    case .bank:
      // looks like for microkorg s, fetch is:
      // F0 42 30 00 01 40 10 F7
      return fetchCommand(functionID: 0x1c)
    default:
      return nil
    }
  }
  
  override func midiOuts() -> [Observable<[Data]?>] {
    var midiOuts = [Observable<[Data]?>]()
    midiOuts.append(global(input: patchStateManager([.global])!.typedChangesOutput()))
    midiOuts.append(voice(input: patchStateManager([.patch])!.typedChangesOutput()))
    midiOuts.append(bank(input: bankStateManager([.bank])!.typedChangesOutput()))
    return midiOuts
  }
  
  override func midiChannel(forPath path: SynthPath) -> Int {
    return channel
  }
  
  override func bankPaths(forPatchType patchType: SysexPatch.Type) -> [SynthPath] {
    switch patchType {
    case is MicrokorgPatch.Type:
      return [[.bank]]
    default:
      return []
    }
  }
  
  override func bankTitles(forPatchType patchType: SysexPatch.Type) -> [String] {
    switch patchType {
    case is MicrokorgPatch.Type:
      return ["Voice Bank"]
    default:
      return []
    }
  }
  
  override func bankIndexLabelBlock(forPath path: SynthPath) -> ((Int) -> String)? {
    return {
      let letter = $0 < 64 ? "A" : "B"
      let bank = ($0 % 64) / 8 + 1
      let slot = $0 % 8 + 1
      return "\(letter)\(bank)\(slot)"
    }
  }

}

extension MicrokorgEditor {

  func global(input: Observable<(PatchChange, MicrokorgGlobalPatch, Bool)>) -> Observable<[Data]?> {
    return GenericMidiOut.wholePatchChange(throttle: .milliseconds(1000), input: input) { [$0.sysexData(channel: 0)] }
  }

  static let arpGateMap = [0, 0, 1, 2, 3, 3, 4, 5, 6, 7, 7, 8, 9, 10, 11, 11, 12, 13, 14, 14, 15, 16, 17, 18, 18, 19, 20, 21, 22, 22, 23, 24, 25, 26, 26, 27, 28, 29, 29, 30, 31, 32, 33, 33, 34, 35, 36, 37, 37, 38, 39, 40, 41, 41, 42, 43, 44, 44, 45, 46, 47, 48, 48, 49, 50, 51, 52, 52, 53, 54, 55, 56, 56, 57, 58, 59, 59, 60, 61, 62, 63, 63, 64, 65, 66, 67, 67, 68, 69, 70, 71, 71, 72, 73, 74, 74, 75, 76, 77, 78, 78, 79, 80, 81, 82, 82, 83, 84, 85, 86, 86, 87, 88, 89, 89, 90, 91, 92, 93, 93, 94, 95, 96, 97, 97, 98, 99, 100]
  
  static let semitoneMap = [-24, -24, -24, -23, -23, -23, -22, -22, -21, -21, -21, -20, -20, -20, -19, -19, -18, -18, -18, -17, -17, -16, -16, -16, -15, -15, -15, -14, -14, -13, -13, -13, -12, -12, -11, -11, -11, -10, -10, -10, -9, -9, -8, -8, -8, -7, -7, -7, -6, -6, -5, -5, -5, -4, -4, -3, -3, -3, -2, -2, -2, -1, -1, 0, 0, 0, 1, 1, 2, 2, 2, 3, 3, 3, 4, 4, 5, 5, 5, 6, 6, 7, 7, 7, 8, 8, 8, 9, 9, 10, 10, 10, 11, 11, 11, 12, 12, 13, 13, 13, 14, 14, 15, 15, 15, 16, 16, 16, 17, 17, 18, 18, 18, 19, 19, 20, 20, 20, 21, 21, 21, 22, 22, 23, 23, 23, 24, 24]
  
  /// Transform <channel, patchChange, patch> into MIDI out data
  func voice(input: Observable<(PatchChange, MicrokorgPatch, Bool)>) -> Observable<[Data]?> {
    return GenericMidiOut.patchChange(throttle: .milliseconds(100), input: input) { (patch, path, value) -> [Data]? in
      guard let param = MicrokorgPatch.params[path] else { return nil }
      if param.parm > 0 {
        // if parm > 0, use NRPN
        // not using Midi.nrpn bc of the way values were stored in param.parm
        let outValue: Int
        if path == [.arp, .on] || path == [.arp, .latch] {
          outValue = value * 0x40
        }
        else if path == [.arp, .type] {
          outValue = value * 0x16
        }
        else if path == [.arp, .gate, .time] {
          outValue = Self.arpGateMap.firstIndex(of: value) ?? 0
        }
        else if path.last == .src || path.last == .dest {
          outValue = value * 0x10
        }
        else {
          outValue = value
        }
        return [
          Data(Midi.cc(99, value: (param.parm >> 8) & 0x7f, channel: self.channel) +
               Midi.cc(98, value: param.parm & 0x7f, channel: self.channel) +
               Midi.cc(6, value: outValue, channel: self.channel))
        ]
//        return [Data(Midi.nrpn(param.parm, value: value, channel: self.channel))]
      }
      else if param.parm < 0 {
        // if < 0, look for ctrl # in Global
        guard let g = self.patch(forPath: [.global]),
              let cc = g[[.ctrl, .i(param.parm * -1)]] else { return [patch.sysexData(channel: self.channel)] }

        // select timbre if needed
        let selData: Data
        if path.starts(with: [.tone, .i(0)]) {
          selData = Data(Midi.cc(95, value: 0, channel: self.channel))
        }
        else if path.starts(with: [.tone, .i(1)]) {
          selData = Data(Midi.cc(95, value: 2, channel: self.channel))
        }
        else {
          selData = Data()
        }
          
        let outValue: Int
        if path.suffix(4) == [.osc, .i(0), .wave, .mode] {
          outValue = value * 0x10
        }
        else if path.suffix(3) == [.osc, .i(0), .wave] {
          outValue = value * 2
        }
        else if path.suffix(3) == [.osc, .i(1),  .wave] {
          outValue = value * 63
        }
        else if path.suffix(2) == [.mod, .select] {
          outValue = value * 0x20
        }
        else if path.last == .semitone {
          outValue = Self.semitoneMap.firstIndex(of: value - 64) ?? 0
        }
        else if path.suffix(2) == [.filter, .type] {
          outValue = value * 0x20
        }
        else if path.suffix(2) == [.formant, .shift] {
          outValue = value * 26
        }
        else if path.last == .dist {
          outValue = value * 0x40
        }
        else if path.suffix(3) == [.lfo, .i(0), .wave] {
          outValue = value * 0x20
        }
        else if path.suffix(3) == [.lfo, .i(0), .sync, .note] || path.suffix(3) == [.lfo, .i(1), .sync, .note] {
          outValue = value * 9
        }
        else if path.suffix(3) == [.lfo, .i(1), .wave] {
          outValue = value * 0x20
        }
        else if path == [.delay, .sync, .note] {
          outValue = value * 9
        }
        else {
          outValue = value
        }
        return [selData + Data(Midi.cc(cc, value: outValue, channel: self.channel))]
      }
      else {
        // else send whole patch
        return [patch.sysexData(channel: self.channel)]
      }
    } patchTransform: { (patch) -> [Data]? in
      return [patch.sysexData(channel: self.channel)]
    } nameTransform: { (patch, path, name) -> [Data]? in
      return [patch.sysexData(channel: self.channel)]
    }
  }
  
  func bank(input: Observable<(BankChange,MicrokorgBank, Bool)>) -> Observable<[Data]?> {
    return input.map { [weak self] (bankChange, bank, transmit) in
      guard transmit, let self = self else { return nil }
      switch bankChange {
      case .patchChange(let patches):
        let d: [[Data]] = patches.compactMap {
          guard let patch = $0.value as? MicrokorgPatch else { return nil }
          return [patch.sysexData(channel: self.channel), self.programWriteData(location: $0.key)] as [Data]
        }
        return [Data](d.joined())
      case .patchSwap(let i1, let i2):
        // patches are already swapped in the bank itself; we're just pushing out the updated bank info
        // hence no swapping happening here.
        var data = [bank.patches[i1].sysexData(channel: self.channel)]
        data.append(self.programWriteData(location: i1))
        data.append(bank.patches[i2].sysexData(channel: self.channel))
        data.append(self.programWriteData(location: i2))
        return data
      case .replace(_), .push:
        return [bank.sysexData(channel: self.channel)]
      case .nameChange(_):
        return nil
      }
    }
  }
  
  func programWriteData(location: Int) -> Data {
    return Data([0xf0, 0x42, 0x30 + UInt8(channel), 0x58, 0x11, 0x00, UInt8(location), 0xf7])
  }
  
}

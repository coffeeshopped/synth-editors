
class MS2KEditor : SingleDocSynthEditor {
  
  var channel: Int { return patch(forPath: [.global])?[[.channel]] ?? 0 }

  required init(baseURL: URL) {
    let map: [SynthPath:Sysexible.Type] = [
      [.global] : ChannelSettingsPatch.self,
      [.patch] : MS2KPatch.self,
      [.bank] : MS2KBank.self,
    ]

    let migrationMap: [SynthPath:String] = [
      [.global] : "Global.json",
      [.patch] : "Voice.syx",
      [.bank] : "Bank.syx",
    ]

    super.init(baseURL: baseURL, sysexMap: map, migrationMap: migrationMap)
  }

  // MARK: MIDI I/O
  
  override func fetchCommands(forPath path: SynthPath) -> [RxMidi.FetchCommand]? {
    switch path[0] {
    case .patch:
      return [.request(Data([0xf0, 0x42, 0x30 + UInt8(channel), 0x58, 0x10, 0xf7])),
              .send(editModeSysex())]
    case .bank:
      return [.request(Data([0xf0, 0x42, 0x30 + UInt8(channel), 0x58, 0x1c, 0xf7]))]
    default:
      return nil
    }
  }
  
  private func editModeSysex() -> Data {
    // sysex for entering edit mode
    return Data([0xf0, 0x42, 0x30 + UInt8(channel), 0x58, 0x4e, 0x01, 0x00, 0xf7])
  }
  
  override func midiOuts() -> [Observable<[Data]?>] {
    var midiOuts = [Observable<[Data]?>]()
    
    midiOuts.append(voice(input: patchStateManager([.patch])!.typedChangesOutput()))

    midiOuts.append(bank(input: bankStateManager([.bank])!.typedChangesOutput()))

    return midiOuts
  }
  
  override func midiChannel(forPath path: SynthPath) -> Int {
    return channel
  }
  
  override func bankPaths(forPatchType patchType: SysexPatch.Type) -> [SynthPath] {
    switch patchType {
    case is MS2KPatch.Type:
      return [[.bank]]
    default:
      return []
    }
  }
  
  override func bankTitles(forPatchType patchType: SysexPatch.Type) -> [String] {
    switch patchType {
    case is MS2KPatch.Type:
      return ["Voice Bank"]
    default:
      return []
    }
  }
  
}

extension MS2KEditor {
  
  /// Transform <channel, patchChange, patch> into MIDI out data
  func voice(input: Observable<(PatchChange, MS2KPatch, Bool)>) -> Observable<[Data]?> {
    
    return GenericMidiOut.patchChange(throttle: .milliseconds(100), input: input, paramTransform: { [weak self] (patch, path, value) -> [Data]? in
      guard let param = type(of: patch).params[path] else { return nil }
      guard let self = self else { return nil }
      let v = (param as? RangeParam)?.displayOffset == -64 ? value - 64 : value
      return [self.paramData(paramAddress: param.parm, value: v)]

    }, patchTransform: { [weak self] (patch) -> [Data]? in
      guard let self = self else { return nil }
      return [patch.sysexData(channel: self.channel)]

    }) { [weak self] (patch, path, name) -> [Data]? in
      guard let self = self else { return nil }
      return MS2KPatch.nameByteRange.map {
        self.paramData(paramAddress: $0, value: Int(patch.bytes[$0]))
        }

    }
  }
  
  private func paramData(paramAddress: Int, value: Int) -> Data {
    var data = Data([0xf0, 0x42, 0x30 + UInt8(channel), 0x58, 0x41])
    let b1 = UInt8(value & 0x7f)
    let b2 = UInt8((value >> 7) & 0x7f)
    data.append(contentsOf: [UInt8(paramAddress & 0x7f), UInt8((paramAddress >> 7) & 0x7f), b1, b2])
    data.append(0xf7)
    return data
  }
  
  
  func bank(input: Observable<(BankChange, MS2KBank, Bool)>) -> Observable<[Data]?> {
    return input.map { [weak self] (bankChange, bank, transmit) in
      guard transmit, let self = self else { return nil }
      switch bankChange {
      case .patchChange(let patches):
        let d: [[Data]] = patches.compactMap {
          guard let patch = $0.value as? MS2KPatch else { return nil }
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



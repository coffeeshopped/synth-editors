
// MKS-50: 128 tones / 128 patches (tone + perf ctrl) all writeable

protocol MKS50TypeEditor : SingleDocSynthEditor {
  var channel: Int { get }
}

class MKS50Editor : SingleDocSynthEditor, MKS50TypeEditor {
    
  var channel: Int { return patch(forPath: [.global])?[[.channel]] ?? 0 }

  required init(baseURL: URL) {
    let map: [SynthPath:Sysexible.Type] = [
      [.global] : ChannelSettingsPatch.self,
      [.tone] : AlphaJunoVoicePatch.self,
      [.bank, .tone, .i(0)] : AlphaJunoVoiceBank.self,
      [.bank, .tone, .i(1)] : AlphaJunoVoiceBank.self,
      [.patch] : MKS50PatchPatch.self,
      [.bank, .patch, .i(0)] : MKS50PatchBank.self,
      [.bank, .patch, .i(1)] : MKS50PatchBank.self,
      [.chord] : MKS50ChordPatch.self,
      [.bank, .chord] : MKS50ChordBank.self,
    ]

    let migrationMap: [SynthPath:String] = [
      [.global] : "Global.json",
      [.tone] : "Tone.syx",
      [.bank, .tone, .i(0)] : "Tone Bank 1.syx",
      [.bank, .tone, .i(1)] : "Tone Bank 2.syx",
      [.patch] : "Patch.syx",
      [.bank, .patch, .i(0)] : "Patch Bank 1.syx",
      [.bank, .patch, .i(1)] : "Patch Bank 2.syx",
      [.chord] : "Chord.syx",
      [.bank, .chord] : "Chord Bank.syx",
    ]

    super.init(baseURL: baseURL, sysexMap: map, migrationMap: migrationMap)
    load { [weak self] in
      self?.initPerfParamsOutput()
    }
  }
  
  // MARK: MIDI I/O
  
  override func fetchCommands(forPath path: SynthPath) -> [RxMidi.FetchCommand]? {
    switch path {
    case [.tone]:
      return [.requestMsg(.sysex([0xf0, 0xf7]), .gtEq(54))]
    case [.bank, .tone, .i(0)], [.bank, .tone, .i(1)]:
      return [.requestMsg(.sysex([0xf0, 0xf7]), .gtEq(4256))]
    case [.patch]:
      return [.requestMsg(.sysex([0xf0, 0xf7]), .gtEq(31))]
    case [.bank, .patch, .i(0)], [.bank, .patch, .i(1)]:
      return [.requestMsg(.sysex([0xf0, 0xf7]), .gtEq(4256))]
    case [.chord]:
      return [.requestMsg(.sysex([0xf0, 0xf7]), .gtEq(14))]
    case [.bank, .chord]:
      return [.requestMsg(.sysex([0xf0, 0xf7]), .gtEq(202))]
    default:
      return nil
    }
  }

  private var voiceParamsOutput: Observable<SynthPathParam>?

  private var perfDisposeBag: DisposeBag?
      
  private func initPerfParamsOutput() {
    perfDisposeBag = DisposeBag()
    
    if let params = super.paramsOutput(forPath: [.patch]) {
      let bankMaps: [Observable<SynthPathParam>] = (0..<2).map {
        let bankOut = bankChangesOutput(forPath: [.bank, .tone, .i($0)])!
        let letter = ["a", "b"][$0]
        return EditorHelper.bankNameOptionsMap(output: bankOut, path: [.tone, .name, .i($0)]) {
          "\(letter)\(1 + $0 / 8)\(1 + $0 % 8): \($1)"
        }
      }
      voiceParamsOutput = Observable.merge(bankMaps + [params])
    }
  }
  
  override func paramsOutput(forPath path: SynthPath) -> Observable<SynthPathParam>? {
    switch path {
    case [.patch]:
      return voiceParamsOutput
    default:
      return super.paramsOutput(forPath: path)
    }
  }
  
  override func midiOuts() -> [Observable<[Data]?>] {
    var midiOuts = [Observable<[Data]?>]()

    midiOuts.append(voiceOut(input: patchStateManager([.tone])!.typedChangesOutput()))
    midiOuts.append(patchOut(input: patchStateManager([.patch])!.typedChangesOutput()))
    
    midiOuts.append(GenericMidiOut.wholePatchChange(throttle: .milliseconds(30), input: patchStateManager([.chord])!.output, patchTransform: {
      guard let patch = $0 as? MKS50ChordPatch else { return nil }
      return [patch.sysexData(channel: self.channel)]
    }))

    (0..<2).forEach { bank in
      midiOuts.append(GenericMidiOut.pushOnlyBank(input: bankStateManager([.bank, .tone, .i(bank)])!.output, bankTransform: {
        guard let b = $0 as? AlphaJunoVoiceBank else { return nil }
        return b.sysexData(channel: self.channel)
      }))
    }

    (0..<2).forEach { bank in
      midiOuts.append(GenericMidiOut.pushOnlyBank(input: bankStateManager([.bank, .patch, .i(bank)])!.output, bankTransform: {
        guard let b = $0 as? MKS50PatchBank else { return nil }
        return b.sysexData(channel: self.channel)
      }))
    }

    midiOuts.append(GenericMidiOut.pushOnlyBank(input: bankStateManager([.bank, .chord])!.output, bankTransform: {
      guard let b = $0 as? MKS50ChordBank else { return nil }
      return [b.sysexData(channel: self.channel)]
    }))

    return midiOuts // interval 0.2 ?
  }
  
  override func midiChannel(forPath path: SynthPath) -> Int { return channel }

  override func bankPaths(forPatchType patchType: SysexPatch.Type) -> [SynthPath] {
    switch patchType {
    case is AlphaJunoVoicePatch.Type:
      return [[.bank, .tone, .i(0)], [.bank, .tone, .i(1)]]
    case is MKS50PatchPatch.Type:
      return [[.bank, .patch, .i(0)], [.bank, .patch, .i(1)]]
    case is MKS50ChordPatch.Type:
      return [[.bank, .chord]]
    default:
      return []
    }
  }
  
  override func bankTitles(forPatchType patchType: SysexPatch.Type) -> [String] {
    switch patchType {
    case is AlphaJunoVoicePatch.Type:
      return ["Tone Bank a", "Tone Bank b"]
    case is MKS50PatchPatch.Type:
      return ["Patch Bank A", "Patch Bank B"]
    case is MKS50ChordPatch.Type:
      return ["Chord Bank"]
    default:
      return []
    }
  }

  override func bankIndexLabelBlock(forPath path: SynthPath) -> ((Int) -> String)? {
    switch path {
    case [.bank, .chord]:
      return { "\($0 + 1)" }
    default:
      return { "\(($0 / 8) + 1)\(($0 % 8) + 1)" }
    }
  }

}

// MARK: Midi Out

extension MKS50TypeEditor {


  
  func voiceOut(input: Observable<(PatchChange, AlphaJunoVoicePatch, Bool)>) -> Observable<[Data]?> {
    
    return GenericMidiOut.patchChange(throttle: .milliseconds(20), input: input, paramTransform: { (patch, path, value) -> [Data]? in
      guard let param = type(of: patch).params[path] else { return nil }
      let v = (param as? RangeParam)?.range.upperBound == 15 ? value << 3 : value
      return [Data([0xf0, 0x41, 0x36, UInt8(self.channel), 0x23, 0x20, 0x01, UInt8(param.parm), UInt8(v), 0xf7])]
      
    }, patchTransform: { (patch) -> [Data]? in
      return [patch.sysexData(channel: self.channel)]

    }, nameTransform: { (patch, path, name) -> [Data]? in
      return [patch.sysexData(channel: self.channel)]

    })
  }
  
  func patchOut(input: Observable<(PatchChange, MKS50PatchPatch, Bool)>) -> Observable<[Data]?> {
    return GenericMidiOut.patchChange(throttle: .milliseconds(20), input: input, paramTransform: { (patch, path, value) -> [Data]? in
      guard let param = type(of: patch).params[path] else { return nil }
      let v: Int
      switch param.parm {
      case 9:
        // multiple params in param 9
        var byte = 0
        MKS50PatchPatch.params.filter { $0.value.parm == 9 }.forEach {
          byte = byte.set(bit: $0.value.bits!.lowerBound, value: 1 - patch[$0.key]!)
        }
        v = byte
      default:
        let sv = value < 0 ? 128 + value : value
        v = (param.parm == 12 ? value << 5 : sv)
      }
      return [Data([0xf0, 0x41, 0x36, UInt8(self.channel), 0x23, 0x30, 0x01, UInt8(param.parm), UInt8(v), 0xf7])]
      
    }, patchTransform: { (patch) -> [Data]? in
      return [patch.sysexData(channel: self.channel)]

    }, nameTransform: { (patch, path, name) -> [Data]? in
      return [patch.sysexData(channel: self.channel)]

    })

  }
  
}


// AJ1: 64 presets / 64 memory
// AJ2: 64 presets / 64 memory / 64 cartridge
// MKS-50: 128 tones / 128 patches (tone + perf ctrl) all writeable

class AlphaJunoEditor : SingleDocSynthEditor, MKS50TypeEditor {
  
  var channel: Int { return patch(forPath: [.global])?[[.channel]] ?? 0 }

  required init(baseURL: URL) {
    let map: [SynthPath:Sysexible.Type] = [
      [.global] : ChannelSettingsPatch.self,
      [.tone] : AlphaJunoVoicePatch.self,
      [.bank, .tone] : AlphaJunoVoiceBank.self,
    ]

    let migrationMap: [SynthPath:String] = [
      [.global] : "Global.json",
      [.tone] : "Tone.syx",
      [.bank, .tone] : "Tone Bank.syx",
    ]

    super.init(baseURL: baseURL, sysexMap: map, migrationMap: migrationMap)
  }
    
  // MARK: MIDI I/O
  
  override func midiOuts() -> [Observable<[Data]?>] {
    var midiOuts = [Observable<[Data]?>]()

    midiOuts.append(voiceOut(input: patchStateManager([.tone])!.typedChangesOutput()))

    midiOuts.append(GenericMidiOut.pushOnlyBank(input: bankStateManager([.bank, .tone])!.output, bankTransform: {
      guard let b = $0 as? AlphaJunoVoiceBank else { return nil }
      return b.sysexData(channel: self.channel)
    }))

    return midiOuts
  }
  
  override func midiChannel(forPath path: SynthPath) -> Int { return channel }

  
  override func fetchCommands(forPath path: SynthPath) -> [RxMidi.FetchCommand]? {
    switch path {
    case [.tone]:
      return [.requestMsg(.sysex([0xf0, 0xf7]), .gtEq(54))]
    case [.bank, .tone]:
      return [.requestMsg(.sysex([0xf0, 0xf7]), .gtEq(4256))]
    default:
      return nil
    }
  }
    
  override func bankPaths(forPatchType patchType: SysexPatch.Type) -> [SynthPath] {
    switch patchType {
    case is AlphaJunoVoicePatch.Type:
      return [[.bank, .tone]]
    default:
      return []
    }
  }
  
  override func bankTitles(forPatchType patchType: SysexPatch.Type) -> [String] {
    switch patchType {
    case is AlphaJunoVoicePatch.Type:
      return ["Tone Bank"]
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


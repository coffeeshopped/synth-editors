
public struct TetraEditor : StaticEditorTemplate {
  
  public static let sysexMap: [SynthPath : SysexTemplate.Type] = [
    [.global] : TetraGlobalPatch.self,
    [.patch] : TetraVoicePatch.self,
    [.perf] : TetraComboPatch.self,
    [.bank, .i(0)] : TetraVoiceBank.self,
    [.bank, .i(1)] : TetraVoiceBank.self,
    [.bank, .i(2)] : TetraVoiceBank.self,
    [.bank, .i(3)] : TetraVoiceBank.self,
    [.bank, .perf] : TetraComboBank.self,
  ]
  
  public static var migrationMap: [SynthPath : String]? = nil
  

  static func channel(_ editor: TemplatedEditor) -> Int {
    // value of 0 == global
    let ch = editor.patch(forPath: [.global])?[[.channel]] ?? 0
    return ch > 0 ? ch - 1 : 0
  }
    
    
  // MARK: MIDI I/O
  
  private static func request(_ bytes: [UInt8]) -> RxMidi.FetchCommand {
    .request(Data(Tetra.sysexHeader + bytes + [0xf7]))
  }
  
  public static func fetchCommands(_ editor: TemplatedEditor, forPath path: SynthPath) -> [RxMidi.FetchCommand]? {
    switch path[0] {
    case .global:
      return [request([0x0e])]
    case .patch:
      return [request([0x06])]
    case .perf:
      return [request([0x38])]
    case .bank:
      if let bank = path.i(1) {
        return (0..<128).map { request([0x05, UInt8(bank), $0]) }
      }
      else { // combo
        return (0..<128).map { request([0x21, $0]) }
      }
    default:
      return nil
    }
  }
  
  
  private static let comparator = PatchComparator<FnSinglePatch<TetraGlobalPatch>>(path: [.global])
  public static func patchChanged(_ editor: TemplatedEditor, forPath path: SynthPath, _ change: PatchChange, transmit: Bool) {
    comparator.check(path: path, change: change)
  }
  
  
  public static func midiOuts(_ editor: TemplatedEditor) -> [Observable<RxMidi.Command?>] {
    return [
      nrpnOut(editor, [.global]),
      nrpnOut(editor, [.patch]),
      nrpnOut(editor, [.perf]),
    ] +
    (0..<4).map { bank in
      partiallyUpdatableBankOut(editor, path: [.bank, .i(bank)]) {
        [TetraVoicePatch.sysexData($0, bank: bank, location: $1)]
      }
    } +
    [partiallyUpdatableBankOut(editor, path: [.bank, .perf]) {
      [TetraComboPatch.sysexData($0, location: $1)]
    }]
  }

  public static func midiChannel(_ editor: TemplatedEditor, forPath path: SynthPath) -> Int {
    return channel(editor)
  }

  public static func bankInfo(forPatchTemplate templateType: PatchTemplate.Type) -> [(SynthPath, String)] {
    switch templateType {
    case is TetraVoicePatch.Type:
      return [
        ([.bank, .i(0)], "Bank 1"),
        ([.bank, .i(1)], "Bank 2"),
        ([.bank, .i(2)], "Bank 3"),
        ([.bank, .i(3)], "Bank 4"),
        ]
    case is TetraComboPatch.Type:
      return [
        ([.bank, .perf], "Combo Bank"),
        ]
    default:
      return []
    }
  }
  
  static func nrpnOut(_ editor: TemplatedEditor, _ path: SynthPath) -> Observable<RxMidi.Command?> {
    let input = editor.patchStateManager(path)!.typedChangesOutput() as Observable<(PatchChange, ByteBackedSysexPatch, Bool)>
    return FnMidiOut.patchChange(throttle: .milliseconds(100), input: input, paramTransform: { [weak editor] (patch, path, value) in
      guard let editor = editor,
        let param = type(of: patch).params[path] else { return nil }
      let ch = UInt8(channel(editor))
      return nrpnData(channel: ch, index: param.parm, value: UInt8(value)).map { ($0, 0.03) }

    }, patchTransform: {
      return [(.sysex([UInt8]($0.fileData())), 0)]

    }) { [weak editor] (patch, path, name) in
      guard let editor = editor,
            type(of: patch).nameByteRange.count > 0 else { return nil }
      let parmOffset = (type(of: patch) as? TemplatedPatch.Type)?.template is TetraComboPatch.Type ? 512 : 0
      let bytes = patch.nameBytes
      let ch = UInt8(channel(editor))
      return type(of: patch).nameByteRange.enumerated().map {
        nrpnData(channel: ch, index: $0.element + parmOffset, value: bytes[$0.offset])
      }.reduce([], +).map { ($0, 0.01) }
      
    }
  }

  static func nrpnData(channel: UInt8, index: Int, value: UInt8) -> [MidiMessage] {
    return [
      .cc(channel: channel, number: 0x63, value: UInt8(index >> 7)),
      .cc(channel: channel, number: 0x62, value: UInt8(index & 0x7f)),
      .cc(channel: channel, number: 0x06, value: value >> 7),
      .cc(channel: channel, number: 0x26, value: value & 0x7f),
      .cc(channel: channel, number: 0x25, value: 0x3f),
      .cc(channel: channel, number: 0x24, value: 0x3f),
    ]
  }
}

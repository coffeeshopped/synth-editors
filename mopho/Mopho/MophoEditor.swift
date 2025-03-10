
protocol MophoTypeEditor : StaticEditorTemplate {
  associatedtype GlobalPatch: SinglePatchTemplate
  associatedtype VoicePatch: MophoVoiceTypePatch
  associatedtype VoiceBank: SingleBankTemplate
}

extension MophoTypeEditor {

  public static var sysexMap: [SynthPath : SysexTemplate.Type] {
    var map: [SynthPath:SysexTemplate.Type] = [
      [.global] : GlobalPatch.self,
      [.patch] : VoicePatch.self,
    ]
    (0..<3).forEach {
      map[[.bank, .i($0)]] = VoiceBank.self
    }
    return map
  }
  
  public static var migrationMap: [SynthPath : String]? { [
    [.global] : "Global.syx",
    [.patch] : "TempVoice.syx",
    [.bank, .i(0)] : "Bank 1.syx",
    [.bank, .i(1)] : "Bank 2.syx",
    [.bank, .i(2)] : "Bank 3.syx",
  ] }
 
  static func channel(_ editor: TemplatedEditor) -> Int {
    // value of 0 == global
    let ch = editor.patch(forPath: [.global])?[[.channel]] ?? 0
    return ch > 0 ? ch - 1 : 0
  }

  
  // MARK: MIDI I/O
  
  private static func request(_ bytes: [UInt8]) -> RxMidi.FetchCommand {
    .request(Data(VoicePatch.sysexHeader + bytes + [0xf7]))
  }
  
  public static func fetchCommands(_ editor: TemplatedEditor, forPath path: SynthPath) -> [RxMidi.FetchCommand]? {
    switch path[0] {
    case .global:
      return [request([0x0e])]
    case .patch:
      return [request([0x06])]
    case .bank:
      guard let bank = path.i(1) else { return nil }
      return (0..<128).map { request([0x05, UInt8(bank), $0]) }
    default:
      return nil
    }
  }
  
  public static func midiOuts(_ editor: TemplatedEditor) -> [Observable<RxMidi.Command?>] {
    return [
      TetraEditor.nrpnOut(editor, [.global]),
      TetraEditor.nrpnOut(editor, [.patch]),
    ]
    + (0..<3).map { bank in
      partiallyUpdatableBankOut(editor, path: [.bank, .i(bank)]) {
        [VoicePatch.sysexData($0, bank: bank, location: $1)]
      }
    }
  }

  public static func midiChannel(_ editor: TemplatedEditor, forPath path: SynthPath) -> Int {
    channel(editor)
  }

  public static func bankInfo(forPatchTemplate templateType: PatchTemplate.Type) -> [(SynthPath, String)] {
    switch templateType {
    case is VoicePatch.Type:
      return [
        ([.bank, .i(0)], "Bank 1"),
        ([.bank, .i(1)], "Bank 2"),
        ([.bank, .i(2)], "Bank 3"),
        ]
    default:
      return []
    }
  }
}


public struct MophoEditor : MophoTypeEditor {
  typealias GlobalPatch = MophoGlobalPatch
  typealias VoicePatch = MophoVoicePatch
  typealias VoiceBank = MophoVoiceBank
}

public struct MophoKeyEditor : MophoTypeEditor {
  typealias GlobalPatch = MophoKeyGlobalPatch
  typealias VoicePatch = MophoKeyVoicePatch
  typealias VoiceBank = MophoKeyVoiceBank
}


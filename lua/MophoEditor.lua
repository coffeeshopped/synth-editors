protocol MophoTypeEditor : StaticEditorTemplate {
  associatedtype GlobalPatch: SinglePatchTemplate
  associatedtype VoicePatch: MophoVoiceTypePatch
  associatedtype VoiceBank: SingleBankTemplate
}

MophoTypeEditor = {

  sysexMap = (function()
    local map = {
      ["global"] = GlobalPatch,
      ["patch"] = VoicePatch,
    }
    for i=1,3 do
      map["bank/i(" .. i .. ")"] = VoiceBank
    end
    return map
  end)()
  
  migrationMap = {
    ["global"] = "Global.syx",
    ["patch"] = "TempVoice.syx",
    ["bank/i(1)"] = "Bank 1.syx",
    ["bank/i(2)"] = "Bank 2.syx",
    ["bank/i(3)"] = "Bank 3.syx",
  }
 
  channel = function (editor)
    -- value of 0 == global
    ch = editor.patch("global"])?["channel"] or 0
    return (ch > 0) and (ch - 1) or 0
  end

  
  -- MARK: MIDI I/O
  
  local request = function(bytes)
    .request(Data(VoicePatch.sysexHeader + bytes + [0xf7]))
  end
  
  fetchCommands = function (editor, path)
    SynthPath.
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
  end
  
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



public struct MicroQEditor : StaticEditorTemplate {
  
  public static var sysexMap: [SynthPath : SysexTemplate.Type] = {
    var map:[SynthPath:SysexTemplate.Type] = [
      [.global] : MicroQGlobalPatch.self,
      [.patch] : MicroQVoicePatch.self,
      [.multi] : MicroQMultiPatch.self,
      [.rhythm] : MicroQDrumPatch.self,
      [.bank, .i(0)] : MicroQVoiceBank.self,
      [.bank, .i(1)] : MicroQVoiceBank.self,
      [.bank, .i(2)] : MicroQVoiceBank.self,
      [.bank, .multi] : MicroQMultiBank.self,
      [.bank, .rhythm] : MicroQDrumBank.self,
    ]
    (0..<16).forEach { map[[.multi, .i($0)]] = MicroQVoicePatch.self }
    (0..<32).forEach { map[[.rhythm, .i($0)]] = MicroQVoicePatch.self }
    return map
  }()
    
  public static var migrationMap: [SynthPath : String]? = nil
  
  static func deviceId(_ editor: TemplatedEditor) -> UInt8 {
    UInt8(editor.patch(forPath: [.global])?[[.deviceId]] ?? 0)
  }
  
  private static func request(_ deviceId: UInt8, _ bytes: [UInt8]) -> RxMidi.FetchCommand {
    .requestMsg(.sysex(MicroQVoicePatch.sysexHeader(deviceId: deviceId) + bytes + [0xf7]), nil)
  }
  
  public static func fetchCommands(_ editor: TemplatedEditor, forPath path: SynthPath) -> [RxMidi.FetchCommand]? {
    let deviceId = deviceId(editor)
    switch path[0] {
    case .patch:
      return [request(deviceId, [0x00, 0x20, 0x00])]
    case .multi:
      if let i = path.i(1) {
        return [request(deviceId, [0x00, 0x30, UInt8(i)])]
      }
      else {
        return [request(deviceId, [0x01, 0x20, 0x00])]
      }
    case .rhythm:
      if let i = path.i(1) {
        return [request(deviceId, [0x00, 0x30, UInt8(i + 16)])]
      }
      else {
        return [request(deviceId, [0x02, 0x20, 0x00])]
      }
    case .global:
      return [request(deviceId, [0x04])]
    case .bank:
      switch path.last {
      case let .i(bank):
        return 100.map { request(deviceId, [0x00, UInt8(bank), UInt8($0)]) }
      case .multi:
        return 100.map { request(deviceId, [0x01, 0x00, UInt8($0)]) }
      case .rhythm:
        return 20.map { request(deviceId, [0x02, 0x00, UInt8($0)]) }
      default:
        break
      }
    default:
      break
    }
    return nil
  }
  
  public static func extraParamsOutput(_ editor: TemplatedEditor, forPath path: SynthPath) -> Observable<SynthPathParam>? {
    guard path == [.multi] || path == [.rhythm] else { return nil }
    let voices = (0..<3).map {
      mapBankNameParams(editor, bankPath: [.bank, .i($0)], toParamPath: [.patch, .i($0), .name])
    }
    let rhythm = mapBankNameParams(editor, bankPath: [.bank, .rhythm], toParamPath: [.rhythm, .name])
    return Observable.merge(voices + [rhythm])
  }

  private static func patchOut<T:MicroQPatch>(_ editor: TemplatedEditor, _ path: SynthPath, _ templateType: T.Type) -> Observable<(PatchChange, FnSinglePatch<T>, Bool)> {
    editor.patchStateManager(path)!.typedChangesOutput()
  }
  
  public static func transformMidiCommand(_ editor: TemplatedEditor, forPath path: SynthPath, _ command: RxMidi.Command) -> RxMidi.Command {
    guard path == [.rhythm], case let .sendMsg(msg) = command else { return command }
    let ch = UInt8(editor.midiChannel(forPath: path))
    return .sendMsg(msg.channel(ch))
  }

  public static func midiOuts(_ editor: TemplatedEditor) -> [Observable<RxMidi.Command?>] {
    let multis = 16.map {
      midiOut(editor, 0x20, UInt8($0), patchOut(editor, [.multi, .i($0)], MicroQVoicePatch.self))
    }
    let drums = 32.map {
      midiOut(editor, 0x20, UInt8($0 + 16), patchOut(editor, [.rhythm, .i($0)], MicroQVoicePatch.self))
    }
    
    return [
      midiOut(editor, 0x20, 0x00, patchOut(editor, [.patch], MicroQVoicePatch.self)),
      midiOut(editor, 0x21, 0x00, patchOut(editor, [.multi], MicroQMultiPatch.self)),
      drumOut(editor, patchOut(editor, [.rhythm], MicroQDrumPatch.self)),
      midiOut(editor, 0x24, 0x00, patchOut(editor, [.global], MicroQGlobalPatch.self)),
    ] + multis + drums +
    3.map {
      bankOut(editor, path: [.bank, .i($0)], bank: UInt8($0), template: MicroQVoicePatch.self)
    } +
    [
      bankOut(editor, path: [.bank, .multi], bank: 0, template: MicroQMultiPatch.self),
      bankOut(editor, path: [.bank, .rhythm], bank: 0, template: MicroQDrumPatch.self)
    ]
  }
  
  private static func bankOut<T:MicroQPatch>(_ editor: TemplatedEditor, path: SynthPath, bank: UInt8, template: T.Type) -> Observable<RxMidi.Command?> {
    partiallyUpdatableBankOut(editor, path: path) {
      [T.sysexData($0, deviceId: deviceId($2), bank: bank, location: UInt8($1))]
    }
  }

  
  public static func midiChannel(_ editor: TemplatedEditor, forPath path: SynthPath) -> Int {
    0 // TODO
  }
  
  public static func bankInfo(forPatchTemplate templateType: PatchTemplate.Type) -> [(SynthPath, String)] {
    switch templateType {
    case is MicroQVoicePatch.Type:
      return [
        ([.bank, .i(0)], "Bank A"),
        ([.bank, .i(1)], "Bank B"),
        ([.bank, .i(2)], "Bank C"),
      ]
    case is MicroQMultiPatch.Type:
      return [([.bank, .multi], "Multi Bank")]
    case is MicroQDrumPatch.Type:
      return [([.bank, .rhythm], "Drum Bank")]
    default:
      return []
    }
  }
  
  static func midiOut<T:MicroQPatch>(_ editor: TemplatedEditor, _ cmdByte: UInt8, _ locByte: UInt8, _ input: Observable<(PatchChange, FnSinglePatch<T>, Bool)>) -> Observable<RxMidi.Command?> {

    let bankByte: UInt8 = T.self is MicroQVoicePatch.Type ? 0x30 : 0x20
    let bufferBytes: [UInt8] = T.self is MicroQVoicePatch.Type ? [cmdByte, locByte] : [cmdByte]
    return FnMidiOut.patchChange(input: input) { [weak editor] patch, path, value in
      guard let editor = editor,
        let param = type(of: patch).params[path] else { return nil }
      let devId = deviceId(editor)

      // some params are buggy so send whole patch
      if param.parm < 0 {
        return [(T.sysexData(patch.bytes, deviceId: devId, bank: bankByte, location: locByte), 0)]
      }
      else if path == [.category] {
        return (379..<383).map {
          (paramMsg(deviceId: devId, bufferBytes: bufferBytes, parmByte: $0, value: patch.bytes[$0]), 0.01)
        }
      }
      
      return [(paramMsg(deviceId: devId, bufferBytes: bufferBytes, parmByte: param.byte, value: patch.bytes[param.byte]), 0.01)]

    } patchTransform: { [weak editor] patch in
      guard let editor = editor else { return nil }
      let devId = deviceId(editor)
      // TODO bank isn't 0x20 for multi buffers
      return [(T.sysexData(patch.bytes, deviceId: devId, bank: bankByte, location: locByte), 0.01)]
      
    } nameTransform: { [weak editor] patch, path, name in
      guard let editor = editor else { return nil }
      let devId = deviceId(editor)
      return type(of: patch).nameByteRange.map {
        (paramMsg(deviceId: devId, bufferBytes: bufferBytes, parmByte: $0, value: patch.bytes[$0]), 0.01)
      }

    }

  }
  
  private static func paramMsg(deviceId: UInt8, bufferBytes: [UInt8], parmByte: Int, value: UInt8) -> MidiMessage {
    .sysex(MicroQVoicePatch.sysexHeader(deviceId: deviceId) + bufferBytes +
      [UInt8(parmByte >> 7), UInt8(parmByte & 0x7f), value, 0xf7])
  }
  
  static func drumOut(_ editor: TemplatedEditor, _ input: Observable<(PatchChange, FnSinglePatch<MicroQDrumPatch>, Bool)>) -> Observable<RxMidi.Command?> {

    return FnMidiOut.wholePatchChange(input: input) { [weak editor] patch in
      guard let editor = editor else { return nil }
      return [(MicroQDrumPatch.sysexData(patch.bytes, deviceId: deviceId(editor), bank: 0x20, location: 0x00), 0)]
    }
  }
  
}

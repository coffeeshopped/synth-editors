
class EvolverKeyEditor : EvolverEditor {
  
  private static let _patchMap: [SynthPath:Sysexible.Type] = {
    var map: [SynthPath:Sysexible.Type] = [
      [.global] : EvolverKeyGlobalPatch.self,
      [.patch] : EvolverKeyVoicePatch.self,
      [.wave] : EvolverWavePatch.self,
      [.bank, .wave] : EvolverWaveBank.self,
    ]
    (0..<4).forEach { map[[.bank, .i($0)]] = EvolverKeyVoiceBank.self }
    return map
  }()
  class override var patchMap: [SynthPath:Sysexible.Type] { return _patchMap }

  override func fetchCommands(forPath path: SynthPath) -> [RxMidi.FetchCommand]? {
    switch path[0] {
    case .bank:
      if let bank = path.i(1) {
        return (0..<128).map {
          // 1 request should return both patch and name data
          return .request(sysexHeader + Data([0x05, UInt8(bank), $0, 0xf7]))
        }
      }
      else {
        // wave bank
        return [RxMidi.FetchCommand]((0..<32).map {
          return .request(sysexHeader + Data([0x0b, $0 + 96, 0xf7]))
        })
      }
    default:
      return super.fetchCommands(forPath: path)
    }
  }
}

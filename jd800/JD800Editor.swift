
class JD800Editor : RolandNewAddressableEditor {
    
  override var deviceId: Int {
    return patch(forPath: [.deviceId])?[[.deviceId]] ?? 0
  }
  
  private static let _sysexMap: [SynthPath:Sysexible.Type] = {
    var map: [SynthPath:Sysexible.Type] = [
      [.deviceId]     : JD800SettingsPatch.self,
      [.global]       : JD800SystemPatch.self,
      [.patch]        : JD800VoicePatch.self,
      [.rhythm]       : JD800SpecialSetupPatch.self,
      [.perf]         : JD800PartsPatch.self,
      [.bank, .patch] : JD800VoiceBank.self,
      [.bank, .rhythm] : JD800SpecialSetupBank.self
    ]
    (0..<5).forEach {
      map[[.part, .i($0)]] = JD800VoicePatch.self
    }
    return map
  }()
  class var sysexMap: [SynthPath:Sysexible.Type] { return _sysexMap }
  
  static let migrationMap: [SynthPath:String] = [:]
  
  required init(baseURL: URL) {
    super.init(baseURL: baseURL, sysexMap: type(of: self).sysexMap, migrationMap: type(of: self).migrationMap)
    
    load { [weak self] in
      self?.initPatchParamsOutput()
    }
  }
  
  // MARK: Interactions
  
  private var patchParamsOutput: Observable<SynthPathParam>?
  private var rhythmParamsOutput: Observable<SynthPathParam>?
    
  // add the PCM card param
  private func initPatchParamsOutput() {
    guard let patchParams = super.paramsOutput(forPath: [.patch]),
      let rhythmParams = super.paramsOutput(forPath: [.rhythm]),
      let deviceOut = patchChangesOutput(forPath: [.deviceId]) else { return }
    
    let deviceParams: Observable<SynthPathParam> = deviceOut.map {
      guard let patch = $0.1,
        let pcm = patch[[.pcm]],
        let card = SOJD80Card.cards[pcm] else { return [:] }
      
      return [[.pcm] : OptionsParam(options: card.waveOptions)]
    }

    patchParamsOutput = Observable.merge(patchParams, deviceParams)
    rhythmParamsOutput = Observable.merge(rhythmParams, deviceParams)
  }
  
  override func paramsOutput(forPath path: SynthPath) -> Observable<SynthPathParam>? {
    switch path.first {
    case .patch, .part:
      return patchParamsOutput
    case .rhythm:
      return rhythmParamsOutput
    default:
      return super.paramsOutput(forPath: path)
    }
  }
  
  // MARK: MIDI I/O
  
  override var requestHeader: Data {
    return Data([0xf0, 0x41, UInt8(deviceId), 0x3d, 0x11])
  }
  
  override public func fetchCommands(forPath path: SynthPath) -> [RxMidi.FetchCommand]? {
    guard path.first == .part else { return super.fetchCommands(forPath: path) }
    
    // we're using normal VoicePatch structure for storing the patch internally, but fetch
    // needs to request a different structure
    let addressable = JD800VoicePartPatch.self
    let address = addressable.startAddress(path)
    return [.request(fetchRequestData(forAddress: address, size: addressable.size, addressCount: addressable.addressCount))]
  }

  override func midiDataObservable(forPath path: SynthPath) -> Observable<[Data]?>? {
    guard path.first == .part else { return super.midiDataObservable(forPath: path) }
    
    let address = JD800VoicePartPatch.startAddress(path)
    guard let manager = patchStateManager(path) else { return nil }
    return voicePartMidi(address: address, input: manager.typedChangesOutput())
  }
  
  // A modified copy of the code in RolandNewAddressableMidiOut.multi
  private func voicePartMidi(address: RolandAddress, input: Observable<(PatchChange, JD800VoicePatch, Bool)>) -> Observable<[Data]?> {
    
    return input.throttle(0.1, scheduler:MainScheduler.instance).map { [weak self] (change, patch, transmit) in
      guard transmit,
        let editor = self else { return nil }
      
      switch change {
      case .paramsChange(let params):
        var subchanges = [SynthPath:PatchChange]()
        // go through all the changes
        params.forEach { (path, param) in
          patch.subpatches.keys.forEach { prefix in
            guard path.starts(with: prefix) else { return }
            let newChange: PatchChange = .paramsChange([path.subpath(from: prefix.count) : param])
            subchanges[prefix] = (subchanges[prefix] ?? .paramsChange([:])).updated(withChange: newChange)
          }
        }
        
        // if there are changes across multiple subpatches, send the whole patch!
        if subchanges.count > 1 {
          return patch.partSysexData(deviceId: editor.deviceId, address: address)
        }
        
        guard let changePair = subchanges.first,
          let addressable = patch.subpatches[changePair.key] as? RolandSingleAddressable,
          let subpatchAddress = JD800VoicePartPatch.subpatchAddresses[changePair.key],
          case let .paramsChange(subparams) = changePair.value else { return nil }
        
        let fullSubpatchAddress = address + subpatchAddress
        if subparams.count > 1 {
          //, if there are multiple changes, send subpatch
          return addressable.sysexData(deviceId: editor.deviceId, address: fullSubpatchAddress)
        }
        else if let pair = subparams.first {
          //  otherwise, send individual change
          return [addressable.paramSetData(deviceId: editor.deviceId, address: fullSubpatchAddress, path: pair.key)]
        }
        else {
          return nil
        }
      case .nameChange(let path, _):
        let p = path.count == 0 ? [.common] : path
        guard let addr = patch.addressables[p] else { return nil }
        return [addr.nameSetData(deviceId: editor.deviceId, address: address)]
        
      case .replace(_), .push:
        return patch.partSysexData(deviceId: editor.deviceId, address: address)
        
      case .noop:
        return nil
      }
    }
  }
  
  override func midiChannel(forPath path: SynthPath) -> Int {
    switch path[0] {
    case .patch:
      return patch(forPath: [.deviceId])?[[.channel]] ?? 0
    case .rhythm:
      return min(patch(forPath: [.perf])?[[.part, .i(5), .channel]] ?? 0, 15)
    case .part:
      guard let i = path.i(1) else { return 0 }
      return min(patch(forPath: [.perf])?[[.part, .i(i), .channel]] ?? 0, 15)
    default:
      return 0
    }
  }
  
  override func bankIndexLabelBlock(forPath path: SynthPath) -> ((Int) -> String)? {
    guard path == [.bank, .patch] else { return super.bankIndexLabelBlock(forPath: path) }
    return {
      let bank = ($0 / 8) + 1
      let patch = ($0 % 8) + 1
      return "\(bank)\(patch)"
    }
  }

  
}

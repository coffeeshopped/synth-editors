

protocol JD800Patch : RolandSingleAddressable { }
extension JD800Patch {
  
  // Different multi-byte param pack/unpack
  
  /// Compose Int value from bytes (MSB first)
  static func multiByteParamInt(from: [UInt8]) -> Int {
    guard from.count > 1 else { return Int(from[0]) }
    return (1...from.count).reduce(0) {
      let shift = (from.count - $1) * 7
      return $0 + (Int(from[$1 - 1]) << shift)
    }
  }

  /// Decompose Int to bytes (7! bits at a time)
  static func multiByteParamBytes(from: Int, count: Int) -> [UInt8] {
    guard count > 0 else { return [UInt8(from)] }
    return (1...count).map {
      let shift = (count - $0) * 7
      return UInt8((from >> shift) & 0x7f)
    }
  }
}

protocol JD800MultiPatch : RolandCompactMultiAddressable { }
extension JD800MultiPatch {
  
  // Overriding the RolandCompactMultiAddressable implementation bc I'm not sure if
  // the D-110 needs that version (which does a single, huge sysex msg instead of multiple 266-byte msgs
  func sysexData(deviceId: Int, address: RolandAddress) -> [Data] {
    let sortedPaths = type(of: self).sortedSubpatchPaths()
    var data: Data!
    var bytes = [UInt8]()
    sortedPaths.forEach {
      guard let addressable = addressables[$0] else { return }

      if data == nil {
        data = type(of: addressable).dataSetHeader(deviceId: deviceId)
      }

      bytes.append(contentsOf: addressable.bytes)
    }
    
    // now we have a slab of all the bytes. Break them up into 256-byte chunks, and make a sysex msg of each
    let chunkSize = 256
    return stride(from: 0, to: bytes.count, by: chunkSize).map {
      let thisAdd = address + RolandAddress(intValue: $0)
      var d = Data()
      d.append(type(of: self).dataSetHeader(deviceId: deviceId))
      d.append(contentsOf: thisAdd.sysexBytes(count: type(of: self).addressCount))
      let boff = min($0 + chunkSize, bytes.count)
      let theseB = [UInt8](bytes[$0..<boff])
      d.append(contentsOf: theseB)
      d.append(type(of: self).checksum(address: thisAdd, dataBytes: theseB))
      d.append(0xf7)
      return d
    }
  }

}


const editor = {
  rolandModelId: [0x3d], 
  addressCount: 3,
  name: "",
  map: ([
    ["deviceId", ?, Settings.patchWerk],
    ["global", System.patchWerk],
    ["patch" , Voice.patchWerk],
    ["rhythm", SpecialSetup.patchWerk],
    ["perf"  , Parts.patchWerk],
    ["bank/patch", Voice.bankWerk],
    ["bank/rhythm", SpecialSetup.bankWerk],
  ]).concat(
    (5).map(i => [['part', i], , Voice.patchWerk])
  ),
  fetchTransforms: [
  ],

  midiOuts: [
  ],
  
  midiChannels: [
    ["voice", "basic"],
  ],
  slotTransforms: [
    ['bank/patch', ['user', i => {
      const bank = (i / 8) + 1
      const patch = (i % 8) + 1
      return `${bank}${patch}`
    }]]
  ],
  
}



class JD800Editor : RolandNewAddressableEditor {
    
  override var deviceId: Int {
    return patch(forPath: "deviceId")?["deviceId"] ?? 0
  }

  // MARK: Interactions
  
  private var patchParamsOutput: Observable<SynthPathParam>?
  private var rhythmParamsOutput: Observable<SynthPathParam>?
    
  // add the PCM card param
  private func initPatchParamsOutput() {
    guard let patchParams = super.paramsOutput(forPath: "patch"),
      let rhythmParams = super.paramsOutput(forPath: "rhythm"),
      let deviceOut = patchChangesOutput(forPath: "deviceId") else { return }
    
    let deviceParams: Observable<SynthPathParam> = deviceOut.map {
      guard let patch = $0.1,
        let pcm = patch["pcm"],
        let card = SOJD80Card.cards[pcm] else { return [:] }
      
      return ["pcm" : OptionsParam(options: card.waveOptions)]
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
    return `request(fetchRequestData(forAddress: address/${size: addressable.size}/${addressCount: addressable.addressCount))}`
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
        let p = path.count == 0 ? "common" : path
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
      return patch(forPath: "deviceId")?["channel"] ?? 0
    case .rhythm:
      return min(patch(forPath: "perf")?["part/5/channel"] ?? 0, 15)
    case .part:
      guard let i = path.i(1) else { return 0 }
      return min(patch(forPath: "perf")?["part/i/channel"] ?? 0, 15)
    default:
      return 0
    }
  }
  
}

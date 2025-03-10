
class MinilogueEditor : SingleDocSynthEditor {
  
  var channel: Int { return patch(forPath: [.global])?[[.channel]] ?? 0 }

  required init(baseURL: URL) {
    let map: [SynthPath:Sysexible.Type] = [
      [.global] : ChannelSettingsPatch.self,
      [.patch] : MiniloguePatch.self,
      [.bank] : MinilogueBank.self,
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
      return [.request(Data([0xf0,0x42,0x30 + UInt8(channel), 0x00, 0x01, 0x2c, 0x10, 0xf7]))]
    case .bank:
      return (0..<200).map {
        let addressLower = UInt8($0 & 0x7f)
        let addressUpper = UInt8(($0 >> 7) & 0x1)
        return .request(Data([0xf0, 0x42, 0x30 + UInt8(channel), 0x00, 0x01, 0x2c, 0x1c,
              addressLower, addressUpper, 0xf7]))
      }
    default:
      return nil
    }
  }

  override func midiOuts() -> [Observable<[Data]?>] {
    var midiOuts = [Observable<[Data]?>]()
    
    midiOuts.append(voice(input: patchStateManager([.patch])!.typedChangesOutput()))

    midiOuts.append(GenericMidiOut.partiallyUpdatableBank(input: bankStateManager([.bank])!.output, patchTransform: {
      guard let patch = $0 as? MiniloguePatch else { return nil }
      return [patch.sysexData(channel: self.channel, location: $1)]
    }))
    
    return midiOuts
  }
  
  override func midiChannel(forPath path: SynthPath) -> Int {
    return channel
  }
  
  override func bankPaths(forPatchType patchType: SysexPatch.Type) -> [SynthPath] {
    return [[.bank]]
  }
  
  override func bankTitles(forPatchType patchType: SysexPatch.Type) -> [String] {
    return ["Voice Bank"]
  }

}

extension MinilogueEditor {
  
  /// Transform <channel, patchChange, patch> into MIDI out data
  func voice(input: Observable<(PatchChange, MiniloguePatch, Bool)>) -> Observable<[Data]?> {
    
    return GenericMidiOut.patchChange(throttle: .milliseconds(100), input: input, paramTransform: { (patch, path, value) -> [Data]? in
      guard let param = type(of: patch).params[path] else { return nil }
      guard param.parm > 0 else { return [patch.sysexData(channel: self.channel)] }
      // look for a CC number we can use
      // TODO: value is going to be way out of range for many params (up to 1023)
      // find a way to scale. maybe based on param type
      //        let outV = Int((127*Float(value)/Float(1+ param.maxVal - param.minVal)).rounded())
      let outV: Int
      if param is Minilogue10BitParam {
        outV = value.map(inRange: 0...1023, outRange: 0...127)
      }
      else if let param = param as? ParamWithRange {
        let range = param.range
        outV = Int( 128 * Float(value) / Float(1 + range.upperBound - range.lowerBound) ) + 1
      }
      else { outV = value }
      
      return [Data(Midi.cc(param.parm, value: outV, channel: self.channel))]
    }, patchTransform: { (patch) -> [Data]? in
      return [patch.sysexData(channel: self.channel)]

    }) { (patch, path, name) -> [Data]? in
      return [patch.sysexData(channel: self.channel)]

    }
  }
  
}

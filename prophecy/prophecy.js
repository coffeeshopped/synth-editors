static func sysexHeader(deviceId: UInt8) -> [UInt8] {
  return [0xf0, 0x42, 0x30 + deviceId, 0x41]
}

const editor = {
  name: "",
  trussMap: [
    ["global", Global.patchTruss],
    ["patch", Voice.patchTruss],
    ["arp", Arp.patchTruss],
    ["bank/patch/0", Voice.bankTruss],
    ["bank/patch/1", Voice.bankTruss],
    ["bank/arp", Arp.bankTruss],
  ],
  
  
  fetchTransforms: [
  ],

  midiOuts: [
  ],
  
  midiChannels: [
    ["patch", "basic"],
  ],
  slotTransforms: [
  ],
}

class ProphecyEditor : SingleDocSynthEditor {
    
  var tempArp = 0

  private func fetchCommand(cmdBytes: [UInt8]) -> RxMidi.FetchCommand {
    return .request(Data(Prophecy.sysexHeader(deviceId: UInt8(channel)) + cmdBytes + [0xf7]))
  }
    
  override func fetchCommands(forPath path: SynthPath) -> [RxMidi.FetchCommand]? {
    switch path {
    case "global":
      return [fetchCommand(cmdBytes: [0x0e, 0x00])]
    case "patch":
      return [fetchCommand(cmdBytes: [0x10, 0x00])]
    case "arp":
      return [fetchCommand(cmdBytes: [0x34, UInt8(tempArp), 0x00])]
    case "bank/patch/0",
         "bank/patch/1":
      guard let bank = path.i(2) else { return nil }
      return [fetchCommand(cmdBytes: [0x1c, 0x10 + UInt8(bank), 0x00, 0x00])]
    case "bank/arp":
      return [fetchCommand(cmdBytes: [0x34, 0x10, 0x00])]
    default:
      return nil
    }
  }
  
  private var lastOscSelect = 0
  
  override func changePatch(forPath path: SynthPath, _ change: PatchChange, transmit: Bool) {
    super.changePatch(forPath: path, change, transmit: transmit)

    switch path {
    case "patch":
      if case let .paramsChange(values) = change {
        values.forEach { pair in
          switch pair.key {
          case "osc/select":
            let mode = pair.value
            let lastPair = lastOscSelect < ProphecyVoicePatch.oscPairs.count ? ProphecyVoicePatch.oscPairs[lastOscSelect] : ProphecyVoicePatch.oscPairs[0]
            guard mode < ProphecyVoicePatch.oscPairs.count else { return }
            let oscPair = ProphecyVoicePatch.oscPairs[mode]
            
            var v = [SynthPath:Int]()
            (0..<2).forEach {
              if lastPair[$0] != oscPair[$0],
                 let osc = oscPair[$0],
                 let defaults = ProphecyVoicePatch.oscDefaults[osc] {
                v.merge(new: defaults.prefixed("osc/$0"))
              }
            }
            if v.count > 0 {
              super.changePatch(forPath: "patch", .paramsChange(SynthPathIntsMake(v)), transmit: false)
            }
            lastOscSelect = mode
          default:
            break
          }
        }
      }
      else if case let .replace(patch) = change {
        if let mode = patch["osc/select"] {
          lastOscSelect = mode
        }
      }
    case "arp":
      guard case .paramsChange(let values) = change,
            let number = values["number"] else { return }
      tempArp = number
      fetch(forPath: path)
    default:
      break
    }
  }
  
//  private var tempArpOut = PublishSubject<(PatchChange, SysexPatch?)>()
//  private var arpPatchOutput: Observable<(PatchChange, SysexPatch?)>?
//
//  override func patchChangesOutput(forPath path: SynthPath) -> Observable<(PatchChange, SysexPatch?)>? {
//    guard path == "arp" else { return super.patchChangesOutput(forPath: path) }
//    if arpPatchOutput == nil, let patchOut = super.patchChangesOutput(forPath: "arp") {
//      arpPatchOutput = Observable.merge(patchOut, tempArpOut)
//    }
//    return arpPatchOutput
//  }
//
//  override func sysexible(forPath path: SynthPath) -> Sysexible? {
//    // used by the overlay popup loader
//    guard path.starts(with: "extra/key"),
//          let overlayBank = sysexible(forPath: "extra") as? BassStationIIOverlayPatch,
//          let key = overlayBank.subpatches[path.subpath(from: 1)] as? BassStationIIOverlayKeyPatch else { return super.sysexible(forPath: path) }
//    return BassStationIIVoicePatch.fromOverlay(key)
//
//  }

  // make those big multi-msg pushes happen faster!
//  override var sendInterval: TimeInterval { return 0.01 }

  override func midiOuts() -> [Observable<[Data]?>] {
    var midiOuts = [Observable<[Data]?>]()
    
    midiOuts.append(globalOut(input: patchStateManager("global")!.typedChangesOutput()))
    midiOuts.append(voiceOut(input: patchStateManager("patch")!.typedChangesOutput()))
    midiOuts.append(arpOut(input: patchStateManager("arp")!.typedChangesOutput()))

    (0..<2).forEach { bank in
      midiOuts.append(GenericMidiOut.partiallyUpdatableBank(input: bankStateManager("bank/patch/bank")!.output, patchTransform: {
        guard let patch = $0 as? ProphecyVoicePatch else { return nil }
        return [patch.sysexData(channel: self.channel, bank: bank, program: $1)]
      }))
    }

//    midiOuts.append(GenericMidiOut.partiallyUpdatableBank(input: bankStateManager("bank/arp")!.output, patchTransform: {
//      guard let patch = $0 as? Deepmind12ArpPatch else { return nil }
//      return [patch.sysexData(channel: self.deviceId, program: $1)]
//    }))

    return midiOuts
  }
  
  override func bankIndexLabelBlock(forPath path: SynthPath) -> ((Int) -> String)? {
    switch path {
    case "bank/patch/0":
      return { "A\($0)" }
    case "bank/patch/1":
      return { "B\($0)" }
    default:
      return { "\($0 + 1)" }
    }
  }
}

// MARK: Midi Out

extension ProphecyEditor {

  func paramChange(group: UInt8, paramId: Int, value: Int) -> [UInt8] {
    return Prophecy.sysexHeader(deviceId: UInt8(channel)) +
      [0x41, group, UInt8(paramId & 0x7f), UInt8((paramId >> 7) & 0x7f),
       UInt8(value & 0x7f), UInt8((value >> 7) & 0x7f), 0xf7]
  }
  
}

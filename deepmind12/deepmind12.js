
const sysexHeader = [0xf0, 0x00, 0x20, 0x32, 0x20, 'deviceId']

module.exports = {
  sysexHeader,
}

const fetchCommand = cmdBytes => ['truss', [sysexHeader, cmdBytes, 0xf7]

const editor = {
  name: "Deepmind 12",
  trussMap: [
    ["mode", Connect.patchTruss],
    ["global", Global.patchTruss],
    ["patch", Voice.patchTruss],
    ["arp", Arp.patchTruss],
    ["bank/patch/0", Voice.bankTruss],
    ["bank/patch/1", Voice.bankTruss],
    ["bank/patch/2", Voice.bankTruss],
    ["bank/patch/3", Voice.bankTruss],
    ["bank/patch/4", Voice.bankTruss],
    ["bank/patch/5", Voice.bankTruss],
    ["bank/patch/6", Voice.bankTruss],
    ["bank/patch/7", Voice.bankTruss],
    ["bank/arp", Arp.bankTruss],
  ],
  fetchTransforms: [
    ["global", ['truss', fetchCommand([0x05])]],
    ["patch", ['truss', fetchCommand([0x03])]],
    ["arp", ['truss', fetchCommand([0x0e])]],
    ["bank/patch/0", ['truss', fetchCommand([0x09, 0, 0, 127])]],
    ["bank/patch/1", ['truss', fetchCommand([0x09, 1, 0, 127])]],
    ["bank/patch/2", ['truss', fetchCommand([0x09, 2, 0, 127])]],
    ["bank/patch/3", ['truss', fetchCommand([0x09, 3, 0, 127])]],
    ["bank/patch/4", ['truss', fetchCommand([0x09, 4, 0, 127])]],
    ["bank/patch/5", ['truss', fetchCommand([0x09, 5, 0, 127])]],
    ["bank/patch/6", ['truss', fetchCommand([0x09, 6, 0, 127])]],
    ["bank/patch/7", ['truss', fetchCommand([0x09, 7, 0, 127])]],
    ["bank/arp", ['truss', (32).map(i =>
      fetchCommand([0x07, i])
    )]],
  ],

  midiOuts: [
    ["global", Global.patchTransform],
    ["patch", Voice.patchTransform],
    ["arp", Arp.patchTransform],
    ["bank/patch/0", Voice.bankTransform(0)],
    ["bank/patch/1", Voice.bankTransform(1)],
    ["bank/patch/2", Voice.bankTransform(2)],
    ["bank/patch/3", Voice.bankTransform(3)],
    ["bank/patch/4", Voice.bankTransform(4)],
    ["bank/patch/5", Voice.bankTransform(5)],
    ["bank/patch/6", Voice.bankTransform(6)],
    ["bank/patch/7", Voice.bankTransform(7)],
    ["bank/arp", Arp.bankTransform],
  ],  

  midiChannels: [
    ["voice", "basic"],
  ],
  slotTransforms: ([
    ["bank/arp", 'userZeroToOne']
  ]).concat(
    (8).map(i => [["bank/patch", i], 'userZeroToOne'])
  ),
}



class Deepmind12Editor : SingleDocSynthEditor {
    
  var deviceId: Int { return patch(forPath: "global")?["deviceId"] ?? 0 }
  
  var channel: Int {
    let mode = patch(forPath: "mode")?["mode"] ?? 0
    let modes: [SynthPathItem] = "midi/usb/wifi"
    guard mode < modes.count else { return 0 }
    let ch = patch(forPath: "global")?[[modes[mode], .channel, .rcv]] ?? 1
    return ch < 1 ? 0 : ch - 1
  }

  required init(baseURL: URL) {
//    addMidiInHandler(throttle: 0.1) { [weak self] (msg) in
//      guard let self = self else { return }
//      guard case .cc(let channel, let number, let value) = msg,
//        (80..<88) ~= number,
//        channel == self.channel(forSynth: 0) || channel == self.channel(forSynth: 1) else { return }
//      let part = channel == self.channel(forSynth: 0) ? 0 : 1
//      self.handleMacroCC(part: part, number: number, value: value)
//    }
  }
          
  
  override func changePatch(forPath path: SynthPath, _ change: PatchChange, transmit: Bool) {
    super.changePatch(forPath: path, change, transmit: transmit)
    
    switch path {
    case "patch":
      if case let .paramsChange(values) = change {
        values.forEach { pair in
          switch pair.key {
          case "fx/routing":
            let mode = pair.value
            guard mode < Deepmind12FX.routingLevels.count else { return }
            let levels = Deepmind12FX.routingLevels[mode].defaults
            // update levels to defaults for this mode.
            var pcValues: [SynthPath:Int] = [:]
            (0..<4).forEach { pcValues["fx/$0/level"] = levels[$0] }
            super.changePatch(forPath: "patch", .paramsChange(SynthPathIntsMake(pcValues)), transmit: false)
          case "fx/0/type", "fx/1/type", "fx/2/type", "fx/3/type":
            guard let fx = pair.key.i(1) else { return }
            let fxType = pair.value
            guard fxType < Deepmind12FX.paramDefaults.count else { return }
            let defs = Deepmind12FX.paramDefaults[fxType]
            var pcValues: [SynthPath:Int] = [:]
            (0..<12).forEach { pcValues["fx/fx/param/$0"] = defs[$0] }
            super.changePatch(forPath: "patch", .paramsChange(SynthPathIntsMake(pcValues)), transmit: false)
          default:
            break
          }
        }
      }
    default:
      break
    }
    
  }

  // make those big multi-msg pushes happen faster!
  override var sendInterval: TimeInterval { return 0.01 }  
  
}

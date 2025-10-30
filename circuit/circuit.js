
const patchFetchCommand = (loc) => 
  ['truss', [0xf0, 0x00, 0x20, 0x29, 0x01, 0x60, 0x40, loc, 0xf7]]


const editor = {
  name: "",
  trussMap: [
    ["global", Global.patchTruss],
    ['patch/0', Voice.patchTruss],
    ['patch/1', Voice.patchTruss],
    ['bank/patch', Voice.bankTruss],
  ],
  fetchTransforms: [
    ['patch/0', patchFetchCommand(0)],
    ['patch/1', patchFetchCommand(1)],
    ['bank/patch', (64).flatMap(location => [
      ['send' ['pgmChange', 0, location]], // pgmChange on chan 1
      ['wait', 30],
      patchFetchCommand(0),
      ['wait', 30],
    ])],
  ],

  midiOuts: [
    ['patch/0', Voice.patchTransform(0)],
    ['patch/1', Voice.patchTransform(1)],
    ['bank/patch', Voice.bankTransform]
  ],
  
  midiChannels: [
    ["patch/0", ["patch", "global", "channel/0"]],
    ["patch/1", ["patch", "global", "channel/1"]],
  ],
  slotTransforms: [
    ["bank/patch", ['user', loc => `${loc + 1}`]]
  ],
}



class CircuitEditor : SingleDocSynthEditor {
  required init(baseURL: URL) {
    addMidiInHandler(throttle: .milliseconds(100)) { [weak self] (msg) in
      guard let self = self else { return }
      guard case .cc(let channel, let number, let value) = msg,
        (80..<88) ~= number,
        channel == self.channel(forSynth: 0) || channel == self.channel(forSynth: 1) else { return }
      let part = channel == self.channel(forSynth: 0) ? 0 : 1
      self.handleMacroCC(part: part, number: number, value: value)
    }
  }

  private func handleMacroCC(part: Int, number: UInt8, value: UInt8) {
    let macro = Int(number - 80)
    let pc: PatchChange = .paramsChange(["macro/macro/level" : Int(value)])
    changePatch(forPath: "patch/part", pc, transmit: false)
  }
}

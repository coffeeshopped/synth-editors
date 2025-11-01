
const fetchCommand = (bytes) =>
  ['truss', [0xf0, 0x00, 0x00, 0x0e, 0x22, bytes, 0xf7]]

const patchFetchCommand = (bank, location) =>
  fetchCommand([0x41, bank, 0x00, location])

// TODO: these fetch commands need access to patch info (the patch index)
function bankFetchCommands(bank) {
  let voiceIndexPatch = patch(forPath: "memory/patch") as? MiniakVoiceIndexPatch
  var fallbackLocation: Int?
  for i in 0..<128 {
    if voiceIndexPatch?.voices[bank][i] != nil {
      fallbackLocation = i
      break
    }
  }
  guard let fallback = fallbackLocation else { return nil }
  return (128).flatMap(location => {
    // check if patch exists
    const fetchLocation = voiceIndexPatch?.voices[bank][location] == nil ? fallback : location
    return [
      patchFetchCommand(bank, fetchLocation),
      ['wait', 30],
    ]
  })
}

const editor = {
  name: "",
  trussMap: ([
    ["global", Global.patchTruss],
    ['patch', Voice.patchTruss],
    ['memory/patch', VoiceIndex.patchTruss],
  ]).concat(
    (8).map(i => [["bank/patch", i], Voice.bankTruss])
  ),
  fetchTransforms: ([
    ["global", Global.patchTruss],
    ['patch', ['sequence', [
      patchFetchCommand(fetchBank, fetchLocation),
      ['wait', 30],
      ['send', ['cc', 'channel', 0x20, fetchBank]], // bank select (fine) on chan 1
      ['send', ['pgmChange', 'channel', fetchLocation]], // pgmChange on chan 1
    ]]],
    ['memory/patch', fetchCommand([0x41, 0x00, 0x04, 0x00])],
  ]).concat(
    (8).map(i => [["bank/patch", i], ['sequence', bankFetchCommands(i)]])
  ),

  midiOuts: ([
    ['patch', Voice.patchTransform],
  ]).concat(
    (8).map(i => [["bank/patch", i, Voice.bankTransform(i)])
  ),  

  midiChannels: [
    ["patch", "basic"],
  ],
  slotTransforms: (8).map(i => [["bank/patch", i, 'userDirect']),
}



class MicronEditor : SingleDocSynthEditor {
  var tempBank: UInt8 { return UInt8(patch(forPath: "global")?["bank"] ?? 7) }
  var tempLocation: UInt8 { return UInt8(patch(forPath: "global")?["location"] ?? 127) }
    
  // these should be read where needed, but only set by subscription to globalDoc
  private let fetchBankPath: SynthPath = "dump/bank"
  private let fetchLocationPath: SynthPath = "dump/location"
  var fetchBank: UInt8 { return UInt8(patch(forPath: "global")?[fetchBankPath] ?? 7) }
  var fetchLocation: UInt8 { return UInt8(patch(forPath: "global")?[fetchLocationPath] ?? 127) }

  required init(baseURL: URL) {
    addMidiInHandler(throttle: .milliseconds(0)) { [weak self] (msg) in
      self?.handleMidiIn(msg)
    }
  }
    
  // MARK: MIDI I/O
    
  private func handleMidiIn(_ msg: MidiMessage) {
    switch msg {
    case .cc(let channel, let number, let value):
      guard channel == self.channel,
        number == 0x20 else { return }
      changePatch(forPath: "global", .paramsChange([fetchBankPath : Int(value)]), transmit: false)
    case .pgmChange(let channel, let value):
      guard channel == self.channel else { return }
      changePatch(forPath: "global", .paramsChange([fetchLocationPath : Int(value)]), transmit: false)
    default:
      break
    }
  }
    
  override func onSave(toBankPath bankPath: SynthPath, index: Int, fromPatchPath patchPath: SynthPath) {
    // update fetch bank, location to match to where we just saved
    guard patchPath == "patch",
      let bank = bankPath.i(2) else { return }
    changePatch(forPath: "global", .paramsChange([
      fetchBankPath : bank,
      fetchLocationPath : index,
    ]), transmit: false)
  }
  
  override func changePatch(forPath path: SynthPath, _ change: PatchChange, transmit: Bool) {
    super.changePatch(forPath: path, change, transmit: transmit)
    guard case .replace = change else { return }
    makeFetchMatchWrite()
  }

  fileprivate func makeFetchMatchWrite() {
    changePatch(forPath: "global", .paramsChange([
      fetchBankPath : Int(tempBank),
      fetchLocationPath : Int(tempLocation)
    ]), transmit: false)
  }

}

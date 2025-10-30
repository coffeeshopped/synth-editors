

  var name: String {
  set {
    nameBytes = nameSetFilter(newValue).bytes(forCount: 16)
  }
  get {
    return Self.name(forData: Data(nameBytes))
  }
}

const sysexHeader = [0xf0, 0x00, 0x20, 0x29, 0x00, 0x33, 0x00]

const fetchCmd = cmdBytes => ['truss', [sysexHeader, cmdBytes, 0xf7]]

const overlayFetchCommands = (25).flatMap(loc => [
  fetchCmd([0x4f, loc]),
  ['wait', 30],
  fetchCmd([0x54, loc]),
  ['wait', 30],
])

const editor = {
  name: "Bass Station II",
  trussMap: [
    ["global", 'channel'],
    ["patch", Voice.patchTruss],
    ["extra", Overlay.patchTruss],
    ["bank/patch", Voice.bankTruss],
    ["bank/extra", Overlay.bankTruss],
  ],
  fetchTransforms: [
    ["patch", fetchCmd([0x40])],
    ["extra", overlayFetchCommands],
    ["bank/patch", (128).flatMap(loc => [
      // pgmChange on global channel
      ['send', [['+', 'channel' 0xc0], loc]],
      ['wait', 30],
      fetchCmd([0x40]),
      ['wait', 30],
    ])],
    ["bank/extra", (8).flatMap(i => ([
      ['send', [sysexHeader, 0x50, i + 1, 0xf7]],
    ]).concat(
      overlayFetchCommands
    ))],
  ],
    
  midiOuts: [
    ["patch", Voice.patchTransform],
    ["extra", Overlay.patchTransform],
    ["bank/patch", Voice.bankTransform],
    ["bank/extra", Overlay.bankTransform],
  ],
  
  midiChannels: [
    ["patch", "basic"],
  ],
  slotTransforms: [
    ["bank/patch", ['user', loc => `${loc}`]],
    ["bank/extra", ['user', loc => `${loc + 1}`]]
  ],
  
  // make those big multi-msg pushes happen faster!
  // override var sendInterval: TimeInterval { return 0.01 }

}

  // override func sysexible(forPath path: SynthPath) -> Sysexible? {
  // // used by the overlay popup loader
  // guard path.starts(with: [.extra, .key]),
  //       let overlayBank = sysexible(forPath: [.extra]) as? BassStationIIOverlayPatch,
  //       let key = overlayBank.subpatches[path.subpath(from: 1)] as? BassStationIIOverlayKeyPatch else { return super.sysexible(forPath: path) }
  // return BassStationIIVoicePatch.fromOverlay(key)
// }
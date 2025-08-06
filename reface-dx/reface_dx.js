const Voice = require('./reface_dx_voice.js')

const paramData = address => ['yamParm', 'channel', [0x7f, 0x1c, 0x05, address, 'b']]


const patchTransform = {
  type: 'multiDictPatch',
  throttle: 100, 
  coalesce: 5,
  param: (path, parm, value) => {
    switch (pathPart(path, 0)) {
    case 'common':
      return [[paramData([0x30, 0x00, parm.b]), 50]]
    case 'op':
      const op = pathPart(path, 1)
      return [[paramData([0x31, op, parm.b]), 50]]
    default:
      return null
    }
  }, 
  patch: tempSysexData().map { (.sysex($0), 50) },
  name: { editorVal, bodyData, path, name in
  guard let p = bodyData["common"] else { return [] }
  return 10.map {
    paramData([0x30, 0x00, UInt8($0)], value: p[$0])
  }.map { (.sysex($0), 50) }
}

const bankTransform = .multi(throttle: 100, .basicChannel, .wholeBank({ editorVal, bodyData in

  // change the first patch
  var bodyData = bodyData
  let path: SynthPath = "common/bend"
  guard let parm = patchTruss.parm(path) else { return [] }
  let value = patchTruss.getValue(bodyData[0], path: path) ?? 0
  let dirtyValue = value == parm.span.range.lowerBound ? value + 1 : parm.span.range.lowerBound // just something different from orig value
  patchTruss['setValue', &bodyData[0], path: path, dirtyValue]

  // change param back
  let address: [UInt8]
  switch path[0] {
  case .common:
    address = [0x30, 0x00, UInt8(parm.b!)]
  case .op:
    guard let op = path.i(1) else { return [] }
    address = [0x31, UInt8(op), UInt8(parm.b!)]
  default:
    return []
  }
  
  // send patches
  let data: [MidiMessage] = bodyData.enumerated().map {
    .sysex(sysexData($1, channel: editorVal, location: $0).flatMap({ $0 }))
  } + [
    // pgm change to 1, then 2, then 1
    .pgmChange(channel: UInt8(editorVal), value: 0),
    .pgmChange(channel: UInt8(editorVal), value: 1),
    .pgmChange(channel: UInt8(editorVal), value: 0),
    .sysex(paramData(channel: editorVal, address: address, value: UInt8(value))),
  ]

  // TODO: show msg to store bank
  return data.map { ($0, 50) }
}))


const fetch = address => ['yamFetch', 'channel', [0x7f, 0x1c, 0x05, address]]

const editor = {
  name: "Reface DX",
  trussMap: [
    ["global", 'channel'],
    ["patch", Voice.patchTruss],
    ["bank/voice", Voice.bankTruss],
  ],
  fetchTransforms: [
    ["patch", ['truss', fetch([0x0e, 0x0f, 0x00])]],
    ["bank/voice", ['bankTruss', fetch([0x0e, 0x00, 'b']), {waitInterval: 200}]],
  ],
  midiChannels: [
    ["patch", 'basic'],
  ],
  midiOuts: [
    ["patch", Voice.patchTransform],
    ["bank/voice", Voice.bankTransform],
  ],
  slotTransforms: [
    ["bank/voice", ['user', i => `${i / 8 + 1}-${i % 8 + 1}`]],
  ],
}


const moduleTruss = {
  editor: editor,
  manu: "Yamaha",
  subid: 'refacedx',
  indexPath: [1, 0],
  sections: [
    ['first', [
      'channel',
      ['voice', "Voice", VoiceController.ctrlr()],
    ]],
    ['banks', [
      ['bank', "Voice Bank", "bank/voice"],
    ]],
  ],
  colorGuide: [
    "#ca5e07",
    "#07afca",
    "#fa925f",
  ],
} 

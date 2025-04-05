

const pitchBiasPack = {
  let iso = Iso<Int,Int>(forward: {
    $0 < 0 ? $0 + 51 : $0 - 50
  }, backward: {
    $0 > 50 ? $0 - 51 : $0 + 50
  })
  return iso >>> PackIso.byte(86)
}()

const parms = [
  { inc: 1, b: 0, block: [
    ['aftertouch/pitch', { max: 99 }],
    ['aftertouch/amp', { max: 99 }],
    ['aftertouch/pitch/bias', { max: 100, dispOff: -50 }],
    ['aftertouch/env/bias', { max: 99 }],
  ] },
]

const compactParms = [
  { inc: 1, b: 84, block: [
    ['aftertouch/pitch', { }],
    ['aftertouch/amp', { }],
    ['aftertouch/pitch/bias', { packIso: pitchBiasPack }],
    ['aftertouch/env/bias', { }],
  ] }
]

const sysexData = ['yamCmd', ['channel', 0x7e, 0x00, 0x21], [["enc", "LM  8023AE"], "b"]]

const patchTruss = {
  type: 'singlePatch',
  id: 'tx81z.aced2',
  bodyDataCount: 10,
  parseBody: 16,
  createFile: sysexData,
  parms: parms,
  randomize: () => [
    // TODO 
  //    (0..<4).forEach {
    //      self[[.op, .i($0), .shift]] = 0
    //    }
  ],
}

const compactTruss = {
  type: 'singlePatch',
  id: 'tx81z.aced2.compact',
  bodyDataCount: 128,
  parms: compactParms,
}

module.exports = {
  patchTruss: patchTruss,
  compactTruss: compactTruss,
  patchWerk: Op4.patchWerk(0x13, sysexData),
}

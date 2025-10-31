const Global = require('./evolverkey_global.js')
const Voice = require('./evolverkey_voice.js')
const Wave = require('./evolver_wave.js')

const editor = {
  name: "",
  trussMap: ([
    ["global", Global.patchTruss],
    ['patch', Voice.patchTruss],
    ['wave', Wave.patchTruss],
    ['bank/wave', Wave.bankTruss],
  ]).concat(
    (4).map(i => [['bank', i], Voice.bankTruss])
  ),
  fetchTransforms: [
  ],

  midiOuts: [
  ],
  
  midiChannels: [
    ["voice", "basic"],
  ],
  slotTransforms: [
  ],
}



class EvolverKeyEditor : EvolverEditor {

  override func fetchCommands(forPath path: SynthPath) -> [RxMidi.FetchCommand]? {
    switch path[0] {
    case .bank:
      if let bank = path.i(1) {
        return (0..<128).map {
          // 1 request should return both patch and name data
          return .request(sysexHeader + Data([0x05, UInt8(bank), $0, 0xf7]))
        }
      }
      else {
        // wave bank
        return [RxMidi.FetchCommand]((0..<32).map {
          return .request(sysexHeader + Data([0x0b, $0 + 96, 0xf7]))
        })
      }
    default:
      return super.fetchCommands(forPath: path)
    }
  }
}

const Global = require('./evolver_global.js')
const Voice = require('./evolver_voice.js')
const Wave = require('./evolver_wave.js')

const sysexHeader = 

const fetchBytes = (bytes) => [0xf0, 0x01, 0x20, 0x01, bytes, 0xf7]
const fetchCmd = (bytes) => ['truss', fetchBytes(bytes)]

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
  fetchTransforms: ([
    ["global", fetch([0x0e])],
    ['patch', fetch([0x06])],
    ['wave', fetch([0x0b, waveNumber])],
    ['bank/wave', ['bankTruss', fetchBytes([0x0b, ['+', 'b', 96]])]],
  ]).concat(
    (4).map(i => 
      [['bank', i], ['sequence', (128).flatMap(p => [
        // request patch, then name data
        fetchCmd([0x05, i, p]),
        ['wait', 10],
        fetchCmd([0x10, i, p]),
        ['wait', 10],
      ])]]
    )
  ),

  midiOuts: ([
    ["global", Global.patchTransform],
    ['patch', Voice.patchTransform],
    ['wave', Wave.patchTransform],
    ['bank/wave', Wave.bankTransform],
  ]).concat(
    (4).map(i => [['bank', i], Voice.bankTransform(i)])
  ),
  
  midiOuts.append(GenericMidiOut.pushOnlyPatch(input: patchStateManager("wave")!.typedChangesOutput() as Observable<(PatchChange,EvolverWavePatch, Bool)>, patchTransform: {
  }))
  
  midiChannels: [
    ["voice", "basic"],
  ],
  slotTransforms: [
  ],
}



class EvolverEditor : SingleDocSynthEditor {
    
  var channel: Int {
    let ch = patch(forPath: "global")?["channel"] ?? 0
    return ch > 0 ? ch - 1 : 0
  }
  
  var waveNumber: UInt8 = 0
  
  override func changePatch(forPath path: SynthPath, _ change: PatchChange, transmit: Bool) {
    super.changePatch(forPath: path, change, transmit: transmit)
    guard path == "wave",
          case let .paramsChange(changes) = change,
          let wave = changes["number"] else { return }
    waveNumber = UInt8(wave)
  }
  
}

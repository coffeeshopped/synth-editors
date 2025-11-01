const Virus = require('./virus.js')

const editor = {
  name: "",
  trussMap: ([
    ["global", Global.patchTruss],
    ["patch", Voice.patchTruss],
    ["multi", EmbeddedMulti.patchTruss],
    ["multi/bank", EmbeddedMulti.bankTruss],
  ]).concat(
    (4).map(i => [["bank", i] = Voice.bankTruss }
  ),
  fetchTransforms: [
    // ["global", Virus.fetchCmd([0x35])],
    ["patch", Virus.fetchCmd([0x30, 0x00, 0x40])],
    ["multi", Virus.embMultiFetchCmd(0)],
    ["multi/bank", ['bankTruss', Virus.embMultiFetchCmd(['+', 'b', 32])]],
  ]).concat(
    (4).map(i => [["bank", i], ['bankTruss', [Virus.fetchCmd([0x30, i + 1, 'b'])]]])
  ),

  midiOuts: ([
    ["global", Global.patchTransform],
    ["patch", Voice.patchTransform],
    ["multi", EmbeddedMulti.patchTransform],
    ["multi/bank", EmbeddedMulti.bankTransform],
  ]).concat(
    (4).map(i => [["bank", i] = Voice.bankTransform(i) }
  ),
  
  midiChannels: [
    ["voice", "basic"],
  ],
  slotTransforms: ([
    ["multi/bank", 'direct'],
  ]).concat(
    (4).map(i => [["bank", i], ['user', x => {
      const b = ["A", "B", "C", "D"][i]
      return `${b}${x}`
    }]])
  ),

}



class VirusTIEditor : SingleDocSynthEditor, VirusEditor {
  
  // Time between send sysex msgs (for push)
  override var sendInterval: TimeInterval { return 0.2 }

  private let delayBetweenFetches: TimeInterval = 0.1
  

}

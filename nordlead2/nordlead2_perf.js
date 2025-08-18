
class NordLead2PerfPatch : NordLead2Patch, PerfPatch {
      
  const tempBuffer = 0x1e
  const cardBank = 0x1f
  
  func fileData() -> Data {
    return sysexData(deviceId: 0, bank: type(of: self).tempBuffer, location: 0)
  }
  
  /// Gives temp buffer sysex set data for a slot
  func patchSysexData(deviceId: Int, location: Int) -> Data {
    var data = type(of: self).dataSetHeader(deviceId: deviceId, bank: 0, location: location)
    data.append(contentsOf: type(of: self).split(bytes: patchBytes(location: location)))
    data.append(0xf7)
    return data
  }
  
  func patch(location: Int) -> NordLead2VoicePatch {
    let p = NordLead2VoicePatch(rawBytes: patchBytes(location: location))
    // Name isn't stored in sysex, so set it based on what we have in subnames
    p.name = subnames["patch/location"] ?? "Untitled"
    return p
  }
  
  private func patchBytes(location: Int) -> ArraySlice<UInt8> {
    let patchByteSize = 66
    let offset = location * patchByteSize // size in raw bytes of one patch's data
    return bytes[offset..<(offset+patchByteSize)]
  }
  
}

const lfoSyncOptions = ["2 bar","1 bar","1/2","1/4","1/8","1/8 triplet","1/16"]

const trigNoteOptions: [Int:String] = ([23, 127].map {
  $0 == 23 ? "Off" : `${$0}`
})

const destOptions = ["LFO 1 Amt","LFO 2 Amt","Cutoff","FM Amt","Osc 2 Pitch"]

const parms = [
  { prefix: 'patch', count: 4, bx: 66, block: [
    Voice.parms,
  ] },
  { prefix: 'part', count: 4, bx: 1, block: [
    ["channel", { b: 264, max: 15, dispOff: 1 }],
    ["lfo/0/sync", { b: 268, opts: lfoSyncOptions }],
    ["lfo/1/sync", { b: 272, opts: lfoSyncOptions }],
    ["filter/env/trigger", { b: 276, max: 1 }],
    ["filter/env/trigger/channel", { b: 280, max: 15, dispOff: 1 }],
    ["filter/env/trigger/note", { b: 284, opts: trigNoteOptions }],
    ["amp/env/trigger", { b: 288, max: 1 }],
    ["amp/env/trigger/channel", { b: 292, max: 15, dispOff: 1 }],
    ["amp/env/trigger/note", { b: 296, opts: trigNoteOptions }],
    ["morph/trigger", { b: 300, max: 1 }],
    ["morph/trigger/channel", { b: 304, max: 15, dispOff: 1 }],
    ["morph/trigger/note", { b: 308, opts: trigNoteOptions }],
    ["on", { b: 324, max: 1 }],
    ["pgm", { b: 328, max: 98 }],
    ["bank", { b: 332, opts: ["Int","1 (Card)","2 (Card)","3 (Card)"] }],
    ["channel/pressure/amt", { b: 336, max: 7 }],
    ["channel/pressure/dest", { b: 340, opts: destOptions }],
    ["foot/amt", { b: 344, max: 7 }],
    ["foot/dest/note", { b: 348, opts: destOptions }],
  ] },
  ["bend", { b: 312, opts: ["1","2","3","4","7","10","12","24","48"] }],
  ["unison/detune", { b: 313, max: 8 }],
  ["out/mode/0", { b: 314, bits: [0, 3], opts: ["ab1","ab2","ab3","ab4"] }],
  ["out/mode/1", { b: 314, bits: [4, 7], opts: ["cd-","cd1","cd2","cd3","cd4"] }],
  ["deviceId", { b: 315, max: 15, dispOff: 1 }],
  ["pgmChange", { b: 316, max: 1 }],
  ["midi/ctrl", { b: 317, max: 1 }],
//    ["tune", { b: 318, rng: [-99, 99] }],
  ["pedal/type", { b: 319, max: 2 }],
  ["local/ctrl", { b: 320, max: 1 }],
  ["key/octave/shift", { b: 321, max: 4 }],
  ["select/channel", { b: 322, max: 3 }],
  ["arp/out", { b: 323, max: 1 }],
  
  ["split", { b: 352, max: 1 }],
  ["split/pt", { b: 353, max: 127 }],
]

const patchTruss = {
  single: 'perf',
  parms: parms,
  parseBody: ['>',
    ['bytes', { start: 6, count: 708 }],
    'denibblizeLSB',
  ],
  initFile: "Nord-Lead-perf-init",
}
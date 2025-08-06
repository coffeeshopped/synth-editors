const Voice = require('./proteus_voice.js')

// typealias ProteusInstMapItem = (inst: Int, set: Int, name: String)

//    func randomize() {
//      randomizeAllParams()
//      (0..<3).forEach {
//        self["link/$0"] = -1
//      }
//      (0..<4).forEach {
//        self["key/lo/$0"] = 0
//        self["key/hi/$0"] = 127
//      }
//      (0..<2).forEach {
//        self["$0/key/lo"] = 0
//        self["$0/key/hi"] = 127
//      }
//      self["0/volume"] = 127
//      self["0/delay"] = 0
//      self["0/start"] = 0
//      self["1/delay"] = (0...10).random()!
//
//      self["mix"] = 0
//    }

// high paramCoalesceCount bc patch push is just 128 param change messages anyway
static func patchTransform(params) {
  .single(throttle: 100, Proteus.deviceId, .patch(coalesce: 128, param: { editorVal, bodyData, parm, value in
    let v = Proteus.unpack(bodyData, parm: parm.p!) ?? 0
    return [(.sysex(Proteus.paramData(parm: parm.p!, value: v)), 10)]
  }, patch: { editorVal, bodyData in
    sysexData(bodyData, deviceId: UInt8(editorVal)).map { (.sysex($0), 10) }
  }, name: { editorVal, bodyData, path, name in
    12.map {
      (.sysex(Proteus.paramData(parm: $0, value: Int(bodyData[$0 * 2]))), 10)
    }
  }))
}


function sysexData(location) {
  let byteSum = bytes.map{ Int($0) }.reduce(0, +)
  return Proteus.sysex([0x01, location.bits(0...6), location.bits(7...13)] + bytes + [(byteSum % 128)])
}

// for temp data
const sysexData = (128).map(i =>
  Proteus.paramSetData(i, ['byte', i * 2], ['byte', i * 2 + 1])
)

const namePackIso = NamePackIso(pack: { bytes, name in
  let sizedName = NamePackIso.filtered(name: name, count: 12)
  let byteArr = sizedName.bytes(forCount: 12)
  (0..<12).forEach {
    bytes[$0 * 2] = byteArr[$0]
    bytes[$0 * 2 + 1] = 0
  }

}, unpack: { bytes in
  let nameBytes = 12.map { bytes[$0 * 2] }
  return NamePackIso.trimmed(name: NamePackIso.cleanBytesToString(nameBytes))

}, byteRange: 0..<12)  // byteRange is just used to calc maxNameCount AFAICT


function instPackIso(parm, instMap, reverseInstMap) {
  PackIso(pack: { bytes, value in
    guard value < instMap.count else { return }
    let item = instMap[value]
    let v = 0.set(bits: 0...7, value: item.inst).set(bits: 8...12, value: item.set)
    Proteus.pack(&bytes, parm: parm, value: v)
    
  }, unpack: { bytes in
    let v = Proteus.unpack(bytes, parm: parm) ?? 0
    let inst = v.bits(0...7)
    let set = v.bits(8...12)
    return reverseInstMap[set]?[inst] ?? 0
  })
}
    
const instMap = [
  [0, 0, "None"],
  [1, 0, "Piano"],
  [2, 0, "Piano Pad"],
  [3, 0, "Loose Piano"],
  [4, 0, "Tight Piano"],
  [5, 0, "Strings"],
  [6, 0, "Long Strings"],
  [7, 0, "Slow Strings"],
  [8, 0, "Dark Strings"],
  [9, 0, "Voices"],
  [10, 0, "Slow Voices"],
  [11, 0, "Dark Choir"],
  [12, 0, "Synth Flute"],
  [13, 0, "Soft Flute"],
  [14, 0, "Alto Sax"],
  [15, 0, "Tenor Sax"],
  [16, 0, "Baritone Sax "],
  [17, 0, "Dark Sax"],
  [18, 0, "Soft Trumpet "],
  [19, 0, "Dark Soft Trumpet"],
  [20, 0, "Hard Trumpet"],
  [21, 0, "Dark Hard Trumpet"],
  [22, 0, "Horn Falls"],
  [23, 0, "Trombone 1"],
  [24, 0, "Trombone 2"],
  [25, 0, "French Horn"],
  [26, 0, "Brass 1"],
  [27, 0, "Brass 2"],
  [28, 0, "Brass 3"],
  [29, 0, "Trombone/Sax"],
  [30, 0, "Guitar Mute"],
  [31, 0, "Electric Guitar"],
  [32, 0, "Acoustic Guitar"],
  [33, 0, "Rock Bass"],
  [34, 0, "Stone Bass"],
  [35, 0, "Flint Bass"],
  [36, 0, "Funk Slap"],
  [37, 0, "Funk Pop"],
  [38, 0, "Harmonics"],
  [39, 0, "Rock/Harmonics"],
  [40, 0, "Stone/Harmonics"],
  [41, 0, "Nose Bass"],
  [42, 0, "Bass Synth 1"],
  [43, 0, "Bass Synth 2"],
  [44, 0, "Synth Pad"],
  [45, 0, "Medium Envelope Pad "],
  [46, 0, "Long Envelope Pad"],
  [47, 0, "Dark Synth"],
  [48, 0, "Percussive Organ"],
  [49, 0, "Marimba"],
  [50, 0, "Vibraphone"],
  [51, 0, "All Percussion (balanced levels)"],
  [52, 0, "All Percussion (unbalanced levels)"],
  [53, 0, "Standard Percussion Setup 1"],
  [54, 0, "Standard Percussion Setup 2"],
  [55, 0, "Standard Percussion Setup 3"],
  [56, 0, "Kicks"],
  [57, 0, "Snares"],
  [58, 0, "Toms"],
  [59, 0, "Cymbals"],
  [60, 0, "Latin Drums"],
  [61, 0, "Latin Percussion"],
  [62, 0, "Agogo Bell"],
  [63, 0, "Woodblock"],
  [64, 0, "Conga"],
  [65, 0, "Timbale"],
  [66, 0, "Ride Cymbal"],
  [67, 0, "Percussion FX1"],
  [68, 0, "Percussion FX2"],
  [69, 0, "Metal"],
  [70, 0, "Oct 1 (Sine)"],
  [71, 0, "Oct 2 All"],
  [72, 0, "Oct 3 All"],
  [73, 0, "Oct 4 All"],
  [74, 0, "Oct 5 All"],
  [75, 0, "Oct 6 All"],
  [76, 0, "Oct 7 All"],
  [77, 0, "Oct 2 Odd"],
  [78, 0, "Oct 3 Odd"],
  [79, 0, "Oct 4 Odd"],
  [80, 0, "Oct 5 Odd"],
  [81, 0, "Oct 6 Odd"],
  [82, 0, "Oct 7 Odd"],
  [83, 0, "Oct 2 Even"],
  [84, 0, "Oct 3 Even"],
  [85, 0, "Oct 4 Even"],
  [86, 0, "Oct 5 Even"],
  [87, 0, "Oct 6 Even"],
  [88, 0, "Oct 7 Even"],
  [89, 0, "Low Odds"],
  [90, 0, "Low Evens"],
  [91, 0, "Four Octaves"],
  [92, 0, "Synth Cycle 1"],
  [93, 0, "Synth Cycle 2"],
  [94, 0, "Synth Cycle 3"],
  [95, 0, "Synth Cycle 4"],
  [96, 0, "Fundamental Gone 1"],
  [97, 0, "Fundamental Gone 2"],
  [98, 0, "Bite Cycle"],
  [99, 0, "Buzzy Cycle 1"],
  [100, 0, "Metalphone 1"],
  [101, 0, "Metalphone 2"],
  [102, 0, "Metalphone 3"],
  [103, 0, "Metalphone 4"],
  [104, 0, "Duck Cycle 1"],
  [105, 0, "Duck Cycle 2"],
  [106, 0, "Duck Cycle 3"],
  [107, 0, "Wind Cycle 1"],
  [108, 0, "Wind Cycle 2"],
  [109, 0, "Wind Cycle 3"],
  [110, 0, "Wind Cycle 4"],
  [111, 0, "Organ Cycle 1"],
  [112, 0, "Organ Cycle 2"],
  [113, 0, "Noise"],
  [114, 0, "Stray Voice 1"],
  [115, 0, "Stray Voice 2"],
  [116, 0, "Stray Voice 3"],
  [117, 0, "Stray Voice 4"],
  [118, 0, "Synth String 1"],
  [119, 0, "Synth String 2"],
  [120, 0, "Animals"],
  [121, 0, "Reed"],
  [122, 0, "Pluck 1"],
  [123, 0, "Pluck 2"],
  [124, 0, "Mallet 1"],
  [125, 0, "Mallet 2"],
]

const parms = Voice.createParms(instMap, 1)
const patchTruss = Voice.createPatchTruss(1, parms, "proteus1-voice-init")
const bankTruss = Voice.createBankTruss(patchTruss, "proteus1-voice-bank-init")

module.exports = {
  patchTruss,
  bankTruss,
}
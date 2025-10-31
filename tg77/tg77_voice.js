
static func location(forData data: Data) -> Int { return Int(data[31] & 0x3f) }
const fileDataCount = 466

// structure -> contentByteCount
const contentByteCounts: [Int] = {
  return [466, 832, 1564, 466, 832,
          221, 342, 584, 587, 1074,
          588].map { $0 - (32 + 2) }
}()

const headerString: String = "LM  8101VC"
func bytesForSysex() -> [UInt8] {
  let contentByteCount = type(of: self).contentByteCounts[Int(bytes[0])]
  return [UInt8](bytes[0..<contentByteCount])
}

func sysexData(channel: Int) -> Data {
  var b = type(of: self).headerString.unicodeScalars.map { UInt8($0.value) }
  b.append(contentsOf: [UInt8](repeating: 0, count: 14))
  b.append(contentsOf: [0x7f, 0x30]) // use 0x30 so that bigger structures still work?
  b.append(contentsOf: bytesForSysex())
  
  let byteCountMSB = UInt8((b.count >> 7) & 0x7f)
  let byteCountLSB = UInt8(b.count & 0x7f)
  var data = Data([0xf0, 0x43, UInt8(channel), 0x7a, byteCountMSB, byteCountLSB])
  data.append(contentsOf: b)
  data.append(type(of: self).checksum(bytes: b))
  data.append(0xf7)
  return data
}

var opOns = [Int](repeating: 1, count: 6)

required init(data: Data) {
  // 1530 is biggest possible size (4AFM)
  bytes = [UInt8](repeating: 0, count: 1530)
  guard data.count > 34 else { return }
  var byteIndex = 0
  data[32..<(data.count-2)].forEach {
    bytes[byteIndex] = $0
    byteIndex += 1
  }
}

var elementCount: Int { Self.elementCount(forStructure: bytes[0]) }

static func elementCount(forStructure structure: UInt8) -> Int {
  switch structure {
  case 0, 3, 5:
    return 1
  case 1, 4, 6, 8:
    return 2
  case 2, 7, 9:
    return 4
  default:
    return 0
  }
}

var firstElementOffset: Int {
  let elCount = elementCount
  switch elCount {
  case 1:
    return 75
  case 2:
    return 84
  case 4:
    return 102
  default:
    return 66
  }
}

var hasAFM: Bool { [0,1,2,3,4,8,9].contains(bytes[0]) }

func isElementFM(_ el: Int) -> Bool { Self.isElementFM(el, structure: bytes[0]) }

static func isElementFM(_ el: Int, structure: UInt8) -> Bool {
  switch el {
  case 0:
    return structure < 5 || structure >= 8
  case 1:
    return [1,2,4,9].contains(structure)
  default: // 3, 4
    return structure == 2
  }
}

func elementSize(_ el: Int) -> Int { isElementFM(el) ? afmElementSize : awmElementSize }

func elementOffset(_ el: Int) -> Int {
  var off = firstElementOffset
  (0..<el).forEach { off += elementSize($0) }
  return off
}

const afmElementSubpaths: [SynthPath] = elementSubpaths(mode: .fm)
const awmElementSubpaths: [SynthPath] = elementSubpaths(mode: .wave)

private static func elementSubpaths(mode: SynthPathItem) -> [SynthPath] {
  let commonPrefix: SynthPath = "element/0/common"
  let modePrefix: SynthPath = `element/0/${mode}`
  return TG77VoicePatch.paramKeys().compactMap {
    guard $0.starts(with: commonPrefix) || $0.starts(with: modePrefix) else { return nil }
    return $0.subpath(from: 2)
  }
}

/// Generate a dictionary of SynthPaths and values for a given element. SynthPaths do not have "element/" prefix
func values(forElement elem: Int) -> [SynthPath:Int]? {
  guard elem < elementCount else { return nil }
  let allPaths = isElementFM(elem) ? type(of: self).afmElementSubpaths : type(of: self).awmElementSubpaths
  return allPaths.dictionary { [$0 : self["element/elem" + $0]!] }
}

private let afmElementSize = 357
private let opSize = 45
private let opsTotalSize = 45 * 6
private let fmCommonSize = 26
private let awmElementSize = 112
private let awmCommonSize = 27 // size of non-amp, non-filter stuff
private let filterSize = 29
private let filtersTotalSize = 61 // 2 filters + filter common

public func byteIndex(forPath path: SynthPath) -> Int {
  guard let param = type(of: self).params[path],
    path.count > 0 else { return -1 }
  
  var byteIndex = param.byte
  
  switch path.first! {
  case .structure:
    byteIndex += 0
  case .common:
    byteIndex += 29
  case .fx:
    byteIndex += 11
  case .rhythm:
    byteIndex += 66
  default:
    // element
    guard let el = path.i(1) else { return -1 }
    let elOffset = elementOffset(el)
    switch path[2] {
    case .common:
      // 98, 107
      byteIndex += 66 + (9 * el)
    case .fm:
      switch path[3] {
      case .op:
        guard let op = path.i(4) else { return -1 }
        let opOffset = (5 - op) * opSize
        byteIndex += elOffset + opOffset
      case .common:
        byteIndex += elOffset + opsTotalSize
      default:
        // go to filter 0
        byteIndex += elOffset + opsTotalSize + fmCommonSize
        if let filter = path.i(4), filter == 1 {
          // go to filter 1
          byteIndex += filterSize
        }
        else if path[4] == .common {
          // filter common
          byteIndex += 2 * filterSize
        }
      }
    default:
      // .wave
      switch path[3] {
      case .amp:
        byteIndex += elOffset + awmCommonSize + filtersTotalSize - 27
      case .filter:
        // go to filter 0
        byteIndex += elOffset + awmCommonSize
        if let filter = path.i(4), filter == 1 {
          // go to filter 1
          byteIndex += filterSize
        }
        else if path[4] == .common {
          // filter common
          byteIndex += 2 * filterSize
        }
      default: // all non-amp, non-filter
        byteIndex += elOffset
      }
    }
  }
  
  return byteIndex
}

subscript(path: SynthPath) -> Int? {
  get {
    // op on
    if path.count == 6 && path[3] == .op && path[5] == .on {
      guard let op = path.i(4) else { return nil }
      return opOns[op]
    }
    
    let index = byteIndex(forPath: path)
    guard let param = type(of: self).params[path] as? TG33Param,
      index >= 0 else { return nil }
    
    let b = param.length == 2 ? Int((bytes[index] & 0x1) << 7) + Int(bytes[index+1]) : Int(bytes[index])
    
    if let bits = param.bits {
      return b.bits(bits)
    }
    else if let rangeParam = param as? ParamWithRange,
      rangeParam.range.lowerBound < 0 {
      return b > rangeParam.range.upperBound ? -b + (rangeParam.range.upperBound + 1) : b
    }
    else {
      return b
    }
  }
  set {
    // op on
    if path.count == 6 && path[3] == .op && path[5] == .on {
      guard let op = path.i(4), let newValue = newValue else { return }
      return opOns[op] = newValue
    }

    // if setting algo, set all of the related param values!
//      if path.last == .algo {
//        guard let elem = path.i(1),
//          let algo = newValue else { return }
//        guard algo < TG77Algorithms.paramValues.count else { return }
//        TG77Algorithms.paramValues[algo].forEach {
//          self["element/elem/fm/op" + $0.key] = $0.value
//        }
//      }

    
    let index = byteIndex(forPath: path)
    guard let newValue = newValue,
      let param = type(of: self).params[path] as? TG33Param,
      index >= 0 else { return }
    
    if param.length == 2 {
      if let bits = param.bits {
        if bits.upperBound == 7 {
          let bitLength = 1 + bits.upperBound - bits.lowerBound
          bytes[index] = bytes[index].set(bits: [0, 0], value: newValue >> (bitLength - 1))
          bytes[index+1] = bytes[index+1].set(bits: bits.lowerBound...6,
                                              value: newValue.bits(0...(bitLength-2)))
          return
        }
        else {
          bytes[index+1] = bytes[index+1].set(bits: bits, value: newValue)
          return
        }
      }
      else {
        let bVal = newValue < 0 ? UInt8(bitPattern: Int8(newValue)) : UInt8(newValue)
        bytes[index] = bVal >> 7
        bytes[index+1] = bVal & 0x7f
        return
      }
    }
    else {
      if let bits = param.bits {
        return bytes[index] = bytes[index].set(bits: bits, value: newValue)
      }
      else if let rangeParam = param as? ParamWithRange,
        rangeParam.range.lowerBound < 0 {
        return bytes[index] = newValue < 0 ? UInt8(-newValue + (rangeParam.range.upperBound + 1)) : UInt8(newValue)
      }
      else {
        return bytes[index] = UInt8(newValue)
      }
    }
  }
}

static func paramChange(forElement elem: Int, algorithm: Int) -> PatchChange? {
  guard algorithm < TG77Algorithms.paramValues.count else { return nil }
  var dict = [SynthPath:Int]()
  TG77Algorithms.paramValues[algorithm].forEach {
    dict["element/elem/fm/op" + $0.key] = $0.value
  }
  return MakeParamsChange(dict)
}


private const fixeds = [0, 6, 11, 17, 23, 29, 34, 40, 46, 51, 57, 63, 69, 74, 80, 86, 92, 97, 103, 109, 114, 120, 126, 132, 137, 143, 149, 154, 160, 166, 172, 177, 183, 186, 195, 200, 206, 212, 217, 223, 229, 235, 240, 246, 252, 257, 263, 275, 280, 286, 292, 298, 309, 315, 320, 332, 338, 349, 355, 366, 372, 383, 395, 401, 412, 423, 435, 446, 458, 469, 481, 492, 504, 515, 526, 544, 555, 566, 584, 595, 612, 629, 641, 658, 675, 692, 710, 727, 744, 761, 778, 801, 818, 841, 864, 881, 904, 927, 950, 973]

public static func freqRatio(fixedMode: Bool, coarse: Int, fine: Int) -> String {
  if fixedMode {
    let c = min(coarse, 4)
    let freq: Float
    if c == 0 {
      guard fine < fixeds.count else { return "?" }
      freq = Float(fixeds[fine]) / 1000
    }
    else {
      freq = powf(10, Float(c-1)) * exp(Float(M_LN10) * (Float(fine)/100))
    }
    return String(format:"%.4g", freq)
  }
  else {
    // ratio mode
    return DX7Patch.freqRatio(fixedMode: fixedMode, coarse: coarse, fine: fine)
  }
}


func randomize() {
  self["structure"] = ([0, 10]).random()!
  randomizeKeepingStructure()
}

func randomizeKeepingStructure() {

  // only iterate on our keys based on structure
  for key in paramKeys() {
    guard key != "structure" else { continue }
    guard let param = type(of: self).param(key) else { continue }
    self[key] = param.randomize()
  }
  
  self["common/volume"] = 127
  self["common/porta"] = 0
  self["common/porta/time"] = 0
  self["common/out/select"] = 0

  // each element
  (0..<elementCount).forEach { el in
    // Element Common
    do {
      let pre: SynthPath = "element/el/common"
      self[pre + "level"] = 127
      self[pre + "note/shift"] = 64
      self[pre + "note/lo"] = 0
      self[pre + "note/hi"] = 127
      self[pre + "velo/lo"] = 1
      self[pre + "velo/hi"] = 127
      self[pre + "out/0"] = 1
      self[pre + "out/1"] = 1
      self[pre + "pan"] = ([32, 95]).random()! // skip user pan tables

      randomizeElement(el)
      
      // FILTER
      let m: SynthPathItem = isElementFM(el) ? .fm : .wave
      (0..<2).forEach { filter in
        let pre: SynthPath = `element/el/${m}/filter/filter`
        self[pre + "type"] = 0
      }
    }
  }
  
  if self["structure"]! == 10 {
    ([0, 61]).forEach { drum in
      let pre: SynthPath = "rhythm/drum"
      self[pre + "out/select"] = 0
      self[pre + "out/0"] = 1
      self[pre + "out/1"] = 1
      self[pre + "wave/src"] = 0
      self[pre + "volume"] = ([100, 127]).random()!
      self[pre + "note/shift"] = ([48, 72]).random()!
    }
  }
}

func randomizeElement(_ el: Int) {
  if isElementFM(el) {
    randomizeAFM(el)
  }
  else {
    randomizeAWM(el)
  }
}

private func randomizeAFM(_ el: Int) {
  // find the output ops and set level 4 to 0
  let algos = TG77VoicePatch.algorithms()
  let algoIndex = self["element/el/fm/common/algo"] ?? 0
  let algo = algos[algoIndex]
  
  // load template patch for this algo
  let algoPatch = `tg77a-${algoIndex+1}`
  guard let dataAsset = PBDataAsset(name: algoPatch) else { return }
  let p = TG77VoicePatch(data: dataAsset.data)

  // AFM Common
  do {
    let pre: SynthPath = "element/el/fm/common"
    self[pre + "pitch/env/level/-1"] = 64
    self[pre + "pitch/env/level/0"] = 64
    self[pre + "pitch/env/level/1"] = 64
    self[pre + "pitch/env/level/2"] = 64
    self[pre + "pitch/env/release/level/0"] = 64
    self[pre + "lfo/0/pitch"] = ([0, 10]).random()!
//      self[pre + "lfo/0/amp"] =
//      self[pre + "lfo/0/filter"] =
    self[pre + "lfo/1/pitch"] = 0
  }
  
  
  // AFM Ops
  (0..<6).forEach { op in
    let pre: SynthPath = "element/el/fm/op/op"
    let algoPre: SynthPath = "element/0/fm/op/op"
    
    self[pre + "on"] = 1
    
    self[pre + "hold/time"] = 63

    // copy algo bits from template patch
    self[pre + "src/0"] = p[algoPre + "src/0"]
    self[pre + "src/1"] = p[algoPre + "src/1"]
    self[pre + "dest"] = p[algoPre + "dest"]
    self[pre + "src/0/shift"] = p[algoPre + "src/0/shift"]
    self[pre + "src/1/shift"] = p[algoPre + "src/1/shift"]
    self[pre + "feedback/src/0"] = p[algoPre + "feedback/src/0"]
    self[pre + "feedback/src/1"] = p[algoPre + "feedback/src/1"]
    self[pre + "adjust/level"] = p[algoPre + "adjust/level"]

    //      self[pre + "pitch/mod"] = 0
    
    self[pre + "level/scale/offset/0"] = 128
    self[pre + "level/scale/offset/1"] = 128
    self[pre + "level/scale/offset/2"] = 128
    self[pre + "level/scale/offset/3"] = 128
  }
  
  for outputId in algo.outputOps {
    let op: SynthPath = "element/el/fm/op/outputId"
    self[op + "level/-1"] = 0
    self[op + "level/0"] = 57+([0, 6]).random()!
    self[op + "rate/0"] = 47+([0, 16]).random()!
    self[op + "level/1"] = 47+([0, 16]).random()!
    self[op + "level/2"] = 47+([0, 16]).random()!
    self[op + "level/3"] = 47+([0, 16]).random()!
    self[op + "release/level/0"] = 0
    self[op + "release/rate/0"] = 30+([0, 33]).random()!
    self[op + "release/level/1"] = 0
    self[op + "release/rate/1"] = 30+([0, 33]).random()!
    self[op + "level"] = 127
    self[op + "amp/mod"] = 0
  }
  
  // for one out, make it harmonic and louder
  let randomOut = algo.outputOps[(0..<algo.outputOps.count).random()!]
  let op: SynthPath = "element/el/fm/op/randomOut"
  self[op + "osc/mode"] = 0
  self[op + "fine"] = 0
  self[op + "coarse"] = 1
  self[op + "detune"] = 0
}


private func randomizeAWM(_ el: Int) {
  do {
    let pre: SynthPath = "element/el/wave"
    self[pre + "src"] = 0
//      self[pre + "wave"] =
//      self[pre + "freq/mode"] = TG33OptionsParam(parm: parm, parm2: 0x0002, byte: 3, options: ["Normal", "Fixed"])
//      self[pre + "fixed/note"] = TG33RangeParam(parm: parm, parm2: 0x0003, byte: 4)
//      self[pre + "freq/fine"] = TG33RangeParam(parm: parm, parm2: 0x0004, byte: 5, displayOffset: -64)
    self[pre + "pitch/env/level/-1"] = 64
    self[pre + "pitch/env/level/0"] = 64
    self[pre + "pitch/env/level/1"] = 64
    self[pre + "pitch/env/level/2"] = 64
    self[pre + "pitch/env/release/level/0"] = 64
    self[pre + "lfo/0/pitch"] = ([0, 10]).random()!
//      self[pre + "lfo/0/amp"] = TG33RangeParam(parm: parm, parm2: 0x0015, byte: 22)
//      self[pre + "lfo/0/filter"] = TG33RangeParam(parm: parm, parm2: 0x0016, byte: 23)
//      self[pre + "amp/env/mode"] = TG33OptionsParam(parm: parm, parm2: 0x004f, byte: 27, options: ["Normal", "Hold"])
    self[pre + "amp/env/rate/0"] = ([40, 63]).random()!
//      self[pre + "amp/env/rate/1"] = TG33RangeParam(parm: parm, parm2: 0x0051, byte: 29, maxVal: 63)
//      self[pre + "amp/env/rate/2"] = TG33RangeParam(parm: parm, parm2: 0x0052, byte: 30, maxVal: 63)
//      self[pre + "amp/env/rate/3"] = TG33RangeParam(parm: parm, parm2: 0x0053, byte: 31, maxVal: 63)
//      self[pre + "amp/env/release/rate/0"] = TG33RangeParam(parm: parm, parm2: 0x0054, byte: 32, maxVal: 63)
//      self[pre + "amp/env/level/1"] = TG33RangeParam(parm: parm, parm2: 0x0055, byte: 33, maxVal: 63)
//      self[pre + "amp/env/level/2"] = TG33RangeParam(parm: parm, parm2: 0x0056, byte: 34, maxVal: 63)
    self[pre + "amp/level/scale/offset/0"] = 128
    self[pre + "amp/level/scale/offset/1"] = 128
    self[pre + "amp/level/scale/offset/2"] = 128
    self[pre + "amp/level/scale/offset/3"] = 128
    self[pre + "amp/velo"] = ([0, 7]).random()!
  }

}

static func paramKeys(forStructure structure: UInt8) -> [SynthPath] {
  let elCount = elementCount(forStructure: structure)
  let isFM = (0..<elCount).map { isElementFM($0, structure: structure) }
  return params.compactMap { (key, param) in
    if structure == 10 {
      // drums
      let goodKeys: [SynthPathItem] = "rhythm/fx/structure"
      let goodPaths: [SynthPath] = ["common/volume/ctrl", "common/volume/range", "common/volume"]
      if goodKeys.contains(key[0]) {
        return key
      }
      else if goodPaths.contains(key) {
        return key
      }

      return nil
    }
    else {
      // non-elements keys are always present
      guard key[0] != .rhythm else { return nil }
      guard key[0] == .element else { return key }
      
      // check element exists in this structure
      guard let el = key.i(1), el < elCount else { return nil }
      
      if key[2] == .fm && isFM[el] {
        return key
      }
      else if key[2] == .wave && !isFM[el] {
        return key
      }
      else if key[2] == .common {
        return key
      }
      return nil
    }
  }
}

const structureParamKeys: [[SynthPath]] = ([0, 10]).map { paramKeys(forStructure: $0) }

func paramKeys() -> [SynthPath] {
  return type(of: self).structureParamKeys[Int(bytes[0])]
}

func allValues() -> SynthPathInts {
  var v = SynthPathInts()
  for key in paramKeys() {
    guard let value = self[key] else { continue }
    v[key] = value
  }
  return v
}
  
const structureOptions = ["1AFM mono", "2AFM mono", "4AFM mono", "1 AFM poly", "2 AFM poly", "1AWM poly", "2AWM poly", "4AWM poly", "1AFM 1AWM poly", "2AFM 2AWM poly", "Drum Set"]

const indivOutOptions = ([0, 8].map {
  $0 == 0 ? "Off" : `${$0}`
})

const microOptions = ["Internal 1", "Internal 2"] + TG77MicrotunePatch.presetOptions

const chorusOptions = ["0: Through","1: Chorus","2: Flanger","3: Symphonic", "4: Tremolo"]

const algoOptions = (45).map(i =>  `tg77-algo-${$0+1}` )

const fxModeOptions = (4).map(i =>  `tg77-fx-mode-${$0}` )

const reverbOptions = ["0: Through", "1: Reverb Hall", "2: Reverb Room", "3: Reverb Plate", "4: Reverb Church", "5: Reverb Club", "6: Reverb Stage", "7: Reverb Bathroom", "8: Reverb Metal", "9: Single Delay", "10: Delay L, R", "11: Stereo Echo", "12: Doubler 1", "13: Doubler 2", "14: Ping-Pong Echo", "15: Pan Reflection", "16: Early Relection", "17: Gate Reverb", "18: Reverse Gate", "19: Feedb. Early Refl.", "20: Feedbk Gate", "21: Feedbk Reverse", "22: Single Delay & Reverb", "23: Delay L/R & Reverb", "24: Tunnel Reverb", "25: Tone Control 1", "26: Single Delay + Tone Ctrl 1", "27: Delay L/R + Tone Ctrl 1", "28: Tone Ctrl 2", "29: Single Delay + Tone Ctrl 2", "30: Delay L/R + Tone Ctrl 2", "31: Distort + Reverb", "32: Distort + Single Delay", "33: Distort + Delay L/R", "34: Distortion", "35: Ind Delay", "36: Ind Tone Control", "37: Ind Distortion", "38: Ind Reverb", "39: Ind Delay & Reverb", "40: Ind Reverb & Delay"]

const ctrlOptions = ([0, 121].map {
  return $0 == 121 ? "Aftertouch" : `CC ${$0}`
})

// 6,7,8 are FB src 1,2,3
// 10 is noise?
// 2 is AWM?
// 9,1 seem to be from algo (hard-code)
// 3,4 is also hard-code
// 0 is open
// algo hard-coded feedback appears same as user-progged (6,7,8)
const inSrcOptions: [Int:String] = [
  0 : "Off",
  2 : "AWM",
  6 : "FB1",
  7 : "FB2",
  8 : "FB3",
  10 : "Noise",
]

const bpIso = Miso.noteName(zeroNote: "C-2")

const afmWaveOptions = (16).map(i =>  `tg77-fm-wave-${$0+1}` )

const lfoWaveOptions = ["Triangle", "Saw Down", "Saw Up", "Square", "Sine", "Sample&Hold"]

const subLFOWaveOptions = ["Triangle", "Saw Down", "Square", "Sample&Hold"]

const blankWaveOptions = (0..<128.map {
  return `Wave ${$0 + 1}`
})

const waveSourceOptions = ["Preset", "Card", "AFM"]

const waveOptions = ["1: Piano", "2: Trumpet", "3: Mute Tp", "4: Horn", "5: Flugel", "6: Trombone", "7: Brass", "8: Flute", "9: Clarinet", "10: Tenor Sax", "11: Alto Sax", "12: GtrSteel", "13: EG Sngl", "14: EG Humbk", "15: EG Harmo", "16: EG mute", "17: E.Bass", "18: Thumping", "19: Popping", "20: Fretless", "21: Wood Bass", "22: Shamisen", "23: Koto", "24: Violin", "25: Pizz", "26: Strings", "27: AnlgBass", "28: Anlg Brs", "29: Chorus", "30: Itopia", "31: Vib", "32: Marimba", "33: Tubular", "34: Cele Wv", "35: HarpsiWv", "36: E.P. Wv", "37: Pipe Wv", "38: Organ Wv", "39: Tuba Wv", "40: Picco Wv", "41: S.Sax Wv", "42: BassonWv", "43: Reco Wv", "44: MuteTpWv", "45: GutWv", "46: 12Str Wv", "47: Bass Wv", "48: Cello Wv", "49: ContraWv", "50: Xylo Wv", "51: Glock Wv", "52: Harp Wv", "53: Sitar Wv", "54: StlDrmWv", "55: MtReedWv", "56: OhAttack", "57: AnlgSaw1", "58: AnlgSaw2", "59: Digital1", "60: Digital2", "61: Digital3", "62: Pulse 10", "63: Pulse 25", "64: Pulse 50", "65: Tri", "66: Piano Np", "67: E.P. Np", "68: Vibe Np", "69: DmpPiano", "70: Bottle 1", "71: Bottle 2", "72: Bottle 3", "73: Tube", "74: Vocal Ga", "75: Vocal Ba", "76: Sax trans", "77: Bow trans", "78: Bulb", "79: Tear", "80: Bamboo", "81: Cup Echo", "82: Digi Atk", "83: Temp Ra", "84: Giri", "85: Water", "86: Steam", "87: Narrow", "88: Airy", "89: Styroll", "90: Noise", "91: Bell mix", "92: Haaa", "93: BD1", "94: BD2", "95: BD3", "96: BD4", "97: SD1", "98: SD2", "99: SD3", "100: SD roll", "101: Rim", "102: Tom 1", "103: Tom 2", "104: HHclosed", "105: HH open", "106: Crash", "107: Ride", "108: Claps", "109: Cowbell", "110: Tmbrn", "111: Shaker", "112: Analg Perc"]

const chorusParamDefaults: [[Int]] = [
  [9, 99, 20, 0],
  [5, 65, 30, 0],
  [11, 60, 6, 35],
  [3, 80, 0, 0],
  [24, 50, 2, 0],
]

const reverbParamDefaults: [[Int]] = [
  [20, 0, 6],
  [20, 9, 29],
  [12, 9, 20],
  [15, 9, 10],
  [24, 6, 48],
  [15, 8, 20],
  [19, 5, 10],
  [12, 11, 16],
  [19, 14, 10],
  [25, 25, 20],
  [32, 64, 0],
  [30, 32, 36],
  [20, 0, 6],
  [32, 64, 6],
  [38, 18, 64],
  [25, 20, 0],
  [19, 13, 20],
  [21, 13, 20],
  [21, 13, 20],
  [19, 13, 48],
  [21, 13, 48],
  [21, 13, 48],
  [16, 38, 70],
  [12, 19, 38],
  [20, 38, 70],
  [7, 6, 5],
  [8, 38, 0],
  [8, 74, 48],
  [1, 6, 12],
  [1, 50, 48],
  [2, 50, 48],
  [20, 100, 50],
  [75, 30, 100],
  [75, 51, 100],
  [100, 0, 7],
  [38, 35, 30],
  [7, 5, 6],
  [100, 100, 6],
  [20, 16, 7],
  [38, 64, 20],
  [20, 38, 64],
]


// seems like parm1 and parm2 are swapped vs TG33 here.
// parm2 keeps changing while parm1 is fixed (vice versa for TG33)
const parms = [
  ["structure", { p: 0x0200, parm2: 0x0000, b: 0, opts: structureOptions }],
  ["common/bend", { p: 0x0200, parm2: 0x0028, b: 11, max: 12 }],
  ["common/aftertouch/bend", { p: 0x0200, parm2: 0x0029, b: 12, rng: [-12, 12] }],
  ["common/pitch/ctrl", { p: 0x0200, parm2: 0x002a, b: 13, opts: ctrlOptions }],
  ["common/pitch/range", { p: 0x0200, parm2: 0x002b, b: 14 }],
  ["common/amp/ctrl", { p: 0x0200, parm2: 0x002c, b: 15, opts: ctrlOptions }],
  ["common/amp/range", { p: 0x0200, parm2: 0x002d, b: 16 }],
  ["common/filter/ctrl", { p: 0x0200, parm2: 0x002e, b: 17, opts: ctrlOptions }],
  ["common/filter/range", { p: 0x0200, parm2: 0x002f, b: 18 }],
  ["common/pan/ctrl", { p: 0x0200, parm2: 0x0030, b: 19, opts: ctrlOptions }],
  ["common/pan/range", { p: 0x0200, parm2: 0x0031, b: 20 }],
  ["common/filter/bias/ctrl", { p: 0x0200, parm2: 0x0032, b: 21, opts: ctrlOptions }],
  ["common/filter/bias/range", { p: 0x0200, parm2: 0x0033, b: 22 }],
  ["common/pan/bias/ctrl", { p: 0x0200, parm2: 0x0034, b: 23, opts: ctrlOptions }],
  ["common/pan/bias/range", { p: 0x0200, parm2: 0x0035, b: 24 }],
  ["common/env/bias/ctrl", { p: 0x0200, parm2: 0x0036, b: 25, opts: ctrlOptions }],
  ["common/env/bias/range", { p: 0x0200, parm2: 0x0037, b: 26 }],
  ["common/volume/ctrl", { p: 0x0200, parm2: 0x0038, b: 27, opts: ctrlOptions }],
  ["common/volume/range", { p: 0x0200, parm2: 0x0039, b: 28 }],
  ["common/micro", { p: 0x0200, parm2: 0x003a, b: 29, opts: microOptions }],
  ["common/random/pitch", { p: 0x0200, parm2: 0x003b, b: 30, max: 7 }],
  ["common/porta", { p: 0x0200, parm2: 0x003c, b: 31, opts: ["Fingered", "Full Time"] }],
  ["common/porta/time", { p: 0x0200, parm2: 0x003d, b: 32 }],
  ["common/out/select", { p: 0x0200, parm2: 0x003e, b: 33, opts: indivOutOptions }],
  ["common/volume", { p: 0x0200, parm2: 0x003f, b: 34 }],
  
  { prefix: 'element', count: 4, px: 32, block: [
    ["common/level", { p: 0x0300, parm2: 0x0000, b: 0 }],
    ["common/detune", { p: 0x0300, parm2: 0x0001, b: 1, rng: [-7, 7] }],
    ["common/note/shift", { p: 0x0300, parm2: 0x0002, b: 2, dispOff: -64 }],
    ["common/note/lo", { p: 0x0300, parm2: 0x0003, b: 3 }],
    ["common/note/hi", { p: 0x0300, parm2: 0x0004, b: 4 }],
    ["common/velo/lo", { p: 0x0300, parm2: 0x0005, b: 5, rng: [1, 127] }],
    ["common/velo/hi", { p: 0x0300, parm2: 0x0006, b: 6 }],
    ["common/pan", { p: 0x0300, parm2: 0x0007, b: 7, max: 95 }],
    ["common/micro", { p: 0x0300, parm2: 0x0008, b: 8, bit: 0 }],
    ["common/out/0", { p: 0x0300, parm2: 0x0008, b: 8, bit: 1 }],
    ["common/out/1", { p: 0x0300, parm2: 0x0008, b: 8, bit: 2 }],
    { prefix: 'fm/common', block: [
      ["algo", { p: 0x0500, parm2: 0x0000, b: 0, opts: algoOptions }],
      ["pitch/env/rate/0", { p: 0x0500, parm2: 0x0001, b: 1, max: 63 }],
      ["pitch/env/rate/1", { p: 0x0500, parm2: 0x0002, b: 2, max: 63 }],
      ["pitch/env/rate/2", { p: 0x0500, parm2: 0x0003, b: 3, max: 63 }],
      ["pitch/env/release/rate/0", { p: 0x0500, parm2: 0x0004, b: 4, max: 63 }],
      ["pitch/env/level/-1", { p: 0x0500, parm2: 0x0005, b: 5, dispOff: -64 }],
      ["pitch/env/level/0", { p: 0x0500, parm2: 0x0006, b: 6, dispOff: -64 }],
      ["pitch/env/level/1", { p: 0x0500, parm2: 0x0007, b: 7, dispOff: -64 }],
      ["pitch/env/level/2", { p: 0x0500, parm2: 0x0008, b: 8, dispOff: -64 }],
      ["pitch/env/release/level/0", { p: 0x0500, parm2: 0x0009, b: 9, dispOff: -64 }],
      ["pitch/env/range", { p: 0x0500, parm2: 0x000a, b: 10, opts: ["8oct", "2oct", "1oct", "1/2oct"] }],
      ["pitch/rate/scale", { p: 0x0500, parm2: 0x000b, b: 11, rng: [-7, 7] }],
      ["pitch/velo", { p: 0x0500, parm2: 0x000c, b: 12, max: 1 }],
      ["lfo/0/speed", { p: 0x0500, parm2: 0x000d, b: 13, max: 99 }],
      ["lfo/0/delay", { p: 0x0500, parm2: 0x000e, b: 14, max: 99 }],
      ["lfo/0/pitch", { p: 0x0500, parm2: 0x000f, b: 15 }],
      ["lfo/0/amp", { p: 0x0500, parm2: 0x0010, b: 16 }],
      ["lfo/0/filter", { p: 0x0500, parm2: 0x0011, b: 17 }],
      ["lfo/0/wave", { p: 0x0500, parm2: 0x0012, b: 18, opts: lfoWaveOptions }],
      ["lfo/0/phase", { p: 0x0500, parm2: 0x0013, b: 19, max: 99 }],
      ["lfo/1/wave", { p: 0x0500, parm2: 0x0015, b: 21, opts: subLFOWaveOptions }],
      ["lfo/1/speed", { p: 0x0500, parm2: 0x0016, b: 22 }],
      ["lfo/1/delay/mode", { p: 0x0500, parm2: 0x0017, b: 23, opts: ["Delay", "Decay"] }],
      ["lfo/1/delay/time", { p: 0x0500, parm2: 0x0018, b: 24, max: 99 }],
      ["lfo/1/pitch", { p: 0x0500, parm2: 0x0019, b: 25 }],
    ] },
    { prefix: 'fm', block: [
      { prefix: 'op', count: 6, block: (i) => {
        const p = ((((5 - op) << 4) + 6) << 8)
        return [
          ["on", { p: 0x0500, parm2: 0x7f7f, b: -1, max: 1 }],
          ["rate/0", { p: p, parm2: 0x0000, b: 0, max: 63 }],
          ["rate/1", { p: p, parm2: 0x0001, b: 1, max: 63 }],
          ["rate/2", { p: p, parm2: 0x0002, b: 2, max: 63 }],
          ["rate/3", { p: p, parm2: 0x0003, b: 3, max: 63 }],
          ["release/rate/0", { p: p, parm2: 0x0004, b: 4, max: 63 }],
          ["release/rate/1", { p: p, parm2: 0x0005, b: 5, max: 63 }],
          ["level/0", { p: p, parm2: 0x0006, b: 6, max: 63 }],
          ["level/1", { p: p, parm2: 0x0007, b: 7, max: 63 }],
          ["level/2", { p: p, parm2: 0x0008, b: 8, max: 63 }],
          ["level/3", { p: p, parm2: 0x0009, b: 9, max: 63 }],
          ["release/level/0", { p: p, parm2: 0x000a, b: 10, max: 63 }],
          ["release/level/1", { p: p, parm2: 0x000b, b: 11, max: 63 }],
          ["loop/pt", { p: p, parm2: 0x000c, b: 12, max: 3, dispOff: 1 }],
          ["hold/time", { p: p, parm2: 0x000d, b: 13, max: 63 }],
          ["level/-1", { p: p, parm2: 0x000e, b: 14, max: 63 }],
          ["rate/scale", { p: p, parm2: 0x000f, b: 15, rng: [-7, 7] }],
          ["amp/mod", { p: p, parm2: 0x0010, b: 16, max: 7 }],
          ["velo", { p: p, parm2: 0x0011, b: 17, rng: [-7, 7] }],
          ["src/0", { p: p, parm2: 0x0013, b: 19, length: 2, bits: [0, 3], opts: inSrcOptions }],
          ["src/1", { p: p, parm2: 0x0013, b: 19, length: 2, bits: [4, 7], opts: inSrcOptions }],
          // dest is 1,2,3 for feedback sources
          ["dest", { p: p, parm2: 0x0014, b: 21, bits: [0, 1], max: 3 }],
          ["feedback/src/0", { p: p, parm2: 0x0014, b: 21, bits: [2, 3], max: 2 }],
          ["feedback/src/1", { p: p, parm2: 0x0014, b: 21, bit: 4 }],
          // these 2 shifts aren't auto-changed by algo change
          ["src/0/shift", { p: p, parm2: 0x0015, b: 22, bits: [0, 2], max: 7 }],
          ["src/1/shift", { p: p, parm2: 0x0015, b: 22, bits: [3, 5], max: 7 }],
          ["adjust/level", { p: p, parm2: 0x0016, b: 23, max: 7 }],
          ["wave", { p: p, parm2: 0x0017, b: 24, opts: afmWaveOptions }],
          ["pitch/mod", { p: p, parm2: 0x0018, b: 25, bits: [2, 4], max: 7 }],
          ["pitch/env", { p: p, parm2: 0x0018, b: 25, bit: 1 }],
          ["osc/mode", { p: p, parm2: 0x0018, b: 25, bit: 0 }],
          ["phase/on", { p: p, parm2: 0x0019, b: 26, max: 1 }],
          ["phase", { p: p, parm2: 0x0019, b: 27, bits: [0, 6] }],
          ["detune", { p: p, parm2: 0x001a, b: 28, rng: [-15, 15] }],
          ["level", { p: p, parm2: 0x001b, b: 29 }],
          ["level/scale/pt/0", { p: p, parm2: 0x001c, b: 30, iso: bpIso }],
          ["level/scale/pt/1", { p: p, parm2: 0x001d, b: 31, iso: bpIso }],
          ["level/scale/pt/2", { p: p, parm2: 0x001e, b: 32, iso: bpIso }],
          ["level/scale/pt/3", { p: p, parm2: 0x001f, b: 33, iso: bpIso }],
          ["level/scale/offset/0", { p: p, parm2: 0x0020, b: 34, length: 2, rng: [1, 255], dispOff: -128 }],
          ["level/scale/offset/1", { p: p, parm2: 0x0021, b: 36, length: 2, rng: [1, 255], dispOff: -128 }],
          ["level/scale/offset/2", { p: p, parm2: 0x0022, b: 38, length: 2, rng: [1, 255], dispOff: -128 }],
          ["level/scale/offset/3", { p: p, parm2: 0x0023, b: 40, length: 2, rng: [1, 255], dispOff: -128 }],
          ["rate/velo", { p: p, parm2: 0x0024, b: 42, max: 1 }],
          ["coarse", { p: p, parm2: 0x0025, b: 43, max: 31 }],
          ["fine", { p: p, parm2: 0x0026, b: 44, max: 99 }],
        ]
      } },
    ] },
    
    { prefix: 'wave', block: [
      { p: 0x0700, fixed: [
        ["src", { parm2: 0x0000, b: 0, opts: waveSourceOptions }],
        ["wave", { parm2: 0x0001, b: 1, length: 2, opts: waveOptions }],
        ["freq/mode", { parm2: 0x0002, b: 3, opts: ["Normal", "Fixed"] }],
        ["fixed/note", { parm2: 0x0003, b: 4 }],
        ["freq/fine", { parm2: 0x0004, b: 5, dispOff: -64 }],
        ["pitch/mod", { parm2: 0x0005, b: 6, max: 7 }],
        ["pitch/env/rate/0", { parm2: 0x0006, b: 7, max: 63 }],
        ["pitch/env/rate/1", { parm2: 0x0007, b: 8, max: 63 }],
        ["pitch/env/rate/2", { parm2: 0x0008, b: 9, max: 63 }],
        ["pitch/env/release/rate/0", { parm2: 0x0009, b: 10, max: 63 }],
        ["pitch/env/level/-1", { parm2: 0x000a, b: 11, dispOff: -64 }],
        ["pitch/env/level/0", { parm2: 0x000b, b: 12, dispOff: -64 }],
        ["pitch/env/level/1", { parm2: 0x000c, b: 13, dispOff: -64 }],
        ["pitch/env/level/2", { parm2: 0x000d, b: 14, dispOff: -64 }],
        ["pitch/env/release/level/0", { parm2: 0x000e, b: 15, dispOff: -64 }],
        ["pitch/env/range", { parm2: 0x000f, b: 16, opts: ["2oct", "1oct", "1/2oct"] }],
        ["pitch/rate/scale", { parm2: 0x0010, b: 17, rng: [-7, 7] }],
        ["pitch/velo", { parm2: 0x0011, b: 18, max: 1 }],
        ["lfo/0/speed", { parm2: 0x0012, b: 19, max: 99 }],
        ["lfo/0/delay", { parm2: 0x0013, b: 20, max: 99 }],
        ["lfo/0/pitch", { parm2: 0x0014, b: 21 }],
        ["lfo/0/amp", { parm2: 0x0015, b: 22 }],
        ["lfo/0/filter", { parm2: 0x0016, b: 23 }],
        ["lfo/0/wave", { parm2: 0x0017, b: 24, opts: lfoWaveOptions }],
        ["lfo/0/phase", { parm2: 0x0018, b: 25, max: 99 }],
        ["amp/env/mode", { parm2: 0x004f, b: 27, opts: ["Normal", "Hold"] }],
        ["amp/env/rate/0", { parm2: 0x0050, b: 28, max: 63 }],
        ["amp/env/rate/1", { parm2: 0x0051, b: 29, max: 63 }],
        ["amp/env/rate/2", { parm2: 0x0052, b: 30, max: 63 }],
        ["amp/env/rate/3", { parm2: 0x0053, b: 31, max: 63 }],
        ["amp/env/release/rate/0", { parm2: 0x0054, b: 32, max: 63 }],
        ["amp/env/level/1", { parm2: 0x0055, b: 33, max: 63 }],
        ["amp/env/level/2", { parm2: 0x0056, b: 34, max: 63 }],
        ["amp/rate/scale", { parm2: 0x0057, b: 35, rng: [-7, 7] }],
        ["amp/level/scale/pt/0", { parm2: 0x0058, b: 36, iso: bpIso }],
        ["amp/level/scale/pt/1", { parm2: 0x0059, b: 37, iso: bpIso }],
        ["amp/level/scale/pt/2", { parm2: 0x005a, b: 38, iso: bpIso }],
        ["amp/level/scale/pt/3", { parm2: 0x005b, b: 39, iso: bpIso }],
        ["amp/level/scale/offset/0", { parm2: 0x0005c, b: 40, length: 2, rng: [1, 255], dispOff: -128 }],
        ["amp/level/scale/offset/1", { parm2: 0x005d, b: 42, length: 2, rng: [1, 255], dispOff: -128 }],
        ["amp/level/scale/offset/2", { parm2: 0x005e, b: 44, length: 2, rng: [1, 255], dispOff: -128 }],
        ["amp/level/scale/offset/3", { parm2: 0x005f, b: 46, length: 2, rng: [1, 255], dispOff: -128 }],
        ["amp/velo", { parm2: 0x0060, b: 48, rng: [-7, 7] }],
        ["amp/attack/velo", { parm2: 0x0061, b: 49, max: 1 }],
        ["amp/mod", { parm2: 0x0062, b: 50, rng: [-7, 7] }],
      ] },
    ] },
    
    { prefixes: ['fm', 'wave'], px: 3, block: [
      { prefix: 'filter', count: 2, block: [
        { p: 0x0900, fixed: [
          ["type", { parm2: 0x0000, b: 0, opts: ["Thru", "LPF", "HPF"] }],
          ["cutoff", { parm2: 0x0001, b: 1 }],
          ["mode", { parm2: 0x0002, b: 2, opts: ["EG", "LFO", "EG-VA"] }],
          ["env/rate/0", { parm2: 0x0003, b: 3, max: 63 }],
          ["env/rate/1", { parm2: 0x0004, b: 4, max: 63 }],
          ["env/rate/2", { parm2: 0x0005, b: 5, max: 63 }],
          ["env/rate/3", { parm2: 0x0006, b: 6, max: 63 }],
          ["env/release/rate/0", { parm2: 0x0007, b: 7, max: 63 }],
          ["env/release/rate/1", { parm2: 0x0008, b: 8, max: 63 }],
          ["env/level/-1", { parm2: 0x0009, b: 9, dispOff: -64 }],
          ["env/level/0", { parm2: 0x000a, b: 10, dispOff: -64 }],
          ["env/level/1", { parm2: 0x000b, b: 11, dispOff: -64 }],
          ["env/level/2", { parm2: 0x000c, b: 12, dispOff: -64 }],
          ["env/level/3", { parm2: 0x000d, b: 13, dispOff: -64 }],
          ["env/release/level/0", { parm2: 0x000e, b: 14, dispOff: -64 }],
          ["env/release/level/1", { parm2: 0x000f, b: 15, dispOff: -64 }],
          ["rate/scale", { parm2: 0x0010, b: 16, rng: [-7, 7] }],
          ["level/scale/pt/0", { parm2: 0x0011, b: 17, iso: bpIso }],
          ["level/scale/pt/1", { parm2: 0x0012, b: 18, iso: bpIso }],
          ["level/scale/pt/2", { parm2: 0x0013, b: 19, iso: bpIso }],
          ["level/scale/pt/3", { parm2: 0x0014, b: 20, iso: bpIso }],
          ["level/scale/offset/0", { parm2: 0x0015, b: 21, length: 2, rng: [1, 255], dispOff: -128 }],
          ["level/scale/offset/1", { parm2: 0x0016, b: 23, length: 2, rng: [1, 255], dispOff: -128 }],
          ["level/scale/offset/2", { parm2: 0x0017, b: 25, length: 2, rng: [1, 255], dispOff: -128 }],
          ["level/scale/offset/3", { parm2: 0x0018, b: 27, length: 2, rng: [1, 255], dispOff: -128 }],
        ] },
      ] },
      ["reson", { p: 0x0902, parm2: 0x0032, b: 0, max: 99 }],
      ["velo", { p: 0x0902, parm2: 0x0033, b: 1, rng: [-7, 7] }],
      ["mod", { p: 0x0902, parm2: 0x0034, b: 2, rng: [-7, 7] }],
    ] },
    
  ] },
  
  // FX
  ["fx/mode", { p: 0x0800, parm2: 0x0000, b: 0, opts: fxModeOptions }],
  { prefix: 'fx/chorus', count: 2, bx: 7, block: (i) => {
    const off = i * 7
    return [
      ["type", { p: 0x0800, parm2: 0x0001 + off, b: 1, opts: chorusOptions }],
      ["balance", { p: 0x0800, parm2: 0x0002 + off, b: 2, max: 100 }],
      ["level", { p: 0x0800, parm2: 0x0003 + off, b: 3, max: 100 }],
      ["param/0", { p: 0x0800, parm2: 0x0004 + off, b: 4 }],
      ["param/1", { p: 0x0800, parm2: 0x0005 + off, b: 5 }],
      ["param/2", { p: 0x0800, parm2: 0x0006 + off, b: 6 }],
      ["param/3", { p: 0x0800, parm2: 0x0007 + off, b: 7 }],
    ]
  } },
  { prefix: 'fx/reverb', count: 2, bx: 6, block: (i) => {
    const off = i * 6
    return [
      ["type", { p: 0x0800, parm2: 0x000f + off, b: 15, opts: reverbOptions }],
      ["balance", { p: 0x0800, parm2: 0x0010 + off, b: 16, max: 100 }],
      ["level", { p: 0x0800, parm2: 0x0011 + off, b: 17, max: 100 }],
      ["param/0", { p: 0x0800, parm2: 0x0012 + off, b: 18 }],
      ["param/1", { p: 0x0800, parm2: 0x0013 + off, b: 19 }],
      ["param/2", { p: 0x0800, parm2: 0x0014 + off, b: 20 }],
    ]
  } }  
  ["fx/mix/0", { p: 0x0800, parm2: 0x001b, b: 27, max: 1 }],
  ["fx/mix/1", { p: 0x0800, parm2: 0x001c, b: 28, max: 1 }],
  { prefix: 'rhythm/drum', count: 62, bx: 8, block: (i) => {
    const p = 0x0400 + i + 36
    return [
      ["alt/group", { p: p, parm2: 0x0000, b: 0, bit: 6 }],
      ["out/select", { p: p, parm2: 0x0000, b: 0, bits: [2, 5], max: 8 }],
      ["out/0", { p: p, parm2: 0x0000, b: 0, bit: 0 }],
      ["out/1", { p: p, parm2: 0x0000, b: 0, bit: 1 }],
      ["wave/src", { p: p, parm2: 0x0001, b: 1, opts: ["Preset", "Card"] }],
      ["wave/wave", { p: p, parm2: 0x0002, b: 2, length: 2, opts: waveOptions }],
      ["volume", { p: p, parm2: 0x0003, b: 4 }],
      ["fine", { p: p, parm2: 0x0004, b: 5, dispOff: -64 }],
      ["note/shift", { p: p, parm2: 0x0005, b: 6, rng: [16, 100], dispOff: -64 }],
      ["pan", { p: p, parm2: 0x0006, b: 7, max: 62, dispOff: -31 }],
    ]
  } },
]


const patchTruss = {
  single: 'voice',
  namePack: [1, 10],
  initFile: "tg77-voice-init",
  validSizes: [466,832,1564,221,342,584,587,1074,588],
}

const bankTruss = {
  singleBank: patchTruss,
  patchCount: 64,
  initFile: "tg77-voice-bank-init",
}

const patchTransform = (location) => ({
  throttle: 100,
  param: (path, parm, value) => {
    let v: Int
    if param.byte < 0 {
      // op on
      guard let el = path.i(1) else { return nil }
      v = (0..<6).map {
        guard patch[[.element, .i(el), .fm, .op, .i($0), .on]] == 1 else { return 0 }
        return 1 << (5 - $0)
        }.reduce(0, +)
    }
    else if value < 0 {
      let upper = (param as? ParamWithRange)?.range.upperBound ?? 0
      v = -value + upper + 1
    }
    else if param.parm2 == 0x0019 && param.byte > 25 {
      // phase is weird
      var byteIndex = patch.byteIndex(forPath: path)
      if param.bits != nil { byteIndex -= 1 }
      v = Int(((patch.bytes[byteIndex] & 1) << 7) + patch.bytes[byteIndex + 1])
    }
    else if param.bits != nil {
      // grab the whole byte from the patch instead
      let byteIndex = patch.byteIndex(forPath: path)
      let b = param.length == 2 ? ((patch.bytes[byteIndex] & 0x1) << 7) + patch.bytes[byteIndex+1] : patch.bytes[byteIndex]
      v = Int(b)
    }
    else {
      v = value
    }
    return [self.paramData(param: param, value: v)]
  },
  singlePatch: [[sysexData, 10]],
  name: (patch, path, name) -> [Data]? in
  return TG77VoicePatch.nameByteRange.map {
    self.paramData(parm: 0x0200, parm2: Int($0), value: Int(patch.bytes[$0]))
    },
})

const bankTransform = {
  throttle: 0,
  singleBank: loc => [[sysexData(loc), 50]],
}


class TG77VoiceBank : TypicalTypedSysexPatchBank<TG77VoicePatch> {
    
  override func fileData() -> Data {
    return sysexData { $0.sysexData(channel: 0, location: $1) }
  }
  
  override class func isCompleteFetch(sysex: Data) -> Bool {
    return isValid(sysex: sysex)
  }

  override class func isValid(fileSize: Int) -> Bool {
    // there are so many possibilities of valid file sizes, we're fudging.
    return fileSize >= 221 * 64
  }

  override class func isValid(sysex: Data) -> Bool {
    // smallest possible
    guard sysex.count >= 221 * 64 else { return false }
    
    let s = SysexData(data: sysex)
    guard s.count == 64 else { return false }
    for msg in s {
      guard TG77VoicePatch.isValid(fileSize: msg.count) else { return false }
    }
    return true
  }

  
  static let emptyBankOptions = OptionsParam.makeOptions((1...64).map { "\($0)" })
    
}

const preset1 = ["A1. SP|Cosmo", "A2. SP:Metroid", "A3. SP:Diamond", "A4. SP.Sqrpad", "A5. SP|Arianne", "A6. SP:Sawpad", "A7. SP:Darkpad", "A8. SP|Mystery", "A9. SP.Padfaze", "A10. SP:Twilite", "A11. SP|Annapad", "A12. AP.Ivory", "A13. AP|CP77", "A14. AP|Bright", "A15. AP|Hammer", "A16. AP|Grand", "B1. BR:Plucky", "B2. BR|BigBand", "B3. BR:1980", "B4. BR|Trmpets", "B5. BR.ModSyn", "B6. BR|Ensembl", "B7. BR|FrHorn", "B8. BR|Soul", "B9. BR.FM Bite", "B10. EP|IceRing", "B11. EP.Synbord", "B12. EP.GS77", "B13. EP|Knocker", "B14. EP.Beltine", "B15. EP|Dynomod", "B16. EP.Urbane", "C1. ME:St.Mick", "C2. ME|Blad", "C3. ME|Forest", "C4. ME.Gargoyl", "C5. ME|Pikloop", "C6. ME|Aquavox", "C7. ME:Alps", "C8. ME.Cycles", "C9. WN.Bluharp", "C10. WN|Tenor", "C11. WN|Clarino", "C12. WN|AltoSax", "C13. WN|Moothie", "C14. WN|Saxion", "C15. WN.Flute", "C16. WN|Ohboy", "D1. ST.Ripper", "D2. ST:Violins", "D3. ST|Section", "D4. ST.SynStrg", "D5. ST.Chamber", "D6. BA|Frtless", "D7. BA|Starred", "D8. BA.HardOne", "D9. BA:VC1", "D10. BA:VC2", "D11. BA.VC3", "D12. BA.Rox", "D13. BA|Woodbas", "D14. BA.Round", "D15. BA:Erix", "D16. BA.FMFrtls"]

const preset2 = ["A1. SC:Neworld", "A2. SC.Stratos", "A3. SC.Ripples", "A4. SC.Digitak", "A5. SC.Hone", "A6. SC:Spaces", "A7. SC|Sybaby", "A8. SC|Icedrop", "A9. SC|Wired", "A10. SL.Gnome", "A11. SL.SawMono", "A12. SL:SqrMono", "A13. SL.Pro77", "A14. SL.Nester", "A15. SL:Eazy", "A16. SL:Lips", "B1. KY|Bosh", "B2. KY|Wahclav", "B3. KY.Wires", "B4. KY:Tradclv", "B5. KY.Thumper", "B6. KY|Modclav", "B7. PL.Sitar", "B8. PL.Harp", "B9. PL|Saratog", "B10. PL|Steel", "B11. PL|Twelve", "B12. PL|Shonuff", "B13. PL|MutGtr", "B14. PL.Guitar", "B15. PL.Shami", "B16. PL:Koto", "C1. OR.YC45D", "C2. OR|Pipes", "C3. OR:Jazzman", "C4. OR.Combo", "C5. PC.Marimba", "C6. PC|OzHamer", "C7. PC:Tobago", "C8. PC.Vibes", "C9. PC|Glass", "C10. PC|Island", "C11. PC|GrtWall", "C12. CH.Itopia", "C13. CH:GaChoir", "C14. CH:Chamber", "C15. CH|Spirit", "C16. CH:ChorMst", "D1. SE*Goto>1", "D2. SE.Xpander", "D3. SE*Inferno", "D4. SE*Them!!!", "D5. OR*Gassman", "D6. BR*ZapBras", "D7. BR*BrasOrc", "D8. PL*Stairwy", "D9. ST*Widestg", "D10. ST*Symflow", "D11. ST*Quartet", "D12. ST*Tutti", "D13. ME*Voyager", "D14. ME*Galaxia", "D15. DR Both", "D16. DR Group2"]

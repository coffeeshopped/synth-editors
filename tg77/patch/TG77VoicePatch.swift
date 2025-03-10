
class TG77VoicePatch : TG77Patch, Algorithmic, BankablePatch {
  
  static func algorithms() -> [DXAlgorithm] {
    return TG77Algorithms.all
  }
  
  static let bankType: SysexPatchBank.Type = TG77VoiceBank.self
  static func location(forData data: Data) -> Int { return Int(data[31] & 0x3f) }

  static let nameByteRange = 1..<11
  static let initFileName = "tg77-voice-init"
  static let fileDataCount = 466
  
  static let fileSizes = [466,832,1564,221,342,584,587,1074,588]
  // different sizes depending on structure
  static func isValid(fileSize: Int) -> Bool {
    return fileSizes.contains(fileSize)
  }
  
  // structure -> contentByteCount
  static let contentByteCounts: [Int] = {
    return [466, 832, 1564, 466, 832,
            221, 342, 584, 587, 1074,
            588].map { $0 - (32 + 2) }
  }()

  static let headerString: String = "LM  8101VC"
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

  
  var bytes: [UInt8]
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
  
  static let afmElementSubpaths: [SynthPath] = elementSubpaths(mode: .fm)
  static let awmElementSubpaths: [SynthPath] = elementSubpaths(mode: .wave)

  private static func elementSubpaths(mode: SynthPathItem) -> [SynthPath] {
    let commonPrefix: SynthPath = [.element, .i(0), .common]
    let modePrefix: SynthPath = [.element, .i(0), mode]
    return TG77VoicePatch.paramKeys().compactMap {
      guard $0.starts(with: commonPrefix) || $0.starts(with: modePrefix) else { return nil }
      return $0.subpath(from: 2)
    }
  }

  /// Generate a dictionary of SynthPaths and values for a given element. SynthPaths do not have [.element, .i()] prefix
  func values(forElement elem: Int) -> [SynthPath:Int]? {
    guard elem < elementCount else { return nil }
    let allPaths = isElementFM(elem) ? type(of: self).afmElementSubpaths : type(of: self).awmElementSubpaths
    return allPaths.dictionary { [$0 : self[[.element, .i(elem)] + $0]!] }
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
//          self[[.element, .i(elem), .fm, .op] + $0.key] = $0.value
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
            bytes[index] = bytes[index].set(bits: 0...0, value: newValue >> (bitLength - 1))
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
      dict[[.element, .i(elem), .fm, .op] + $0.key] = $0.value
    }
    return MakeParamsChange(dict)
  }

  
  private static let fixeds = [0, 6, 11, 17, 23, 29, 34, 40, 46, 51, 57, 63, 69, 74, 80, 86, 92, 97, 103, 109, 114, 120, 126, 132, 137, 143, 149, 154, 160, 166, 172, 177, 183, 186, 195, 200, 206, 212, 217, 223, 229, 235, 240, 246, 252, 257, 263, 275, 280, 286, 292, 298, 309, 315, 320, 332, 338, 349, 355, 366, 372, 383, 395, 401, 412, 423, 435, 446, 458, 469, 481, 492, 504, 515, 526, 544, 555, 566, 584, 595, 612, 629, 641, 658, 675, 692, 710, 727, 744, 761, 778, 801, 818, 841, 864, 881, 904, 927, 950, 973]
  
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
    self[[.structure]] = (0...10).random()!
    randomizeKeepingStructure()
  }
  
  func randomizeKeepingStructure() {

    // only iterate on our keys based on structure
    for key in paramKeys() {
      guard key != [.structure] else { continue }
      guard let param = type(of: self).param(key) else { continue }
      self[key] = param.randomize()
    }
    
    self[[.common, .volume]] = 127
    self[[.common, .porta]] = 0
    self[[.common, .porta, .time]] = 0
    self[[.common, .out, .select]] = 0

    // each element
    (0..<elementCount).forEach { el in
      // Element Common
      do {
        let pre: SynthPath = [.element, .i(el), .common]
        self[pre + [.level]] = 127
        self[pre + [.note, .shift]] = 64
        self[pre + [.note, .lo]] = 0
        self[pre + [.note, .hi]] = 127
        self[pre + [.velo, .lo]] = 1
        self[pre + [.velo, .hi]] = 127
        self[pre + [.out, .i(0)]] = 1
        self[pre + [.out, .i(1)]] = 1
        self[pre + [.pan]] = (32...95).random()! // skip user pan tables

        randomizeElement(el)
        
        // FILTER
        let m: SynthPathItem = isElementFM(el) ? .fm : .wave
        (0..<2).forEach { filter in
          let pre: SynthPath = [.element, .i(el), m, .filter, .i(filter)]
          self[pre + [.type]] = 0
        }
      }
    }
    
    if self[[.structure]]! == 10 {
      (0...61).forEach { drum in
        let pre: SynthPath = [.rhythm, .i(drum)]
        self[pre + [.out, .select]] = 0
        self[pre + [.out, .i(0)]] = 1
        self[pre + [.out, .i(1)]] = 1
        self[pre + [.wave, .src]] = 0
        self[pre + [.volume]] = (100...127).random()!
        self[pre + [.note, .shift]] = (48...72).random()!
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
    let algoIndex = self[[.element, .i(el), .fm, .common, .algo]] ?? 0
    let algo = algos[algoIndex]
    
    // load template patch for this algo
    let algoPatch = "tg77a-\(algoIndex+1)"
    guard let dataAsset = PBDataAsset(name: algoPatch) else { return }
    let p = TG77VoicePatch(data: dataAsset.data)

    // AFM Common
    do {
      let pre: SynthPath = [.element, .i(el), .fm, .common]
      self[pre + [.pitch, .env, .level, .i(-1)]] = 64
      self[pre + [.pitch, .env, .level, .i(0)]] = 64
      self[pre + [.pitch, .env, .level, .i(1)]] = 64
      self[pre + [.pitch, .env, .level, .i(2)]] = 64
      self[pre + [.pitch, .env, .release, .level, .i(0)]] = 64
      self[pre + [.lfo, .i(0), .pitch]] = (0...10).random()!
//      self[pre + [.lfo, .i(0), .amp]] =
//      self[pre + [.lfo, .i(0), .filter]] =
      self[pre + [.lfo, .i(1), .pitch]] = 0
    }
    
    
    // AFM Ops
    (0..<6).forEach { op in
      let pre: SynthPath = [.element, .i(el), .fm, .op, .i(op)]
      let algoPre: SynthPath = [.element, .i(0), .fm, .op, .i(op)]
      
      self[pre + [.on]] = 1
      
      self[pre + [.hold, .time]] = 63

      // copy algo bits from template patch
      self[pre + [.src, .i(0)]] = p[algoPre + [.src, .i(0)]]
      self[pre + [.src, .i(1)]] = p[algoPre + [.src, .i(1)]]
      self[pre + [.dest]] = p[algoPre + [.dest]]
      self[pre + [.src, .i(0), .shift]] = p[algoPre + [.src, .i(0), .shift]]
      self[pre + [.src, .i(1), .shift]] = p[algoPre + [.src, .i(1), .shift]]
      self[pre + [.feedback, .src, .i(0)]] = p[algoPre + [.feedback, .src, .i(0)]]
      self[pre + [.feedback, .src, .i(1)]] = p[algoPre + [.feedback, .src, .i(1)]]
      self[pre + [.adjust, .level]] = p[algoPre + [.adjust, .level]]

      //      self[pre + [.pitch, .mod]] = 0
      
      self[pre + [.level, .scale, .offset, .i(0)]] = 128
      self[pre + [.level, .scale, .offset, .i(1)]] = 128
      self[pre + [.level, .scale, .offset, .i(2)]] = 128
      self[pre + [.level, .scale, .offset, .i(3)]] = 128
    }
    
    for outputId in algo.outputOps {
      let op: SynthPath = [.element, .i(el), .fm, .op, .i(outputId)]
      self[op + [.level, .i(-1)]] = 0
      self[op + [.level, .i(0)]] = 57+(0...6).random()!
      self[op + [.rate, .i(0)]] = 47+(0...16).random()!
      self[op + [.level, .i(1)]] = 47+(0...16).random()!
      self[op + [.level, .i(2)]] = 47+(0...16).random()!
      self[op + [.level, .i(3)]] = 47+(0...16).random()!
      self[op + [.release, .level, .i(0)]] = 0
      self[op + [.release, .rate, .i(0)]] = 30+(0...33).random()!
      self[op + [.release, .level, .i(1)]] = 0
      self[op + [.release, .rate, .i(1)]] = 30+(0...33).random()!
      self[op + [.level]] = 127
      self[op + [.amp, .mod]] = 0
    }
    
    // for one out, make it harmonic and louder
    let randomOut = algo.outputOps[(0..<algo.outputOps.count).random()!]
    let op: SynthPath = [.element, .i(el), .fm, .op, .i(randomOut)]
    self[op + [.osc, .mode]] = 0
    self[op + [.fine]] = 0
    self[op + [.coarse]] = 1
    self[op + [.detune]] = 0
  }

  
  private func randomizeAWM(_ el: Int) {
    do {
      let pre: SynthPath = [.element, .i(el), .wave]
      self[pre + [.src]] = 0
//      self[pre + [.wave]] =
//      self[pre + [.freq, .mode]] = TG33OptionsParam(parm: parm, parm2: 0x0002, byte: 3, options: ["Normal", "Fixed"])
//      self[pre + [.fixed, .note]] = TG33RangeParam(parm: parm, parm2: 0x0003, byte: 4)
//      self[pre + [.freq, .fine]] = TG33RangeParam(parm: parm, parm2: 0x0004, byte: 5, displayOffset: -64)
      self[pre + [.pitch, .env, .level, .i(-1)]] = 64
      self[pre + [.pitch, .env, .level, .i(0)]] = 64
      self[pre + [.pitch, .env, .level, .i(1)]] = 64
      self[pre + [.pitch, .env, .level, .i(2)]] = 64
      self[pre + [.pitch, .env, .release, .level, .i(0)]] = 64
      self[pre + [.lfo, .i(0), .pitch]] = (0...10).random()!
//      self[pre + [.lfo, .i(0), .amp]] = TG33RangeParam(parm: parm, parm2: 0x0015, byte: 22)
//      self[pre + [.lfo, .i(0), .filter]] = TG33RangeParam(parm: parm, parm2: 0x0016, byte: 23)
//      self[pre + [.amp, .env, .mode]] = TG33OptionsParam(parm: parm, parm2: 0x004f, byte: 27, options: ["Normal", "Hold"])
      self[pre + [.amp, .env, .rate, .i(0)]] = (40...63).random()!
//      self[pre + [.amp, .env, .rate, .i(1)]] = TG33RangeParam(parm: parm, parm2: 0x0051, byte: 29, maxVal: 63)
//      self[pre + [.amp, .env, .rate, .i(2)]] = TG33RangeParam(parm: parm, parm2: 0x0052, byte: 30, maxVal: 63)
//      self[pre + [.amp, .env, .rate, .i(3)]] = TG33RangeParam(parm: parm, parm2: 0x0053, byte: 31, maxVal: 63)
//      self[pre + [.amp, .env, .release, .rate, .i(0)]] = TG33RangeParam(parm: parm, parm2: 0x0054, byte: 32, maxVal: 63)
//      self[pre + [.amp, .env, .level, .i(1)]] = TG33RangeParam(parm: parm, parm2: 0x0055, byte: 33, maxVal: 63)
//      self[pre + [.amp, .env, .level, .i(2)]] = TG33RangeParam(parm: parm, parm2: 0x0056, byte: 34, maxVal: 63)
      self[pre + [.amp, .level, .scale, .offset, .i(0)]] = 128
      self[pre + [.amp, .level, .scale, .offset, .i(1)]] = 128
      self[pre + [.amp, .level, .scale, .offset, .i(2)]] = 128
      self[pre + [.amp, .level, .scale, .offset, .i(3)]] = 128
      self[pre + [.amp, .velo]] = (0...7).random()!
    }

  }
  
  static func paramKeys(forStructure structure: UInt8) -> [SynthPath] {
    let elCount = elementCount(forStructure: structure)
    let isFM = (0..<elCount).map { isElementFM($0, structure: structure) }
    return params.compactMap { (key, param) in
      if structure == 10 {
        // drums
        let goodKeys: [SynthPathItem] = [.rhythm, .fx, .structure]
        let goodPaths: [SynthPath] = [[.common, .volume, .ctrl], [.common, .volume, .range], [.common, .volume]]
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
  
  static let structureParamKeys: [[SynthPath]] = (0...10).map { paramKeys(forStructure: $0) }
  
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
  
  static let params: SynthPathParam = {
    var p = SynthPathParam()
    
    p[[.structure]] = TG33OptionsParam(parm: 0x0200, parm2: 0x0000, byte: 0, options: structureOptions)
    p[[.common, .bend]] = TG33RangeParam(parm: 0x0200, parm2: 0x0028, byte: 11, maxVal: 12)
    p[[.common, .aftertouch, .bend]] = TG33RangeParam(parm: 0x0200, parm2: 0x0029, byte: 12, range: -12...12)
    p[[.common, .pitch, .ctrl]] = TG33OptionsParam(parm: 0x0200, parm2: 0x002a, byte: 13, options: ctrlOptions)
    p[[.common, .pitch, .range]] = TG33RangeParam(parm: 0x0200, parm2: 0x002b, byte: 14)
    p[[.common, .amp, .ctrl]] = TG33OptionsParam(parm: 0x0200, parm2: 0x002c, byte: 15, options: ctrlOptions)
    p[[.common, .amp, .range]] = TG33RangeParam(parm: 0x0200, parm2: 0x002d, byte: 16)
    p[[.common, .filter, .ctrl]] = TG33OptionsParam(parm: 0x0200, parm2: 0x002e, byte: 17, options: ctrlOptions)
    p[[.common, .filter, .range]] = TG33RangeParam(parm: 0x0200, parm2: 0x002f, byte: 18)
    p[[.common, .pan, .ctrl]] = TG33OptionsParam(parm: 0x0200, parm2: 0x0030, byte: 19, options: ctrlOptions)
    p[[.common, .pan, .range]] = TG33RangeParam(parm: 0x0200, parm2: 0x0031, byte: 20)
    p[[.common, .filter, .bias, .ctrl]] = TG33OptionsParam(parm: 0x0200, parm2: 0x0032, byte: 21, options: ctrlOptions)
    p[[.common, .filter, .bias, .range]] = TG33RangeParam(parm: 0x0200, parm2: 0x0033, byte: 22)
    p[[.common, .pan, .bias, .ctrl]] = TG33OptionsParam(parm: 0x0200, parm2: 0x0034, byte: 23, options: ctrlOptions)
    p[[.common, .pan, .bias, .range]] = TG33RangeParam(parm: 0x0200, parm2: 0x0035, byte: 24)
    p[[.common, .env, .bias, .ctrl]] = TG33OptionsParam(parm: 0x0200, parm2: 0x0036, byte: 25, options: ctrlOptions)
    p[[.common, .env, .bias, .range]] = TG33RangeParam(parm: 0x0200, parm2: 0x0037, byte: 26)
    p[[.common, .volume, .ctrl]] = TG33OptionsParam(parm: 0x0200, parm2: 0x0038, byte: 27, options: ctrlOptions)
    p[[.common, .volume, .range]] = TG33RangeParam(parm: 0x0200, parm2: 0x0039, byte: 28)
    p[[.common, .micro]] = TG33OptionsParam(parm: 0x0200, parm2: 0x003a, byte: 29, options: microOptions)
    p[[.common, .random, .pitch]] = TG33RangeParam(parm: 0x0200, parm2: 0x003b, byte: 30, maxVal: 7)
    p[[.common, .porta]] = TG33OptionsParam(parm: 0x0200, parm2: 0x003c, byte: 31, options: ["Fingered", "Full Time"])
    p[[.common, .porta, .time]] = TG33RangeParam(parm: 0x0200, parm2: 0x003d, byte: 32)
    p[[.common, .out, .select]] = TG33OptionsParam(parm: 0x0200, parm2: 0x003e, byte: 33, options: indivOutOptions)
    p[[.common, .volume]] = TG33RangeParam(parm: 0x0200, parm2: 0x003f, byte: 34)
    
    
    (0...3).forEach { el in
      // Element Common
      do {
        let parm = 0x0300 + (el << 5)
        let pre: SynthPath = [.element, .i(el), .common]
        p[pre + [.level]] = TG33RangeParam(parm: parm, parm2: 0x0000, byte: 0)
        p[pre + [.detune]] = TG33RangeParam(parm: parm, parm2: 0x0001, byte: 1, range: -7...7)
        p[pre + [.note, .shift]] = TG33RangeParam(parm: parm, parm2: 0x0002, byte: 2, displayOffset: -64)
        p[pre + [.note, .lo]] = TG33RangeParam(parm: parm, parm2: 0x0003, byte: 3)
        p[pre + [.note, .hi]] = TG33RangeParam(parm: parm, parm2: 0x0004, byte: 4)
        p[pre + [.velo, .lo]] = TG33RangeParam(parm: parm, parm2: 0x0005, byte: 5, range: 1...127)
        p[pre + [.velo, .hi]] = TG33RangeParam(parm: parm, parm2: 0x0006, byte: 6)
        p[pre + [.pan]] = TG33RangeParam(parm: parm, parm2: 0x0007, byte: 7, maxVal: 95)
        p[pre + [.micro]] = TG33RangeParam(parm: parm, parm2: 0x0008, byte: 8, bit: 0)
        p[pre + [.out, .i(0)]] = TG33RangeParam(parm: parm, parm2: 0x0008, byte: 8, bit: 1)
        p[pre + [.out, .i(1)]] = TG33RangeParam(parm: parm, parm2: 0x0008, byte: 8, bit: 2)
      }
      
      
      // AFM Common
      do {
        let parm = 0x0500 + (el << 5)
        let pre: SynthPath = [.element, .i(el), .fm, .common]
        p[pre + [.algo]] = TG33OptionsParam(parm: parm, parm2: 0x0000, byte: 0, options: algoOptions)
        p[pre + [.pitch, .env, .rate, .i(0)]] = TG33RangeParam(parm: parm, parm2: 0x0001, byte: 1, maxVal: 63)
        p[pre + [.pitch, .env, .rate, .i(1)]] = TG33RangeParam(parm: parm, parm2: 0x0002, byte: 2, maxVal: 63)
        p[pre + [.pitch, .env, .rate, .i(2)]] = TG33RangeParam(parm: parm, parm2: 0x0003, byte: 3, maxVal: 63)
        p[pre + [.pitch, .env, .release, .rate, .i(0)]] = TG33RangeParam(parm: parm, parm2: 0x0004, byte: 4, maxVal: 63)
        p[pre + [.pitch, .env, .level, .i(-1)]] = TG33RangeParam(parm: parm, parm2: 0x0005, byte: 5, displayOffset: -64)
        p[pre + [.pitch, .env, .level, .i(0)]] = TG33RangeParam(parm: parm, parm2: 0x0006, byte: 6, displayOffset: -64)
        p[pre + [.pitch, .env, .level, .i(1)]] = TG33RangeParam(parm: parm, parm2: 0x0007, byte: 7, displayOffset: -64)
        p[pre + [.pitch, .env, .level, .i(2)]] = TG33RangeParam(parm: parm, parm2: 0x0008, byte: 8, displayOffset: -64)
        p[pre + [.pitch, .env, .release, .level, .i(0)]] = TG33RangeParam(parm: parm, parm2: 0x0009, byte: 9, displayOffset: -64)
        p[pre + [.pitch, .env, .range]] = TG33OptionsParam(parm: parm, parm2: 0x000a, byte: 10, options: ["8oct", "2oct", "1oct", "1/2oct"])
        p[pre + [.pitch, .rate, .scale]] = TG33RangeParam(parm: parm, parm2: 0x000b, byte: 11, range: -7...7)
        p[pre + [.pitch, .velo]] = TG33RangeParam(parm: parm, parm2: 0x000c, byte: 12, maxVal: 1)
        p[pre + [.lfo, .i(0), .speed]] = TG33RangeParam(parm: parm, parm2: 0x000d, byte: 13, maxVal: 99)
        p[pre + [.lfo, .i(0), .delay]] = TG33RangeParam(parm: parm, parm2: 0x000e, byte: 14, maxVal: 99)
        p[pre + [.lfo, .i(0), .pitch]] = TG33RangeParam(parm: parm, parm2: 0x000f, byte: 15)
        p[pre + [.lfo, .i(0), .amp]] = TG33RangeParam(parm: parm, parm2: 0x0010, byte: 16)
        p[pre + [.lfo, .i(0), .filter]] = TG33RangeParam(parm: parm, parm2: 0x0011, byte: 17)
        p[pre + [.lfo, .i(0), .wave]] = TG33OptionsParam(parm: parm, parm2: 0x0012, byte: 18, options: lfoWaveOptions)
        p[pre + [.lfo, .i(0), .phase]] = TG33RangeParam(parm: parm, parm2: 0x0013, byte: 19, maxVal: 99)
        p[pre + [.lfo, .i(1), .wave]] = TG33OptionsParam(parm: parm, parm2: 0x0015, byte: 21, options: subLFOWaveOptions)
        p[pre + [.lfo, .i(1), .speed]] = TG33RangeParam(parm: parm, parm2: 0x0016, byte: 22)
        p[pre + [.lfo, .i(1), .delay, .mode]] = TG33OptionsParam(parm: parm, parm2: 0x0017, byte: 23, options: ["Delay", "Decay"])
        p[pre + [.lfo, .i(1), .delay, .time]] = TG33RangeParam(parm: parm, parm2: 0x0018, byte: 24, maxVal: 99)
        p[pre + [.lfo, .i(1), .pitch]] = TG33RangeParam(parm: parm, parm2: 0x0019, byte: 25)
      }


      // AFM Ops
      (0..<6).forEach { op in
        let parm = ((((5 - op) << 4) + 6) << 8) + (el << 5)
        let pre: SynthPath = [.element, .i(el), .fm, .op, .i(op)]
        
        let onParm = 0x0500 + (el << 5)
        p[pre + [.on]] = TG33RangeParam(parm: onParm, parm2: 0x7f7f, byte: -1, maxVal: 1)

        p[pre + [.rate, .i(0)]] = TG33RangeParam(parm: parm, parm2: 0x0000, byte: 0, maxVal: 63)
        p[pre + [.rate, .i(1)]] = TG33RangeParam(parm: parm, parm2: 0x0001, byte: 1, maxVal: 63)
        p[pre + [.rate, .i(2)]] = TG33RangeParam(parm: parm, parm2: 0x0002, byte: 2, maxVal: 63)
        p[pre + [.rate, .i(3)]] = TG33RangeParam(parm: parm, parm2: 0x0003, byte: 3, maxVal: 63)
        p[pre + [.release, .rate, .i(0)]] = TG33RangeParam(parm: parm, parm2: 0x0004, byte: 4, maxVal: 63)
        p[pre + [.release, .rate, .i(1)]] = TG33RangeParam(parm: parm, parm2: 0x0005, byte: 5, maxVal: 63)
        p[pre + [.level, .i(0)]] = TG33RangeParam(parm: parm, parm2: 0x0006, byte: 6, maxVal: 63)
        p[pre + [.level, .i(1)]] = TG33RangeParam(parm: parm, parm2: 0x0007, byte: 7, maxVal: 63)
        p[pre + [.level, .i(2)]] = TG33RangeParam(parm: parm, parm2: 0x0008, byte: 8, maxVal: 63)
        p[pre + [.level, .i(3)]] = TG33RangeParam(parm: parm, parm2: 0x0009, byte: 9, maxVal: 63)
        p[pre + [.release, .level, .i(0)]] = TG33RangeParam(parm: parm, parm2: 0x000a, byte: 10, maxVal: 63)
        p[pre + [.release, .level, .i(1)]] = TG33RangeParam(parm: parm, parm2: 0x000b, byte: 11, maxVal: 63)
        p[pre + [.loop, .pt]] = TG33RangeParam(parm: parm, parm2: 0x000c, byte: 12, maxVal: 3, displayOffset: 1)
        p[pre + [.hold, .time]] = TG33RangeParam(parm: parm, parm2: 0x000d, byte: 13, maxVal: 63)
        p[pre + [.level, .i(-1)]] = TG33RangeParam(parm: parm, parm2: 0x000e, byte: 14, maxVal: 63)
        p[pre + [.rate, .scale]] = TG33RangeParam(parm: parm, parm2: 0x000f, byte: 15, range: -7...7)
        p[pre + [.amp, .mod]] = TG33RangeParam(parm: parm, parm2: 0x0010, byte: 16, maxVal: 7)
        p[pre + [.velo]] = TG33RangeParam(parm: parm, parm2: 0x0011, byte: 17, range: -7...7)
        p[pre + [.src, .i(0)]] = TG33OptionsParam(parm: parm, parm2: 0x0013, byte: 19, length: 2, bits: 0...3, options: inSrcOptions)
        p[pre + [.src, .i(1)]] = TG33OptionsParam(parm: parm, parm2: 0x0013, byte: 19, length: 2, bits: 4...7, options: inSrcOptions)
        // dest is 1,2,3 for feedback sources
        p[pre + [.dest]] = TG33RangeParam(parm: parm, parm2: 0x0014, byte: 21, bits: 0...1, maxVal: 3)
        p[pre + [.feedback, .src, .i(0)]] = TG33RangeParam(parm: parm, parm2: 0x0014, byte: 21, bits: 2...3, maxVal: 2)
        p[pre + [.feedback, .src, .i(1)]] = TG33RangeParam(parm: parm, parm2: 0x0014, byte: 21, bit: 4)
        // these 2 shifts aren't auto-changed by algo change
        p[pre + [.src, .i(0), .shift]] = TG33RangeParam(parm: parm, parm2: 0x0015, byte: 22, bits: 0...2, maxVal: 7)
        p[pre + [.src, .i(1), .shift]] = TG33RangeParam(parm: parm, parm2: 0x0015, byte: 22, bits: 3...5, maxVal: 7)
        p[pre + [.adjust, .level]] = TG33RangeParam(parm: parm, parm2: 0x0016, byte: 23, maxVal: 7)
        p[pre + [.wave]] = TG33OptionsParam(parm: parm, parm2: 0x0017, byte: 24, options: afmWaveOptions)
        p[pre + [.pitch, .mod]] = TG33RangeParam(parm: parm, parm2: 0x0018, byte: 25, bits: 2...4, maxVal: 7)
        p[pre + [.pitch, .env]] = TG33RangeParam(parm: parm, parm2: 0x0018, byte: 25, bit: 1)
        p[pre + [.osc, .mode]] = TG33RangeParam(parm: parm, parm2: 0x0018, byte: 25, bit: 0)
        p[pre + [.phase, .on]] = TG33RangeParam(parm: parm, parm2: 0x0019, byte: 26, maxVal: 1)
        p[pre + [.phase]] = TG33RangeParam(parm: parm, parm2: 0x0019, byte: 27, bits: 0...6)
        p[pre + [.detune]] = TG33RangeParam(parm: parm, parm2: 0x001a, byte: 28, range: -15...15)
        p[pre + [.level]] = TG33RangeParam(parm: parm, parm2: 0x001b, byte: 29)
        p[pre + [.level, .scale, .pt, .i(0)]] = MisoParam.make(parm: parm, parm2: 0x001c, byte: 30, iso: bpIso)
        p[pre + [.level, .scale, .pt, .i(1)]] = MisoParam.make(parm: parm, parm2: 0x001d, byte: 31, iso: bpIso)
        p[pre + [.level, .scale, .pt, .i(2)]] = MisoParam.make(parm: parm, parm2: 0x001e, byte: 32, iso: bpIso)
        p[pre + [.level, .scale, .pt, .i(3)]] = MisoParam.make(parm: parm, parm2: 0x001f, byte: 33, iso: bpIso)
        p[pre + [.level, .scale, .offset, .i(0)]] = TG33RangeParam(parm: parm, parm2: 0x0020, byte: 34, length: 2, range: 1...255, displayOffset: -128)
        p[pre + [.level, .scale, .offset, .i(1)]] = TG33RangeParam(parm: parm, parm2: 0x0021, byte: 36, length: 2, range: 1...255, displayOffset: -128)
        p[pre + [.level, .scale, .offset, .i(2)]] = TG33RangeParam(parm: parm, parm2: 0x0022, byte: 38, length: 2, range: 1...255, displayOffset: -128)
        p[pre + [.level, .scale, .offset, .i(3)]] = TG33RangeParam(parm: parm, parm2: 0x0023, byte: 40, length: 2, range: 1...255, displayOffset: -128)
        p[pre + [.rate, .velo]] = TG33RangeParam(parm: parm, parm2: 0x0024, byte: 42, maxVal: 1)
        p[pre + [.coarse]] = TG33RangeParam(parm: parm, parm2: 0x0025, byte: 43, maxVal: 31)
        p[pre + [.fine]] = TG33RangeParam(parm: parm, parm2: 0x0026, byte: 44, maxVal: 99)
      }
      
      // AWM
      do {
        let parm = 0x0700 + (el << 5)
        let pre: SynthPath = [.element, .i(el), .wave]
        p[pre + [.src]] = TG33OptionsParam(parm: parm, parm2: 0x0000, byte: 0, options: waveSourceOptions)
        p[pre + [.wave]] = TG33OptionsParam(parm: parm, parm2: 0x0001, byte: 1, length: 2, options: waveOptions)
        p[pre + [.freq, .mode]] = TG33OptionsParam(parm: parm, parm2: 0x0002, byte: 3, options: ["Normal", "Fixed"])
        p[pre + [.fixed, .note]] = TG33RangeParam(parm: parm, parm2: 0x0003, byte: 4)
        p[pre + [.freq, .fine]] = TG33RangeParam(parm: parm, parm2: 0x0004, byte: 5, displayOffset: -64)
        p[pre + [.pitch, .mod]] = TG33RangeParam(parm: parm, parm2: 0x0005, byte: 6, maxVal: 7)
        p[pre + [.pitch, .env, .rate, .i(0)]] = TG33RangeParam(parm: parm, parm2: 0x0006, byte: 7, maxVal: 63)
        p[pre + [.pitch, .env, .rate, .i(1)]] = TG33RangeParam(parm: parm, parm2: 0x0007, byte: 8, maxVal: 63)
        p[pre + [.pitch, .env, .rate, .i(2)]] = TG33RangeParam(parm: parm, parm2: 0x0008, byte: 9, maxVal: 63)
        p[pre + [.pitch, .env, .release, .rate, .i(0)]] = TG33RangeParam(parm: parm, parm2: 0x0009, byte: 10, maxVal: 63)
        p[pre + [.pitch, .env, .level, .i(-1)]] = TG33RangeParam(parm: parm, parm2: 0x000a, byte: 11, displayOffset: -64)
        p[pre + [.pitch, .env, .level, .i(0)]] = TG33RangeParam(parm: parm, parm2: 0x000b, byte: 12, displayOffset: -64)
        p[pre + [.pitch, .env, .level, .i(1)]] = TG33RangeParam(parm: parm, parm2: 0x000c, byte: 13, displayOffset: -64)
        p[pre + [.pitch, .env, .level, .i(2)]] = TG33RangeParam(parm: parm, parm2: 0x000d, byte: 14, displayOffset: -64)
        p[pre + [.pitch, .env, .release, .level, .i(0)]] = TG33RangeParam(parm: parm, parm2: 0x000e, byte: 15, displayOffset: -64)
        p[pre + [.pitch, .env, .range]] = TG33OptionsParam(parm: parm, parm2: 0x000f, byte: 16, options: ["2oct", "1oct", "1/2oct"])
        p[pre + [.pitch, .rate, .scale]] = TG33RangeParam(parm: parm, parm2: 0x0010, byte: 17, range: -7...7)
        p[pre + [.pitch, .velo]] = TG33RangeParam(parm: parm, parm2: 0x0011, byte: 18, maxVal: 1)
        p[pre + [.lfo, .i(0), .speed]] = TG33RangeParam(parm: parm, parm2: 0x0012, byte: 19, maxVal: 99)
        p[pre + [.lfo, .i(0), .delay]] = TG33RangeParam(parm: parm, parm2: 0x0013, byte: 20, maxVal: 99)
        p[pre + [.lfo, .i(0), .pitch]] = TG33RangeParam(parm: parm, parm2: 0x0014, byte: 21)
        p[pre + [.lfo, .i(0), .amp]] = TG33RangeParam(parm: parm, parm2: 0x0015, byte: 22)
        p[pre + [.lfo, .i(0), .filter]] = TG33RangeParam(parm: parm, parm2: 0x0016, byte: 23)
        p[pre + [.lfo, .i(0), .wave]] = TG33OptionsParam(parm: parm, parm2: 0x0017, byte: 24, options: lfoWaveOptions)
        p[pre + [.lfo, .i(0), .phase]] = TG33RangeParam(parm: parm, parm2: 0x0018, byte: 25, maxVal: 99)
        p[pre + [.amp, .env, .mode]] = TG33OptionsParam(parm: parm, parm2: 0x004f, byte: 27, options: ["Normal", "Hold"])
        p[pre + [.amp, .env, .rate, .i(0)]] = TG33RangeParam(parm: parm, parm2: 0x0050, byte: 28, maxVal: 63)
        p[pre + [.amp, .env, .rate, .i(1)]] = TG33RangeParam(parm: parm, parm2: 0x0051, byte: 29, maxVal: 63)
        p[pre + [.amp, .env, .rate, .i(2)]] = TG33RangeParam(parm: parm, parm2: 0x0052, byte: 30, maxVal: 63)
        p[pre + [.amp, .env, .rate, .i(3)]] = TG33RangeParam(parm: parm, parm2: 0x0053, byte: 31, maxVal: 63)
        p[pre + [.amp, .env, .release, .rate, .i(0)]] = TG33RangeParam(parm: parm, parm2: 0x0054, byte: 32, maxVal: 63)
        p[pre + [.amp, .env, .level, .i(1)]] = TG33RangeParam(parm: parm, parm2: 0x0055, byte: 33, maxVal: 63)
        p[pre + [.amp, .env, .level, .i(2)]] = TG33RangeParam(parm: parm, parm2: 0x0056, byte: 34, maxVal: 63)
        p[pre + [.amp, .rate, .scale]] = TG33RangeParam(parm: parm, parm2: 0x0057, byte: 35, range: -7...7)
        p[pre + [.amp, .level, .scale, .pt, .i(0)]] = MisoParam.make(parm: parm, parm2: 0x0058, byte: 36, iso: bpIso)
        p[pre + [.amp, .level, .scale, .pt, .i(1)]] = MisoParam.make(parm: parm, parm2: 0x0059, byte: 37, iso: bpIso)
        p[pre + [.amp, .level, .scale, .pt, .i(2)]] = MisoParam.make(parm: parm, parm2: 0x005a, byte: 38, iso: bpIso)
        p[pre + [.amp, .level, .scale, .pt, .i(3)]] = MisoParam.make(parm: parm, parm2: 0x005b, byte: 39, iso: bpIso)
        p[pre + [.amp, .level, .scale, .offset, .i(0)]] = TG33RangeParam(parm: parm, parm2: 0x0005c, byte: 40, length: 2, range: 1...255, displayOffset: -128)
        p[pre + [.amp, .level, .scale, .offset, .i(1)]] = TG33RangeParam(parm: parm, parm2: 0x005d, byte: 42, length: 2, range: 1...255, displayOffset: -128)
        p[pre + [.amp, .level, .scale, .offset, .i(2)]] = TG33RangeParam(parm: parm, parm2: 0x005e, byte: 44, length: 2, range: 1...255, displayOffset: -128)
        p[pre + [.amp, .level, .scale, .offset, .i(3)]] = TG33RangeParam(parm: parm, parm2: 0x005f, byte: 46, length: 2, range: 1...255, displayOffset: -128)
        p[pre + [.amp, .velo]] = TG33RangeParam(parm: parm, parm2: 0x0060, byte: 48, range: -7...7)
        p[pre + [.amp, .attack, .velo]] = TG33RangeParam(parm: parm, parm2: 0x0061, byte: 49, maxVal: 1)
        p[pre + [.amp, .mod]] = TG33RangeParam(parm: parm, parm2: 0x0062, byte: 50, range: -7...7)
      }


      // FILTER
      let mode: [SynthPathItem] = [.fm, .wave]
      mode.forEach { m in
        // 2 Filters per element
        (0..<2).forEach { filter in
          let parm = 0x0900 + (el << 5) + (m == .fm ? filter : filter + 3)
          let pre: SynthPath = [.element, .i(el), m, .filter, .i(filter)]

          p[pre + [.type]] = TG33OptionsParam(parm: parm, parm2: 0x0000, byte: 0, options: ["Thru", "LPF", "HPF"])
          p[pre + [.cutoff]] = TG33RangeParam(parm: parm, parm2: 0x0001, byte: 1)
          p[pre + [.mode]] = TG33OptionsParam(parm: parm, parm2: 0x0002, byte: 2, options: ["EG", "LFO", "EG-VA"])
          p[pre + [.env, .rate, .i(0)]] = TG33RangeParam(parm: parm, parm2: 0x0003, byte: 3, maxVal: 63)
          p[pre + [.env, .rate, .i(1)]] = TG33RangeParam(parm: parm, parm2: 0x0004, byte: 4, maxVal: 63)
          p[pre + [.env, .rate, .i(2)]] = TG33RangeParam(parm: parm, parm2: 0x0005, byte: 5, maxVal: 63)
          p[pre + [.env, .rate, .i(3)]] = TG33RangeParam(parm: parm, parm2: 0x0006, byte: 6, maxVal: 63)
          p[pre + [.env, .release, .rate, .i(0)]] = TG33RangeParam(parm: parm, parm2: 0x0007, byte: 7, maxVal: 63)
          p[pre + [.env, .release, .rate, .i(1)]] = TG33RangeParam(parm: parm, parm2: 0x0008, byte: 8, maxVal: 63)
          p[pre + [.env, .level, .i(-1)]] = TG33RangeParam(parm: parm, parm2: 0x0009, byte: 9, displayOffset: -64)
          p[pre + [.env, .level, .i(0)]] = TG33RangeParam(parm: parm, parm2: 0x000a, byte: 10, displayOffset: -64)
          p[pre + [.env, .level, .i(1)]] = TG33RangeParam(parm: parm, parm2: 0x000b, byte: 11, displayOffset: -64)
          p[pre + [.env, .level, .i(2)]] = TG33RangeParam(parm: parm, parm2: 0x000c, byte: 12, displayOffset: -64)
          p[pre + [.env, .level, .i(3)]] = TG33RangeParam(parm: parm, parm2: 0x000d, byte: 13, displayOffset: -64)
          p[pre + [.env, .release, .level, .i(0)]] = TG33RangeParam(parm: parm, parm2: 0x000e, byte: 14, displayOffset: -64)
          p[pre + [.env, .release, .level, .i(1)]] = TG33RangeParam(parm: parm, parm2: 0x000f, byte: 15, displayOffset: -64)
          p[pre + [.rate, .scale]] = TG33RangeParam(parm: parm, parm2: 0x0010, byte: 16, range: -7...7)
          p[pre + [.level, .scale, .pt, .i(0)]] = MisoParam.make(parm: parm, parm2: 0x0011, byte: 17, iso: bpIso)
          p[pre + [.level, .scale, .pt, .i(1)]] = MisoParam.make(parm: parm, parm2: 0x0012, byte: 18, iso: bpIso)
          p[pre + [.level, .scale, .pt, .i(2)]] = MisoParam.make(parm: parm, parm2: 0x0013, byte: 19, iso: bpIso)
          p[pre + [.level, .scale, .pt, .i(3)]] = MisoParam.make(parm: parm, parm2: 0x0014, byte: 20, iso: bpIso)
          p[pre + [.level, .scale, .offset, .i(0)]] = TG33RangeParam(parm: parm, parm2: 0x0015, byte: 21, length: 2, range: 1...255, displayOffset: -128)
          p[pre + [.level, .scale, .offset, .i(1)]] = TG33RangeParam(parm: parm, parm2: 0x0016, byte: 23, length: 2, range: 1...255, displayOffset: -128)
          p[pre + [.level, .scale, .offset, .i(2)]] = TG33RangeParam(parm: parm, parm2: 0x0017, byte: 25, length: 2, range: 1...255, displayOffset: -128)
          p[pre + [.level, .scale, .offset, .i(3)]] = TG33RangeParam(parm: parm, parm2: 0x0018, byte: 27, length: 2, range: 1...255, displayOffset: -128)
        }
        
        // Filter common
        let parm = 0x0900 + (el << 5) + (m == .fm ? 2 : 5)
        let pre: SynthPath = [.element, .i(el), m, .filter, .common]
        p[pre + [.reson]] = TG33RangeParam(parm: parm, parm2: 0x0032, byte: 0, maxVal: 99)
        p[pre + [.velo]] = TG33RangeParam(parm: parm, parm2: 0x0033, byte: 1, range: -7...7)
        p[pre + [.mod]] = TG33RangeParam(parm: parm, parm2: 0x0034, byte: 2, range: -7...7)
      }
    }

    // FX
    p[[.fx, .mode]] = TG33OptionsParam(parm: 0x0800, parm2: 0x0000, byte: 0, options: fxModeOptions)
    (0..<2).forEach { chorus in
      let off = chorus * 7
      let pre: SynthPath = [.fx, .chorus, .i(chorus)]
      p[pre + [.type]] = TG33OptionsParam(parm: 0x0800, parm2: 0x0001 + off, byte: 1 + off, options: chorusOptions)
      p[pre + [.balance]] = TG33RangeParam(parm: 0x0800, parm2: 0x0002 + off, byte: 2 + off, maxVal: 100)
      p[pre + [.level]] = TG33RangeParam(parm: 0x0800, parm2: 0x0003 + off, byte: 3 + off, maxVal: 100)
      p[pre + [.param, .i(0)]] = TG33RangeParam(parm: 0x0800, parm2: 0x0004 + off, byte: 4 + off)
      p[pre + [.param, .i(1)]] = TG33RangeParam(parm: 0x0800, parm2: 0x0005 + off, byte: 5 + off)
      p[pre + [.param, .i(2)]] = TG33RangeParam(parm: 0x0800, parm2: 0x0006 + off, byte: 6 + off)
      p[pre + [.param, .i(3)]] = TG33RangeParam(parm: 0x0800, parm2: 0x0007 + off, byte: 7 + off)
    }
    (0..<2).forEach { reverb in
      let off = reverb * 6
      let pre: SynthPath = [.fx, .reverb, .i(reverb)]
      p[pre + [.type]] = TG33OptionsParam(parm: 0x0800, parm2: 0x000f + off, byte: 15 + off, options: reverbOptions)
      p[pre + [.balance]] = TG33RangeParam(parm: 0x0800, parm2: 0x0010 + off, byte: 16 + off, maxVal: 100)
      p[pre + [.level]] = TG33RangeParam(parm: 0x0800, parm2: 0x0011 + off, byte: 17 + off, maxVal: 100)
      p[pre + [.param, .i(0)]] = TG33RangeParam(parm: 0x0800, parm2: 0x0012 + off, byte: 18 + off)
      p[pre + [.param, .i(1)]] = TG33RangeParam(parm: 0x0800, parm2: 0x0013 + off, byte: 19 + off)
      p[pre + [.param, .i(2)]] = TG33RangeParam(parm: 0x0800, parm2: 0x0014 + off, byte: 20 + off)
    }
    p[[.fx, .mix, .i(0)]] = TG33RangeParam(parm: 0x0800, parm2: 0x001b, byte: 27, maxVal: 1)
    p[[.fx, .mix, .i(1)]] = TG33RangeParam(parm: 0x0800, parm2: 0x001c, byte: 28, maxVal: 1)
    
    (0...61).forEach { drum in
      let off = drum * 8
      let pre: SynthPath = [.rhythm, .i(drum)]
      let parm = 0x0400 + drum + 36
      p[pre + [.alt, .group]] = TG33RangeParam(parm: parm, parm2: 0x0000, byte: 0 + off, bit: 6)
      p[pre + [.out, .select]] = TG33RangeParam(parm: parm, parm2: 0x0000, byte: 0 + off, bits: 2...5, maxVal: 8)
      p[pre + [.out, .i(0)]] = TG33RangeParam(parm: parm, parm2: 0x0000, byte: 0 + off, bit: 0)
      p[pre + [.out, .i(1)]] = TG33RangeParam(parm: parm, parm2: 0x0000, byte: 0 + off, bit: 1)
      p[pre + [.wave, .src]] = TG33OptionsParam(parm: parm, parm2: 0x0001, byte: 1 + off, options: ["Preset", "Card"])
      p[pre + [.wave, .wave]] = TG33OptionsParam(parm: parm, parm2: 0x0002, byte: 2 + off, length: 2, options: waveOptions)
      p[pre + [.volume]] = TG33RangeParam(parm: parm, parm2: 0x0003, byte: 4 + off)
      p[pre + [.fine]] = TG33RangeParam(parm: parm, parm2: 0x0004, byte: 5 + off, displayOffset: -64)
      p[pre + [.note, .shift]] = TG33RangeParam(parm: parm, parm2: 0x0005, byte: 6 + off, range: 16...100, displayOffset: -64)
      p[pre + [.pan]] = TG33RangeParam(parm: parm, parm2: 0x0006, byte: 7 + off, maxVal: 62, displayOffset: -31)
    }
    
    return p
  }()
  
  static let structureOptions = OptionsParam.makeOptions(["1AFM mono", "2AFM mono", "4AFM mono", "1 AFM poly", "2 AFM poly", "1AWM poly", "2AWM poly", "4AWM poly", "1AFM 1AWM poly", "2AFM 2AWM poly", "Drum Set"])
  
  static let indivOutOptions = OptionsParam.makeOptions((0...8).map {
    $0 == 0 ? "Off" : "\($0)"
  })
  
  static let microOptions = OptionsParam.makeOptions(["Internal 1", "Internal 2"] + TG77MicrotunePatch.presetOptions)

  static let chorusOptions = OptionsParam.makeOptions(["0: Through","1: Chorus","2: Flanger","3: Symphonic", "4: Tremolo"])

  static let algoOptions = OptionsParam.makeOptions((0..<45).map { "tg77-algo-\($0+1)" })

  static let fxModeOptions = OptionsParam.makeOptions((0..<4).map { "tg77-fx-mode-\($0)" })
  
  static let reverbOptions = OptionsParam.makeOptions(["0: Through", "1: Reverb Hall", "2: Reverb Room", "3: Reverb Plate", "4: Reverb Church", "5: Reverb Club", "6: Reverb Stage", "7: Reverb Bathroom", "8: Reverb Metal", "9: Single Delay", "10: Delay L, R", "11: Stereo Echo", "12: Doubler 1", "13: Doubler 2", "14: Ping-Pong Echo", "15: Pan Reflection", "16: Early Relection", "17: Gate Reverb", "18: Reverse Gate", "19: Feedb. Early Refl.", "20: Feedbk Gate", "21: Feedbk Reverse", "22: Single Delay & Reverb", "23: Delay L/R & Reverb", "24: Tunnel Reverb", "25: Tone Control 1", "26: Single Delay + Tone Ctrl 1", "27: Delay L/R + Tone Ctrl 1", "28: Tone Ctrl 2", "29: Single Delay + Tone Ctrl 2", "30: Delay L/R + Tone Ctrl 2", "31: Distort + Reverb", "32: Distort + Single Delay", "33: Distort + Delay L/R", "34: Distortion", "35: Ind Delay", "36: Ind Tone Control", "37: Ind Distortion", "38: Ind Reverb", "39: Ind Delay & Reverb", "40: Ind Reverb & Delay"])
  
  static let ctrlOptions = OptionsParam.makeOptions((0...121).map {
    return $0 == 121 ? "Aftertouch" : "CC \($0)"
  })
  
  // 6,7,8 are FB src 1,2,3
  // 10 is noise?
  // 2 is AWM?
  // 9,1 seem to be from algo (hard-code)
  // 3,4 is also hard-code
  // 0 is open
  // algo hard-coded feedback appears same as user-progged (6,7,8)
  static let inSrcOptions: [Int:String] = [
    0 : "Off",
    2 : "AWM",
    6 : "FB1",
    7 : "FB2",
    8 : "FB3",
    10 : "Noise",
  ]
  
  static let bpIso = Miso.noteName(zeroNote: "C-2")
  
  static let afmWaveOptions = OptionsParam.makeOptions((0..<16).map { "tg77-fm-wave-\($0+1)" })
  
  static let lfoWaveOptions = OptionsParam.makeOptions(["Triangle", "Saw Down", "Saw Up", "Square", "Sine", "Sample&Hold"])
  
  static let subLFOWaveOptions = OptionsParam.makeOptions(["Triangle", "Saw Down", "Square", "Sample&Hold"])
  
  static let blankWaveOptions = OptionsParam.makeOptions((0..<128).map {
    return "Wave \($0 + 1)"
  })
  
  static let waveSourceOptions = OptionsParam.makeOptions(["Preset", "Card", "AFM"])
  
  static let waveOptions = OptionsParam.makeOptions(["1: Piano", "2: Trumpet", "3: Mute Tp", "4: Horn", "5: Flugel", "6: Trombone", "7: Brass", "8: Flute", "9: Clarinet", "10: Tenor Sax", "11: Alto Sax", "12: GtrSteel", "13: EG Sngl", "14: EG Humbk", "15: EG Harmo", "16: EG mute", "17: E.Bass", "18: Thumping", "19: Popping", "20: Fretless", "21: Wood Bass", "22: Shamisen", "23: Koto", "24: Violin", "25: Pizz", "26: Strings", "27: AnlgBass", "28: Anlg Brs", "29: Chorus", "30: Itopia", "31: Vib", "32: Marimba", "33: Tubular", "34: Cele Wv", "35: HarpsiWv", "36: E.P. Wv", "37: Pipe Wv", "38: Organ Wv", "39: Tuba Wv", "40: Picco Wv", "41: S.Sax Wv", "42: BassonWv", "43: Reco Wv", "44: MuteTpWv", "45: GutWv", "46: 12Str Wv", "47: Bass Wv", "48: Cello Wv", "49: ContraWv", "50: Xylo Wv", "51: Glock Wv", "52: Harp Wv", "53: Sitar Wv", "54: StlDrmWv", "55: MtReedWv", "56: OhAttack", "57: AnlgSaw1", "58: AnlgSaw2", "59: Digital1", "60: Digital2", "61: Digital3", "62: Pulse 10", "63: Pulse 25", "64: Pulse 50", "65: Tri", "66: Piano Np", "67: E.P. Np", "68: Vibe Np", "69: DmpPiano", "70: Bottle 1", "71: Bottle 2", "72: Bottle 3", "73: Tube", "74: Vocal Ga", "75: Vocal Ba", "76: Sax trans", "77: Bow trans", "78: Bulb", "79: Tear", "80: Bamboo", "81: Cup Echo", "82: Digi Atk", "83: Temp Ra", "84: Giri", "85: Water", "86: Steam", "87: Narrow", "88: Airy", "89: Styroll", "90: Noise", "91: Bell mix", "92: Haaa", "93: BD1", "94: BD2", "95: BD3", "96: BD4", "97: SD1", "98: SD2", "99: SD3", "100: SD roll", "101: Rim", "102: Tom 1", "103: Tom 2", "104: HHclosed", "105: HH open", "106: Crash", "107: Ride", "108: Claps", "109: Cowbell", "110: Tmbrn", "111: Shaker", "112: Analg Perc"])
  
  static let chorusParamDefaults: [[Int]] = [
    [9, 99, 20, 0],
    [5, 65, 30, 0],
    [11, 60, 6, 35],
    [3, 80, 0, 0],
    [24, 50, 2, 0],
  ]
  
  static let reverbParamDefaults: [[Int]] = [
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
  
}

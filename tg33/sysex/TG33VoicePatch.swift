
class TG33VoicePatch : YamahaSinglePatch, BankablePatch {
  
  static let bankType: SysexPatchBank.Type = TG33VoiceBank.self
  
  static let nameByteRange = 0x0c..<0x14
  static let initFileName = "tg33-init"
  static let fileDataCount = 605
  
  var bytes: [UInt8]
  
  required init(data: Data) {
    // 587 bytes
    bytes = [UInt8](data[0x10..<0x25b])
  }
  
  init(bankData: Data) {
    bytes = [UInt8](bankData)
  }

  subscript(path: SynthPath) -> Int? {
    get {
      guard let param = type(of: self).params[path] else { return nil }
      
      switch path.last! {
      case .shift, .bias:
        let v = bytes[param.byte]
        return Int(Int8(bitPattern: v << 1)) >> 1
      case .wave:
        guard let index = path.i(1) else { return nil }
        if index % 2 == 1 {
          let hi: UInt8 = (bytes[param.byte] & 0x1) << 7
          let lo: UInt8 = bytes[param.byte+1] & 0x7f
          return Int(hi) + Int(lo)
        }
      case .scale:
        // accommodate .mod as well
        if path[path.count - 2] == .level {
          let hi: UInt8 = (bytes[param.byte] & 0x1) << 3
          let lo: UInt8 = (bytes[param.byte+1] & 0x7f) >> 4
          return (Int(hi) + Int(lo)) << 4
        }
      case .lfo:
        let hi: UInt8 = (bytes[param.byte] & 0x1) << 2
        let lo: UInt8 = (bytes[param.byte+1] & 0x7f) >> 5
        return (Int(hi) + Int(lo)) << 5
      case .i:
        if path[2] == .time {
          let hi: UInt8 = (bytes[param.byte] & 0x1) << 7
          let lo: UInt8 = bytes[param.byte+1] & 0x7f
          return Int(hi) + Int(lo)
        }
      case .attack, .release:
        let hi: UInt8 = (bytes[param.byte] & 0x1) << 7
        let lo: UInt8 = bytes[param.byte+1] & 0x7f
        return Int(Int8(bitPattern: hi + lo))
      default:
        break
      }
      return unpack(param: param)
    }
    set {
      guard let param = type(of: self).params[path],
        let newValue = newValue else { return }
      var packValue = newValue
      switch path.last! {
      case .shift, .bias:
        packValue = Int(UInt8(bitPattern: Int8(newValue << 1))) >> 1
      case .wave:
        guard let index = path.i(1) else { return }
        if index % 2 == 1 {
          bytes[param.byte] = UInt8((newValue >> 7) & 0x1)
          bytes[param.byte + 1] = UInt8(newValue & 0x7f)
          return
        }
      case .scale:
        if path[path.count - 2] == .level {
          // have to maintain value for rate scaling too
          let v = newValue >> 4
          bytes[param.byte] = UInt8((v >> 3) & 0x1)
          bytes[param.byte + 1] = (UInt8(v & 0x7) << 4) | (bytes[param.byte + 1] & 0x0f)
          return
        }
      case .lfo:
        let v = newValue >> 4
        bytes[param.byte] = UInt8((v >> 2) & 0x1)
        bytes[param.byte + 1] = (UInt8(v & 0x3) << 5) | (bytes[param.byte + 1] & 0x1f)
        return
      case .i:
        if path[2] == .time {
          bytes[param.byte] = UInt8((newValue >> 7) & 0x1)
          bytes[param.byte + 1] = UInt8(newValue & 0x7f)
          return
        }
      case .attack, .release:
        let v = UInt8(bitPattern: Int8(newValue))
        bytes[param.byte] = UInt8((v >> 7) & 0x1)
        bytes[param.byte + 1] = UInt8(v & 0x7f)
        return
      default:
        break
      }
      pack(value: packValue, forParam: param)
    }
  }
  
  
  func unpack(param: Param) -> Int? {
    guard let p = param as? ParamWithRange,
      p.range.lowerBound < 0 else {
        return defaultUnpack(param: param)
    }
    
    // range check
    let byte = param.byte
    guard byte < bytes.count else { return nil }

    let bits = p.bits ?? 0...6
    let bitLength = 1 + UInt8(bits.upperBound - bits.lowerBound)
    let ander: UInt8 = (1 << bitLength) - 1
    var v = (bytes[byte] >> UInt8(bits.lowerBound)) & ander
    // need to look at top bit (based on bits) and extend sign to the left...
    let signBitIndex = Int(bitLength - 1)
    if v.bits(signBitIndex...signBitIndex) == 1 {
      let orer: UInt8 = ((1 << (8 - bitLength)) - 1) << bitLength
      v |= orer // extend the sign bit to the left
      return Int(Int8(bitPattern: v))
    }
    else {
      return Int(v)
    }
  }
  
  
  func pack(value: Int, forParam param: Param) {
    guard value < 0 else {
      return defaultPack(value: value, forParam: param)
    }
    
    var b = bytes[param.byte]
    let v = UInt8(bitPattern: Int8(value))
    if let bits = param.bits {
      let bitlen = 1 + (bits.upperBound - bits.lowerBound)
      let bitmask: UInt8 = (1 << bitlen) - 1 // all 1's
      // clear the bits
      b &= ~(bitmask << bits.lowerBound)
      // set the bits
      b |= ((v & bitmask) << bits.lowerBound)
    }
    else {
      b = v
    }
    
    bytes[param.byte] = b
  }
  
  
  
  func sysexData(channel: Int) -> Data {
    var b = "LM  0012VE".unicodeScalars.map { UInt8($0.value) }
    b.append(contentsOf: bytes)

    let byteCountMSB = UInt8((b.count >> 7) & 0x7f)
    let byteCountLSB = UInt8(b.count & 0x7f)
    var data = Data([0xf0, 0x43, UInt8(channel), 0x7e, byteCountMSB, byteCountLSB])
    data.append(contentsOf: b)
    data.append(type(of: self).checksum(bytes: b))
    data.append(0xf7)
    return data
  }
  
  func fileData() -> Data {
    return sysexData(channel: 0)
  }

  func randomize() {
    randomizeAllParams()
    
    (0..<4).forEach {
      // set max level for all elements
      self[[.element, .i($0), .volume]] = 0
      // normal scale
      self[[.element, .i($0), .scale]] = 0

      self[[.element, .i($0), .velo]] = (0...3).random()!

      self[[.element, .i($0), .env, .attack, .level]] = (0...5).random()!
      
    }

    // no env delay
    self[[.common, .env, .delay]] = 127
    self[[.common, .env, .attack]] = 0
    self[[.common, .env, .release]] = 0
  }
  
  static let params: SynthPathParam = {
    var p = SynthPathParam()
  
    p[[.common, .structure]] = TG33OptionsParam(parm: 0x000000, parm2: 0x017e, byte: 0x00, bit: 0, options: ["A-B","A-B-C-D"])
    p[[.common, .fx, .type]] = TG33OptionsParam(parm: 0x010001, parm2: 0x017f, byte: 0x01, options: fxOptions)
    p[[.common, .fx, .balance]] = TG33RangeParam(parm: 0x020002, parm2: 0x017f, byte: 0x02)
    p[[.common, .fx, .send]] = TG33RangeParam(parm: 0x020006, parm2: 0x017f, byte: 0x06)
    p[[.common, .bend]] = TG33RangeParam(parm: 0x030014, parm2: 0x017f, byte: 0x14, maxVal: 12)
    p[[.common, .aftertouch, .level, .mod]] = TG33RangeParam(parm: 0x060015, parm2: 0x013f, byte: 0x15, bit: 6)
    p[[.common, .aftertouch, .pitch, .mod]] = TG33RangeParam(parm: 0x050015, parm2: 0x015f, byte: 0x15, bit: 5)
    p[[.common, .aftertouch, .amp, .mod]] = TG33RangeParam(parm: 0x050015, parm2: 0x016f, byte: 0x15, bit: 4)
    p[[.common, .modWheel, .pitch, .mod]] = TG33RangeParam(parm: 0x040015, parm2: 0x017d, byte: 0x15, bit: 1)
    p[[.common, .modWheel, .amp, .mod]] = TG33RangeParam(parm: 0x040015, parm2: 0x017e, byte: 0x15, bit: 0)
    p[[.common, .pitch, .bias]] = TG33RangeParam(parm: 0x060016, parm2: 0x017f, byte: 0x16, range: -12...12)
    p[[.common, .env, .delay]] = TG33OptionsParam(parm: 0x010017, parm2: 0x017f, byte: 0x18, options: options99)
    p[[.common, .env, .attack]] = TG33OptionsParam(parm: 0x070018, parm2: 0x017f, byte: 0x19, options: signedOptions99for63)
    p[[.common, .env, .release]] = TG33OptionsParam(parm: 0x070019, parm2: 0x017f, byte: 0x1b, options: signedOptions99for63)

    
    p[[.vector, .level, .speed]] = TG33OptionsParam(parm: 0x000000, parm2: 0x017f, byte: 0xb9, options: speedOptions)
    p[[.vector, .detune, .speed]] = TG33OptionsParam(parm: 0x030001, parm2: 0x017f, byte: 0xba, options: speedOptions)
    (0..<50).forEach {
      let byteOff = $0 * 4
      let timeOpts = $0 == 0 ? startTimeOptions : timeOptions

      let timeOff = RolandAddress(intValue: ($0 * 3) + 2)
      let tAdd = 0x020000 | timeOff.value
      let xAdd = 0x020000 | (timeOff + 0x01).value
      let yAdd = 0x020000 | (timeOff + 0x02).value
      p[[.vector, .level, .time, .i($0)]] = TG33OptionsParam(parm: tAdd, parm2: 0x017f, byte: 0xbb + byteOff, options: timeOpts)
      p[[.vector, .level, .x, .i($0)]] = TG33RangeParam(parm: xAdd, parm2: 0x017f, byte: 0xbd + byteOff, maxVal: 62, displayOffset: -31)
      p[[.vector, .level, .y, .i($0)]] = TG33RangeParam(parm: yAdd, parm2: 0x017f, byte: 0xbe + byteOff, maxVal: 62, displayOffset: -31)
      
      let time2Off = RolandAddress(intValue: ($0 * 3) + 152)
      let t2Add = 0x050000 | time2Off.value
      let x2Add = 0x050000 | (time2Off + 0x01).value
      let y2Add = 0x050000 | (time2Off + 0x02).value
      p[[.vector, .detune, .time, .i($0)]] = TG33OptionsParam(parm: t2Add, parm2: 0x017f, byte: 0x183 + byteOff, options: timeOpts)
      p[[.vector, .detune, .x, .i($0)]] = TG33RangeParam(parm: x2Add, parm2: 0x017f, byte: 0x185 + byteOff, maxVal: 62, displayOffset: -31)
      p[[.vector, .detune, .y, .i($0)]] = TG33RangeParam(parm: y2Add, parm2: 0x017f, byte: 0x186 + byteOff, maxVal: 62, displayOffset: -31)
    }

    [0,2].forEach {
      let off = $0 * 39
      
      p[[.element, .i($0), .wave]] = TG33OptionsParam(parm: 0x000000, parm2: 0x017f, byte: 0x1d + off, options: waveOptions)
      p[[.element, .i($0), .note, .shift]] = TG33RangeParam(parm: 0x010001, parm2: 0x017f, byte: 0x1f + off, range: -12...12)
      p[[.element, .i($0), .aftertouch]] = TG33RangeParam(parm: 0x050002, parm2: 0x010f, byte: 0x20 + off, bits: 4...6, range: -3...3)
      p[[.element, .i($0), .velo]] = TG33RangeParam(parm: 0x040002, parm2: 0x0170, byte: 0x20 + off, bits: 0...3, range: -5...5)

      // LFO
      p[[.element, .i($0), .lfo]] = TG33OptionsParam(parm: 0x070003, parm2: 0x001f, byte: 0x21 + off, options: lfoOptions)
      p[[.element, .i($0), .lfo, .speed]] = TG33RangeParam(parm: 0x090003, parm2: 0x0160, byte: 0x22 + off, bits: 0...4, maxVal: 31)
      p[[.element, .i($0), .lfo, .delay]] = TG33OptionsParam(parm: 0x080004, parm2: 0x017f, byte: 0x24 + off, options: options99)
      p[[.element, .i($0), .lfo, .rate]] = TG33OptionsParam(parm: 0x080005, parm2: 0x017f, byte: 0x26 + off, options: inverseOptions99)
      p[[.element, .i($0), .lfo, .amp, .mod]] = TG33RangeParam(parm: 0x070006, parm2: 0x0170, byte: 0x27 + off, bits: 0...3, maxVal: 15)
      p[[.element, .i($0), .lfo, .pitch, .mod]] = TG33RangeParam(parm: 0x070007, parm2: 0x0160, byte: 0x28 + off, bits: 0...4, maxVal: 31)
      p[[.element, .i($0), .lfo, .amp, .mod, .on]] = TG33RangeParam(byte: 0x27 + off, bit: 4)
      p[[.element, .i($0), .lfo, .pitch, .mod, .on]] = TG33RangeParam(byte: 0x28 + off, bit: 5)

      p[[.element, .i($0), .pan]] = TG33OptionsParam(parm: 0x030008, parm2: 0x0178, byte: 0x29 + off, bits: 0...2, options: panOptions)
      p[[.element, .i($0), .volume]] = TG33OptionsParam(parm: 0x020009, parm2: 0x017f, byte: 0x2a + off, options: inverseOptions99)

      p[[.element, .i($0), .env]] = TG33OptionsParam(parm: 0x000008, parm2: 0x010f, byte: 0x29 + off, bits: 4...6, options: envOptions)
      p[[.element, .i($0), .env, .level, .scale]] = TG33OptionsParam(parm: 0x07000b, parm2: 0x000f, byte: 0x2c + off, bits: 0...3, options: levelScalingOptions)
      p[[.element, .i($0), .env, .rate, .scale]] = TG33RangeParam(parm: 0x08000b, parm2: 0x0178, byte: 0x2d + off, bits: 0...2, maxVal: 7, displayOffset: 1)
      p[[.element, .i($0), .env, .delay]] = TG33RangeParam(parm: 0x01000c, parm2: 0x007f, byte: 0x2e + off)
      p[[.element, .i($0), .env, .attack, .rate]] = TG33OptionsParam(parm: 0x03000c, parm2: 0x0140, byte: 0x2f + off, bits: 0...5, options: options99for63)
      p[[.element, .i($0), .env, .decay, .i(0), .rate]] = TG33OptionsParam(parm: 0x04000d, parm2: 0x0140, byte: 0x30 + off, bits: 0...5, options: options99for63)
      p[[.element, .i($0), .env, .decay, .i(1), .rate]] = TG33OptionsParam(parm: 0x05000e, parm2: 0x0140, byte: 0x32 + off, bits: 0...5, options: options99for63)
      p[[.element, .i($0), .env, .release, .rate]] = TG33OptionsParam(parm: 0x06000f, parm2: 0x0140, byte: 0x33 + off, bits: 0...5, options: options99for63)
      p[[.element, .i($0), .env, .innit, .level]] = TG33OptionsParam(parm: 0x020010, parm2: 0x0100, byte: 0x34 + off, options: inverseOptions99)
      p[[.element, .i($0), .env, .attack, .level]] = TG33OptionsParam(parm: 0x030011, parm2: 0x0100, byte: 0x35 + off, options: inverseOptions99)
      p[[.element, .i($0), .env, .decay, .i(0), .level]] = TG33OptionsParam(parm: 0x040012, parm2: 0x0100, byte: 0x36 + off, options: inverseOptions99)
      p[[.element, .i($0), .env, .decay, .i(1), .level]] = TG33OptionsParam(parm: 0x050013, parm2: 0x0100, byte: 0x37 + off, options: inverseOptions99)

      // HIDDEN PARAMS
      p[[.element, .i($0), .detune]] = TG33RangeParam(byte: 0x2b + off, bits: 0...3, maxVal: 15)
      p[[.element, .i($0), .scale]] = TG33RangeParam(byte: 0x2b + off, bits: 4...5, maxVal: 3)
    }

    [1,3].forEach {
      let off = ($0 - 1) * 39
      
      p[[.element, .i($0), .wave]] = TG33OptionsParam(parm: 0x000016, parm2: 0x017f, byte: 0x3a + off, options: fmOptions)
      p[[.element, .i($0), .note, .shift]] = TG33RangeParam(parm: 0x010017, parm2: 0x017f, byte: 0x3d + off, range: -12...12)
      p[[.element, .i($0), .aftertouch]] = TG33RangeParam(parm: 0x050018, parm2: 0x010f, byte: 0x3e + off, bits: 4...6, range: -3...3)
      p[[.element, .i($0), .velo]] = TG33RangeParam(parm: 0x040018, parm2: 0x0170, byte: 0x3e + off, bits: 0...3, range: -5...5)
      
      // LFO
      p[[.element, .i($0), .lfo]] = TG33OptionsParam(parm: 0x070019, parm2: 0x001f, byte: 0x3f + off, bits: 5...6, options: lfoOptions)
      p[[.element, .i($0), .lfo, .speed]] = TG33RangeParam(parm: 0x090019, parm2: 0x0160, byte: 0x40 + off, bits: 0...4, maxVal: 31)
      p[[.element, .i($0), .lfo, .delay]] = TG33OptionsParam(parm: 0x08001a, parm2: 0x017f, byte: 0x41 + off, options: options99)
      p[[.element, .i($0), .lfo, .rate]] = TG33OptionsParam(parm: 0x08001b, parm2: 0x017f, byte: 0x43 + off, options: inverseOptions99)
      p[[.element, .i($0), .lfo, .amp, .mod]] = TG33RangeParam(parm: 0x07001c, parm2: 0x0170, byte: 0x45 + off, bits: 0...3, maxVal: 15)
      p[[.element, .i($0), .lfo, .pitch, .mod]] = TG33RangeParam(parm: 0x07001d, parm2: 0x0160, byte: 0x46 + off, bits: 0...4, maxVal: 31)
      
      p[[.element, .i($0), .pan]] = TG33OptionsParam(parm: 0x03001e, parm2: 0x0178, byte: 0x47 + off, bits: 0...2, options: panOptions)
      p[[.element, .i($0), .feedback]] = TG33RangeParam(parm: 0x06001f, parm2: 0x0178, byte: 0x48 + off, bits: 0...2, maxVal: 7)
      p[[.element, .i($0), .tone, .level]] = TG33OptionsParam(parm: 0x060021, parm2: 0x017f, byte: 0x4b + off, options: inverseOptions99)
      p[[.element, .i($0), .volume]] = TG33OptionsParam(parm: 0x02002d, parm2: 0x017f, byte: 0x5b + off, options: inverseOptions99)
      
      p[[.element, .i($0), .env]] = TG33OptionsParam(parm: 0x00001e, parm2: 0x010f, byte: 0x47 + off, bits: 4...6, options: envOptions)
      p[[.element, .i($0), .env, .level, .scale]] = TG33OptionsParam(parm: 0x07002f, parm2: 0x000f, byte: 0x5d + off, bits: 4...6, options: levelScalingOptions)
      p[[.element, .i($0), .env, .rate, .scale]] = TG33RangeParam(parm: 0x08002f, parm2: 0x0178, byte: 0x5e + off, bits: 0...3, maxVal: 7, displayOffset: 1)
      p[[.element, .i($0), .env, .delay]] = TG33RangeParam(parm: 0x010030, parm2: 0x007f, byte: 0x5f + off)
      p[[.element, .i($0), .env, .attack, .rate]] = TG33OptionsParam(parm: 0x030030, parm2: 0x0140, byte: 0x60 + off, bits: 0...5, options: options99for63)
      p[[.element, .i($0), .env, .decay, .i(0), .rate]] = TG33OptionsParam(parm: 0x040031, parm2: 0x0140, byte: 0x62 + off, bits: 0...5, options: options99for63)
      p[[.element, .i($0), .env, .decay, .i(1), .rate]] = TG33OptionsParam(parm: 0x050032, parm2: 0x0140, byte: 0x63 + off, bits: 0...5, options: options99for63)
      p[[.element, .i($0), .env, .release, .rate]] = TG33OptionsParam(parm: 0x060033, parm2: 0x0140, byte: 0x64 + off, bits: 0...5, options: options99for63)
      p[[.element, .i($0), .env, .innit, .level]] = TG33OptionsParam(parm: 0x020034, parm2: 0x0100, byte: 0x65 + off, options: inverseOptions99)
      p[[.element, .i($0), .env, .attack, .level]] = TG33OptionsParam(parm: 0x030035, parm2: 0x0100, byte: 0x66 + off, options: inverseOptions99)
      p[[.element, .i($0), .env, .decay, .i(0), .level]] = TG33OptionsParam(parm: 0x040036, parm2: 0x0100, byte: 0x67 + off, options: inverseOptions99)
      p[[.element, .i($0), .env, .decay, .i(1), .level]] = TG33OptionsParam(parm: 0x050037, parm2: 0x0100, byte: 0x68 + off, options: inverseOptions99)

      // HIDDEN PARAMS
      p[[.element, .i($0), .detune]] = TG33RangeParam(byte: 0x5c + off, bits: 0...3, maxVal: 15)
      p[[.element, .i($0), .scale]] = TG33RangeParam(byte: 0x5c + off, bits: 4...5, maxVal: 3)

      p[[.element, .i($0), .algo]] = TG33OptionsParam(byte: 0x48 + off, bit: 4, options: ["FM","Mix"])
      
      p[[.element, .i($0), .wave, .type]] = TG33OptionsParam(byte: 0x5a + off, bits: 4...6, options: opWaveOptions)
      p[[.element, .i($0), .ratio]] = TG33RangeParam(byte: 0x5a + off, bits: 0...3, maxVal: 15)
      p[[.element, .i($0), .fixed]] = TG33RangeParam(byte: 0x59 + off, bit: 0)
      p[[.element, .i($0), .amp, .mod]] = TG33RangeParam(byte: 0x45 + off, bit: 5)
      p[[.element, .i($0), .pitch, .mod]] = TG33RangeParam(byte: 0x46 + off, bit: 6)

      p[[.element, .i($0), .mod, .detune]] = TG33RangeParam(byte: 0x4c + off, bits: 0...3, maxVal: 15)
      p[[.element, .i($0), .mod, .scale]] = TG33RangeParam(byte: 0x4c + off, bits: 4...5, maxVal: 3)
      p[[.element, .i($0), .mod, .wave, .type]] = TG33OptionsParam(byte: 0x4a + off, bits: 4...6, options: opWaveOptions)
      p[[.element, .i($0), .mod, .ratio]] = TG33RangeParam(byte: 0x4a + off, bits: 0...3, maxVal: 15)
      p[[.element, .i($0), .mod, .fixed]] = TG33RangeParam(byte: 0x49 + off, bit: 0)
      p[[.element, .i($0), .mod, .amp, .mod]] = TG33RangeParam(byte: 0x45 + off, bit: 4)
      p[[.element, .i($0), .mod, .pitch, .mod]] = TG33RangeParam(byte: 0x46 + off, bit: 5)
      
      p[[.element, .i($0), .mod, .env, .level, .scale]] = TG33OptionsParam(byte: 0x4e + off, bits: 4...6, options: levelScalingOptions)
      p[[.element, .i($0), .mod, .env, .rate, .scale]] = TG33RangeParam(byte: 0x4e + off, bits: 0...3, maxVal: 7, displayOffset: 1)
      p[[.element, .i($0), .mod, .env, .delay]] = TG33RangeParam(byte: 0x4f + off, maxVal: 1)
      p[[.element, .i($0), .mod, .env, .attack, .rate]] = TG33OptionsParam(byte: 0x50 + off, bits: 0...5, options: options99for63)
      p[[.element, .i($0), .mod, .env, .decay, .i(0), .rate]] = TG33OptionsParam(byte: 0x52 + off, bits: 0...5, options: options99for63)
      p[[.element, .i($0), .mod, .env, .decay, .i(1), .rate]] = TG33OptionsParam(byte: 0x53 + off, bits: 0...5, options: options99for63)
      p[[.element, .i($0), .mod, .env, .release, .rate]] = TG33OptionsParam(byte: 0x54 + off, bits: 0...5, options: options99for63)
      p[[.element, .i($0), .mod, .env, .innit, .level]] = TG33OptionsParam(byte: 0x55 + off, options: inverseOptions99)
      p[[.element, .i($0), .mod, .env, .attack, .level]] = TG33OptionsParam(byte: 0x56 + off, options: inverseOptions99)
      p[[.element, .i($0), .mod, .env, .decay, .i(0), .level]] = TG33OptionsParam(byte: 0x57 + off, options: inverseOptions99)
      p[[.element, .i($0), .mod, .env, .decay, .i(1), .level]] = TG33OptionsParam(byte: 0x58 + off, options: inverseOptions99)
    }

    return p
  }()
  
  static let fxOptions = OptionsParam.makeOptions(["Rev Hall","Rev Room","Rev Plate","Rev Club", "Rev Metal", "Delay 1", "Delay 2", "Delay 3", "Doubler", "Ping Pong", "Pan Ref", "Early Ref", "Gate Rev", "Dly&Rev 1", "Dly&Rev 2", "Dist&Rev"])
  
  static let envOptions: [Int:String] = OptionsParam.makeOptions(["User", "Preset", "Piano", "Guitar", "Pluck", "Brass", "Strings", "Organ"])
  
  static let lfoOptions: [Int:String] = [
    0x00 : "Saw Down",
    0x20 : "Triangle",
    0x40 : "Square",
    0x60 : "Samp&Hold",
    0x80 : "Saw Up"
  ]

  static let panOptions: [Int:String] = OptionsParam.makeOptions(["Left", "Left Center", "Center", "Right Center", "Right"])

  static let speedOptions: [Int:String] = OptionsParam.makeOptions((0..<16).map {
    return $0 == 0 ? "160 ms" : "\($0*10) ms"
  })
  
  // TODO: these are slightly off. fix.
  static let options99Values: [Int] = (0..<128).map { ($0 * 100) / 128 }
  static let options99: [Int:String] = OptionsParam.makeOptions(options99Values.map { "\($0)" })
  static let inverseOptions99: [Int:String] = OptionsParam.makeOptions(options99Values.map { "\(99 - $0)" })
  
  static let options99for63: [Int:String] = OptionsParam.makeOptions((0..<64).map {
    return $0 < 37 ? "\($0 * 2)" : "\(36 + $0)"
  })

  static let signedOptions99for63: [Int:String] = {
    var opts = [Int:String]()
    (-36...36).forEach {
      opts[$0] = "\($0 * 2)"
    }
    (37...63).forEach {
      opts[$0] = "\(36 + $0)"
    }
    (-63 ... -37).forEach {
      opts[$0] = "\(-36 + $0)"
    }
    return opts
  }()
  
  static let levelScalingOptions: [Int:String] = [
    0x00 : "1",
    0x10 : "2",
    0x20 : "3",
    0x30 : "4",
    0x40 : "5",
    0x50 : "6",
    0x60 : "7",
    0x70 : "8",
    0x80 : "9",
    0x90 : "10",
    0xa0 : "11",
    0xb0 : "12",
    0xc0 : "13",
    0xd0 : "14",
    0xe0 : "15",
    0xf0 : "16",
  ]
  
  static let levelScalingImageOptions: [Int:String] = {
    var opts = [Int:String]()
    (0..<16).forEach { opts[$0 * 0x10] = "tg33-ls-\($0+1)" }
    return opts
  }()

  static let rateScalingImageOptions: [Int:String] = {
    var opts = [Int:String]()
    (0..<8).forEach { opts[$0] = "tg33-rs-\($0+1)" }
    return opts
  }()
  
  static let timeOptions: [Int:String] = OptionsParam.makeOptions((0..<256).map {
    switch $0 {
    case 254: return "Repeat"
    case 255: return "End"
    default: return "\($0+1)"
    }
  })
  
  static let startTimeOptions: [Int:String] = {
    var opts = timeOptions
    opts[254] = "(invalid)"
    return opts
  }()

  static let opWaveOptions = OptionsParam.makeOptions((0..<7).map { "\($0+1)" })
  
  static let waveOptions = OptionsParam.makeOptions(["Piano", "E.piano", "Clavi", "Cembalo", "Celesta", "P.organ", "E.organ1", "E.organ2", "Reed", "Trumpet", "Mute Trp", "Trombone", "Flugel", "Fr horn", "BrasAtak", "SynBrass", "Flute", "Clarinet", "Oboe", "Sax", "Gut", "Steel", "E.Gtr 1", "E.Gtr 2", "Mute Gtr", "Sitar", "Pluck 1", "Pluck 2", "Wood B 1", "Wood B 2", "E.Bass 1", "E.Bass 2", "E.Bass 3", "E.Bass 4", "Slap", "Fretless", "SynBass1", "SynBass2", "Strings", "Vn.Ens.", "Cello", "Pizz", "Syn Str", "Choir", "Itopia", "Ooo!", "Vibes", "Marimba", "Bells", "Timpani", "Tom", "E. Tom", "Cuica", "Whistle", "Claps", "Hit", "Harmonic", "Mix", "Sync", "Bell Mix", "Styroll", "DigiAtak", "Noise 1", "Noise 2", "Oh Hit", "Water 1", "Water 2", "Stream", "Coin", "Crash", "Bottle", "Tear", "Cracker", "Scratch", "Metal 1", "Metal 2", "Metal 3", "Metal 4", "Wood", "Bamboo", "Slam", "Tp. Body", "Tb. Body", "Horn Body", "Fl. Body", "Str. Body", "AirBlown", "Reverse1", "Reverse2", "Reverse3", "EP wv", "Organ wv", "M.TP wv", "Gtr wv", "Str wv 1", "Str wv 2", "Pad wv", "Digital1", "Digital2", "Digital3", "Digital4", "Digital5", "Saw 1", "Saw 2", "Saw 3", "Saw 4", "Square 1", "Square 2", "Square 3", "Square 4", "Pulse 1", "Pulse 2", "Pulse 3", "Pulse 4", "Pulse 5", "Pulse 6", "Tri", "Sin8'", "Sin8'+4'", "SEQ1", "SEQ 2", "SEQ 3", "SEQ 4", "SEQ 5", "SEQ 6", "SEQ 7", "SEQ 8", "Drum set"])
  
  static let fmOptions = OptionsParam.makeOptions(["E.Piano1", "E.Piano2", "E.Piano3", "E.Piano4", "E.Piano5", "E.Piano6", "E.organ1", "E.organ2", "E.organ3", "E.organ4", "E.organ5", "E.organ6", "E.organ7", "E.organ8", "Brass 1", "Brass 2", "Brass 3", "Brass 4", "Brass 5", "Brass 6", "Brass 7", "Brass 8", "Brass 9", "Brass 10", "Brass 11", "Brass 12", "Brass 13", "Brass 14", "Wood 1", "Wood 2", "Wood 3", "Wood 4", "Wood 5", "Wood 6", "Wood 7", "Wood 8", "Reed 1", "Reed 2", "Reed 3", "Reed 4", "Reed 5", "Reed 6", "Clavi 1", "Clavi 2", "Clavi 3", "Clavi 4", "Guitar 1", "Guitar 2", "Guitar 3", "Guitar 4", "Guitar 5", "Guitar 6", "Guitar 7", "Guitar 8", "Bass 1", "Bass 2", "Bass 3", "Bass 4", "Bass 5", "Bass 6", "Bass 7", "Bass 8", "Bass 9", "Str 1", "Str 2", "Str 3", "Sir 4", "Str 5", "Str 6", "Str 7", "Vibes 1", "Vibes 2", "Vibes 3", "Vibes 4", "Marimba1", "Marimba2", "Marimba3", "Bells 1", "Bells 2", "Bells 3", "Bells 4", "Bells 5", "Bells 6", "Bells 7", "Bells 8", "Metal 1", "Metal 2", "Metal 3", "Metal 4", "Metal 5", "Metal 6", "Lead 1", "Lead 2", "Lead 3", "Lead 4", "Lead 5", "Lead 6", "Lead 7", "Sus. 1", "Sus. 2", "Sus. 3", "Sus. 4", "Sus. 5", "Sus. 6", "Sus. 7", "Sus. 8", "Sus. 9", "Sus. 10", "Sus. 11", "Sus. 12", "Sus. 13", "Sus, 14", "Sus. 15", "Attack 1", "Attack 2", "Attack 3", "Attack 4", "Attack 5", "Move 1", "Move 2", "Move 3", "Move 4", "Move 5", "Move 6", "Move 7", "Decay 1", "Decay 2", "Decay 3", "Decay 4", "Decay 5", "Decay 6", "Decay 7", "Decay 8", "Decay 9", "Decay 10", "Decay 11", "Decay 12", "Decay 13", "Decay 14", "Decay 15", "Decay 16", "Decay 17", "Decay 18", "SFX 1", "SFX 2", "SFX 3", "SFX 4", "SFX 5", "SFX 6", "SFX 7", "Sin 16'", "Sin 8'", "Sin 4'", "Sin 2 2/3", "Sin 2'", "Saw 1", "Saw 2", "Square", "LFOnoise", "Noise 1", "Noise 2", "Digi 1", "Digi 2", "Digi 3", "Digi 4", "Digi 5", "Digi 6", "Digi 7", "Digi 8", "Digi 9", "Digi 10", "Digi 11", "wave1-1", "wave1-2", "wave1-3", "wave2-1", "wave2-2", "wave2-3", "wave3-1", "wave3-2", "wave3-3", "wave4-1", "wave4-2", "wave4-3", "wave5-1", "wave5-2", "wave5-3", "wave6-1", "wave6-2", "wave6-3", "wave7-1", "wave7-2", "wave7-3", "wave8-1", "wave8-2", "wave8-3", "wave9-1", "wave9-2", "wave9-3", "wave10-1", "wave10-2", "wave10-3", "wave11-1", "wave11-2", "wave11-3", "wave12-1", "wave12-2", "wave12-3", "wave13-1", "wave13-2", "wave13-3", "wave14-1", "wave14-2", "wave14-3", "wave15-1", "wave15-2", "wave15-3", "wave16-1", "wave16-2", "wave16-3", "wave17-1", "wave17-2", "wave17-3", "wave18-1", "wave18-2", "wave18-3", "wave19-1", "wave19-2", "wave19-3", "wave20-1", "wave20-2", "wave20-3", "wave21-1", "wave21-2", "wave21-3", "wave22-1", "wave22-2", "wave22-3", "wave23-1", "wave23-2", "wave23-3", "wave24-1", "wave24-2", "wave24-3", "wave25-1", "wave25-2", "wave25-3", "wave26-1", "wave26-2", "wave26-3", "wave27-1", "wave27-2", "wave27-3", "wave28", "wave29", "wave30"])
}

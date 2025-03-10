
//class WavestationSRPatchPatch : WavestationPatch, VoicePatch, BankablePatch {
//
//  static let bankType: SysexPatchBank.Type = WavestationSRPatchBank.self
//  static func location(forData data: Data) -> Int { return 0 }
//    
//  static let initFileName = "wavestationsr-patch-init"
//  static let fileDataCount = 861
//  static let nameByteRange = 0..<16
//
//  var bytes: [UInt8]
//  
//  // TODO
//  required init(data: Data) {
//    // 426 bytes
//    bytes = stride(from: 7, to: 859, by: 2).map { data[$0] + (data[$0 + 1] << 4) }
////    printMyBytes()
////    debugPrint("A: Bank: \(self[[.voice, .i(0), .bank]]!) Num: \(self[[.voice, .i(0), .number]]!)")
////    debugPrint("B: Bank: \(self[[.voice, .i(1), .bank]]!) Num: \(self[[.voice, .i(1), .number]]!)")
////    debugPrint("C: Bank: \(self[[.voice, .i(2), .bank]]!) Num: \(self[[.voice, .i(2), .number]]!)")
////    debugPrint("D: Bank: \(self[[.voice, .i(3), .bank]]!) Num: \(self[[.voice, .i(3), .number]]!)")
//  }
//  
//  init(bodyData: Data) {
//    bytes = stride(from: 0, to: 852, by: 2).map { bodyData[$0] + (bodyData[$0 + 1] << 4) }
//  }
//  
//  static let waveBankMap = [0,1,6,4,5,7,8,9,10,11,2]
//
//  subscript(path: SynthPath) -> Int? {
//    get {
//      guard let param = type(of: self).params[path] else { return nil }
//      
//      switch path {
//      case [.voice, .i(0), .bank],
//           [.voice, .i(1), .bank],
//           [.voice, .i(2), .bank],
//           [.voice, .i(3), .bank]:
//        guard let voice = path.i(1),
//          let lilBank = unpack(param: param),
//          let bankExtra = self[[.bank, .extra]] else { return nil }
//        guard lilBank < 4 else { return lilBank }
//        var bigBank = lilBank
//        if bankExtra.bit(voice) == 1 {
//          bigBank += 4
//        }
//        else if bankExtra.bit(voice + 4) == 1 {
//          bigBank += 8
//        }
//        return type(of: self).waveBankMap.firstIndex(of: bigBank) ?? 0
//        
//      default:
//        break
//      }
//      return unpack(param: param)
//    }
//    set {
//      guard let param = type(of: self).params[path],
//        let newValue = newValue else { return }
//      var packValue = newValue
//      
//      switch path {
//      case [.voice, .i(0), .bank],
//           [.voice, .i(1), .bank],
//           [.voice, .i(2), .bank],
//           [.voice, .i(3), .bank]:
//        guard let voice = path.i(1),
//          var bankExtra = self[[.bank, .extra]],
//          newValue < 11 else { return }
//        // find the right internal value
//        packValue = type(of: self).waveBankMap[packValue]
//        if (4...7) ~= packValue {
//          packValue = packValue - 4
//          bankExtra = bankExtra.set(bit: voice, value: 1).set(bit: voice + 4, value: 0)
//        }
//        else if (8...11) ~= packValue {
//          packValue = packValue - 8
//          bankExtra = bankExtra.set(bit: voice, value: 0).set(bit: voice + 4, value: 1)
//        }
//        else {
//          bankExtra = bankExtra.set(bit: voice, value: 0).set(bit: voice + 4, value: 0)
//        }
//        pack(value: bankExtra, forParam: type(of: self).params[[.bank, .extra]]!)
//
//      default:
//        break
//      }
//      
//      pack(value: packValue, forParam: param)
//      
//      // update fade inc if LFO fade or amt is set
//      if path.count == 5 && path[2] == .lfo && (path[4] == .amt || path[4] == .fade),
//        let voice = path.i(1),
//        let lfo = path.i(3),
//        let amt = self[[.voice, .i(voice), .lfo, .i(lfo), .amt]],
//        let fade = self[[.voice, .i(voice), .lfo, .i(lfo), .fade]] {
//        let inc = lfoFadeInc(fade: fade, amt: amt)
//        self[[.voice, .i(voice), .lfo, .i(lfo), .fade, .inc]] = inc
//      }
//      
//      // if any mix rate or level changes, update all the slopes (inefficient, but easier to code)
//      if path.count == 3 && path[0] == .mix && (path[1] == .rate || path[1] == .ac || path[1] == .bd) {
//        (0..<4).forEach { updateMixSlopes(index: $0) }
//      }
//
//    }
//  }
//
//  func sysexData(channel: Int, bank: Int, location: Int) -> Data {
//    var data = Data(sysexHeader(channel: channel) + [0x40, UInt8(bank), UInt8(location)])
//    let bodyData = sysexBodyData()
//    data.append(bodyData)
//    data.append(checksum(bodyData))
//    data.append(0xf7)
//    return data
//  }
//  
//  func fileData() -> Data {
//    return sysexData(channel: 0, bank: 0, location: 0)
//  }
//  
//  private func lfoFadeInc(fade: Int, amt: Int) -> Int {
//    return (0x7FFFFF * amt) / (WavestationSRPatchPatch.rateMap[fade] * 127)
//  }
//  
//  private func updateMixSlopes(index: Int) {
//    guard let mixRate = self[[.mix, .rate, .i(index)]],
//      let mixX0 = self[[.mix, .ac, .i(index - 1)]],
//      let mixX1 = self[[.mix, .ac, .i(index)]],
//      let mixY0 = self[[.mix, .bd, .i(index - 1)]],
//      let mixY1 = self[[.mix, .bd, .i(index)]] else { return }
//
//    let rate = WavestationSRPatchPatch.rateMap[mixRate]
//    
//    // TODO: these seem wrong. why both always the same? and there's no .i(3), .alt
//    self[[.mix, .number, .i(index)]] = rate
//    self[[.mix, .number, .i(index), .alt]] = rate
//
//    self[[.mix, .ac, .slop, .i(index)]] = 0x1000000 * (mixX1 - mixX0) / rate
//    self[[.mix, .bd, .slop, .i(index)]] = 0x1000000 * (mixY1 - mixY0) / rate
//  }
//
//
//    // TODO
//    func randomize() {
//      randomizeAllParams()
//  //    self[[.structure]] = (0...10).random()!
//    }
//
//
//  static let ByteCount = 0
//
//    static let params: SynthPathParam = {
//      var p = SynthPathParam()
//      
//      // these are SR-expanded. older WS's need old method
//      p[[.mix, .rate, .i(0)]] = RangeParam(parm: 421, byte: 16, maxVal: 99)
//      p[[.mix, .rate, .i(1)]] = RangeParam(parm: 422, byte: 17, maxVal: 99)
//      p[[.mix, .rate, .i(2)]] = RangeParam(parm: 423, byte: 18, maxVal: 99)
//      p[[.mix, .rate, .i(3)]] = RangeParam(parm: 424, byte: 19, maxVal: 99)
//      p[[.mix, .number, .i(0)]] = RangeParam(parm: 0, byte: 20, extra: [ByteCount:2])
//      p[[.mix, .number, .i(1)]] = RangeParam(parm: 0, byte: 22, extra: [ByteCount:2])
//      p[[.mix, .number, .i(2)]] = RangeParam(parm: 0, byte: 24, extra: [ByteCount:2])
//      p[[.mix, .number, .i(2), .alt]] = RangeParam(parm: 0, byte: 26, extra: [ByteCount:2])
//      p[[.mix, .number, .i(1), .alt]] = RangeParam(parm: 0, byte: 28, extra: [ByteCount:2])
//      p[[.mix, .number, .i(0), .alt]] = RangeParam(parm: 0, byte: 30, extra: [ByteCount:2])
//      p[[.mix, .number, .i(3)]] = RangeParam(parm: 0, byte: 32, extra: [ByteCount:2])
//      p[[.mix, .slop, .ac, .i(0)]] = RangeParam(parm: 0, byte: 34, extra: [ByteCount:4])
//      p[[.mix, .slop, .ac, .i(1)]] = RangeParam(parm: 0, byte: 38, extra: [ByteCount:4])
//      p[[.mix, .slop, .ac, .i(2)]] = RangeParam(parm: 0, byte: 42, extra: [ByteCount:4])
//      p[[.mix, .slop, .ac, .i(3)]] = RangeParam(parm: 0, byte: 46, extra: [ByteCount:4])
//      p[[.mix, .slop, .bd, .i(0)]] = RangeParam(parm: 0, byte: 50, extra: [ByteCount:4])
//      p[[.mix, .slop, .bd, .i(1)]] = RangeParam(parm: 0, byte: 54, extra: [ByteCount:4])
//      p[[.mix, .slop, .bd, .i(2)]] = RangeParam(parm: 0, byte: 58, extra: [ByteCount:4])
//      p[[.mix, .slop, .bd, .i(3)]] = RangeParam(parm: 0, byte: 62, extra: [ByteCount:4])
//      p[[.mix, .ac, .i(-1)]] = RangeParam(parm: 195, byte: 66, maxVal: 254, displayOffset: -127)
//      p[[.mix, .ac, .i(0)]] = RangeParam(parm: 195, byte: 67, maxVal: 254, displayOffset: -127)
//      p[[.mix, .ac, .i(1)]] = RangeParam(parm: 195, byte: 68, maxVal: 254, displayOffset: -127)
//      p[[.mix, .ac, .i(2)]] = RangeParam(parm: 195, byte: 69, maxVal: 254, displayOffset: -127)
//      p[[.mix, .ac, .i(3)]] = RangeParam(parm: 195, byte: 70, maxVal: 254, displayOffset: -127)
//      p[[.mix, .bd, .i(-1)]] = RangeParam(parm: 196, byte: 71, maxVal: 254, displayOffset: -127)
//      p[[.mix, .bd, .i(0)]] = RangeParam(parm: 196, byte: 72, maxVal: 254, displayOffset: -127)
//      p[[.mix, .bd, .i(1)]] = RangeParam(parm: 196, byte: 73, maxVal: 254, displayOffset: -127)
//      p[[.mix, .bd, .i(2)]] = RangeParam(parm: 196, byte: 74, maxVal: 254, displayOffset: -127)
//      p[[.mix, .bd, .i(3)]] = RangeParam(parm: 196, byte: 75, maxVal: 254, displayOffset: -127)
//      p[[.mix, .rrepeat]] = RangeParam(parm: 202, byte: 76, formatter: {
//        switch $0 {
//        case 0: return "Off"
//        case 127: return "Inf"
//        default: return "\($0)"
//        }
//      })
//      p[[.mix, .env, .loop]] = OptionsParam(parm: 201, byte: 77, options: mixEnvLoopOptions)
//
//      p[[.mix, .ac, .mod, .i(0), .src]] = OptionsParam(parm: 203, byte: 78, options: srcOptions)
//      p[[.mix, .ac, .mod, .i(0), .amt]] = RangeParam(parm: 204, byte: 79)
//      p[[.mix, .ac, .mod, .i(1), .src]] = OptionsParam(parm: 205, byte: 80, options: srcOptions)
//      p[[.mix, .ac, .mod, .i(1), .amt]] = RangeParam(parm: 206, byte: 81)
//      p[[.mix, .bd, .mod, .i(0), .src]] = OptionsParam(parm: 207, byte: 82, options: srcOptions)
//      p[[.mix, .bd, .mod, .i(0), .amt]] = RangeParam(parm: 208, byte: 83)
//      p[[.mix, .bd, .mod, .i(1), .src]] = OptionsParam(parm: 209, byte: 84, options: srcOptions)
//      p[[.mix, .bd, .mod, .i(1), .amt]] = RangeParam(parm: 210, byte: 85)
//
//      p[[.structure]] = OptionsParam(parm: 77, byte: 86, options: structureOptions)
//      p[[.sync]] = RangeParam(parm: 78, byte: 87)
//
//      // bank expansion byte -  88
//      p[[.bank, .extra]] = RangeParam(parm: 0, byte: 88, maxVal: 255)
//
//      // dummy 141 - 89
//      
//      // wave a, b ,c ,d
//      (0..<4).forEach { v in
//        let off = (v * 84) + 90
//        let poff = v * 7
//        p[[.voice, .i(v), .semitone]] = RangeParam(parm: 151 + poff, byte: 0 + off)
//        p[[.voice, .i(v), .detune]] = RangeParam(parm: 152 + poff, byte: 1 + off)
//        p[[.voice, .i(v), .bank]] = RangeParam(parm: 147 + poff, byte: 2 + off, maxVal: 10, displayOffset: 1)
//        p[[.voice, .i(v), .number]] = RangeParam(parm: 148 + poff, byte: 3 + off, extra: [ByteCount:2], maxVal: 515)
//        p[[.voice, .i(v), .pitch, .scale]] = RangeParam(parm: 153 + poff, byte: 5 + off)
//        
//        p[[.voice, .i(v), .lfo, .i(0), .rate]] = RangeParam(parm: 125, byte: 6 + off, maxVal: 99)
//        p[[.voice, .i(v), .lfo, .i(0), .amt]] = RangeParam(parm: 126, byte: 7 + off, range: -127...127)
//        p[[.voice, .i(v), .lfo, .i(0), .delay]] = RangeParam(parm: 129, byte: 8 + off, maxVal: 99)
//        p[[.voice, .i(v), .lfo, .i(0), .fade]] = RangeParam(parm: 130, byte: 9 + off, maxVal: 99)
//        p[[.voice, .i(v), .lfo, .i(0), .shape]] = OptionsParam(parm: 127, byte: 10 + off, options: lfoWaves)
//        p[[.voice, .i(v), .lfo, .i(0), .sync]] = RangeParam(parm: 128, byte: 10 + off)
//        p[[.voice, .i(v), .lfo, .i(0), .rate, .mod, .src]] = OptionsParam(parm: 133, byte: 11 + off, options: srcOptions)
//        p[[.voice, .i(v), .lfo, .i(0), .rate, .mod, .amt]] = RangeParam(parm: 134, byte: 12 + off, range: -127...127)
//        p[[.voice, .i(v), .lfo, .i(0), .amt, .mod, .src]] = OptionsParam(parm: 131, byte: 13 + off, options: srcOptions)
//        p[[.voice, .i(v), .lfo, .i(0), .amt, .mod, .amt]] = RangeParam(parm: 132, byte: 14 + off, range: -127...127)
//
//        p[[.voice, .i(v), .lfo, .i(1), .rate]] = RangeParam(parm: 135, byte: 15 + off, maxVal: 99)
//        p[[.voice, .i(v), .lfo, .i(1), .amt]] = RangeParam(parm: 136, byte: 16 + off, range: -127...127)
//        p[[.voice, .i(v), .lfo, .i(1), .delay]] = RangeParam(parm: 139, byte: 17 + off, maxVal: 99)
//        p[[.voice, .i(v), .lfo, .i(1), .fade]] = RangeParam(parm: 140, byte: 18 + off, maxVal: 99)
//        p[[.voice, .i(v), .lfo, .i(1), .shape]] = OptionsParam(parm: 137, byte: 19 + off, options: lfoWaves)
//        p[[.voice, .i(v), .lfo, .i(1), .sync]] = RangeParam(parm: 138, byte: 19 + off)
//        p[[.voice, .i(v), .lfo, .i(1), .rate, .mod, .src]] = OptionsParam(parm: 143, byte: 20 + off, options: srcOptions)
//        p[[.voice, .i(v), .lfo, .i(1), .rate, .mod, .amt]] = RangeParam(parm: 144, byte: 21 + off, range: -127...127)
//        p[[.voice, .i(v), .lfo, .i(1), .amt, .mod, .src]] = OptionsParam(parm: 141, byte: 22 + off, options: srcOptions)
//        p[[.voice, .i(v), .lfo, .i(1), .amt, .mod, .amt]] = RangeParam(parm: 142, byte: 23 + off, range: -127...127)
//        
//        p[[.voice, .i(v), .env, .rate, .i(0)]] = RangeParam(parm: 105, byte: 24 + off, maxVal: 99)
//        p[[.voice, .i(v), .env, .rate, .i(1)]] = RangeParam(parm: 106, byte: 25 + off, maxVal: 99)
//        p[[.voice, .i(v), .env, .rate, .i(2)]] = RangeParam(parm: 107, byte: 26 + off, maxVal: 99)
//        p[[.voice, .i(v), .env, .rate, .i(3)]] = RangeParam(parm: 108, byte: 27 + off, maxVal: 99)
//        p[[.voice, .i(v), .env, .level, .i(-1)]] = RangeParam(parm: 100, byte: 28 + off, maxVal: 99)
//        p[[.voice, .i(v), .env, .level, .i(0)]] = RangeParam(parm: 101, byte: 29 + off, maxVal: 99)
//        p[[.voice, .i(v), .env, .level, .i(1)]] = RangeParam(parm: 102, byte: 30 + off, maxVal: 99)
//        p[[.voice, .i(v), .env, .level, .i(2)]] = RangeParam(parm: 103, byte: 31 + off, maxVal: 99)
//        p[[.voice, .i(v), .env, .level, .i(3)]] = RangeParam(parm: 104, byte: 32 + off, maxVal: 99)
//        p[[.voice, .i(v), .env, .velo]] = RangeParam(parm: 109, byte: 33 + off)
//
//        p[[.voice, .i(v), .amp, .env, .rate, .i(0)]] = RangeParam(parm: 114, byte: 34 + off, maxVal: 99)
//        p[[.voice, .i(v), .amp, .env, .rate, .i(1)]] = RangeParam(parm: 115, byte: 35 + off, maxVal: 99)
//        p[[.voice, .i(v), .amp, .env, .rate, .i(2)]] = RangeParam(parm: 116, byte: 36 + off, maxVal: 99)
//        p[[.voice, .i(v), .amp, .env, .rate, .i(3)]] = RangeParam(parm: 117, byte: 37 + off, maxVal: 99)
//        p[[.voice, .i(v), .amp, .env, .level, .i(-1)]] = RangeParam(parm: 110, byte: 38 + off, maxVal: 99)
//        p[[.voice, .i(v), .amp, .env, .level, .i(0)]] = RangeParam(parm: 111, byte: 39 + off, maxVal: 99)
//        p[[.voice, .i(v), .amp, .env, .level, .i(1)]] = RangeParam(parm: 112, byte: 40 + off, maxVal: 99)
//        p[[.voice, .i(v), .amp, .env, .level, .i(2)]] = RangeParam(parm: 113, byte: 41 + off, maxVal: 99)
//
//        p[[.voice, .i(v), .pitch, .macro]] = RangeParam(parm: 80, byte: 42 + off)
//        p[[.voice, .i(v), .filter, .macro]] = RangeParam(parm: 81, byte: 43 + off)
//        p[[.voice, .i(v), .amp, .env, .macro]] = RangeParam(parm: 82, byte: 44 + off)
//        p[[.voice, .i(v), .pan, .macro]] = RangeParam(parm: 83, byte: 45 + off)
//        p[[.voice, .i(v), .env, .macro]] = RangeParam(parm: 84, byte: 46 + off)
//
//        p[[.voice, .i(v), .bend]] = RangeParam(parm: 85, byte: 47 + off)
//
//        p[[.voice, .i(v), .pitch, .mod, .i(0), .src]] = OptionsParam(parm: 89, byte: 48 + off, options: srcOptions)
//        p[[.voice, .i(v), .pitch, .mod, .i(0), .amt]] = RangeParam(parm: 90, byte: 49 + off)
//        p[[.voice, .i(v), .pitch, .mod, .i(1), .src]] = OptionsParam(parm: 91, byte: 50 + off, options: srcOptions)
//        p[[.voice, .i(v), .pitch, .mod, .i(1), .amt]] = RangeParam(parm: 92, byte: 51 + off)
//
//        p[[.voice, .i(v), .filter, .key, .trk]] = RangeParam(parm: 94, byte: 52 + off)
//        p[[.voice, .i(v), .filter, .mod, .i(0), .src]] = OptionsParam(parm: 96, byte: 53 + off, options: srcOptions)
//        p[[.voice, .i(v), .filter, .mod, .i(0), .amt]] = RangeParam(parm: 97, byte: 54 + off)
//        p[[.voice, .i(v), .filter, .mod, .i(1), .src]] = OptionsParam(parm: 98, byte: 55 + off, options: srcOptions)
//        p[[.voice, .i(v), .filter, .mod, .i(1), .amt]] = RangeParam(parm: 99, byte: 56 + off)
//
//        p[[.voice, .i(v), .amp, .env, .velo]] = RangeParam(parm: 118, byte: 57 + off)
//        p[[.voice, .i(v), .amp, .env, .velo, .attack]] = RangeParam(parm: 123, byte: 58 + off)
//        p[[.voice, .i(v), .amp, .env, .key, .decay]] = RangeParam(parm: 124, byte: 59 + off)
//
//        p[[.voice, .i(v), .amp, .mod, .i(0), .src]] = OptionsParam(parm: 119, byte: 60 + off, options: srcOptions)
//        p[[.voice, .i(v), .amp, .mod, .i(0), .amt]] = RangeParam(parm: 120, byte: 61 + off)
//        p[[.voice, .i(v), .amp, .mod, .i(1), .src]] = OptionsParam(parm: 121, byte: 62 + off, options: srcOptions)
//        p[[.voice, .i(v), .amp, .mod, .i(1), .amt]] = RangeParam(parm: 122, byte: 63 + off)
//
//        p[[.voice, .i(v), .key, .pan]] = RangeParam(parm: 146, byte: 64 + off)
//        p[[.voice, .i(v), .velo, .pan]] = RangeParam(parm: 145, byte: 65 + off)
//
//        p[[.voice, .i(v), .cutoff]] = RangeParam(parm: 93, byte: 66 + off, maxVal: 99)
//        p[[.voice, .i(v), .excite]] = RangeParam(parm: 95, byte: 67 + off, maxVal: 99)
//        
//        p[[.voice, .i(v), .env, .velo, .rate]] = RangeParam(parm: 347, byte: 68 + off)
//        p[[.voice, .i(v), .env, .key, .rate]] = RangeParam(parm: 348, byte: 69 + off)
//
//        p[[.voice, .i(v), .pitch, .env, .amt]] = RangeParam(parm: 86, byte: 70 + off)
//        p[[.voice, .i(v), .pitch, .env, .rate]] = RangeParam(parm: 87, byte: 71 + off)
//
//        p[[.voice, .i(v), .velo, .pitch, .env, .amt]] = RangeParam(parm: 88, byte: 72 + off)
//        p[[.voice, .i(v), .level]] = RangeParam(parm: 150 + poff, byte: 73 + off, maxVal: 99)
//        
//        p[[.voice, .i(v), .lfo, .i(0), .fade, .inc]] = RangeParam(parm: 0, byte: 74 + off, extra: [ByteCount:4])
//        p[[.voice, .i(v), .lfo, .i(1), .fade, .inc]] = RangeParam(parm: 0, byte: 78 + off, extra: [ByteCount:4])
//
//        p[[.voice, .i(v), .patch, .out]] = RangeParam(parm: 0, byte: 82 + off)
//        p[[.voice, .i(v), .number, .extra]] = RangeParam(parm: 0, byte: 83 + off)
//      }
//      
//      return p
//    }()
//
//  static let rateMap = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 83, 85, 90, 95, 100, 110, 120, 130, 140, 150, 180, 210, 240, 270, 300, 400, 500, 600, 700]
//  
//  static let structureOptions = OptionsParam.makeOptions(["1 osc", "2 osc", "4 osc"])
//
//  static let srcOptions = OptionsParam.makeOptions(["Keyboard", "Centered Keybd", "Velocity", "Exp Velocity", "LFO1", "LFO2", "Env 1", "Aftertouch", "AT + Wheel", "Mod Wheel", "MIDI 1", "MIDI 2", "Pedal"])
//  
//  static let lfoWaves = OptionsParam.makeOptions(["Tri", "Square", "Saw", "Ramp", "Random"])
//  
//  static let mixEnvLoopOptions = OptionsParam.makeOptions(["Off", "0->3", "1->3", "2->3", "0<->3", "1<->3", "2<->3"])
//
//  static let pitchMacroOptions = OptionsParam.makeOptions(["Default", "Env 1 Bend", "Descending", "Ascending", "AfterT Bend", "MIDI Bend", "AfterT + MIDI Bend"])
//  static let filterMacroOptions = OptionsParam.makeOptions(["Bypass", "Low Pass", "Low Pass / LFO", "AfterT Sweep" ])
//  static let envMacroOptions = OptionsParam.makeOptions(["Default", "Piano", "Organ", "Org Release", "Brass", "String", "Clav", "Drum", "Ramp", "On", "Off"])
//  static let panMacroOptions = OptionsParam.makeOptions(["Keyboard", "Velocity", "Key + Velo", "Off"])
//
//  static let waveOptions: [Int:String] = {
//    let waves = ["Soft EP", "Hard EP", "EP Tine", "EP Body1", "EP Body2", "EP Body3", "Digi EP", "E_PIAN03", "CLAV_DSM", "Organ 1", "Organ 2", "Organ 3", "PipeOrg1", "PipeOrg2", "Pluck 1", "Pluck 2", "Pluck 3", "A. Guitar", "E. Guitar", "Dist. Gtr", "EGuitChEme", "MuteGtr1", "MuteGtr2", "MuteGtr3", "Koto", "harmonic", "Stick", "E. Bass", "Synbass1", "Synbass2", "BassHarm", "Vibes", "Hi Bell", "Jar", "TinCup", "Agogo", "Gendar", "Tubular", "New Pole", "Soft Mrmba", "Thai Mrmba", "Glass Hit", "Crystal", "Flute", "FluteTrans", "Overblown", "Bottle", "BassnOboe", "Clarinet", "BariSax", "TenorSax", "AltoSax", "BrassEns", "TromTrp", "Tuba&Flu", "Bowing", "Synorch", "PWM String", "SynString", "Airvox", "Voices", "Choir", "Glass Vox", "\"OO\" Vox", "\"AH\" Vox", "MV Wave", "FV Wave", "DW Voice", "SynthPad", "Birdland", "ChromRes", "ProSync", "SuperSaw", "Ping Wave", "Digital1", "Digital2", "Digital3", "Bellwave", "PercWave", "ShellDrum", "BD head", "Tambourine", "Cabasa", "Woodblock", "HH Loop", "WhiteNoi", "Spectrm1", "Spectrm2", "Spectrm3", "Spectrm4", "Sonar", "Metal 1TR", "Metal 2TR", "KalimbaTR", "GamelanTR", "MarimbaTR", "Potnoise", "Ticker", "VibeHit", "Whack 1", "Whack 2", "HDulciTR", "HoseHit1", "HoseHit2", "SynbassTR", "A.BassTR", "\"ch\"", "\"hhh\"", "\"kkk\"", "\"puh\"", "\"sss\"", "\"tnn\"", "Inharm1", "Inharm2", "Inharm3", "Inharm4", "Inharm5", "Inharm6", "Inharm7", "Inharm8", "Inharm9", "Inharm10", "Formant1", "Formant2", "Formant3",  "Formant4", "Formant5", "Formant6", "Formant7", "Sine", "Triangle", "VS 35", "VS 36", "VS 37", "VS 38", "VS 39", "VS 40", "VS 41", "VS 42", "VS 43", "VS 44", "VS 45", "VS 46", "VS 47", "VS 48", "VS 49", "VS 50", "VS 51", "VS 52", "VS 53", "VS 54", "VS 55", "VS 56", "VS 57", "VS 58", "VS 59", "VS 60", "VS 61", "VS 62", "VS 63", "VS 64", "VS 65", "VS 66", "VS 67", "VS 68", "VS 69", "VS 70", "VS 71", "VS 72", "VS 73", "VS 74", "VS 75", "VS 76", "VS 77", "VS 78", "VS 79", "VS 80", "VS 81", "VS 82", "VS 83", "VS 84", "VS 85", "VS 86", "VS 87", "VS 88", "VS 89", "VS 90", "VS 91", "VS 92", "VS 93", "VS 94", "VS 95", "VS 96", "VS 97", "VS 98", "VS 99", "VS 100", "VS 101", "VS 102", "VS 103", "VS 104", "VS 105", "VS 106", "VS 107", "VS 108", "VS 109", "VS 110", "VS 111", "VS 112", "VS 113", "VS 114", "VS 115", "VS 116", "VS 117", "VS 118", "VS 119", "VS 120", "VS 121", "VS 122", "VS 123", "VS 124", "VS 125", "saw", "OBPUL1", "OBPUL3", "OBPUL4", "OBPUL5", "OBPUL6", "OBPUL7", "OBRES1", "OBRES2", "OBRES3", "OBSAW3", "OBTRESB", "OBTRESD", "OBTRESF", "OBTRESH", "OBTRESJ", "DBTRESL", "OBTRESN", "PPUL2", "PPUL3", "PPUL4", "PPUL5", "PPUL6", "PSAW2", "13 - 01", "13 - 03", "13 - 05", "13 - 07", "13 - 09", "13 - 11", "13 - 13", "13 - 15", "13 - 17", "13 - 19", "13 - 21", "13 - 23", "13 - 25", "13 - 27", "13 - 29", "13 - 31", "13 - 33", "13 - 35", "13 - 37", "13 - 39", "13 - 41", "13 - 43", "13 - 45", "13 - 47", "13 - 49", "13 - 51", "13 - 53", "13 - 55", "13 - 57", "13 - 59", "13 - 61", "13 - 63", "resx001", "resx002", "resx003", "resx004", "resx005", "resx006", "resx007", "resx008", "resx009", "resx010", "resx011", "resx012", "resx013", "resx014", "resx015", "resx016", "resx017", "resx018", "resx019", "resx020", "resx021", "resx022", "resx023", "resx024", "resx025", "resx026", "resx027", "resx028", "resx029", "resx030", "resx031", "resx032", "Min1 - 01a", "Min1 - 02a", "Min1 - 04a", "Min1 - 05a", "Min1 - 06a", "Min1 - 07a", "Min1 - 08a", "Min1 - 09a", "Min1 - 12a", "Min1 - 13a", "Pres321", "Pres335", "Pres349", "Pres363", "Pres377", "Pres384", "Pres391", "Pres398", "Pres110", "Pres3112", "Pres3119", "Pres3126", "Sax .1sec", "Sax 1 sec", "Sax 1.3sec", "Sax 1.5sec", "Sax 1.7sec", "Sax 2 sec", "Sax 2.2sec", "Sax 2.4sec", "Sax 2.7sec", "Sax 2.9sec", "Sax 3 sec", "Sax 3.4sec", "Sax 3.6sec", "Sax 4.3sec", "Sax 4.7sec", "Sax 5 sec", "Square", "Pulse02", "Pulse04", "Pulse06", "Pulse08", "Pulse10", "Pulse12", "Pulse14", "Pulse16", "Pulse18", "Pulse20", "Pulse22", "Pulse24", "Pulse26", "Pulse28", "Pulse30", "Pulse31", "MagicOrgan", "Magic 1a", "Crickets", "Noise 2", "GrandPiano", "DigiPiano", "SynthPd2", "SynPad2a", "AirSynth", "VoiceSyn", "VoiSyn1a", "BellWind", "PWM", "AnaStrings", "Square Res", "Res Wave", "TrashWave", "TrshWv1a", "PsychoWave", "SynBass3", "SynBas3a", "DynoBass", "DynoBs1a", "DeepBass", "DeepBs1a", "MiniBass", "MiniBs1a", "Slap Bass", "Fretless", "Fretles1a", "Cello", "Cello 1a", "AltoSax2", "Horn Sectn", "FrenchHorn", "PanFlute", "PanFl 1a", "Hard Flute", "Wood Flute", "Harmonium", "Hrmnium1a", "Guitar 1", "Guitar 2", "Harp", "Harp 1a", "Shamisen", "Shamsn1a", "Marimba", "Marim 1a", "Marim Loop", "HrdKalimba", "SofKalimba", "SftKalim1a", "Vibes 2", "PercBell", "M.Heaven", "BrightBell", "BrBel 1a", "Drum Kit", "Kick", "AmbiKick", "Crack Snar", "Snare", "Sidestick", "Tom", "HiHat Clos", "HiHat Open", "Conga", "Conga Loop", "Claves", "Tenny Hit", "Thonk", "Tick Hit", "Pot Hit", "Hammer", "PianoHit", "NoiseVibe", "\"Tuunn\"", "\"Pehh\"", "\"Thuum\"", "\"Kaahh\"", "\"Tchh\"", "\"Pan\"", "\"Ti\"", "\"Cap\"", "\"Chhi\"", "\"Tinn\"", "\"Haaa\"", "Glottal", "VS 126", "VS 127", "VS 128", "VS 129", "VS 130", "VS 131", "VS 132", "VS 133", "VS 134", "VS 135", "VS 136", "VS 137", "VS 138", "VS 139", "VS 140", "VS 141", "VS 142", "VS 143", "VS 144", "VS 145", "VS 146", "VS 147", "VS 148", "VS 149", "VS 150", "VS 151", "VS 152", "VS 153", "VS 154", "VS 155", "Input1 [A/D]", "Input2 [A/D]"]
//    
//    var opts = [Int:String]()
//    waves.enumerated().forEach {
//      let i = $0.offset + 32
//      opts[i] = "\(i): \($0.element)"
//    }
//    return opts
//  }()
//  
//  // 0 -> Bank 3 (shown as 4) through 10 (shown as 11)
//  static let waveSeqOptions: [[Int:String]] = [
//    OptionsParam.makeNumberedOptions(["Snare 1", "16 Rthm", "Kick", "DSdrms", "Afrika", "DSbass", "Helicop", "BizyVox", "MagiWnd", "Gtr+Pno", "Orch WS", "NoizBug", "Rain D1", "RedRain", "W echoL", "Drum R", "Drum L", "W echoR", "Mr.Funk", "Kinko", "1/4 Kik", "HHts 1", "TikTok", "Snare 2", "Jungle1", "Crazy’X", "Kik+Snr", "JoVox", "LoopDrm", "FunW/16", "Indstrl", "Jungle2" ]),
//    OptionsParam.makeNumberedOptions(["Chug", "Chug5th", "Brite 1", "Harpsi1", "ZooLoo1", "PlukOB2", "Res&Pul", "AeroPad", "Bas&Pad", "VibrSaw", "WaterPh", "GlasLoo", "TubelGl", "TinAgo", "Bass 3", "ChifTyn", "HdChif1", "Mini 4", "Mini 2", "Mini 6", "BrasTrn", "WveStas", "E.Bass1", "Ch+Kkk", "PGDance", "AngelBl", "AnglBl2", "Mystery", "RezDown", "RezBass", "Pulses3", "Resomin" ]),
//    OptionsParam.makeNumberedOptions(["Life1", "Life 2", "StdyKik", "RunHats", "Heebie", "Jeebies", "Noizz1", "Trmnatr", "PanMal1", "PanMal2", "AvengrB", "Mr. 4/4", "IbidBox", "Iso Box", "Swirls", "TrasHyb", "HarpPad", "Cross B", "Groove1", "Bounce1", "BasiKik", "Hats 3", "Conga 1", "FunSnar", "Bounce2", "Hatties", "SynWav2", "KikPat1", "Kuntry1", "Kuntry2", "8_6/8KS", "Haties2" ]),
//    OptionsParam.makeNumberedOptions(["WS Harp", "WS Bell", "Inharmo", "HouseBs", "HipHop", "OB)PWM", "OB(PWM", "Owwaah!", "Inharmc", "Harpsi", "HarpGl", "Ping!", "BentMin", "SDB2", "String", "PWM", "Atmos", "Haunted", "Alien1", "Freddie", "AnglBl3", "Bell1", "Subtle", "Digits", "B-Stng", "Orient", "Tin Stg", "Swerl", "Evolver", "OB Wow", "Tribes", "Wildlie" ]),
//    OptionsParam.makeNumberedOptions(["Rap Hat", "RapFill", "Rap K&S", "RapVar2", "Rap Var", "EPnoPad", "VelEPno", "PanBell", "SaxBrss", "HrnyBrs", "RapKick", "ZapKick", "ZapSnar", "HarpRun", "SpdMtl", "TingStr", "BowdPad", "BowdStr", "BowdSyn", "BowCelo", "Nyloner", "AckGits", "SonrVox", "NylnFlt", "TickSyn", "AirPerc", "BrthPad", "THOKbas", "KUHLbas", "HarmBas", "KlikBas", "MidiEko" ]),
//    OptionsParam.makeNumberedOptions(["Unknown", "Strince", "Taurust", "Celsia2", "SlowRes", "Ariane", "HellBel", "Organic", "Quicky2", "Drums!", "Chromes", "Spectrm", "WSNois2", "Tubular", "BendUp", "Inharma", "WetDrem", "VSWave3", "BusyBas", "Heaven1", "Heaven2", "Waiting", "SlapSeq", "PolySeq", "HowHats", "HowKik+", "HowSnar", "HowDity", "KotoPad", "FeedBck", "DarkSid", "Tremol" ]),
//    OptionsParam.makeNumberedOptions(["WhlVox", "KikS", "Quar", "Stri", "Hats", "S. Pole", "Galaxis", "SpSail", "RappaWv", "SlowGls", "2->3 Pt", "Samba 1", "Samba 2", "Tambou", "Forest", "Caba", "Galax2", "Chime", "Agogo", "WoodBrc", "Tremolo", "PoppaBs", "Morgan", "Bassing", "Bassier", "Afro 1", "E.Bass", "Brass 1", "BassHar", "Orbits", "SloWav2", "TaDream" ]),
//    OptionsParam.makeNumberedOptions(["WSTouch", "DeepWav", "Quarks", "ResXwav", "Strings", "Unison", "WSMetal", "WS S&H", "WSTable", "WSVoice", "ResMove", "WSNoise", "LobWave", "FolowMe", "P5 Res", "Complex", "WS Fade", "VelHarm", "Mini", "SoftWav", "Spectra", "WSGrowl", "SynWav1", "EnSweep", "GateRez", "Marbles", "Ostinat", "Drops", "SloWave", "WavRytm", "Ski Jam", "WavSong" ]),
//  ]
//
//}

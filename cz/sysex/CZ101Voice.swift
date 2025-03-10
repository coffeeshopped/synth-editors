
extension CZ101 {
  
  enum Voice {
    
//    public class func location(forData data: Data) -> Int { Int(data[6]) - 0x20 }

    static let validBundle = SinglePatchTruss.Core.validBundle(counts: [263,264,295,296])

    // cz-101 style or cz-1 style
    static let patchTruss = try! SinglePatchTruss("cz101.voice", 256, params: parms.params(), initFile: "CZ-init", createFileData: {
      sysexData($0, channel: 0, location: 0x60, cz1: false)
    }, parseBodyData: {
      let contentByteCount = 256
      switch $0.count {
      case 264, 296:
        // from a file (1 extra byte in header)
        return $0.safeBytes(7..<(7+contentByteCount))
      case 263, 295:
        // a fetched patch has 1 fewer byte in the header
        return $0.safeBytes(6..<(6+contentByteCount))
      default:
        // who knows
        return [UInt8](repeating: 0, count: contentByteCount)
      }
    }, validBundle: validBundle)

    
    static func bankTruss(patchCount: Int) -> SingleBankTruss {
      let fileDataCount = 263 * patchCount
      let defaultParse = SingleBankTrussWerk.sortAndParseBodyDataWithLocationMap({
        Int($0[6]) - 0x20
      }, patchTruss: patchTruss, patchCount: patchCount)
      let validBundle = SingleBankTruss.Core.validBundle(counts: [fileDataCount, fileDataCount + patchCount])
      
      return SingleBankTruss(patchTruss: patchTruss, patchCount: patchCount, createFileData: SingleBankTrussWerk.createFileDataWithLocationMap {
        sysexData($0, channel: 0, location: 0x20 + $1, cz1: false)
      }, parseBodyData: {
        switch $0.count {
        case fileDataCount + patchCount:
          return try defaultParse($0)
        default:
          // from fetch. order of msgs determines locations
          let sysex = SysexData(data: Data($0))
          return try (0..<patchCount).map {
            guard $0 < sysex.count else { return [UInt8](repeating: 0, count: patchTruss.bodyDataCount) }
            return try patchTruss.parseBodyData(sysex[$0].bytes())
          }
        }

      }, validBundle: validBundle)
    }
    
    // only diff is 0x21 (instead of 0x20)
    // signifies this is a CZ-1 patch (with name, velo data)
    static func sysexData(_ bytes: [UInt8], channel: Int, location: Int, cz1: Bool) -> [UInt8] {
      [0xf0, 0x44, 0x00, 0x00, 0x70 + UInt8(channel), (cz1 ? 0x21 : 0x20), UInt8(location)] + bytes + [0xf7]
    }
        

    static let parms: [Parm] = {
      var p: [Parm] = [
        .p([.osc, .i(0), .wave, .i(0)], packIso: dco1Wave1, .opts(waveOptions)),
        .p([.osc, .i(0), .wave, .i(1)], packIso: dco1Wave2, .opts(waveOffOptions)),
        .p([.osc, .i(1), .wave, .i(0)], packIso: dco2Wave1, .opts(waveOptions)),
        .p([.osc, .i(1), .wave, .i(1)], packIso: dco2Wave2, .opts(waveOffOptions)),
      ]

      p += .prefix([.osc], count: 2, bx: 0, block: { osc in
        [
          .p([.env, .sustain], packIso: dcoEnvSustain(osc), .max(7, dispOff: 1)),
          .p([.env, .end], packIso: dcoEnvEnd(osc), .max(7, dispOff: 1)),
          .p([.velo], packIso: dcoEnvVelo(osc), .max(15)),
        ] + .prefix([.env], block: {
          .prefix([.rate], count: 8, bx: 0) { step in
            [.p([], packIso: dcoEnv(osc, rate: step), .max(99))]
          } +
          .prefix([.level], count: 8, bx: 0) { step in
            [.p([], packIso: dcoEnv(osc, level: step), .max(99))]
          }
        })
      })
      
      p += .prefix([.filter], count: 2, bx: 0, block: { line in
        [
          .p([.env, .sustain], packIso: dcwEnvSustain(line), .max(7, dispOff: 1)),
          .p([.env, .end], packIso: dcwEnvEnd(line), .max(7, dispOff: 1)),
          .p([.velo], packIso: dcwEnvVelo(line), .max(15)),
          .p([.keyTrk], packIso: dcwKeyFollow(line), .max(9)),
        ] + .prefix([.env], block: {
          .prefix([.rate], count: 8, bx: 0) { step in
            [.p([], packIso: dcwEnv(line, rate: step), .max(99))]
          } +
          .prefix([.level], count: 8, bx: 0) { step in
            [.p([], packIso: dcwEnv(line, level: step), .max(99))]
          }
        })
      })

      p += .prefix([.amp], count: 2, bx: 0, block: { line in
        [
          .p([.env, .sustain], packIso: dcaEnvSustain(line), .max(7, dispOff: 1)),
          .p([.env, .end], packIso: dcaEnvEnd(line), .max(7, dispOff: 1)),
          .p([.velo], packIso: dcaEnvVelo(line), .max(15)),
          .p([.keyTrk], packIso: dcaKeyFollow(line), .max(9)),
          .p([.level], packIso: dcaLevel(line), .rng(1...15)),
        ] + .prefix([.env], block: {
          .prefix([.rate], count: 8, bx: 0) { step in
            [.p([], packIso: dcaEnv(line, rate: step), .max(99))]
          } +
          .prefix([.level], count: 8, bx: 0) { step in
            [.p([], packIso: dcaEnv(line, level: step), .max(99))]
          }
        })
      })

      p += [
        .p([.select], packIso: lineSelect, .opts(["1", "2", "1+1'", "1+2'"])),
        .p([.detune, .direction], packIso: detuneDirection, .opts(["Up", "Down"])),
        .p([.detune, .octave], packIso: detuneOctave, .opts(["0","1","2","3"])),
        .p([.detune, .note], packIso: detuneNote, .max(11)),
        .p([.detune, .fine], packIso: detuneFine, .max(60)),
        .p([.mod], packIso: modulation, .opts(["None", "Ring", "Noise"])),
        .p([.octave], packIso: octave, .opts(["-1", "0", "+1"])),
        .p([.vib, .wave], packIso: vibWave, .opts(["Triangle", "Up Saw", "Down Saw", "Square"])),
        .p([.vib, .delay], packIso: vibDelay, .max(99)),
        .p([.vib, .rate], packIso: vibRate, .max(99)),
        .p([.vib, .depth], packIso: vibDepth, .max(99)),
      ]

      return p
    }()

//    static let waveOptions = OptionsParam.makeOptions(["Saw", "Square", "Pulse", "Double Sine", "Saw Pulse", "Resonance 1", "Resonance 2", "Resonance 3"])
//    static let waveOffOptions = OptionsParam.makeOptions(["Saw", "Square", "Pulse", "Double Sine", "Saw Pulse", "Resonance 1", "Resonance 2", "Resonance 3", "Off"])
    static let waveOptions = (1...8).map { "cz-wav-\($0)" }
    static let waveOffOptions = waveOptions + ["cz-wav-off"]

    
    static func setByte(_ bytes: inout [UInt8], _ i: Int, v: UInt8) {
      // cz does this thing where it splits 1 byte into 2
      bytes[(i*2)] = v & 0xf
      bytes[(i*2)+1] = (v >> 4) & 0xf
    }
    
    static func byte(_ bytes: [UInt8], _ i: Int) -> UInt8 {
      let b1 = bytes[(i*2)]
      let b2 = bytes[(i*2)+1]
      return (b2 << 4) | b1
    }

    // MARK: DCO

    static let dco1Wave1 = PackIso(pack: {
      setDcoWave1(&$0, $1, startByte: 14)
    }, unpack: {
      Int(dcoWave1WithStartByte($0, 14))
    })
    
    static let dco1Wave2 = PackIso(pack: {
      setDcoWave2(&$0, $1, startByte: 14)
    }, unpack: {
      Int(dcoWave2WithStartByte($0, 14))
    })
    
    static let dco2Wave1 = PackIso(pack: {
      setDcoWave1(&$0, $1, startByte: 71)
    }, unpack: {
      Int(dcoWave1WithStartByte($0, 71))
    })
    
    static let dco2Wave2 = PackIso(pack: {
      setDcoWave2(&$0, $1, startByte: 71)
    }, unpack: {
      Int(dcoWave2WithStartByte($0, 71))
    })
    
    
    private static func dcoWave1WithStartByte(_ bytes: [UInt8], _ startByte: Int) -> UInt8 {
      let v1 = (byte(bytes, startByte) >> 5) & 7
      let v2 = (byte(bytes, startByte + 1) >> 6) & 3
      
      if v1 < 6 {
        let lookup: [UInt8:UInt8] = [
          0 : 0,
          1 : 1,
          2 : 2,
          4 : 3,
          5 : 4
        ]
        return lookup[v1] ?? 0
      }
      else {
        return v2 + 4
      }
    }
    
    private static func dcoWave2WithStartByte(_ bytes: [UInt8], _ startByte: Int) -> UInt8 {
      let v1 = (byte(bytes, startByte) >> 1) & 15
      let v2 = (byte(bytes, startByte+1) >> 6) & 3
      
      if v1 < 13 {
        let lookup: [UInt8:UInt8] = [
          0 : 8,
          1 : 0,
          3 : 1,
          5 : 2,
          9 : 3,
          11: 4
        ]
        return lookup[v1] ?? 0
      }
      else {
        return v2 + 4
      }
    }
    
    private static func setDcoWave1(_ bytes: inout [UInt8], _ v: Int, startByte: Int) {
      var byte1 = byte(bytes, startByte)
      var byte2 = byte(bytes, startByte+1)
      
      let lookup1 = [ 0, 1, 2, 4, 5, 6, 6, 6 ]
      let lookup2 = [ 0, 0, 0, 0, 0, 1, 2, 3 ]
      
      byte1 = (byte1 & 0x1f) | UInt8(lookup1[v] << 5)
      
      let otherV = dcoWave2WithStartByte(bytes, startByte)
      // only set second byte if waveform is reso, or other wave form is NOT reso
      if (v > 4 || otherV < 5) {
        byte2 = (byte2 & 0x3f) | UInt8(lookup2[v] << 6)
      }
      
      setByte(&bytes, startByte, v:byte1)
      setByte(&bytes, startByte+1, v:byte2)
    }
    
    // v: 8 = NONE
    private static func setDcoWave2(_ bytes: inout [UInt8], _ v: Int, startByte:Int) {
      var byte1 = byte(bytes, startByte)
      var byte2 = byte(bytes, startByte+1)
      
      let lookup1 = [ 1, 3, 5, 9, 11, 13, 13, 13, 0 ]
      let lookup2 = [ 0, 0, 0, 0, 0, 1, 2, 3, 0 ]
      
      byte1 = (byte1 & 0xe0) | UInt8(lookup1[v] << 1)
      
      let otherV = dcoWave1WithStartByte(bytes, startByte)
      // only set second byte if waveform is reso, or other wave form is NOT reso
      if (v > 4 || otherV < 5) {
        byte2 = (byte2 & 0x3f) | UInt8(lookup2[v] << 6)
      }
      
      setByte(&bytes, startByte, v:byte1)
      setByte(&bytes, startByte+1, v:byte2)
    }
    
    private static func dcoEnvIndex(_ env: Int) -> Int { env == 0 ? 54 : 111 }

    static func dcoEnvSustain(_ env: Int) -> PackIso {
      .init(pack: {
        for i in 0..<8 {
          let byteIndex = dcoEnvIndex(env) + 2 + 2 * i
          var level = byte($0, byteIndex) % 128
          if i == $1 { level += 128 }
          setByte(&$0, byteIndex, v: UInt8(level))
        }
      }, unpack: {
        for i in 0..<8 {
          let byteIndex = dcoEnvIndex(env) + 2 + 2 * i
          if byte($0, byteIndex) > 127 { return i }
        }
        return 7
      })
    }
    
    static func dcoEnvEnd(_ env: Int) -> PackIso {
      .init(pack: {
        let index = dcoEnvIndex(env)
        setByte(&$0, index, v: UInt8(byte($0, index).set(bits: 0...3, value: $1)))
      }, unpack: {
        Int(byte($0, dcoEnvIndex(env))) & 0xf
      })
    }

    static func dcoEnvVelo(_ env: Int) -> PackIso {
      .init(pack: {
        let index = dcoEnvIndex(env)
        setByte(&$0, index, v: UInt8(byte($0, index).set(bits: 4...7, value: $1)))
      }, unpack: {
        byte($0, dcoEnvIndex(env)).bits(4...7)
      })
    }

    static func dcoEnv(_ env: Int, rate r: Int) -> PackIso {
      .init(pack: {
        let byteIndex = dcoEnvIndex(env) + 1 + 2*r
        var rateByte = ($1 * 127)/99
        if r > 0 {
          let level = dcoEnv($0, env, level: r)
          let previousLevel = dcoEnv($0, env, level: r-1)
          if previousLevel > level { rateByte += 128 }
        }
        
        setByte(&$0, byteIndex, v: UInt8(rateByte))
      }, unpack: {
        dcoEnv($0, env, rate: r)
      })
    }
    
    static func dcoEnv(_ bytes: [UInt8], _ env: Int, rate r: Int) -> Int {
      let byteIndex = dcoEnvIndex(env) + 1 + 2*r
      let byte1 = Int(byte(bytes, byteIndex) % 128)
      return byte1 == 0 ? 0 : byte1 == 127 ? 99 : (byte1*99)/127 + 1
    }
    
    static func dcoEnv(_ env: Int, level l: Int) -> PackIso {
      let envSus = dcoEnvSustain(env).unpack
      return .init(pack: {
        let sustainIndex = envSus($0)
        for i in 0..<8 {
          let byteIndex = dcoEnvIndex(env) + 1 + 2*i
          
          let level = i == l ? $1 : dcoEnv($0, env, level: i)

          var rateByte = (dcoEnv($0, env, rate: i) * 127) / 99
          if i > 0 {
            let previousLevel = i-1 == l ? $1 : dcoEnv($0, env, level: i-1)
            if previousLevel > level { rateByte += 128 }
          }
          
          var levelByte = level
          if levelByte > 63 { levelByte += 4 }
          if i == sustainIndex { levelByte += 128 }
          
          setByte(&$0, byteIndex, v: UInt8(rateByte))
          setByte(&$0, byteIndex+1, v: UInt8(levelByte))
        }
      }, unpack: {
        dcoEnv($0, env, level: l)
      })
    }
    
    static func dcoEnv(_ bytes: [UInt8], _ env: Int, level l: Int) -> Int {
      let byteIndex = dcoEnvIndex(env) + 2 + 2 * l
      let byte2 = Int(byte(bytes, byteIndex) % 128)
      return byte2 < 64 ? byte2 : byte2 - 4
    }

    
    // MARK: DCW
    
    private static func dcwEnvIndex(_ env: Int) -> Int { env == 0 ? 37 : 94 }
    
    static func dcwEnv(_ env: Int, rate r: Int) -> PackIso {
      .init(pack: {
        let byteIndex = dcwEnvIndex(env) + 1 + 2*r
        var rateByte = ($1 * 119)/99 + 8
        if r > 0 {
          let level = dcwEnv($0, env, level: r)
          let previousLevel = dcwEnv($0, env, level: r-1)
          if previousLevel > level { rateByte += 128 }
        }
        
        setByte(&$0, byteIndex, v: UInt8(rateByte))
      }, unpack: {
        dcwEnv($0, env, rate: r)
      })
    }
    
    static func dcwEnv(_ bytes: [UInt8], _ env: Int, rate r: Int) -> Int {
      let byteIndex = dcwEnvIndex(env) + 1 + 2*r
      let byte1 = Int(byte(bytes, byteIndex) % 128)
      return byte1 <= 8 ? 0 : byte1 == 127 ? 99 : ((byte1-8)*99)/119 + 1
    }
    
    static func dcwEnv(_ env: Int, level l: Int) -> PackIso {
      let sus = dcwEnvSustain(env).unpack
      return .init(pack: {
        let sustainIndex = sus($0)
        for i in 0..<8 {
          let byteIndex = dcwEnvIndex(env) + 1 + 2*i
          
          let level = i == l ? $1 : dcwEnv($0, env, level: i)
          
          var rateByte = (dcwEnv($0, env, rate: i) * 119)/99 + 8
          if i > 0 {
            let previousLevel = i-1 == l ? $1 : dcwEnv($0, env, level: i - 1)
            if previousLevel > level { rateByte += 128 }
          }
          
          var levelByte = (level*127)/99
          if i == sustainIndex { levelByte += 128 }
          
          setByte(&$0, byteIndex, v: UInt8(rateByte))
          setByte(&$0, byteIndex+1, v: UInt8(levelByte))
        }
      }, unpack: {
        dcwEnv($0, env, level: l)
      })
    }
    
    static func dcwEnv(_ bytes: [UInt8], _ env: Int, level l: Int) -> Int {
      let byteIndex = dcwEnvIndex(env) + 2 + 2*l
      let byte2 = Int(byte(bytes, byteIndex) % 128)
      return byte2 == 0 ? 0 : byte2 == 127 ? 99 : (byte2*99)/127 + 1
    }
    
    static func dcwEnvSustain(_ env: Int) -> PackIso {
      .init(pack: {
        for i in 0..<8 {
          let byteIndex = dcwEnvIndex(env) + 2 + 2*i
          var level = byte($0, byteIndex) % 128
          if i == $1 { level += 128 }
          setByte(&$0, byteIndex, v: level)
        }
      }, unpack: {
        for i in 0..<8 {
          let byteIndex = dcwEnvIndex(env) + 2 + 2*i
          if byte($0, byteIndex) > 127 { return i }
        }
        return 7
      })
    }
    
    static func dcwEnvEnd(_ env: Int) -> PackIso {
      .init(pack: {
        let index = dcwEnvIndex(env)
        setByte(&$0, index, v: UInt8(byte($0, index).set(bits: 0...3, value: $1)))
      }, unpack: {
        Int(byte($0, dcwEnvIndex(env))) & 0xf
      })
    }

    static func dcwEnvVelo(_ env: Int) -> PackIso {
      .init(pack: {
        let index = dcwEnvIndex(env)
        setByte(&$0, index, v: UInt8(byte($0, index).set(bits: 4...7, value: $1)))
      }, unpack: {
        byte($0, dcwEnvIndex(env)).bits(4...7)
      })
    }
    
    static func dcwKeyFollow(_ env: Int) -> PackIso {
      .init(pack: {
        let index = env == 0 ? 18 : 75
        let lookup: [UInt8] = [ 0, 31, 44, 57, 70, 83, 96, 110, 146, 255 ]
        setByte(&$0, index, v:UInt8($1))
        setByte(&$0, index+1, v: lookup[$1])
      }, unpack: {
        Int(byte($0, env == 0 ? 18 : 75))
      })
    }

    
    // MARK: DCA
    
    private static func dcaEnvIndex(_ env: Int) -> Int { env == 0 ? 20 : 77 }
    
    static func dcaEnv(_ env: Int, rate r: Int) -> PackIso {
      .init(pack: {
        let byteIndex = dcaEnvIndex(env) + 1 + 2*r
        var rateByte = ($1 * 119)/99
        if r > 0 {
          let level = dcaEnv($0, env, level: r)
          let previousLevel = dcaEnv($0, env, level: r-1)
          if previousLevel > level { rateByte += 128 }
        }
        
        setByte(&$0, byteIndex, v: UInt8(rateByte))
      }, unpack: {
        dcaEnv($0, env, rate: r)
      })
    }
    
    static func dcaEnv(_ bytes: [UInt8], _ env: Int, rate r: Int) -> Int {
      let byteIndex = dcaEnvIndex(env) + 1 + 2*r
      let byte1 = Int(byte(bytes, byteIndex) % 128)
      return byte1 == 0 ? 0 : byte1 >= 119 ? 99 : (byte1*99)/119 + 1
    }
    
    static func dcaEnv(_ env: Int, level l: Int) -> PackIso {
      let sus = dcaEnvSustain(env).unpack
      return .init(pack: {
        let sustainIndex = sus($0)
        for i in 0..<8 {
          let byteIndex = dcaEnvIndex(env) + 1 + 2*i
          
          let level = i == l ? $1 : dcaEnv($0, env, level: i)
          
          var rateByte = (dcaEnv($0, env, rate: i) * 119)/99
          if i > 0 {
            let previousLevel = i-1 == l ? $1 : dcaEnv($0, env, level: i-1)
            if previousLevel > level { rateByte += 128 }
          }
          
          var levelByte = level == 0 ? 0 : level + 28
          if i == sustainIndex { levelByte += 128 }
          
          setByte(&$0, byteIndex, v: UInt8(rateByte))
          setByte(&$0, byteIndex+1, v: UInt8(levelByte))
        }
      }, unpack: {
        dcaEnv($0, env, level: l)
      })
    }
    
    static func dcaEnv(_ bytes: [UInt8], _ env: Int, level l: Int) -> Int {
      let byteIndex = dcaEnvIndex(env) + 2 + 2*l
      let byte2 = Int(byte(bytes, byteIndex) % 128)
      return byte2 < 28 ? 0 : byte2 - 28
    }
    
    static func dcaEnvSustain(_ env: Int) -> PackIso {
      .init(pack: {
        for i in 0..<8 {
          let byteIndex = dcaEnvIndex(env) + 2 + 2*i
          var level = byte($0, byteIndex) % 128
          if i == $1 { level += 128}
          setByte(&$0, byteIndex, v:UInt8(level))
        }
      }, unpack: {
        for i in 0..<8 {
          let byteIndex = dcaEnvIndex(env) + 2 + 2*i
          if byte($0, byteIndex) > 127 { return i }
        }
        return 7
      })
    }
    
    static func dcaEnvEnd(_ env: Int) -> PackIso {
      .init(pack: {
        let index = dcaEnvIndex(env)
        setByte(&$0, index, v: UInt8(byte($0, index).set(bits: 0...3, value: $1)))
      }, unpack: {
        Int(byte($0, dcaEnvIndex(env))) & 0xf
      })
    }
    
    static func dcaEnvVelo(_ env: Int) -> PackIso {
      .init(pack: {
        let index = dcaEnvIndex(env)
        setByte(&$0, index, v: UInt8(byte($0, index).set(bits: 4...7, value: $1)))
      }, unpack: {
        byte($0, dcaEnvIndex(env)).bits(4...7)
      })
    }


    private static func dcaKFIndex(_ env: Int) -> Int { env == 0 ? 16 : 73 }
    
    static func dcaLevel(_ env: Int) -> PackIso {
      .init(pack: {
        let index = dcaKFIndex(env)
        setByte(&$0, index, v: UInt8(byte($0, index).set(bits: 4...7, value: 15-$1)))
      }, unpack: {
        15 - Int(byte($0, dcaKFIndex(env))).bits(4...7)
      })
    }
        
    static func dcaKeyFollow(_ env: Int) -> PackIso {
      .init(pack: {
        let index = dcaKFIndex(env)
        let keyFollowLookup: [UInt8] = [ 0x00, 0x08, 0x11, 0x1a, 0x24, 0x2f, 0x3a, 0x45, 0x52, 0x5f ]
        setByte(&$0, index, v: UInt8(byte($0, index).set(bits: 0...3, value: $1)))
        setByte(&$0, index+1, v: keyFollowLookup[$1])
      }, unpack: {
        Int(byte($0, dcaKFIndex(env))) & 0xf
      })
    }
    
    // MARK: Mods
    
    static let modulation = PackIso(pack: {
      let lookup = [ 0, 4, 3 ]
      let b = byte($0, 15).set(bits: 3...5, value: lookup[$1])
      setByte(&$0, 15, v: b)
    }, unpack: {
      let v = byte($0, 15).bits(3...5)
      let lookup = [ 0, 4, 3 ]
      return lookup.firstIndex(of: v) ?? 0
    })
    
    // 0: -1
    // 1: 0
    // 2: +1
    static let octave = PackIso(pack: {
      let b = byte($0, 0).set(bits: 2...3, value: ($1+2) % 3)
      setByte(&$0, 0, v: b)
    }, unpack: {
      let v = byte($0, 0).bits(2...3)
      return (v+1) % 3
    })

    
    static let lineSelect = PackIso(pack: {
      setByte(&$0, 0, v: byte($0, 0).set(bits: 0...1, value: $1))
    }, unpack: {
      byte($0, 0).bits(0...1)
    })
    
    // MARK: Detune
    
    static let detuneDirection = PackIso(pack: {
      setByte(&$0, 1, v:UInt8($1))
    }, unpack: {
      Int(byte($0, 1))
    })
    
    static let detuneOctave = PackIso(pack: {
      let oct = UInt8(min(max($1,0),3))
      let b = byte($0, 3)
      setByte(&$0, 3, v: (oct*12) + (b%12))
    }, unpack: {
      Int(byte($0, 3)) / 12
    })

    static let detuneNote = PackIso(pack: {
      let n = UInt8(min(max($1,0),11))
      let b = byte($0, 3)
      setByte(&$0, 3, v:(b - (b % 12)) + n)
    }, unpack: {
      Int(byte($0, 3)) % 12
    })
    
    static let detuneFine = PackIso(pack: {
      let f = min(max($1,0),60)
      setByte(&$0, 2, v:UInt8(4*((f-1)/15 + f)))
    }, unpack: {
      Int(byte($0, 2)/4 - byte($0, 2)/64)
    })
    
    // MARK: Vibrato
    
    static let vibWave = PackIso(pack: {
      let lookup = [ 8, 4, 32, 2 ]
      setByte(&$0, 4, v: UInt8(lookup[$1]))
    }, unpack: {
      let lookup: [UInt8] = [ 8, 4, 32, 2 ]
      return lookup.firstIndex(of: byte($0, 4)) ?? 0
    })

    static let vibDelay = PackIso(pack: {
      let vib = min(max($1,0),99)
      let lookup = [ 0, 0, 31, 125, 377, 1009, 2529 ]
      let vibShift4 = vib >> 4
      let v = vib < 16 ? vib : (vib * (1 << (vibShift4 - 1))) - lookup[vibShift4]
      setByte(&$0, 5, v:UInt8(vib))
      setByte(&$0, 6, v:UInt8(v & 0xff))
      setByte(&$0, 7, v:UInt8(v >> 8))
    }, unpack: {
      Int(byte($0, 5))
    })
    
    static let vibRate = PackIso(pack: {
      var v: Int
      let vib: Int = min(max($1,0),99)
      let lookup: [Int] = [ 0, -32, 928, 3872, 11808, 31776, 79904 ]
      if vib < 16 {
        v = Int(vib + 1) * 32
      }
      else {
        v = vib
        let shift: Int = ((v + 1) >> 4) + 4
        let vShift4: Int = v >> 4
        v = (v * (1 << shift)) - lookup[vShift4]
      }
      setByte(&$0, 8, v: UInt8(vib))
      setByte(&$0, 9, v: UInt8(v & 0xff))
      setByte(&$0, 10, v: UInt8(v >> 8))
    }, unpack: {
      Int(byte($0, 8))
    })
    
    static let vibDepth = PackIso(pack: {
      var v: Int
      let vib = min(max($1,0),99)
      let lookup = [ 0, 0, 31, 125, 377, 1009, 2529 ]
      if vib < 16 {
        v = vib
      }
      else if vib < 99 {
        v = vib + 1
        let vibShift4 = vib >> 4
        v = (v * (1 << (vibShift4 - 1))) - lookup[vibShift4]
      }
      else {
        v = 768
      }
      setByte(&$0, 11, v: UInt8(vib))
      setByte(&$0, 12, v:UInt8(v & 0xff))
      setByte(&$0, 13, v:UInt8(v >> 8))
    }, unpack: {
      Int(byte($0, 11))
    })


  }
  
}

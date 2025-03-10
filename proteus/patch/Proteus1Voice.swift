
typealias ProteusInstMapItem = (inst: Int, set: Int, name: String)

extension Proteus1 {
  
  enum Voice {
  

    
//    func randomize() {
//      randomizeAllParams()
//      (0..<3).forEach {
//        self[[.link, .i($0)]] = -1
//      }
//      (0..<4).forEach {
//        self[[.key, .lo, .i($0)]] = 0
//        self[[.key, .hi, .i($0)]] = 127
//      }
//      (0..<2).forEach {
//        self[[.i($0), .key, .lo]] = 0
//        self[[.i($0), .key, .hi]] = 127
//      }
//      self[[.i(0), .volume]] = 127
//      self[[.i(0), .delay]] = 0
//      self[[.i(0), .start]] = 0
//      self[[.i(1), .delay]] = (0...10).random()!
//
//      self[[.mix]] = 0
//    }
    
    static let patchTruss = createPatchTruss(proteus: 1, parms: parms, initFile: "proteus1-voice-init")
    static func createPatchTruss(proteus: Int, parms: [Parm], initFile: String) -> SinglePatchTruss {
      try! SinglePatchTruss("proteus\(proteus).voice", 256, namePackIso: namePackIso, params: parms.params(), initFile: initFile, createFileData: {
        sysexData($0, deviceId: 0).flatMap { $0 }
      }, parseBodyData: {
        switch $0.count {
        case 265:
          return [UInt8]($0[7..<263]) // 256 data bytes
        default:
          var bytes = [UInt8](repeating: 0, count: 256)
          SysexData(data: $0.data()).forEach { msg in
            guard msg.count > 8 else { return }
            let off = Int(msg[5]) + (Int(msg[6]) << 7)
            guard off >= 0 && off * 2 + 1 < bytes.count else { return }
            bytes[off * 2] = msg[7]
            bytes[off * 2 + 1] = msg[8]
          }
          return bytes
        }
      }, validSizes: [1280, 265], includeFileDataCount: true, pack: { bodyData, param, value in
        Proteus.pack(&bodyData, parm: param.p!, value: value)
      }, unpack: { bodyData, param in
        Proteus.unpack(bodyData, parm: param.p!)
      })
    }
    
    static let bankTruss = createBankTruss(patchTruss, initFile: "proteus1-voice-bank-init")
    
    static func createBankTruss(_ patchTruss: SinglePatchTruss, initFile: String) -> SingleBankTruss {
      let patchCount = 64
      return SingleBankTruss(patchTruss: patchTruss, patchCount: patchCount, initFile: initFile, fileDataCount: patchCount * 265, createFileData: SingleBankTrussWerk.createFileDataWithLocationMap {
        sysexData($0, deviceId: 0, location: $1 + 64)
      }, parseBodyData: SingleBankTrussWerk.sortAndParseBodyDataWithLocationMap({
        0.set(bits: 0...6, value: $0[5]).set(bits: 7...13, value: $0[6]) % 64
      }, patchTruss: patchTruss, patchCount: patchCount)
      )
    }
    
    // high paramCoalesceCount bc patch push is just 128 param change messages anyway
    static func patchTransform(params: SynthPathParam) -> MidiTransform {
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
    
    
    static func sysexData(_ bytes: [UInt8], deviceId: Int, location: Int) -> [UInt8] {
      let byteSum = bytes.map{ Int($0) }.reduce(0, +)
      return Proteus.sysex(deviceId: UInt8(deviceId), [0x01, UInt8(location.bits(0...6)), UInt8(location.bits(7...13))] + bytes + [UInt8(byteSum % 128)])
    }
    
    // for temp data
    static func sysexData(_ bytes: [UInt8], deviceId: UInt8) -> [[UInt8]] {
      128.map {
        Proteus.paramSetData(deviceId: deviceId, parm: $0, byte0: bytes[$0 * 2], byte1: bytes[$0 * 2 + 1])
      }
    }
    
    static let namePackIso = NamePackIso(pack: { bytes, name in
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
  
    static let chorusMax = 1
    static let parms = createParms(instMap: instMap, chorusMax: chorusMax)
    
    static func createParms(instMap: [ProteusInstMapItem], chorusMax: Int) -> [Parm] {

      var reverseInstMap = [Int:[Int:Int]]()
      instMap.enumerated().forEach {
        let item = $0.element
        if reverseInstMap[item.set] == nil {
          reverseInstMap[item.set] = [:]
        }
        reverseInstMap[item.set]![item.inst] = $0.offset
      }
      
      var p: [Parm] = .prefix([.link], count: 3, bx: 0, px: 1, block: { _ in
        [.p([], p: 12)]
      })
      p += .prefix([.key, .lo], count: 4, bx: 0, px: 1, block: { _ in
        [.p([], p: 15, .iso(noteIso))]
      })
      p += .prefix([.key, .hi], count: 4, bx: 0, px: 1, block: { _ in
        [.p([], p: 19, .iso(noteIso))]
      })
      p += .prefix([], count: 2, bx: 0, px: 18, block: { i in [
        .p([.wave], p: 23, packIso: instPackIso(parm: 23 + i * 18, instMap: instMap, reverseInstMap: reverseInstMap), .opts(instMap.map { $0.name })),
        .p([.start], p: 24),
        .p([.coarse], p: 25, .rng(-36...36)),
        .p([.fine], p: 26, .rng(-64...64)),
        .p([.volume], p: 27),
        .p([.pan], p: 28, .rng(-7...7)),
        .p([.delay], p: 29),
        .p([.key, .lo], p: 30, .iso(noteIso)),
        .p([.key, .hi], p: 31, .iso(noteIso)),
        .p([.attack], p: 32, .rng(0...99)),
        .p([.hold], p: 33, .rng(0...99)),
        .p([.decay], p: 34, .rng(0...99)),
        .p([.sustain], p: 35, .rng(0...99)),
        .p([.release], p: 36, .rng(0...99)),
        .p([.env, .on], p: 37, .max(1)),
        .p([.solo], p: 38),
        .p([.chorus], p: 39, .max(chorusMax)),
        .p([.reverse], p: 40),
      ] })
      p += [
        .p([.cross, .mode], p: 59, .opts(["Off", "XFade", "XSwitch"])),
        .p([.cross, .direction], p: 60, .opts(["Pri>Sec", "Sec>Pri"])),
        .p([.cross, .balance], p: 61),
        .p([.cross, .amt], p: 62, .max(255)),
        .p([.cross, .pt], p: 63, .iso(noteIso)),
      ]
      p += .prefix([.lfo], count: 2, bx: 0, px: 5, block: { _ in [
        .p([.shape], p: 64, .opts(["Rand", "Tri", "Sine", "Saw", "Square"])),
        .p([.freq], p: 65),
        .p([.delay], p: 66),
        .p([.mod], p: 67),
        .p([.amt], p: 68, .rng(-128...127)),
      ] })
      p += [
        .p([.extra, .delay], p: 74, .max(127)),
        .p([.extra, .attack], p: 75, .max(99)),
        .p([.extra, .hold], p: 76, .max(99)),
        .p([.extra, .decay], p: 77, .max(99)),
        .p([.extra, .sustain], p: 78, .max(99)),
        .p([.extra, .release], p: 79, .max(99)),
        .p([.extra, .amt], p: 80, .rng(-128...127)),
      ]
      p += .prefix([.key, .velo], count: 6, bx: 0, px: 1, block: { _ in [
        .p([.src], p: 81, .opts(["Key", "Velo"])),
        .p([.dest], p: 87, .opts(["Off", "Pitch", "Pitch P", "Pitch S", "Volume", "Volume P", "Volume S", "Attack", "Attack P", "Attack S", "Decay", "Decay P", "Decay S", "Release", "Release P", "Release S", "XFade", "LFO 1 Amt", "LFO 1 Rate", "LFO 2 Amt", "LFO 2 Rate", "Aux Amt", "Aux Attack", "Aux Decay", "Aux Release", "Start", "Start P", "Start S", "Pan", "Pan P", "Pan S", "Tone", "Tone P", "Tone S"])),
        .p([.amt], p: 93, .rng(-128...127)),
      ] })
      p += .prefix([.mod], count: 8, bx: 0, px: 1, block: { _ in [
        .p([.src], p: 99, .opts(["Pitch Whl", "Ctrl A", "Ctrl B", "Ctrl C", "Ctrl D", "Mono Press", "Poly Press", "LFO 1", "LFO 2", "Aux"])),
        .p([.dest], p: 107, .opts(["Off", "Pitch", "Pitch P", "Pitch S", "Volume", "Volume P", "Volume S", "Attack", "Attack P", "Attack S", "Decay", "Decay P", "Decay S", "Release", "Release P", "Release S", "Crossfade", "LFO 1 Amount", "LFO 1 Rate", "LFO 2 Amount", "LFO 2 Rate", "Aux Amount", "Aux Attack", "Aux Decay", "Aux Release"])),
      ]})
      p += .prefix([.foot], count: 3, bx: 0, px: 1, block: { _ in [
        .p([.dest], p: 115, .opts(["Off", "Sustain", "Sustain P", "Sustain S", "Alt Env", "Alt Env P", "Alt Env S", "Alt Rel", "Alt Rel P", "Alt Rel S", "XSwitch"])),
      ]})
      p += .prefix([.ctrl], count: 4, bx: 0, px: 1, block: { _ in [
        .p([.amt], p: 118, .rng(-128...127)),
      ]})
      p += [
        .p([.pressure, .amt], p: 122, .rng(-128...127)),
        .p([.bend], p: 123, .opts(14.map { $0 > 12 ? "Global" : "+/-\($0)" })),
        .p([.velo, .curve], p: 124, .opts(6.map {
          $0 == 0 ? "Off" : $0 == 5 ? "Global" : "\($0)"
        })),
        .p([.key, .mid], p: 125, .iso(noteIso)),
        .p([.mix], p: 126, .opts(["Main", "Sub1", "Sub2"])),
        .p([.tune], p: 127, .opts(["Equal", "Just C", "Vallotti", "19-Tone", "Gamelan", "User"])),
      ]
      
      return p
    }
    
    static let noteIso = Miso.noteName(zeroNote: "C-2")
    
    static func instPackIso(parm: Int, instMap: [ProteusInstMapItem], reverseInstMap: [Int:[Int:Int]]) -> PackIso {
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
        
    static let instMap: [ProteusInstMapItem] = [
      (0, 0, "None"),
      (1, 0, "Piano"),
      (2, 0, "Piano Pad"),
      (3, 0, "Loose Piano"),
      (4, 0, "Tight Piano"),
      (5, 0, "Strings"),
      (6, 0, "Long Strings"),
      (7, 0, "Slow Strings"),
      (8, 0, "Dark Strings"),
      (9, 0, "Voices"),
      (10, 0, "Slow Voices"),
      (11, 0, "Dark Choir"),
      (12, 0, "Synth Flute"),
      (13, 0, "Soft Flute"),
      (14, 0, "Alto Sax"),
      (15, 0, "Tenor Sax"),
      (16, 0, "Baritone Sax "),
      (17, 0, "Dark Sax"),
      (18, 0, "Soft Trumpet "),
      (19, 0, "Dark Soft Trumpet"),
      (20, 0, "Hard Trumpet"),
      (21, 0, "Dark Hard Trumpet"),
      (22, 0, "Horn Falls"),
      (23, 0, "Trombone 1"),
      (24, 0, "Trombone 2"),
      (25, 0, "French Horn"),
      (26, 0, "Brass 1"),
      (27, 0, "Brass 2"),
      (28, 0, "Brass 3"),
      (29, 0, "Trombone/Sax"),
      (30, 0, "Guitar Mute"),
      (31, 0, "Electric Guitar"),
      (32, 0, "Acoustic Guitar"),
      (33, 0, "Rock Bass"),
      (34, 0, "Stone Bass"),
      (35, 0, "Flint Bass"),
      (36, 0, "Funk Slap"),
      (37, 0, "Funk Pop"),
      (38, 0, "Harmonics"),
      (39, 0, "Rock/Harmonics"),
      (40, 0, "Stone/Harmonics"),
      (41, 0, "Nose Bass"),
      (42, 0, "Bass Synth 1"),
      (43, 0, "Bass Synth 2"),
      (44, 0, "Synth Pad"),
      (45, 0, "Medium Envelope Pad "),
      (46, 0, "Long Envelope Pad"),
      (47, 0, "Dark Synth"),
      (48, 0, "Percussive Organ"),
      (49, 0, "Marimba"),
      (50, 0, "Vibraphone"),
      (51, 0, "All Percussion (balanced levels)"),
      (52, 0, "All Percussion (unbalanced levels)"),
      (53, 0, "Standard Percussion Setup 1"),
      (54, 0, "Standard Percussion Setup 2"),
      (55, 0, "Standard Percussion Setup 3"),
      (56, 0, "Kicks"),
      (57, 0, "Snares"),
      (58, 0, "Toms"),
      (59, 0, "Cymbals"),
      (60, 0, "Latin Drums"),
      (61, 0, "Latin Percussion"),
      (62, 0, "Agogo Bell"),
      (63, 0, "Woodblock"),
      (64, 0, "Conga"),
      (65, 0, "Timbale"),
      (66, 0, "Ride Cymbal"),
      (67, 0, "Percussion FX1"),
      (68, 0, "Percussion FX2"),
      (69, 0, "Metal"),
      (70, 0, "Oct 1 (Sine)"),
      (71, 0, "Oct 2 All"),
      (72, 0, "Oct 3 All"),
      (73, 0, "Oct 4 All"),
      (74, 0, "Oct 5 All"),
      (75, 0, "Oct 6 All"),
      (76, 0, "Oct 7 All"),
      (77, 0, "Oct 2 Odd"),
      (78, 0, "Oct 3 Odd"),
      (79, 0, "Oct 4 Odd"),
      (80, 0, "Oct 5 Odd"),
      (81, 0, "Oct 6 Odd"),
      (82, 0, "Oct 7 Odd"),
      (83, 0, "Oct 2 Even"),
      (84, 0, "Oct 3 Even"),
      (85, 0, "Oct 4 Even"),
      (86, 0, "Oct 5 Even"),
      (87, 0, "Oct 6 Even"),
      (88, 0, "Oct 7 Even"),
      (89, 0, "Low Odds"),
      (90, 0, "Low Evens"),
      (91, 0, "Four Octaves"),
      (92, 0, "Synth Cycle 1"),
      (93, 0, "Synth Cycle 2"),
      (94, 0, "Synth Cycle 3"),
      (95, 0, "Synth Cycle 4"),
      (96, 0, "Fundamental Gone 1"),
      (97, 0, "Fundamental Gone 2"),
      (98, 0, "Bite Cycle"),
      (99, 0, "Buzzy Cycle 1"),
      (100, 0, "Metalphone 1"),
      (101, 0, "Metalphone 2"),
      (102, 0, "Metalphone 3"),
      (103, 0, "Metalphone 4"),
      (104, 0, "Duck Cycle 1"),
      (105, 0, "Duck Cycle 2"),
      (106, 0, "Duck Cycle 3"),
      (107, 0, "Wind Cycle 1"),
      (108, 0, "Wind Cycle 2"),
      (109, 0, "Wind Cycle 3"),
      (110, 0, "Wind Cycle 4"),
      (111, 0, "Organ Cycle 1"),
      (112, 0, "Organ Cycle 2"),
      (113, 0, "Noise"),
      (114, 0, "Stray Voice 1"),
      (115, 0, "Stray Voice 2"),
      (116, 0, "Stray Voice 3"),
      (117, 0, "Stray Voice 4"),
      (118, 0, "Synth String 1"),
      (119, 0, "Synth String 2"),
      (120, 0, "Animals"),
      (121, 0, "Reed"),
      (122, 0, "Pluck 1"),
      (123, 0, "Pluck 2"),
      (124, 0, "Mallet 1"),
      (125, 0, "Mallet 2"),
    ]

  }

}

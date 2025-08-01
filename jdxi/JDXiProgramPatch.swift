
protocol JDXiPartPatchBuilder {
  static var bankOptions: [Int:String] { get }
  static var patchOptions: [String] { get }
}

extension JDXiPartPatchBuilder {
  
  static func createParams(isDrums: Bool = false) -> SynthPathParam {
    var p: [Parm] = [
      .p([.channel], 0x00, .max(15, dispOff: 1)),
      .p([.on], 0x0001, .max(1)),
      //    .p([.bank], 0x0006), // shouldn't ever be changed, AFAIK
      .p([.bank, .lo], 0x0007),
      .p([.pgm], 0x0008),
      .p([.level], 0x0009),
      .p([.pan], 0x000a, .rng(dispOff: -64)),
      .p([.coarse], 0x000b, .rng(16...112, dispOff: -64)),
      .p([.fine], 0x000c, .rng(14...114, dispOff: -64)),
      .p([.poly], 0x000d, .opts(["Mono", "Poly", "Tone"])),
      .p([.legato], 0x000e, .opts(["Off", "On", "Tone"])),
      .p([.bend], 0x000f, .opts(25.map { "\($0)" } + ["Tone"])),
      .p([.porta], 0x0010, .opts(["Off", "On", "Tone"])),
      .p([.porta, .time], 0x0011, packIso: Roland.msbMultiPackIso(2)(0x0011), .opts(128.map { "\($0)" } + ["Tone"])),
      .p([.cutoff], 0x0013, .rng(dispOff: -64)),
      .p([.reson], 0x0014, .rng(dispOff: -64)),
      .p([.attack], 0x0015, .rng(dispOff: -64)),
      .p([.decay], 0x0016, .rng(dispOff: -64)),
      .p([.release], 0x0017, .rng(dispOff: -64)),
      .p([.vib, .rate], 0x0018, .rng(dispOff: -64)),
      .p([.vib, .depth], 0x0019, .rng(dispOff: -64)),
      .p([.vib, .delay], 0x001a, .rng(dispOff: -64)),
      .p([.octave, .shift], 0x001b, .rng(61...67, dispOff: -64)),
      .p([.velo], 0x001c, .rng(1...127, dispOff: -64)),
      .p([.velo, .range, .lo], 0x0021, .rng(1...127)),
      .p([.velo, .range, .hi], 0x0022),
      .p([.velo, .fade, .lo], 0x0023),
      .p([.velo, .fade, .hi], 0x0024),
      .p([.mute], 0x0025, .max(1)),
      .p([.delay], 0x002b),
      .p([.reverb], 0x002c),
      .p([.out, .assign], 0x002d, .options(isDrums ? JDXi.Program.drumOutAssignOptions : JDXi.Program.outputAssignOptions)),
      .p([.scale, .type], 0x002f),
      .p([.scale, .key], 0x0030),
    ]
    
    p += .prefix([.scale, .tune], count: 12, bx: 1, block: { i, off in
      [.p([], 0x31, .rng(dispOff: -64))]
    })

    p += [
      .p([.rcv, .pgmChange], 0x003d, .max(1)),
      .p([.rcv, .bank, .select], 0x003e, .max(1)),
      .p([.rcv, .bend], 0x003f, .max(1)),
      .p([.rcv, .poly, .key, .pressure], 0x0040, .max(1)),
      .p([.rcv, .channel, .pressure], 0x0041, .max(1)),
      .p([.rcv, .modWheel], 0x0042, .max(1)),
      .p([.rcv, .volume], 0x0043, .max(1)),
      .p([.rcv, .pan], 0x0044, .max(1)),
      .p([.rcv, .expression], 0x0045, .max(1)),
      .p([.rcv, .hold], 0x0046, .max(1)),
    ]

    return p.params()
  }

}

extension JDXi {

  enum Program {
    // 3363: size calculated by fileDataCountBundle
    static let patchWerk: RolandMultiPatchTrussWerk = {
      let bundle = MultiPatchTruss.fileDataCountBundle(trusses: rolandMap.map { $0.werk.truss }, validSizes: [3123, 3138], includeFileDataCount: false)
      var t = multiPatchWerk("Program", rolandMap, start: 0x18000000, validBundle: bundle)
      return t
    }()
    
    //  // 1210: what it *should* be based on the size of the subpatches
    //  // 3123: what is *is* bc the JD-Xi sends extra sysex msg. undocumented
    
    static let rolandMap = {
      var map: [RolandMultiPatchTrussWerk.MapItem] = [
        ([.common], 0x0000, Common.patchWerk),
        ([.voice, .fx], 0x0100, VocalEffect.patchWerk),
        ([.fx, .i(0)], 0x0200, Effect1.patchWerk),
        ([.fx, .i(1)], 0x0400, Effect2.patchWerk),
        ([.delay], 0x0600, Delay.patchWerk),
        ([.reverb], 0x0800, Reverb.patchWerk),
        ([.ctrl], 0x4000, Ctrlr.patchWerk),
      ]
      map += [
        ([.digital, .i(0)], 0x2000, Digital1Part.patchWerk),
        ([.digital, .i(1)], 0x2100, Digital2Part.patchWerk),
        ([.analog], 0x2200, AnalogPart.patchWerk),
        ([.rhythm], 0x2300, DrumPart.patchWerk),
      ]
      map += partPaths.enumerated().map { (i, path) in
        let off: RolandAddress = 0x0100 * i
        return [
          ([.zone] + path, 0x3000 + off, Zone.patchWerk),
        ]
      }.reduce([], +)
      map += (4..<16).map {
        // other parts that aren't used for anything, but exist
        let off: RolandAddress = 0x0100 * $0
        return [
          ([.part, .i($0)], 0x2000 + off, ExtraPart.patchWerk),
          ([.zone, .i($0)], 0x3000 + off, Zone.patchWerk),
        ]
      }.reduce([], +)
      map += 16.map {
        // extra mystery subpatches
        ([.extra, .i(0), .i($0)], 0x1000 + 0x0100 * $0 , Extra1.patchWerk) // 15 bytes each
      }
      return map
    }()
    
    static let outputAssignOptions = OptionsParam.makeOptions(["EFX1","EFX2","Delay","Reverb","Direct"])
    
    static let drumOutAssignOptions: [Int:String] = outputAssignOptions <<< [5 : "Kit"]
    
    
    enum Bank {
      // 395983: automatically calculated size
      // 401664: different firmware(?) size
      // 399744: what is coming in actually
      static let bankWerk: RolandMultiBankTrussWerk = {
        let bundle = MultiBankTruss.Core.validBundle(counts: [399744, 401664])
        return multiBankWerk(patchWerk, startOffset: 0x30, initFile: "jdxi-program-bank-init", validBundle: bundle)
      }()
    }

    enum Full { 

      static let refTruss = RolandMultiSysexTrussWerk.createFullRefTruss(JDXi.sysexWerk, "Full Program", map, start: 0x18000000, isos: isos, refPath: refPath, initFile: "jdxi-full-program-init", sections: sections)

      static let refPath: SynthPath = [.perf]

      static let map: [RolandMultiSysexTrussWerk.MapItem] = [
        ([.perf], 0x00000000, Program.patchWerk),
        ([.digital, .i(0)], 0x01010000, Digital.patchWerk),
        ([.digital, .i(1)], 0x01210000, Digital.patchWerk),
        ([.analog], 0x01420000, Analog.patchWerk),
        ([.rhythm], 0x01700000, Drum.patchWerk),
      ]
            
      static let sections: [(String, [SynthPath])] = [
        ("Program", [refPath]),
        ("Digital", 2.map { [.digital, .i($0)] }),
        ("Analog", [[.analog]]),
        ("Drums", [[.rhythm]]),
      ]

//      static func isCompleteFetch(sysex: Data) -> Bool {
//        return [try! defaultFileDataCount(), 12166].contains(sysex.count)
//      }

      //  static func isValid(fileSize: Int) -> Bool {
    //    return [fileDataCount, 12166].contains(fileSize)
    //  }
            
      static let isos: FullRefTruss.Isos = partPaths.dict { partPath in
        [partPath : .basic(path: partPath + [.bank, .lo], location: partPath + [.pgm], pathMap: 128.map { bank in
          switch bank {
          case 0, 1, 2, 3:
            return [.bank, partPath.first!, .i(bank)]
          case 64, 65:
            return [.preset, partPath.first!, .i(bank - 64)]
          default:
            return [.pgm]
          }
        }, remap: { refMem, toMap in
          guard toMap.path == [.pgm] else { return toMap }

          // look at the mem loc of this Program, and pull the corresponding loc from the right bank
          let srcBankPath: SynthPath
          let srcSlot: Int

          switch partPath.first {
          case .digital:
            // bank is based on the location of this ref
            srcBankPath = [.bank, .digital, .i(refMem.path.endex * 2 + refMem.location / 64)]
            // slot is based on location of this ref, and whether it's digital 1 or 2!
            srcSlot = (refMem.location % 64) * 2 + partPath.endex
          default:
            srcBankPath = [.bank] + partPath + [.i(refMem.path.endex)]
            srcSlot = refMem.location
          }
          return MemSlot(srcBankPath, srcSlot)
        })]
      }
    }
        
    private static let partPaths: [SynthPath] = [[.digital, .i(0)], [.digital, .i(1)], [.analog], [.rhythm]]
          
    private static let usedPaths: [SynthPath] = {
      var paths: [SynthPath] = [
        [.common],
        [.voice, .fx],
        [.fx, .i(0)],
        [.fx, .i(1)],
        [.delay],
        [.reverb],
        [.ctrl],
      ]
      for pt in partPaths {
        paths.append(pt)
        paths.append([.zone] + pt)
      }
      return paths
    }()


    // optimization to skip over all the unused subpatches
  //  subscript(path: SynthPath) -> Int? {
  //    get {
  //      for subpatchPath in Self.usedPaths {
  //        guard path.starts(with: subpatchPath) else { continue }
  //        return subpatches[subpatchPath]?[path.subpath(from: subpatchPath.count)]
  //      }
  //      return nil
  //    }
  //    set {
  //      for subpatchPath in Self.usedPaths {
  //        guard path.starts(with: subpatchPath) else { continue }
  //        subpatches[subpatchPath]?[path.subpath(from: subpatchPath.count)] = newValue
  //      }
  //    }
  //  }

    struct Common {

      static let patchWerk = singlePatchWerk("Program Common", params, size: 0x24, start: 0x0000, name: .basic(0..<0x0c), sysexDataFn: sysexData)
      // size 0x1f // DOCS ARE WRONG!
      
      static let parms: [Parm] = [
        .p([.level], 0x0010),
        .p([.tempo], 0x0011, packIso: JDXi.multiPack(0x0011), .rng(500...30000)),
        .p([.voice, .fx], 0x0016, .opts(["Off","Vocoder","Auto-Pitch"])),
        .p([.voice, .fx, .number], 0x001c, .max(20, dispOff: 1)),
        .p([.voice, .fx, .part], 0x001d, .opts(["1","2"])),
        .p([.auto, .note, .on], 0x001e, .max(1)),
      ]
      
      static let params = parms.params()
      
      // add a param set for voice fx on the end because of a bug. without it, voc fx always on
      static func sysexData(_ bytes: [UInt8], deviceId: UInt8, address: RolandAddress) -> [[UInt8]] {
        [sysexWerk.sysexMsg(deviceId: deviceId, address: address, bytes: bytes)] +
        [sysexWerk.paramSetData(bytes, deviceId: deviceId, address: address, path: [.voice, .fx], params: params)]
      }

    }

    static func lrng(_ range: ClosedRange<Int> = 0...127) -> Parm.Span {
      .rng((range.lowerBound+32768)...(range.upperBound+32768), dispOff: -32768)
    }
    
    static func loptions(_ options: [String]) -> Parm.Span {
      var opts = [Int:String]()
      options.enumerated().forEach { opts[32768 + $0.offset] = $0.element }
      return .options(opts)
    }
    
    static func lopts(byte: Int = 0, _ opts: [String]) -> Parm.Span {
      let rr = 32768...(opts.count + 32768 - 1)
      return .isoS(Miso.options(opts, startIndex: 32768), range: rr)
    }

    static func liso(_ r: ClosedRange<Int> = 0...127, _ iso: Iso<Float, Float>) -> Parm.Span {
      let rr = (r.lowerBound + 32768)...(r.upperBound + 32768)
      return .isoF(Miso.a(-32768) >>> iso, range: rr)
    }

    static func liso(_ r: ClosedRange<Int> = 0...127, _ iso: Iso<Float, String>) -> Parm.Span {
      let rr = (r.lowerBound + 32768)...(r.upperBound + 32768)
      return .isoS(Miso.a(-32768) >>> iso, range: rr)
    }
    

    static let noteOptions: [String] = [
      "64th trp",
      "64th",
      "32nd trp",
      "32nd",
      "16th trp",
      "Dot 32nd",
      "16th",
      "8th trp",
      "Dot 16th",
      "8th",
      "1/4 trp",
      "Dot 8th",
      "1/4",
      "1/2 trp",
      "Dot 1/4",
      "1/2",
      "Whole trp",
      "Dot 1/2",
      "Whole",
      "Double trp",
      "Dot whole",
      "Double",
      ]
    
    static let syncRateIso = Miso.options(noteOptions)
    static let syncRateParam = liso(0...21, syncRateIso)


    struct VocalEffect {
      static let patchWerk = singlePatchWerk("Program Vocal", params, size: 0x18, start: 0x0100)
      
      static let params: SynthPathParam = {
        var p = SynthPathParam()

        p[[.level]] = RangeParam(byte: 0x00)
        p[[.pan]] = RangeParam(byte: 0x0001, displayOffset: -64)
        p[[.delay]] = RangeParam(byte: 0x0002)
        p[[.reverb]] = RangeParam(byte: 0x0003)
        p[[.out, .assign]] = OptionsParam(byte: 0x0004, options: Program.outputAssignOptions)
        p[[.auto, .pitch, .on]] = RangeParam(byte: 0x0005, maxVal: 1)
        p[[.auto, .pitch, .type]] = OptionsParam(byte: 0x0006, options: ["Soft", "Hard", "Elec 1", "Elec 2"])
        p[[.auto, .pitch, .scale]] = OptionsParam(byte: 0x0007, options: ["Chromatic","Maj(Min)"])
        p[[.auto, .pitch, .key]] = OptionsParam(byte: 0x0008, options: ["C", "Db", "D", "Eb", "E", "F", "F#", "G", "Ab", "A", "Bb", "B", "Cm", "C#m", "Dm", "D#m", "Em", "Fm", "F#m", "Gm", "G#m", "Am", "Bbm", "Bm"])
        p[[.auto, .pitch, .note]] = OptionsParam(byte: 0x0009, options: ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"])
        p[[.auto, .pitch, .gender]] = RangeParam(byte: 0x000a, maxVal: 20, displayOffset: -10)
        p[[.auto, .pitch, .octave]] = RangeParam(byte: 0x000b, maxVal: 2, displayOffset: -1)
        p[[.auto, .pitch, .balance]] = RangeParam(byte: 0x000c, maxVal: 100, displayOffset: -50)
        // "on" doesn't seem to do anything.
  //      p[[.vocoder, .on]] = RangeParam(byte: 0x000d, maxVal: 1)
        p[[.vocoder, .env]] = OptionsParam(byte: 0x000e, options: ["Sharp","Soft","Long"])
    //    p[[.???]] = RangeParam(byte: 0x000f) // printed in ref but unlabeled!
        p[[.vocoder, .mic, .sens]] = RangeParam(byte: 0x0010)
        p[[.vocoder, .synth, .level]] = RangeParam(byte: 0x0011)
        p[[.vocoder, .mic, .mix]] = RangeParam(byte: 0x0012)
        p[[.vocoder, .mic, .hi, .pass]] = OptionsParam(byte: 0x0013, options: ["Bypass", "1000", "1250", "1600", "2000", "2500", "3150", "4000", "5000", "6300", "8000", "10000", "12500", "16000"])
        
        return p
      }()
      
    }

    struct Effect1 {

      static let patchWerk = singlePatchWerk("Program Effect 1", params, size: 0x111, start: 0x0200)
      
      static let parms: [Parm] = [
        .p([.type], 0x00, .opts(["Thru", "Distortion", "Fuzz", "Compressor", "Bit Crusher"])),
        // not actually accessible from the panel, so don't use it. each fx has its own level param
        //      .p([.level], 0x0001),
        .p([.delay], 0x0002),
        .p([.reverb], 0x0003),
        .p([.out, .assign], 0x0004, .opts(["Direct","EFX2"])),
      ] + .prefix([.param], count: 32, bx: 4, block: { i, off in [
        .p([], 0x11, packIso: JDXi.multiPack(0x11 + off), lrng()),
      ] })
      
      static let params = parms.params()
      
      static let paramMap = [
        1 : distParams,
        2 : fuzzParams,
        3 : compParams,
        4 : crushParams
      ]

      static let distParams : [(String,Parm.Span)] = [
        ("Level", lrng()),
        ("Drive", lrng()),
        ("Type", lrng(0...5)),
        ("Presence", lrng())
      ]

      static let fuzzParams : [(String,Parm.Span)] = [
        ("Level", lrng()),
        ("Drive", lrng()),
        ("Type", lrng(0...5)),
        ("Presence", lrng())
      ]

      static let compParams : [(String,Parm.Span)] = [
        ("Threshold", lrng()),
        ("Ratio", liso(0...19, Miso.switcher([
          .range(0...18, Miso.options([1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100]) >>> Miso.unitFormat(":1")),
          .int(19, "inf:1"),
        ]))),
        ("Attack", liso(0...31, Miso.piecewise(breaks: [
          (0, 0.05),
          (5, 0.1),
          (14, 1),
          (23, 10),
          (31, 50),
        ]) >>> Miso.round(2) >>> Miso.unitFormat("ms"))),
        ("Release", liso(0...23, Miso.piecewise(breaks: [
          (0, 0.05),
          (1, 0.07),
          (2, 0.1),
          (3, 0.5),
          (4, 1),
          (5, 5),
          (6, 10),
          (7, 17),
          (8, 25),
          (11, 100),
          (20, 1000),
          (21, 1200),
          (22, 1500),
          (23, 2000),
        ]) >>> Miso.round(2) >>> Miso.unitFormat("ms"))),
        ("Level", lrng()),
        ("Side Sw", lopts(["Off", "On"])),
        ("Side Lvl", lrng()),
        ("Side Note", liso(0...127, Miso.noteName(zeroNote: "C-1"))),
        ("Side Time", lrng(60...1000)),
        ("Side Rel", lrng()),
        ("Side Sync", lopts(["Off", "On"])),
      ]

      static let crushParams : [(String,Parm.Span)] = [
        ("Level", lrng()),
        ("Rate", lrng()),
        ("Bit", lrng()),
        ("Filter", lrng())
      ]

    }

    enum Effect2 {
      static let patchWerk = singlePatchWerk("Program Effect 2", params, size: 0x111, start: 0x0400)
      
      static let parms: [Parm] = [
        .p([.type], 0x00, .options([
          0 : "Thru",
          5 : "Flanger",
          6 : "Phaser",
          7 : "Ring Mod",
          8 : "Slicer"])),
        // not actually accessible from the panel, so don't use it. each fx has its own level param
        //      .p([.level], 0x0001),
        .p([.delay], 0x0002),
        .p([.reverb], 0x0003),
      ] + .prefix([.param], count: 32, bx: 4, block: { i, off in [
        .p([], 0x11, packIso: JDXi.multiPack(0x11 + off), lrng()),
      ] })
      
      static let params = parms.params()
      
      static let paramMap = [
        5 : flangerParams,
        6 : phaserParams,
        7 : ringParams,
        8 : slicerParams
      ]
      
      static let flangerParams : [(String,Parm.Span)] = [
        ("Rate Sync", lrng(0...1)),
        ("Rate", lrng()),
        ("Rate", syncRateParam),
        ("Depth", lrng()),
        ("Feedback", lrng()),
        ("Manual", lrng()),
        ("Balance", lrng(0...100)),
        ("Level", lrng()),
      ]
      
      static let phaserParams : [(String,Parm.Span)] = [
        ("Rate Sync", lrng(0...1)),
        ("Rate", lrng()),
        ("Rate", syncRateParam),
        ("Depth", lrng()),
        ("Reson", lrng()),
        ("Manual", lrng()),
        ("Level", lrng()),
      ]
      
      static let ringParams : [(String,Parm.Span)] = [
        ("Frequency", lrng()),
        ("Sens", lrng()),
        ("Balance", lrng(0...100)),
        ("Level", lrng())
      ]
      
      static let slicerParams : [(String,Parm.Span)] = [
        ("Timing Ptrn", lrng(0...15)),
        ("Rate", syncRateParam),
        ("Attack", lrng()),
        ("Trig Lvl", lrng()),
        ("Level", lrng())
      ]
      
    }

    static let hfDampIso = Miso.switcher([
      .range(0...16, Miso.options([200, 250, 315, 400, 500, 630, 800, 1000, 1250, 1600, 2000, 2500, 3150, 4000, 5000, 6300, 8000]) >>> Miso.unitFormat("Hz")),
      .int(17, "Bypass"),
    ])
    
    enum Delay {

      static let patchWerk = singlePatchWerk("Program Delay", params, size: 0x64, start: 0x0600)
      
      static let parms: [Parm] = [
        .p([.on], 0x0000, .max(1)),
        //    .p([.level], 0x0001),
        .p([.reverb], 0x0003),
      ] + .prefix([.param], count: 24, bx: 4, block: { i, off in
        let span: Parm.Span
        switch i {
        case 0:
          span = loptions(["Single","Pan"])
        case 1:
          span = lopts(["Off","On"])
        case 2: // free delay time
          span = lrng(0...2600)
        case 3: // sync note
          span = liso(0...21, syncRateIso)
        case 4: // tap time
          span = liso(0...100, Miso.unitFormat("%"))
        case 5: // feedback
          span = liso(0...98, Miso.unitFormat("%"))
        case 6: // hf damp
          span = liso(0...17, hfDampIso)
        case 7: // ACTUAL level?
          span = lrng()
        default:
          span = lrng()
        }
        return [.p([], 0x4, packIso: JDXi.multiPack(0x4 + off), span)]
      })
      
      static let params = parms.params()
      
    }

    enum Reverb {

      static let patchWerk = singlePatchWerk("Program Reverb", params, size: 0x63, start: 0x0800)
      
      static let parms: [Parm] = [
        .p([.on], 0x0000, .max(1)),
        //    .p([.level], 0x0001),
      ] + .prefix([.param], count: 24, bx: 4, block: { i, off in
        let span: Parm.Span
        
        switch i {
        case 0:
          span = loptions(["Room 1", "Room 2", "Stage 1", "Stage 2", "Hall 1", "Hall 2"])
        case 1: // time
          span = lrng()
        case 2: // HF Damp
          span = liso(0...17, hfDampIso)
        case 3: // level
          span = lrng()
        default:
          span = lrng()
        }
        
        return [.p([], 0x3, packIso: JDXi.multiPack(0x3 + off), span)]
      })
      
      static let params = parms.params()
      
    }
    
    enum Digital1Part : JDXiPartPatchBuilder {
      
      static let patchWerk = singlePatchWerk("Program Digital 1", createParams(), size: 0x4c, start: 0x2000)
      
      static var bankOptions: [Int : String] = [
        0 : "User 1",
        1 : "User 2",
        2 : "User 3",
        3 : "User 4",
        64 : "Preset 1",
        65 : "Preset 2",
        127 : "Program"
      ]
      
      static var patchOptions = ["JP8 Strings1",  "Soft Pad 1",  "JP8 Strings2",  "JUNO Str 1",  "Oct Strings",  "Brite Str 1",  "Boreal Pad",  "JP8 Strings3",  "JP8 Strings4",  "Hollow Pad 1",  "LFO Pad 1",  "Hybrid Str",  "Awakening 1",  "Cincosoft 1",  "Bright Pad 1",  "Analog Str 1",  "Soft ResoPd1",  "HPF Poly 1",  "BPF Poly",  "Sweep Pad 1",  "Soft Pad 2",  "Sweep JD 1",  "FltSweep Pd1",  "HPF Pad",  "HPF SweepPd1",  "KOff Pad",  "Sweep Pad 2",  "TrnsSweepPad",  "Revalation 1",  "LFO CarvePd1",  "RETROX 139 1",  "LFO ResoPad1",  "PLS Pad 1",  "PLS Pad 2",  "Trip 2 Mars1",  "Reso S&H Pd1",  "SideChainPd1",  "PXZoon 1",  "Psychoscilo1",  "Fantasy 1",  "D-50 Stack 1",  "Organ Pad",  "Bell Pad",  "Dreaming 1",  "Syn Sniper 1",  "Strings 1",  "D-50 Pizz 1",  "Super Saw 1",  "S-SawStacLd1",  "Tekno Lead 1",  "Tekno Lead 2",  "Tekno Lead 3",  "OSC-SyncLd 1",  "WaveShapeLd1",  "JD RingMod 1",  "Buzz Lead 1",  "Buzz Lead 2",  "SawBuzz Ld 1",  "Sqr Buzz Ld1",  "Tekno Lead 4",  "Dist Flt TB1",  "Dist TB Sqr1",  "Glideator 1",  "Vintager 1",  "Hover Lead 1",  "Saw Lead 1",  "Saw+Tri Lead",  "PortaSaw Ld1",  "Reso Saw Ld",  "SawTrap Ld 1",  "Fat GR Lead",  "Pulstar Ld",  "Slow Lead",  "AnaVox Lead",  "Square Ld 1",  "Square Ld 2",  "Sqr Lead 1",  "Sqr Trap Ld1",  "Sine Lead 1",  "Tri Lead",  "Tri Stac Ld1",  "5th SawLead1",  "Sweet 5th 1",  "4th Syn Lead",  "Maj Stack Ld",  "MinStack Ld1",  "Chubby Lead1",  "CuttingLead1",  "Seq Bass 1",  "Reso Bass 1",  "TB Bass 1",  "106 Bass 1",  "FilterEnvBs1",  "JUNO Sqr Bs1",  "Reso Bass 2",  "JUNO Bass",  "MG Bass 1",  "106 Bass 3",  "Reso Bass 3",  "Detune Bs 1",  "MKS-50 Bass1",  "Sweep Bass",  "MG Bass 2",  "MG Bass 3",  "ResRubber Bs",  "R&B Bass 1",  "Reso Bass 4",  "Wide Bass 1",  "Chow Bass 1",  "Chow Bass 2",  "SqrFilterBs1",  "Reso Bass 5",  "Syn Bass 1",  "ResoSawSynBs",  "Filter Bass1",  "SeqFltEnvBs",  "DnB Bass 1",  "UnisonSynBs1",  "Modular Bs",  "Monster Bs 1",  "Monster Bs 2",  "Monster Bs 3",  "Monster Bs 4",  "Square Bs 1",  "106 Bass 2",  "5th Stac Bs1",  "SqrStacSynBs",  "MC-202 Bs"]
    }

    enum Digital2Part : JDXiPartPatchBuilder {
      
      static let patchWerk = singlePatchWerk("Program Digital 2", createParams(), size: 0x4c, start: 0x2000)

      static var bankOptions: [Int : String] = Digital1Part.bankOptions
      
      static var patchOptions = ["TB Bass 2", "Square Bs 2", "SH-101 Bs", "R&B Bass 2", "MG Bass 4", "Seq Bass 2", "Tri Bass 1", "BPF Syn Bs 2", "BPF Syn Bs 1", "Low Bass 1", "Low Bass 2", "Kick Bass 1", "SinDetuneBs1", "Organ Bass 1", "Growl Bass 1", "Talking Bs 1", "LFO Bass 1", "LFO Bass 2", "Crack Bass", "Wobble Bs 1", "Wobble Bs 2", "Wobble Bs 3", "Wobble Bs 4", "SideChainBs1", "SideChainBs2", "House Bass 1", "FM Bass", "4Op FM Bass1", "Ac. Bass", "Fingerd Bs 1", "Picked Bass", "Fretless Bs", "Slap Bass 1", "JD Piano 1", "E. Grand 1", "Trem EP 1", "FM E. Piano 1", "FM E. Piano 2", "Vib Wurly 1", "Pulse Clav", "Clav", "70’s E. Organ", "House Org 1", "House Org 2", "Bell 1", "Bell 2", "Organ Bell", "Vibraphone 1", "Steel Drum", "Harp 1", "Ac. Guitar", "Bright Strat", "Funk Guitar1", "Jazz Guitar", "Dist Guitar1", "D. Mute Gtr1", "E. Sitar", "Sitar Drone", "FX 1", "FX 2", "FX 3", "Tuned Winds1", "Bend Lead 1", "RiSER 1", "Rising SEQ 1", "Scream Saw", "Noise SEQ 1", "Syn Vox 1", "JD SoftVox", "Vox Pad", "VP-330 Chr", "Orch Hit", "Philly Hit", "House Hit", "O’Skool Hit1", "Punch Hit", "Tao Hit", "SEQ Saw 1", "SEQ Sqr", "SEQ Tri 1", "SEQ 1", "SEQ 2", "SEQ 3", "SEQ 4", "Sqr Reso Plk", "Pluck Synth1", "Paperclip 1", "Sonar Pluck1", "SqrTrapPlk 1", "TB Saw Seq 1", "TB Sqr Seq 1", "JUNO Key", "Analog Poly1", "Analog Poly2", "Analog Poly3", "Analog Poly4", "JUNO Octavr1", "EDM Synth 1", "Super Saw 2", "S-Saw Poly", "Trance Key 1", "S-Saw Pad 1", "7th Stac Syn", "S-SawStc Syn", "Trance Key 2", "Analog Brass", "Reso Brass", "Soft Brass 1", "FM Brass", "Syn Brass 1", "Syn Brass 2", "JP8 Brass", "Soft SynBrs1", "Soft SynBrs2", "EpicSlow Brs", "JUNO Brass", "Poly Brass", "Voc:Ensemble", "Voc:5thStack", "Voc:Robot", "Voc:Saw", "Voc:Sqr", "Voc:Rise Up", "Voc:Auto Vib", "Voc:PitchEnv", "Voc:VP-330", "Voc:Noise", "Init Tone"]
    }

    enum AnalogPart : JDXiPartPatchBuilder {
      
      static let patchWerk = singlePatchWerk("Program Analog", createParams(), size: 0x4c, start: 0x2000)
      
      static var bankOptions: [Int : String] = [
        0 : "User 1",
        1 : "User 2",
        64 : "Preset",
        127 : "Program"
      ]
      
      static var patchOptions = ["Toxic Bass 1", "Sub Bass 1", "Backwards 1", "Fat as That1", "Saw+Sub Bs 1", "Saw Bass 1", "Pulse Bass 1", "ResoSaw Bs 1", "ResoSaw Bs 2", "AcidSaw SEQ1", "Psy Bass 1", "Dist TB Bs 1", "Sqr Bass 1", "Tri Bass 1", "Snake Glide1", "Soft Bass 1", "Tear Drop 1", "Slo worn 1", "Dist LFO Bs1", "ResoPulseBs1", "Squelchy 1", "DnB Wobbler1", "OffBeat Wob1", "Chilled Wob", "Bouncy Bass1", "PulseOfLife1", "PWM Base 1", "Pumper Bass1", "ClickerBass1", "Psy Bass 2", "HooverSuprt1", "Celoclip 1", "Tri Fall Bs1", "808 Bass 1", "House Bass 1", "Psy Bass 3", "Reel 1", "PortaSaw Ld1", "Porta Lead 1", "Analog Tp 1", "Tri Lead 1", "Sine Lead 1", "Saw Buzz 1", "Buzz Saw Ld1", "Laser Lead 1", "Saw & Per 1", "Insect 1", "Sqr SEQ 1", "ZipPhase 1", "Stinger 1", "3 Oh 3", "Sus Zap 1", "Bowouch 1", "Resocut 1", "LFO FX", "Fall Synth 1", "Twister 1", "Analog Kick1", "Zippers 1", "Zippers 2", "Zippers 3", "Siren Hell 1", "SirenFX/Mod1", "Init Tone"]
    }
      
    enum DrumPart : JDXiPartPatchBuilder {
      static let patchWerk = singlePatchWerk("Program Drums", createParams(isDrums: true), size: 0x4c, start: 0x2000)
      
      static var bankOptions: [Int : String] = [
        0 : "User 1",
        1 : "User 2",
        64 : "Preset",
        127 : "Program"
      ]
      
      static var patchOptions = ["TR-909 Kit 1", "TR-808 Kit 1", "707&727 Kit1", "CR-78 Kit 1", "TR-606 Kit 1", "TR-626 Kit 1", "EDM Kit 1", "Drum&Bs Kit1", "Techno Kit 1", "House Kit 1", "Hiphop Kit 1", "R&B Kit 1", "TR-909 Kit 2", "TR-909 Kit 3", "TR-808 Kit 2", "TR-808 Kit 3", "TR-808 Kit 4", "808&909 Kit1", "808&909 Kit2", "707&727 Kit2", "909&7*7 Kit1", "808&7*7 Kit1", "EDM Kit 2", "Techno Kit 2", "Hiphop Kit 2", "80’s Kit 1", "90’s Kit 1", "Noise Kit 1", "Pop Kit 1", "Pop Kit 2", "Rock Kit", "Jazz Kit", "Latin Kit",]
    }
    
    enum ExtraPart : JDXiPartPatchBuilder {
      static let patchWerk = singlePatchWerk("Program Extra", createParams(), size: 0x4c, start: 0x2000)

      static var bankOptions: [Int : String] = [:]
      static var patchOptions: [String] = []
    }

      
    enum Zone {
      static let patchWerk = singlePatchWerk("Program Zone", params, size: 0x23, start: 0x3000)
            
      static let params: SynthPathParam = {
        var p = SynthPathParam()
        p[[.arp]] = RangeParam(byte: 0x0003, maxVal: 1)
        p[[.octave, .shift]] = RangeParam(byte: 0x0019, range: 61...67, displayOffset: -64)
        return p
      }()
      
    }

    /// Mystery extra subpatch!
    enum Extra1 {
      static let patchWerk = singlePatchWerk("Program Extra1", [:], size: 0x1, start: 0x1000)
    }

    enum Ctrlr {
      static let patchWerk = singlePatchWerk("Program Controller", params, size: 0x0c, start: 0x4000)
      
      static let params: SynthPathParam = {
        var p = SynthPathParam()
        
        p[[.resolution]] = OptionsParam(byte: 0x01, options: ["4", "8", "8L", "8H", "8t", "16", "16L", "16H", "16t"])
        p[[.length]] = OptionsParam(byte: 0x02, options: ["30", "40", "50", "60", "70", "80", "90", "100", "120", "Full"])
        p[[.on]] = RangeParam(byte: 0x03, maxVal: 1)
        p[[.style]] = OptionsParam(byte: 0x05, options: ["Basic 1 (a)", "Basic 2 (a)", "Basic 3 (a)", "Basic 4 (a)", "Basic 5 (a)", "Basic 6 (a)", "Seq Ptn 1 (2)", "Seq Ptn 2 (2)", "Seq Ptn 3 (2)", "Seq Ptn 4 (2)", "Seq Ptn 5 (2)", "Seq Ptn 6 (3)", "Seq Ptn 7 (3)", "Seq Ptn 8 (3)", "Seq Ptn 9 (3)", "Seq Ptn 10 (3)", "Seq Ptn 11 (3)", "Seq Ptn 12 (3)", "Seq Ptn 13 (3)", "Seq Ptn 14 (3)", "Seq Ptn 15 (3)", "Seq Ptn 16 (3)", "Seq Ptn 17 (3)", "Seq Ptn 18 (4)", "Seq Ptn 19 (4)", "Seq Ptn 20 (4)", "Seq Ptn 21 (4)", "Seq Ptn 22 (4)", "Seq Ptn 23 (4)", "Seq Ptn 24 (4)", "Seq Ptn 25 (4)", "Seq Ptn 26 (4)", "Seq Ptn 27 (4)", "Seq Ptn 28 (4)", "Seq Ptn 29 (4)", "Seq Ptn 30 (5)", "Seq Ptn 31 (5)", "Seq Ptn 32 (6)", "Seq Ptn 33 (p)", "Seq Ptn 34 (p)", "Seq Ptn 35 (p)", "Seq Ptn 36 (p)", "Seq Ptn 37 (p)", "Seq Ptn 38 (p)", "Seq Ptn 39 (p)", "Seq Ptn 40 (p)", "Seq Ptn 41 (p)", "Seq Ptn 42 (p)", "Seq Ptn 43 (p)", "Seq Ptn 44 (p)", "Seq Ptn 45 (p)", "Seq Ptn 46 (p)", "Seq Ptn 47 (p)", "Seq Ptn 48 (p)", "Seq Ptn 49 (p)", "Seq Ptn 50 (p)", "Seq Ptn 51 (p)", "Seq Ptn 52 (p)", "Seq Ptn 53 (p)", "Seq Ptn 54 (p)", "Seq Ptn 55 (p)", "Seq Ptn 56 (p)", "Seq Ptn 57 (p)", "Seq Ptn 58 (p)", "Seq Ptn 59 (p)", "Seq Ptn 60 (p)", "Bassline 1 (1)", "Bassline 2 (1)", "Bassline 3 (1)", "Bassline 4 (1)", "Bassline 5 (1)", "Bassline 6 (1)", "Bassline 7 (1)", "Bassline 8 (1)", "Bassline 9 (1)", "Bassline 10 (2)", "Bassline 11 (2)", "Bassline 12 (2)", "Bassline 13 (2)", "Bassline 14 (2)", "Bassline 15 (2)", "Bassline 16 (3)", "Bassline 17 (3)", "Bassline 18 (3)", "Bassline 19 (3)", "Bassline 20 (3)", "Bassline 21 (3)", "Bassline 22 (p)", "Bassline 23 (p)", "Bassline 24 (p)", "Bassline 25 (p)", "Bassline 26 (p)", "Bassline 27 (p)", "Bassline 28 (p)", "Bassline 29 (p)", "Bassline 30 (p)", "Bassline 31 (p)", "Bassline 32 (p)", "Bassline 33 (p)", "Bassline 34 (p)", "Bassline 35 (p)", "Bassline 36 (p)", "Bassline 37 (p)", "Bassline 38 (p)", "Bassline 39 (p)", "Bassline 40 (p)", "Bassline 41 (p)", "Sliced 1 (a)", "Sliced 2 (a)", "Sliced 3 (a)", "Sliced 4 (a)", "Sliced 5 (a)", "Sliced 6 (a)", "Sliced 7 (a)", "Sliced 8 (a)", "Sliced 9 (a)", "Sliced 10 (a)", "Gtr Arp 1 (4)", "Gtr Arp 2 (5)", "Gtr Arp 3 (6)", "Gtr Backing 1(a)", "Gtr Backing 2(a)", "Key Bckng1 (a)", "Key Bckng2 (a)", "Key Bckng3 (1-3)", "1/1 Note Trg (1)", "1/2 Note Trg (1)", "1/4 Note Trg (1)"])
        p[[.motif]] = OptionsParam(byte: 0x06, options: ["Up/L", "Up/H", "Up", "Down/L", "Down/H", "Down", "UpDown/L", "UpDown/H", "UpDown", "Random/L", "Random", "Phrase"])
        p[[.octave, .range]] = RangeParam(byte: 0x07, range: 61...67, displayOffset: -64)
        p[[.accent, .rate]] = RangeParam(byte: 0x09, maxVal: 100)
        p[[.velo]] = RangeParam(byte: 0x0a)
        
        return p
      }()
      
    }

    
  }

}


extension TX81Z {
  
  enum Perf {
    
    static let patchWerk = createPatchWerk(parms: parms, compactParms: compactParms)
    
    static func createPatchWerk(parms: [Parm], compactParms: [Parm]) -> Op4.PatchWerk {
      Op4.PatchWerk(synth, "perf", 110, namePack: .basic(100..<110), params: parms.params(), initFile: "tx81z-perf-init", cmdByte: 0x10, sysexData: {
        Yamaha.sysexData(channel: $1, cmdBytes: [0x7e, 0x00, 0x78], bodyBytes: "LM  8976PE".sysexBytes() + $0)
      }, parseOffset: 16, compact: (body: 76, namePack: .basic(66..<76), parms: compactParms))
    }
    
    static let patchTransform = patchChangeTransform(patchWerk: patchWerk)
    
    static func patchChangeTransform(patchWerk: Op4.PatchWerk) -> MidiTransform {
      return .single(throttle: 30, Op4.sysexChannel, .patch(param: { editorVal, bodyData, parm, value in
        if parm.path.last == .number {
          return [
            (patchWerk.paramSysex(editorVal, [UInt8(parm.b!) - 1, value.bit(7)]), 50),
            (patchWerk.paramSysex(editorVal, [UInt8(parm.b!), UInt8(value.bits(0...6))]), 0),
          ]
        }
        else {
          return [(patchWerk.paramSysex(editorVal, [UInt8(parm.b!), bodyData[parm.b!]]), 0)]
        }
      }, patch: patchWerk.patchTransform, name: patchWerk.nameTransform))
    }
    
    static let bankTruss = createBankTruss(patchCount: 24, patchWerk: patchWerk, initFile: "")
        
    static func createBankTruss(patchCount: Int, patchWerk: Op4.PatchWerk, initFile: String) -> SingleBankTruss {
      SingleBankTruss(patchTruss: patchWerk.truss, patchCount: patchCount, initFile: initFile, fileDataCount: 2450, createFileData: {
        bankSysexData(bodyData: $0, channel: 0, patchCount: patchCount, patchWerk: patchWerk)
      }, parseBodyData: {
        YamahaCompactTrussWerk.compactParseBodyData($0, parseOffset: 16, patchTruss: patchWerk.truss, compactPatchTruss: patchWerk.compactTruss!, patchCount: patchCount)
      })
    }
    
    static func bankSysexData(bodyData: SingleBankTruss.BodyData, channel: Int, patchCount: Int, patchWerk: Op4.PatchWerk) -> [UInt8] {
      Op4.bankSysexData(bodyData: bodyData, channel: channel, patchCount: patchCount, patchWerk: patchWerk, cmdBytes: [0x7e, 0x13, 0x0a], headerString: "LM  8976PM")
    }
    
    static func wholeBankTransform(patchCount: Int, patchWerk: Op4.PatchWerk) -> MidiTransform {
      .single(throttle: 30, Op4.sysexChannel, .wholeBank({ editorVal, bodyData in
        [(.sysex(bankSysexData(bodyData: bodyData, channel: editorVal, patchCount: patchCount, patchWerk: patchWerk)), 100)]
      }))
    }

    static let compactParms: [Parm] = .prefix([.part], count: 8, bx: 8, block: { i in [
      .p([.voice, .reserve], 0, bits: 0...3),
      .p([.voice, .number], 1, packIso: bankVoiceNumberPack(byte: i * 8 + 1)), // MSB in bit 4 of po + 0
      .p([.channel], 2, bits: 0...4),
      .p([.note, .lo], 3),
      .p([.note, .hi], 4),
      .p([.detune], 5, bits: 0...3),
      .p([.note, .shift], 6, bits: 0...5),
      .p([.volume], 7),
      .p([.out, .select], 0, bits: 5...6),
      .p([.lfo], 2, bits: 5...6),
      .p([.micro], 6, bit: 6),
    ] }) <<< [
      .p([.micro, .scale], 64, bits: 0...3),
      .p([.assign], 65, bit: 0),
      .p([.fx], 65, bits: 1...2),
      .p([.micro, .key], 65, bits: 3...6),
    ]
    
    
    static func voiceNumberPack(byte: Int) -> PackIso {
      PackIso.splitter([
        (byte, nil, 0...6),
        (byte - 1, nil, 7...7),
      ])
    }
    
    static let parms: [Parm] = .prefix([.part], count: 8, bx: 12) { i in [
      .p([.voice, .reserve], 0, .max(8)),
      .p([.voice, .number], 2, packIso: voiceNumberPack(byte: i * 12 + 2), .max(159)),
      .p([.channel], 3, .opts(16.map { "\($0 + 1)" } + ["Omni"])),
      .p([.note, .lo], 4, .iso(noteIso)),
      .p([.note, .hi], 5, .iso(noteIso)),
      .p([.detune], 6, .max(14, dispOff: -7)),
      .p([.note, .shift], 7, .max(48, dispOff: -24)),
      .p([.volume], 8, .max(99)),
      .p([.out, .select], 9, .opts(["Off", "I", "II", "I+II"])),
      .p([.lfo], 10, .opts(["Off", "Inst 1", "Inst 2", "Vib"])),
      .p([.micro], 11, .max(1)),
    ] } <<< [
      .p([.micro, .scale], 96, .opts(["Oct.", "Full", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11"])),
      .p([.assign], 97, .opts(["Norm", "Altr"])),
      .p([.fx], 98, .opts(["Off", "Delay", "Pan", "Chord"])),
      .p([.micro, .key], 99, .opts(["C", "Db", "D", "Eb", "E", "F", "Gb", "G", "Ab", "A", "Bb", "B"])),
    ]

    static let noteIso = Miso.noteName(zeroNote: "C-2")
    
    static func bankVoiceNumberPack(byte: Int) -> PackIso {
      PackIso.splitter([
        (byte, nil, 0...6),
        (byte - 1, 4...4, 7...7),
      ])
    }
    
    static let presetVoices = ["A1. GrandPiano", "A2. Uprt Piano", "A3. Deep Grd", "A4. HonkeyTonk", "A5. Elec Grand", "A6. Fuzz Piano", "A7. SkoolPiano", "A8. Thump Pno", "A9. LoTine81Z", "A10. HiTine81Z", "A11. ElectroPno", "A12. NewElectro", "A13. DynomiteEP", "A14. DynoWurlie", "A15. Wood Piano", "A16. Reed Piano", "A17. PercOrgan", "A18. 16 8 4 2 F", "A19. PumpOrgan", "A20. <6 Tease>", "A21. Farcheeza", "A22. Small Pipe", "A23. Big Church", "A24. AnalogOrgn", "A25. Thin Clav", "A26. EZ Clav", "A27. Fuzz Clavi", "A28. LiteHarpsi", "A29. RichHarpsi", "A30. Celeste", "A31. BriteCelst", "A32. Squeezebox", "B1. Trumpet81Z", "B2. Full Brass", "B3. FlugelHorn", "B4. ChorusBras", "B5. French Horn", "B6. AtackBrass", "B7. SpitBoneBC", "B8. Horns BC", "B9. MelloTenor", "B10. RaspAlto", "B11. Flute", "B12. Pan Floot", "B13. Basson", "B14. Oboe", "B15. Clarinet", "B16. Harmonica", "B17. DoubleBass", "B18. BowCello", "B19. BoxCello", "B20. SoloViolin", "B21. HiString 1", "B22. LowString", "B23. Pizzicato", "B24. Harp", "B25. ReverbStrg", "B26. SynString", "B27. Voices", "B28. HarmoPad", "B29. FanfarTpts", "B30. HiString 2", "B31. PercFlute", "B32. BreathOrgn", "C1. NylonGuit", "C2. Guitar #1", "C3. TwelveStrg", "C4. Funky Pick", "C5. AllThatJaz", "C6. HeavyMetal", "C7. Old Banjo", "C8. Zither", "C9. ElecBass 1", "C10. SqncrBass", "C11. SynFunkBas", "C12. ElecBass 2", "C13. AnalogBass", "C14. Jaco Bass", "C15. LatelyBass", "C16. MonophBass", "C17. StadiumSol", "C18. TrumptSolo", "C19. BCSexyPhon", "C20. Lyrisyn", "C21. WarmSquare", "C22. Sync Lead", "C23. MellowSqar", "C24. Jazz Flute", "C25. HeavyLead", "C26. Java Jive", "C27. Xylophone", "C28. GreatVibes", "C29. Sitar", "C30. Bell Pad", "C31. PlasticHit", "C32. DigiAnnie", "D1. BaadBreath", "D2. VocalNuts", "D3. KrstlChoir", "D4. Metalimba", "D5. WaterGlass", "D6. BowedBell", "D7. >>WOW<<", "D8. Fuzzy Koto", "D9. Spc Midiot", "D10. Gurgle", "D11. Hole in 1", "D12. Birds", "D13. MalibuNite", "D14. Helicopter", "D15. Flight Sim", "D16. BrthBells", "D17. Storm Wind", "D18. Alarm Call", "D19. Racing Car", "D20. Whistling", "D21. Space Talk", "D22. Space Vibe", "D23. Timpani", "D24. FM Hi-Hats", "D25. Bass Drum", "D26. Tube Bells", "D27. Noise Shot", "D28. Snare 1", "D29. Snare 2", "D30. Hand Drum", "D31. Synballs", "D32. Efem Toms"]
  }
}


extension JV80 {
  
  enum Perf {
    
    static let patchWerk = JV8X.Perf.patchWerk(part: Part.patchWerk)
    static let bankWerk = JV8X.Perf.bankWerk(patchWerk)
    
//      override class func startAddress(_ path: SynthPath?) -> RolandAddress {
//        return (path?.endex ?? 0) == 0 ? 0x01001000 : 0x02001000
//      }
//    static func location(forData data: Data) -> Int {
//      return Int(addressBytes(forSysex: data)[1])
//    }
    
    enum Common {
      
      static let patchWerk = try! JV8X.sysexWerk.singlePatchWerk("Perf Common", parms.params(), size: 0x1f, start: 0x0000, name: .basic(0..<0x0c))

      static let parms: [Parm] = [
        .p([.key, .mode], 0x0c),
        .p([.reverb, .type], 0x0d, .opts(JV80.Voice.Common.reverbTypeOptions)),
        .p([.reverb, .level], 0x0e),
        .p([.reverb, .time], 0x0f),
        .p([.reverb, .feedback], 0x10),
        .p([.chorus, .type], 0x11, .opts(JV80.Voice.Common.chorusTypeOptions)),
        .p([.chorus, .level], 0x12),
        .p([.chorus, .depth], 0x13),
        .p([.chorus, .rate], 0x14),
        .p([.chorus, .feedback], 0x15),
        .p([.chorus, .out, .assign], 0x16, .opts(JV80.Voice.Common.chorusOutOptions)),
      ] + .prefix([.part], count: 8, bx: 1, block: { index, offset in
        [.p([.voice, .reserve], 0x17, .max(28))]
      })
    }

    enum Part {
      
      static let patchWerk = try! JV8X.sysexWerk.singlePatchWerk("Perf Part", parms.params(), size: 0x22, start: 0x0800)
      
//      static func isValid(fileSize: Int) -> Bool {
//        return fileSize == fileDataCount || fileSize == fileDataCount + 1 // allow for JV-880 patches
//      }
      
      static let parms: [Parm] = [
        .p([.send, .on], 0x00, .max(1)),
        .p([.send, .channel], 0x01, .max(15, dispOff: 1)),
        .p([.send, .pgmChange], 0x02, packIso: JV8X.multiPack(0x02), .max(128)),
        .p([.send, .volume], 0x04, packIso: JV8X.multiPack(0x04), .max(128)),
        .p([.send, .pan], 0x06, packIso: JV8X.multiPack(0x06), .max(128)),
        .p([.send, .key, .range, .lo], 0x08),
        .p([.send, .key, .range, .hi], 0x09),
        .p([.send, .key, .transpose], 0x0a, .rng(28...100, dispOff: -64)),
        .p([.send, .velo, .sens], 0x0b, .rng(1...127)),
        .p([.send, .velo, .hi], 0x0c),
        .p([.send, .velo, .curve], 0x0d, .max(6, dispOff: 1)),

        .p([.int, .on], 0x0e, .max(1)),
        .p([.int, .key, .range, .lo], 0x0f),
        .p([.int, .key, .range, .hi], 0x10),
        .p([.int, .key, .transpose], 0x11, .rng(28...100, dispOff: -64)),
        .p([.int, .velo, .sens], 0x12, .rng(1...127)),
        .p([.int, .velo, .hi], 0x13),
        .p([.int, .velo, .curve], 0x14, .max(6, dispOff: 1)),

        .p([.on], 0x15, .max(1)),
        .p([.channel], 0x16, .max(15, dispOff: 1)),
        .p([.patch, .number], 0x17, packIso: JV8X.multiPack(0x17), .max(255)),
        .p([.level], 0x19),
        .p([.pan], 0x1a, .rng(dispOff: -64)),
        .p([.coarse], 0x1b, .rng(16...112, dispOff: -64)),
        .p([.fine], 0x1c, .rng(14...114, dispOff: -64)),
        .p([.reverb], 0x1d, .max(1)),
        .p([.chorus], 0x1e, .max(1)),
        .p([.rcv, .pgmChange], 0x1f, .max(1)),
        .p([.rcv, .volume], 0x20, .max(1)),
        .p([.rcv, .hold], 0x21, .max(1)),
      ]
      
      static let patchGroupOptions: [Int:String] = OptionsParam.makeOptions(["Internal", "Card", "Preset-A", "Preset-B"])
      
      static let blankPatchOptions = OptionsParam.makeOptions((1...64).map { "\($0)" })
      
      static let presetAOptions = OptionsParam.makeOptions(["1: A.Piano 1", "2: A.Piano 2", "3: Mellow Piano", "4: Pop Piano 1", "5: Pop Piano 2", "6: Pop Piano 3", "7: MIDled Grand", "8: Country Bar", "9: Glist EPiano", "10: MIDI EPiano", "11: SA Rhodes", "12: Dig Rhodes 1", "13: Dig Rhodes 2", "14: Stiky Rhodes", "15: Guitr Rhodes", "16: Nylon Rhodes", "17: Clav 1", "18: Clav 2", "19: Marimba", "20: Marimba SW", "21: Warm Vibe", "22: Vibe", "23: Wave Bells", "24: Vibrobell", "25: Pipe Organ 1", "26: Pipe Organ 2", "27: Pipe Organ 3", "28: E.Organ 1", "29: E.Organ 2", "30: Jazz Organ 1", "31: Jazz Organ 2", "32: Metal Organ", "33: Nylon Gtr 1", "34: Flanged Nyln", "35: Steel Guitar", "36: PickedGuitar", "37: 12 strings", "38: Velo Harmnix", "39: Nylon+Steel", "40: SwitchOnMute", "41: JC Strat", "42: Stratus", "43: Syn Strat", "44: Pop Strat", "45: Clean Strat", "46: Funk Gtr", "47: Syn Guitar", "48: Overdrive", "49: Fretless", "50: St Fretless", "51: Woody Bass 1", "52: Woody Bass 2", "53: Analog Bs 1", "54: House Bass", "55: Hip Bass", "56: RockOut Bass", "57: Slap Bass", "58: Thumpin Bass", "59: Pick Bass", "60: Wonder Bass", "61: Yowza Bass", "62: Rubber Bs 1", "63: Rubber Bs 2", "64: Stereoww Bs"])
      static let presetBOptions = OptionsParam.makeOptions(["1: Pizzicato", "2: Real Pizz", "3: Harp", "4: SoarinString", "5: Warm Strings", "6: Marcato", "7: St Strings", "8: Orch Strings", "9: Slow Strings", "10: Velo Strings", "11: BrightStrngs", "12: TremoloStrng", "13: Orch Stab 1", "14: Brite Stab", "15: JP-  8 Strings", "16: String Synth", "17: Wire Strings", "18: New Age Vox", "19: Arasian Morn", "20: Beauty Vox", "21: Vento Voxx", "22: Pvox Oooze", "23: GlassVoices", "24: Space Ahh", "25: Trumpet", "26: Trombone", "27: Harmon Mute1", "28: Harmon Mute2", "29: TeaJay Brass", "30: Brass Sect 1", "31: Brass Sect 2", "32: Brass Swell·", "33: Brass Combo", "34: Stab Brass", "35: Soft Brass", "36: Horn Brass", "37: French Horn", "38: AltoLead Sax", "39: Alto Sax", "40: Tenor Sax 1", "41: Tenor Sax 2", "42: Sax Section", "43: Sax Tp Tb", "44: FlutePiccolo", "45: Flute mod", "46: Ocarina", "47: OverblownPan", "48: Air Lead", "49: Steel Drum", "50: Log Drum", "51: Box Lead", "52: Soft Lead", "53: Whistle", "54: Square Lead", "55: Touch Lead", "56: NightShade", "57: Pizza Hutt", "58: EP+Exp Pad", "59: JP-8 Pad", "60: Puff", "61: SpaciosSweep", "62: Big n Beefy", "63: RevCymBend", "64: Analog Seq"])
      
    }

  }
  
}

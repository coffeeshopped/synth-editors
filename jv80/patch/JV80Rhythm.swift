
extension JV80 {
  
  enum Rhythm {

    static let patchWerk = JV8X.Rhythm.patchWerk(note: Note.patchWerk)
    static let bankWerk = JV8X.Rhythm.bankWerk(patchWerk)
      
//      override class func startAddress(_ path: SynthPath?) -> RolandAddress {
//        return (path?.endex ?? 0) == 0 ? 0x017f4000 : 0x027f4000
//      }
//    static func location(forData data: Data) -> Int {
//      return 0 // rhythm banks are just 1 patch
//    }

    enum Note {
      
      static let patchWerk = try! JV8X.sysexWerk.singlePatchWerk("Rhythm Note", parms.params(), size: 0x33, start: 0x0000)

//      static func isValid(fileSize: Int) -> Bool {
//        return fileSize == fileDataCount || fileSize == fileDataCount + 1 // allow for JV-880 patches
//      }

      static let parms: [Parm] = [
        .p([.wave, .group], 0x00, .opts(["Int","Exp","PCM"])),
        .p([.wave, .number], 0x01, packIso: JV8X.multiPack(0x01), .max(254)),
        .p([.on], 0x03, .max(1)),
        .p([.coarse], 0x04, .iso(Miso.noteName(zeroNote: "C-1"))),
        .p([.mute, .group], 0x5, .max(31)),
        .p([.env, .sustain], 0x6, .max(1)),
        .p([.fine], 0x07, .rng(14...114, dispOff: -64)),
        .p([.random, .pitch], 0x08, .options(randomPitchOptions)),
        .p([.bend, .range], 0x9, .max(12)),

        .p([.pitch, .env, .velo, .sens], 0x0a, .rng(1...127, dispOff: -64)),
        .p([.pitch, .env, .velo, .time], 0x0b, .options(veloTSensOptions)),
        .p([.pitch, .env, .depth], 0x0c, .rng(52...76, dispOff: -64)),
        .p([.pitch, .env, .time, .i(0)], 0x0d),
        .p([.pitch, .env, .level, .i(0)], 0x0e, .rng(1...127, dispOff: -64)),
        .p([.pitch, .env, .time, .i(1)], 0x0f),
        .p([.pitch, .env, .level, .i(1)], 0x10, .rng(1...127, dispOff: -64)),
        .p([.pitch, .env, .time, .i(2)], 0x11),
        .p([.pitch, .env, .level, .i(2)], 0x12, .rng(1...127, dispOff: -64)),
        .p([.pitch, .env, .time, .i(3)], 0x13),
        .p([.pitch, .env, .level, .i(3)], 0x14, .rng(1...127, dispOff: -64)),

        .p([.filter, .type], 0x15, .opts(["Off","LPF","HPF"])),
        .p([.cutoff], 0x16),
        .p([.reson], 0x17),
        .p([.reson, .mode], 0x18, .opts(["Soft", "Hard"])),
        .p([.filter, .env, .velo, .sens], 0x19, .rng(1...127, dispOff: -64)),
        .p([.filter, .env, .velo, .time], 0x1a, .options(veloTSensOptions)),
        .p([.filter, .env, .depth], 0x1b, .rng(1...127, dispOff: -64)),
        .p([.filter, .env, .time, .i(0)], 0x1c),
        .p([.filter, .env, .level, .i(0)], 0x1d),
        .p([.filter, .env, .time, .i(1)], 0x1e),
        .p([.filter, .env, .level, .i(1)], 0x1f),
        .p([.filter, .env, .time, .i(2)], 0x20),
        .p([.filter, .env, .level, .i(2)], 0x21),
        .p([.filter, .env, .time, .i(3)], 0x22),
        .p([.filter, .env, .level, .i(3)], 0x23),

        .p([.level], 0x24),
        .p([.pan], 0x25, packIso: JV8X.multiPack(0x25), .max(128, dispOff: -64)),
        .p([.amp, .env, .velo, .sens], 0x27, .rng(1...127, dispOff: -64)),
        .p([.amp, .env, .velo, .time], 0x28, .options(veloTSensOptions)),
        .p([.amp, .env, .time, .i(0)], 0x29),
        .p([.amp, .env, .level, .i(0)], 0x2a),
        .p([.amp, .env, .time, .i(1)], 0x2b),
        .p([.amp, .env, .level, .i(1)], 0x2c),
        .p([.amp, .env, .time, .i(2)], 0x2d),
        .p([.amp, .env, .level, .i(2)], 0x2e),
        .p([.amp, .env, .time, .i(3)], 0x2f),

        .p([.out, .level], 0x30),
        .p([.reverb], 0x31),
        .p([.chorus], 0x32),
      ]
            
      static let randomPitchOptions: [Int:String] = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "20", "30", "40", "50", "60", "70", "80", "90", "100", "200", "300", "400", "500", "600", "700", "800", "900", "1000", "1100", "1200"]
      
      static let veloTSensOptions: [Int:String] = ["-100", "-70", "-50", "-40", "-30", "-20", "-10", "0", "10", "20", "30", "40", "50", "70", "100"]
    }

  }
  
}


extension JDXi {

  enum Analog {
    
    static let patchWerk = multiPatchWerk("Analog", [
      ([.common], 0x0000, Common.patchWerk),
      ([.extra], 0x0200, Extra.patchWerk),
    ], start: 0x19420000)

    //  static func location(forData data: Data) -> Int {
  //    return Int(addressBytes(forSysex: data)[1])
  //  }
    

  //  static let fileDataCount = 513
    
    // 354: what it *should* be based on the size of the subpatches
    // 513: what is *is* bc the JD-Xi sends an extra sysex msg. undocumented
  //  static func isValid(fileSize: Int) -> Bool {
  //    return fileSize == fileDataCount || fileSize == 354
  //  }
    
    enum Bank {
      static let bankWerk = multiBankWerk(patchWerk, startOffset: 0x70, initFile: "jdxi-analog-bank-init")
    }
    
    enum Common {
      
      static let patchWerk = singlePatchWerk("Analog Common", params, size: 0x40, start: 0x0000, name: .basic(0..<0x0c))
      
      static let params: SynthPathParam = {
        var p = SynthPathParam()

        p[[.lfo, .shape]] = OptionsParam(byte: 0x000d, options: ["Tri", "Sin", "Saw", "Square", "S&H", "Random"])
        p[[.lfo, .rate]] = RangeParam(byte: 0x000e)
        p[[.lfo, .fade]] = RangeParam(byte: 0x000f)
        p[[.lfo, .tempo, .sync]] = RangeParam(byte: 0x0010, maxVal: 1)
        p[[.lfo, .sync, .note]] = OptionsParam(byte: 0x0011, options: ["16", "12", "8", "4", "2", "1", "3/4", "2/3", "1/2", "3/8", "1/3", "1/4", "3/16", "1/6", "1/8", "3/32", "1/12", "1/16", "1/24", "1/32"])
        p[[.lfo, .pitch, .depth]] = RangeParam(byte: 0x0012, range: 1...127, displayOffset: -64)
        p[[.lfo, .filter, .depth]] = RangeParam(byte: 0x0013, range: 1...127, displayOffset: -64)
        p[[.lfo, .amp, .depth]] = RangeParam(byte: 0x0014, range: 1...127, displayOffset: -64)
        p[[.lfo, .key, .sync]] = RangeParam(byte: 0x0015, maxVal: 1)
        p[[.osc, .wave]] = OptionsParam(byte: 0x0016, options: ["Saw", "Tri", "Square"])
        p[[.coarse]] = RangeParam(byte: 0x0017, range: 40...88, displayOffset: -64)
        p[[.fine]] = RangeParam(byte: 0x0018, range: 14...114, displayOffset: -64)
        p[[.pw]] = RangeParam(byte: 0x0019)
        p[[.pw, .mod, .depth]] = RangeParam(byte: 0x001a)
        p[[.pitch, .env, .velo]] = RangeParam(byte: 0x001b, range: 1...127, displayOffset: -64)
        p[[.pitch, .env, .attack]] = RangeParam(byte: 0x001c)
        p[[.pitch, .env, .decay]] = RangeParam(byte: 0x001d)
        p[[.pitch, .env, .depth]] = RangeParam(byte: 0x001e, range: 1...127, displayOffset: -64)
        p[[.sub, .osc, .type]] = OptionsParam(byte: 0x001f, options: ["Off", "Oct -1", "Oct -2"])
        p[[.filter, .on]] = RangeParam(byte: 0x0020, maxVal: 1)
        p[[.cutoff]] = RangeParam(byte: 0x0021)
        p[[.filter, .key, .trk]] = RangeParam(byte: 0x0022, range: 54...74, displayOffset: -64)
        p[[.reson]] = RangeParam(byte: 0x0023)
        p[[.filter, .env, .velo]] = RangeParam(byte: 0x0024, range: 1...127, displayOffset: -64)
        p[[.filter, .env, .attack]] = RangeParam(byte: 0x0025)
        p[[.filter, .env, .decay]] = RangeParam(byte: 0x0026)
        p[[.filter, .env, .sustain]] = RangeParam(byte: 0x0027)
        p[[.filter, .env, .release]] = RangeParam(byte: 0x0028)
        p[[.filter, .env, .depth]] = RangeParam(byte: 0x0029, range: 1...127, displayOffset: -64)
        p[[.amp, .level]] = RangeParam(byte: 0x002a)
        p[[.amp, .key, .trk]] = RangeParam(byte: 0x002b, range: 54...74, displayOffset: -64)
        p[[.amp, .velo]] = RangeParam(byte: 0x002c, range: 1...127, displayOffset: -64)
        p[[.amp, .env, .attack]] = RangeParam(byte: 0x002d)
        p[[.amp, .env, .decay]] = RangeParam(byte: 0x002e)
        p[[.amp, .env, .sustain]] = RangeParam(byte: 0x002f)
        p[[.amp, .env, .release]] = RangeParam(byte: 0x0030)
        p[[.porta]] = RangeParam(byte: 0x0031, maxVal: 1)
        p[[.porta, .time]] = RangeParam(byte: 0x0032)
        p[[.legato]] = RangeParam(byte: 0x0033, maxVal: 1)
        p[[.octave, .shift]] = RangeParam(byte: 0x0034, range: 61...67, displayOffset: -64)
        p[[.bend, .up]] = RangeParam(byte: 0x0035, maxVal: 24)
        p[[.bend, .down]] = RangeParam(byte: 0x0036, maxVal: 24)
        p[[.lfo, .pitch, .mod]] = RangeParam(byte: 0x0038, range: 1...127, displayOffset: -64)
        p[[.lfo, .filter, .mod]] = RangeParam(byte: 0x0039, range: 1...127, displayOffset: -64)
        p[[.lfo, .amp, .mod]] = RangeParam(byte: 0x003a, range: 1...127, displayOffset: -64)
        p[[.lfo, .rate, .mod]] = RangeParam(byte: 0x003b, range: 1...127, displayOffset: -64)

        return p
      }()
    }

    enum Extra {
      static let patchWerk = singlePatchWerk("Analog Extra", [:], size: 0x111, start: 0x0200)
    }

  }

}

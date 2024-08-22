
extension JV2080 {
  
  enum Voice {
    
    static let patchWerk = JVXP.Voice.patchWerk(common: Common.patchWerk, tone: JV1080.Voice.Tone.patchWerk, initFile: "jv2080-init")
    
    static let bankWerk = JVXP.Voice.bankWerk(patchWerk)
    
    enum Common {
      
      static let patchWerk = JVXP.Voice.Common.patchWerk(parms.params(), 0x4a)
            
      static let parms = JV1080.Voice.Common.parms + [
        .p([.clock, .src], 0x48, .opts(["Patch","System"])),
        .p([.category], 0x49, .options(categoryOptions)),
      ]

      static let categoryOptions = OptionsParam.makeOptions(["None", "Ac. Piano", "El. Piano", "Keyboards", "Bell", "Mallet", "Organ", "Accordion", "Harmonica", "Ac. Guitar", "El. Guitar", "Dist. Guitar", "Bass", "Synth Bass", "Strings", "Orchestra", "Hit & Stab", "Wind", "Flute", "Ac. Brass", "Synth Brass", "Sax", "Hard Lead", "Soft Lead", "Techno Synth", "Pulsating", "Synth FX", "Other Synth", "Bright Pad", "Soft Pad", "Vox", "Plucked", "Ethnic", "Fretted", "Percussion", "Sound FX", "Beat & Groove", "Drums", "Combination"])
    }

  }
}


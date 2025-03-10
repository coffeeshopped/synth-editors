
extension CZ101 {
  
  enum Global {
    
    static let patchTruss = JSONPatchTruss("cz101.global", parms: parms, initFile: "")
        
    static let parms: [Parm] = [
      .p([.channel], 0x00, .max(15, dispOff: 1)),
      .p([.tune], 0x01, p: 0x06, .max(127, dispOff: -63)),
      .p([.bend], 0x40, .max(12)),
      .p([.transpose], 0x41, .options([
        0x45 : "G",
        0x44 : "A♭",
        0x43 : "A",
        0x42 : "B♭",
        0x41 : "B",
        0x00 : "C",
        0x01 : "C#",
        0x02 : "D",
        0x03 : "E♭",
        0x04 : "E",
        0x05 : "F",
        0x06 : "F#"
        ])),
    ]
  }
  
}

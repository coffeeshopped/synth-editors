
extension D110 {
  
  enum System {
    
    static let patchWerk = try! DXX.sysexWerk.singlePatchWerk("System", [parms.first!].params(), size: 0x1, start: 0x100000)
    
    static let parms: [Parm] = [
      .p([.tune], 0x00, .iso(Miso.switcher([
        .range(0...7, Miso.lerp(in: 0...7, out: 427.4...428.8)),
        .range(8...34, Miso.lerp(in: 8...34, out: 429...434)),
        .range(35...127, Miso.lerp(in: 35...127, out: 434.2...452.6)),
      ]) >>> Miso.round(1))), //, .iso(Miso.lerp(in: 0...127, out: 427.4...452.6))),
      .p([.reverb, .type], 0x01, .opts(reverbTypeOptions)),
      .p([.reverb, .time], 0x02, .max(7, dispOff: 1)),
      .p([.reverb, .level], 0x03, .max(7)),
    ] + .prefix([.part], count: 8, bx: 1, block: { i, off in
      [
        .p([.reserve], 0x04, .max(32)),
        .p([.channel], 0x0d, .opts(channelOptions)),
      ]
    }) + [
      .p([.part, .rhythm, .reserve], 0x0c, .max(32)),
      .p([.part, .rhythm, .channel], 0x15, .opts(channelOptions)),
    ]
    
    static let reverbTypeOptions = ["Room 1", "Room 2", "Hall 1", "Hall 2", "Plate", "Tap Delay 1","Tap Delay 2", "Tap Delay 3"]
    
    static let channelOptions = 17.map { $0 == 16 ? "Off" : "\($0+1)" }
  }
  
}

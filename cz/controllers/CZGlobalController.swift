
extension CZ101.Global {
  
  enum Controller {
    
    static let ctrlr: PatchController = .patch(color: 1, [
      .grid([[
        .knob("MIDI Channel", [.channel]),
        .knob("Tune", [.tune]),
      ],[
        .knob("Bend", [.bend]),
        .select("Transpose", [.transpose]),
      ]])
    ], effects: [])
  }
}


extension VolcaFM2 {

  struct GlobalController {
    
    static let ctrlr: PatchController = .patch([
      .grid(color: 1, [[
        .knob("MIDI Ch", [.channel]),
        .checkbox("Patch Seq Sync", [.send, .patch]),
      ]])
    ])
  }

}


extension JDXi.Global {
  
  enum Controller {
    
    static var controller: PatchController {
      return .patch([
        .panel("main", color: 1, [[
          .knob("Tune", [.common, .tune]),
          .knob("Key Shift", [.common, .key, .shift]),
          .knob("Level", [.common, .level]),
          .knob("Pgm Chan", [.common, .pgmChange, .channel]),
          .checkbox("Rx Pgm Ch", [.common, .rcv, .pgmChange]),
          .checkbox("Rx Bank Sel", [.common, .rcv, .bank, .select]),
        ]])
      ], layout: [
        .simpleGrid([[("main", 1)]]),
      ])
    }

  }
  
}

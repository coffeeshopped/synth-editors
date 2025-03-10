
extension DXX {
  
  enum Controller {
    
    static func systemCtrlr(hiddenPanels: [String], layout: [PatchController.Constraint]) -> PatchController {
      
      let outEffects: [PatchController.Effect] = [
        .setup(hiddenPanels.map {
          .dimPanel(true, $0, dimAlpha: 0)
        })
      ]

      return .patch(color: 1, [
        .panel("tune", [[
          .knob("Tune", [.tune]),
        ]]),
        .panel("reverb", [[
          .select("Reverb", [.reverb, .type]),
          .knob("Time", [.reverb, .time]),
          .knob("Level", [.reverb, .level]),
          ]]),
        .panel("reserve", [9.map {
          let label = $0 == 0 ? "P Reserve" : $0 == 8 ? "R" : "\($0+1)"
          return .knob(label, [.part, $0 == 8 ? .rhythm : .i($0), .reserve])
        }]),
        .panel("channel", [9.map {
          let label = $0 == 0 ? "MIDI Ch" : $0 == 8 ? "R" : "\($0+1)"
          return .knob(label, [.part, $0 == 8 ? .rhythm : .i($0), .channel])
        }]),
        .panel("out", [9.map {
          let label = $0 == 0 ? "Out Level" : $0 == 8 ? "R" : "\($0+1)"
          return .knob(label, [.part, $0 == 8 ? .rhythm : .i($0), .level])
        }]),
        .panel("pan", [9.map {
          guard $0 < 8 else { return .spacer(2) }
          let label = $0 == 0 ? "Pan" : "\($0+1)"
          return .knob(label, [.part, .i($0), .pan])
        }]),
        .panel("space", [[]]),
      ], effects: outEffects, layout: layout)
    }
  }
  
}

extension D10 {
  
  enum Controller {
    
    static let systemCtrlr = DXX.Controller.systemCtrlr(hiddenPanels: ["channel"], layout: [
      .row([("tune",3),("reverb",6),("space",3)]),
      .row([("reserve",3)]),
      .row([("out",3)]),
      .row([("pan",3)]),
      .col([("tune",1),("reserve",1),("out",1),("pan",1)]),
    ])
  }
  
}

extension D5 {
  
  enum Controller {
    
    static let systemCtrlr = DXX.Controller.systemCtrlr(hiddenPanels: ["reverb"], layout: [
      .row([("tune",1),("space",4)]),
      .row([("channel",1)]),
      .row([("reserve",3)]),
      .row([("out",3)]),
      .row([("pan",3)]),
      .col([("tune",1),("channel",1), ("reserve",1),("out",1),("pan",1)]),
    ])
  }
  
}

extension D110 {
  
  enum Controller {
    
    static let systemCtrlr: PatchController = .patch(color: 1, [
      .grid([[
        .knob("Tune", [.tune]),
      ]])
    ])
  }
  
}


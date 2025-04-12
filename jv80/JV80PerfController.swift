
extension JV80.Perf {
  
  enum Controller {
    
    static func ctrlr() -> PatchController {
      return .paged([
        .switcher(["Common","Parts", "Transmit", "Internal"], color: 1),
        .panel("space", [[]]),
      ], effects: [
      ], layout: [
        .row([("switch",10), ("space", 10)]),
        .row([("page",1)]),
        .col([("switch",1), ("page",8)]),
      ], pages: .controllers([
        JV880.Perf.Controller.common(),
        JV880.Perf.Controller.parts(hideOut: true),
        .oneRow(8, child: transmit()),
        .oneRow(8, child: internl()),
      ]))
    }

    static func transmit() -> PatchController {
      .index([.part], label: [.on], { $0 == 7 ? "Rhythm" : "\($0 + 1)" }, color: 1, [
        .grid(prefix: [.send], [[
          .checkbox("On", [.on]),
          .knob("Channel", [.channel]),
        ], [
          .knob("Pgm Ch", [.pgmChange]),
          .knob("Volume", [.volume]),
        ], [
          .knob("Pan", [.pan]),
        ], [
          .knob("Key Lo", [.key, .range, .lo]),
          .knob("Key Hi", [.key, .range, .hi]),
        ], [
          .knob("Key Transpose", [.key, .transpose]),
        ], [
          .knob("Velo Sens", [.velo, .sens]),
          .knob("Velo Hi", [.velo, .hi]),
        ], [
          .knob("Velo Curve", [.velo, .curve]),
        ]])
      ])
    }

    static func internl() -> PatchController {
      .index([.part], label: [.on], { $0 == 7 ? "Rhythm" : "\($0 + 1)" }, color: 1, [
        .grid(prefix: [.int], [[
          .checkbox("On", [.on]),
          ], [
          .knob("Key Lo", [.key, .range, .lo]),
          .knob("Key Hi", [.key, .range, .hi]),
          ], [
          .knob("Key Transpose", [.key, .transpose]),
          ], [
          .knob("Velo Sens", [.velo, .sens]),
          .knob("Velo Hi", [.velo, .hi]),
          ], [
          .knob("Velo Curve", [.velo, .curve]),
          ]])
      ])
    }

  }
  
}

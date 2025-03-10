
extension Proteus1.Map {
  
  enum Controller {
    
    static func ctrlr() -> PatchController {
      return .patch(color: 1, 8.map { row in
        .panel("row\(row)", [
          16.map { .knob("\(row * 16 + $0)", [.i(row * 16 + $0)]) }
        ])
      }, effects: [], layout: [
        .simpleGrid(8.map { [("row\($0)", 1)] })
      ])
    }
  }
  
}

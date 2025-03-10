
public extension Op4 {
  
  static func opPath(_ index: Int) -> (SynthPath) -> SynthPath {
    {
      $0[0] == .extra ? [.extra, .op, .i(index)] + $0.subpath(from: 1) : [.voice, .op, .i(index)] + $0
    }
  }

  static func opPath(_ index: Int, _ path: SynthPath) -> SynthPath {
    opPath(index)(path)
  }

  static func opPaths(_ index: Int, _ paths: [SynthPath]) -> [SynthPath] {
    let p = opPath(index)
    return paths.map { p($0) }
  }

  static func opItems(_ index: Int, _ items: [[PatchController.PanelItem]]) -> [[PatchController.PanelItem]] {
    let p = opPath(index)
    return items.map { $0.map { $0.pathTransform(p) } }
  }
  
  static func envItem(index i: Int) -> PatchController.PanelItem {
    return .display(.env(envPathFn), "", [
      .src(opPath(i, [.attack]), dest: [.attack], { $0 / 31 }),
      .src(opPath(i, [.decay, .i(0)]), dest: [.decay, .i(0)], { $0 / 31 }),
      .src(opPath(i, [.decay, .i(1)]), dest: [.decay, .i(1)], { $0 / 31 }),
      .src(opPath(i, [.decay, .level]), dest: [.decay, .level], { $0 / 15 }),
      .src(opPath(i, [.release]), dest: [.release], { $0 / 15 }),
      .src(opPath(i, [.level]), dest: [.level], { $0 / 99 }),
      .src(opPath(i, [.extra, .shift]), dest: [.shift], { $0 / 4 }),
    ], id: [.env])
  }
  
  static let envPathFn: PatchController.DisplayPathFn = { values in
    var cmds = [PBBezier.PathCommand]()
    let shft = values[[.shift]] ?? 0
    let a = values[[.attack]] ?? 0
    let d1 = values[[.decay, .i(0)]] ?? 0
    let d2 = values[[.decay, .i(1)]] ?? 0
    let s = values[[.decay, .level]] ?? 0
    let r = values[[.release]] ?? 0
    let level = values[[.level]] ?? 0

    let segWidth: CGFloat = 1 / 5
    var x: CGFloat = 0
    let shftHeight = shft // TODO: make it log not lin
    
    // move to 0 , shftHeight
    cmds.append(.move(to: CGPoint(x: 0, y: 0)))
    cmds.append(.addLine(to: CGPoint(x: 0, y: shftHeight)))
    
    // ar
    x += a == 1 ? 0 : 1 / tan((0.25 + 0.25 * a) * .pi)
    cmds.append(.addLine(to: CGPoint(x: x, y: 1)))
    
    // d1r
    x += d1 == 1 ? 0 : 1 / tan((0.25 + 0.25 * d1) * .pi)
    cmds.append(.addLine(to: CGPoint(x: x, y: shftHeight + s)))
    
    // d2r
    x += (1 - d2) * segWidth
    let y = shftHeight + (d2 == 0 ? 1 : 0.5) * s
    cmds.append(.addLine(to: CGPoint(x: x, y: y)))
    
    // sustain
    x += (1 - r) * segWidth
    cmds.append(.addLine(to: CGPoint(x: x, y: shftHeight)))
    
    cmds.append(.addLine(to: CGPoint(x: 1, y: shftHeight)))
    cmds.append(.addLine(to: CGPoint(x: 1, y: 0)))
    
    cmds.append(.apply(.identity.scaledBy(x: 1, y: level)))
    
    return cmds
  }
  
  static func algoCtrlr(_ miniOp: @escaping (Int) -> PatchController) -> PatchController {
    .fm(algorithms, opCtrlr: miniOp, algoPath: [.voice, .algo])
  }
  
  enum MiniOp {
    
    static func controller(index: Int, ratioEffect: PatchController.Effect, opType: String, allPaths: [SynthPath]) -> PatchController {

      return .patch([
        .items(color: 2, [
          (envItem(index: index), "env"),
          (.label("?", align: .leading, size: 11, id: [.op]), "op"),
          (.label("x", align: .trailing, size: 11, bold: false, id: [.osc, .mode]), "freq"),
        ])
      ], effects: [
        ratioEffect,
        .dimsOn(opPath(index, [.on]), id: nil),
        .indexChange({ [.setCtrlLabel([.op], "\($0 + 1)")] }),
        .editMenu([.env], paths: opPaths(index, allPaths), type: opType, init: nil, rand: nil),
      ], layout: [
        .row([("op",1),("freq",4)]),
        .row([("env",1)]),
        .colFixed(["op", "env"], fixed: "op", height: 11, spacing: 2),
      ])
      
    }
    
  }

}

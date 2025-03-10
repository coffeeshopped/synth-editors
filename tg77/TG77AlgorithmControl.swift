
class TG77AlgorithmControl : FMAlgorithmControl {
  
  private var feedbackSources = [-1, -1, -1]
  private var inputs = [[0,0],
                        [0,0],
                        [0,0],
                        [0,0],
                        [0,0],
                        [0,0],
                        ]
  private var levels = [[0,0],
                [0,0],
                [0,0],
                [0,0],
                [0,0],
                [0,0],
                ]
  
  private let feedbackPaths: [[PBBezierPath]] = (0..<6).map { _ in
    return [PBBezierPath(), PBBezierPath()]
  }
  
  private let feedbackLayers: [[CAShapeLayer]] = (0..<6).map { _ in
    return [CAShapeLayer(), CAShapeLayer()]
  }
  
  override func initLayers() {
    super.initLayers()
    
    (0..<6).forEach { op in
      (0..<2).forEach { input in
        let l = feedbackLayers[op][input]
        l.fillColor = nil
        l.lineWidth = 2.0
        l.lineJoin = CAShapeLayerLineJoin.round
        layer.addSublayer(l)
      }
    }
  }
  
  override open var valueColor: PBColor! {
    didSet {
      (0..<6).forEach { op in
        (0..<2).forEach { input in
          feedbackLayers[op][input].strokeColor = valueColor.tinted(amount: 0.2).cgColor
        }
      }
    }
  }

  
  func set(feedbackSrc src: Int, op: Int) {
    feedbackSources[src] = op

    (0..<6).forEach { op in
      (0..<2).forEach { input in
        guard inputs[op][input] == src + 6 else { return }
        updateFeedbackPath(op: op, input: input)
      }
    }
  }
  
  func set(op: Int, input: Int, src: Int) {
    inputs[op][input] = src
    updateFeedbackPath(op: op, input: input)
  }

  func set(level: Int, forOp op: Int, input: Int) {
    levels[op][input] = level
    feedbackLayers[op][input].opacity = Float(level) / 7
  }
  
  func updateFeedbackPath(op: Int, input: Int) {
    guard let algorithm = algorithm else { return }
    let opSrcValue = inputs[op][input]
    // TODO: Handle noise and AWM inputs
    let l = feedbackLayers[op][input]
    let path = feedbackPaths[op][input]
    path.removeAllPoints()
    
    if [1,3,4,5,9].contains(opSrcValue) {
      // hard-coded from algo
      let dxop = algorithm.ops[op]
      if input == 0 {
        let inOp = dxop.input(input) ?? -1
        guard inOp >= 0 else { return }
        
        update(path: path, fromOp: inOp, toOp: op, input: input)
      }
      else {
        // there could be multiple inputs to deal with
        var nextInput = input
        while let inOp = dxop.input(nextInput) {
          update(path: path, fromOp: inOp, toOp: op, input: input)
          nextInput += 1
        }
      }
      
      let anim = CABasicAnimation(keyPath: "path")
      anim.fromValue = l.path
      anim.toValue   = path.cgPath
      l.add(anim, forKey: nil)
      l.path = path.cgPath

      l.isHidden = false
    }
    else if [6,7,8].contains(opSrcValue) {
      // see if fb op is hard-coded
      let srcOp = feedbackSources[opSrcValue - 6]
      guard srcOp >= 0 else { return }
      //let isHardCoded = algorithm?.feedbackSrcOps.contains(srcOp) ?? false

      update(path: path, fromOp: srcOp, toOp: op, input: input)

      let anim = CABasicAnimation(keyPath: "path")
      anim.fromValue = l.path
      anim.toValue   = path.cgPath
      l.add(anim, forKey: nil)
      l.path = path.cgPath

      l.isHidden = false
    }
    else if opSrcValue == 2 {
      // AWM
      l.isHidden = true
    }
    else if opSrcValue == 10 {
      // NOISE
      l.isHidden = true
    }
    else {
      // NONE
      l.isHidden = true
    }
  }
  
  public func update(path: PBBezierPath, fromOp: Int, toOp: Int, input: Int) {
    let startPt = outputPoint(forOp: fromOp)
    let endPt = inputPoint(forOp: toOp, input: input)
    
    path.move(to: startPt)
    path.addLine(to: CGPoint(x: startPt.x, y: startPt.y + 0.5 * opVMargin))
    // are we going up or down?
    if endPt.y > startPt.y {
      // down
      path.addLine(to: CGPoint(x: endPt.x, y: startPt.y + 0.5 * opVMargin))
    }
    else {
      // up
      let midX = startPt.x + 0.5 * (opWidth + opHMargin)
      path.addLine(to: CGPoint(x: midX, y: startPt.y + 0.5 * opVMargin))
      path.addLine(to: CGPoint(x: midX, y: endPt.y - 0.5 * opVMargin))
      path.addLine(to: CGPoint(x: endPt.x, y: endPt.y - 0.5 * opVMargin))
    }
    path.addLine(to: endPt)
  }
  
  public func inputPoint(forOp op: Int, input: Int) -> CGPoint {
    let opCtl = opContainers[op]
    let x = opCtl.center.x + (input == 0 ? -0.25 * opWidth : 0.25 * opWidth)
    return CGPoint(x: x, y: opCtl.center.y - 0.5 * opHeight)
  }

  override func layoutConnections() {
    guard let algo = algorithm else { return }
    connectionsLayer.frame = layer.bounds
    connectionsPath.removeAllPoints()

    (0..<opContainers.count).forEach { i in
      // draw outputs
      let op = algo.ops[i]

      guard op.outputs.count == 0 else { return }
      // output op
      let startPt = outputPoint(forOp: i)
      let endPt = CGPoint(x: frame.width * 0.5, y: frame.height)
      let midY = 0.5 * (startPt.y + endPt.y)
      connectionsPath.move(to: startPt)
      connectionsPath.addLine(to: CGPoint(x: startPt.x, y: midY))
      connectionsPath.addLine(to: CGPoint(x: endPt.x, y: midY))
      connectionsPath.addLine(to: endPt)
    }

    connectionsAnimation.fromValue = connectionsLayer.path
    connectionsAnimation.toValue   = connectionsPath.cgPath
    connectionsLayer.add(connectionsAnimation, forKey: nil)
    connectionsLayer.path = connectionsPath.cgPath
    
    (0..<6).forEach { op in
      (0..<2).forEach { input in
        updateFeedbackPath(op: op, input: input)
      }
    }
  }
  
}

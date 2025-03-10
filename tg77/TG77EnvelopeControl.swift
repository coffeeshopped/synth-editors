
class TG77EnvelopeControl : PBRateLevelEnvelopeControl {

  private let sustainLayer = CAShapeLayer()
  private let sustainPath = PBBezierPath()
  
  override func initLayers() {
    super.initLayers()
    sustainLayer.lineWidth = 3
    sustainLayer.fillColor = nil
    layer.addSublayer(sustainLayer)
  }
  
  public var holdTime: CGFloat = 0 {
    didSet { updateEnvelopePath() }
  }
  
  @IBInspectable public var releaseCount: Int = 2 {
    didSet {
      releaseRates = [CGFloat](repeating: 0, count: releaseCount)
      releaseLevels = [CGFloat](repeating: 0, count: releaseCount)
      updateEnvelopePath()
    }
  }
  
  private var releaseRates = [CGFloat](repeating: 0, count: 2)
  private var releaseLevels = [CGFloat](repeating: 0, count: 2)

  override func updateColors() {
    super.updateColors()
    sustainLayer.strokeColor = activeValueColor.cgColor
  }
  
  public func set(releaseRate: CGFloat, forIndex index: Int) {
    releaseRates[index] = releaseRate
    updateEnvelopePath()
  }
  
  public func set(releaseLevel: CGFloat, forIndex index: Int) {
    releaseLevels[index] = releaseLevel
    updateEnvelopePath()
  }

  public func releaseRate(_ index: Int) -> CGFloat {
    return releaseRates[index]
  }
  
  public func releaseLevel(_ index: Int) -> CGFloat {
    return releaseLevels[index]
  }


  override open func updateEnvelopePath() {
    
    let totalPoints = pointCount + releaseCount
    let segWidth = (sustainPoint >= totalPoints ? frame.width / CGFloat(totalPoints) : frame.width / CGFloat(totalPoints + 1) )
    let yScale = (bipolar ? 0.5 * frame.height : frame.height)
    var x: CGFloat
    var y: CGFloat
    
    envelopePath.removeAllPoints()
    sustainPath.removeAllPoints()
    
    envelopePath.move(to: CGPoint(x: -4, y: bipolar ? frame.height / 2 : frame.height + 4))
    
    var lastLevel: CGFloat = startLevel * gain
    x = 0
    y = (1 - lastLevel) * yScale
    envelopePath.addLine(to: CGPoint(x: x, y: y))

    x = holdTime * segWidth
    envelopePath.addLine(to: CGPoint(x: x, y: y))
    
    for index in 0..<pointCount {
      let nextLevel = level(index) * gain
      var r = rate(index)
      if r == 0 { r = 0.0001 }
      if r == 1 { r = 0.999 }
      let levelDiff = abs(nextLevel - lastLevel)
      x += segWidth * (levelDiff / tan(r * .pi * 0.5))
      lastLevel = nextLevel
      y = (1 - lastLevel) * yScale
      envelopePath.addLine(to: CGPoint(x: x, y: y))
      
      if sustainPoint == index {
        sustainPath.move(to: CGPoint(x: x, y: y))
      }
      else if sustainPoint < index {
        sustainPath.addLine(to: CGPoint(x: x, y: y))
      }
    }
    
    if sustainPoint == pointCount - 1 {
      x += segWidth
      envelopePath.addLine(to: CGPoint(x: x, y: y))
      sustainPath.addLine(to: CGPoint(x: x, y: y))
    }

    (0..<releaseCount).forEach { index in
      let nextLevel = releaseLevel(index) * gain
      var r = releaseRate(index)
      if r == 0 { r = 0.0001 }
      if r == 1 { r = 0.999 }
      let levelDiff = abs(nextLevel - lastLevel)
      x += segWidth * (levelDiff / tan(r * .pi * 0.5))
      lastLevel = nextLevel
      y = (1 - lastLevel) * yScale
      envelopePath.addLine(to: CGPoint(x: x, y: y))
      if sustainPoint == index {
        x += segWidth
        envelopePath.addLine(to: CGPoint(x: x, y: y))
      }
    }

    
    envelopePath.addLine(to: CGPoint(x: frame.width, y: y))
    envelopePath.addLine(to: CGPoint(x: frame.width + 4, y: bipolar ? frame.height/2 : frame.height + 4))
    
    animateEnvelopeChanges()
    animateSustainChanges()
  }
  
  private let animation = CABasicAnimation(keyPath: "path")
  private static let animationKey = "path"
  private func animateSustainChanges() {
    // remove old animation since this can get called many times rapidly
    sustainLayer.removeAnimation(forKey: Self.animationKey)

    animation.fromValue = sustainLayer.presentation()?.path
    animation.toValue = sustainPath.cgPath
    sustainLayer.path = sustainPath.cgPath
    sustainLayer.add(animation, forKey: Self.animationKey)
  }

}

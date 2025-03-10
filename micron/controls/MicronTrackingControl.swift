
class MicronTrackingControl : PBLabeledControl {

  private let xLayer = CAShapeLayer()
  private let yLayer = CAShapeLayer()
  private let graphLayer = CAShapeLayer()
  private let xPath = PBBezierPath()
  private let yPath = PBBezierPath()
  private let graphPath = PBBezierPath()
  
  var pointCount = 16 {
    didSet { updateGraphPath() }
  }
  
  var points = [CGFloat](repeating: 0, count: 33)
  
  func set(point: Int, level: CGFloat) {
    points[point + 16] = level
    updateGraphPath()
  }
  
  override public func initLayers() {
    super.initLayers()
    
    layer.cornerRadius = 2.0
    clipsToBounds = true
    
    xLayer.lineWidth = 1.0
    xLayer.fillColor = nil
    xLayer.lineDashPattern = [2,3]
    
    yLayer.lineWidth = 1.0
    yLayer.fillColor = nil
    yLayer.lineDashPattern = [2,3]

    graphLayer.lineWidth = 3.0
    graphLayer.fillColor = nil
    
    layer.addSublayer(xLayer)
    layer.addSublayer(yLayer)
    layer.addSublayer(graphLayer)
  }

  override public func updateColors() {
    super.updateColors()
    graphLayer.strokeColor = activeValueColor.cgColor
    backgroundColor = activeValueBackgroundColor
    xLayer.strokeColor = activeLabelColor.cgColor
    yLayer.strokeColor = activeLabelColor.cgColor
  }
  
  private func updateXPath() {
    // draw a horizontal line in the center
    xPath.removeAllPoints()
    xPath.move(to: CGPoint(x: 0, y: breakY))
    xPath.addLine(to: CGPoint(x: frame.width, y: breakY))
    
    let animation = CABasicAnimation(keyPath: "path")
    animation.fromValue = xLayer.path
    animation.toValue = xPath.cgPath
    xLayer.add(animation, forKey:"xpath")
    xLayer.path = xPath.cgPath
  }
  
  private func updateYPath() {
    // draw a vertical line at the breakpoint
    yPath.removeAllPoints()
    yPath.move(to: CGPoint(x: breakX,y: 0))
    yPath.addLine(to: CGPoint(x: breakX,y: frame.height))
    
    let animation = CABasicAnimation(keyPath: "path")
    animation.fromValue = yLayer.path
    animation.toValue = yPath.cgPath
    yLayer.add(animation, forKey:"ypath")
    yLayer.path = yPath.cgPath
  }
  
  private let graphAnimation = CABasicAnimation(keyPath: "path")
  func updateGraphPath() {
    graphPath.removeAllPoints()
    
    let startIndex = 16 - pointCount
    let segWidth = frame.width / CGFloat(pointCount * 2)
    
    var x: CGFloat = 0
    graphPath.move(to: CGPoint(x: x, y: frame.height - (points[startIndex] + 1) * 0.5 * frame.height))
    for i in ((startIndex + 1)..<(startIndex + pointCount * 2 + 1)) {
      x += segWidth
      let y = frame.height - (points[i] + 1) * 0.5 * frame.height
      graphPath.addLine(to: CGPoint(x: x, y: y))
    }

    let animationKey = "graphPath"
    graphLayer.removeAnimation(forKey: animationKey)
    graphAnimation.fromValue = graphLayer.presentation()?.path
    graphAnimation.toValue = graphPath.cgPath
    graphLayer.add(graphAnimation, forKey:animationKey)
    graphLayer.path = graphPath.cgPath
  }
  
  private var breakX = 0 as CGFloat
  private var breakY = 0 as CGFloat

  override public func layoutSubviews() {
    super.layoutSubviews()
  
    breakX = frame.width * 0.5
    breakY = frame.height * 0.5
  
    updateXPath()
    updateYPath()
    updateGraphPath()
  }
  
}

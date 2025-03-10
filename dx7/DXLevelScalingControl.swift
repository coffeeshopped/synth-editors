
//@IBDesignable
//public class DXLevelScalingControl : PBLabeledControl {
//
//  var xLayer = CAShapeLayer()
//  var yLayer = CAShapeLayer()
//  var graphLayer = CAShapeLayer()
//  var xPath = PBBezierPath()
//  var yPath = PBBezierPath()
//  var graphPath = PBBezierPath()
//  var breakX = 0 as CGFloat
//  var breakY = 0 as CGFloat
//  
//  override public func initLayers() {
//    super.initLayers()
//    
//    layer.cornerRadius = 2.0
//    clipsToBounds = true
//    
//    xLayer.lineWidth = 1.0
//    xLayer.fillColor = nil
//    xLayer.lineDashPattern = [2,3]
//    
//    yLayer.lineWidth = 1.0
//    yLayer.fillColor = nil
//    
//    graphLayer.lineWidth = 3.0
//    graphLayer.fillColor = nil
//    
//    layer.addSublayer(xLayer)
//    layer.addSublayer(yLayer)
//    layer.addSublayer(graphLayer)
//  }
//
//  override public func updateColors() {
//    super.updateColors()
//    graphLayer.strokeColor = activeValueColor.cgColor
//    backgroundColor = activeValueBackgroundColor
//    xLayer.strokeColor = activeLabelColor.cgColor
//    yLayer.strokeColor = activeLabelColor.cgColor
//  }
//  
//
//  public var breakpoint = 0 {
//    didSet {
//      breakX = frame.width * (CGFloat(breakpoint)/99.0);
//      updateYPath()
//      updateGraphPath()
//    }
//  }
//  
//  public var leftDepth = 0 {
//    didSet {
//      updateGraphPath()
//    }
//  }
//  
//  public var rightDepth = 0 {
//    didSet {
//      updateGraphPath()
//    }
//  }
//  
//  public var leftCurve = 0 {
//    didSet {
//      updateGraphPath()
//    }
//  }
//
//  public var rightCurve = 0 {
//    didSet {
//      updateGraphPath()
//    }
//  }
//  
//  func updateXPath() {
//    // draw a horizontal line in the center
//    xPath.removeAllPoints()
//    xPath.move(to: CGPoint(x: 0, y: breakY))
//    xPath.addLine(to: CGPoint(x: frame.width, y: breakY))
//    
//    let animation = CABasicAnimation(keyPath: "path")
//    animation.fromValue = xLayer.path
//    animation.toValue = xPath.cgPath
//    xLayer.add(animation, forKey:"xpath")
//    xLayer.path = xPath.cgPath
//  }
//  
//  func updateYPath() {
//    // draw a vertical line at the breakpoint
//    yPath.removeAllPoints()
//    yPath.move(to: CGPoint(x: breakX,y: 0))
//    yPath.addLine(to: CGPoint(x: breakX,y: frame.height))
//    
//    let animation = CABasicAnimation(keyPath: "path")
//    animation.fromValue = yLayer.path
//    animation.toValue = yPath.cgPath
//    yLayer.add(animation, forKey:"ypath")
//    yLayer.path = yPath.cgPath
//  }
//  
//  private let graphAnimation = CABasicAnimation(keyPath: "path")
//  func updateGraphPath() {
//    graphPath.removeAllPoints()
//    
//    // draw left curve
//    graphPath.move(to: CGPoint(x: breakX, y: breakY))
//    switch DXLevelScalingCurve(rawValue: leftCurve) {
//      case .negativeLinear?:
//        graphPath.addLine(to: CGPoint(x: 0, y: breakY*(1.0 + (CGFloat(leftDepth)/99.0))))
//      case .negativeExponential?:
//        graphPath.addCurve(to: CGPoint(x: 0, y: breakY*(1.0 + (CGFloat(leftDepth)/99.0))),
//                        controlPoint1: CGPoint(x: 0.25*breakX, y: breakY),
//                        controlPoint2: CGPoint(x: 0.25*breakX, y: breakY))
//      case .positiveExponential?:
//        graphPath.addCurve(to: CGPoint(x: 0, y: breakY*(1.0 - (CGFloat(leftDepth)/99.0))),
//                        controlPoint1: CGPoint(x: 0.25*breakX, y: breakY),
//                        controlPoint2: CGPoint(x: 0.25*breakX, y: breakY))
//      case .positiveLinear?:
//        graphPath.addLine(to: CGPoint(x: 0, y: breakY*(1.0 - (CGFloat(leftDepth)/99.0))))
//      default:
//        break
//    }
//  
//    // draw right curve
//    graphPath.move(to: CGPoint(x: breakX, y: breakY))
//    switch DXLevelScalingCurve(rawValue: rightCurve) {
//      case .negativeLinear?:
//        graphPath.addLine(to: CGPoint(x: frame.width, y: breakY*(1.0 + (CGFloat(rightDepth)/99.0))))
//      case .negativeExponential?:
//        graphPath.addCurve(to: CGPoint(x: frame.width, y: breakY*(1.0 + (CGFloat(rightDepth)/99.0))),
//                        controlPoint1: CGPoint(x: breakX + 0.75*(frame.width-breakX), y: breakY),
//                        controlPoint2: CGPoint(x: breakX + 0.75*(frame.width-breakX), y: breakY))
//      case .positiveExponential?:
//        graphPath.addCurve(to: CGPoint(x: frame.width, y: breakY*(1.0 - (CGFloat(rightDepth)/99.0))),
//                        controlPoint1: CGPoint(x: breakX + 0.75*(frame.width-breakX), y: breakY),
//                        controlPoint2: CGPoint(x: breakX + 0.75*(frame.width-breakX), y: breakY))
//      case .positiveLinear?:
//        graphPath.addLine(to: CGPoint(x: frame.width, y: breakY*(1.0 - (CGFloat(rightDepth)/99.0))))
//      default:
//        break
//    }
//    
//
//    let animationKey = "graphPath"
//    graphLayer.removeAnimation(forKey: animationKey)
//    graphAnimation.fromValue = graphLayer.presentation()?.path
//    graphAnimation.toValue = graphPath.cgPath
//    graphLayer.add(graphAnimation, forKey:animationKey)
//    graphLayer.path = graphPath.cgPath
//  }
//  
//  override public func layoutSubviews() {
//    super.layoutSubviews()
//  
//    breakX = frame.width * CGFloat(breakpoint)/99.0
//    breakY = frame.height * 0.5
//  
//    updateXPath()
//    updateYPath()
//    updateGraphPath()
//  }
//  
//}

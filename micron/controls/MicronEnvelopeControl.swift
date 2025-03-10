
class MicronEnvelopeControl : PBAdsrEnvelopeControl {
  
  enum Slope : Int {
    case linear, expPos, expNeg
  }

  var attackSlope: Slope = .linear {
    didSet { updateEnvelopePath() }
  }
  
  var decaySlope: Slope = .linear {
    didSet { updateEnvelopePath() }
  }
  
  var releaseSlope: Slope = .linear {
    didSet { updateEnvelopePath() }
  }
  
  var sustainTime: CGFloat = 0 {
    didSet { updateEnvelopePath() }
  }
  
  var freeRun: Bool = false {
    didSet { updateEnvelopePath() }
  }
  
  override func updateEnvelopePath() {
    
    let segWidth = frame.width * 0.25
    var x: CGFloat = 0
    
    envelopePath.removeAllPoints()
    
    let startPoint = CGPoint(x: 0, y: frame.height)
    envelopePath.move(to: startPoint)
    
    // attack
    x += attack*segWidth
    let aPoint = CGPoint(x: x, y: 0)
    switch attackSlope {
    case .linear:
      envelopePath.addLine(to: aPoint)
    case .expPos:
      envelopePath.addCurve(to: aPoint,
                            controlPoint1: CGPoint(x: startPoint.x, y: aPoint.y),
                            controlPoint2: aPoint)
    case .expNeg:
      envelopePath.addCurve(to: aPoint,
                            controlPoint1: startPoint,
                            controlPoint2: CGPoint(x: aPoint.x, y: startPoint.y))
    }
    
    // decay
    x += decay*segWidth
    let susHeight = sustain * frame.height
    let dPoint = CGPoint(x: x, y: frame.height - susHeight)
    switch decaySlope {
    case .linear:
      envelopePath.addLine(to: dPoint)
    case .expPos:
      envelopePath.addCurve(to: dPoint,
                            controlPoint1: CGPoint(x: aPoint.x, y: dPoint.y),
                            controlPoint2: dPoint)
    case .expNeg:
      envelopePath.addCurve(to: dPoint,
                            controlPoint1: aPoint,
                            controlPoint2: CGPoint(x: dPoint.x, y: aPoint.y))
    }

    // sustain
    if !freeRun {
      x += sustainTime * segWidth
    }
    let sPoint = CGPoint(x: x, y: frame.height - susHeight)
    envelopePath.addLine(to: sPoint)

    // release
    x += rrelease * segWidth
    let rPoint = CGPoint(x: x, y: frame.height)
    switch releaseSlope {
    case .linear:
      envelopePath.addLine(to: rPoint)
    case .expPos:
      envelopePath.addCurve(to: rPoint,
                            controlPoint1: CGPoint(x: sPoint.x, y: rPoint.y),
                            controlPoint2: rPoint)
    case .expNeg:
      envelopePath.addCurve(to: rPoint,
                            controlPoint1: sPoint,
                            controlPoint2: CGPoint(x: rPoint.x, y: sPoint.y))
    }
    animateEnvelopeChanges()
  }
}

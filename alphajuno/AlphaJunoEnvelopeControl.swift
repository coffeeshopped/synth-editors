
class AlphaJunoEnvelopeControl : PBRateLevelEnvelopeControl {

  override func updateEnvelopePath() {
    
    let segWidth = frame.width * 0.25
    var x: CGFloat = 0
    
    envelopePath.removeAllPoints()
    
    let startPoint = CGPoint(x: 0, y: frame.height)
    envelopePath.move(to: startPoint)
    
    // attack
    x += rate(0) * segWidth
    let aPoint = CGPoint(x: x, y: frame.height * (1 - level(0)))
    envelopePath.addLine(to: aPoint)

    // decay
    x += rate(1) * segWidth
    let preDPoint = CGPoint(x: x, y: frame.height * (1 - level(1)))
    envelopePath.addLine(to: preDPoint)
    
    x += rate(2) * segWidth
    let susHeight = level(2) * frame.height
    let dPoint = CGPoint(x: x, y: frame.height - susHeight)
    envelopePath.addCurve(to: dPoint,
                          controlPoint1: CGPoint(x: (preDPoint.x + dPoint.x) * 0.5, y: dPoint.y),
                          controlPoint2: dPoint)
//    envelopePath.addCurve(to: dPoint,
//                          controlPoint1: aPoint,
//                          controlPoint2: CGPoint(x: dPoint.x, y: aPoint.y))

    // sustain
    x += segWidth
    let sPoint = CGPoint(x: x, y: frame.height - susHeight)
    envelopePath.addLine(to: sPoint)

    // release
    x += rate(3) * segWidth
    let rPoint = CGPoint(x: x, y: frame.height)
    envelopePath.addCurve(to: rPoint,
                          controlPoint1: CGPoint(x: sPoint.x, y: rPoint.y),
                          controlPoint2: rPoint)
//    envelopePath.addCurve(to: rPoint,
//                          controlPoint1: sPoint,
//                          controlPoint2: CGPoint(x: rPoint.x, y: sPoint.y))

    animateEnvelopeChanges()
  }
}

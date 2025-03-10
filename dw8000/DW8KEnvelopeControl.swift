
class DW8KEnvelopeControl : PBRateLevelEnvelopeControl {

  required init(label l: String) {
    super.init(label: l)
    initStyles()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    initStyles()
  }
  
  private func initStyles() {
    set(level: 1, forIndex: 0)
    sustainPoint = 2
  }
  
  override func updateEnvelopePath() {

    let segWidth = frame.width * 0.2
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
    let dPoint = CGPoint(x: x, y: frame.height * (1 - level(1)))
    envelopePath.addCurve(to: dPoint,
                          controlPoint1: CGPoint(x: (aPoint.x + dPoint.x) * 0.5, y: dPoint.y),
                          controlPoint2: dPoint)

    x += rate(2) * segWidth
    let susHeight = level(2) * frame.height
    let bPoint = CGPoint(x: x, y: frame.height - susHeight)
    envelopePath.addLine(to: bPoint)

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

    animateEnvelopeChanges()
  }
}

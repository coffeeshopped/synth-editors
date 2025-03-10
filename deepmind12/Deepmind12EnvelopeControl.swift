
class Deepmind12EnvelopeControl : PBAdsrEnvelopeControl {

  var aCurve: CGFloat = 0 {
    didSet {
      updateEnvelopePath()
    }
  }
  var dCurve: CGFloat = 0 {
    didSet {
      updateEnvelopePath()
    }
  }
  var sCurve: CGFloat = 0 {
    didSet {
      updateEnvelopePath()
    }
  }
  var rCurve: CGFloat = 0 {
    didSet {
      updateEnvelopePath()
    }
  }
  
  override func updateEnvelopePath() {
    
    let segWidth: CGFloat = 0.25
    var x: CGFloat = 0
    var at = CGPoint(x: 0, y: 0)
    var dest = CGPoint(x: 0, y: 0)
    envelopePath.removeAllPoints()
    envelopePath.move(to: dest)
    
    // attack
    x += attack * segWidth
    at = dest
    dest = CGPoint(x: x, y: 1)
    envelopePath.addCurve(to: dest, controlPoint1: lerp(p1: at, p2: dest, weight: aCurve), controlPoint2: dest)
    
    // decay
    x += decay * segWidth
    at = dest
    dest = CGPoint(x: x, y: sustain)
    envelopePath.addCurve(to: dest, controlPoint1: lerp(p1: at, p2: dest, weight: dCurve), controlPoint2: dest)

    // sustain
    x += segWidth
    at = dest
    // 0: 45 degrees down
    // 1: 45 degrees up
    dest = CGPoint(x: x, y: sustain + tan((sCurve * 0.5 - 0.25) * .pi))
    envelopePath.addLine(to: dest)
    
    // release
    x += rrelease * segWidth
    at = dest
    dest = CGPoint(x: x, y: 0)
    envelopePath.addCurve(to: dest, controlPoint1: lerp(p1: at, p2: dest, weight: rCurve), controlPoint2: dest)

    let t = CGAffineTransform.identity
      .translatedBy(x: 0, y: bounds.height)
      .scaledBy(x: bounds.width, y: -bounds.height)
    envelopePath.apply(t)

    animateEnvelopeChanges()
  }
  
  private func lerp(p1: CGPoint, p2: CGPoint, weight: CGFloat) -> CGPoint {
    let d1 = CGPoint(x: p1.x, y: p2.y)
    let d2 = CGPoint(x: p2.x, y: p1.y)
    return CGPoint(x: d1.x + (d2.x - d1.x) * weight, y: d1.y + (d2.y - d1.y) * weight)
  }
  
}


extension Blofeld {

  // TODO: still in use by Micro Q!
  class EnvelopeControl : PBAdsrEnvelopeControl {
    
    var attackLevel : CGFloat = 0 {
      didSet {
        updateEnvelopePath()
      }
    }
    var decay2 : CGFloat = 0 {
      didSet {
        updateEnvelopePath()
      }
    }

    var sustain2 : CGFloat = 0 {
      didSet {
        updateEnvelopePath()
      }
    }
    
    var cgMode: CGFloat {
      get { CGFloat(mode.rawValue) }
      set { mode = .init(rawValue: Int(newValue)) ?? .ADS1DS2R }
    }
    
    var mode : Voice.EnvelopeMode = .ADSR {
      didSet {
        updateEnvelopePath()
      }
    }
    
    override func updateEnvelopePath() {
      
      let adsrStyle = mode == .ADSR || mode == .OneShot
      let segCount: CGFloat = {
        switch mode {
        case .ADSR, .LoopAll, .LoopS1S2: return 4
        case .ADS1DS2R: return 5
        case .OneShot: return 3
        }
      }()
      let segWidth = 1 / segCount
      var x: CGFloat = 0
      
      envelopePath.removeAllPoints()
      envelopePath.move(to: CGPoint(x: 0, y: 0))
      
      // attack
      x += attack * segWidth
      envelopePath.addLine(to: CGPoint(x: x, y: adsrStyle ? 1 : attackLevel))
      
      // decay
      x += decay * segWidth
      envelopePath.addCurve(to: CGPoint(x: x, y: sustain))

      if mode == .ADSR {
        // sustain1
        x += segWidth
        envelopePath.addLine(to: CGPoint(x: x, y: sustain))
      }
      
      if !adsrStyle {
        // s1 to s2
        x += decay2 * segWidth
        envelopePath.addLine(to: CGPoint(x: x, y: sustain2))
      }
      
      if mode == .ADS1DS2R {
        // sustain2
        x += segWidth
        envelopePath.addLine(to: CGPoint(x: x, y: sustain2))
      }
      
      // release
      x += rrelease * segWidth
      let rWeight = mode == .OneShot ? 0.5 : 0
      envelopePath.addCurve(to: CGPoint(x: x, y: 0), weight: rWeight)
      
      let t = CGAffineTransform.identity
        .translatedBy(x: 0, y: bounds.height)
        .scaledBy(x: bounds.width, y: -bounds.height)
      envelopePath.apply(t)

      animateEnvelopeChanges()
    }
    
  }

}


class NordSensKnob : PBKnob {
  
  var sensStrokeWidth: CGFloat = 2
  var sensValueLayer = CAShapeLayer()
  var sensPath = PBBezierPath()

  override func initLayers() {
    super.initLayers()

    sensValueLayer.lineWidth = sensStrokeWidth
    sensValueLayer.fillColor = nil
    
    layer.addSublayer(sensValueLayer)
    
    sensValueLayer.actions = ["hidden" : NSNull()]
  }
  
  override func updateValuePath() {
    super.updateValuePath()

    let endPct = CGFloat(value - minimumValue) / CGFloat(maximumValue - minimumValue)
    var startPct = endPct + CGFloat(sensValue)/127
    startPct = min(1, max(0, startPct))
    if startPct < endPct {
      sensValueLayer.strokeStart = startPct
      sensValueLayer.strokeEnd = endPct
    }
    else {
      sensValueLayer.strokeStart = endPct
      sensValueLayer.strokeEnd = startPct
    }
  }
  
  override func updateValueLabel() {
    guard sensMode else { return super.updateValueLabel() }
    valueLabel.text = "\(sensValue)"
  }

  
  override func updateColors() {
    super.updateColors()
    sensValueLayer.strokeColor = activeSensColor.cgColor
  }
  
  @IBInspectable var sensColor: PBColor! = PBColor.blue {
    didSet {
      disabledSensColor = disabledColor(sensColor)
      updateColors()
    }
  }

  var disabledSensColor: PBColor! = PBColor.black
  
  var activeSensColor: PBColor {
    return (isEnabled ? sensColor : disabledSensColor)
  }
  

  var sensMode = false {
    didSet {
      valueLabel.textColor = (sensMode ? activeSensColor : activeLabelColor)
      labelView.textColor = (sensMode ? activeSensColor : activeLabelColor)
      updateValueLabel()
    }
  }

  fileprivate var sensAnim = CABasicAnimation(keyPath:"path")

  override func layoutSubviews() {
    super.layoutSubviews()

    let sensRadius = knobRadius-(knobStrokeWidth+1)
    var t = CGAffineTransform(translationX: knobCenter.x, y: knobCenter.y).scaledBy(x: sensRadius, y: sensRadius)
    let newSensPath = knobPath.cgPath.copy(using: &t)

    let hideKnobLayers = knobRadius < 10
    
    CATransaction.begin()

    sensValueLayer.isHidden = hideKnobLayers

    sensAnim.fromValue = sensValueLayer.path
    sensAnim.toValue = newSensPath
    sensValueLayer.add(sensAnim, forKey:"path")
    sensValueLayer.path = newSensPath

    updateValuePath()

    CATransaction.commit()
  }
  
  var sensValue = 0 {
    didSet {
      updateValueLabel()
      updateValuePath()
    }
  }


  override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
    guard sensMode else { return super.beginTracking(touch, with: event) }
    
    startValue = sensValue
    hoverValueLayer(touch)
    return true
  }

  override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
    guard sensMode else { return super.continueTracking(touch, with: event) }
    
    trackValueLayer(touch)
    
    let touchPoint = touch.location(in: self)
    let delta = touchPoint.y - self.startTouchPoint.y
    var newValue = startValue - Int(round(delta/pixelsPerUnit))
    
    // constrain to min/max
    newValue = min(newValue, 127)
    newValue = max(newValue, -127)
    
    // only assign/notify if value actually changed
    if newValue != sensValue {
      sensValue = newValue
      // alternate action trigger!
      sendActions(for: .value2Changed)
    }
    
    return true
  }
  
}


class NordSensKnob : PBKnob {
  
  var sensStrokeWidth: CGFloat = 2
  var sensValueLayer = CAShapeLayer()
  var sensPath = PBBezierPath()
  
  override func initLayers() {
    super.initLayers()
    
    sensValueLayer.lineWidth = sensStrokeWidth
    sensValueLayer.fillColor = nil
    sensValueLayer.actions = ["hidden" : NSNull()]
    layer.addSublayer(sensValueLayer)
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
    textField.stringValue = "\(sensValue)"
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
      textField.textColor = (sensMode ? activeSensColor : activeLabelColor)
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
      guard -127...127 ~= sensValue else { return sensValue = oldValue }
      updateValueDisplay()
    }
  }
  
  override open func controlTextDidEndEditing(_ obj: Notification) {
    guard sensMode else { return super.controlTextDidEndEditing(obj) }
    sensValueChange(textField.integerValue)
    textField.isEditable = false
  }
  
  override open func control(_ control: NSControl, textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
    guard sensMode else { return super.control(control, textView: textView, doCommandBy: commandSelector) }
    switch commandSelector {
    case #selector(moveUp(_:)):
      sensValue += 1
    case #selector(moveUpAndModifySelection(_:)):
      sensValue += 10
    case #selector(moveDown(_:)):
      sensValue -= 1
    case #selector(moveDownAndModifySelection(_:)):
      sensValue -= 10
    case #selector(insertNewline(_:)):
      window?.makeFirstResponder(window?.initialFirstResponder)
    default:
      return false
    }
    return true
  }
  
  // MARK: Mouse Events
  
  override open func mouseDragged(with event: NSEvent) {
    guard sensMode else { return super.mouseDragged(with: event) }
    guard isEnabled else { return }
    
    let delta = Int((Double(event.deltaY) * responsiveness).rounded())
    guard delta != 0 else { return }
    sensValueChange(sensValue - delta)
    mouseMoved = true
  }
  
  open override func scrollWheel(with event: NSEvent) {
    guard sensMode else { return super.scrollWheel(with: event) }
    guard isEnabled else { return }
    
    let delta = Int((Double(event.deltaY) * responsiveness).rounded())
    guard delta != 0 else { return }
    sensValueChange(sensValue - delta)
  }
  
  /// Set the value and fire the action
  func sensValueChange(_ v: Int) {
    sensValue = v
    sendAction(#selector(NordLead2SensController.sensChange(_:)), to: target)
  }
  
}

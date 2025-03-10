
class JP8080MorphKnob : PBKnob {
  
  enum Mode {
    case velo
    case ctrl
  }
  
  typealias ValueTuple = (w: CGFloat, layer: CAShapeLayer, path: PBBezierPath, value: Int, anim: CABasicAnimation, strokeOff: CGFloat, color: PBColor, disabled: PBColor)

  private var valueTuples: [Mode:ValueTuple] = [
    .velo : (2, CAShapeLayer(), PBBezierPath(), 0, CABasicAnimation(keyPath:"path"), 1, .blue, .blue),
    .ctrl : (2, CAShapeLayer(), PBBezierPath(), 0, CABasicAnimation(keyPath:"path"), 3, .blue, .blue),
  ]
  
  override func initLayers() {
    super.initLayers()

    valueTuples.values.forEach {
      $0.layer.lineWidth = $0.w
      $0.layer.fillColor = nil
      $0.layer.actions = ["hidden" : NSNull()]
      layer.addSublayer($0.layer)
    }
  }
  
  func setValue(_ value: Int, mode: Mode) {
    guard -127...127 ~= value else { return }
    valueTuples[mode]?.value = value
    updateValueDisplay()
  }
  
  func value(forMode mode: Mode) -> Int {
    valueTuples[mode]?.value ?? 0
  }
  
  override func updateValuePath() {
    super.updateValuePath()
  
    let endPct = CGFloat(value - minimumValue) / CGFloat(maximumValue - minimumValue)
    valueTuples.values.forEach {
      var startPct = endPct + CGFloat($0.value) / 127
      startPct = min(1, max(0, startPct))
      if startPct < endPct {
        $0.layer.strokeStart = startPct
        $0.layer.strokeEnd = endPct
      }
      else {
        $0.layer.strokeStart = endPct
        $0.layer.strokeEnd = startPct
      }
    }
  }
  
  override func updateValueLabel() {
    guard let mode = mode else { return super.updateValueLabel() }
    let v = "\(valueTuples[mode]?.value ?? 0)"
    #if os(macOS)
    textField.stringValue = v
    #else
    valueLabel.text = v
    #endif
  }
  
  
  override func updateColors() {
    super.updateColors()
    valueTuples.forEach {
      $0.value.layer.strokeColor = activeColor(mode: $0.key).cgColor
    }
  }
  
  public func setColor(_ color: PBColor, mode: Mode) {
    valueTuples[mode]?.color = color
    valueTuples[mode]?.disabled = disabledColor(color)
    updateColors()
  }
      
  private func activeColor(mode: Mode) -> PBColor {
    (isEnabled ? valueTuples[mode]?.color : valueTuples[mode]?.disabled) ?? .blue
  }
  
  var mode: Mode? = nil {
    didSet {
      let color = mode == nil ? activeLabelColor : activeColor(mode: mode!)
      #if os(macOS)
      textField.textColor = color
      #else
      valueLabel.textColor = color
      #endif

      labelView.textColor = color
      updateValueLabel()
    }
  }
    
  override func layoutSubviews() {
    super.layoutSubviews()
        
    let hideKnobLayers = knobRadius < 10
    
    CATransaction.begin()
    
    valueTuples.values.forEach {
      $0.layer.isHidden = hideKnobLayers
      
      let radius = knobRadius - (knobStrokeWidth + $0.strokeOff)
      var t = CGAffineTransform(translationX: knobCenter.x, y: knobCenter.y).scaledBy(x: radius, y: radius)
      let newPath = knobPath.cgPath.copy(using: &t)

      $0.anim.fromValue = $0.layer.path
      $0.anim.toValue = newPath
      $0.layer.add($0.anim, forKey:"path")
      $0.layer.path = newPath
    }
    
    updateValuePath()
    
    CATransaction.commit()
  }
    
  #if os(macOS)
  override open func controlTextDidEndEditing(_ obj: Notification) {
    guard mode != nil else { return super.controlTextDidEndEditing(obj) }
    myValueChange(textField.integerValue)
    textField.isEditable = false
  }
  
  override open func control(_ control: NSControl, textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
    guard let mode = mode else { return super.control(control, textView: textView, doCommandBy: commandSelector) }
    switch commandSelector {
    case #selector(moveUp(_:)):
      valueTuples[mode]?.value += 1
    case #selector(moveUpAndModifySelection(_:)):
      valueTuples[mode]?.value += 10
    case #selector(moveDown(_:)):
      valueTuples[mode]?.value -= 1
    case #selector(moveDownAndModifySelection(_:)):
      valueTuples[mode]?.value -= 10
    case #selector(insertNewline(_:)):
      window?.makeFirstResponder(window?.initialFirstResponder)
    default:
      return false
    }
    return true
  }
  
  // MARK: Mouse Events
  
  override open func mouseDragged(with event: NSEvent) {
    guard let mode = mode else { return super.mouseDragged(with: event) }
    guard isEnabled else { return }
    
    let delta = Int((Double(event.deltaY) * responsiveness).rounded())
    guard delta != 0 else { return }
    myValueChange((valueTuples[mode]?.value ?? 0) - delta)
    mouseMoved = true
  }
  
  open override func scrollWheel(with event: NSEvent) {
    guard let mode = mode else { return super.scrollWheel(with: event) }
    guard isEnabled else { return }
    
    let delta = Int((Double(event.deltaY) * responsiveness).rounded())
    guard delta != 0 else { return }
    myValueChange((valueTuples[mode]?.value ?? 0) - delta)
  }
  
  #else
  
  override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
    guard let mode = mode else { return super.beginTracking(touch, with: event) }
    
    startValue = valueTuples[mode]?.value ?? 0
    hoverValueLayer(touch)
    return true
  }

  override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
    guard let mode = mode else { return super.continueTracking(touch, with: event) }
    
    trackValueLayer(touch)
    
    let touchPoint = touch.location(in: self)
    let delta = touchPoint.y - startTouchPoint.y
    var newValue = startValue - Int(round(delta / pixelsPerUnit))
    
    // constrain to min/max
    newValue = min(newValue, 127)
    newValue = max(newValue, -127)
    
    // only assign/notify if value actually changed
    if newValue != valueTuples[mode]?.value {
      myValueChange(newValue)
    }
    
    return true
  }
  #endif
    
  /// Set the value and fire the action
  private func myValueChange(_ v: Int) {
    guard let mode = mode else { return }
    valueTuples[mode]?.value = v
    updateValueLabel()
    updateValuePath()
    #if os(macOS)
    sendAction(action, to: target)
    #else
    sendActions(for: .valueChanged)
    #endif
  }

}

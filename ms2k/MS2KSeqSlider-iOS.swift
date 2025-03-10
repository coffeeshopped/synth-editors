
@IBDesignable
class MS2KSeqSlider : PBLabeledControl, RangeControl {
  
  var valueFormatter: ParamValueFormatter? = nil
  var valueParser: ParamValueParser? = nil
  
  var valueMap: [String]?
  var startTouchPoint = CGPoint()
  var startValue = 0
  var minimumValue: Int = 0 {
    didSet {
      guard maximumValue >= minimumValue else { return maximumValue = minimumValue }
      guard value >= minimumValue else { return value = minimumValue }
      updateValuePath()
    }
  }
  var maximumValue: Int = 127 {
    didSet {
      guard minimumValue <= maximumValue else { return minimumValue = maximumValue }
      guard value <= maximumValue else { return value = maximumValue }
      updateValuePath()
    }
  }
  
  var displayOffset: Int = 0 {
    didSet {
      updateColors()
      updateValuePath()
    }
  }
  
  private var valueLayer = CALayer()
  
  override func initLayers() {
    super.initLayers()

    layer.cornerRadius = 2

    valueLayer.cornerRadius = 1
    
    labelView.isOpaque = false
    
    layer.insertSublayer(valueLayer, below: labelView.layer)
  }
  
  // MARK: Colors
  
  @IBInspectable var altValueColor: UIColor! = UIColor.blue {
    didSet {
      var white: CGFloat = 0
      var alpha: CGFloat = 0
      altValueColor.getWhite(&white, alpha:&alpha)
      disabledAltValueColor = UIColor(white:white, alpha:alpha)
      
      updateColors()
    }
  }
  
  var disabledAltValueColor: UIColor! = UIColor.black
  
  var activeAltValueColor: UIColor {
    return isEnabled ? altValueColor : disabledAltValueColor
  }

  // override based on value
  override var activeValueColor: UIColor {
    return value + displayOffset < 0 ? activeAltValueColor : super.activeValueColor
  }

  override func updateColors() {
    super.updateColors()
    labelView.backgroundColor = UIColor.clear
    valueLayer.backgroundColor = activeValueColor.cgColor
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    if frame.width > 20 {
      CATransaction.begin()
      CATransaction.setDisableActions(true)
      labelView.isHidden = false
      labelView.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.width)
      CATransaction.commit()
    }
    else {
      labelView.isHidden = true
    }
    
    updateValuePath()
  }

  func updateValuePath() {
    let range = CGFloat(maximumValue - minimumValue)
    let s1 = CGFloat(-1 * (minimumValue + displayOffset)) / range
    let s2 = CGFloat(value - minimumValue) / range
    valueLayer.frame = CGRect(x: 0, y: frame.height * s1, width: frame.width, height: frame.height * (s1-s2))
  }
  
  
  override var value: Int {
    didSet {
      // ignore values outside of range
      guard value >= minimumValue && value <= maximumValue else { return value = oldValue }
      
      labelView.text = "\(value+displayOffset)"

      // update value color if needed
      // compare signs :)
      if (value+displayOffset) * (oldValue+displayOffset) <= 0 {
        valueLayer.backgroundColor = activeValueColor.cgColor
      }
      
      setNeedsLayout()
    }
  }
  
  override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
    startTouchPoint = touch.location(in: self)
    startValue = value
    return true
  }

  override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
    let delta = touch.location(in: self).y - startTouchPoint.y
    value = Int(startValue - Int(roundf(0.333*Float(delta))))
    sendActions(for: .valueChanged)
    return true
  }

}

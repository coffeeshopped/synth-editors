
class MS2KSeqSlider : PBFullSlider {
  
  override open func updateValuePath() {
    let range = CGFloat(maximumValue - minimumValue)
    let s1 = CGFloat(-1 * (minimumValue + displayOffset)) / range
    let s2 = CGFloat(value - minimumValue) / range
    valueLayer.frame = CGRect(x: 0, y: frame.height * s1, width: frame.width, height: frame.height * (s1-s2))
  }

  // MARK: Colors
  
  @IBInspectable var altValueColor: PBColor! = PBColor.blue {
    didSet {
      disabledAltValueColor = altValueColor.desaturated()
      updateColors()
    }
  }
  
  var disabledAltValueColor: PBColor! = PBColor.black
  
  var activeAltValueColor: PBColor {
    return isEnabled ? altValueColor : disabledAltValueColor
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
}

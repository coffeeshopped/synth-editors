
class MophoSeqSlider : PBFullSlider {
  
  override func updateValueDisplay() {
    super.updateValueDisplay()
    label = type(of: self).noteForValue(value)
  }
  
  static let noteMap = ["C","C#","D","D#","E","F","F#","G","G#","A","A#","B"]
  class func noteForValue(_ v: Int) -> String {
    switch v {
    case 127:
      return "Rest"
    case 126:
      return "Reset"
    default:
      return String(format:"%@%@%d", noteMap[(v%24)/2], (v % 2 == 1 ? "+" : ""), v/24)
    }
    
  }

}


class BSIINoteSelectControl : PBGridSelectControl {
  
  override func updateColors() {
    let lightBackgroundColor = activeValueColor.tinted(amount: 0.75)
    let darkBackgroundColor = activeValueColor.darkened(amount: 0.75)

    gridLayer.strokeColor = activeValueColor.cgColor
    layer.borderColor = lightBackgroundColor.cgColor
    
    labels.enumerated().forEach {
      let l = $0.element
      let isDark = [1,3,6,8,10].contains($0.offset % 12)
      l.foregroundColor = isDark ? lightBackgroundColor.cgColor : darkBackgroundColor.cgColor
      l.backgroundColor = isDark ? darkBackgroundColor.cgColor : lightBackgroundColor.cgColor
    }
    
    guard let selectedLabelIndex = selectedLabelIndex,
          selectedLabelIndex < labels.count else { return }
    labels[selectedLabelIndex].foregroundColor = darkBackgroundColor.cgColor
    labelBackgrounds[selectedLabelIndex].backgroundColor = activeValueColor.cgColor
  }
}

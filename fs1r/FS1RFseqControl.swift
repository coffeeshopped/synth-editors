////
////  FS1RFseqControl.swift
////  Yamaha
////
////  Created by Chadwick Wood on 11/6/20.
////  Copyright © 2020 Coffeeshopped LLC. All rights reserved.
////
//
//import Foundation
//import PBAPI
//
//class FS1RFseqControl : PBLabeledControl, PBGestureRecognizerDelegate {
//    
//  private var pitch = [Int](repeating: 0, count: 512)
//  private var vFreqs = (0..<8).map { _ in [Int](repeating: 0, count: 512) }
//  private var nFreqs = (0..<8).map { _ in [Int](repeating: 0, count: 512) }
//  private var vLevels = (0..<8).map { _ in [Int](repeating: 0, count: 512) }
//  private var nLevels = (0..<8).map { _ in [Int](repeating: 0, count: 512) }
//
//  var activePath: SynthPath = [.pitch] {
//    didSet {
//      
//    }
//  }
//  
//  private func activeValues() -> [Int] {
//    switch activePath.first {
//    case .pitch:
//      return pitch
//    default:
//      guard let trk = activePath.i(1) else { return [] }
//      switch activePath[2] {
//      case .voiced:
//        return activePath[3] == .freq ? vFreqs[trk] : vLevels[trk]
//      default:
//        return activePath[3] == .freq ? nFreqs[trk] : nLevels[trk]
//      }
//    }
//  }
//
//  private func activeLayer() -> CAShapeLayer {
//    switch activePath.first {
//    case .pitch:
//      return pitchLayer
//    default:
//      guard let trk = activePath.i(1) else { return CAShapeLayer() }
//      switch activePath[2] {
//      case .voiced:
//        return activePath[3] == .freq ? vFreqLayers[trk] : vLevelLayers[trk]
//      default:
//        return activePath[3] == .freq ? nFreqLayers[trk] : nLevelLayers[trk]
//      }
//    }
//  }
//
//  private func activeBezierPath() -> PBBezierPath {
//    switch activePath.first {
//    case .pitch:
//      return pitchPath
//    default:
//      guard let trk = activePath.i(1) else { return PBBezierPath() }
//      switch activePath[2] {
//      case .voiced:
//        return activePath[3] == .freq ? vFreqPaths[trk] : vLevelPaths[trk]
//      default:
//        return activePath[3] == .freq ? nFreqPaths[trk] : nLevelPaths[trk]
//      }
//    }
//  }
//  
//  private func setActiveValue(step: Int, value: Int) {
//    switch activePath.first {
//    case .pitch:
//      pitch[step] = value
//    default:
//      guard let trk = activePath.i(1) else { return }
//      switch activePath[2] {
//      case .voiced:
//        if activePath[3] == .freq {
//          vFreqs[trk][step] = value
//        }
//        else {
//          vLevels[trk][step] = value
//        }
//      default:
//        if activePath[3] == .freq {
//          nFreqs[trk][step] = value
//        }
//        else {
//          nLevels[trk][step] = value
//        }
//      }
//    }
//  }
//
//  enum Mode : Int {
//    case pen, line, smooth, randomize, shiftX, shiftY, scaleY
//  }
//  
//  var mode: Mode = .pen
//  
//  var stepCount = 512 {
//    didSet { updateArrayPath() }
//  }
//  
//  var range = 0...127 {
//    didSet {
//      minLabel.text = "\(range.lowerBound)"
//      maxLabel.text = "\(range.upperBound)"
//      updateArrayPath()
//    }
//  }
//  
//  func updateArrayPath() {
//    
//  }
//
//  private let gridLayer = CAShapeLayer()
//  let gridPath = PBBezierPath()
//
//  private let pitchLayer = CAShapeLayer()
//  let pitchPath = PBBezierPath()
//  private let vFreqLayers = (0..<8).map { _ in CAShapeLayer() }
//  let vFreqPaths = (0..<8).map { _ in PBBezierPath() }
//  private let nFreqLayers = (0..<8).map { _ in CAShapeLayer() }
//  let nFreqPaths = (0..<8).map { _ in PBBezierPath() }
//  private let vLevelLayers = (0..<8).map { _ in CAShapeLayer() }
//  let vLevelPaths = (0..<8).map { _ in PBBezierPath() }
//  private let nLevelLayers = (0..<8).map { _ in CAShapeLayer() }
//  let nLevelPaths = (0..<8).map { _ in PBBezierPath() }
//
//  private var maxLabel: PBLabel!
//  private var minLabel: PBLabel!
//  
//  override func initLayers() {
//    super.initLayers()
//    
//    layer.cornerRadius = 2.0
//    clipsToBounds = true
//    
//    let layerInitBlock: (CAShapeLayer) -> Void = { [weak self] in
//      $0.fillColor = nil
//      $0.lineWidth = 2
//      self?.layer.addSublayer($0)
//    }
//    layerInitBlock(pitchLayer)
//    vFreqLayers.forEach { layerInitBlock($0) }
//    nFreqLayers.forEach { layerInitBlock($0) }
//    vLevelLayers.forEach { layerInitBlock($0) }
//    nLevelLayers.forEach { layerInitBlock($0) }
//
//    gridLayer.fillColor = nil
//    gridLayer.lineWidth = 1
//    gridLayer.path = gridPath.cgPath
//    layer.insertSublayer(gridLayer, below: pitchLayer)
//    
//    minLabel = makeLabel()
//    maxLabel = makeLabel()
//    addSubview(minLabel)
//    addSubview(maxLabel)
//    
//    #if os(iOS)
//    zoomRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(zoomGesture(_:)))
//    zoomRecognizer.delegate = self
//    addGestureRecognizer(zoomRecognizer)
//
//    panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panGesture(_:)))
//    panRecognizer.minimumNumberOfTouches = 2
//    panRecognizer.delegate = self
//    addGestureRecognizer(panRecognizer)
//    #else
//    
//    #endif
//  }
//  
//  private func makeLabel() -> PBLabel {
//    let l = PBLabel()
//    l.font = PBFont.boldSystemFont(ofSize: 13)
//    return l
//  }
//  
//  private var zoomScale: CGFloat = 1
//  
//  private var startX: CGFloat = 0
//  
//  private var zoomValueX: CGFloat = 0
//  private var zoomViewX: CGFloat = 0
//  private var startScale: CGFloat = 1
//  private var startZoomViewX: CGFloat = 0
//  
//  override func updateColors() {
//    super.updateColors()
//
//    let al = activeLayer()
//    let layerColorBlock: (CAShapeLayer) -> Void = { [weak self] in
//      if $0 == al {
//        $0.strokeColor = self?.activeValueColor.cgColor
//      }
//      else {
//        $0.strokeColor = self?.activeValueColor.withAlphaComponent(0.5).cgColor
//      }
//    }
//    layerColorBlock(pitchLayer)
//    vFreqLayers.forEach { layerColorBlock($0) }
//    nFreqLayers.forEach { layerColorBlock($0) }
//    vLevelLayers.forEach { layerColorBlock($0) }
//    nLevelLayers.forEach { layerColorBlock($0) }
//
//    
//    let gridColor = backgroundColor?.tinted(amount: 0.2)
//    gridLayer.strokeColor = gridColor?.cgColor
//    if let gridColor = gridColor {
//      minLabel?.textColor = gridColor
//      maxLabel?.textColor = gridColor
//    }
//  }
//  
//  override func layoutSubviews() {
//    super.layoutSubviews()
//    
//    pitchLayer.frame = layer.bounds
//    vFreqLayers.forEach { $0.frame = layer.bounds }
//    nFreqLayers.forEach { $0.frame = layer.bounds }
//    vLevelLayers.forEach { $0.frame = layer.bounds }
//    nLevelLayers.forEach { $0.frame = layer.bounds }
//
//    maxLabel.frame = CGRect(x: 4, y: 4, width: 60, height: 19)
//    minLabel.frame = CGRect(x: 4, y: bounds.height - (4 + 19), width: 60, height: 19)
//
//    updateTransforms()
//  }
//  
//  private var toViewTransform: CGAffineTransform = .identity
//  private var fromViewTransform: CGAffineTransform = .identity
//
//  private func updateTransforms() {
//    // NOTE: I thought the operations should happen in reverse order. Need to read about matrix math...
//    let zValX = max(0, zoomValueX)
//    toViewTransform = CGAffineTransform.identity
//      .translatedBy(x: zoomViewX, y: bounds.height)
//      .scaledBy(x: zoomScale * bounds.width / CGFloat(stepCount), y: -bounds.height / (CGFloat(range.upperBound - range.lowerBound)))
//      .translatedBy(x: -zValX, y: -1 * CGFloat(range.lowerBound))
//    
//    let minShift = CGPoint.zero.applying(toViewTransform).x
//    if minShift > 0 {
//      toViewTransform = toViewTransform.concatenating(CGAffineTransform(translationX: -minShift, y: 0))
//    }
//    let maxShift = CGPoint(x: stepCount, y: 0).applying(toViewTransform).x
//    if maxShift < bounds.width {
//      toViewTransform = toViewTransform.concatenating(CGAffineTransform(translationX: bounds.width - maxShift, y: 0))
//    }
//    
//    
//    fromViewTransform = toViewTransform.inverted()
//    
//    updateGrid()
//    updatePath(pitchPath, values: pitch, layer: pitchLayer)
//    (0..<8).forEach {
//      updatePath(vFreqPaths[$0], values: vFreqs[$0], layer: vFreqLayers[$0])
//      updatePath(nFreqPaths[$0], values: nFreqs[$0], layer: nFreqLayers[$0])
//      updatePath(vLevelPaths[$0], values: vLevels[$0], layer: vLevelLayers[$0])
//      updatePath(nLevelPaths[$0], values: nLevels[$0], layer: nLevelLayers[$0])
//    }
//  }
//  
//  func updateGrid() {
//    guard stepCount > 0 else { return }
//
//    let divisionCount = 8
//    gridPath.removeAllPoints()
//    
//    let divisionWidth = stepCount / divisionCount
//    
//    for i in 1..<divisionCount {
//      gridPath.move(to: CGPoint(x: divisionWidth * i, y: range.upperBound))
//      gridPath.addLine(to: CGPoint(x: divisionWidth * i, y: range.lowerBound))
//    }
//    
//    gridPath.move(to: CGPoint(x: 0, y: 0))
//    gridPath.addLine(to: CGPoint(x: stepCount, y: 0))
//    
//    gridPath.apply(toViewTransform)
//    animateGridChanges()
//  }
//  
//  private func updateActivePath() {
//    updatePath(activeBezierPath(), values: activeValues(), layer: activeLayer())
//  }
//  
//  func updatePath(_ path: PBBezierPath, values: [Int], layer: CAShapeLayer) {
//    guard stepCount > 0 else { return }
//    
//    path.removeAllPoints()
//    
//    path.move(to: CGPoint(x: -2 , y: 0))
//    
//    // take valuePanShift into account for drawing
//    path.addLine(to: CGPoint(x: 0 , y: values[0]))
//    for i in 0..<stepCount {
//      path.addLine(to: CGPoint(x: i+1, y: values[i]))
//      if i + 1 < stepCount { path.addLine(to: CGPoint(x: i + 1, y: values[i + 1])) }
//    }
//    path.addLine(to: CGPoint(x: stepCount + 1, y: 0))
//
//    path.apply(toViewTransform)
//    
//    animateChanges(path: path, layer: layer)
//  }
//
//  private let gridAnimation = CABasicAnimation(keyPath: "path")
//  private static let gridAnimationKey = "gridPath"
//  final func animateGridChanges() {
//    // remove old animation since this can get called many times rapidly
//    gridLayer.removeAnimation(forKey: FS1RFseqControl.animationKey)
//    
//    gridAnimation.duration = 0.05
//    gridAnimation.fromValue = gridLayer.presentation()?.path
//    gridAnimation.toValue = gridPath.cgPath
//    gridLayer.path = gridPath.cgPath
//    gridLayer.add(gridAnimation, forKey: FS1RFseqControl.gridAnimationKey)
//  }
//
//  private let animation = CABasicAnimation(keyPath: "path")
//  private static let animationKey = "path"
//  final func animateChanges(path: PBBezierPath, layer: CAShapeLayer) {
//    // remove old animation since this can get called many times rapidly
//    layer.removeAnimation(forKey: FS1RFseqControl.animationKey)
//    
//    animation.duration = 0.05
//    animation.fromValue = layer.presentation()?.path
//    animation.toValue = path.cgPath
//    layer.path = path.cgPath
////    arrayLayer.add(animation, forKey: PBArrayControl.animationKey)
//  }
//  
//  private var lastDataSet: (Int,Int) = (0,0)
//  
//  private func dataSet(fromViewPoint pt: CGPoint) -> (Int,Int) {
//    let dataPoint = pt.applying(fromViewTransform)
//    let index = max(min(Int(dataPoint.x), stepCount - 1), 0)
//    let v = max(min(Int(round(dataPoint.y)), range.upperBound), range.lowerBound)
//    return (index,v)
//  }
//  
//  private func continueSmooth(_ dataSet: (Int,Int)) {
//    let lo = min(dataSet.0, lastDataSet.0)
//    let hi = max(dataSet.0, lastDataSet.0)
//    let oldValues = activeValues()
//    for i in lo...hi {
//      let newValue = 0.3333 * Float(oldValues[i]) +
//        0.3333 * Float(oldValues[(i - 1 + stepCount) % stepCount]) +
//        0.3333 * Float(oldValues[(i + 1 + stepCount) % stepCount])
//      setActiveValue(step: i, value: Int(round(newValue)))
//    }
//    updateActivePath()
//  }
//  
//  private func continueRandomize(_ dataSet: (Int,Int)) {
//    let lo = min(dataSet.0, lastDataSet.0)
//    let hi = max(dataSet.0, lastDataSet.0)
//    let oldValues = activeValues()
//    // randomize the value 20%
//    let randomizePct: Float = 0.07
//    let randomRange = Int(round(Float(range.upperBound - range.lowerBound) * randomizePct))
//    let doubleRandomRange = 2 * randomRange
//    for i in lo...hi {
//      let newValue = oldValues[i] + ((0...doubleRandomRange).random()! - randomRange)
//      setActiveValue(step: i, value: max(min(newValue, range.upperBound), range.lowerBound))
//    }
//    updateActivePath()
//  }
//  
//  private func continuePen(_ dataSet: (Int,Int)) {
//    setActiveValue(step: dataSet.0, value: dataSet.1)
//    if abs(dataSet.0 - lastDataSet.0) > 1 {
//      //interpolate
//      let startIndex: Int
//      let indexRange = abs(dataSet.0 - lastDataSet.0)
//      let startValue: Int
//      let valueRange: Float
//      if dataSet.0 < lastDataSet.0 {
//        startIndex = dataSet.0
//        startValue = dataSet.1
//        valueRange = Float(lastDataSet.1 - dataSet.1)
//      }
//      else {
//        startIndex = lastDataSet.0
//        startValue = lastDataSet.1
//        valueRange = Float(dataSet.1 - lastDataSet.1)
//      }
//      for i in 1..<indexRange {
//        setActiveValue(step: startIndex + i, value: startValue + Int(round(Float(i)/Float(indexRange) * valueRange)))
//      }
//    }
//    updateActivePath()
//  }
//
//  private func continueLine(_ dataSet: (Int,Int)) {
//    undoValues.enumerated().forEach {
//      setActiveValue(step: $0.offset, value: $0.element)
//    }
//    setActiveValue(step: dataSet.0, value: dataSet.1)
//    if abs(dataSet.0 - lineStartDataSet.0) > 1 {
//      //interpolate
//      let startIndex: Int
//      let indexRange = abs(dataSet.0 - lineStartDataSet.0)
//      let startValue: Int
//      let valueRange: Float
//      if dataSet.0 < lineStartDataSet.0 {
//        startIndex = dataSet.0
//        startValue = dataSet.1
//        valueRange = Float(lineStartDataSet.1 - dataSet.1)
//      }
//      else {
//        startIndex = lineStartDataSet.0
//        startValue = lineStartDataSet.1
//        valueRange = Float(dataSet.1 - lineStartDataSet.1)
//      }
//      
//      for i in 1..<indexRange {
//        setActiveValue(step: startIndex+i, value: startValue + Int(round(Float(i)/Float(indexRange) * valueRange)))
//      }
//    }
//    updateActivePath()
//  }
//
//  private func continueShiftX(_ dataSet: (Int,Int)) {
//    let shift = shiftStart - dataSet.0
//    for i in 0..<stepCount {
//      setActiveValue(step: i, value: undoValues[(i + shift + stepCount) % stepCount])
//    }
//    updateActivePath()
//  }
//
//  private func continueShiftY(_ dataSet: (Int,Int)) {
//    let shift = shiftStart - dataSet.1
//    (0..<stepCount).forEach {
//      setActiveValue(step: $0, value: max(min(undoValues[$0] - shift, range.upperBound), range.lowerBound))
//    }
//    updateActivePath()
//  }
//
//  private func continueScaleY(_ y: CGFloat) {
//    let diff = scaleStart - y
//    let scaleFactor: CGFloat
//    scaleFactor = 1 + diff / 100
//
//    (0..<stepCount).forEach {
//      setActiveValue(step: $0, value: max(min(Int(round(CGFloat(undoValues[$0]) * scaleFactor)), range.upperBound), range.lowerBound))
//    }
//    updateActivePath()
//  }
//
//  private var undoValues = [Int]()
//  
//  private var lineStartDataSet: (Int,Int) = (0,0)
//  private var shiftStart = 0
//  private var scaleStart: CGFloat = 0
//
//  
//  private func beginDraw(location: CGPoint) {
//    let dataSet = self.dataSet(fromViewPoint: location)
//    lastDataSet = dataSet
//    undoValues = activeValues()
//
//    switch mode {
//    case .pen:
//      continuePen(dataSet)
//    case .line:
//      lineStartDataSet = dataSet
//    case .smooth:
//      continueSmooth(dataSet)
//    case .randomize:
//      break
//    case .shiftX:
//      shiftStart = dataSet.0
//    case .shiftY:
//      shiftStart = dataSet.1
//    case .scaleY:
//      scaleStart = location.y
//    }
//  }
//  
//  private func continueDraw(location: CGPoint) {
//    let dataSet = self.dataSet(fromViewPoint: location)
//    
//    switch mode {
//    case .pen:
//      continuePen(dataSet)
//    case .line:
//      continueLine(dataSet)
//    case .smooth:
//      continueSmooth(dataSet)
//    case .randomize:
//      continueRandomize(dataSet)
//    case .shiftX:
//      continueShiftX(dataSet)
//    case .shiftY:
//      continueShiftY(dataSet)
//    case .scaleY:
//      continueScaleY(location.y)
//    }
//
//    lastDataSet = dataSet
//  }
//  
//  #if os(iOS)
//
//  private var zoomRecognizer: UIPinchGestureRecognizer!
//  private var panRecognizer: UIPanGestureRecognizer!
//
//  func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
//    return true
//  }
//
//  @objc func zoomGesture(_ sender: UIPinchGestureRecognizer) {
//    switch sender.state {
//    case .began:
//      startScale = zoomScale
//      let loc = sender.location(in: self)
//      zoomViewX = loc.x
//      zoomValueX = loc.applying(fromViewTransform).x
//    case .changed:
//      // clamp to 1...16
//      zoomScale = min(max(startScale * sender.scale, 1), 16)
//      updateTransforms()
//    default:
//      break
//    }
//  }
//  
//  @objc func panGesture(_ sender: UIPanGestureRecognizer) {
//    switch sender.state {
//    case .began:
//      startZoomViewX = zoomViewX
//    case .changed:
//      let shift = sender.translation(in: self).x
//      zoomViewX = startZoomViewX + shift
//      updateTransforms()
//    default:
//      break
//    }
//  }
//
//  
//  override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
//    beginDraw(location: touch.location(in: self))
//    return true
//  }
//    
//  override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
//    continueDraw(location: touch.location(in: self))
//    return true
//  }
//
//  override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
//    sendActions(for: .valueChanged)
//  }
//  
//  override func cancelTracking(with event: UIEvent?) {
////    values = undoValues
//    updateArrayPath()
//  }
//
//  #else
//  
//  override func mouseDown(with event: NSEvent) {
//    beginDraw(location: convert(event.locationInWindow, from: nil))
//  }
//  
//  override func mouseDragged(with event: NSEvent) {
//    continueDraw(location: convert(event.locationInWindow, from: nil))
//  }
//  
//  override func mouseUp(with event: NSEvent) {
//    sendAction(action, to: target)
//  }
//  
//  #endif
//}

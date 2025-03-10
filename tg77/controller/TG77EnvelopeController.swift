
protocol TG77EnvelopeController : NewPatchEditorController {
  var env: TG77EnvelopeControl { get }
}

extension TG77EnvelopeController {

  func addRateLevelBlocks() {
    (0..<env.pointCount).forEach {
      addRateBlock(step: $0)
      addLevelBlock(step: $0, bipolar: env.bipolar)
    }
    (0..<env.releaseCount).forEach {
      addRateBlock(step: $0, release: true)
      addLevelBlock(step: $0, release: true, bipolar: env.bipolar)
    }
    addStartLevelBlock(bipolar: env.bipolar)
  }
  
  func addGainBlock() {
    let env = self.env
    addPatchChangeBlock(path: [.level]) { env.gain = CGFloat($0) / 127 }
  }
  
  func addHoldBlock() {
    let env = self.env
    addPatchChangeBlock(path: [.hold, .time]) { env.holdTime = 1 - CGFloat($0) / 63 }
  }
  
  func addRateBlock(step: Int, release: Bool = false) {
    let env = self.env
    let transform: ((Int) -> CGFloat) = { CGFloat($0 + 1) / 64 }
    if release {
      addPatchChangeBlock(path: [.release, .rate, .i(step)]) {
        env.set(releaseRate: transform($0), forIndex: step)
      }
    }
    else {
      addPatchChangeBlock(path: [.rate, .i(step)]) {
        env.set(rate: transform($0), forIndex: step)
      }
    }
  }
  
  func addLevelBlock(step: Int, release: Bool = false, bipolar: Bool = false) {
    let env = self.env
    let transform: ((Int) -> CGFloat) = bipolar ? { CGFloat($0 - 64) / 63 } : { CGFloat($0) / 63 }
    if release {
      addPatchChangeBlock(path: [.release, .level, .i(step)]) {
        env.set(releaseLevel: transform($0), forIndex: step)
      }
    }
    else {
      addPatchChangeBlock(path: [.level, .i(step)]) {
        env.set(level: transform($0), forIndex: step)
      }
    }
  }
  
  func addStartLevelBlock(bipolar: Bool = false) {
    let env = self.env
    if bipolar {
      addPatchChangeBlock(path: [.level, .i(-1)]) { env.startLevel = CGFloat($0 - 64) / 63 }
    }
    else {
      addPatchChangeBlock(path: [.level, .i(-1)]) { env.startLevel = CGFloat($0) / 63 }
    }
  }
}


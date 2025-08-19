
class TG77MiniOpController : NewPatchEditorController {
  
  override open var prefix: SynthPath? { return [.op, .i(index)] }

  private let opLabel = PBLabel()
  
  override var index: Int {
    didSet { opLabel.text = "\(index + 1)" }
  }
  
  override func loadView(_ view: PBView) {
    let envController = EnvController()
    envController.addGainBlock()
    addChild(envController)
    view.addSubview(envController.view)
    layout.addView(envController.view, forLayoutKey: "env")
    
    opLabel.textAlignment = .left
    opLabel.font = PBFont.boldSystemFont(ofSize: 11)
    view.addSubview(opLabel)
    layout.addView(opLabel, forLayoutKey: "op")
    
    let freqRatioLabel = PBLabel()
    freqRatioLabel.textAlignment = .right
    freqRatioLabel.font = PBFont.systemFont(ofSize: 11)
    freqRatioLabel.adjustsFontSizeToFitWidth = true
    freqRatioLabel.minimumScaleFactor = 0.5
    view.addSubview(freqRatioLabel)
    layout.addView(freqRatioLabel, forLayoutKey: "freq")
    
    let spacing = "-2-"
    layout.addRowConstraints([("op",1),("freq",4)], pinned: true, pinMargin: spacing, spacing: spacing)
    layout.addRowConstraints([("env",1)], pinned: true, pinMargin: spacing, spacing: spacing)
    layout.addConstraints(withVisualFormat: "V:|-s1-[op(>=11)]\(spacing)[env]-s1-|", options: [])
    
    addPatchChangeBlock(path: [.on]) { view.alpha = $0 == 1 ? 1 : 0.3 }
    
    addPatchChangeBlock(paths: [[.osc, .mode], [.coarse], [.fine], [.detune]]) { values in
      guard let coarse = values[[.coarse]],
        let fine = values[[.fine]],
        let detune = values[[.detune]] else { return }
      let fixedMode = values[[.osc, .mode]] == 1
      let valText = TG77VoicePatch.freqRatio(fixedMode: fixedMode, coarse: coarse, fine: fine)
      let detuneOff = detune
      let detuneString = (detuneOff == 0 ? "" : detuneOff < 0 ? "\(detuneOff)" : "+\(detuneOff)")
      freqRatioLabel.text = (fixedMode ? "\(valText) Hz" : "x \(valText)") + detuneString
    }
//    #if os(iOS)
//    let tap = UITapGestureRecognizer(target: self, action: #selector(tap(_:)))
//    #else
//    let tap = NSClickGestureRecognizer(target: self, action: #selector(tap(_:)))
//    #endif
//    view.addGestureRecognizer(tap)
    
    registerForEditMenu(envController.view, bundle: (
      paths: { Self.AllPaths },
      pasteboardType: "com.cfshpd.TG77Op",
      initialize: nil,
      randomize: nil
    ))

    addColor(view: view, level: 3)
  }
  
  static let AllPaths: [SynthPath] = TG77VoicePatch.paramKeys().compactMap {
    guard $0.starts(with: [.element, .i(0), .fm, .op, .i(0)]) else { return nil }
    let filtered: [SynthPathItem] = [.src, .dest, .feedback, .adjust]
    guard !filtered.contains($0[5]) else { return nil }
    return $0.subpath(from: 5)
  }
    
  
  class EnvController : NewPatchEditorController, TG77EnvelopeController {
    let env = TG77EnvelopeControl(label: "")
    
    override func loadView() {
      env.pointCount = 4
      env.releaseCount = 2
      self.view = env
    }
    
    override func viewDidLoad() {
      super.viewDidLoad()
      addRateLevelBlocks()
      addHoldBlock()
      let env = self.env
      addPatchChangeBlock(path: [.loop, .pt]) { env.sustainPoint = $0 }
    }
    
  }

}


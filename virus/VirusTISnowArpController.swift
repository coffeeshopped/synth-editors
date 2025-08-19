
extension VirusTISnowVoiceController {
  
  class ArpController : NewPatchEditorController {
    override var prefix: SynthPath? { return [.arp] }
    
    override func loadView() {
      let paddedView = PaddedContainer()
      paddedView.horizontalPadding = 0
      paddedView.verticalPadding = 0.05
      let view = paddedView.mainView
      createPanels(forKeys: ["mode", "menu", "checks", "velo", "len"])
      addPanelsToLayout(andView: view)
      
      layout.addRowConstraints([("mode", 13), ("menu", 3)], pinned: true, pinMargin: "", spacing: "-s1-")
      layout.addRowConstraints([("checks", 1)], pinned: true, pinMargin: "", spacing: "-s1-")
      layout.addRowConstraints([("velo", 1)], pinned: true, pinMargin: "", spacing: "-s1-")
      layout.addRowConstraints([("len", 1)], pinned: true, pinMargin: "", spacing: "-s1-")
      layout.addColumnConstraints([("mode", 1), ("checks", 2), ("velo", 2), ("len", 2)], pinned: true, pinMargin: "", spacing: "-s1-")
      
      let octave = PBKnob(label: "Octaves")
      let noteLen = PBKnob(label: "Note Len")
      let hold = PBCheckbox(label: "Hold")
      let patLen = PBKnob(label: "Pattern Length")
      grid(panel: "mode", items: [[
        (PBSelect(label: "Arp Mode"), [.mode]),
        (octave, [.range]),
        (PBKnob(label: "Pattern"), [.pattern]),
        (PBSelect(label: "Resolution"), [.clock]),
        (noteLen, [.note, .length]),
        (PBKnob(label: "Swing"), [.swing]),
        (hold, [.hold]),
        (patLen, [.pattern, .length]),
      ]])
      
      let menuButton = createMenuButton(titled: "Arp")
      grid(panel: "menu", items: [[(menuButton, nil)]])
      
      let checks: [PBCheckbox] = (1...32).map { PBCheckbox(label: "\($0)") }
      let check1: [(PBView, SynthPath?)] = (0..<16).map {
        let off = $0 * 2
        return (checks[off], [.i(off), .on])
      } + [(LabelItem(gridWidth: 1), nil)]
      let check2: [(PBView, SynthPath?)] = [(LabelItem(gridWidth: 1), nil)] + (0..<16).map {
        let off = $0 * 2 + 1
        return (checks[off], [.i(off), .on])
      }
      grid(panel: "checks", items: [check1, check2])
      
      let sliders: [PBFullSlider] = (0..<32).map { PBFullSlider(label: "\($0 + 1)") }
      grid(panel: "velo", items: [(0..<32).map { (sliders[$0], [.i($0), .velo]) }])
      
      let lens: [PBKnob] = (1...32).map { PBKnob(label: "\($0)") }
      let len1: [(PBView, SynthPath?)] = (0..<16).map {
        let off = $0 * 2
        return (lens[off], [.i(off), .length])
      } + [(LabelItem(gridWidth: 1), nil)]
      let len2: [(PBView, SynthPath?)] = [(LabelItem(gridWidth: 1), nil)] + (0..<16).map {
        let off = $0 * 2 + 1
        return (lens[off], [.i(off), .length])
      }
      grid(panel: "len", items: [len1, len2])

      
      addPatchChangeBlock(path: [.mode]) { value in
        [octave, noteLen, hold].forEach { $0.isHidden = value == 7 }
      }
      addPatchChangeBlock(path: [.pattern]) { [weak self] value in
        let alpha: CGFloat = value == 0 ? 1 : 0.3
        ["checks", "velo", "len"].forEach { self?.panels[$0]?.alpha = alpha }
        patLen.alpha = alpha
        
      }
      addPatchChangeBlock(path: [.pattern, .length]) { length in
        (0..<32).forEach {
          let alpha: CGFloat = length < $0 ? 0.2 : 1
          checks[$0].alpha = alpha
          sliders[$0].alpha = alpha
          lens[$0].alpha = alpha
        }
      }
      (0..<32).forEach { step in
        addPatchChangeBlock(path: [.i(step), .on]) {
          sliders[step].isHidden = $0 == 0
          lens[step].isHidden = $0 == 0
        }
      }
      
      layout.activateConstraints()
      self.view = paddedView
      
      registerForEditMenu(menuButton, bundle: (
        paths: {(0..<32).map { [.i($0), .on] } + (0..<32).map { [.i($0), .velo] } + (0..<32).map { [.i($0), .length] }},
        pasteboardType: "",
        initialize: {
          (0..<32).map { $0 % 2 == 0 ? 1 : 0 } +
          [Int](repeating: 100, count: 32) +
          [Int](repeating: 64, count: 32)
        },
        randomize: {
          (0..<32).map { _ in (0...1).random()! } +
          (0..<32).map { _ in (0...127).random()! } +
          (0..<32).map { _ in (0...127).random()! }

        }
      ))
      
      addColor(panels: ["mode"], level: 1)
      addColor(panels: ["checks", "velo", "len"], level: 2)
      addColor(panels: ["menu"], clearBackground: true)

    }
  }

}

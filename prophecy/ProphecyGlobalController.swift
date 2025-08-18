
class ProphecyGlobalController : NewPagedEditorController {
  
  private let mainController = MainController()
  private let pgmController = PgmChController()
  private let ctrlController = CtrlController()
  
  override func loadView(_ view: PBView) {
    switchCtrl = PBSegmentedControl(items: ["Main", "Program Ch", "Controllers"])
    grid(panel: "switch", items: [[(switchCtrl, nil)]])
    
    addPanelsToLayout(andView: view)
    
    layout.addGridConstraints([
      (row: [("switch", 1)], height: 1),
      (row: [("page", 1)], height: 8),
    ], spacing: "-s1-")
    
    addColor(panels: ["switch"], clearBackground: true)
  }
  
  override func viewController(forIndex index: Int) -> PBViewController? {
    let controllers = [mainController, pgmController, ctrlController]
    guard index < controllers.count else { return nil }
    return controllers[index]
  }
    
  class MainController : NewPatchEditorController {
    override func loadView(_ view: PBView) {
      addChild(FullController(), withPanel: "full")

      grid(panel: "tune", items: [[
        (PBKnob(label: "MIDI Ch"), [.channel]),
        (PBKnob(label: "Tune"), [.tune]),
        (PBKnob(label: "Transpose"), [.transpose]),
        (PBSwitch(label: "Transpose Mode"), [.transpose, .mode]),
        (PBKnob(label: "Velo Curve"), [.velo, .curve]),
        (PBKnob(label: "AfterT Crv"), [.aftertouch, .curve]),
        (PBKnob(label: "AfterT Sens"), [.aftertouch, .sens]),
        (PBKnob(label: "Ribbon Z"), [.z, .sens]),
        (PBSwitch(label: "Pedal Polarity"), [.foot, .pedal, .polarity]),
        (PBSwitch(label: "Foot Sw Polarity"), [.foot, .mode, .polarity]),
        (PBSwitch(label: "Octave Mode"), [.octave, .mode]),
        (PBCheckbox(label: "Page Mem"), [.scene, .memory]),
        (PBCheckbox(label: "10's Hold"), [.hold]),
        (PBSwitch(label: "Delay/Reverb"), [.delay, .on]),
        (PBCheckbox(label: "Mem Protect"), [.memory, .protect]),
        (PBCheckbox(label: "Arp Mem Protect"), [.arp, .memory, .protect]),
      ]])
      
      grid(panel: "local", items: [[
        (PBCheckbox(label: "Local"), [.local]),
        (PBCheckbox(label: "Omni"), [.omni]),
        (PBSwitch(label: "Clock Src"), [.clock, .src]),
        (PBCheckbox(label: "Sysex Send"), [.sysex, .send]),
        (PBCheckbox(label: "Sysex Rcv"), [.sysex, .rcv]),
        (PBCheckbox(label: "PgmCh Send"), [.pgm, .send]),
        (PBCheckbox(label: "PgmCh Rcv"), [.pgm, .rcv]),
      ]])
      
      grid(panel: "knobs", items: [[
        (PBSelect(label: "Knob 1 Ctrl"), [.knob, .i(0), .ctrl]),
        (PBSelect(label: "Knob 2 Ctrl"), [.knob, .i(1), .ctrl]),
        (PBSelect(label: "Knob 3 Ctrl"), [.knob, .i(2), .ctrl]),
        (PBSelect(label: "Knob 4 Ctrl"), [.knob, .i(3), .ctrl]),
        (PBSelect(label: "Knob 5 Ctrl"), [.knob, .i(4), .ctrl]),
      ]])
      
      grid(panel: "ec5", items: [[
        (PBSelect(label: "EC5 A"), [.extra, .i(0)]),
        (PBSelect(label: "EC5 B"), [.extra, .i(1)]),
        (PBSelect(label: "EC5 C"), [.extra, .i(2)]),
        (PBSelect(label: "EC5 D"), [.extra, .i(3)]),
        (PBSelect(label: "EC5 E"), [.extra, .i(4)]),
      ]])
      
      grid(panel: "arp", items: [[
        (PBSelect(label: "Arp Velo Ctrl"), [.velo, .ctrl]),
        (PBSelect(label: "Arp Gate Ctrl"), [.gate, .ctrl]),
      ]])
      
      let noteMiso = Miso.noteName(zeroNote: "C", octave: false)
      grid(panel: "octave", itemsAndHeights: [
        (row: [(LabelItem(text: "User Scale 1", gridWidth: 1, textAlignment: .left), nil)], height: 1),
        (row: (0..<12).map { (PBKnob(label: "\(noteMiso.forward(Float($0)))"), [.scale, .octave, .i($0)]) }, height: 2),
      ])

      addPanelsToLayout(andView: view)
      
      layout.addGridConstraints([
        (row: [("tune", 16)], height: 1),
        (row: [("local", 7), ("knobs", 7.5)], height: 1),
        (row: [("ec5", 7.5), ("arp", 3)], height: 1),
        (row: [("octave", 12),], height: 1.5),
        (row: [("full", 12),], height: 2.5),
      ], pinMargin: "", spacing: "-s1-")
      
      addColorToAll()
    }
  }
  
  class FullController : NewPatchEditorController {
    override func loadView(_ view: PBView) {
      let labeledSwitch = LabeledSegmentedControl(label: "Octave", items: (-1...9).map { "\($0)" })
      switchCtrl = labeledSwitch.segmentedControl
      
      let noteMiso = Miso.noteName(zeroNote: "C", octave: false)
      let knobs = (0..<12).map { PBKnob(label: "\(noteMiso.forward(Float($0)))") }
      grid(view: view, itemsAndHeights: [
        (row: [(LabelItem(text: "User Scale 2", gridWidth: 1, textAlignment: .left), nil)], height: 1),
        (row: (0..<12).map { (knobs[$0], nil) }, height: 2),
        (row: [(labeledSwitch, nil)], height: 2),
      ])
      
      (0..<12).forEach { k in
        let knob = knobs[k]
        knob.minimumValue = -100
        knob.maximumValue = 100
        addPatchChangeBlock { [weak self] changes in
          let index = self?.index ?? 0
          let path: SynthPath = [.scale, .key, .i(index * 12 + k)]
          guard let value = Self.updatedValue(path: path, state: changes) else { return }
          knob.value = value
        }
        addControlChangeBlock(control: knob) { [weak self] in
          let index = self?.index ?? 0
          let path: SynthPath = [.scale, .key, .i(index * 12 + k)]
          return .paramsChange([path : knob.value])
        }
      }
    }
  }
  
  // Bank PGm ch map
  class PgmChController : NewPatchEditorController {
    override var prefix: SynthPath? { return [.bank, .i(index)] }

    override var index: Int {
      didSet {
        guard index < 3 else { return }
        knobs.enumerated().forEach { $0.element.label = ["A", "B", "C"][index] + "\($0.offset)" }
      }
    }
    
    private let knobs = (0..<64).map { PBKnob(label: "A\($0)") }

    override func loadView(_ view: PBView) {
      let labeledSwitch = LabeledSegmentedControl(label: "Bank", items: ["A", "B", "C"])
      switchCtrl = labeledSwitch.segmentedControl
      grid(panel: "switch", items: [[(switchCtrl, nil)]])
      
      grid(panel: "bytes", items: [[
        (PBKnob(label: "Select LSB"), [.lo]),
        (PBKnob(label: "MSB"), [.hi]),
      ]])
      
      (0..<4).forEach { row in
        grid(panel: "row\(row)", items: [
          (0..<16).map {
            let k = row * 16 + $0
            return (knobs[k], [.pgm, .i(k)])
          }
        ])
      }
      
      addPanelsToLayout(andView: view)
      
      layout.addGridConstraints([
        [("switch", 6), ("bytes", 2)],
        [("row0", 16)],
        [("row1", 16)],
        [("row2", 16)],
        [("row3", 16)],
      ], pinMargin: "", spacing: "-s1-")
      
      index += 0
      
      addColorToAll(except: ["switch"])
      addColor(panels: ["switch"], clearBackground: true)
    }
  }
  
  class CtrlController : NewPatchEditorController {
    override var prefix: SynthPath? {
      switch index {
      case 0:
        return [.bend]
      case 1:
        return [.aftertouch]
      default:
        return [.ctrl, .i(index - 2)]
      }
    }
    
    override func loadView(_ view: PBView) {
      let gridCtrl = PBGridSelectControl()
      gridCtrl.options = OptionsParam.makeOptions(["Bend", "AfterT"] + (0..<96).map { "CC\($0)" })
      gridCtrl.columnCount = 14
      gridCtrl.addValueChangeTarget(self, action: #selector(selectIndex(_:)))
      grid(panel: "switch", items: [[(gridCtrl, nil)]])
      
      grid(panel: "ctrl", items: [[
        (PBCheckbox(label: "Xmt"), [.send]),
      ],[
        (PBSwitch(label: "Rcv"), [.rcv]),
      ],[
        (PBSelect(label: "Translate"), [.transpose]),
      ],[
        (PBCheckbox(label: "Return"), [.thru]),
      ]])
      
      addPanelsToLayout(andView: view)
      
      layout.addGridConstraints([[("switch", 14), ("ctrl", 2)]], pinMargin: "", spacing: "-s1-")
      
      addColorToAll(except: ["switch"])
      addColor(panels: ["switch"], clearBackground: true)
    }
    
  }
}

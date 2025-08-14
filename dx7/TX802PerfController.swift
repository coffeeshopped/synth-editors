
//class TX802PerfController : NewPatchEditorController {
//  
//  private var partControllers: [PartController]!
//
//  override func loadView(_ view: PBView) {
//    partControllers = addChildren(count: 8, panelPrefix: "p")
//    var layoutItems = [(String,CGFloat)]()
//    partControllers.enumerated().forEach {
//      let key = "p\($0.offset)"
//      layout.addView($0.element.view, forLayoutKey: key)
//      view.addSubview($0.element.view)
//      layoutItems.append((key,1))
//    }
//    
//    layout.addGridConstraints([layoutItems], spacing: "-s1-")
//    addColorToAll()
//  }
//    
//  
//  class PartController : NewPatchEditorController {
//    
//    override var index: Int {
//      didSet {
//        linkGen.isHidden = index == 0
//        partLabel.text = "\(index + 1)"
//      }
//    }
//    
//    override var prefix: SynthPath? { return [.part, .i(index)] }
//    
//    private let linkGen = PBSwitch(label: "Linked")
//    private let partLabel = LabelItem()
//    
//    private var internalOptions = [Int:String]()
//    private static let blankNameOptions = OptionsParam.makeOptions((1...64).map { "\($0)" })
//    
//    override func loadView(_ view: PBView) {
//      partLabel.textAlignment = .center
//      
//      let pgmDropdown = PBSelect(label: "Voice")
//      let altAssign = PBCheckbox(label: "Alt Assign")
//      quickGrid(view: view, items: [[
//        (linkGen, nil, "linkGen"),
//        (altAssign, [.key, .assign, .group], nil),
//        ],[
//        (PBSwitch(label: "Bank"), [.voice, .bank], nil),
//        (PBKnob(label: "Midi Ch"), [.channel], nil),
//        ],[
//        (pgmDropdown, [.voice, .number], nil),
//        ],[
//        (PBKnob(label: "Volume"), [.volume], nil),
//        (PBSwitch(label: "Output"), [.out, .assign], nil),
//        ],[
//        (PBKnob(label: "Note Lo"), [.note, .lo], nil),
//        (PBKnob(label: "Note Hi"), [.note, .hi], nil),
//        ],[
//        (PBKnob(label: "Note Shift"), [.note, .shift], nil),
//        (PBKnob(label: "Detune"), [.detune], nil),
//        ],[
//        (PBCheckbox(label: "EG Damp"), [.env, .redamper], nil),
//        ],[
//        (PBKnob(label: "MicroT Tab"), [.micro, .tune], nil),
//        ],[
//        (partLabel, nil, "partLabel")
//        ]])
//
//      let linkGen = self.linkGen
//      addBlocks(control: linkGen, path: [.channel, .offset]) {
//        linkGen.options = [0 : " ", 1 : "⬅️"]
//      } patchChangeAssignBlock: { [weak self] in
//        linkGen.value = $0 == self?.index ? 0 : 1
//      } controlChangeValueBlock: { [weak self] in
//        let index = self?.index ?? 0
//        return linkGen.value == 0 ? index : index - 1
//      }
//
//      addPatchChangeBlock(path: [.channel, .offset]) { [weak self] in
//        view.alpha = $0 == self?.index ? 1 : 0.4
//      }
//      addPatchChangeBlock { [weak self] (state) in
//        guard let index = self?.index,
//              index > 0,
//              let changes = self?.updatedValuesForFullPaths(fullPaths: [
//                [.part, .i(index), .channel],
//                [.part, .i(index - 1), .channel]
//              ], changes: state),
//              let myChan = changes[[.part, .i(index), .channel]],
//              let prevChan = changes[[.part, .i(index - 1), .channel]] else { return }
//        altAssign.isHidden = myChan != prevChan
//      }
//      
//      
//      let pgmOptionsBlock: ((Int) -> Void) = { [weak self] (value) in
//        guard let self = self else { return }
//        let options: [Int:String]
//        switch value {
//        case 0:
//          options = self.internalOptions
//        case 1:
//          options = Self.blankNameOptions
//        case 2:
//          options = TX802VoiceBank.bankAOptions
//        case 3:
//          options = TX802VoiceBank.bankBOptions
//        default:
//          options = [:]
//        }
//        pgmDropdown.options = options
//      }
//      addPatchChangeBlock(path: [.voice, .bank], valueChangeBlock: pgmOptionsBlock)
//      addParamChangeBlock { [weak self] (params) in
//        (0..<2).forEach { bank in
//          guard let param = params.params[[.patch, .name, .i(bank)]] as? OptionsParam else { return }
//          param.options.forEach {
//            self?.internalOptions[$0.key + (bank * 32)] = $0.value
//          }
//          // update the dropdown options if needed
//          if let bank = self?.latestValue(path: [.voice, .bank]) {
//            pgmOptionsBlock(bank)
//          }
//        }
//      }
//    }
//  }
//
//}
//

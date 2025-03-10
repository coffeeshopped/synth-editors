
struct TetraComboController {
  
  static func controller(popover: ModulePopoverPatchBrowserController) -> FnPagedEditorController {
    ActivatedFnEditorController { (vc) in

      let segLabels: [String] = Array((1...4).map { ["V\($0)", "S\($0)"] }.joined())
      vc.switchCtrl = PBSegmentedControl(items: segLabels)
      vc.grid(panel: "switch", pinMargin: "", items: [[(vc.switchCtrl, nil)]])

      vc.grid(panel: "knobs", items: [[
        (PBSelect(label: "Knob 1"), [.knob, .i(0)]),
        (PBSelect(label: "Knob 2"), [.knob, .i(1)]),
        (PBSelect(label: "Knob 3"), [.knob, .i(2)]),
        (PBSelect(label: "Knob 4"), [.knob, .i(3)]),
        ]])

      let uniAssign = PBSelect(label: "Unison Assign")
      vc.grid(panel: "key", prefix: [.layer, .i(0)], items: [[
        (PBCheckbox(label: "Unison"), [.unison]),
        (uniAssign, [.keyAssign]),
        ]])
      vc.dims(view: uniAssign, forPath: [.layer, .i(0), .unison])

      vc.addLayoutConstraints { (layout) in
        layout.addRowConstraints([("switch", 8), ("key", 2.5), ("knobs", 6)], pinned: true, spacing: "-s1-")
        layout.addRowConstraints([("page",1)], pinned: true, spacing: "-s1-")
        layout.addColumnConstraints([
          ("switch",1),("page",8),
        ], pinned: true, spacing: "-s1-")
      }
      
      vc.addColor(panels: ["switch"], level: 1, clearBackground: true)
      vc.addColor(panels: ["key", "knobs"], level: 1)

      vc.setControllerLogic([
        [.voice] : { voiceController(popover: popover) },
        [.seq] : seqController,
      ], indexMap: 4.map { [[.voice, .i($0)], [.seq, .i($0)]] }.reduce([], +))
    }
  }
  
  static func voiceController(popover: ModulePopoverPatchBrowserController) -> FnPatchEditorController {
    MophoVoiceController.controller { (vc) in
      vc.prefixBlock = { [.layer, .i($0.index)] }
      let oscs = MophoVoiceController.oscsController(syncPanel: {
        $0.grid(panel: "sync", items: [[
          (PBCheckbox(label: "Sync 2→1"), [.sync]),
          (PBKnob(label: "Slop"), [.slop]),
          (PBKnob(label: "Bend"), [.bend]),
          ],[
          (PBKnob(label: "Mix"), [.mix]),
          (PBKnob(label: "Noise"), [.noise]),
          (PBKnob(label: "Feedbk Vol"), [.extAudio]),
          (PBKnob(label: "Feedbk Gain"), [.extAudio, .gain]),
          (PBSwitch(label: "Glide Mode"), [.glide]),
          ]])
      }, waveReset: true  )
      vc.addChild(oscs, withPanel: "oscs")

      vc.grid(panel: "vol", items: [[
        (PBKnob(label: "Voice Vol"), [.volume]),
      ],[
        (PBKnob(label: "Pan Sprd"), [.pan]),
      ]])

      let button = vc.createButton(titled: "Voice/Seq 1")
      vc.grid(panel: "menu", items: [[(button, nil)]])
      vc.addIndexChangeBlock { button.setTitleKeepingColor("Voice/Seq \($0 + 1)")}

      vc.addLayoutConstraints {
        $0.addRowConstraints([
          ("oscs",12), ("mods",4)
          ], options: [.alignAllTop], pinned: true, pinMargin: "", spacing: "-s1-")
        $0.addRowConstraints([
          ("fEnv", 7), ("aEnv",5)
          ], pinned: false, spacing: "-s1-")
        $0.addRowConstraints([
          ("lfos",8), ("env3", 6), ("vol", 2.5), ("push", 2)
        ], options: [.alignAllTop], pinned: true, pinMargin: "", spacing: "-s1-")
        $0.addRowConstraints([
          ("controls", 7.5), ("menu", 3),
        ], pinned: false, spacing: "-s1-")

        $0.addColumnConstraints([
          ("oscs",2),("fEnv",2),("lfos",4)
          ], pinned: true, pinMargin: "", spacing: "-s1-")
        $0.addColumnConstraints([
          ("env3",2),("controls",2),
          ], pinned: false, spacing: "-s1-")

        $0.addEqualConstraints(forItemKeys: ["aEnv","oscs"], attribute: .trailing)
        $0.addEqualConstraints(forItemKeys: ["aEnv","mods"], attribute: .bottom)
        $0.addEqualConstraints(forItemKeys: ["push","menu"], attribute: .trailing)
        $0.addEqualConstraints(forItemKeys: ["lfos","controls"], attribute: .bottom)
        $0.addEqualConstraints(forItemKeys: ["env3", "vol", "push"], attribute: .bottom)
      }
      
      let paths = TetraVoicePatch.params.keys.filter { $0.starts(with: [.layer, .i(0)]) }.map { $0.subpath(from: 2) }
      let patchBlock: (SysexPatch) -> [Int] = { [weak vc] (patch) in
         // don't change unison
         let unison = vc?.latestValue(path: [.unison]) ?? 0
         patch[[.layer, .i(0), .unison]] = unison
         return paths.map { patch[[.layer, .i(0)] + $0] ?? 0 }
      }
      vc.registerForEditMenu(button, bundle: (
        paths: { paths },
        pasteboardType: "com.cfshpd.TetraLayer",
        initialize: { patchBlock(FnSinglePatch<TetraVoicePatch>()) },
        randomize: { patchBlock(FnSinglePatch<TetraVoicePatch>.random()) }
      ))

      popover.sysexibleSelectedHandler = { [weak vc] (patch) in
        var values = [SynthPath:Int]()
        paths.forEach { values[$0] = patch[[.layer, .i(0)] + $0] ?? 0 }
        vc?.pushPatchChange(.paramsChange(SynthPathIntsMake(values)))
      }
      popover.sysexibleSaveHandler = { [weak vc] in
        let patch = FnSinglePatch<TetraVoicePatch>()
        let name = vc?.latestNameForFullPath([])
        patch.name = name != nil && name!.count > 0 ? name! : "Untitled"
        paths.forEach { patch[[.layer, .i(0)] + $0] = vc?.latestValue(path: $0) }
        return patch
      }
      vc.addMenuItem(title: "Load/Save...") { [weak vc] in
        vc?.showBrowserPopover(popover, forView: button)
      }

      
      vc.addColor(panels: ["vol"], level: 1)
      vc.addColor(panels: ["menu"], level: 1, clearBackground: true)
    }
  }
  
    
  static func seqController() -> FnPatchEditorController {
    ActivatedFnEditorController { (vc) in
      vc.prefixBlock = { [.layer, .i($0.index)] }
      vc.addChildren(count: 4, panelPrefix: "trk", setup: MophoSeqController.trackController(index:))

      vc.grid(panel: "ctrl", items: [
        [(PBCheckbox(label: "Sequencer"), [.seq, .on])],
        [(PBSelect(label: "Trigger"), [.seq, .trigger])],
        [(PBKnob(label: "Tempo"), [.tempo])],
        [(PBSelect(label: "Clock Divide"), [.clock, .divide])],
      ])
      
      vc.addLayoutConstraints { (layout) in
        layout.addRowConstraints([("ctrl", 1.5), ("trk0", 14.5)], options: [.alignAllTop], pinned: true, pinMargin: "", spacing: "-s1-")
        layout.addColumnConstraints([
          ("trk0",2), ("trk1",2), ("trk2",2), ("trk3",2),
        ], options: [.alignAllLeading, .alignAllTrailing], pinned: true, pinMargin: "", spacing: "-s1-")
        layout.addEqualConstraints(forItemKeys: ["ctrl", "trk1"], attribute: .bottom)
      }
      
      vc.addColorToAll()
    }
  }

}



struct TetraVoiceController {
  
  static func controller() -> FnPagedEditorController {
    ActivatedFnEditorController { (vc) in

      vc.switchCtrl = PBSegmentedControl(items: ["Voice A", "Seq A", "Voice B", "Seq B"])
      vc.grid(panel: "switch", pinMargin: "", items: [[(vc.switchCtrl, nil)]])

      let layerVC = layerController()
      vc.addChild(layerVC, withPanel: "layer")
      vc.addIndexChangeBlock { layerVC.index = $0 / 2 }
      
      vc.grid(panel: "knobs", items: [[
        (PBSelect(label: "Knob 1"), [.knob, .i(0)]),
        (PBSelect(label: "Knob 2"), [.knob, .i(1)]),
        (PBSelect(label: "Knob 3"), [.knob, .i(2)]),
        (PBSelect(label: "Knob 4"), [.knob, .i(3)]),
        ]])

      let split = PBKnob(label: "Split Pt")
      vc.grid(panel: "key", items: [[
        (PBSwitch(label: "Key Mode"), [.key, .mode]),
        (split, [.split, .pt]),
        ]])
      vc.addPatchChangeBlock(path: [.key, .mode]) {
        split.alpha = $0 == 2 ? 1 : 0.4
      }

      vc.addLayoutConstraints { (layout) in
        layout.addRowConstraints([("switch", 6), ("layer", 2), ("key", 2), ("knobs", 6)], pinned: true, spacing: "-s1-")
        layout.addRowConstraints([("page",1)], pinned: true, spacing: "-s1-")
        layout.addColumnConstraints([
          ("switch",1),("page",8),
        ], pinned: true, spacing: "-s1-")
      }
      
      vc.addColor(panels: ["switch", "layer"], level: 1, clearBackground: true)
      vc.addColor(panels: ["key", "knobs"], level: 1)
      
      vc.setControllerLogic([
        [.voice] : voiceController,
        [.seq] : seqController,
      ], indexMap: 2.map { [[.voice, .i($0)], [.seq, .i($0)]] }.reduce([], +))
    }
  }
  
  static func layerController() -> FnPatchEditorController {
    ActivatedFnEditorController { vc in
      vc.prefixBlock = { [.layer, .i($0.index)] }
      
      let button = vc.createButton(titled: "Layer A")
      vc.grid(items: [[(button, nil)]])
      vc.addIndexChangeBlock {
        button.setTitleKeepingColor("Layer \(["A", "B"][$0 % 2])")
      }

      let paths = TetraVoicePatch.params.keys.filter { $0.starts(with: [.layer, .i(0)]) }.map { $0.subpath(from: 2) }
      let patchBlock: (SysexPatch) -> [Int] = { (patch) in
         paths.map { patch[[.layer, .i(0)] + $0] ?? 0 }
      }
      vc.registerForEditMenu(button, bundle: (
        paths: { paths },
        pasteboardType: "com.cfshpd.TetraLayer",
        initialize: { patchBlock(FnSinglePatch<TetraVoicePatch>()) },
        randomize: { patchBlock(FnSinglePatch<TetraVoicePatch>.random()) }
      ))
    }
  }
  
  static func voiceController() -> FnPatchEditorController {
    MophoVoiceController.controller { (vc) in
      vc.prefixBlock = { [.layer, .i($0.index)] }
      let oscs = MophoVoiceController.oscsController(syncPanel: {
        $0.grid(panel: "sync", items: [[
          (PBCheckbox(label: "Sync 2→1"), [.sync]),
          (PBKnob(label: "Slop"), [.slop]),
          (PBKnob(label: "Bend"), [.bend]),
          (PBSelect(label: "Unison Assign"), [.keyAssign]),
          ],[
          (PBKnob(label: "Mix"), [.mix]),
          (PBKnob(label: "Noise"), [.noise]),
          (PBKnob(label: "Feedbk Vol"), [.extAudio]),
          (PBKnob(label: "Feedbk Gain"), [.extAudio, .gain]),
          (PBSwitch(label: "Glide Mode"), [.glide]),
          ]])
      }, waveReset: true  )
      vc.addChild(oscs, withPanel: "oscs")

      let uniMode = PBSelect(label: "Unison Mode")
      vc.grid(panel: "vol", items: [[
        (PBKnob(label: "Voice Vol"), [.volume]),
        (PBKnob(label: "Pan Sprd"), [.pan]),
      ],[
        (PBCheckbox(label: "Unison"), [.unison]),
        (uniMode, [.unison, .mode]),
        ]])
      vc.dims(view: uniMode, forPath: [.unison])

      let arpMode = PBSelect(label: "Arp Mode")
      vc.grid(panel: "arp", items: [[
        (PBCheckbox(label: "Arp"), [.arp, .on]),
        (PBKnob(label: "Tempo"), [.tempo]),
      ],[
        (arpMode, [.arp, .mode]),
        (PBSelect(label: "Clock Divide"), [.clock, .divide]),
      ]])
      vc.dims(view: arpMode, forPath: [.arp, .on])

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
          ("arp", 3), ("controls", 7.5)
        ], pinned: false, spacing: "-s1-")

        $0.addColumnConstraints([
          ("oscs",2),("fEnv",2),("lfos",4)
          ], pinned: true, pinMargin: "", spacing: "-s1-")
        $0.addColumnConstraints([
          ("env3",2),("arp",2),
          ], pinned: false, spacing: "-s1-")

        $0.addEqualConstraints(forItemKeys: ["aEnv","oscs"], attribute: .trailing)
        $0.addEqualConstraints(forItemKeys: ["aEnv","mods"], attribute: .bottom)
        $0.addEqualConstraints(forItemKeys: ["push","controls"], attribute: .trailing)
        $0.addEqualConstraints(forItemKeys: ["lfos","arp"], attribute: .bottom)
        $0.addEqualConstraints(forItemKeys: ["env3", "vol", "push"], attribute: .bottom)
      }
      
      vc.addColor(panels: ["vol", "arp"], level: 1)
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


struct MophoSeqController {
  
  static func controller() -> FnPatchEditorController {
    ActivatedFnEditorController { (vc) in
      vc.addChildren(count: 4, panelPrefix: "trk", setup: trackController(index:))

      vc.addLayoutConstraints { (layout) in
        layout.addGridConstraints([
          [("trk0",2)], [("trk1",2)], [("trk2",2)], [("trk3",2)]
        ], pinMargin: "", spacing: "-s1-")
      }
      
      vc.addColorToAll()
    }
  }
  
  static func trackController(index: Int) -> FnPatchEditorController {
    ActivatedFnEditorController { (vc) in
      vc.prefixBlock = { _ in [.seq, .i(index)] }
      
      let label = LabelItem(text: "Sequence \(index + 1)", gridWidth: 2, textAlignment: .center)
      vc.view.addSubview(label)
      
      let destDropdown = PBSelect(label: "Destination")
      vc.view.addSubview(destDropdown)
      vc.addBlocks(control: destDropdown, path: [.dest])
      
      let editButton = vc.createMenuButton(titled: "Edit")
      vc.registerForEditMenu(editButton, bundle: (
        paths: { (0..<16).map { [.step, .i($0)] } },
        pasteboardType: "com.cfshpd.MophoSeqTrack",
        initialize: { return [Int](repeating: 0, count: 16) },
        randomize: { (0..<16).map { _ in (0...127).random()! } }
      ))
      vc.view.addSubview(editButton)
      
      var items: [(String,CGFloat)] = [("label",3)]
      
      for i in 0..<16 {
        let key  = "Step\(i)"
        let s = MophoSeqSlider(label: "")
        vc.view.addSubview(s)
        vc.addLayoutConstraints { (layout) in
          layout.addView(s, forLayoutKey: key)
        }
        s.tag = i
        vc.addBlocks(control: s, path: [.step, .i(i)])
        items.append((key,1))
      }
      
      vc.addLayoutConstraints { (layout) in
        layout.addView(label, forLayoutKey: "label")
        layout.addView(destDropdown, forLayoutKey: "Dest")
        layout.addView(editButton, forLayoutKey: "edit")

        layout.addRowConstraints(items, options: [.alignAllTop], pinned: true, spacing: "-s1-")
        layout.addColumnConstraints([
          ("label",2),("Dest",2),("edit",2)
          ], options: [.alignAllLeading, .alignAllTrailing], pinned: true)
        layout.addEqualConstraints(forItemKeys: (0...16).map { $0 == 0 ? "edit" : "Step\($0-1)" }, attribute: .bottom)
      }
    }
  }
}


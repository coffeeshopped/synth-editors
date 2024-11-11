//
//  MicroQDrumController.swift
//  Blofeld
//
//  Created by Chadwick Wood on 10/19/21.
//  Copyright © 2021 Coffeeshopped LLC. All rights reserved.
//

import Foundation
import PBCore

struct MicroQDrumController {
  
  static func controller() -> FnPagedEditorController {
    ActivatedFnEditorController { vc in
      let labeledNoteSelect = LabeledGridSelectControl(label: "Play")
      let noteSelect = labeledNoteSelect.gridControl
      noteSelect.columnCount = 16
      noteSelect.options = OptionsParam.makeOptions((1...32).map { "\($0)" })
      noteSelect.value = 0
      vc.addCommandBlock(control: noteSelect) { vc in
        guard let note = vc.latestValue(path: [.part, .i(noteSelect.value), .key]) else { return }
        let n = UInt8(note)
        vc.midiCommand(.sendMsg(.noteOn(channel: 0, note: n, velocity: 100)))
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
          vc.midiCommand(.sendMsg(.noteOff(channel: 0, note: n, velocity: 100)))
        }
      }

      vc.grid(panel: "note", items: [[(labeledNoteSelect, nil)]])
      
      vc.switchCtrl = PBSegmentedControl(items: ["Drum 1–12", "Drum 13–24", "Drum 25–32", "FX", "Arp"])
      vc.grid(panel: "switch", items: [[(vc.switchCtrl, nil)]])
            
      vc.addLayoutConstraints { layout in
        layout.addGridConstraints([
          (row: [("note", 1)], height: 2),
          (row: [("switch", 9)], height: 1),
          (row: [("page", 1)], height: 6),
        ], spacing: "-s1-")
      }
      
      vc.setControllerLogic([
        [.normal] : mainController,
        [.arp] : arpController,
        [.fx] : fxController,
      ], indexMap: 3.map { [.normal, .i($0)] } + [[.fx], [.arp]])
      
      vc.addColor(panels: ["note", "switch"], clearBackground: true)
    }
  }
    
  static func mainController() -> FnPatchEditorController {
    ActivatedFnEditorController { vc in
      let parts = vc.addChildren(count: 12, panelPrefix: "part") { index in
        ActivatedFnEditorController { sub in
          sub.prefixBlock = { [.part, .i($0.index)] }
          let sound = PBSelect(label: "Sound")
          sub.addIndexChangeBlock { [weak sub] in
            sound.label = "Sound \($0 + 1)"
            sub?.view.isHidden = $0 >= 32
          }
          sub.grid(items: [[
            (sound, [.number]),
            (PBSwitch(label: "Bank"), [.bank]),
            (PBSwitch(label: "Output"), [.out]),
            (PBKnob(label: "Volume"), [.volume]),
            (PBKnob(label: "Transpose"), [.transpose]),
            (PBKnob(label: "Pan"), [.pan]),
            (PBKnob(label: "Key"), [.key]),
          ]])
          
          sub.bankSelectOptions(control: sound, path: [.bank]) {
            [.patch, .i($0), .name] as SynthPath
          }
          
          sub.addColor(view: sub.view)
        }
      }
      vc.addIndexChangeBlock { index in
        parts.enumerated().forEach { $0.element.index = index * 12 + $0.offset }
      }
      
      vc.addLayoutConstraints { layout in
        layout.addGridConstraints(
          (0..<6).map { row in
            (0..<2).map { col in ("part\(row * 2 + col)", 1) }
          }
        , pinMargin: "", spacing: "-s1-")
      }
    }
  }
  
  static func arpController() -> FnPatchEditorController {
    ActivatedFnEditorController { vc in
      MicroQVoiceController.arpControllerSetup(vc)
      
      vc.addLayoutConstraints { layout in
        layout.addGridConstraints([
          [("mode", 1)],
          [("step", 1)],
          [("length", 1)],
          [("time", 1)],
          [("accent", 1)],
          [("glide", 1)],
        ], pinMargin: "", spacing: "-s1-")
      }
      
      vc.addColorToAll()
    }
  }
  
  static func fxController() -> FnPatchEditorController {
    ActivatedFnEditorController { vc in
      vc.addChildren(count: 2, panelPrefix: "fx") { MicroQVoiceController.fxController(index: $0) }
      vc.createPanels(forKeys: ["top", "bottom"])
      vc.addLayoutConstraints { layout in
        layout.addGridConstraints([
          (row: [("fx0", 1)], height: 1),
          (row: [("fx1", 1)], height: 1),
          (row: [("bottom", 1)], height: 4),
        ], pinMargin: "", spacing: "-s1-")
      }
      vc.addColor(panels: ["fx0", "fx1"])
    }
  }
  
}

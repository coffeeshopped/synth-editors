//
//  MicroQMultiController.swift
//  Blofeld
//
//  Created by Chadwick Wood on 10/19/21.
//  Copyright © 2021 Coffeeshopped LLC. All rights reserved.
//

import Foundation
import PBCore

struct MicroQMultiController {
  
  static func controller() -> FnPagedEditorController {
    ActivatedFnEditorController { vc in
      vc.switchCtrl = PBSegmentedControl(items: ["Main 1–8", "Main 9–16"])
      vc.grid(panel: "switch", items: [[(vc.switchCtrl, nil)]])
      
      vc.grid(panel: "ctrl", items: [[
        (PBKnob(label: "Volume"), [.volume]),
        (PBSelect(label: "Ctrl W"), [.ctrl, .i(0)]),
        (PBSelect(label: "Ctrl X"), [.ctrl, .i(1)]),
        (PBSelect(label: "Ctrl Y"), [.ctrl, .i(2)]),
        (PBSelect(label: "Ctrl Z"), [.ctrl, .i(3)]),
      ]])
      
      vc.addLayoutConstraints { layout in
        layout.addGridConstraints([
          (row: [("switch", 9), ("ctrl", 7)], height: 1),
          (row: [("page", 1)], height: 8),
        ], spacing: "-s1-")
      }
      
      vc.setControllerLogic([
        [.normal] : mainController
      ], indexMap: 2.map { [.normal, .i($0)] })
      
      vc.addColor(panels: ["switch"], clearBackground: true)
      vc.addColor(panels: ["ctrl"])
    }
  }
  
  static func mainController() -> FnPatchEditorController {
    ActivatedFnEditorController { vc in
      let parts = vc.addChildren(count: 8, panelPrefix: "part") { index in
        ActivatedFnEditorController { sub in
          sub.prefixBlock = { [.part, .i($0.index)] }
          let status = PBSwitch(label: "Part ?")
          let sound = PBSelect(label: "Sound")
          sub.addIndexChangeBlock {
            sound.label = "Part \($0 + 1)"
            status.label = "Part \($0 + 1)"
          }
          sub.grid(items: [[
            (sound, [.number]),
          ],[
            (PBSwitch(label: "Bank"), [.bank]),
            (PBKnob(label: "Channel"), [.channel]),
          ],[
            (PBKnob(label: "Volume"), [.volume]),
            (PBKnob(label: "Pan"), [.pan]),
          ],[
            (PBKnob(label: "Transpose"), [.transpose]),
            (PBKnob(label: "Detune"), [.detune]),
          ],[
            (PBSelect(label: "Output"), [.out]),
          ],[
            (PBKnob(label: "Velo Lo"), [.velo, .lo]),
            (PBKnob(label: "Velo Hi"), [.velo, .hi]),
          ],[
            (PBKnob(label: "Key Lo"), [.key, .lo]),
            (PBKnob(label: "Key Hi"), [.key, .hi]),
          ],[
            (status, [.on]),
          ]])
          
          sub.bankSelectOptions(control: sound, path: [.bank]) {
            switch $0 {
            case 0...2:
              return [.patch, .i($0), .name] as SynthPath
            case 4:
              return [.rhythm, .name] as SynthPath
            default:
              return nil
            }
          }
          
          sub.dims(forPath: [.on])
          
          sub.addColor(view: sub.view)
        }
      }
      vc.addIndexChangeBlock { index in
        parts.enumerated().forEach { $0.element.index = index * 8 + $0.offset }
      }
      
      vc.addLayoutConstraints { layout in
        layout.addGridConstraints([(0..<8).map { ("part\($0)", 1) }], pinMargin: "", spacing: "-s1-")
      }
    }
  }
  
  static func rangeController() -> FnPatchEditorController {
    ActivatedFnEditorController { vc in
      vc.addChildren(count: 16, panelPrefix: "part") { index in
        ActivatedFnEditorController { sub in
          sub.prefixBlock = { _ in [.part, .i(index)] }
          sub.grid(items: [[
            (LabelItem(text: "\(index + 1)", textAlignment: .center), nil),
          ],[
            (LabelItem(text: "\(index + 1)", textAlignment: .center), nil),
          ]])
          
          sub.addColor(view: sub.view)
        }
      }
      
      vc.addLayoutConstraints { $0.oneRowGrid(count: 16, panelPrefix: "part", pinMargin: "") }
    }
  }
  
  static func rcvController() -> FnPatchEditorController {
    ActivatedFnEditorController { vc in
      vc.addChildren(count: 16, panelPrefix: "part") { index in
        ActivatedFnEditorController { sub in
          sub.prefixBlock = { _ in [.part, .i(index)] }
          sub.grid(items: [[
            (LabelItem(text: "\(index + 1)", textAlignment: .center), nil),
          ],[
            (PBCheckbox(label: "Bend"), [.bend]),
          ],[
            (PBCheckbox(label: "Mod Wh"), [.modWheel]),
          ],[
            (PBCheckbox(label: "AfterT"), [.aftertouch]),
          ],[
            (PBCheckbox(label: "Sustain"), [.sustain]),
          ],[
            (PBCheckbox(label: "Button 2"), [.pushIt]),
          ],[
            (PBCheckbox(label: "Pgm Ch"), [.pgmChange]),
          ],[
            (LabelItem(text: "\(index + 1)", textAlignment: .center), nil),
          ]])
          
          sub.addColor(view: sub.view)
        }
      }
      
      vc.addLayoutConstraints { $0.oneRowGrid(count: 16, panelPrefix: "part", pinMargin: "") }
    }
  }
  
}

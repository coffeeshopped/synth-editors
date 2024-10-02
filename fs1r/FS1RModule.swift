//
//  FS1RModule.swift
//  Patch Base
//
//  Created by Chadwick Wood on 6/11/18.
//  Copyright © 2018 Coffeeshopped LLC. All rights reserved.
//


import PBAPI
import YamahaCore

extension FS1R {
  
  public enum Module {
    
    public static let truss = BasicModuleTruss(Editor.truss, manu: Manufacturer.yamaha, model: "FS1R", subid: "fs1r", sections: sections, dirMap: [
      [.part] : "Patch",
      [.bank, .voice, .extra] : "Voice Bank",
    ], colorGuide: ColorGuide([
        "#009f63",
        "#ec421e",
        "#717efe",
        "#79f11e",
        ]), indexPath: IndexPath(item: 0, section: 1))
    
    static let sections: [ModuleTrussSection] = [
      .first([
        .global(Global.Controller.controller),
        .perf(Perf.Controller.controller),
        .voice("Fseq", path: [.fseq], PatchController.patch([])),
        .fullRef(),
        ]),
      .basic("Parts", .perfParts(4, { "Part \($0 + 1)" }, Voice.Controller.controller)),
      .banks([
        .bank("Voice Bank", [.bank, .voice]),
        .bank("Perf Bank", [.bank, .perf]),
        .bank("Fseq Bank", [.bank, .fseq]),
        ]),
      .backup,
    ]
    
//    public static func onEditorLoad(_ module: TemplatedModule) {
//      module.templatedEditor.patchChangesOutput(forPath: [.global])?.subscribe(onNext: { [unowned module] (change, patch) in
//        let memory: Int
//        switch change {
//        case .replace(let p):
//          memory = p[[.memory]] ?? 0
//        case .paramsChange(let values):
//          guard let mem = values[[.memory]] else { return }
//          memory = mem
//        case .noop: // load!
//          guard let p = patch else { return }
//          memory = p[[.memory]] ?? 0
//        default:
//          return
//        }
//
//        guard memory != module.templatedEditor.getExtra([.memory]) else { return }
//
//        module.templatedEditor.setExtra([.memory], value: memory)
//
//        let paths: [SynthPath] = [[.bank, .voice], [.backup]]
//        paths.forEach {
//          module.reinitWindowController(forSynthPath: $0)
//        }
//
//      }).disposed(by: module.templatedEditor.disposeBag)
//    }
    
    
  }
  
}

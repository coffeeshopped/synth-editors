
enum XV {
  
  static let sysexWerk = RolandSysexTrussWerk(modelId: [0x00, 0x10], addressCount: 4)
  
  static func multiPack2(_ byte: RolandAddress) -> PackIso { Roland.msbMultiPackIso(2)(byte) }
  static func multiPack4(_ byte: RolandAddress) -> PackIso { Roland.msbMultiPackIso(4)(byte) }
  
  static func mapItems(global: AnyRolandSysexTrussWerk, perf: AnyRolandSysexTrussWerk, partCount: Int, voice: AnyRolandSysexTrussWerk, rhythm: RolandMultiPatchTrussWerk, voiceBank: AnyRolandSysexTrussWerk, perfBank: AnyRolandSysexTrussWerk, rhythmBank: AnyRolandSysexTrussWerk, fx: AnyRolandSysexTrussWerk) -> [RolandEditorTrussWerk.MapItem] {
    let parts: [RolandEditorTrussWerk.MapItem] = partCount.map {
      let patchAdd: RolandAddress = 0x11000000 + ($0 * RolandAddress(0x200000))
      let rhythmAdd: RolandAddress = patchAdd + 0x100000
      return [
        ([.part, .patch, .i($0)], patchAdd, voice),
        ([.part, .rhythm, .i($0)], rhythmAdd, rhythm),
      ]
    }.reduce([], +)
    
    return [
      ([.global], global.start, global),
      ([.perf], perf.start, perf),
      ([.patch], voice.start, voice),
      ([.rhythm], rhythm.start, rhythm),
      ([.bank, .patch, .i(0)], voiceBank.start, voiceBank),
      ([.bank, .perf, .i(0)], perfBank.start, perfBank),
      ([.bank, .rhythm, .i(0)], rhythmBank.start, rhythmBank),
      ([.fx], fx.start, fx), // for popover
    ] + parts
  }
    
  static func editorTruss(_ name: String, global: AnyRolandSysexTrussWerk, perf: RolandMultiPatchTrussWerk, partCount: Int, voice: RolandMultiPatchTrussWerk, rhythm: RolandMultiPatchTrussWerk, voiceBank: AnyRolandSysexTrussWerk, perfBank: AnyRolandSysexTrussWerk, rhythmBank: AnyRolandSysexTrussWerk, fx: AnyRolandSysexTrussWerk) -> BasicEditorTruss {
    
    let map = mapItems(global: global, perf: perf, partCount: partCount, voice: voice, rhythm: rhythm, voiceBank: voiceBank, perfBank: perfBank, rhythmBank: rhythmBank, fx: fx)
    let werk = sysexWerk.editorWerk(name, map: map)
    
    let backupTruss = werk.backupTruss(sysexWerk, start: 0x0, paths: [
      [.global],
      [.bank, .patch, .i(0)],
      [.bank, .perf, .i(0)],
      [.bank, .rhythm, .i(0)],
    ])
    
    let fullRefTruss = XV.Perf.Full.refTruss(partCount, perf: perf, voice: voice, rhythm: rhythm)

    var t = BasicEditorTruss(werk.displayId, truss: [([.deviceId], RolandDeviceIdSettingsTruss)] + werk.sysexMap() + [
      ([.fx], fx.anyTruss),
      ([.extra, .perf], fullRefTruss),
      ([.backup], backupTruss),
    ])
    t.fetchTransforms = werk.defaultFetchTransforms()
    
    t.extraParamOuts = [
      ([.perf], .bankNames([.bank, .patch, .i(0)], [.patch, .name])),
      ([.perf], .bankNames([.bank, .rhythm, .i(0)], [.rhythm, .name])),
    ]
    //    + 15.map {
    //      let i = indexToPathPart($0)
    //      return ([.part, .i(i)], .patchOut([.perf], { change, patch in
    //        var out = SynthPathParam()
    //        if let v = change.value([.common, .fx, .src]) {
    //          out[[.common, .fx, .src]] = RangeParam(parm: v)
    //        }
    //        return out
    //      }))
    //    }
    t.midiOuts = werk.midiOuts()
    
    t.midiChannels = [
      [.patch] : .patch([.global], [.common, .patch, .channel]),
      [.rhythm] : .patch([.global], [.common, .patch, .channel]),
    ] <<< partCount.dict {
      [[.part, .i($0)] : .patch([.perf], [.part, .i($0), .channel])]
    }
    
    t.pathTransforms = partCount.dict { part in
      [
        [.part, .i(part)] : .patchParam([.perf], [.part, .i(part), .bank, .hi], { hi in
          [.part, Perf.partType(forHi: hi), .i(part)]
        })
      ]
    }

    let userXform: MemSlot.Transform = .user({ "US:\(($0 + 1).zPad(3))" })
    t.slotTransforms = [
      [.bank, .patch, .i(0)] : userXform,
      [.bank, .perf, .i(0)] : userXform,
      [.bank, .rhythm, .i(0)] : userXform,
    ]

    return t
  }
  

  //    static func transformMidiCommand(_ editor: TemplatedEditor, forPath path: SynthPath, _ command: RxMidi.Command) -> RxMidi.Command {
  //      guard case let .sendMsg(msg) = command else { return command }
  //      let ch = UInt8(editor.midiChannel(forPath: path))
  //      return .sendMsg(msg.channel(ch))
  //    }
  //    static var compositeMap: [SynthPath : MultiSysexTemplate.Type] {
  //      [
  //        [.extra, .perf] : FullPerfPatch.self,
  //        [.backup] : Backup.self,
  //      ]
  //    }
  //
  //
  //    static func patchInfo(_ editor: TemplatedEditor, forPath path: SynthPath) -> (slot: String, name: String)? {
  //      let sp = path.pathPlusEndex()
  //      var slot: String?
  //      var name: String?
  //      switch sp.path.first {
  //      case .bank: // .bank, .patch, .i(0)
  //        let partType = sp.path[1]
  //        slot = "US"
  //        name = editor.bank(forPath: [.bank, partType, .i(0)])?[sp.endex].name
  //      default:
  //        let partType = sp.path.first
  //        let voicePresetOptionMap = partType == .patch ? FullPerfPatch.Perf.PartPatch.voicePresetOptionMap : FullPerfPatch.Perf.PartPatch.rhythmPresetOptionMap
  //        switch sp.path[1] {
  //        case .int:
  //          switch sp.path[2] {
  //          case .gm2:
  //            slot = "GM"
  //            name = voicePresetOptionMap[[.gm2]]?[sp.endex]
  //          case .cart:
  //            slot = "CA"
  //          case .preset:
  //            let i = sp.path.i(3) ?? 0
  //            let banks = ["A", "B", "C", "D", "E", "F", "G", "H"]
  //            if i < banks.count {
  //              slot = "P\(banks[i])"
  //            }
  //            name = voicePresetOptionMap[sp.path.subpath(from: 2)]?[sp.endex]
  //          default:
  //            break
  //          }
  //        case .srjv, .srx:
  //          let boardIndex = sp.path.i(2) ?? 0
  //          let board = (sp.path[1] == .srjv ? SRJVBoard.boards : SRXBoard.boards)[boardIndex]
  //          let slotPrefix = sp.path[1] == .srjv ? "SRJV" : "SRX"
  //          slot = "\(slotPrefix)\(boardIndex)"
  //          name = (partType == .patch ? board?.patchOptions : board?.rhythmOptions)?[sp.endex]
  //        default:
  //          break
  //        }
  //      }
  //
  //      return (slot: "\(slot ?? "??")-\(sp.endex + 1)", name: name ?? "?")
  //    }
  
  struct CtrlConfig {
    let waveGroupOptions: [Int:String]
    let partConfig: Perf.Part.Config
    let perfTruss: any PatchTruss
    let voiceTruss: any PatchTruss
    let fxTruss: any PatchTruss
    let partCount: Int
    
    // only 5050 has the 2 extra FX chunks
    var is5050: Bool { perfTruss.parm([.fx, .i(2), .type]) != nil }
    
    // only 5080 has > 16 parts
    var is5080: Bool { perfTruss.parm([.part, .i(30), .out, .assign]) != nil }
    
    var hasVibAndDecay: Bool { perfTruss.parm([.part, .i(0), .decay]) != nil }
    
    var hasScaleTune: Bool { perfTruss.parm([.part, .i(0), .scale, .tune, .i(0)]) != nil }
  }
  
  static func moduleTruss(_ editorTruss: EditorTruss, subid: String, sections: [ModuleTrussSection], config: CtrlConfig) -> BasicModuleTruss {
    
    let vc: ModuleTrussCore.ViewControllerFn = { module, indexPath in
      guard indexPath.section == 1, indexPath.row > 1 else {
        return sections[indexPath.section].items[indexPath.row].controller
      }

      let perf = module.anySynthEditor.patch(forPath: [.perf])
      let path = module.synthPath(forIndexPath: indexPath) ?? []
      let t = XV.Perf.partType(forHi: perf?[path + [.bank, .hi]] ?? 0)
      if t == .patch {
        return .voice(XV.Voice.Controller.controller(config: config))
      }
      else {
        return .custom(XV.Rhythm.Controller.controller(config: config))
      }
    }
    
    var truss = BasicModuleTruss(editorTruss, manu: Manufacturer.roland, model: editorTruss.displayId, subid: subid, sections: sections, viewController: vc, dirMap: [
      [.part, .patch] : "Patch",
      [.part, .rhythm] : "Rhythm*",
    ], colorGuide: ColorGuide([
      "#db8a2d",
      "#15a9e8",
      "#ec9a2c",
      "#0ba6ff",
    ]), indexPath: IndexPath(item: 2, section: 0))
    
    
    truss.commandEffects = config.partCount.map { part in
      .patchParamChange([.perf], [.part, .i(part), .bank, .hi], { hi in
        // TODO: ideally we would check if the value had *changed*
//        let partType = XV.Perf.partType(forHi: hi)
        return [.invalidateWindow([.part, .i(part)])]
      })
    }
    
    return truss
  }
  
  static func sections(config: CtrlConfig, global: PatchController) -> [ModuleTrussSection] {
    return [
      .first([
        .deviceId(),
        .global(global),
        .voice("Patch", XV.Voice.Controller.controller(config: config)),
        .custom("Rhythm", [.rhythm], XV.Rhythm.Controller.controller(config: config)),
      ]),
      .basic("Performance", [
        .fullRef(),
        .perf(XV.Perf.Controller.controller(config: config)),
      ] + config.partCount.map {
        .voice("Part \($0 + 1)", path: [.part, .i($0)], XV.Voice.Controller.controller(config: config))
      }),
      .banks([
        .bank("Patch Bank", [.bank, .patch, .i(0)]),
        .bank("Rhythm Bank", [.bank, .rhythm, .i(0)]),
        .bank("Perf Bank", [.bank, .perf, .i(0)]),
      ]),
      .backup,
    ]
  }
  
}

-- require('/Users/chadwickwood/Code/patch-base/js/someother.js');
-- 
function createModule ()
  return "wow"
end

-- print(createModule())


globalBlock = function ()
  return function (module)
    return "HERE I AM"
  end
end

FS1RModule = {
  manu = "Yamaha",
  model = "FS1R",
  modelId = "fs1r",
  
  colorGuide = {
    "#009f63",
    "#ec421e",
    "#717efe",
    "#79f11e",
  },
  
  defaultIndexPath = { 0, 1 }, --- should this be 1-indexed, lua-style?

  sections = {
    { null, {
      { "Global", "global", globalBlock},
      { "Performance", "perf", globalBlock},
      { "Fseq", "fseq", globalBlock},
      { "Full Perf", "extra/perf", globalBlock},
    }},
    -- ("Parts", [
    --   ("Part 1", [.part, .i(0)], voiceBlock),
    --   ("Part 2", [.part, .i(1)], voiceBlock),
    --   ("Part 3", [.part, .i(2)], voiceBlock),
    --   ("Part 4", [.part, .i(3)], voiceBlock),
    --   ]),
    -- ("Banks", [
    --   ("Voice Bank", [.bank, .voice], defaultBankEditorBlock()),
    --   ("Perf Bank", [.bank, .perf], defaultBankEditorBlock()),
    --   ("Fseq Bank", [.bank, .fseq], defaultBankEditorBlock()),
    --   ]),
    -- ("Backup", items: [
    --   ("Backup", path: [.backup], controllerBlock: defaultBackupEditorBlock()),
    --   ]),
  },
  
  directory = function (templateType)
    local f = {
      ["FS1RFseqPatch"] = "Fseqs",
      ["FS1RFseqBank"] = "Fseqs Banks",
    }
    return f[templateType]
  end,

  onEditorLoad = function (module) {
    module.templatedEditor.patchChangesOutput(forPath: [.global])?.subscribe(onNext: { [unowned module] (change, patch) in
      let memory: Int
      switch change {
      case .replace(let p):
        memory = p[[.memory]] ?? 0
      case .paramsChange(let values):
        guard let mem = values[[.memory]] else { return }
        memory = mem
      case .noop: // load!
        guard let p = patch else { return }
        memory = p[[.memory]] ?? 0
      default:
        return
      }

      guard memory != module.templatedEditor.getExtra([.memory]) else { return }

      module.templatedEditor.setExtra([.memory], value: memory)

      let paths: [SynthPath] = [[.bank, .voice], [.backup]]
      paths.forEach {
        module.reinitWindowController(forSynthPath: $0)
      }

    }).disposed(by: module.templatedEditor.disposeBag)
  }

}

print(FS1RModule.directory("OtherPatch"))

--   // typealias EditorTemplate = FS1REditor
--   
--   static var voiceBlock: SynthModuleTemplateControllerBlock {
--     return { _ in
--       let keysController = BasicKeysViewController.defaultInstance()
--       let mainController = FS1RVoiceController.controller()
--       return PlayAdornedController(mainController: mainController, playController: keysController)
--     }
--   }
-- 
--   static var perfBlock: SynthModuleTemplateControllerBlock {
--     return { _ in
--       let keysController = BasicKeysMIDIViewController.defaultInstance()
--       let mainController = FS1RPerfController.controller()
--       return PlayAdornedController(mainController: mainController, playController: keysController)
--     }
--   }
-- 
--   static var fseqBlock : SynthModuleTemplateControllerBlock {
--     return { _ in
--       let keysController = BasicKeysViewController.defaultInstance()
--       let mainController = FS1RFseqController.controller()
--       return PlayAdornedController(mainController: mainController, playController: keysController)
--     }
--   }
-- 
--   

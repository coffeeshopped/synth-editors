
function SynthModuleBlockify (f)
  return function (module) f() end
end

MophoMainController = {}

local defaultVoiceBlock = function(f) end
local defaultBankEditorBlock = function(f) end

MophoModule = {
  -- public typealias EditorTemplate = MophoEditor
  
  manu = "DSI",
  model = "Mopho",
  modelId = "mopho",
  
  colorGuide = {
    "#FDC63F",
    "#4080ff",
    "#a3e51e",
    "#ff6347",
  },

  makeSections = function (global, main)
    return {
      {nil, {
        {"Global", "global", global},
        {"Voice", "patch", defaultVoiceBlock(main)},
      }},
      {"Voice Bank", {
        {"Bank 1", "bank/i(0)", defaultBankEditorBlock()},
        {"Bank 2", "bank/i(1)", defaultBankEditorBlock()},
        {"Bank 3", "bank/i(2)", defaultBankEditorBlock()},
      }},
    }
  end,
  
  directory = function (templateType)
    local f = {
      ["MophoGlobalPatch"] = "Global",
      ["MophoVoicePatch"] = "Patches",
      ["MophoVoiceBank"] = "Banks",
    }
    return f[templateType]
  end,
}

MophoModule.sections = MophoModule.makeSections(SynthModuleBlockify(MophoGlobalController), SynthModuleBlockify(MophoMainController.controller))



-- public struct MophoKeyModule : TypedSynthModuleTemplate {
--   public typealias EditorTemplate = MophoKeyEditor
-- 
--   public static var manu: Manufacturer = .dsi
--   public static var model: String = "Mopho Keyboard"
--   public static var modelId: String = "m".o.p.h.o.k.e.y
--   
--   public static let colorGuide = MophoModule.colorGuide
--   
--   public static var sections: [SynthModuleTemplateSection] = MophoModule.makeSections(global: { _ in MophoKeysGlobalController() }, main: { _ in MophoKeysMainController.controller() })
-- 
--   public static func directory(templateType: SysexTemplate.Type) -> String? {
--     MophoModule.directory(templateType: templateType)
--   }
--   
-- }

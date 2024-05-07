require('/core/NumberUtils.js')
require('/core/ArrayUtils.js')

class RxMidi {
  static FetchCommand = class { 
    static request(bytes) {
      return bytes
    }
  }
}

function channel(editor) {
  // value of 0 == global
  let ch = editor.patch(["global"])?.get(["channel"]) ?? 0
  return ch > 0 ? ch - 1 : 0
}

function nrpnData(channel, index, value) {
  return [
    ["cc", channel, 0x63, index.bit(7)],
    ["cc", channel, 0x62, index.bits(0, 6)],
    ["cc", channel, 0x06, value.bit(7)],
    ["cc", channel, 0x26, value.bits(0, 6)],
    ["cc", channel, 0x25, 0x3f],
    ["cc", channel, 0x24, 0x3f],
  ]
}

function nrpnOut(editor, path, patchType, nameParmOffset) {
  return {
    path: path,
    outType: "patchChange",
    throttle: 100, 
    paramTransform: function(bytes, path, value) {
      // TODO: get truss for path from editor to cache params?
      let param = patchType.params[path.join("/")]
      if (!param) { return null }
      let ch = channel(editor)
      return nrpnData(ch, param.p, value).map(msg => [msg, 0.03])
    },
    patchTransform: function(bytes) {
      return [[["sx", patchType.fileData(bytes)], 0]]
    },
    nameTransform: function(bytes, path, name) {
      if (patchType.nameByteRange.length <= 0) { return null }
      // let parmOffset = patchType == TetraComboPatch ? 512 : 0
      let ch = channel(editor)
      return patchType.nameByteRange.rangeMap(
        i => nrpnData(ch, i + nameParmOffset, bytes[i])
      ).flat().map(msg => [msg, 0.01])
    },
  }
}

function bankOut(editor, path, patchType, bankIndex) {
  return {
    path: path,
    outType: "partialBank",
    patchTransform: function(bytes, location) {
      return [[["sx", patchType.sysexWriteData(bytes, bankIndex, location)], 0]]
    }
  }
}

function MophoTypeEditor(GlobalPatch, VoicePatch, VoiceBank) {
  return class {
  
    static sysexMap = (function() {
      return [
        [["global"], GlobalPatch],
        [["patch"], VoicePatch],
      ].concat((3).map(i => [["bank", i], VoiceBank]))
    })()

    static compositeMap = [
      [["backup"], require('patch/backup.js')(GlobalPatch, VoiceBank)],
    ]

    // MARK: MIDI I/O
    
    static request = (bytes) => 
      RxMidi.FetchCommand.request(VoicePatch.sysexHeader.concat(bytes, 0xf7))
    
    static fetchCommands(editor, path) {
      switch (path[0]) {
      case "global":
        return [this.request([0x0e])]
      case "patch":
        return [this.request([0x06])]
      case "bank":
        var bank = path[1]
        return (128).map(i => this.request([0x05, bank, i]))
      default:
        return null
      }
    }
      
    static midiChannel = function(editor, path) { return channel(editor) }
  
    static bankInfo(templateType) {
      switch (templateType) {
      case VoicePatch:
        return [
          [["bank", 0], "Bank 1"],
          [["bank", 1], "Bank 2"],
          [["bank", 2], "Bank 3"],
          ]
      default:
        return []
      }
    }

    // returns an array of objects to be used to construct streams/connections from editor->midi
    static midiOuts(editor) {
      return [
        nrpnOut(editor, ["global"], GlobalPatch, 0),
        nrpnOut(editor, ["patch"], VoicePatch, 0),
      ].concat((3).map(i => bankOut(editor, ["bank", i], VoicePatch, i)))
    }

  }  
}

const MophoGlobalPatch = require('patch/globalPatch.js')
const MophoVoicePatch = require('patch/voicePatch.js')
const MophoVoiceBank = require('patch/voiceBank.js')
const MophoEditor = MophoTypeEditor(MophoGlobalPatch, MophoVoicePatch, MophoVoiceBank)

exports.MophoEditor = MophoEditor

// public struct JDXiEditor : RolandEditorTemplate, RefEditorTemplate {
// 
//   // this is a fixed value on the JD-Xi
//   public static func deviceId(_ editor: TemplatedEditor) -> UInt8 { 16 }
// 
//   public static var sysexMap: [SynthPath : SysexTemplate.Type] = {
//     var types: [SynthPath:SysexTemplate.Type] = [
//       [.global]       : JDXiGlobalPatch.self,
//       [.perf]         : JDXiProgramPatch.self,
//       [.digital, .i(0)]       : JDXiDigitalPatch.self,
//       [.digital, .i(1)]        : JDXiDigitalPatch.self,
//       [.analog] : JDXiAnalogPatch.self,
//       [.rhythm] : JDXiDrumPatch.self,
//       [.rhythm, .partial] : JDXiDrumPatch.PartialPatch.self, // only actually here for popover
//     ]
//     (0..<2).forEach { types[[.bank, .perf, .i($0)]] = JDXiProgramBank.self }
//     (0..<4).forEach { types[[.bank, .digital, .i($0)]] = JDXiDigitalBank.self }
//     (0..<2).forEach { types[[.bank, .analog, .i($0)]] = JDXiAnalogBank.self }
//     (0..<2).forEach { types[[.bank, .rhythm, .i($0)]] = JDXiDrumBank.self }
//     return types
//   }()
// 
//   public static let migrationMap: [SynthPath:String]? = {
//     var names: [SynthPath:String] = [
//       [.global]       : "Global.syx",
//       [.perf]         : "Program.syx",
//       [.digital, .i(0)]       : "Digital 1.syx",
//       [.digital, .i(1)]        : "Digital 2.syx",
//       [.analog] : "Analog.syx",
//       [.rhythm] : "Drums.syx",
//     ]
//     (0..<2).forEach { names[[.bank, .perf, .i($0)]] = "Program Bank \($0+1).syx" }
//     (0..<4).forEach { names[[.bank, .digital, .i($0)]] = "Digital Bank \($0+1).syx" }
//     (0..<2).forEach { names[[.bank, .analog, .i($0)]] = "Analog Bank \($0+1).syx" }
//     (0..<2).forEach { names[[.bank, .rhythm, .i($0)]] = "Drum Bank \($0+1)" }
//     return names
//   }()
// 
//   public static func fetchCommands(_ editor: TemplatedEditor, forPath path: SynthPath) -> [RxMidi.FetchCommand]? {
//     // can't fetch drum kits using a 1-request method. causes a crash on the synth
//     switch path.first {
//     case .rhythm:
//       return drumPatchFetchData(editor, startAddress: JDXiDrumPatch.startAddress(nil))
//     case .bank:
//       guard path[1] == .rhythm else { return defaultIntentFetchCommands(editor, forPath: path) }
//       let startAddress = JDXiDrumBank.startAddress(path)
//       return JDXiDrumBank.patchCount.map {
//         let offsetAddress = JDXiDrumBank.offsetAddress(location: UInt8($0))
//         return drumPatchFetchData(editor, startAddress: startAddress + offsetAddress)
//         }.reduce([], +)
//     case .backup:
//       let partPaths = JDXiBackup.rolandMap.map { $0.path }
//       return partPaths.compactMap { fetchCommands(editor, forPath: $0) }.reduce([], +)
//     case .extra:
//       let partPaths = JDXiFullProgramPatch.rolandMap.map { $0.path }
//       return partPaths.compactMap { fetchCommands(editor, forPath: $0) }.reduce([], +)
//     default:
//       return defaultIntentFetchCommands(editor, forPath: path)
//     }
//   }
//   
//   private static func drumPatchFetchData(_ editor: TemplatedEditor, startAddress: RolandAddress) -> [RxMidi.FetchCommand] {
//     let sortedMap = JDXiDrumPatch.rolandMap.sorted(by: { $0.address < $1.address })
//     return sortedMap.map {
//       let data = fetchRequestData(editor, forAddress: startAddress + $0.address, size: $0.patch.size, addressCount: $0.patch.addressCount)
//       return .requestMsg(.sysex(data), .eq($0.patch.fileDataCount))
//       }
//   }
//   
//   // MARK: MIDI I/O
//   
//   public static func requestHeader(_ editor: TemplatedEditor) -> [UInt8] {
//     [0xf0, 0x41, deviceId(editor), 0x00, 0x00, 0x00, 0x0e, 0x11]
//   }
//   
//   public static func extraParamsOutput(_ editor: TemplatedEditor, forPath path: SynthPath) -> Observable<[SynthPath : Param]>? {
//     guard path == [.perf] else { return nil }
//     
//     let digitalOuts = mapNames(editor, count: 4, prefix: .digital)
//     let analogOuts = mapNames(editor, count: 2, prefix: .analog)
//     let drumOuts = mapNames(editor, count: 2, prefix: .rhythm)
//     return Observable.merge(digitalOuts + analogOuts + drumOuts)
//   }
//   
//   private static func mapNames(_ editor: TemplatedEditor, count: Int, prefix: SynthPathItem) -> [Observable<[SynthPath : Param]>] {
//     count.map { bank in
//       mapBankNameParams(editor, bankPath: [.bank, prefix, .i(bank)], toParamPath: [prefix, .i(bank), .name]) { (i, n) in
//         "\(userIndex(bank: bank, pgm: i)): \(n)"
//       }
//     }
//   }
//   
//   private static func userIndex(bank: Int, pgm: Int) -> Int {
//     pgm + 1 + 300 + bank * 128
//   }
//   
//   public static func transformMidiCommand(_ editor: TemplatedEditor, forPath path: SynthPath, _ command: RxMidi.Command) -> RxMidi.Command {
//     guard case let .sendMsg(msg) = command else { return command }
//     let ch = UInt8(editor.midiChannel(forPath: path))
//     return .sendMsg(msg.channel(ch))
//   }
// 
//   public static let compositeMap: [SynthPath : MultiSysexTemplate.Type] = [
//     [.backup] : JDXiBackup.self,
//     [.extra, .perf] : JDXiFullProgramPatch.self,
//   ]
//   
//   public static func refTypes(using patchType: SysexPatch.Type) -> [RefTemplate.Type] {
//     switch (patchType as? TemplatedPatch.Type)?.patchTemplate {
//     case is JDXiDigitalPatch.Type, is JDXiAnalogPatch.Type, is JDXiDrumPatch.Type:
//       return [JDXiProgramPatch.self]
//     default:
//       return []
//     }
//   }
//   
//   public static func patchInfo(_ editor: TemplatedEditor, forPath path: SynthPath) -> (slot: String, name: String)? {
//     let sp = path.pathPlusEndex()
//     var slot: String?
//     var name: String?
//     switch sp.path.first {
//     case .bank:
//       slot = "\(userIndex(bank: sp.path.endex, pgm: sp.endex))"
//       name = editor.bank(forPath: sp.path)?[sp.endex].name
//     case .preset:
//       slot = "\(sp.path.endex * 128 + sp.endex + 1)"
//       let nameOptions: [Int:String]
//       switch sp.path[1] {
//       case .digital:
//         switch sp.path.endex {
//         case 0:
//           nameOptions = JDXiProgramPatch.Digital1PartPatch.patchOptions
//         default:
//           nameOptions = JDXiProgramPatch.Digital2PartPatch.patchOptions
//         }
//       case .analog:
//         nameOptions = JDXiProgramPatch.AnalogPartPatch.patchOptions
//       case .rhythm:
//         nameOptions = JDXiProgramPatch.DrumPartPatch.patchOptions
//       default:
//         return nil
//       }
//       name = nameOptions[sp.endex]
//     case .pgm:
//       return (slot: "Program", name: "--")
//     default:
//       return nil
//     }
// 
//     return (slot: slot ?? "??", name: name ?? "?")
//   }
//     
//   public static func midiChannel(_ editor: TemplatedEditor, forPath path: SynthPath) -> Int {
//     editor.patch(forPath: [.perf])?[path + [.channel]] ?? 0
//   }
//   
// 
//   public static func bankInfo(forPatchTemplate templateType: PatchTemplate.Type) -> [(SynthPath, String)] {
//     switch templateType {
//     case is JDXiProgramPatch.Type:
//       return 2.map { ([.bank, .perf, .i($0)], "Program Bank \($0 + 1)") }
//     case is JDXiDigitalPatch.Type:
//       return 4.map { ([.bank, .digital, .i($0)], "Digital Bank \($0 + 1)") }
//     case is JDXiAnalogPatch.Type:
//       return 2.map { ([.bank, .analog, .i($0)], "Analog Bank \($0 + 1)") }
//     case is JDXiDrumPatch.Type:
//       return 2.map { ([.bank, .rhythm, .i($0)], "Drum Bank \($0 + 1)") }
//     default:
//       return []
//     }
//   }
//   
//   public static func bankIndexLabelBlock(forPath path: SynthPath) -> ((Int) -> String)? {
//     let endex = path.endex
//     if path.starts(with: [.bank, .perf]) {
//       let letters = endex == 0 ? ["E", "F"] : ["G", "H"]
//       return { "\(letters[($0 / 64) % 2])\(($0 % 64) + 1)" }
//     }
//     else {
//       return { "\(userIndex(bank: endex, pgm: $0))" }
//     }
//   }
// }


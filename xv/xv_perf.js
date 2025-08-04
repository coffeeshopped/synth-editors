
const soloIso = ['switch', [
  [0, 'Off'],
]]

const srcIso = ['switch', [
  [0, 'Perform'],
]]

function commonPatchWerk(parms) {
  return {
    single: "Perf Common",
    parms: parms, 
    size: 0x35,
    name: [0, 0x0b],
  }
}

// PART

function partType(hi) {
  return ([86, 88, 92, 120]).includes(hi) ? 'rhythm' : 'patch'
}

      /// For mapping SynthPaths to control values (internal to Patch Base)
const internalGroups: [SynthPath] = [[], "user", "preset/0", "preset/1", "preset/2", "preset/3", "preset/4", "preset/5", "preset/6", "preset/7", "cart", "gm2"]

const srjvGroups: [SynthPath] = (1...19).map { "$0" } + (98...99).map { "$0" }

const srxGroups: [SynthPath] = (1...12).map { "$0" } + ["98"]

const presetGroups: [SynthPath] = 8.map { "$0" }


const internalGroupsMap = {
  "-" : "---",
  "int/user" : "User",
  "int/preset/0" : "Preset A",
  "int/preset/1" : "Preset B",
  "int/preset/2" : "Preset C",
  "int/preset/3" : "Preset D",
  "int/preset/4" : "Preset E",
  "int/preset/5" : "Preset F",
  "int/preset/6" : "Preset G",
  "int/preset/7" : "Preset H",
  "int/cart" : "Card",
  "int/gm2" : "GM2",
}

const internalPartGroupOptions = Array.sparse(([
  "-",
  "int/user",
  "int/preset/0",
  "int/preset/1",
  "int/preset/2",
  "int/preset/3",
  "int/preset/4",
  "int/preset/5",
  "int/gm2",
]).map(k => [valueForSynthPath(k), internalGroupsMap[k]]))

const srxPartGroupOptions = SRXBoard.boards.dict {
  [valueForSynthPath("srx/$0.key") : "SRX: \($0.value.name)"]
}

const srjvPartGroupOptions = SRJVBoard.boards.dict {
  [valueForSynthPath("srjv/$0.key") : "SRJV: \($0.value.name)"]
}

/// Map roland Id to hi/lo bank byte
function hiLo(synthPath) { // -> [hi, lo]
  switch (synthPath[0]) {
  case 'int':
    switch (synthPath[1]) {
    case 'gm2':
      return [120, 0]
    case 'user':
      return [86, 0]
    case 'cart':
      return [86, 32]
    case 'preset':
      return [86, 64 + (Part.presetGroups.firstIndex(of: synthPath.subpath(from: 2)) ?? 0)]
    default:
      return [86, 0]
    }
  case 'srjv':
    return [88, (Part.srjvGroups.firstIndex(of: synthPath.subpath(from: 1)) ?? 0) * 2]
  case 'srx':
    const i = synthPath[1]
    const lookup = [0, 0, 1, 2, 3, 4, 7, 11, 15, 19, 23, 24, 25]
    return [92, i < lookup.length ? lookup[i] : 0]
  default:
    return [127, 0]
  }
}

function partGroup(hi, lo) {
  switch (hi) {
  case 86, 87:
    switch lo {
    case 0, 1: return "int/user"
    case 32, 33: return "int/cart"
    case 64...71: return "int/preset/lo - 64"
    default: return "int/user"
    }
  case 88, 89:
    return "srjv/(lo / 2) + 1"
  case 92, 93:
    switch lo {
    case 0: return "srx/1"
    case 1: return "srx/2"
    case 2: return "srx/3"
    case 3: return "srx/4"
    case 4, 5, 6: return "srx/5"
    case 7, 8, 9, 10: return "srx/6"
    case 11, 12, 13, 14: return "srx/7"
    case 15, 16, 17, 18: return "srx/8"
    case 19, 20, 21, 22: return "srx/9"
    case 23: return "srx/10"
    case 24: return "srx/11"
    case 25: return "srx/12"
    default: return "srx/1"
    }
  case 120, 121: return "int/gm2"
  case 127: return '-'
  default: return "int/user"
  }
}

// map SynthPath to value for part group select
function valueForSynthPath(synthPath) {
  switch synthPath[0] {
  case 'int':
    return internalGroups.firstIndex(of: synthPath.subpath(from: 1)) ?? 0
  case 'srjv':
    return 100 + (srjvGroups.firstIndex(of: synthPath.subpath(from: 1)) ?? 0)
  case 'srx':
    return 200 + (srxGroups.firstIndex(of: synthPath.subpath(from: 1)) ?? 0)
  default:
    return 0
  }
}

function synthPathForValue(value) {
  let v = value % 100
  switch value {
  case 0:
    return []
  case 1..<100:
    guard v < internalGroups.count else { return "int/user" }
    return "int" + internalGroups[v]
  case 100..<200:
    guard v < srjvGroups.count else { return "int/user" }
    return "srjv" + srjvGroups[v]
  case 200..<300:
    guard v < srxGroups.count else { return "int/user" }
    return "srx" + srxGroups[v]
  default:
    return "int/user"
  }
}

function partPatchWerk(parms, size) {
  return { 
    single: "Perf Part", 
    parms: parms, 
    size: size,
  }
}


// MIDI

const veloCurveIso = ['switch', [
  [0, 'Off'],
]]

const midiParms = [
  ['rcv/pgmChange', { b: 0x00, max: 1 }],
  ['rcv/bank', { b: 0x01, max: 1 }],
  ['rcv/bend', { b: 0x02, max: 1 }],
  ['rcv/poly/pressure', { b: 0x03, max: 1 }],
  ['rcv/channel/pressure', { b: 0x04, max: 1 }],
  ['rcv/mod', { b: 0x05, max: 1 }],
  ['rcv/volume', { b: 0x06, max: 1 }],
  ['rcv/pan', { b: 0x07, max: 1 }],
  ['rcv/expression', { b: 0x08, max: 1 }],
  ['rcv/hold', { b: 0x09, max: 1 }],
  ['phase/lock', { b: 0x0a, max: 1 }],
  ['velo/curve', { b: 0x0b, iso: veloCurveIso, max: 4 }],
]

const midiPatchWerk = {
  single: "Perf Midi", 
  parms: midiParms, 
  size: 0x0c,
}


function patchWerk(partCount, werks, other, initFile) {  
  let parts: [RolandMultiPatchTrussWerk.MapItem] = partCount.map {
    ("part/$0", 0x2000 + ($0 * RolandAddress(0x100)), part)
  }
  // TODO: roland address math
  return {
    multi: "Performance", 
    map: ([
      ["common", 0x0000, werks.common],
      ["fx/0", 0x0200, werks.fx],
      ["chorus", 0x0400, werks.chorus],
      ["reverb", 0x0600, werks.reverb],
    ]).concat((16).map(i =>
      [["midi", i], 0x1000 + (i * 0x100), midiPatchWerk]
    ), parts, other),
    initFile: initFile,
  }
}

function bankWerk(patchWerk, initFile) {
  return {
    multi: patchWerk,
    patchCount: 64,
    initFile: initFile,
  }
}

module.exports = {
  soloIso,
  srcIso,
  commonPatchWerk,
  patchWerk,
  bankWerk,
}

extension XV {
  
  enum Perf {
        
    enum Full {
      
      static func refTruss(_ partCount: Int, perf: RolandMultiPatchTrussWerk, voice: RolandMultiPatchTrussWerk, rhythm: RolandMultiPatchTrussWerk) -> FullRefTruss {
        let sections: [(String, [SynthPath])] = [
          ("Performance", [refPath]),
          ("Parts", partCount.map { "part/$0" }),
        ]

        let start: RolandAddress = 0x10000000
        let sysexWerk = XV.sysexWerk

        let parseMapHeadData: FullRefTruss.ParseMapHeadDataFn = { fileData in
          let sysex = SysexData(data: Data(fileData))

          // determine the base address of the fetched data
          let baseAddress = sysex.map { sysexWerk.address(forSysex: $0.bytes()) }.sorted(by: { $0 < $1 }).first

          // put together the performance
          var perfData = Data()
          sysex.forEach { msg in
            let offsetAddress = sysexWerk.address(forSysex: msg.bytes()) - baseAddress!
            guard perf.mapIndex(address: offsetAddress - start, sysex: msg.bytes()) != nil else { return }
            perfData += msg
          }
          return .multi(try! perf.truss.parseBodyData(perfData.bytes()))
        }
        
        let createFileData: FullRefTruss.Core.ToMidiFn = { bodyData in
          guard let perfData = bodyData[refPath] else {
            throw SysexTrussError.incorrectSysexType(msg: "Missing head data in XV Full Perf")
          }
          let cMap = customMap(perfData: perfData, partCount: partCount, perf: perf, voice: voice, rhythm: rhythm)
          return try cMap.compactMap {
            guard let bd = bodyData[$0.path] else { return nil }
            return try $0.werk.anySysexData(bd, deviceId: UInt8(RolandDefaultDeviceId), address: $0.address + start).reduce([], +)
          }.reduce([], +)
        }
        
        let parseBodyData: FullRefTruss.Core.ParseBodyDataFn = { fileData in
          guard let headData = parseMapHeadData(fileData) else {
            throw SysexTrussError.incorrectSysexType(msg: "Unable to parse headData: XV Full Perf")
          }
          let cMap = customMap(perfData: headData, partCount: partCount, perf: perf, voice: voice, rhythm: rhythm)

          return try RolandMultiSysexTrussWerk.defaultParseBodyData(fileData, sysexWerk: sysexWerk, map: cMap)
        }
        
        let trussMapFn: FullRefTruss.TrussMapFn = { headData in
          let rolandMap = customMap(perfData: headData, partCount: partCount, perf: perf, voice: voice, rhythm: rhythm)
          return rolandMap.map { ($0.path, $0.werk.anyTruss) }
        }
        
        return FullRefTruss("Full Perf", trussMapFn: trussMapFn, trussPaths: trussPaths(partCount), parseMapHeadData: parseMapHeadData, refPath: refPath, refTruss: perf.truss, isos: isos(partCount), sections: sections, initFile: "xv5050-full-perf-init", createFileData: createFileData, parseBodyData: parseBodyData, fileDataCount: 18951)
      }
      
      const refPath: SynthPath = "perf"

      static func trussPaths(_ partCount: Int) -> [SynthPath] {
        ["perf"] + partCount.map { "part/$0" }
      }
      
      static var namePath: SynthPath? { "perf" }
      
      static func isos(_ partCount: Int) -> FullRefTruss.Isos {
        partCount.dict { part in
          let partPath: SynthPath = "part/part"
          
          return [partPath : .init(values: { mem in
            guard mem.path.first == .bank else { return [:] }
            return .init([
              "bank/hi" : 86 + (mem.path[1] == .patch ? 1 : 0),
              "bank/lo" : 0,
              "pgm/number" : mem.path.i(3) ?? 0,
            ])
          }, memSlot: { values, refMem in
            guard let hi = values["bank/hi"],
                  let lo = values["bank/lo"],
                  let pgm = values["pgm/number"] else { return nil }
            let path = partGroup(forHi: hi, lo: lo)
            return .init(path, pgm)
          }, paramPaths: ["bank/hi", "bank/lo", "pgm/number"])]
          
        }
      }
      
      static func isValid(fileSize: Int) -> Bool { true
    //    fileSize >= 18951 // TODO
      }
      
      
      static func isCompleteFetch(sysex: [UInt8], partCount: Int, perf: RolandMultiPatchTrussWerk, voice: RolandMultiPatchTrussWerk, rhythm: RolandMultiPatchTrussWerk) -> Bool {
        // check min size
        guard sysex.count >= 18951 else { return false }

        // create a perf patch (just the perf, not full perf) to pull out the patch types
        let perfBodyData = try! perf.truss.parseBodyData([UInt8](sysex[0..<perf.truss.fileDataCount]))
        var patchCount = 0
        var rhythmCount = 0
        (0..<partCount).forEach {
          let hi = perf.truss.getValue(perfBodyData, path: "part/$0/bank/hi") ?? 0
          if partType(forHi: hi) == .patch {
            patchCount += 1
          }
          else {
            rhythmCount += 1
          }
        }
        // sum them
        let expectedSize = (patchCount * voice.truss.fileDataCount) + (rhythmCount * rhythm.truss.fileDataCount) + perf.truss.fileDataCount
        return expectedSize == sysex.count
      }
      
      private static func customMap(perfData: SysexBodyData, partCount: Int, perf: RolandMultiPatchTrussWerk, voice: RolandMultiPatchTrussWerk, rhythm: RolandMultiPatchTrussWerk) -> [RolandMultiSysexTrussWerk.MapItem] {
        guard case .multi(let perfData) = perfData else { return [] }
        
        let partTypes: [SynthPathItem] = (0..<partCount).compactMap {
          guard let hi = perf.truss.getValue(perfData, path: "part/$0/bank/hi") else { return nil }
          return partType(forHi: hi)
        }
        return [
          ("perf", 0x00000000, perf),
        ]
        + partTypes.enumerated().map { (part, partType) in
          // rhythm part addresses are offset by 0x100000
          let isRhythm = partType == .rhythm
          let addy: RolandAddress = 0x01000000 + (part * 0x200000) + (isRhythm ? 0x100000 : 0)
          return ("part/part", addy, isRhythm ? rhythm : voice)
        }
      }
      
    }
    
    enum Part {
      
      struct Config {
        var voicePartGroups: [Int:String]
        var rhythmPartGroups: [Int:String]
        var voicePresets: [SynthPath:[Int:String]]
        var rhythmPresets: [SynthPath:[Int:String]]
      }

      
    }
  }
  
}

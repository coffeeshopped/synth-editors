
extension XV {
  
  enum Perf {
    
    static func patchWerk(_ partCount: Int, common: RolandSinglePatchTrussWerk, part: RolandSinglePatchTrussWerk, fx: RolandSinglePatchTrussWerk, chorus: RolandSinglePatchTrussWerk, reverb: RolandSinglePatchTrussWerk, other: [RolandMultiPatchTrussWerk.MapItem], initFile: String) -> RolandMultiPatchTrussWerk {
      let parts: [RolandMultiPatchTrussWerk.MapItem] = partCount.map {
        ([.part, .i($0)], 0x2000 + ($0 * RolandAddress(0x100)), part)
      }
      return XV.sysexWerk.multiPatchWerk("Performance", [
        ([.common], 0x0000, common),
        ([.fx, .i(0)], 0x0200, fx),
        ([.chorus], 0x0400, chorus),
        ([.reverb], 0x0600, reverb),
      ] + 16.map {
        ([.midi, .i($0)], 0x1000 + ($0 * RolandAddress(0x100)), XV5050.Perf.Midi.patchWerk)
      } + parts + other, start: 0x10000000, initFile: initFile)
    }
    
    static func bankWerk(_ patchWerk: RolandMultiPatchTrussWerk, initFile: String) -> RolandMultiBankTrussWerk {
      sysexWerk.multiBankWerk(patchWerk, 64, start: 0x20000000, initFile: initFile)
    }
    
    enum Full {
      
      static func refTruss(_ partCount: Int, perf: RolandMultiPatchTrussWerk, voice: RolandMultiPatchTrussWerk, rhythm: RolandMultiPatchTrussWerk) -> FullRefTruss {
        let sections: [(String, [SynthPath])] = [
          ("Performance", [refPath]),
          ("Parts", partCount.map { [.part, .i($0)] }),
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
      
      static let refPath: SynthPath = [.perf]

      static func trussPaths(_ partCount: Int) -> [SynthPath] {
        [[.perf]] + partCount.map { [.part, .i($0)] }
      }
      
      static var namePath: SynthPath? { [.perf] }
      
      static func isos(_ partCount: Int) -> FullRefTruss.Isos {
        partCount.dict { part in
          let partPath: SynthPath = [.part, .i(part)]
          
          return [partPath : .init(values: { mem in
            guard mem.path.first == .bank else { return [:] }
            return .init([
              [.bank, .hi] : 86 + (mem.path[1] == .patch ? 1 : 0),
              [.bank, .lo] : 0,
              [.pgm, .number] : mem.path.i(3) ?? 0,
            ])
          }, memSlot: { values, refMem in
            guard let hi = values[[.bank, .hi]],
                  let lo = values[[.bank, .lo]],
                  let pgm = values[[.pgm, .number]] else { return nil }
            let path = partGroup(forHi: hi, lo: lo)
            return .init(path, pgm)
          }, paramPaths: [[.bank, .hi], [.bank, .lo], [.pgm, .number]])]
          
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
          let hi = perf.truss.getValue(perfBodyData, path: [.part, .i($0), .bank, .hi]) ?? 0
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
          guard let hi = perf.truss.getValue(perfData, path: [.part, .i($0), .bank, .hi]) else { return nil }
          return partType(forHi: hi)
        }
        return [
          ([.perf], 0x00000000, perf),
        ]
        + partTypes.enumerated().map { (part, partType) in
          // rhythm part addresses are offset by 0x100000
          let isRhythm = partType == .rhythm
          let addy: RolandAddress = 0x01000000 + (part * 0x200000) + (isRhythm ? 0x100000 : 0)
          return ([.part, .i(part)], addy, isRhythm ? rhythm : voice)
        }
      }
      
    }
    
    
    
    
    /// Map roland Id to hi bank byte
    static func hiLo(forSynthPath synthPath: SynthPath) -> (Int,Int) {
      let hi: Int
      let lo: Int
      switch synthPath.first {
      case .int:
        switch synthPath[1] {
        case .gm2:
          hi = 120
          lo = 0
        case .user:
          hi = 86
          lo = 0
        case .cart:
          hi = 86
          lo = 32
        case .preset:
          hi = 86
          lo = 64 + (Part.presetGroups.firstIndex(of: synthPath.subpath(from: 2)) ?? 0)
        default:
          hi = 86
          lo = 0
        }
      case .srjv:
        hi = 88
        lo = (Part.srjvGroups.firstIndex(of: synthPath.subpath(from: 1)) ?? 0) * 2
      case .srx:
        hi = 92
        switch synthPath.i(1) {
        case 1: lo = 0
        case 2: lo = 1
        case 3: lo = 2
        case 4: lo = 3
        case 5: lo = 4
        case 6: lo = 7
        case 7: lo = 11
        case 8: lo = 15
        case 9: lo = 19
        case 10: lo = 23
        case 11: lo = 24
        case 12: lo = 25
        default: lo = 0
        }
      default:
        hi = 127
        lo = 0
      }
      return (hi, lo)
    }
    
    static func partType(forHi hi: Int) -> SynthPathItem {
      switch hi {
      case 86, 88, 92, 120:
        return .rhythm
      default:
        return .patch
      }
    }

    static func partGroup(forHi hi: Int, lo: Int) -> SynthPath {
      switch hi {
      case 86, 87:
        switch lo {
        case 0, 1: return [.int, .user]
        case 32, 33: return [.int, .cart]
        case 64...71: return [.int, .preset, .i(lo - 64)]
        default: return [.int, .user]
        }
      case 88, 89:
        return [.srjv, .i((lo / 2) + 1)]
      case 92, 93:
        switch lo {
        case 0: return [.srx, .i(1)]
        case 1: return [.srx, .i(2)]
        case 2: return [.srx, .i(3)]
        case 3: return [.srx, .i(4)]
        case 4, 5, 6: return [.srx, .i(5)]
        case 7, 8, 9, 10: return [.srx, .i(6)]
        case 11, 12, 13, 14: return [.srx, .i(7)]
        case 15, 16, 17, 18: return [.srx, .i(8)]
        case 19, 20, 21, 22: return [.srx, .i(9)]
        case 23: return [.srx, .i(10)]
        case 24: return [.srx, .i(11)]
        case 25: return [.srx, .i(12)]
        default: return [.srx, .i(1)]
        }
      case 120, 121: return [.int, .gm2]
      case 127: return []
      default: return [.int, .user]
      }
    }
    
    

    
    enum Common {
      
      static func patchWerk(params: SynthPathParam) -> RolandSinglePatchTrussWerk {
        try! XV.sysexWerk.singlePatchWerk("Perf Common", params, size: 0x35, start: 0x0000, name: .basic(0..<0x0c))
      }

    }

    
    enum Part {
      
      struct Config {
        var voicePartGroups: [Int:String]
        var rhythmPartGroups: [Int:String]
        var voicePresets: [SynthPath:[Int:String]]
        var rhythmPresets: [SynthPath:[Int:String]]
      }
      
      static func patchWerk(params: SynthPathParam, size: RolandAddress) -> RolandSinglePatchTrussWerk {
        try! XV.sysexWerk.singlePatchWerk("Perf Part", params, size: size, start: 0x2000)
      }
      
      /// For mapping SynthPaths to control values (internal to Patch Base)
      static let internalGroups: [SynthPath] = [[], [.user], [.preset, .i(0)], [.preset, .i(1)], [.preset, .i(2)], [.preset, .i(3)], [.preset, .i(4)], [.preset, .i(5)], [.preset, .i(6)], [.preset, .i(7)], [.cart], [.gm2]]
      static let srjvGroups: [SynthPath] = (1...19).map { [.i($0)] } + (98...99).map { [.i($0)] }
      static let srxGroups: [SynthPath] = (1...12).map { [.i($0)] } + [[.i(98)]]
      static let presetGroups: [SynthPath] = 8.map { [.i($0)] }

      static let internalGroupsMap: [SynthPath:String] = [
        [] : "---",
        [.int, .user] : "User",
        [.int, .preset, .i(0)] : "Preset A",
        [.int, .preset, .i(1)] : "Preset B",
        [.int, .preset, .i(2)] : "Preset C",
        [.int, .preset, .i(3)] : "Preset D",
        [.int, .preset, .i(4)] : "Preset E",
        [.int, .preset, .i(5)] : "Preset F",
        [.int, .preset, .i(6)] : "Preset G",
        [.int, .preset, .i(7)] : "Preset H",
        [.int, .cart] : "Card",
        [.int, .gm2] : "GM2",
        ]
      static let internalPartGroupOptions: [Int:String] = {
        let ids: [SynthPath] = [
          [],
          [.int, .user],
          [.int, .preset, .i(0)],
          [.int, .preset, .i(1)],
          [.int, .preset, .i(2)],
          [.int, .preset, .i(3)],
          [.int, .preset, .i(4)],
          [.int, .preset, .i(5)],
          [.int, .gm2],
        ]
        return ids.dict {
          [XV.Perf.Part.value(forSynthPath: $0) : internalGroupsMap[$0] ?? ""]
        }
      }()
      
      
      static let srxPartGroupOptions = SRXBoard.boards.dict {
        [value(forSynthPath: [.srx, .i($0.key)]) : "SRX: \($0.value.name)"]
      }
      
      static let srjvPartGroupOptions = SRJVBoard.boards.dict {
        [value(forSynthPath: [.srjv, .i($0.key)]) : "SRJV: \($0.value.name)"]
      }
      
      // map SynthPath to value for part group select
      static func value(forSynthPath synthPath: SynthPath) -> Int {
        switch synthPath.first {
        case .int:
          return internalGroups.firstIndex(of: synthPath.subpath(from: 1)) ?? 0
        case .srjv:
          return 100 + (srjvGroups.firstIndex(of: synthPath.subpath(from: 1)) ?? 0)
        case .srx:
          return 200 + (srxGroups.firstIndex(of: synthPath.subpath(from: 1)) ?? 0)
        default:
          return 0
        }
      }
      
      static func synthPath(forValue value: Int) -> SynthPath {
        let v = value % 100
        switch value {
        case 0:
          return []
        case 1..<100:
          guard v < internalGroups.count else { return [.int, .user] }
          return [.int] + internalGroups[v]
        case 100..<200:
          guard v < srjvGroups.count else { return [.int, .user] }
          return [.srjv] + srjvGroups[v]
        case 200..<300:
          guard v < srxGroups.count else { return [.int, .user] }
          return [.srx] + srxGroups[v]
        default:
          return [.int, .user]
        }
      }
      
    }
  }
  
}

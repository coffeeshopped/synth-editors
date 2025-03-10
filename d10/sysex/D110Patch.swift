
extension D110 {
  
  // A construct representing a "Patch", but in temp memory.
  /**
   Since the D-110 doesn't have a notion of a temporary "Patch" area, but rather only 8 temp Timbres + the System area,
   we are representing a Patch as a multi-patch built out of those parts. So a file written for a Patch, and the MIDI communication for editing a patch, is represented here.
   But for writing a Patch to *memory*, we use a separate specification (D110.Patch).
   */
  enum Patch {
    
    static let patchWerk: RolandMultiPatchTrussWerk = {
      let start: RolandAddress = 0x030000
      let map: [RolandMultiPatchTrussWerk.MapItem] = 8.map {
        ([.part, .i($0)], 0x10 * $0, Timbre.patchWerk)
      } + [
        ([.part, .rhythm], 0x0100, Timbre.patchWerk),
        ([.common], Common.patchWerk.start - start, Common.patchWerk),
      ]
//      let bundle = MultiPatchTruss.fileDataCountBundle(trusses: map.map { $0.werk.truss }, validSizes: [256, 266], includeFileDataCount: true)
      return DXX.sysexWerk.multiPatchWerk("Patch", map, start: start)
    }()

    static let commonPaths: [SynthPath] = [
      [.reverb, .type],
      [.reverb, .time],
      [.reverb, .level],
      [.part, .rhythm, .reserve],
      [.part, .rhythm, .channel],
    ] + 8.flatMap {
      [
        [.part, .i($0), .reserve],
        [.part, .i($0), .channel],
      ]
    }
    
    static let partPaths: [SynthPath] = [
      [.tone, .group],
      [.tone, .number],
      [.tune],
      [.fine],
      [.bend],
      [.assign, .mode],
      [.out, .assign],
      [.balance],
      [.out, .level],
      [.pan],
      [.key, .hi],
      [.key, .lo],
    ]
    
    static func tempToMem(_ temp: MultiPatchTruss.BodyData) throws -> SinglePatchTruss.BodyData {
      // for each patch bodyData, parse it using the truss above,
      let all = patchWerk.truss.allValues(temp)
      // then map those key/values to the key/values of MemPatch,
      var mem = [SynthPath:Int]()
      
      commonPaths.forEach {
        mem[$0] = all[[.common] + $0]
      }
      
      8.times { part in
        partPaths.forEach {
          let path = [.part, .i(part)] + $0
          mem[path] = all[path]
        }
      }
      mem[[.part, .rhythm, .out, .level]] = all[[.part, .rhythm, .out, .level]]
      
      let memWerk = memPatchWerk
      var memData = try memWerk.truss.createEmptyBodyData()
      mem.forEach {
        memWerk.truss.setValue(&memData, path: $0, $1)
      }
      
      // don't forget the name too.
      let n = patchWerk.truss.getName(temp) ?? "?"
      memWerk.truss.setName(&memData, n)
      
      return memData
    }
    
    // take body data from patchWerk (above), and turn into a bunch of sysex for Patch Memory
    static func bankCreateFile(_ bodyData: MultiBankTruss.BodyData, deviceId: UInt8, address: RolandAddress, patchWerk: RolandMultiPatchTrussWerk, iso: RolandOffsetAddressIso) throws -> [[UInt8]] {
      try bodyData.enumerated().map({ (index, bd) in
        let memWerk = memPatchWerk
        let memData = try tempToMem(bd)
        
        // then create the sysex data of the MemPatch
        let a = address + iso.address(UInt8(index))
        return memWerk.sysexDataFn(memData, deviceId, a)
      }).reduce([], +)
    }
    
    
    static func bankParseBody(fileData: [UInt8], iso: RolandOffsetAddressIso, patchWerk: RolandMultiPatchTrussWerk, patchCount: Int) throws -> MultiBankTruss.BodyData {
      
      let rData = RolandWerkData(data: Data(fileData), werk: patchWerk.werk)

      let memWerk = memPatchWerk
      let patchTruss = patchWerk.truss

      return try (0..<patchCount).map {
        let patchData = rData.bytes(offset: iso.address(UInt8($0)), size: memWerk.size)
        let subdata = patchWerk.werk.dummySysex(bytes: patchData)
        let memBD = try memWerk.truss.parseBodyData(subdata)
        let mem = memWerk.truss.allValues(memBD)
        let n = memWerk.truss.getName(memBD) ?? "?"
        
        var all = [SynthPath:Int]()
        
        commonPaths.forEach {
          all[[.common] + $0] = mem[$0]
        }
        
        8.times { part in
          partPaths.forEach {
            let path = [.part, .i(part)] + $0
            all[path] = mem[path]
          }
        }
        all[[.part, .rhythm, .out, .level]] = mem[[.part, .rhythm, .out, .level]]

        
        var allData = try patchTruss.createEmptyBodyData()
        all.forEach {
          patchTruss.setValue(&allData, path: $0, $1)
        }
        patchTruss.setName(&allData, n)

        return allData
      }
      
    }
    
    
    static let bankWerk: RolandMultiBankTrussWerk = {
      return RolandMultiBankTrussWerk(patchWerk, 64, start: 0x060000, iso: .init(address: {
        0x0100 * Int($0)
      }, location: {
        $0.sysexBytes(count: DXX.sysexWerk.addressCount)[1]
      }), createFileFn: bankCreateFile, parseBodyFn: bankParseBody, validBundle: MultiBankTruss.fileDataCountBundle(patchTruss: patchWerk.truss, patchCount: 64, validSizes: [8512, 8832], includeFileDataCount: true))
    }()
    
    
    static let memPatchWerk = try! DXX.sysexWerk.singlePatchWerk("MemPatch", memParms.params(), size: 0x0100, start: 0x030400, name: .basic(0x00..<0x0a))
        
    static let memParms: [Parm] = {
      var p: [Parm] = [
        .p([.reverb, .type], 0x0a, .opts(System.reverbTypeOptions)),
        .p([.reverb, .time], 0x0b, .max(7, dispOff: 1)),
        .p([.reverb, .level], 0x0c, .max(7)),
      ]
      p += .prefix([.part], count: 8, bx: 1, block: { index, offset in
        [.p([.reserve], 0x0d, .max(32))]
      })
      p += [
        .p([.part, .rhythm, .reserve], 0x15, .max(32)),
      ]
      p += .prefix([.part], count: 8, bx: 1, block: { index, offset in
        [.p([.channel], 0x16, .max(16))]
      })
      p += [
        .p([.part, .rhythm, .channel], 0x1e, .max(16)),
      ]
      p += .prefix([.part], count: 8, bx: 0x0c, block: { index, offset in
        .inc(b: 0x1f) { [
          .p([.tone, .group], .opts(toneGroupOptions)),
          .p([.tone, .number], .opts(toneNumberOptions)),
          .p([.tune], .max(48, dispOff: -24)),
          .p([.fine], .max(100, dispOff: -50)),
          .p([.bend], .max(24)),
          .p([.assign, .mode], .opts(assignModeOptions)),
          .p([.out, .assign], .max(7)),
          .p([.balance], .max(100, dispOff: -50)), // dummy
          .p([.out, .level], .max(100)),
          .p([.pan], .max(14, dispOff: -7)),
          .p([.key, .lo]),
          .p([.key, .hi]),
        ] }
      })
      p += [
        .p([.part, .rhythm, .out, .level], 0x7f, .max(100)),
      ]


      return p
    }()
    
    static let toneGroupOptions = ["A","B","Int","Rhythm"]
    
    static let toneNumberOptions = (0...63).map { "\($0+1)" }
    
    static let assignModeOptions = ["Poly 1","Poly 2","Poly 3","Poly 4"]
    
    
    enum Common {
      
      static let patchWerk = try! DXX.sysexWerk.singlePatchWerk("Patch Common", tempParms.params(), size: 0x20, start: 0x100001, name: .basic(0x16..<0x20))
      // system params, but removing master tune, and then offsetting all byte locations by -1
      // to account for the shifted start address (added 1 to the System start address).
      static let tempParms: [Parm] = {
        var t = D110.System.parms
        t.removeFirst()
        return t.map { .p($0.path, $0.b! - 1, $0.span) }
      }()
  
    }
  }
  
}

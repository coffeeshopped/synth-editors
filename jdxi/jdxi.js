

public enum JDXi {
  
  static func multiPack(_ byte: RolandAddress) -> PackIso {
    Roland.msbMultiPackIso(4)(byte)
  }

  static func singlePatchWerk(_ displayId: String, _ params: SynthPathParam, size: RolandAddress, start: RolandAddress, name: NamePackIso? = nil, sysexDataFn: RolandSinglePatchTrussWerk.SysexDataFn? = nil) -> RolandSinglePatchTrussWerk {
    try! RolandSinglePatchTrussWerk(sysexWerk, displayId, params, size: size, start: start, name: name, sysexDataFn: sysexDataFn)
  }

  static func multiPatchWerk(_ displayId: String, _ map: [RolandMultiPatchTrussWerk.MapItem], start: RolandAddress, initFile: String = "", sysexDataFn: RolandMultiPatchTrussWerk.SysexDataFn? = nil, validBundle: MultiPatchTruss.ValidBundle? = nil) -> RolandMultiPatchTrussWerk {
    RolandMultiPatchTrussWerk(sysexWerk, displayId, map, start: start, initFile: initFile, sysexDataFn: sysexDataFn, validBundle: validBundle)
  }
  
  static func multiBankWerk(_ patchWerk: RolandMultiPatchTrussWerk, startOffset: UInt8, initFile: String? = nil, iso: RolandOffsetAddressIso? = nil, validBundle: MultiBankTruss.ValidBundle? = nil) -> RolandMultiBankTrussWerk {
    let patchCount = 128
    let start = RolandAddress([startOffset, 0x00, 0x00, 0x00])
    let iso = iso ?? .init(address: {
      RolandAddress(0x010000) * Int($0)
    }, location: {
      $0.sysexBytes(count: 4)[1]
    })
    return RolandMultiBankTrussWerk(patchWerk, patchCount, start: start, iso: iso, validBundle: validBundle)
  }

}

function bankItems(prefix, bankWerk, startOff, count, mult = 1) {
  return count.map(i => {
    let start = [startOff + i * mult, 0x00, 0x00, 0x00]
    return [['bank', prefix, i], start, bankWerk]
  })
}

const editor = {
  rolandModelId: [0x00, 0x00, 0x00, 0x0e], 
  addressCount: 4,
  name: "",
  map: ([
    ["global", Global.patchWerk.start, Global.patchWerk],
    ["perf", Program.patchWerk.start, Program.patchWerk],
    ["digital/0", Digital.patchWerk.start, Digital.patchWerk],
    ["digital/1", 0x19210000, Digital.patchWerk],
    ["analog", Analog.patchWerk.start, Analog.patchWerk],
    ["rhythm", Drum.patchWerk.start, Drum.patchWerk],
    ["rhythm/partial", Drum.Partial.patchWerk.start, Drum.Partial.patchWerk], // only actually here for popover
  ]).concat(
    bankItems('perf', Program.Bank.bankWerk, 0x30, 2),
    bankItems('digital', Digital.Bank.bankWerk, 0x60, 4),
    bankItems('analog', Analog.Bank.bankWerk, 0x70, 2),
    bankItems('rhythm', Drum.Bank.bankWerk, 0x50, 2, 4),
  ),
  fetchTransforms: [
  ],

  midiOuts: [
  ],
  
  midiChannels: [
    ["voice", "basic"],
  ],
  slotTransforms: [
  ],
}



extension JDXi {
  
  enum Editor {
        
    // fixed deviceId.
    static let werk: RolandEditorTrussWerk = RolandEditorTrussWerk("JD-Xi", map, deviceId: .constant(16), sysexWerk: JDXi.sysexWerk)
    
    static let truss: BasicEditorTruss = {
      var t = BasicEditorTruss("JD-Xi", truss: werk.sysexMap() + [
        ("extra/perf", JDXi.Program.Full.refTruss),
        ("backup", JDXi.backupTruss),
      ])
      
      // can't fetch drum kits using a 1-request method. causes a crash on the synth
      t.fetchTransforms = werk.defaultFetchTransforms() <<< [
        "rhythm" : werk.multiFetchTransform(path: "rhythm")!,
      ]
      <<< 2.dict {
        ["bank/rhythm/$0" : werk.multiFetchTransform(path: "bank/rhythm/$0")!]
      }
      
      t.extraParamOuts = mapNames(count: 4, prefix: .digital) + mapNames(count: 2, prefix: .analog) + mapNames(count: 2, prefix: .rhythm)
      t.midiOuts = werk.midiOuts()
      
      t.midiChannels = midiChannels(partPaths)

      t.slotTransforms = userTransforms(.perf, count: 2)
      <<< userTransforms(.digital, count: 4)
      <<< userTransforms(.analog, count: 2)
      <<< userTransforms(.rhythm, count: 2)
      <<< [
        "preset/digital/0" : .preset(presetTransformFn(bank: 0), names: Program.Digital1Part.patchOptions),
        "preset/digital/1" : .preset(presetTransformFn(bank: 1), names: Program.Digital2Part.patchOptions),
        "preset/analog" : .preset(presetTransformFn(bank: 0), names: Program.AnalogPart.patchOptions),
        "preset/rhythm" : .preset(presetTransformFn(bank: 0), names: Program.DrumPart.patchOptions),
        "pgm" : .preset({ _ in "Program" }, names: ["--"]),
      ]
      
      return t
    }()
    
    static let partPaths: [SynthPath] = [
      "digital/0",
      "digital/1",
      "analog",
      "rhythm",
    ]
    
    private static func midiChannels(_ paths: [SynthPath]) -> [SynthPath:MidiChannelTransform] {
      paths.dict { [$0 : .patch("perf", $0 + "channel")] }
    }

    // MARK: MIDI I/O

    private static func mapNames(count: Int, prefix: SynthPathItem) -> [(path: SynthPath, transform: ParamOutTransform)] {
      count.map { bank in
        ("perf", .bankNames(`bank/${prefix}/bank`, [prefix, .i(bank), .name], nameBlock: { (i, n) in
          "\(userIndex(bank: bank, pgm: i)): \(n)"
        }))
      }
    }
    
    private static func userIndex(bank: Int, pgm: Int) -> Int {
      pgm + 1 + 300 + bank * 128
    }
    
    private static func userTransforms(_ prefix: SynthPathItem, count: Int) -> [SynthPath:MemSlot.Transform] {
      return count.dict { b in
        let transform: MemSlot.Transform
        switch prefix {
        case .perf:
          let letters = b == 0 ? ["E", "F"] : ["G", "H"]
          transform = .user({ "\(letters[($0 / 64) % 2])\(($0 % 64) + 1)" })
        default:
          let offset = 1 + 300 + b * 128
          transform = .user({ "\($0 + offset)" })
        }
        return [`bank/${prefix}/b` : transform]
      }
    }
    
    private static func presetTransformFn(bank: Int) -> MemSlot.TransformFn {
      let offset = bank * 128 + 1
      return { "\($0 + offset)" }
    }
           
  }
  
}


extension Blofeld {

  struct MultiMode {
    typealias P = PatchTrussWerk

    static let dumpByte: UInt8 = 0x11

    static let patchTruss = createPatchTruss("Multi", 416, initFile: "blofeld-multi-init", namePack: .basic(0..<16), params: paramOptions, parseOffset: 7, dumpByte: dumpByte)

    static let bankTruss = createBankTruss(dumpByte: dumpByte, patchTruss: MultiMode.patchTruss, initFile: "blofeld-multimode-bank-init")

    
    static let refTruss: FullRefTruss = {
      let partCount = 16

      let blofeldMap: [(path: SynthPath, truss: SinglePatchTruss, dump: UInt8)] = [
        ([.perf], MultiMode.patchTruss, MultiMode.dumpByte),
      ] + partCount.map {
        ([.part, .i($0)], Voice.patchTruss, Voice.dumpByte)
      }

      let trussMap = blofeldMap.map { ($0.path, $0.truss) }
      let partMap = trussMap.filter { $0.0.starts(with: [.part]) }
      let refPath: SynthPath = [.perf]
      
      let createFileData: FullRefTruss.Core.CreateFileDataFn = { bodyData in
        blofeldMap.compactMap {
          guard case .single(let bytes) = bodyData[$0.path] else { return nil }
          return Blofeld.sysexData(bytes, deviceId: 0x7f, dumpByte: $0.dump, bank: 0x7f, location: UInt8($0.path.endex)).bytes()
        }.reduce([], +)
      }
      
      let isos: FullRefTruss.Isos = 16.dict {
        let part: SynthPath = [.part, .i($0)]
        return [part : .basic(path: part + [.bank], location: part + [.sound], pathMap: 8.map { [.bank, .i($0)] })]
      }

      let sections = FullRefTruss.defaultPerfSections(partCount: partCount, refPath: refPath)
      
      return FullRefTruss("Full Multi", trussMap: trussMap, refPath: refPath, isos: isos, sections: sections, initFile: "blofeld-full-perf-init", createFileData: createFileData, pathForData: path(forData:))

    }()
    
    static func path(forData data: [UInt8]) -> SynthPath? {
      guard data.count > 6 else { return nil }
      switch data[4] {
      case 0x11:
        return [.perf]
      case 0x10:
        return [.part, .i(Int(data[6]))]
      default:
        return nil
      }
    }
    
  //  static func isValid(fileSize: Int) -> Bool { true
  //    fileSize >= 18951 // TODO
  //  }
    
    
    static let paramOptions: [ParamOptions] = [
      P.o([.volume], 17),
      P.o([.tempo], 18, isoF: MicroQVoicePatch.tempoIso),
    ]
    <<< P.prefix([.part], count: 16, bx: 24) { i in
      [
        P.o([.bank], 32, opts: bankOptions),
        P.o([.sound], 33),
        P.o([.volume], 34),
        P.o([.pan], 35, dispOff: -64),
        P.o([.channel], 39, isoS: channelIso),
        P.o([.mute], 44, bit: 6, opts: muteOptions),
        P.o([.transpose], 37, range: 16...112, dispOff: -64),
        P.o([.detune], 38, dispOff: -64),
        P.o([.key, .lo], 40, isoS: noteIso),
        P.o([.key, .hi], 41, isoS: noteIso),
        P.o([.velo, .lo], 42, range: 1...127),
        P.o([.velo, .hi], 43),
        
        P.o([.midi], 44, bit: 0),
        P.o([.usb], 44, bit: 1),
        P.o([.local], 44, bit: 2),
        P.o([.bend], 45, bit: 0),
        P.o([.modWheel], 45, bit: 1),
        P.o([.pressure], 45, bit: 2),
        P.o([.sustain], 45, bit: 3),
        P.o([.edits], 45, bit: 4),
        P.o([.pgmChange], 45, bit: 5),
      ]
    }
    
    static let noteIso = Miso.noteName(zeroNote: "C-2")
    
    static let bankOptions = OptionsParam.makeOptions(["A","B","C","D","E","F","G","H"])
    
    static let muteOptions = OptionsParam.makeOptions(["Play", "Mute"])
      
    static let channelIso = Miso.switcher([
      .int(0, "Global"),
      .int(1, "Omni")
    ], default: Miso.a(-1) >>> Miso.str())
  }

}

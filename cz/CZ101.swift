
public enum CZ101 {
  
  static let editorTruss = createEditorTruss("CZ-101", patchCount: 16, letteredBanks: false, cz1: false)
  public static let moduleTruss = createModuleTruss(editorTruss, subid: "cz101", cz1: false)
  
  static func patchRequest(channel: Int, location: UInt8, cz1: Bool) -> [UInt8] {
    // only diff from CZ-101 is the 0x11 (instead of 0x10)
    // makes the CZ-1 send its full patch (with name, velo info)
    let c = 0x70 + UInt8(channel)
    return [0xf0, 0x44, 0x00, 0x00, c, cz1 ? 0x11 : 0x10, location, c, 0x31, 0xf7]
  }

  static func createEditorTruss(_ name: String, patchCount: Int, letteredBanks: Bool, cz1: Bool) -> BasicEditorTruss {
    let voicePatchTruss = cz1 ? CZ1.Voice.patchTruss : Voice.patchTruss
    let voiceBankTruss = cz1 ? CZ1.Voice.bankTruss : Voice.bankTruss(patchCount: patchCount)
    var t = BasicEditorTruss(name, truss: [
      ([.global], Global.patchTruss),
      ([.voice], voicePatchTruss),
      ([.bank, .voice], voiceBankTruss),
    ])
    
    t.fetchTransforms = [
      [.voice] : .truss(.basicChannel, {
        patchRequest(channel: $0, location: 0x60, cz1: cz1)
      }),
      [.bank, .voice] : .bankTruss(.basicChannel, {
        // adding an offset of 32, which at least the CZ-101 needs.
        patchRequest(channel: $0, location: (cz1 ? 0x00 : 0x20) + UInt8($1), cz1: cz1)
        // note that expected byte count per patch is 1 lower than temp fetch.
      }, bytesPerPatch: voicePatchTruss.fileDataCount - 1, waitInterval: 100)
    ]
    
    t.midiChannels = [
      [.voice] : .patch([.global], [.channel]),
    ]
    
    t.midiOuts = [
      ([.global], .json(throttle: 100, .basicChannel, .patch(param: { editorVal, bodyData, parm, value in
        if parm.p! > 0 {
          return [(.cc(channel: UInt8(editorVal), number: UInt8(parm.p!), value: UInt8(value)), 0)]
        }
        else if parm.b! > 0 {
          return [(.sysex([0xf0, 0x44, 0x00, 0x00, 0x70 + UInt8(editorVal), UInt8(parm.b!), UInt8(value), 0xf7]), 0)]
        }
        return []
      }, patch: { editorVal,bodyData in
        return [] // TODO: iterate through all values
      }, name: nil))),
      ([.voice], .single(throttle: 300, .basicChannel, .wholePatch({ editorVal, bodyData in
        [(.sysex(Voice.sysexData(bodyData, channel: editorVal, location: 0x60, cz1: cz1)), 0)]
      }))),
      ([.bank, .voice], .single(throttle: 100, .basicChannel, .bank({ editorVal, bodyData, location in
        [(.sysex(Voice.sysexData(bodyData, channel: editorVal, location: (cz1 ? 0x00 : 0x20) + location, cz1: cz1)), 0)]
      })))
    ]
    
    if letteredBanks || cz1 {
      let banks = ["A","B","C","D","E","F","G","H"]
      t.slotTransforms = [
        [.bank, .voice] : .user({ "\(banks[$0 / 8])\(($0 % 8) + 1)" }),
      ]
    }
    
    return t
  }
  
  static func createModuleTruss(_ editor: EditorTruss, subid: String, cz1: Bool) -> BasicModuleTruss {
    BasicModuleTruss(editor, manu: Manufacturer.casio, model: editor.displayId, subid: subid, sections: [
      .first([
        .global(CZ101.Global.Controller.ctrlr),
        .voice("Temp Voice", path: [.voice], CZ101.Voice.Controller.ctrlr(cz1: cz1)),
        .bank("Voice Bank", [.bank, .voice]),
      ])
    ], dirMap: [:], colorGuide: ColorGuide([
      "#ad41ef",
      "#b5d029",
      "#7520f9",
      "#20f975",
      ]), indexPath: IndexPath(item: 1, section: 0))
  }

}

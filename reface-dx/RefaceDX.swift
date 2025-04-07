
public enum RefaceDX {
  
  static func bulkDumpData(channel: Int, byteCount: Int, address: [UInt8], bodyBytes: [UInt8]) -> [UInt8] {
    Yamaha.sysexData(channel: channel, cmdBytes: [0x7f, 0x1c, 0x00, UInt8(byteCount)], bodyBytes: [0x05] + address + bodyBytes)
  }
  
  static func paramData(channel: Int, address: [UInt8], value: UInt8) -> [UInt8] {
    Yamaha.paramData(channel: channel, cmdBytes: [0x7f, 0x1c, 0x05] + address + [value])
  }

  
  static let editorTruss: BasicEditorTruss = {
    
    var t = BasicEditorTruss("Reface DX", truss: [
      ([.global], ChannelSettingsTruss),
      ([.patch], Voice.patchTruss),
      ([.bank, .voice], Voice.bankTruss),
    ])
    
    t.fetchTransforms = [
      [.patch] : .truss(.basicChannel, { fetch(channel: $0, address: [0x0e, 0x0f, 0x00]) }),
      [.bank, .voice] : .bankTruss(.basicChannel, { value, location in
        fetch(channel: value, address: [0x0e, 0x00, UInt8(location)])
      }, waitInterval: 200)
    ]
    
    t.midiChannels = [
      [.patch] : .basic(map: nil)
    ]
    
    t.midiOuts = [
      ([.patch], Voice.patchTransform),
      ([.bank, .voice], Voice.bankTransform),
    ]
    
    t.slotTransforms = [
      [.bank, .voice] : .user({ "\($0 / 8 + 1)-\($0 % 8 + 1)" })
    ]
    
    return t
  }()
  
  static func fetch(channel: Int, address: [UInt8]) -> [UInt8] {
    Yamaha.fetchRequestBytes(channel: channel, cmdBytes: [0x7f, 0x1c, 0x05] + address)
  }

  
  public static let moduleTruss = BasicModuleTruss(editorTruss, manu: Manufacturer.yamaha, model: editorTruss.displayId, subid: "refacedx", sections: [
    .first([
      .channel(),
      .voice("Voice", Voice.Controller.ctrlr()),
    ]),
    .banks([
      .bank("Voice Bank", [.bank, .voice]),
    ]),
  ], dirMap: nil, colorGuide: ColorGuide([
    "#ca5e07",
    "#07afca",
    "#fa925f",
  ]), indexPath: .init(item: 1, section: 0))
  
}


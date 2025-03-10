
public enum VolcaFM2 {
  
  static func sysexHeader(_ channel: UInt8) -> [UInt8] {
    [0xf0, 0x42, 0x30 + channel, 0x00, 0x01, 0x2f]
  }

  static func sysex(_ channel: Int, _ cmdBytes: [UInt8]) -> [UInt8] {
    sysexHeader(UInt8(channel)) + cmdBytes + [0xf7]
  }

  static func sysex(_ editor: SynthEditor, _ cmdBytes: [UInt8]) -> [UInt8] {
    let channel = UInt8(editor.basicChannel())
    return sysexHeader(channel) + cmdBytes + [0xf7]
  }


}

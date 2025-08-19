
protocol VirusEditor : SingleDocSynthEditor {
  
}

extension VirusEditor {
  
  var deviceId: UInt8 {
    return UInt8(patch(forPath: [.global])?[[.deviceId]] ?? 16)
  }
  
  var channel: Int {
    return patch(forPath: [.global])?[[.channel]] ?? 0
  }

  func sysexCommand(_ bytes: [UInt8]) -> [UInt8] {
    return VirusTI.sysexHeader + [deviceId] + bytes + [0xf7]
  }
  
  func fetchRequest(_ bytes: [UInt8]) -> RxMidi.FetchCommand {
    return .request(Data(sysexCommand(bytes)))
  }

}

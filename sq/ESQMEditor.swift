
class ESQMEditor : ESQ1Editor {
  
  // keypad command is 0x0f (instead of 0x0e for ESQ-1)
  override class func keyPress(_ channel: Int, _ keys: [UInt8]) -> Data {
    Data([0xf0, 0x0f, 0x02, UInt8(channel), 0x0f] + keys + [0xf7])
  }

  override func patchSendData(patch: ESQPatch) -> [Data] {
    // patch data
    // then exit out of save mode: PROGRAM down, up
    return [
      patch.sysexData(channel: channel),
      Self.keyPress(channel, [0x0d, 0x1d]),
    ]
  }
  
  /// Transform <channel, patchChange, patch> into MIDI out data
  override func voice(input: Observable<(PatchChange, ESQPatch, Bool)>) -> Observable<[Data]?> {
    
    return GenericMidiOut.patchChange(throttle: .milliseconds(300), input: input, paramTransform: { (patch, path, value) -> [Data]? in
      guard let param = type(of: patch).params[path] as? ParamWithRange else { return nil }
      var data = [Data]()

      // removed triggering edit mode via keypress

      let minValue = param.range.lowerBound
      let maxValue = param.range.upperBound

      let byte: Int
      
      if type(of: patch) is SQ80Patch.Type && [3, 13, 23, 33].contains(param.parm) {
        // .velo, .extra
        let patchByte = patch.bytes[param.byte]
        // LV value + lin/exp flag at top bit
        byte = patchByte.bits(2...7) + (patchByte.bit(0) * 64)
      }
      else if type(of: patch) is SQ80Patch.Type && [8, 18, 28, 38].contains(param.parm) {
        // .release, .extra
        let patchByte = patch.bytes[param.byte]
        // T4 value + 2nd release flag at top bit
        byte = patchByte.bits(0...5) + (patchByte.bit(7) * 64)
      }
      else if maxValue == 39 || maxValue == 74 {
        // split layer etc preset select is just straight value
        // so is wave select ONLY on SQ-80!
        byte = value
      }
      else if minValue == -63 {
        // the mapping in the final (below) case was making negative values off by 1.
        byte = value + 64
      }
      else {
        byte = max(0, Int((127 * (Float(value - minValue) / Float(maxValue - minValue))).rounded()))
      }

      data.append(Data(Midi.nrpn(param.parm, value: byte, channel: self.channel)))
      return data
      
    }, patchTransform: { (patch) -> [Data]? in
      self.patchSendData(patch: patch)
      
    }) { (patch, path, name) -> [Data]? in
      self.patchSendData(patch: patch)

    }
  }
  
}

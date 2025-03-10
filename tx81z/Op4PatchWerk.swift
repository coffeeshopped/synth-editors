
extension Op4 {
  
  struct PatchWerk {
    
    let cmdByte: UInt8
    let sysexData: (_ bodyData: [UInt8], _ channel: Int) -> [UInt8]
    let truss: SinglePatchTruss
    let compactTruss: SinglePatchTruss?
    let patchTransform: MidiTransform.Fn<SinglePatchTruss,Int>.Whole
    let nameTransform: MidiTransform.Fn<SinglePatchTruss,Int>.Name
    
    init(_ synth: SynthWerk, _ displayType: String, _ bodyDataCount: Int, namePack: NamePackIso? = nil, params: SynthPathParam, initFile: String = "", cmdByte: UInt8, sysexData: @escaping (_ bodyData: [UInt8], _ channel: Int) -> [UInt8],  parseOffset: Int, compact: (body: Int, namePack: NamePackIso?, parms: [Parm])?) {
      self.cmdByte = cmdByte
      self.sysexData = sysexData
      
      self.truss = try! SinglePatchTruss(synth.id(displayType), bodyDataCount, namePackIso: namePack, params: params, initFile: initFile, createFileData: {
        sysexData($0, 0)
      }, parseOffset: parseOffset)
      
      if let compact = compact {
        self.compactTruss = try! SinglePatchTruss(YamahaCompactTrussWerk.compactDisplayType(truss), compact.body, namePackIso: compact.namePack, params: compact.parms.params())
      }
      else {
        self.compactTruss = nil
      }
      
      self.patchTransform = { (editorVal, bodyData) in
        return [(.sysex(sysexData(bodyData, editorVal)), 100)]
      }
      
      self.nameTransform = { (editorVal, bodyData, path, name) in
        return namePack?.byteRange.map {
          let data = Self.paramData(cmdByte, channel: editorVal, cmdBytes: [UInt8($0), bodyData[$0]])
          return (.sysex(data), 10)
        }
      }

    }
    
    private static func paramData(_ cmdByte: UInt8, channel: Int, cmdBytes: [UInt8]) -> [UInt8] {
      Yamaha.paramData(channel: channel, cmdBytes: [cmdByte] + cmdBytes)
    }
    
    func paramData(channel: Int, cmdBytes: [UInt8]) -> [UInt8] {
      Self.paramData(cmdByte, channel: channel, cmdBytes: cmdBytes)
    }

    func paramSysex(_ channel: Int, _ cmdBytes: [UInt8]) -> MidiMessage {
      .sysex(paramData(channel: channel, cmdBytes: cmdBytes))
    }
    
    func parse(compactData: SinglePatchTruss.BodyData) -> SinglePatchTruss.BodyData {
      truss.parse(otherData: compactData, otherTruss: compactTruss!)
    }
    
    func transform(_ bodyData: SinglePatchTruss.BodyData, intoCompact compactData: inout SinglePatchTruss.BodyData) {
      truss.transform(bodyData, into: &compactData, using: compactTruss!)
    }
  }
}



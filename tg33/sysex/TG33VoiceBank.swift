
class TG33VoiceBank : TypicalTypedSysexPatchBank<TG33VoicePatch>, ChannelizedSysexible {
  
  override class var patchCount: Int { return 64 }
  override class var fileDataCount: Int { return 37631 }
  override class var initFileName: String { return "tg33-bank-init" }
  
  func sysexData(channel: Int) -> Data {
    var data = Data([0xf0, 0x43, UInt8(channel), 0x7e])

    stride(from: 0, to: 64, by: 4).forEach {
      var b = [UInt8]()
      if $0 == 0 {
        b.append(contentsOf: "LM  0012VC".unicodeScalars.map { UInt8($0.value) })
      }
      
      for i in 0..<4 { b.append(contentsOf: patches[$0 + i].bytes) }
      
      let byteCountMSB = UInt8((b.count >> 7) & 0x7f)
      let byteCountLSB = UInt8(b.count & 0x7f)

      data.append(contentsOf: [byteCountMSB, byteCountLSB])
      data.append(contentsOf: b)
      data.append(Patch.checksum(bytes: b))
      
      // TODO: gotta add in those 100ms delays in transmit...
    }
    data.append(0xf7)
    return data
  }
  
  override func fileData() -> Data {
    return sysexData(channel: 0)
  }
  
  required init(data: Data) {
    let offset = 14
    let patchByteCount = 587
    let skipCount = (patchByteCount * 4) + 3 // 4 patches plus 2 header bytes and 1 checksum byte
    
    let mapped: [[Patch]] = stride(from: offset, to: data.count, by: skipCount).map { doff in
      return (0..<4).compactMap { patchIndex in
        let start = 2 + doff + (patchByteCount * patchIndex)
        let endex = start + patchByteCount
        guard endex <= data.count else { return nil }
        let sysex = data.subdata(in: start..<endex)
        return Patch(bankData: sysex)
      }
    }
    let p = [Patch](mapped.joined())
    super.init(patches: p)
  }
  
  required init(patches p: [Patch]) {
    super.init(patches: p)
  }
  
  static let ramBanks: [[String]] = [
    ["SP*Pro33", "SP*Echo", "SP*BelSt", "SP*Full", "SP*Ice", "SP*Dandy", "SP*Arkle", "SP*BrVec", "SP*Matrx", "SP*Gut", "SP*Omni", "SP*Oiled", "SP*Ace", "SP*Quire", "SP*Digit", "SP*Swell", "SC:Groov", "SC*Airy", "SC*Solid", "SC*Sweep", "SC*Drops", "SC*Euro", "SC*Decay", "SC:Steel", "SC*Rude", "SC*Bellz", "SC*Pluck", "SC*Glass", "SC*Wood", "SC*Wire", "SC*Cave", "SC*Wispa", "SL*Sync", "SL*VCO", "SL*Chic", "SL:Mini", "SL*Wisul", "SL*Blues", "SL:Cosmo", "SL*Super", "ME*Vecta", "ME*NuAge", "PC*Hit+", "ME*Glace", "ME*Astro", "ME*Vger", "ME*Hitch", "ME*Indus", "SE*Mount", "SE*5.PM", "SE*FlyBy", "SE*Fear", "SE:Wolvs", "SE*Hades", "SE*Neuro", "SE*Angel", "SQ:MrSeq", "SQ:It", "SQ*Id", "SQ*Wrapa", "SQ*TG809", "SQ*Devol", "DR:Kit", "DR*EFX"],
    ["EP*Arlad", "AP*Piano", "EP*Malet", "AP*ApStr", "EP*DX6Op", "EP*Pin", "EP*NewDX", "EP*Fosta", "OR*Gospl", "OR*Rock", "OR*Pipe", "OR*Perc", "KY*Squez", "KY*Hrpsi", "KY*Celst", "KY*Clavi", "BA*Slap", "BA*Atack", "BA*Seq", "BA*Trad", "BA*Pick", "BA*Syn", "BA:Rezz", "BA:Unisn", "BA:Fingr", "BA*Frtls", "BA:Wood", "PL*Foksy", "PL*12Str", "PL*Mute", "PL*Nylon", "PL*Dist", "BR*Power", "BR*Fanfr", "BR*Class", "BR*Reeds", "BR*Chill", "BR*Zeus", "BR*Moot", "BR*Anlog", "BR:FrHrn", "BR:Trmpt", "BR*Tromb", "WN*Sax", "WN:Pan", "WN:Oboe", "WN:Clart", "WN:Flute", "ST*Arco", "ST:Chmbr", "ST*Full", "ST:Pizza", "ST*CelSt", "ST*Exel", "ST*Synth", "ST*Eroid", "CH*Modrn", "CH*Duwop", "CH*Itopy", "CH*Astiz", "PC:Marim", "PC:Vibes", "PC*Bells", "PC*Clang"],
  ]
}

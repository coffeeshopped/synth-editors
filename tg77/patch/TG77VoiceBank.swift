
class TG77VoiceBank : TypicalTypedSysexPatchBank<TG77VoicePatch> {
  
  override class var patchCount: Int { return 64 }
  override class var initFileName: String { return "tg77-voice-bank-init" }
  
  override func fileData() -> Data {
    return sysexData { $0.sysexData(channel: 0, location: $1) }
  }
  
  override class func isCompleteFetch(sysex: Data) -> Bool {
    return isValid(sysex: sysex)
  }

  override class func isValid(fileSize: Int) -> Bool {
    // there are so many possibilities of valid file sizes, we're fudging.
    return fileSize >= 221 * 64
  }

  override class func isValid(sysex: Data) -> Bool {
    // smallest possible
    guard sysex.count >= 221 * 64 else { return false }
    
    let s = SysexData(data: sysex)
    guard s.count == 64 else { return false }
    for msg in s {
      guard TG77VoicePatch.isValid(fileSize: msg.count) else { return false }
    }
    return true
  }

  
  static let emptyBankOptions = OptionsParam.makeOptions((1...64).map { "\($0)" })
  
  static let preset1: [String] = ["A1. SP|Cosmo", "A2. SP:Metroid", "A3. SP:Diamond", "A4. SP.Sqrpad", "A5. SP|Arianne", "A6. SP:Sawpad", "A7. SP:Darkpad", "A8. SP|Mystery", "A9. SP.Padfaze", "A10. SP:Twilite", "A11. SP|Annapad", "A12. AP.Ivory", "A13. AP|CP77", "A14. AP|Bright", "A15. AP|Hammer", "A16. AP|Grand", "B1. BR:Plucky", "B2. BR|BigBand", "B3. BR:1980", "B4. BR|Trmpets", "B5. BR.ModSyn", "B6. BR|Ensembl", "B7. BR|FrHorn", "B8. BR|Soul", "B9. BR.FM Bite", "B10. EP|IceRing", "B11. EP.Synbord", "B12. EP.GS77", "B13. EP|Knocker", "B14. EP.Beltine", "B15. EP|Dynomod", "B16. EP.Urbane", "C1. ME:St.Mick", "C2. ME|Blad", "C3. ME|Forest", "C4. ME.Gargoyl", "C5. ME|Pikloop", "C6. ME|Aquavox", "C7. ME:Alps", "C8. ME.Cycles", "C9. WN.Bluharp", "C10. WN|Tenor", "C11. WN|Clarino", "C12. WN|AltoSax", "C13. WN|Moothie", "C14. WN|Saxion", "C15. WN.Flute", "C16. WN|Ohboy", "D1. ST.Ripper", "D2. ST:Violins", "D3. ST|Section", "D4. ST.SynStrg", "D5. ST.Chamber", "D6. BA|Frtless", "D7. BA|Starred", "D8. BA.HardOne", "D9. BA:VC1", "D10. BA:VC2", "D11. BA.VC3", "D12. BA.Rox", "D13. BA|Woodbas", "D14. BA.Round", "D15. BA:Erix", "D16. BA.FMFrtls"]
  
  static let preset2: [String] = ["A1. SC:Neworld", "A2. SC.Stratos", "A3. SC.Ripples", "A4. SC.Digitak", "A5. SC.Hone", "A6. SC:Spaces", "A7. SC|Sybaby", "A8. SC|Icedrop", "A9. SC|Wired", "A10. SL.Gnome", "A11. SL.SawMono", "A12. SL:SqrMono", "A13. SL.Pro77", "A14. SL.Nester", "A15. SL:Eazy", "A16. SL:Lips", "B1. KY|Bosh", "B2. KY|Wahclav", "B3. KY.Wires", "B4. KY:Tradclv", "B5. KY.Thumper", "B6. KY|Modclav", "B7. PL.Sitar", "B8. PL.Harp", "B9. PL|Saratog", "B10. PL|Steel", "B11. PL|Twelve", "B12. PL|Shonuff", "B13. PL|MutGtr", "B14. PL.Guitar", "B15. PL.Shami", "B16. PL:Koto", "C1. OR.YC45D", "C2. OR|Pipes", "C3. OR:Jazzman", "C4. OR.Combo", "C5. PC.Marimba", "C6. PC|OzHamer", "C7. PC:Tobago", "C8. PC.Vibes", "C9. PC|Glass", "C10. PC|Island", "C11. PC|GrtWall", "C12. CH.Itopia", "C13. CH:GaChoir", "C14. CH:Chamber", "C15. CH|Spirit", "C16. CH:ChorMst", "D1. SE*Goto>1", "D2. SE.Xpander", "D3. SE*Inferno", "D4. SE*Them!!!", "D5. OR*Gassman", "D6. BR*ZapBras", "D7. BR*BrasOrc", "D8. PL*Stairwy", "D9. ST*Widestg", "D10. ST*Symflow", "D11. ST*Quartet", "D12. ST*Tutti", "D13. ME*Voyager", "D14. ME*Galaxia", "D15. DR Both", "D16. DR Group2"]
  
}

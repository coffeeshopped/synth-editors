
const outOptions = ["Out1 L", "Out1 L + R", "Out1 R", "Out2 L", "Out2 L + R", "Out2 R", "Out3 L", "Out1 L + R", "Out3 R", "Aux1 L", "Aux1 L + R", "Aux1 R", "Aux2 L", "Aux2 L + R", "Aux2 R"]

const volIso = Miso.switcher([
  .int(0, "Off")
], default: Miso.str())

const panIso = Miso.switcher([
  .int(0, "Patch")
], default: Miso.a(-64) >>> Miso.str())

// banks C - H
const presetNames = [
  ["AutoBendBC", "Avenues JS", "Back280sSV", "BC NewVoV3", "BlkvelvtSV", "B-SquareBC", "BusysawsSV", "ChilloutJS", "ChrunchyJS", "ClubbassSV", "ClubtoolBC", "Comm basSV", "CommerseSV", "Contra BC", "CosmicbsSV", "CreameryBC", "Cyclone JS", "Da Funk BC", "Dawn JS", "Decay JS", "Deep9thsBC", "Devlish SV", "DHR Amb BC", "Digedi JS", "Driver SV", "Drmswpr SV", "Duffer BC", "Edgy JS", "Etheral SV", "Far EastJS", "FatWah BC", "Five in1BC", "FlyBy BC", "FnkNastyBC", "Freno BC", "Fripper JS", "Future XSV", "FuturwldSV", "GarBass8BC", "Girls SV", "Glassey SV", "Goatic SV", "GoindownSV", "GoodniteJS", "Gulf JS", "Hifive SV", "HOA Pad SV", "Hollow JS", "Homeboy JS", "HongKongBC", "Hoppin' SV", "IndiArp BC", "IntntentSV", "Jazzy JS", "JoeZolo BC", "KatmanduJS", "KingsizeJS", "LatitudeSV", "Let's goSV", "Lite JS", "LongskrtSV", "Maja JS", "Mamba JS", "MentalitJS", "MetalsynJS", "Move it SV", "MoveMyMWBC", "Muzzle BC", "MWC#ord BC", "MystiqueJS", "NasalbasSV", "NastyFX JS", "NewVoV4 BC", "NoiztoyzJS", "OddgssaySV", "OffSoft BC", "Oil-crwlSV", "OwWah BC", "Pathos BC", "Peace BC", "Pensive BC", "Phlute JS", "Pitchy BC", "PlaycoolSV", "Plugged JS", "Polar JS", "PolyGrovJS", "PseudoTBSV", "Pulsar SV", "Q-Pad BC", "RbbrHrp2BC", "Red lineSV", "ReflxshnBC", "RepeaterJS", "RestlessBC", "Rezoid SV", "Rezzer2 BC", "Rise up!SV", "RubbrHrpBC", "Sawz 2 SV", "Sharp BC", "S&HOrganBC", "Sickly BC", "SilkArp SV", "SinebassJS", "SomethngSV", "SpitfireJS", "Spoiled SV", "SpringPdSV", "Spring SV", "StellarpSV", "StickyPdBC", "SubmergeSV", "T-Axxe JS", "Ten InchJS", "ThirdEarJS", "Tinycat SV", "TiptaptuSV", "T Pot BC", "TwotonesBC", "UniVoV BC", "Vapour SV", "V-Bells JS", "VindictrSV", "Low", ">>INPUT<<", "- Init -", "- START -"],
  ["AndromdaHS", "Arctis HS", "AT-Mini HS", "AwashBs HS", "Backing HS", "BadTape HS", "Begin? HS", "BellBoy BC", "BerimTamHS", "Boingy HS", "BowBouncHS", "Bronze HS", "BubblX HS", "CantburyHS", "ChaosBelHS", "Choir2 HS", "ClubMed HS", "Congoid HS", "CptKork HS", "Cremoma HS", "DancePn HS", "Dangelo HS", "DB-Goer HS", "DinoBassHS", "Dirtron HS", "Dread-0 HS", "Dr.What?HS", "Dublyoo HS", "DX-Pno1 HS", "DX-Pno2 HS", "DX-Pno3 HS", "Dynette HS", "Easter1 HS", "E-Grand HS", "EkoRoad HS", "E.Rigby HS", "Everest HS", "Expense HS", "Flats HS", "Flutes HS", "Flutoon HS", "Froese HS", "FunctionHS", "Ganges HS", "GateRim HS", "Goomby HS", "Ham&X HS", "Harpsie HS", "Hektik HS", "HissPad BC", "JamMini HS", "Jawdan HS", "JazRoad HS", "J.Edgar HS", "JuicOrg HS", "Kitchen HS", "Latex HS", "LordOrg HS", "Macho HS", "Manfman HS", "MarkOne HS", "MarsAtx HS", "Meddle HS", "MelloVl HS", "MinorityHS", "Monza HS", "MoonWeedHS", "Multasm HS", "MW-StepsHS", "Nowhere BC", "NylSolo HS", "Oboe HS", "Oddigy HS", "Old S&H HS", "Orange HS", "Oscar1 HS", "Outpost HS", "PanShakeHS", "PataFiz HS", "PeaceOrgHS", "Picking HS", "PickUp HS", "PingOrg HS", "Pit-Str HS", "Pizza HS", "PlukalogHS", "PopCorn HS", "Prions HS", "Pstyro2 HS", "Pumpah HS", "Qatsi HS", "Quack! HS", "RadioG HS", "Raspry HS", "RuminateHS", "Saloon HS", "Saxpet HS", "Series3 HS", "ShineOn HS", "SidKid HS", "SimSyn HS", "SinSolo HS", "Slapska HS", "Spring HS", "Spy HS", "Squeeze HS", "Squoid HS", "Sunder HS", "Tabloid HS", "TheDome HS", "Thustra HS", "TimeStepHS", "Tunnel HS", "TuvaWeelHS", "TweakMe HS", "TwoOfUs HS", "Untune HS", "Vanilla HS", "Voodoo HS", "Vorwerk HS", "Warlord HS", "Wheee! HS", "WishBom HS", "WoodyBs HS", "X-Didge HS", "X-Werx HS", "Xyrimba HS", "Zorch HS"],
  ["AESound zs", "AldoNovaM", "AmbientBlJ", "AmbientFXJ", "ambiRgM zs", "AnHigh M", "Arcade BC", "Atlas J", "Attack! J", "AutoTknoBC", "BadLand M", "Bass 415 M", "Bass 504 M", "Basser M", "BassIk M", "basting2zs", "basting zs", "B-Deep M", "B-Foe M", "bigTung zs", "Bleu! M", "Blotto M", "Bubble2 M", "CappSt M", "Cavsak M", "cirqStb zs", "CLEeeN M", "Cloakin M", "cutRes zs", "decDATA2zs", "decDATA3zs", "decDATA zs", "deciDAT4zs", "dirty zs", "dopeEp zs", "Dragon M", "dropIT zs", "drpBomb zs", "Drubber BC", "Dry Bass J", "dstStep zs", "Dubsak M", "Dumb! M", "Empira 2M", "Entropie J", "Everest J", "Facial M", "FePudn zs", "FlutDrumBC", "fnkStrg zs", "GBEp3 zs", "george2 zs", "GooHat M", "GotHAM! M", "HIDEson M", "IndustryBC", "LepY2 zs", "LepY3 zs", "lootRng zs", "Lost M", "marimba1zs", "marimba4zs", "MeBad? M", "Menace M", "MONose zs", "mostHih zs", "Mr.Foo M", "Necro M", "NoFuture M", "orguit zs", "phasEP zs", "Plead M", "Pluka zs", "PowerStrnJ", "pulsRay zs", "Quarp BC", "RbbrBellBC", "ReBird M", "resPad zs", "Reverse J", "rmBack zs", "rngPort zs", "Roboe zs", "Shifted BC", "ShineChrdJ", "shivrPd zs", "sineZZZ zs", "sinMorf zs", "sitar zs", "Skware zs", "smoovLd zs", "sneakr zs", "SoftBell J", "Softi J", "SoftSeq. J", "sofueMODzs", "SoSad M", "SpaceNighJ", "spasDrv zs", "Spinner M", "spoolPd zs", "sqPadMM zs", "squar00 zs", "Sr.Goo M", "step2it zs", "Subbass zs", "Sunday M", "Tomita J", "Torque", "UfO 4 M", "UKG2 BC", "UKG BC", "V_Acid#9 M", "V-Acid#4 M", "V-Acid#7 M", "VCS 3a J", "videoG1 zs", "videoG2 zs", "videoG4 zs", "waowLd zs", "Weazel M", "WetThn zs", "Wobble M", "xPandr zs", "yahy zs", "Yeao! M", "ZartPad J", "Zupfi J"],
  ["7thHeavnJS", "Ah RESO JS", "Alert JS", "Anabo|icJS", "Anima JS", "Animate JS", "ArtificlJS", "Bad S JS", "Bassic JS", "Bassta JS", "BasstardJS", "BC VoV-2BC", "BC VoV-3BC", "Beatbox JS", "BElla 2 JS", "BellaArpJS", "Bella JS", "BIG FLY JS", "BigSweepJS", "Birdy JS", "Braxter JV", "CalliopeJS", "Carpets JS", "ChainsawJS", "Chant JS", "Choir 4 BC", "Cold SawJS", "ConcreteJS", "Deeper JS", "Dig Me JS", "Dig ThisJS", "Disco OK", "Donkey JS", "Dukbass+BC", "Dyson+ BC", "EnglArp JS", "EnoesqueJS", "FeedyPadJS", "Feng JuiJS", "FM Bass JS", "For DeepJS", "Frozen JS", "FuzzBellJS", "Fuzzbox JS", "FX Drum JS", "Ghost 2 JS", "Ghost JS", "GinaPad JS", "Glitch OK", "Goa4 it JS", "HackbartJS", "HarmonixJS", "Haunted JS", "Hauntin'JS", "Hovis JS", "Hybrid JS", "Impact MS", "Induced JS", "InfectedJS", "InfinityJS", "JaySync JS", "JunoApg JS", "Justice JS", "KyotoLd JS", "Laville JS", "Lead JS", "MajorityJS", "Mallet JS", "MonolithJS", "Moon PadJS", "MorsSpc JS", "Moving JS", "Nasty JS", "NiceArp JS", "No Age JS", "Odyssey JS", "OldScol OK", "Opener JS", "Organic JS", "Outland JS", "OverloadJS", "OvertoneJS", "Percold JS", "Piggy JS", "PluckMe BC", "PolySin JS", "Prodigy JS", "Puls4thsBC", "Pulsic JV", "Puncher JS", "Quarx JS", "Random JS", "Raw JS", "Rhy-Arp JS", "Rough JS", "ScanJob JS", "SeqIt JS", "Simply JS", "Sim SalaJS", "SinderelJS", "SineBeezJS", "SmoothBsBC", "Soaker JS", "Soaring JS", "Soft3rdsBC", "Soloist JS", "Start UpJS", "Subaqua BC", "Sweeper JS", "Taurus JS", "Tight JS", "Tubez JS", "Tubular JS", "Uprite JS", "V-Birth1 K", "Vienna JS", "Virus B JS", "Voyager JS", "Wailin JS", "WalkaArpJS", "Walker JS", "Wave-PadJS", "Waver JS", "WetFunk BC", "Whirly JS", "X-Bellz JS", "Yucca JS", "Low"],
  ["AandreasM@", "Aerosol J", "AerSynthM@", "AI2 Pad M@", "AirMonixM@", "Apogee M@", "AqutouchM@", "Baggins M@", "BGot90s M@", "BigPadSwM@", "Bowzerz M@", "Cali-AirM@", "CheezwizM@", "Claps2 HS", "Clench BC", "CloudCtyM@", "COMPump M@", "CrossQ BC", "D&B FX", "D&B Geneqa", "D&B Woover", "D'EchoerM@", "DetektorM@", "DigiKoto M", "DontFretM@", "DripDropM@", "Driven M@", "EddiWho?M@", "EPhase BC", "EPStage?M@", "EPTines2M@", "EPWhirlyM@", "EPZeply M@", "ETom2002M@", "Fingers M@", "FMChittrM@", "FourSaws", "FunkLd-1SM", "FunkLd-2SM", "FunkLd-3SM", "FunkLd-4SM", "GedyLeedM@", "Gntle9thM@", "Grander M@", "GrimeyM@", "Hallows M@", "HarmopadM@", "He-VPlukM@", "HoldChrdM@", "HrmadnesM@", "Jetropa M@", "JunoPowrM@", "JV Bass M@", "Kompin' M@", "Korgan M@", "Kyrie M@", "Lektrik M@", "LetsSyncM@", "LongKickSM", "LuckyMan J", "MelodieaM@", "MiniBassSM", "MiniBS-2SM", "MiniBS-3SM", "MiniBS-4SM", "MiniBS-5SM", "MiniLeadSM", "ModsweepM@", "NewSnareBC", "NewWorldM@", "NoizBassM@", "ObiPad J", "OceanusM@", "OhEq-8 M@", "Oh Yeah M@", "O'Pad M@", "OrbteriaM@", "PadLayerM@", "Paiow M@", "Pat'sGR M@", "Pergru M@", "Perky! M@", "PhazplukM@", "Popcomp M@", "PortaPoly@", "ProfeticM@", "PrtaBeloBC", "Punchit2SV", "Punsh itSV", "QMenMW BC", "Replika M@", "ResoChrdJS", "Reveal JS", "RezTailsM@", "RichWind", "RimShot BC", "Ripper JS", "Rollin JS", "Rollups M@", "Saw-Ya! M@", "ShortWAVM@", "Spaced JS", "StarPad J", "Stratus JS", "SubdvisnM@", "SunbeamsJS", "SweePlukM@", "Synchym2M@", "SyncPedlM@", "Tender JS", "TheramosM@", "Tight8s M@", "Tremor JS", "TronFlt M@", "TronStr M@", "TwinPadsM@", "UofYouthM@", "VibePad M@", "VolutionM@", "Wavelet M@", "Whales JS", "WineglasM@", "WowGrowlM@", "WynwouldM@", "X Dream JS", "XitLeft M@", "X-Men JS", "Zyntar M@"],
  ["2-Brass RP", "2-Burst RP", "2-CHORD RP", "7thCORD RP", "80s RP", "101BASS RP", "101-SUB RP", "AlfBass RP", "ARP-BD2 RP", "ARP-HH2 RP", "BANDPAD RP", "BASS ME RP", "BASS-O RP", "BE-ME RP", "BE-TWO RP", "BOWED RP", "BPM-PAD RP", "BRASS-1 RP", "BRASS-2 RP", "BRASS-8 RP", "CHORD-U RP", "CLOCKED RP", "CLUB-TO RP", "CORD 1 RP", "CORDY RP", "DEEBASS RP", "DIS-BD RP", "DSP-SEQ RP", "DSP-V RP", "DX-OEM RP", "DX-VE RP", "EASE RP", "E-CORD RP", "eXtream RP", "FAT-SN. RP", "FENDERB RP", "FILTERS RP", "FLUBBER RP", "GO BASS RP", "HAWSCH RP", "HENDRIX RP", "Howner RP", "IQsnare RP", "K-Organ RP", "K-WERK1 RP", "K-WERK2 RP", "K-Werk3 RP", "LowKick RP", "MAXWave RP", "MELLOTR.RP", "MISTERY RP", "MooBass RP", "MO-TJO RP", "MOVER RP", "MS-10 1 RP", "MS-10 2 RP", "MS-99 RP", "NABASS RP", "NOISeAA RP", "NO-TJO RP", "NOT-PAD#RP", "OBY-PAD RP", "O-ME-2 RP", "Omnef RP", "OZ-LEAD RP", "P6OO RP", "PAD-FLG RP", "PADINGS RP", "PHASA RP", "PickGTR RP", "P-LEAD RP", "PolyPha RP", "P-ORGAN RP", "PRO-12 RP", "Q-TECK RP", "QT-SOFT RP", "RE-BASS RP", "RIBASS RP", "ROBASS RP", "ROBOPAD RP", "R-PEGGI RP", "SADINGS RP", "SFX-VC3 RP", "SFX<X> RP", "SH-123 RP", "SHYCUS RP", "SNARE X RP", "SoLead RP", "SORRY RP", "STEVIE RP", "STR-ARP RP", "STR-II RP", "STRINGS RP", "STR-WoW RP", "T-8 RP", "T-DREAM RP", "TD-SEQ RP", "TEC-ARP RP", "TECBASS RP", "TEC-MOS RP", "TEC-NOS RP", "TEC-STR RP", "TE-T42 RP", "TF BASS RP", "THE-BD2 RP", "TI-BASS RP", "TING RP", "TOMBASS RP", "T-ORGAN RP", "V-2-U RP", "VARPEG RP", "V Cl.HH RP", "VELO-ME RP", "VeloPEW RP", "VICHORD RP", "Vi-Rtro RP", "VITAR RP", "VO-PAD RP", "V Op.HH RP", "VR-78 1 RP", "VR-78 2 RP", "Whl-PAD RP", "WINDO RP", "Wurly RP", "X0X KCK RP", "X MEAN RP", "=BASS= RP", "??F=V RP"],
  ]
  
const parms = [
  ["clock", { p: 0x0f, b: 15, dispOff: 63 }],
  
  ["delay/mode", { b: 16, opts: VirusCVoice.delayModeOptions }],
  ["delay/time", { b: 17, iso: VirusTIVoice.delayTimeIso }],
  ["delay/feedback", { b: 18 }],
  ["delay/rate", { b: 19 }],
  ["delay/depth", { b: 20 }],
  ["delay/shape", { b: 21, opts: VirusTIVoice.delayLFOWaveOptions }],
  ["delay/out", { b: 22, opts: outOptions }],
  ["delay/clock", { b: 23, opts: VirusTIVoice.delayClockOptions }],
  ["delay/color", { b: 24, dispOff: -64 }],
  { prefix: 'part', count: 16, bx: 1, block: [
    ["bank", { p: 0x20, b: 32, opts: ["A", "B", "C", "D", "E", "F", "G", "H"] }],
    ["pgm", { p: 0x21, b: 48 }],
    ["channel", { p: 0x22, b: 64, max: 15, dispOff: 1 }],
    ["key/lo", { p: 0x23, b: 80, iso: Miso.noteName(zeroNote: "C-1") }],
    ["key/hi", { p: 0x24, b: 96, iso: Miso.noteName(zeroNote: "C-1") }],
    ["transpose", { p: 0x25, b: 112, rng: [16, 112], dispOff: -64 }],
    ["detune", { p: 0x26, b: 128, dispOff: -64 }],
    ["volume", { p: 0x27, b: 144, dispOff: -64 }],
    ["innit/volume", { p: 0x28, b: 160, iso: volIso }],
    ["out", { p: 0x29, b: 176, opts: outOptions }],
    ["fx", { p: 0x71, b: 192 }],
    ["pan", { p: 0x0a, b: 208, iso: panIso }],
    ["on", { p: 0x48, b: 240, bit: 0 }],
    ["rcv/volume", { p: 0x49, b: 240, bit: 1 }],
    ["hold", { p: 0x4a, b: 240, bit: 2 }],
    ["priority", { p: 0x4d, b: 240, bit: 5, opts: ["Low", "High"] }],
    ["rcv/pgmChange", { p: 0x4e, b: 240, bit: 6 }],
  ] },
]

const patchTruss = {
  single: 'multi',
  parms: parms,
  initFile: "virusc-multi-init",
  parseBody: ['bytes', { start: 9, count: 256 }],
}

  static func location(forData data: Data) -> Int {
  guard data.count > 8 else { return 0 }
  return Int(data[8])
}

//  subscript(path: SynthPath) -> Int? {
//    get {
//      guard let v = rawValue(path: path) else { return nil }
//      switch path {
//      case "0/wave", "1/wave":
//        let inst = v.bits([0, 7])
//        let set = v.bits([8, 12])
//        return Self.reverseInstMap[set]?[inst] ?? 0
//      default:
//        return v
//      }
//    }
//    set {
//      guard let param = type(of: self).params[path],
//        let newValue = newValue else { return }
//      let off = param.parm * 2
//      switch path {
//      case "0/wave", "1/wave":
//        guard newValue < Self.instMap.count else { return }
//        let item = Self.instMap[newValue]
//        let v = 0.set(bits: [0, 7], value: item.inst).set(bits: [8, 12], value: item.set)
//        bytes[off] = UInt8(v.bits([0, 6]))
//        bytes[off + 1] = UInt8(v.bits([7, 13]))
//      default:
//        bytes[off] = UInt8(newValue.bits([0, 6]))
//        bytes[off + 1] = UInt8(newValue.bits([7, 13]))
//      }
//    }
//  }
  
  
  // TODO
  func randomize() {
    randomizeAllParams()
//    (0..<3).forEach {
//      self["link/$0"] = -1
//    }
//    (0..<4).forEach {
//      self["key/lo/$0"] = 0
//      self["key/hi/$0"] = 127
//    }
//    (0..<2).forEach {
//      self["$0/key/lo"] = 0
//      self["$0/key/hi"] = 127
//    }
//    self["0/volume"] = 127
//    self["0/delay"] = 0
//    self["0/start"] = 0
//    self["1/delay"] = ([0, 10]).random()!
//
//    self["mix"] = 0
}

const bankTruss = {
  singleBank: patchTruss,
  patchCount: 128,
  initFile: "virusc-multi-bank-init",
}

class VirusCMultiBank : TypicalTypedSysexPatchBank<VirusCMultiPatch>, PerfBank {
  
  func sysexData(deviceId: UInt8) -> Data {
    return sysexData { $0.sysexData(deviceId: deviceId, bank: 1, part: UInt8($1)) }
  }
  
  override func fileData() -> Data {
    return sysexData(deviceId: 16)
  }
}

const patchTransform = {
  throttle: 100,
  param: (path, parm, value) => {
    let loPage: [SynthPathItem] = [.fx, .pan]
    guard let param = type(of: patch).params[path] else { return nil }
    let part = path.i(1) ?? 0
    let cmdByte: UInt8 = loPage.contains(path.last!) ? 0x70 : 0x72
    return [Data(self.sysexCommand([cmdByte, UInt8(part), UInt8(param.parm), UInt8(value)]))]
  },
  singlePatch: [[patch.sysexData(deviceId: self.deviceId, bank: 0, part: 0), 10]],
  name: { (patch, path, name) -> [Data]? in
    return [Data(name.bytes(forCount: 10).enumerated().map {
      Data(self.sysexCommand([0x72, 0, UInt8(0x04 + $0.offset), $0.element]))
    }.joined())]
  }
}

const bankTransform = {
  throttle: 0,
  singleBank: loc => [[sysexData(deviceId, 1, loc), 50]],
}
  
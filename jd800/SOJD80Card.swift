
public struct SOJD80Card {
  
  public let name: String
  public let waves: [String]
  
  public let waveOptions: [Int:String]
  
  // numbers are the model (SRJD80-?)
  public static let cards: [Int:SOJD80Card] = [
    1 : drums,
    2 : dance,
    3 : rock,
    4 : strings,
    5 : brass,
    6 : piano,
    7 : guitar,
    8 : accordion,
  ]
  
  public static let cardNameOptions: [Int:String] = {
    var options = [Int:String]()
    cards.forEach { options[$0] = $1.name }
    return options
  }()

  
//  public static let boardMap: [RolandId:SOJD80Card] = [
//    .drums : drums,
//    .dance : dance,
//    .rock : rock,
//    .strings : strings,
//    .brass : brass,
//    .piano : piano,
//    .guitar : guitar,
//    .accordion : accordion,
//    ]
  
  init(name: String, waves: [String]) {
    self.name = name
    self.waves = waves
    
    waveOptions = OptionsParam.makeNumberedOptions(waves, offset: 1)
  }
  
  public static let drums = SOJD80Card(name: "Drums (Standard)", waves: ["Fat Kick", "Solid Kick", "Mach Kick", "Real Kick", "Deep Kick", "Room Kick", "Dry Stick", "Room Stick", "LA SN", "Snappy SN", "Fat SN 1", "Fat SN 2", "Wood SN", "Room SN", "Loose SN", "Whack SN", "Real SN", "Lite SN", "Rock SN", "Hard SN", "R8 rimshot", "AttackTom1", "AttackTom2", "AttackTom3", "Power Tom", "Closed HH1", "Closed HH2", "Open HH", "Crash Cym", "Ride Cym", "Ride Bell", "Verb Claps", "Agogo", "Clave 1", "Clave 2", "Guiro Long", "GuiroShort", "Triangle", "Whistle", "Cowbell 2", "Block 2", "Maraca", "Cabasa Up", "CabasaDown", "Tambourin", "Slap Cga", "Mute Cga 1", "Mute Cga 2", "Hi Conga", "Lo Conga", "Hi Bongo", "Lo Bongo", "Timabale", "Chekere"])
  
  public static let dance = SOJD80Card(name: "Drums (Dance)", waves: ["808 K Shrt", "808 K Long", "909 Kick", "Smash Kick", "Bryt Kick", "Tekno Kick", "Industry K", "Mach Kick", "Butt Kick", "Gate Kick", "Mondo Kick", "808 Rim", "808 SN", "909 SN", "CR78 SN", "Attack SN", "Splat SN", "90's SN", "Dance SN 1", "Dance SN 2", "Hip Hop SN", "Video SN", "Rap SN", "House SN", "Swing SN", "Combo SN", "Disco SN", "606 Tom 1", "606 Tom 2", "Boosh Tom", "Blast Tom", "E Tom", "Rim Tom 1", "Rim Tom 2", "Rim Tom 3", "Rim Tom 4", "808 CHH 1", "808 CHH 2", "808 OHH 1", "808 OHH2", "Lite CHH 1", "Lite CHH 2", "Lite OHH", "808 Cym", "Crash Cym", "808 Claps", "DanceClapz", "808 Conga1", "808 Conga2", "808 Conga3", "808 Clave", "808 Cow", "Cowbell 2", "808 Mca", "Snaps", "Tambourine"])
  
  public static let rock = SOJD80Card(name: "Rock Drums", waves: ["Mondo Kick", "Deep Kick", "Solid Kick", "Ambo Kick", "Reverb K", "Room Stick", "Bigshot SN", "Crack SN", "Atomic SN", "Power SN", "Trash SN", "Hard SN", "Combo SN", "Induced SN", "Rock Tom 1", "Rock Tom 2", "Rock Tom 3", "Rock Tom 4", "Ambo Tom 1", "Ambo Tom 2", "Ambo Tom 3", "Ambo Tom 4", "Room Hat 1", "Room Hat 2", "Room Hat 3", "Room Hat 4", "Open HH", "Crash Cym", "Ride Cym", "Ride Bell", "China Cym", "Cowbell 2", "Tambourine"])
  
  public static let strings = SOJD80Card(name: "Strings", waves: ["Strings 1", "Strings 2", "Strings 3", "Strings Atk", "Pizzicato1", "Pizzicato2", "Pizzicato3"])
  
  public static let brass = SOJD80Card(name: "Brass", waves: ["Tp Sect", "Tb/Tp Sect", "LoSax Sect", "Solo Tp 1", "Solo Tp 2", "Solo Tp 3", "Fat Tp mf", "Fat Tp ff", "Solo Tb mf", "Solo Tb ff", "SoloFlugel", "HarmonMut1", "HarmonMut2", "HarmonMut3"])
  
  public static let piano = SOJD80Card(name: "Grand Piano", waves: ["Grand mf A", "Grand mf B", "Grand mf C", "Grand mf D", "Grand ff A", "Grand ff B", "Grand ff C"])
  
  public static let guitar = SOJD80Card(name: "Guitar", waves: ["NYLON GTR1", "NYLON GTR2", "NYLON GTR3", "6STR GTR 1", "6STR GTR 2", "6STR GTR 3", "12STR GTR1", "12STR GTR2", "12STR GTR3", "GTR HARM", "CLEAN GTR1", "CLEAN GTR1", "CLEAN GTR1", "SYN GTR"])
  
  public static let accordion = SOJD80Card(name: "Accordion", waves: ["Musette 1A", "Musette 1B", "Musette 1C", "Musette 2A", "Musette 2B", "Musette 2C", "Musette 3A", "Musette 3B", "Musette 3C", "Master A", "Master B", "Master C", "Single A", "Single B", "Single C", "Bandneon1A", "Bandneon1B", "Bandneon1C", "Bandneon2A", "Bandneon2B", "Bandneon2C", "MasterBs A", "MasterBs B", "MasterBs C", "Bs/Musett1", "Bs/Musett2", "Bs/Musett3", "Bs/Master", "Bs/Single", "Bs/Bandne1", "Bs/Bandne2"])
  

}


class D50VoicePatch : D50MultiPatch, BankablePatch {
  
  static let bankType: SysexPatchBank.Type = D50VoiceBank.self
  
  static func location(forData data: Data) -> Int {
    let address = RolandAddress(addressBytes(forSysex: data))
    return address / RolandAddress(0x000340)
  }

  
  static let initFileName = "d50-voice-init"

  static func startAddress(_ path: SynthPath?) -> RolandAddress { 0x000000 }
  
  var addressables: [SynthPath:RolandSingleAddressable]
  
  required init(data: Data) {
    let rolandData = RolandData(data: data, addressableType: type(of: self))
    let subpatchAddresses = Self.subpatchAddresses
    addressables = [SynthPath:RolandSingleAddressable]()
    Self.addressableTypes.forEach { (path, addressableType) in
      let subaddress = rolandData.startAddress + subpatchAddresses[path]!
      let subdata = rolandData.data(forAddress: subaddress, size: addressableType.size)
      addressables[path] = addressableType.init(data: addressableType.dummySysexMessage(forContentData: subdata))
    }
  }
  
  
  static let addressableTypes: [SynthPath:RolandSingleAddressable.Type] = [
    [.common]      : D50CommonPatch.self,
    [.hi, .common] : D50ToneCommonPatch.self,
    [.hi, .partial, .i(0)] : D50TonePartialPatch.self,
    [.hi, .partial, .i(1)] : D50TonePartialPatch.self,
    [.lo, .common] : D50ToneCommonPatch.self,
    [.lo, .partial, .i(0)] : D50TonePartialPatch.self,
    [.lo, .partial, .i(1)] : D50TonePartialPatch.self,
    ]
  
  static let subpatchAddresses: [SynthPath:RolandAddress] = [
    [.common]      : 0x0300,
    [.hi, .common] : 0x0100,
    [.hi, .partial, .i(0)] : 0x0000,
    [.hi, .partial, .i(1)] : 0x0040,
    [.lo, .common] : 0x0240,
    [.lo, .partial, .i(0)] : 0x0140,
    [.lo, .partial, .i(1)] : 0x0200,
    ]
  
  
  static func isValid(fileSize: Int) -> Bool {
    return fileSize == fileDataCount || fileSize == 468
  }
  
  func sysexData(deviceId: Int, address: RolandAddress) -> [Data] {
    // get the typical sysex data (1 msg per subpatch)
    let defaultData = defaultSysexData(deviceId: deviceId, address: address).reduce(Data(), +)
    // turn that into a contiguous data space
    let rolandData = RolandData(data: defaultData, addressableType: type(of: self))
    // then turn that into submessages across subpatches
    var outData = [sysexMsg(deviceId: deviceId, rolandData: rolandData, address: rolandData.startAddress, size: 0x0200)]
    outData.append(sysexMsg(deviceId: deviceId, rolandData: rolandData, address: rolandData.startAddress + 0x0200, size: 0x0140))
    return outData
  }
  
  private func sysexMsg(deviceId: Int, rolandData: RolandData, address: RolandAddress, size: RolandAddress) -> Data {
    let bytes = [UInt8](rolandData.data(forAddress: address, size: size))
    var data = Self.dataSetHeader(deviceId: deviceId)
    data.append(Data(address.sysexBytes(count: Self.addressCount)))
    data.append(contentsOf: bytes)
    data.append(Self.checksum(address: address, dataBytes: bytes))
    data.append(0xf7)
    return data
  }

}

class D50CommonPatch : D50SinglePatch {
  
  static let initFileName = ""
  static let nameByteRange = 0..<18
  static let size: RolandAddress = 0x40
  
  static func startAddress(_ path: SynthPath?) -> RolandAddress {
    return 0x000300
  }
  
  var bytes: [UInt8]
  
  required init(data: Data) {
    bytes = Self.contentBytes(forData: data)
  }
  
  func randomize() {
    randomizeAllParams()
    self[[.key, .mode]] = (0...2).random()!
    self[[.volume]] = 100
    self[[.midi, .send]] = 0
    self[[.midi, .rcv]] = 0
    self[[.midi, .pgmChange]] = 0
  }
  
  static let params: SynthPathParam = {
    var p = SynthPathParam()
    p[[.key, .mode]] = OptionsParam(byte: 18, options: ["Whole","Dual","Split","Separate","Whole-S","Dual-S","Split-US","Split-LS","Separate-S",])
    p[[.split]] = RangeParam(byte: 19)
    let portaOptions = OptionsParam.makeOptions(["Upper","Lower","U/L"])
    p[[.porta]] = OptionsParam(byte: 20, options: portaOptions)
    p[[.hold]] = OptionsParam(byte: 21, options: portaOptions)
    p[[.hi, .transpose]] = RangeParam(byte: 22, maxVal: 48, displayOffset: -24)
    p[[.lo, .transpose]] = RangeParam(byte: 23, maxVal: 48, displayOffset: -24)
    p[[.hi, .fine]] = RangeParam(byte: 24, maxVal: 100, displayOffset: -50)
    p[[.lo, .fine]] = RangeParam(byte: 25, maxVal: 100, displayOffset: -50)
    p[[.bend]] = RangeParam(byte: 26, maxVal: 12)
    p[[.aftertouch, .bend]] = RangeParam(byte: 27, maxVal: 24, displayOffset: -12)
    p[[.porta, .time]] = RangeParam(byte: 28, maxVal: 100)
    p[[.out, .mode]] = OptionsParam(byte: 29, options: ["d50-outmode-1","d50-outmode-2","d50-outmode-3","d50-outmode-4"])
    p[[.reverb]] = OptionsParam(byte: 30, options: ["Small Hall", "Medium Hall", "Large Hall", "Chapel", "Box", "Small Metal Room", "Small Room", "Medium Room", "Medium Large Room", "Large Room", "Single Delay (102ms)", "Cross Delay (180ms)", "Cross Delay (224ms)", "Cross Delay (148-296ms)", "Short Gate (200ms)", "Long Gate (480ms)", "Bright Hall", "Large Cave", "Steel Pan", "Delay (248ms)", "Delay (338ms)", "Cross Delay (157ms)", "Cross Delay (252ms)", "Cross Delay (274-137ms)", "Gate Reverb", "Reverse Gate (360ms)", "Reverse Gate (480ms)", "Slap Back 1", "Slap Back 2", "Slap Back 3", "Twisted Space", "Space"])
    p[[.reverb, .balance]] = RangeParam(byte: 31, maxVal: 100)
    p[[.volume]] = RangeParam(byte: 32, maxVal: 100)
    p[[.tone, .balance]] = MisoParam.make(byte: 33, maxVal: 100, displayOffset: -50, iso: toneBalanceIso)
    p[[.chase, .mode]] = OptionsParam(byte: 34, options: ["UL","ULL","ULU"])
    p[[.chase, .level]] = RangeParam(byte: 35, maxVal: 100)
    p[[.chase, .time]] = RangeParam(byte: 36, maxVal: 100)
    let midiTxOptions = (0...16).map { $0 == 0 ? "Basic Ch" : "\($0)" }
    p[[.midi, .send]] = OptionsParam(byte: 37, options: OptionsParam.makeOptions(midiTxOptions))
    let midiRxOptions = (0...16).map { $0 == 0 ? "Off" : "\($0)" }
    p[[.midi, .rcv]] = OptionsParam(byte: 38, options: OptionsParam.makeOptions(midiRxOptions))
    let midiProgOptions = (0...100).map { $0 == 0 ? "Off" : "\($0)" }
    p[[.midi, .pgmChange]] = OptionsParam(byte: 39, options: OptionsParam.makeOptions(midiProgOptions))
    return p
  }()
  
  static let toneBalanceIso = Miso.switcher([
    .range(0...49, Miso.m(-1) >>> Miso.a(50) >>> Miso.unitFormat("L")),
    .int(50, "0"),
    .range(51...100, Miso.a(-50) >>> Miso.unitFormat("U")),
  ])
}

class D50ToneCommonPatch : D50SinglePatch {
  
  static let initFileName = ""
  static let nameByteRange = 0..<10
  static let size: RolandAddress = 0x40
  
  static func startAddress(_ path: SynthPath?) -> RolandAddress {
    return 0x000240
  }
  
  var bytes: [UInt8]
  
  required init(data: Data) {
    bytes = Self.contentBytes(forData: data)
  }
  
  func randomize() {
    randomizeAllParams()
    self[[.partial, .i(0), .on]] = 1
    self[[.partial, .i(1), .on]] = 1
    //    set(value: (90...127).random()!, forParameterKey: "FXOutputLevel")
  }
  
  static func isSynth(structure: Int, partial: Int) -> Bool {
    return partial == 0 ? structure < 2 || structure == 4 : structure <= 3
  }
  
  static let params: SynthPathParam = {
    var p = SynthPathParam()
    p[[.structure]] = OptionsParam(byte: 10, options:  ["d50_Structure-1","d50_Structure-2","d50_Structure-3","d50_Structure-4","d50_Structure-5","d50_Structure-6","d50_Structure-7",])

    let pEnv: SynthPath = [.pitch, .env]
    p[pEnv + [.velo]] = RangeParam(byte: 11, maxVal: 2)
    p[pEnv + [.time, .keyTrk]] = RangeParam(byte: 12, maxVal: 4)
    p[pEnv + [.time, .i(0)]] = RangeParam(byte: 13, maxVal: 50)
    p[pEnv + [.time, .i(1)]] = RangeParam(byte: 14, maxVal: 50)
    p[pEnv + [.time, .i(2)]] = RangeParam(byte: 15, maxVal: 50)
    p[pEnv + [.time, .i(3)]] = RangeParam(byte: 16, maxVal: 50)
    p[pEnv + [.level, .i(-1)]] = RangeParam(byte: 17, maxVal: 100, displayOffset: -50)
    p[pEnv + [.level, .i(0)]] = RangeParam(byte: 18, maxVal: 100, displayOffset: -50)
    p[pEnv + [.level, .i(1)]] = RangeParam(byte: 19, maxVal: 100, displayOffset: -50)
    p[pEnv + [.level, .i(2)]] = RangeParam(byte: 20, maxVal: 100, displayOffset: -50)
    p[pEnv + [.level, .i(3)]] = RangeParam(byte: 21, maxVal: 100, displayOffset: -50)
    p[[.pitch, .lfo]] = RangeParam(byte: 22, maxVal: 100)
    p[[.pitch, .bend]] = RangeParam(byte: 23, maxVal: 100)
    p[[.pitch, .aftertouch]] = RangeParam(byte: 24, maxVal: 100)
    for i in 0..<3 {
      let off = i*4
      let lfo: SynthPath = [.lfo, .i(i)]
      p[lfo + [.wave]] = OptionsParam(byte: 25+off, options: ["Tri","Saw","Squ","Rnd"])
      p[lfo + [.rate]] = RangeParam(byte: 26+off, maxVal: 100)
      p[lfo + [.delay]] = RangeParam(byte: 27+off, maxVal: 100)
      p[lfo + [.sync]] = OptionsParam(byte: 28+off, options: i == 0 ? ["Off","On","Key"] : ["Off","On"])
    }
    p[[.lo, .freq]] = OptionsParam(byte: 37, options: ["63","75","88","105","125","150","175","210","250","300","350","420","500","600","700","840"])
    p[[.lo, .gain]] = RangeParam(byte: 38, maxVal: 24, displayOffset: -12)
    p[[.hi, .freq]] = OptionsParam(byte: 39, options: ["250","300","350","420","500","600","700","840","1.0k","1.2k","1.4k","1.7k","2.0k","2.4k","2.8k","3.4k","4.0k","4.8k","5.7k","6.7k","8.0k","9.5k"])
    p[[.hi, .q]] = OptionsParam(byte: 40, options: ["0.3","0.5","0.7","1.0","1.4","2.0","3.0","4.2","6.0"])
    p[[.hi, .gain]] = RangeParam(byte: 41, maxVal: 24, displayOffset: -12)
    p[[.chorus, .type]] = OptionsParam(byte: 42, options: ["Chorus 1","Chorus 2","Flanger 1","Flanger 2","Feedback Chorus","Tremolo","Chorus Tremolo","Dimension"])
    p[[.chorus, .rate]] = RangeParam(byte: 43, maxVal: 100)
    p[[.chorus, .depth]] = RangeParam(byte: 44, maxVal: 100)
    p[[.chorus, .balance]] = RangeParam(byte: 45, maxVal: 100)
    p[[.partial, .i(0), .on]] = RangeParam(byte: 46, bit: 0)
    p[[.partial, .i(1), .on]] = RangeParam(byte: 46, bit: 1)
    p[[.partial, .balance]] = MisoParam.make(byte: 47, maxVal: 100, displayOffset: -50, iso: partialBalanceIso)
    
    return p
  }()
  
  static let partialBalanceIso = Miso.switcher([
    .range(0...49, Miso.m(-1) >>> Miso.a(50) >>> Miso.unitFormat("P1")),
    .int(50, "0"),
    .range(51...100, Miso.a(-50) >>> Miso.unitFormat("P2")),
  ])
  
}

class D50TonePartialPatch : D50SinglePatch {
  
  static let initFileName = ""
  static let size: RolandAddress = 0x40
  
  static func startAddress(_ path: SynthPath?) -> RolandAddress {
    return 0x000140
  }
  
  var bytes: [UInt8]
  
  required init(data: Data) {
    bytes = Self.contentBytes(forData: data)
  }
  
  func randomize() {
    randomizeAllParams()
    
    self[[.amp, .level]] = (90...100).random()!
    self[[.amp, .env, .time, .i(0)]] = (0...20).random()!
    self[[.amp, .env, .level, .i(0)]] = (90...100).random()!
    // TODO: randomization is happening at the parent level! this is being ignored
    // track pitch normally
    self[[.pitch, .keyTrk]] = 11
    // pitch env off
    self[[.pitch, .env, .mode]] = 0
  }
  
  
  static let lfoSelectOptions = OptionsParam.makeOptions(["LFO 1 (+)","LFO 1 (-)","LFO 2 (+)","LFO 2 (-)","LFO 3 (+)","LFO 3 (-)"])
  
  static let params: SynthPathParam = {
    var p = SynthPathParam()
    p[[.coarse]] = RangeParam(byte: 0)
    p[[.fine]] = RangeParam(byte: 1, maxVal: 100, displayOffset: -50)
    p[[.pitch, .keyTrk]] = MisoParam.make(byte: 2, maxVal: 16, iso: Miso.options(pitchKeyTrkOptions))
    p[[.pitch, .lfo, .mode]] = OptionsParam(byte: 3, options: ["Off","(+)","(-)","A&L"])
    p[[.pitch, .env, .mode]] = OptionsParam(byte: 4, options: ["Off","(+)","(-)"])
    p[[.bend, .mode]] = OptionsParam(byte: 5, options: ["Off","Keyfollow","Normal"])
    p[[.wave]] = OptionsParam(byte: 6, options: ["Square","Saw"])
    p[[.pcm, .wave]] = OptionsParam(byte: 7, options: pcmOptions)
    p[[.pw]] = RangeParam(byte: 8, maxVal: 100)
    p[[.pw, .velo]] = RangeParam(byte: 9, maxVal: 14, displayOffset: -7)
    p[[.pw, .lfo]] = OptionsParam(byte: 10, options: lfoSelectOptions)
    p[[.pw, .lfo, .depth]] = RangeParam(byte: 11, maxVal: 100)
    p[[.pw, .aftertouch]] = RangeParam(byte: 12, maxVal: 14, displayOffset: -7)
    p[[.filter, .cutoff]] = RangeParam(byte: 13, maxVal: 100)
    p[[.filter, .reson]] = RangeParam(byte: 14, maxVal: 30)
    p[[.filter, .keyTrk]] = MisoParam.make(byte: 15, maxVal: 14, iso: Miso.options(keyTrkOptions))
    p[[.filter, .bias, .pt]] = OptionsParam(byte: 16, options: biasPtOptions)
    p[[.filter, .bias, .level]] = RangeParam(byte: 17, maxVal: 14, displayOffset: -7)
    let fEnv: SynthPath = [.filter, .env]
    p[fEnv + [.depth]] = RangeParam(byte: 18, maxVal: 100)
    p[fEnv + [.velo]] = RangeParam(byte: 19, maxVal: 100)
    p[fEnv + [.depth, .keyTrk]] = RangeParam(byte: 20)
    p[fEnv + [.time, .keyTrk]] = RangeParam(byte: 21)
    (0..<4).forEach {
      p[fEnv + [.time, .i($0)]] = RangeParam(byte: 22+$0, maxVal: 100)
      p[fEnv + [.level, .i($0)]] = RangeParam(byte: 27+$0, maxVal: 100)
    }
    p[fEnv + [.time, .i(4)]] = RangeParam(byte: 26, maxVal: 100)
    p[fEnv + [.level, .i(4)]] = OptionsParam(byte: 31, options: ["0","100"])
    p[[.filter, .lfo]] = OptionsParam(byte: 32, options: lfoSelectOptions)
    p[[.filter, .lfo, .depth]] = RangeParam(byte: 33, maxVal: 100)
    p[[.filter, .aftertouch]] = RangeParam(byte: 34, maxVal: 14, displayOffset: -7)
    p[[.amp, .level]] = RangeParam(byte: 35, maxVal: 100)
    p[[.amp, .velo]] = RangeParam(byte: 36, maxVal: 100, displayOffset: -50)
    p[[.amp, .bias, .pt]] = OptionsParam(byte: 37, options: biasPtOptions)
    p[[.amp, .bias, .level]] = RangeParam(byte: 38, maxVal: 12, displayOffset: -12)
    let aEnv: SynthPath = [.amp, .env]
    (0..<4).forEach {
      p[aEnv + [.time, .i($0)]] = RangeParam(byte: 39+$0, maxVal: 100)
      p[aEnv + [.level, .i($0)]] = RangeParam(byte: 44+$0, maxVal: 100)
    }
    p[aEnv + [.time, .i(4)]] = RangeParam(byte: 43, maxVal: 100)
    p[aEnv + [.level, .i(4)]] = OptionsParam(byte: 48, options: ["0","100"])
    p[aEnv + [.velo, .keyTrk]] = RangeParam(byte: 49)
    p[aEnv + [.time, .keyTrk]] = RangeParam(byte: 50)
    p[[.amp, .lfo]] = OptionsParam(byte: 51, options: lfoSelectOptions)
    p[[.amp, .lfo, .depth]] = RangeParam(byte: 52, maxVal: 100)
    p[[.amp, .aftertouch]] = RangeParam(byte: 53, maxVal: 14, displayOffset: -7)
    
    return p
  }()
  
  static let pcmOptions = OptionsParam.makeOptions(["Marimba",  "Vibraphone",  "Xylophone 1",  "Xylophone 2",  "Log Bass",  "Hammer",  "Japanese Drum",  "Kalimba",  "Pluck 1",  "Chink",  "Agogo",  "Triangle",  "Bells",  "Nail File",  "Pick",  "Low Piano",  "Mid Piano",  "High Piano",  "Harpsichord",  "Harp",  "Organ Percussion",  "Steel Strings",  "Nylon Strings",  "Electric Guitar 1",  "Electric Guitar 2",  "Dirty Guitar",  "Pick Bass",  "Pop Bass",  "Thump",  "Upright Bass",  "Clarinet",  "Breath",  "Steamer",  "High Flute",  "Low Flute",  "Guiro",  "Indian Flute",  "Flute Harmonics",  "Lips 1",  "Lips 2",  "Trumpet",  "Trombones",  "Contrabass",  "Cello",  "Violin Bow",  "Violins",  "Pizzicart",  "Draw bars (Lp)",  "High Organ (Lp)",  "Low Organ (Lp)",  "Electric Piano (Lp 1)",  "Electric Piano (Lp 2)",  "Clavi (Lp)",  "Harpsichord (Lp)",  "Electric Bass (Lp 1)",  "Acoustic Bass (Lp)",  "Electric Bass (Lp 2)",  "Electric Bass (Lp 3)",  "Electric Guitar (Lp)",  "Cello (Lp)",  "Violin (Lp)",  "Reed (Lp)",  "Sax (Lp 1)",  "Sax (Lp 2)",  "Aah (Lp)",  "Ooh (Lp)",  "Male (Lp 1)",  "Spectrum 1 (Lp)",  "Spectrum 2 (Lp)",  "Spectrum 3 (Lp)",  "Spectrum 4 (Lp)",  "Spectrum 5 (Lp)",  "Spectrum 6 (Lp)",  "Spectrum 7 (Lp)",  "Male (Lp 2)",  "Noise (Lp)",  "Loop 1",  "Loop 2",  "Loop 3",  "Loop 4",  "Loop 5",  "Loop 6",  "Loop 7",  "Loop 8",  "Loop 9",  "Loop 1O",  "Loop 11",  "Loop 12",  "Loop 13",  "Loop 14",  "Loop 15",  "Loop 16",  "Loop 17",  "Loop 18",  "Loop 19",  "Loop 20",  "Loop 21",  "Loop 22",  "Loop 23",  "Loop 24",])
  
  static let biasPtOptions: [Int:String] = {
    let notes = ["A","A#","B","C","C#","D","D#","E","F","F#","G","G#"]
    var options: [String] = (0..<64).map {
      let note = notes[$0 % 12]
      let octave = ($0+9)/12 + 1
      return "<\(note)\(octave)"
    }
    options += (0..<64).map {
      let note = notes[$0 % 12]
      let octave = ($0+9)/12 + 1
      return ">\(note)\(octave)"      
    }
    return OptionsParam.makeOptions(options)
  }()
  
  static let keyTrkOptions = ["-1", "-1/2", "-1/4", "0", "1/8", "1/4", "3/8", "1/2", "5/8", "3/4", "7/8", "1", "5/4", "3/2", "2"]
  static let pitchKeyTrkOptions = keyTrkOptions + ["s1", "s2"]
}

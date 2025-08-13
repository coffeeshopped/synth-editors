

const toneBalanceIso = Miso.switcher([
  .range([0, 49], Miso.m(-1) >>> Miso.a(50) >>> Miso.unitFormat("L")),
  .int(50, "0"),
  .range([51, 100], Miso.a(-50) >>> Miso.unitFormat("U")),
])

let portaOptions = ["Upper","Lower","U/L"]

const commonParms = [
  ["key/mode", { b: 18, opts: ["Whole","Dual","Split","Separate","Whole-S","Dual-S","Split-US","Split-LS","Separate-S",] }],
  ["split", { b: 19 }],
  ["porta", { b: 20, opts: portaOptions }],
  ["hold", { b: 21, opts: portaOptions }],
  ["hi/transpose", { b: 22, max: 48, dispOff: -24 }],
  ["lo/transpose", { b: 23, max: 48, dispOff: -24 }],
  ["hi/fine", { b: 24, max: 100, dispOff: -50 }],
  ["lo/fine", { b: 25, max: 100, dispOff: -50 }],
  ["bend", { b: 26, max: 12 }],
  ["aftertouch/bend", { b: 27, max: 24, dispOff: -12 }],
  ["porta/time", { b: 28, max: 100 }],
  ["out/mode", { b: 29, opts: ["d50-outmode-1","d50-outmode-2","d50-outmode-3","d50-outmode-4"] }],
  ["reverb", { b: 30, opts: ["Small Hall", "Medium Hall", "Large Hall", "Chapel", "Box", "Small Metal Room", "Small Room", "Medium Room", "Medium Large Room", "Large Room", "Single Delay (102ms)", "Cross Delay (180ms)", "Cross Delay (224ms)", "Cross Delay (148-296ms)", "Short Gate (200ms)", "Long Gate (480ms)", "Bright Hall", "Large Cave", "Steel Pan", "Delay (248ms)", "Delay (338ms)", "Cross Delay (157ms)", "Cross Delay (252ms)", "Cross Delay (274-137ms)", "Gate Reverb", "Reverse Gate (360ms)", "Reverse Gate (480ms)", "Slap Back 1", "Slap Back 2", "Slap Back 3", "Twisted Space", "Space"] }],
  ["reverb/balance", { b: 31, max: 100 }],
  ["volume", { b: 32, max: 100 }],
  ["tone/balance", { b: 33, max: 100, dispOff: -50, iso: toneBalanceIso }],
  ["chase/mode", { b: 34, opts: ["UL","ULL","ULU"] }],
  ["chase/level", { b: 35, max: 100 }],
  ["chase/time", { b: 36, max: 100 }],
  let midiTxOptions = ([0, 16]).map { $0 == 0 ? "Basic Ch" : `${$0}` }
  ["midi/send", { b: 37, opts: midiTxOptions }],
  let midiRxOptions = ([0, 16]).map { $0 == 0 ? "Off" : `${$0}` }
  ["midi/rcv", { b: 38, opts: midiRxOptions }],
  let midiProgOptions = ([0, 100]).map { $0 == 0 ? "Off" : `${$0}` }
  ["midi/pgmChange", { b: 39, opts: midiProgOptions }],
]

const commonPatchWerk = {
  single: 'd50.voice.common',
  namePack: [0, 17],
  size: 0x40,
  parms: commonParms,
}

// func randomize() {
  // self["key/mode"] = ([0, 2]).random()!
  // self["volume"] = 100
  // self["midi/send"] = 0
  // self["midi/rcv"] = 0
  // self["midi/pgmChange"] = 0
// }


static func isSynth(structure: Int, partial: Int) -> Bool {
  return partial == 0 ? structure < 2 || structure == 4 : structure <= 3
}

const partialBalanceIso = Miso.switcher([
  .range([0, 49], Miso.m(-1) >>> Miso.a(50) >>> Miso.unitFormat("P1")),
  .int(50, "0"),
  .range([51, 100], Miso.a(-50) >>> Miso.unitFormat("P2")),
])

const toneCommonParms = [
  ["structure", { b: 10, opts: ["d50_Structure-1","d50_Structure-2","d50_Structure-3","d50_Structure-4","d50_Structure-5","d50_Structure-6","d50_Structure-7",] }],
  { prefix: 'pitch/env', block: [
    ["velo", { b: 11, max: 2 }],
    ["time/keyTrk", { b: 12, max: 4 }],
    ["time/0", { b: 13, max: 50 }],
    ["time/1", { b: 14, max: 50 }],
    ["time/2", { b: 15, max: 50 }],
    ["time/3", { b: 16, max: 50 }],
    ["level/-1", { b: 17, max: 100, dispOff: -50 }],
    ["level/0", { b: 18, max: 100, dispOff: -50 }],
    ["level/1", { b: 19, max: 100, dispOff: -50 }],
    ["level/2", { b: 20, max: 100, dispOff: -50 }],
    ["level/3", { b: 21, max: 100, dispOff: -50 }],
  ] },
  ["pitch/lfo", { b: 22, max: 100 }],
  ["pitch/bend", { b: 23, max: 100 }],
  ["pitch/aftertouch", { b: 24, max: 100 }],
  { prefix: 'lfo', count: 3, bx: 4, block: i => [
    ["wave", { b: 25, opts: ["Tri","Saw","Squ","Rnd"] }],
    ["rate", { b: 26, max: 100 }],
    ["delay", { b: 27, max: 100 }],
    ["sync", { b: 28, opts: i == 0 ? ["Off","On","Key"] : ["Off","On"] }],
  ] },
  ["lo/freq", { b: 37, opts: ["63","75","88","105","125","150","175","210","250","300","350","420","500","600","700","840"] }],
  ["lo/gain", { b: 38, max: 24, dispOff: -12 }],
  ["hi/freq", { b: 39, opts: ["250","300","350","420","500","600","700","840","1.0k","1.2k","1.4k","1.7k","2.0k","2.4k","2.8k","3.4k","4.0k","4.8k","5.7k","6.7k","8.0k","9.5k"] }],
  ["hi/q", { b: 40, opts: ["0.3","0.5","0.7","1.0","1.4","2.0","3.0","4.2","6.0"] }],
  ["hi/gain", { b: 41, max: 24, dispOff: -12 }],
  ["chorus/type", { b: 42, opts: ["Chorus 1","Chorus 2","Flanger 1","Flanger 2","Feedback Chorus","Tremolo","Chorus Tremolo","Dimension"] }],
  ["chorus/rate", { b: 43, max: 100 }],
  ["chorus/depth", { b: 44, max: 100 }],
  ["chorus/balance", { b: 45, max: 100 }],
  ["partial/0/on", { b: 46, bit: 0 }],
  ["partial/1/on", { b: 46, bit: 1 }],
  ["partial/balance", { b: 47, max: 100, dispOff: -50, iso: partialBalanceIso }],
]

const toneCommonPatchWerk = {
  single: 'd50.voice.tonecommon',
  namePack: [0, 9],
  size: 0x40,
}

// func randomize() {
  // randomizeAllParams()
  // self["partial/0/on"] = 1
  // self["partial/1/on"] = 1
  // //    set(value: ([90, 127]).random()!, forParameterKey: "FXOutputLevel")
// }

const lfoSelectOptions = ["LFO 1 (+)","LFO 1 (-)","LFO 2 (+)","LFO 2 (-)","LFO 3 (+)","LFO 3 (-)"]
  
const pcmOptions = ["Marimba",  "Vibraphone",  "Xylophone 1",  "Xylophone 2",  "Log Bass",  "Hammer",  "Japanese Drum",  "Kalimba",  "Pluck 1",  "Chink",  "Agogo",  "Triangle",  "Bells",  "Nail File",  "Pick",  "Low Piano",  "Mid Piano",  "High Piano",  "Harpsichord",  "Harp",  "Organ Percussion",  "Steel Strings",  "Nylon Strings",  "Electric Guitar 1",  "Electric Guitar 2",  "Dirty Guitar",  "Pick Bass",  "Pop Bass",  "Thump",  "Upright Bass",  "Clarinet",  "Breath",  "Steamer",  "High Flute",  "Low Flute",  "Guiro",  "Indian Flute",  "Flute Harmonics",  "Lips 1",  "Lips 2",  "Trumpet",  "Trombones",  "Contrabass",  "Cello",  "Violin Bow",  "Violins",  "Pizzicart",  "Draw bars (Lp)",  "High Organ (Lp)",  "Low Organ (Lp)",  "Electric Piano (Lp 1)",  "Electric Piano (Lp 2)",  "Clavi (Lp)",  "Harpsichord (Lp)",  "Electric Bass (Lp 1)",  "Acoustic Bass (Lp)",  "Electric Bass (Lp 2)",  "Electric Bass (Lp 3)",  "Electric Guitar (Lp)",  "Cello (Lp)",  "Violin (Lp)",  "Reed (Lp)",  "Sax (Lp 1)",  "Sax (Lp 2)",  "Aah (Lp)",  "Ooh (Lp)",  "Male (Lp 1)",  "Spectrum 1 (Lp)",  "Spectrum 2 (Lp)",  "Spectrum 3 (Lp)",  "Spectrum 4 (Lp)",  "Spectrum 5 (Lp)",  "Spectrum 6 (Lp)",  "Spectrum 7 (Lp)",  "Male (Lp 2)",  "Noise (Lp)",  "Loop 1",  "Loop 2",  "Loop 3",  "Loop 4",  "Loop 5",  "Loop 6",  "Loop 7",  "Loop 8",  "Loop 9",  "Loop 1O",  "Loop 11",  "Loop 12",  "Loop 13",  "Loop 14",  "Loop 15",  "Loop 16",  "Loop 17",  "Loop 18",  "Loop 19",  "Loop 20",  "Loop 21",  "Loop 22",  "Loop 23",  "Loop 24",]

const biasPtOptions: [Int:String] = {
  let notes = ["A","A#","B","C","C#","D","D#","E","F","F#","G","G#"]
  var options: [String] = (0..<64).map {
    let note = notes[$0 % 12]
    let octave = ($0+9)/12 + 1
    return `<${note}\(octave)`
  }
  options += (0..<64).map {
    let note = notes[$0 % 12]
    let octave = ($0+9)/12 + 1
    return `>${note}\(octave)`      
  }
  return options
}()

const keyTrkOptions = ["-1", "-1/2", "-1/4", "0", "1/8", "1/4", "3/8", "1/2", "5/8", "3/4", "7/8", "1", "5/4", "3/2", "2"]
const pitchKeyTrkOptions = keyTrkOptions + ["s1", "s2"]

const tonePartialParms = [
  { inc: 1, b: 0, block: [
    ["coarse", { }],
    ["fine", { max: 100, dispOff: -50 }],
    ["pitch/keyTrk", { max: 16, iso: Miso.options(pitchKeyTrkOptions) }],
    ["pitch/lfo/mode", { opts: ["Off","(+)","(-)","A&L"] }],
    ["pitch/env/mode", { opts: ["Off","(+)","(-)"] }],
    ["bend/mode", { opts: ["Off","Keyfollow","Normal"] }],
    ["wave", { opts: ["Square","Saw"] }],
    ["pcm/wave", { opts: pcmOptions }],
    ["pw", { max: 100 }],
    ["pw/velo", { max: 14, dispOff: -7 }],
    ["pw/lfo", { opts: lfoSelectOptions }],
    ["pw/lfo/depth", { max: 100 }],
    ["pw/aftertouch", { max: 14, dispOff: -7 }],
    { prefix: 'filter', block: [
      ["cutoff", { max: 100 }],
      ["reson", { max: 30 }],
      ["keyTrk", { max: 14, iso: Miso.options(keyTrkOptions) }],
      ["bias/pt", { opts: biasPtOptions }],
      ["bias/level", { max: 14, dispOff: -7 }],
      { prefix: "env", block: [
        ["depth", { max: 100 }],
        ["velo", { max: 100 }],
        ["depth/keyTrk", { }],
        ["time/keyTrk", { }],
        ["time/0", { max: 100 }],
        ["time/1", { max: 100 }],
        ["time/2", { max: 100 }],
        ["time/3", { max: 100 }],
        ["time/4", { max: 100 }],
        ["level/0", { max: 100 }],
        ["level/1", { max: 100 }],
        ["level/2", { max: 100 }],
        ["level/3", { max: 100 }],
        ["level/4", { opts: ["0","100"] }],
      ] },
      ["lfo", { opts: lfoSelectOptions }],
      ["lfo/depth", { max: 100 }],
      ["aftertouch", { max: 14, dispOff: -7 }],
    ] },
    { prefix: 'amp', block: [
      ["level", { max: 100 }],
      ["velo", { max: 100, dispOff: -50 }],
      ["bias/pt", { opts: biasPtOptions }],
      ["bias/level", { max: 12, dispOff: -12 }],
      { prefix: 'env', block: [
        ["time/0", { max: 100 }],
        ["time/1", { max: 100 }],
        ["time/2", { max: 100 }],
        ["time/3", { max: 100 }],
        ["time/4", { max: 100 }],
        ["level/0", { max: 100 }],
        ["level/1", { max: 100 }],
        ["level/2", { max: 100 }],
        ["level/3", { max: 100 }],
        ["level/4", { opts: ["0","100"] }],
        ["velo/keyTrk", { }],
        ["time/keyTrk", { }],
      ] },
      ["lfo", { opts: lfoSelectOptions }],
      ["lfo/depth", { max: 100 }],
      ["aftertouch", { max: 14, dispOff: -7 }],
    ] },
  ] }
]

const tonePartialPatchWerk = {
  single: 'd50.tonepartial',
  parms: tonePartialParms,
  size: 0x40,
}

  // func randomize() {
  // self["amp/level"] = ([90, 100]).random()!
  // self["amp/env/time/0"] = ([0, 20]).random()!
  // self["amp/env/level/0"] = ([90, 100]).random()!
  // // track pitch normally
  // self["pitch/keyTrk"] = 11
  // // pitch env off
// self["pitch/env/mode"] = 0

static func location(forData data: Data) -> Int {
  let address = RolandAddress(addressBytes(forSysex: data))
  return address / RolandAddress(0x000340)
}

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

const patchWerk = {
  multi: "voice",
  map: [
    ["common", 0x0300, commonPatchWerk,
    ["hi/common", 0x0100, toneCommonPatchWerk,
    ["hi/partial/0", 0x0000, tonePartialPatchWerk,
    ["hi/partial/1", 0x0040, tonePartialPatchWerk,
    ["lo/common", 0x0240, toneCommonPatchWerk,
    ["lo/partial/0", 0x0140, tonePartialPatchWerk,
    ["lo/partial/1", 0x0200, tonePartialPatchWerk,
  ],
  initFile: "d50-voice-init",
}

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




const bankWerk = {
  multiBank: patchWerk,
  patchCount: 64,
  initFile: "d50-voice-bank-init",
}
class D50VoiceBank : TypicalTypedRolandAddressableBank<D50VoicePatch> {
  
  override class func offsetAddress(location: Int) -> RolandAddress {
    return RolandAddress(0x000340) * location
  }

  override class func startAddress(_ path: SynthPath?) -> RolandAddress {
    return 0x020000
  }

  override class var fileDataCount: Int { return 36048 } // this includes reverb, hm.
  
  // 33152: Patch Base format, just the patches
  // 36048: native, compact, 1 msg format. same as dump
  // 29958: handshake format
  override class func isValid(fileSize: Int) -> Bool {
    return [fileDataCount, 33152, 29958].contains(fileSize)
  }
    
  required init(data: Data) {
    let rData = RolandData(data: data, addressableType: Patch.self)
    let startAddress = type(of: self).startAddress()
    let selfType = type(of: self)
    let p: [Patch] = (0..<selfType.patchCount).map {
      let address = startAddress + selfType.offsetAddress(location: $0)
      let d = selfType.sysexMsg(deviceId: 0, rolandData: rData, address: address, size: Patch.size)
      return Patch.init(data: d)
    }
    
    // save the reverb data
    let sysex = SysexData(data: data)
    let cutoffAddress: RolandAddress = 0x036000
    reverbData = sysex.compactMap {
      guard selfType.address(forSysex: $0) >= cutoffAddress else { return nil }
      return $0
    }.reduce(Data(), +)

    super.init(patches: p)
  }
  
  required init(patches p: [Patch]) {
    self.reverbData = Self.init().reverbData
    super.init(patches: p)
  }
  
  private static func sysexMsg(deviceId: Int, rolandData: RolandData, address: RolandAddress, size: RolandAddress) -> Data {
    let bytes = [UInt8](rolandData.data(forAddress: address, size: size))
    var data = D50VoicePatch.dataSetHeader(deviceId: deviceId)
    data.append(Data(address.sysexBytes(count: addressCount)))
    data.append(contentsOf: bytes)
    data.append(checksum(address: address, dataBytes: bytes))
    data.append(0xf7)
    return data
  }

  func sysexData(deviceId: Int, address: RolandAddress) -> [Data] {
    let defaultData = defaultSysexData(deviceId: deviceId, address: address).reduce(Data(), +)
    let rData = RolandData(data: defaultData, addressableType: type(of: self))
    var address = rData.startAddress
    var data = [Data]()
    while address < rData.endAddress {
      let size: RolandAddress = min((rData.endAddress - address), 0x200)
      data.append(type(of: self).sysexMsg(deviceId: deviceId, rolandData: rData, address: address, size: size))
      address = address + size
    }
    data.append(reverbData)
    return data
  }

  // need deviceId of ZERO, not 16 (as is usual for Roland)...
  override open func fileData() -> Data {
    return sysexData(deviceId: 0, address: type(of: self).fileDataAddress).reduce(Data(), +)
  }


}

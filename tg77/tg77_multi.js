
const indivOutOptions = ([0, 8]).map { $0 == 0 ? "Off" : `${$0}` }

const voiceBankOptions = ["Int", "P1", "P2", "Card"]

// common

const commonParms = [
  // FX
  ["fx/mode", { p: 0x0800, parm2: 0x0000, b: 20, opts: Voice.fxModeOptions }],
  { prefix: 'fx/chorus', count: 2, bx: 7, block: (i) => {
    const off = i * 7
    return [
      ["type", { p: 0x0800, parm2: 0x0001 + off, b: 21, opts: Voice.chorusOptions }],
      ["balance", { p: 0x0800, parm2: 0x0002 + off, b: 22, max: 100 }],
      ["level", { p: 0x0800, parm2: 0x0003 + off, b: 23, max: 100 }],
      ["param/0", { p: 0x0800, parm2: 0x0004 + off, b: 24 }],
      ["param/1", { p: 0x0800, parm2: 0x0005 + off, b: 25 }],
      ["param/2", { p: 0x0800, parm2: 0x0006 + off, b: 26 }],
      ["param/3", { p: 0x0800, parm2: 0x0007 + off, b: 27 }],
    ]
  } },
  { prefix: 'fx/reverb', count: 2, bx: 6, block: (i) => {
    const off = i * 6
    return [
      ["type", { p: 0x0800, parm2: 0x000f + off, b: 35, opts: Voice.reverbOptions }],
      ["balance", { p: 0x0800, parm2: 0x0010 + off, b: 36, max: 100 }],
      ["level", { p: 0x0800, parm2: 0x0011 + off, b: 37, max: 100 }],
      ["param/0", { p: 0x0800, parm2: 0x0012 + off, b: 38 }],
      ["param/1", { p: 0x0800, parm2: 0x0013 + off, b: 39 }],
      ["param/2", { p: 0x0800, parm2: 0x0014 + off, b: 40 }],
    ]
  } },
  ["fx/mix/0", { p: 0x0800, parm2: 0x001b, b: 52 + 27, max: 1 }],
  ["fx/mix/1", { p: 0x0800, parm2: 0x001c, b: 52 + 28, max: 1 }],
  { prefix: '', count: 16, bx: 7, px: 1, block: [
    ["on", { p: 0x0100, parm2: 0x0000, b: 58, bit: 6 }],
    ["out/select", { p: 0x0100, parm2: 0x0000, b: 58, bits: [2, 5], opts: indivOutOptions }],
    ["out/0", { p: 0x0100, parm2: 0x0000, b: 58, bit: 0 }],
    ["out/1", { p: 0x0100, parm2: 0x0000, b: 58, bit: 1 }],
    ["voice/bank", { p: 0x0100, parm2: 0x0001, b: 59, opts: voiceBankOptions }],
    ["voice/number", { p: 0x0100, parm2: 0x0002, b: 60, max: 63 }],
    ["volume", { p: 0x0100, parm2: 0x0003, b: 61 }],
    ["fine", { p: 0x0100, parm2: 0x0004, b: 62, dispOff: -64 }],
    ["note/shift", { p: 0x0100, parm2: 0x0005, b: 63, dispOff: -64 }],
    ["pan", { p: 0x0100, parm2: 0x0006, b: 64, max: 63 }],
  ] },
]

const commonTruss = {
  single: 'multi.common',
  parms: commonParms,
  namePack: [0, 18],
  initFile: "tg77-multi-common-init",
  parseBody: ['bytes', { start: 32, count: 170 }],
}

static func location(forData data: Data) -> Int { return Int(data[31] & 0xf) }
const headerString: String = "LM  8101MU"


// extra

const extraParms = [
  ["mode", { p: 0x0c00, parm2: 0x0000, b: 0, opts: ["Dynamic", "Static"] }],
  { prefix: 'part', count: 16, bx: 1, block: (i) => [
    ["fm", { p: 0x0c00, parm2: i + 2, b: 2, max: 16 }],
    ["wave", { p: 0x0c00, parm2: i + 18, b: 18, max: 16 }],    
  ] }
]

const headerString: String = "LM  8104MU"

const extraTruss = {
  single: 'multi.extra',
  parms: extraParms,
  parseBody: ['bytes', { start: 32, count: 34 }],
  initFile: "tg77-multi-extra-init",
}


const patchTruss = {
  multi: 'multi',
  map: [
    ["common", commonTruss],
    ["extra", extraTruss],
  ],
  validSizes: ['auto', commonTruss],
  initFile: "tg77-multi-init",
}

class TG77MultiPatch : YamahaMultiPatch, BankablePatch {
  
  static func location(forData data: Data) -> Int { return Int(data[31] & 0xf) }
  
  public static func isCompleteFetch(sysex: Data) -> Bool {
    // default impl would stop fetch after only common is received
    return sysex.count == fileDataCount
  }

  var name: String {
    get { return subpatches["common"]?.name ?? "" }
    set { subpatches["common"]?.name = newValue }
  }
  
  public func sysexData(channel: Int) -> Data {
    return sysexData(channel: channel, location: -1)
  }
  
  func sysexData(channel: Int, location: Int) -> Data {
    // Common, then Extra
    var data = (ySubpatches["common"] as? TG77MultiCommonPatch)?.sysexData(channel: channel, location: location) ?? Data()
    if let extra = ySubpatches["extra"] as? TG77MultiExtraPatch {
      data += extra.sysexData(channel: channel, location: location)
    }
    return data
  }
}

const patchTransform = {
  throttle: 100,
  param: (path, parm, value) => {
    let v: Int
    if param.bits != nil {
      // grab the whole byte from the patch instead
      let byteIndex = param.byte
      let p = patch.subpatches[[.common]] as! TG77MultiCommonPatch
      let b = param.length == 2 ? ((p.bytes[byteIndex] & 0x1) << 7) + p.bytes[byteIndex+1] : p.bytes[byteIndex]
      v = Int(b)
    }
    else {
      v = value
    }
    return [self.paramData(param: param, value: v)]
  },
  singlePatch: [[sysexData, 10]],
  name: [[sysexData, 10]],
}

const bankTransform = {
  throttle: 0,
  singleBank: loc => [[sysexData(loc), 50]],
}

const commonPatchTransform = {
  throttle: 100,
  param: (path, parm, value) => {
    let v: Int
    if param.bits != nil {
      // grab the whole byte from the patch instead
      let byteIndex = param.byte
      let b = param.length == 2 ? ((patch.bytes[byteIndex] & 0x1) << 7) + patch.bytes[byteIndex+1] : patch.bytes[byteIndex]
      v = Int(b)
    }
    else {
      v = value
    }
    return [self.paramData(param: param, value: v)]
  },
  singlePatch: [[commonSysexData, 10]],
  name: [[commonSysexData, 10]],
}


class TG77MultiBank : TypicalTypedSysexPatchBank<TG77MultiPatch> {
  
  override class var patchCount: Int { return 16 }
  override class var initFileName: String { return "tg77-multi-bank-init" }
  
  override func fileData() -> Data {
    return sysexData { $0.sysexData(channel: 0, location: $1) }
  }
  
  static let emptyBankOptions = OptionsParam.makeOptions((1...16).map { "\($0)" })

}


class TG77MultiCommonBank : TypicalTypedSysexPatchBank<TG77MultiCommonPatch> {
  
  override class var patchCount: Int { return 16 }
  override class var initFileName: String { return "tg77-multi-common-bank-init" }
  
  override func fileData() -> Data {
    return sysexData { $0.sysexData(channel: 0, location: $1) }
  }
  
  static let emptyBankOptions = OptionsParam.makeOptions((1...16).map { "\($0)" })
  
}


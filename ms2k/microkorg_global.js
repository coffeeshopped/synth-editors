

  subscript(path: SynthPath) -> Int? {
    get {
      guard let param = type(of: self).params[path] else { return nil }
      if let rangeParam = param as? ParamWithRange,
         rangeParam.range.lowerBound < 0 {
        return Int(Int8(bitPattern: bytes[param.byte]))
      }
      else {
        return unpack(param: param)
      }
    }
    set {
      guard let param = type(of: self).params[path],
        let newValue = newValue else { return }
      if let rangeParam = param as? ParamWithRange,
         rangeParam.range.lowerBound < 0 {
        bytes[param.byte] = UInt8(bitPattern: Int8(newValue))
      }
      else {
        pack(value: newValue, forParam: param)
      }
    }
  }
  

const parms = [
  ["tune", { b: 0, rng: [-100, 100], iso: ['>' ['*', 0.1], ['+', 440]] }],
  ["transpose", { b: 1, rng: [-12, 12] }],
  ["post", { b: 2, bit: 0, opts: ["Post KBD", "Pre TG"] }],
  ["velo", { b: 3, rng: [1, 127] }],
  ["velo/curve", { b: 4, opts: ["1", "2", "3", "4", "5", "6", "7", "8", "Const"] }],
  ["local", { b: 5, bit: 2 }],
  ["protect", { b: 5, bit: 0 }],
  ["clock", { b: 8, bits: [0, 1], opts: ["Int", "Ext", "Auto"] }],
  ["channel", { b: 9, bits: [0, 3], max: 15, dispOff: 1 }],
  ["sync/ctrl", { b: 10 }],
  ["timbre/ctrl", { b: 11 }],
  ["sysex/on", { b: 16, bit: 7 }],
  ["bend/on", { b: 17, bit: 6 }],
  ["ctrl/on", { b: 17, bit: 2 }],
  ["pgmChange/on", { b: 17, bit: 0 }],
  
  // knob/switch map
  ([0, 40]).forEach {
    // don't use i(0) bc the parms will be negative...
    ["ctrl/$0 + 1", { b: 18 + $0 }],
  }
  
  // pgm change map
]

const sysexData = [0xf0, 0x42, ['+', 0x30, 'channel'], 0x58, 0x51, ['pack78', { count: 229 }], 0xf7]

const patchTruss = {
  single: 'global',
  parseBody: ['unpack87', { count: 200, rng: [5, 233] }],
  initFile: "microkorg-global-init",
}

const patchTransform = {
  throttle: 1000,
  singlePatch: [[sysexData, 10]],
}


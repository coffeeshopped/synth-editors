

class TG77SystemPatch: TG77Patch, GlobalPatch {
  
  const fileDataCount = 98
  
  const headerString: String = "LM  8101SY"
    
  var upperGreeting: String {
    set { set(string: newValue, forByteRange: 0..<20) }
    get { return type(of: self).name(forRange: 0..<20, bytes: bytes) }
  }

  var lowerGreeting: String {
    set { set(string: newValue, forByteRange: 20..<40) }
    get { return type(of: self).name(forRange: 20..<40, bytes: bytes) }
  }
  
  func allNames() -> [SynthPath:String] {
    return [
      [] : name,
      "hi" : upperGreeting,
      "lo" : lowerGreeting,
    ]
  }

  func set(name n: String, forPath path: SynthPath) {
    switch path {
    case "hi":
      upperGreeting = n
    case "lo":
      lowerGreeting = n
    default:
      name = n
    }
  }
  
  func name(forPath path: SynthPath) -> String? {
    switch path {
    case "hi":
      return upperGreeting
    case "lo":
      return lowerGreeting
    default:
      return name
    }
  }


}

const parms = [
  ["note/shift", { p: 0x0f00, parm2: 0x0028, b: 40, dispOff: -64 }],
  ["fine", { p: 0x0f00, parm2: 0x0029, b: 41, dispOff: -64 }],
  ["fixed/velo", { p: 0x0f00, parm2: 0x002a, byte: 42, iso: ['switch', [
    [0, "Off"],
    [[1, 127], []],
  ]] }],
  ["velo/curve", { p: 0x0f00, parm2: 0x002b, b: 43, max: 7 }],
  ["modWheel", { p: 0x0f00, parm2: 0x002c, b: 44, max: 120 }],
  ["foot", { p: 0x0f00, parm2: 0x002d, b: 45, max: 120 }],
  ["edit", { p: 0x0f00, parm2: 0x002e, b: 46, max: 1 }],
  ["send/channel", { p: 0x0f00, parm2: 0x002f, b: 47, max: 15, dispOff: 1 }],
  ["rcv/channel", { p: 0x0f00, parm2: 0x0030, byte: 48, max: 16, iso: ['switch', [
    [[0, 15], ['+', 1]],
    [16, "Omni"],
  ]] }],
  ["local", { p: 0x0f00, parm2: 0x0031, b: 49, max: 1 }],
  ["deviceId", { p: 0x0f00, parm2: 0x0032, byte: 50, max: 17, iso: ['switch', [
    [0, "Off"],
    [[1, 16], []],
    [17, "All"],
  ]] }],
  // even/odd
  ["note/select", { p: 0x0f00, parm2: 0x0033, b: 51, opts: ["All", "Odd", "Even"] }],
  ["protect", { p: 0x0f00, parm2: 0x0034, b: 52, max: 1 }],
  ["pgm/mode", { p: 0x0f00, parm2: 0x0035, b: 53, opts: ["Off", "Normal", "Direct", "Table"] }],
]

const patchTruss = {
  single: 'system',
  parms: parms,
  initFile: "tg77-system-init",
  parseBody: ['bytes', { start: 32, count: 64 }],
}

const patchTransform = {
  throttle: 100,
  param: (path, parm, value) => {
    return [self.paramData(param: param, value: value)]
  },
  singlePatch: [[sysexData, 10]],
}

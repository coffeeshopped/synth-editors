
function bulkDumpData(byteCount, address) {
  return ['yamCmd', ['channel', 0x7f, 0x1c, 0x00, byteCount], [0x05, address, 'b']]
}

function opSysexData(op) {
  return bulkDumpData(32, [0x31, op, 0x00])
}

const levelScaleCurveOptions = ["-Lin", "-Exp", "+Exp", "+Lin"]

const feedbackIso = Miso.switcher([
  .range((-127...(-1)), Miso.m(-1) >>> Miso.unitFormat("sw")),
  .int(0, "0"),
  .range(1...127, Miso.unitFormat("sq"))
])

const opParms = [
  { inc: 1, b: 0x00, block: [
    ['on', { max: 1 }],
    ['rate/0', { }],
    ['rate/1', { }],
    ['rate/2', { }],
    ['rate/3', { }],
    ['level/0', { }],
    ['level/1', { }],
    ['level/2', { }],
    ['level/3', { }],
    ['rate/scale', { }],
    ['level/scale/left/depth', { }],
    ['level/scale/right/depth', { }],
    ['level/scale/left/curve', { opts: levelScaleCurveOptions }],
    ['level/scale/right/curve', { opts: levelScaleCurveOptions }],
    ['lfo/amp/mod', { }],
    ['lfo/pitch/mod', { max: 1 }],
    ['pitch/env', { max: 1 }],
    ['velo', { }],
    ['level', { }],
    ['feedback/level', { }],
    ['feedback/type', { opts: ["Saw", "Sqr"] }],
    ['freq/mode', { opts: ["Ratio", "Fixed"] }],
    ['coarse', { max: 31 }],
    ['fine', { max: 99 }],
    ['detune', { dispOff: -64 }],
  ] },
]

// COMMON

const fxTypeOptions = ["Thru", "Dist", "T.Wah", "Cho", "Fla", "Pha", "Dly", "Rev"]

const commonParms = [
  { inc: 1, b: 0x0c, block: [
    ['transpose', { rng: [40, 88], dispOff: -64 }],
    ['mono', { opts: ["Poly", "Mono Full", "Mono Lgato"] }],
    ['porta', { }],
    ['bend', { rng: [40, 88], dispOff: -64 }],
    ['algo', { max: 11, dispOff: 1 }],
    ['lfo/wave', { opts: ["Sin", "Tri", "Saw Up", "Saw Down", "Sqr", "S&H8", "S&H"] }],
    ['lfo/speed', { }],
    ['lfo/delay', { }],
    ['lfo/pitch/mod', { }],
    ['pitch/env/rate/0', { }],
    ['pitch/env/rate/1', { }],
    ['pitch/env/rate/2', { }],
    ['pitch/env/rate/3', { }],
    ['pitch/env/level/0', { rng: [16, 112], dispOff: -64 }],
    ['pitch/env/level/1', { rng: [16, 112], dispOff: -64 }],
    ['pitch/env/level/2', { rng: [16, 112], dispOff: -64 }],
    ['pitch/env/level/3', { rng: [16, 112], dispOff: -64 }],
    ['fx/0/type', { opts: fxTypeOptions }],
    ['fx/0/param/0', { }],
    ['fx/0/param/1', { }],
    ['fx/1/type', { opts: fxTypeOptions }],
    ['fx/1/param/0', { }],
    ['fx/1/param/1', { }],
  ] },
]

function commonSysexData() {
  return bulkDumpData(42, [0x30, 0x00, 0x00])
}

const opPatchTruss = {
  type: 'singlePatch',
  id: "refacedx.voice.op", 
  bodyDataCount: 28, 
  parseBody: 11,
  parms: opParms,
  initFile: "reface-dx-voice-op-init", 
  createFileData: opSysexData(0),
}

const commonPatchTruss = {
  type: 'singlePatch',
  id: "refacedx.voice.common", 
  bodyDataCount: 38, 
  namePack: [0, 9], 
  parms: commonParms, 
  initFile: "reface-dx-voice-common-init", 
  createFileData: commonSysexData(),
  parseBody: 11,
}

const headerPatchTruss = {
  type: 'singlePatch',
  id: "refacedx.voice.header", 
  bodyDataCount: 0, 
  parms: [], 
  createFileData: commonSysexData(),
  parseBody: 11,
}



/// Temp buffer sysex
function tempSysexData() {
  return sysexData([0x0f, 0x00])
}

/// Location should be 0...31
function sysexData(location) {
  return sysexData([0x00, location])
}

// address should be 2 bytes
function sysexData(address) {
  var data = [bulkDumpData(4, [0x0e, address])]
  data += [Common.sysexData(bodyData["common"])]
  data += 4.map {
    Op.sysexData(bodyData["op/$0"], op: $0)
  }
  data += [bulkDumpData(4, [0x0f, address])]
  return data
}

const trussMap = [
  ["common", commonPatchTruss],
  ["op/0", opPatchTruss],
  ["op/1", opPatchTruss],
  ["op/2", opPatchTruss],
  ["op/3", opPatchTruss],
]

const patchTruss = {
  type: 'multiPatch',
  id: "refacedx.voice",
  trussMap: trussMap, 
  namePath: "common", 
  initFile: "reface-dx-voice-init", 
  fileDataCount: 241, 
  createFileData: {
  sysexData($0, channel: 0)
}, 
  parseBodyData: {
  var bodyData = [SynthPath:[UInt8]]()
  try SysexData(data: $0.data()).forEach {
    let bytes = $0.bytes()
    if Common.patchTruss.isValidFileData(bytes) {
      bodyData["common"] = try Common.patchTruss.parseBodyData(bytes)
    }
    else if Op.patchTruss.isValidFileData(bytes) {
      let op = Int(bytes[9])
      bodyData["op/op"] = try Op.patchTruss.parseBodyData(bytes)
    }
  }
  
  for (path, truss) in trussMap {
    guard bodyData[path] == nil else { continue }
    bodyData[path] = try truss.createInitBodyData()
  }
  return bodyData
}

const bankTruss = MultiBankTruss(patchTruss: patchTruss, patchCount: 32, initFile: "reface-dx-voice-bank-init", createFileData: {
  $0.enumerated().flatMap {
    sysexData($0.element, channel: 0, location: $0.offset).flatMap { $0 }
  }

}, parseBodyData: {
  // look for a header message
  // if header, then this and next 6 messages (7 total) are patch data.
  var patchData = [UInt8]()
  var inPatch = false
  var patches = [[SynthPath:[UInt8]]]()
  try SysexData(data: $0.data()).forEach { d in
    guard inPatch || (d.count == 13 && d[8] == 0x0e) else { return }
    inPatch = true
    patchData += d.bytes()
    
    if d.count == 13 && d[8] == 0x0f && patchTruss.isValidFileData(patchData) {
      // end of patch
      inPatch = false
      patches += [try patchTruss.parseBodyData(patchData)]
      patchData.removeAll(keepingCapacity: true)
    }
  }
  
  if patches.count < 32 {
    try (0..<(32 - patches.count)).forEach { _ in
      patches += [try patchTruss.createInitBodyData()]
    }
  }
  return patches
})

function freqRatio(fixedMode, coarse, fine) {
  if (fixedMode) {
    let freq = pow(10, (coarse / 8.0) + (fine / 100.0))
    return String(format:"%.4g", freq)
  }
  else if (coarse == 0) {
    return String(format:"%.3f", 0.5 + (fine * 0.005))
  }
  else {
    return String(format:"%.2f", coarse + (fine * 0.01))
  }
}


extension RefaceDX {
  
  enum Voice {
    
//    static func location(forData data: Data) -> Int { Int(data[10]) }
    

    
//    func randomize() {
//      randomizeAllParams()
//
//      let algos = Self.algorithms()
//      let algoIndex = self["common/algo"] ?? 0
//
//      let algo = algos[algoIndex]
//
//      // make output ops audible
//      for outputId in algo.outputOps {
//        let op: SynthPath = "op/outputId"
//        self[op + "level/0"] = 116 + (0...9).random()!
//        self[op + "rate/0"] = 106 + (0...19).random()!
//        self[op + "level/2"] = 106 + (0...19).random()!
//        self[op + "level/3"] = 0
//        self[op + "rate/3"] = 60 + (0...67).random()!
//        self[op + "level"] = 116 + (0...9).random()!
//        self[op + "level/scale/left/depth"] = (0...9).random()!
//        self[op + "level/scale/right/depth"] = (0...9).random()!
//      }
//
//      let randomOut = algo.outputOps[(0..<algo.outputOps.count).random()!]
//      let op: SynthPath = "op/randomOut"
//      self[op + "freq/mode"] = 0
//      self[op + "fine"] = 0
//      self[op + "coarse"] = 1
//
//      self["common/transpose"] = 64
//      self["common/porta"] = 0
//      
//      // flat pitch env
//      for i in 0..<4 {
//        self["common/pitch/env/level/i"] = 64
//      }
//
//      // all ops on
//      for op in 0..<4 { self["op/op/on"] = 1 }
//    }

  }
  
}

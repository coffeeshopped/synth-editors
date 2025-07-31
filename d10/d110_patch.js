const System = require('./d110_system.js')
const Timbre = require('./d110_timbre.js')

// system params, but removing master tune, and then offsetting all byte locations by -1
// to account for the shifted start address (added 1 to the System start address).
const tempParms = {
  var t = System.parms
  t.removeFirst()
  return t.map { .p($0.path, $0.b! - 1, $0.span) }
}()

const commonPatchWerk = {
  single: "Patch Common",
  parms: tempParms,
  size: 0x20,
  name: [0x16, 0x1f],
}


// A construct representing a "Patch", but in temp memory.
/**
 Since the D-110 doesn't have a notion of a temporary "Patch" area, but rather only 8 temp Timbres + the System area,
 we are representing a Patch as a multi-patch built out of those parts. So a file written for a Patch, and the MIDI communication for editing a patch, is represented here.
 But for writing a Patch to *memory*, we use a separate specification (D110.Patch).
 */

const commonPaths = [
  "reverb/type",
  "reverb/time",
  "reverb/level",
  "part/rhythm/reserve",
  "part/rhythm/channel",
] + 8.flatMap {
  [
    "part/$0/reserve",
    "part/$0/channel",
  ]
}

const partPaths = [
  "tone/group",
  "tone/number",
  "tune",
  "fine",
  "bend",
  "assign/mode",
  "out/assign",
  "balance",
  "out/level",
  "pan",
  "key/hi",
  "key/lo",
]
    
function tempToMem(temp) {
  // for each patch bodyData, parse it using the truss above,
  let all = patchWerk.truss.allValues(temp)
  // then map those key/values to the key/values of MemPatch,
  var mem = [SynthPath:Int]()
  
  commonPaths.forEach {
    mem[$0] = all["common" + $0]
  }
  
  8.times { part in
    partPaths.forEach {
      let path = "part/part" + $0
      mem[path] = all[path]
    }
  }
  mem["part/rhythm/out/level"] = all["part/rhythm/out/level"]
  
  let memWerk = memPatchWerk
  var memData = try memWerk.truss.createEmptyBodyData()
  mem.forEach {
    memWerk.truss['setValue', &memData, path: $0, $1]
  }
  
  // don't forget the name too.
  let n = patchWerk.truss.getName(temp) ?? "?"
  memWerk.truss.setName(&memData, n)
  
  return memData
}
    
// take body data from patchWerk (above), and turn into a bunch of sysex for Patch Memory
function bankCreateFile(_ bodyData: MultiBankTruss.BodyData, deviceId: UInt8, address: RolandAddress, patchWerk: RolandMultiPatchTrussWerk, iso: RolandOffsetAddressIso) throws -> [[UInt8]] {
  try bodyData.enumerated().map({ (index, bd) in
    let memWerk = memPatchWerk
    let memData = try tempToMem(bd)
    
    // then create the sysex data of the MemPatch
    let a = address + iso.address(UInt8(index))
    return memWerk.sysexDataFn(memData, deviceId, a)
  }).reduce([], +)
}
    
    
function bankParseBody(fileData, iso, patchWerk, patchCount) {
  
  let rData = RolandWerkData(data: Data(fileData), werk: patchWerk.werk)

  let memWerk = memPatchWerk
  let patchTruss = patchWerk.truss

  return try (0..<patchCount).map {
    let patchData = rData.bytes(offset: iso.address(UInt8($0)), size: memWerk.size)
    let subdata = patchWerk.werk.dummySysex(bytes: patchData)
    let memBD = try memWerk.truss.parseBodyData(subdata)
    let mem = memWerk.truss.allValues(memBD)
    let n = memWerk.truss.getName(memBD) ?? "?"
    
    var all = [SynthPath:Int]()
    
    commonPaths.forEach {
      all["common" + $0] = mem[$0]
    }
    
    8.times { part in
      partPaths.forEach {
        let path = "part/part" + $0
        all[path] = mem[path]
      }
    }
    all["part/rhythm/out/level"] = mem["part/rhythm/out/level"]

    
    var allData = try patchTruss.createEmptyBodyData()
    all.forEach {
      patchTruss['setValue', &allData, path: $0, $1]
    }
    patchTruss.setName(&allData, n)

    return allData
  }
  
}

const memParms = [
  ['reverb/type', { b: 0x0a, opts: System.reverbTypeOptions }],
  ['reverb/time', { b: 0x0b, max: 7, dispOff: 1 }],
  ['reverb/level', { b: 0x0c, max: 7 }],
  { prefix: "part", count: 8, bx: 1, block: [
    ['reserve', { b: 0x0d, max: 32 }],
  ] },
  ['part/rhythm/reserve', { b: 0x15, max: 32 }],
  { prefix: "part", count: 8, bx: 1, block: [
    ['channel', { b: 0x16, max: 16 }],
  ] },
  ['part/rhythm/channel', { b: 0x1e, max: 16 }],
  { prefix: "part", count: 8, bx: 0x0c, block: [
    { inc: 1, b: 0x1f, block: [
      ['tone/group', { opts: toneGroupOptions }],
      ['tone/number', { opts: toneNumberOptions }],
      ['tune', { max: 48, dispOff: -24 }],
      ['fine', { max: 100, dispOff: -50 }],
      ['bend', { max: 24 }],
      ['assign/mode', { opts: assignModeOptions }],
      ['out/assign', { max: 7 }],
      ['balance', { max: 100, dispOff: -50 }], // dummy
      ['out/level', { max: 100 }],
      ['pan', { max: 14, dispOff: -7 }],
      ['key/lo', { }],
      ['key/hi', { }],
    ] }
  ] },
  ['part/rhythm/out/level', { b: 0x7f, max: 100 }],
]

const toneGroupOptions = ["A","B","Int","Rhythm"]

const toneNumberOptions = (0...63).map { "\($0+1)" }

const assignModeOptions = ["Poly 1","Poly 2","Poly 3","Poly 4"]

// 0x100001 - 0x030000
const patchWerk = {
  multi: "Patch"
  map: (8).map(i => [["part", i], 0x10 * i, Timbre.patchWerk]).concat([
    ["part/rhythm", 0x0100, Timbre.patchWerk],
    ["common", Common.patchWerk.start - start, commonPatchWerk],
  ]),
}
//      let bundle = MultiPatchTruss.fileDataCountBundle(trusses: map.map { $0.werk.truss }, validSizes: [256, 266], includeFileDataCount: true)

const bankWerk = {
  multiBank: patchWerk,
  patchCount: 64,
  // iso: .init(address: {
  //   0x0100 * Int($0)
  // }, location: {
  //   $0.sysexBytes(count: DXX.sysexWerk.addressCount)[1]
  // }),
  // , createFileFn: bankCreateFile, parseBodyFn: bankParseBody, validBundle: MultiBankTruss.fileDataCountBundle(patchTruss: patchWerk.truss, patchCount: 64, validSizes: [8512, 8832], includeFileDataCount: true))
}

const memPatchWerk = {
  single: 'MemPatch',
  parms: memParms,
  size: 0x0100,
  name: [0x00, 0x09],
}

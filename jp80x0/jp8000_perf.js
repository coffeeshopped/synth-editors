
const commonWerk = {
  single: 'perf.common',
  initFile: "jp8000-perf-common-init",
  size: 0x24,
  namePack: [0x00, 0x0f],
  // voice assign: diff opts
  // add pedal assign
  // no input param
  parms: JP8080Perf.commonParms(false),
}

const partWerk = {
  single: 'perf.part',
  initFile: "jp8000-perf-part-init",
  size: 0x07,
  // no card
  // diff size
  // no group
  parms: JP8080Perf.partParms(false),
}

const patchWerk = {
  multi: 'perf',
  initFile: "jp8000-perf-init",
  map: [
    ['common', 0x0000, commonWerk),
    ['part/0', 0x1000, partWerk),
    ['part/1', 0x1100, partWerk),
    ['patch/0', 0x4000, JP8000Voice.patchWerk),
    ['patch/1', 0x4200, JP8000Voice.patchWerk),
  ],
  validSizes: ['auto', 686],
}


struct JP8000PerfBank : RolandMultiBankTemplate, PerfBank {
 typealias Template = JP8000PerfPatch
 static let patchCount: Int = 64
 static let initFileName: String = "jp8000-perf-bank-init"
 
 static func startAddress(_ path: SynthPath?) -> RolandAddress { 0x03000000 }
 static func offsetAddress(location: UInt8) -> RolandAddress { 0x010000 * Int(location) }

 static func patchArray(fromData data: Data) -> [FnMultiPatch<Template>] {
   patches(fromData: data) {
     Int(Template.addressBytes(forSysex: $0)[1])
   }
 }
 
 static func isValid(fileSize: Int) -> Bool {
   [fileDataCount, 686 * patchCount].contains(fileSize)
 }
}


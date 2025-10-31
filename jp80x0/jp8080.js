
public protocol JP8080SinglePatchTemplate : JP8080SysexTemplate, RolandSinglePatchTemplate { }
public extension JP8080SinglePatchTemplate {
 // 7 bits used in multi-byte params! The default in RolandSinglePatchTemplate is 4 bits (which is what newer synths use
 
 /// Compose Int value from bytes (MSB first)
 static func multiByteParamInt(from: [UInt8]) -> Int {
   guard from.count > 1 else { return Int(from[0]) }
   return (1...from.count).reduce(0) {
     let shift = (from.count - $1) * 7
     return $0 + (Int(from[$1 - 1]) << shift)
   }
 }

 /// Decompose Int to bytes (7! bits at a time)
 static func multiByteParamBytes(from: Int, count: Int) -> [UInt8] {
   guard count > 0 else { return [UInt8(from)] }
   return (1...count).map {
     let shift = (count - $0) * 7
     return UInt8((from >> shift) & 0x7f)
   }
 }
}

public protocol JP8080MultiPatchTemplate : JP8080SysexTemplate, RolandMultiPatchTemplate { }
public protocol JP8080MultiSysexTemplate : JP8080SysexTemplate, RolandMultiSysexTemplate { }

const editor = {
  rolandModelId: [0x00, 0x06], 
  addressCount: 3,
  name: "",
  map: [
    ["deviceId"],
    ["global", Global.patchTruss],
    ["perf", Perf.patchTruss],
    ["bank/perf", Perf.bankTruss],
    ["bank/patch", Voice.bankTruss],
  ],
  fetchTransforms: [
    
  ],

  midiOuts: [
  ],
  
  midiChannels: [
    ["voice", "basic"],
  ],
  slotTransforms: [
    ['bank/perf', ['user', i => {
      const bank = (i / 8) + 1
      const patch = (i % 8) + 1
      return `${bank}${patch}`
    }]],
    ['bank/patch', ['user', i => Voice.bankIndexToPrefix(i)]],
  ],
}



extension JP80X0Editor {

 public static func deviceId(_ editor: TemplatedEditor) -> UInt8 {
   UInt8(editor.patch(forPath: "deviceId")?["deviceId"] ?? RolandDefaultDeviceId)
 }

 public static func extraParamsOutput(_ editor: TemplatedEditor, forPath path: SynthPath) -> Observable<SynthPathParam>? {
   guard path == "perf" else { return nil }
   return mapBankNameParams(editor, bankPath: "bank/patch", toParamPath: "patch/name") {
     "\(JP8080VoiceBank.bankIndexToPrefix($0)): \($1)"
   }
 }
 
}

public struct JP8080Editor : JP80X0Editor {
 
 public static var compositeMap: [SynthPath : MultiSysexTemplate.Type] = [
     "backup" : JP8080Backup.self,
   ]
     
 public static func midiChannel(_ editor: TemplatedEditor, forPath path: SynthPath) -> Int {
   0
 }
 
}


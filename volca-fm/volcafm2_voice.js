

extension VolcaFM2 {

 enum Voice {
   
   static func parseBodyData(d: [UInt8]) throws -> [UInt8] {
     if patchWerk.isValidNative(fileSize: d.count) {
       return patchWerk.parseNative(bodyData: d)
     }
     else {
       let data = Data(d)
       let dxPatch = TX802VoicePatch(data: data).ySubpatches["voice"] as! DX7Patch
       return [UInt8](dxPatch.bankSysexData()) + [
         64, 64, 64, 64, // 0 for attacks/decays
         4, // 0 for transpose
         1, 1, 1, 1, 1, 1, // all ops on
         0, // reserved TODO: should it be some other value?
       ]
     }
   }
   
   const sendPatch: EditorValueTransform = .value("global", "send/patch")
   const voicePatch: EditorValueTransform = .patch("patch")
   const patchTransform: MidiTransform = .singleDict(throttle: 300, `basicChannel/${sendPatch}`, .wholePatch({ editorVal, bodyData in
     let seqMsg = patchWerk.sysexData(bodyData, channel: 0)
     let sendPatch = editorVal[sendPatch] as? Int ?? 0
     if sendPatch == 1,
        let voiceData = (editorVal[voicePatch] as? AnySysexible)?.anyBodyData.data() as? [UInt8] {
       return [
         (seqMsg, 50),
         (patchWerk.sysexData(voiceData, channel: 0), 0),
       ]
     }
     else {
       return [(seqMsg, 0)]
     }
   }))

   static func algorithms() -> [DXAlgorithm] { DX7Patch.algorithms() }
   
//    static func randomize(patch: ByteBackedSysexPatch) {
//      patch.randomizeAllParams()
//
//      patch["partial/0/mute"] = 1
//
//      // find the output ops and set level 4 to 0
//      let algos = algorithms()
//      let algoIndex = patch["algo"] ?? 0
//
//      let algo = algos[algoIndex]
//
//      for outputId in algo.outputOps {
//        let op: SynthPath = "op/outputId"
//        patch[op + "level/0"] = 90+([0, 9]).random()!
//        patch[op + "rate/0"] = 80+([0, 19]).random()!
//        patch[op + "level/2"] = 80+([0, 19]).random()!
//        patch[op + "level/3"] = 0
//        patch[op + "rate/3"] = 30+([0, 69]).random()!
//        patch[op + "level"] = 90+([0, 9]).random()!
//        patch[op + "level/scale/left/depth"] = ([0, 9]).random()!
//        patch[op + "level/scale/right/depth"] = ([0, 9]).random()!
//      }
//
//      // for one out, make it harmonic and louder
//      let randomOut = algo.outputOps[(0..<algo.outputOps.count).random()!]
//      let op: SynthPath = "op/randomOut"
//      patch[op + "osc/mode"] = 0
//      patch[op + "fine"] = 0
//      patch[op + "coarse"] = 1
//
//      // flat pitch env
//      for i in 0..<4 {
//        patch["pitch/env/level/i"] = 50
//      }
//
//      // all ops on
//      for op in 0..<6 { patch["op/op/on"] = 1 }
//    }
   
   
   const bankPatchCount = 64
   const bankFileDataCount = bankPatchCount * (patchFileDataCount + 1)

   const bankTruss: SingleBankTruss = {

     let createFileData = SingleBankTrussWerk.createFileDataWithLocationMap({
       patchWerk.sysexData($0, channel: 0, location: UInt8($1)).bytes()
     })

     let parseBodyData: SingleBankTruss.Core.ParseBodyDataFn = {
       if isValidNativeBank(fileSize: $0.count) {
         return try SingleBankTrussWerk.singleSortedByteArrays(sysexData: $0, count: bankPatchCount, locationByteIndex: 7).map { try patchTruss.parseBodyData($0) }
       }
       else {
         let halfBank = try TX802VoiceBank(data: Data($0)).patches.map {
           try patchTruss.parseBodyData(($0.ySubpatches["voice"] as! DX7Patch).fileData().bytes())
         }
         let emptyBank = try (0..<32).map { _ in
           try patchTruss.createInitBodyData()
         }
         return halfBank + emptyBank
       }
     }
     
     return SingleBankTruss(patchTruss: patchTruss, patchCount: bankPatchCount, fileDataCount: bankFileDataCount, createFileData: createFileData, parseBodyData: parseBodyData, validBundle: SingleBankTruss.Core.validBundle(validSize: {
       isValidNativeBank(fileSize: $0) || TX802VoiceBank.isValid(fileSize: $0)
     }))
   }()
   
   static func isValidNativeBank(fileSize: Int) -> Bool { fileSize == bankFileDataCount }
   

 }

}

const adMiso = Miso.switcher([
   .int(0, -63),
   .range([1, 127], Miso.a(-64))
 ])
 
const curveOptions = ["- Lin","- Exp","+ Exp","+ Lin"]
 
const lfoWaveOptions = ["Triangle","Saw Down","Saw Up","Square","Sine","Sample/Hold"]
 
const breakOptions = ["A-1", "A#-1", "B-1", "C0", "C#0", "D0", "D#0", "E0", "F0", "F#0", "G0", "G#0", "A0", "A#0", "B0", "C1", "C#1", "D1", "D#1", "E1", "F1", "F#1", "G1", "G#1", "A1", "A#1", "B1", "C2", "C#2", "D2", "D#2", "E2", "F2", "F#2", "G2", "G#2", "A2", "A#2", "B2", "C3", "C#3", "D3", "D#3", "E3", "F3", "F#3", "G3", "G#3", "A3", "A#3", "B3", "C4", "C#4", "D4", "D#4", "E4", "F4", "F#4", "G4", "G#4", "A4", "A#4", "B4", "C5", "C#5", "D5", "D#5", "E5", "F5", "F#5", "G5", "G#5", "A5", "A#5", "B5", "C6", "C#6", "D6", "D#6", "E6", "F6", "F#6", "G6", "G#6", "A6", "A#6", "B6", "C7", "C#7", "D7", "D#7", "E7", "F7", "F#7", "G7", "G#7", "A7", "A#7", "B7", "C8"]

const transposeOptions = ["C1", "C#1", "D1", "D#1", "E1", "F1", "F#1", "G1", "G#1", "A1", "A#1", "B1", "C2", "C#2", "D2", "D#2", "E2", "F2", "F#2", "G2", "G#2", "A2", "A#2", "B2", "C3", "C#3", "D3", "D#3", "E3", "F3", "F#3", "G3", "G#3", "A3", "A#3", "B3", "C4", "C#4", "D4", "D#4", "E4", "F4", "F#4", "G4", "G#4", "A4", "A#4", "B4", "C5"]
 
const parms = [
  { prefix: 'op', count: 6, block: (op) => {
    const off = 17 * (5 - op)
    return [
      { prefix: 'rate', count: 4, bx: 1, block: [
        ["", { b: off, max: 99 }],
      ] },
      { prefix: 'level', count: 4, bx: 1, block: [
        ["", { b: off + 4, max: 99 }],
      ] },
      ["level/scale/brk/pt", { b: off+8, opts: breakOptions }],
      ["level/scale/left/depth", { b: off+9, max: 99 }],
      ["level/scale/right/depth", { b: off+10, max: 99 }],
      ["level/scale/left/curve", { b: off + 11, bits: [0, 1], opts: curveOptions }],
      ["level/scale/right/curve", { b: off + 11, bits: [2, 3], opts: curveOptions }],
      ["rate/scale", { b: off+12, bits: [0, 2], max: 7 }],
      ["amp/mod", { b: off+13, bits: [0, 1], max: 3 }],
      ["velo", { b: off+13, bits: [2, 4], max: 7 }],
      ["level", { b: off+14, max: 99 }],
      ["osc/mode", { b: off+15, bit: 0 }],
      ["coarse", { b: off+15, bits: [1, 6], max: 31 }],
      ["fine", { b: off+16, max: 99 }],
      ["detune", { b: off+12, bits: [3, 6], max: 14, dispOff: -7 }],
    ]
  } },
  { prefix: 'pitch/env/rate', count: 4, bx: 1, block: [
    ["", { b: 102, max: 99 }],
  ] },
  { prefix: 'pitch/env/level', count: 4, bx: 1, block: [
    ["", { b: 106, max: 99 }],
  ] },        
  ["algo", { b: 110, max: 31, dispOff: 1 }],
  ["feedback", { b: 111, bits: [0, 2], max: 7 }],
  ["osc/sync", { b: 111, bit: 3 }],
  ["lfo/speed", { b: 112, max: 99 }],
  ["lfo/delay", { b: 113, max: 99 }],
  ["lfo/pitch/mod/depth", { b: 114, max: 99 }],
  ["lfo/amp/mod/depth", { b: 115, max: 99 }],
  ["lfo/sync", { b: 116, bit: 0 }],
  ["lfo/wave", { b: 116, bits: [1, 3], opts: lfoWaveOptions }],
  ["lfo/pitch/mod", { b: 116, bits: [4, 6], max: 7 }],
  ["transpose", { b: 117, opts: transposeOptions }],
     
  ["mod/attack", { b: 128, iso: adMiso }],
  ["mod/decay", { b: 129, iso: adMiso }],
  ["carrier/attack", { b: 130, iso: adMiso }],
  ["carrier/decay", { b: 131, iso: adMiso }],
  ["octave", { b: 132, rng: [2, 6], displayOffset: -4 }],
  ["op/5/on", { b: 133, max: 1 }],
  ["op/4/on", { b: 134, max: 1 }],
  ["op/3/on", { b: 135, max: 1 }],
  ["op/2/on", { b: 136, max: 1 }],
  ["op/1/on", { b: 137, max: 1 }],
  ["op/0/on", { b: 138, max: 1 }],
]

const patchTruss = {
  single: 'voice',
  parms: parms,
  namePack: [118, 127],
  initFile: "volca-fm2-voice-init",
}
   const patchFileDataCount = 168
 const patchWerk = PatchWerk(storeHeaderByte: 0x4e, tempHeaderByte: 0x42, bodyDataCount: 140, patchFileDataCount: patchFileDataCount)
 
 const patchTruss = SinglePatchTruss(, createFileData: patchWerk.createFileData, parseBodyData: parseBodyData, isValidSizeDataAndFetch: {
     patchWerk.isValidNative(fileSize: $0) || tx802isValid(fileSize: $0)
 })
 
 public static func tx802isValid(fileSize: Int) -> Bool {
   // 163: A DX7 (mkI) patch
   return fileSize == 220 || fileSize == 163
 }
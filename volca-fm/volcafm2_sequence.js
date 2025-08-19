
const bipolarFormat = ParamOptions(isoF: Miso.switcher([
   .int(0, -63),
   .range(1...127, Miso.a(-64))
 ]))
 const format99 = ParamOptions(isoF: Miso.lerp(in: 0...127, out: 0...99) >>> Miso.round())
 const arpTypeFormat = ParamOptions(isoS: Miso.lerp(in: 127, out: 0...Float(arpTypeOptions.count - 1)) >>> Miso.round() >>> Miso.options(arpTypeOptions))
 const arpDivFormat = ParamOptions(isoS: Miso.lerp(in: 127, out: 0...Float(arpDivOptions.count - 1)) >>> Miso.round() >>> Miso.options(arpDivOptions))
 const algoFormat = ParamOptions(isoF: Miso.lerp(in: 0...127, out: 1...32) >>> Miso.round())
 const octaveFormat = ParamOptions(isoF: Miso.lerp(in: 0...127, out: -2...2) >>> Miso.round())
 const noteFormat = ParamOptions(isoF: Miso.lerp(in: 0...127, out: -36...36) >>> Miso.round())

 const motionSections = [
   ["transpose", noteFormat],
   ["velo", bipolarFormat],
   ["algo", algoFormat],
   ["mod/attack", bipolarFormat],
   ["mod/decay", bipolarFormat],
   ["carrier/attack", bipolarFormat],
   ["carrier/decay", bipolarFormat],
   ["lfo/rate", format99],
   ["lfo/pitch", format99],
   ["arp/type", arpTypeFormat],
   ["arp/divide", arpDivFormat],
   ["chorus", null],
   ["reverb", null],
 ]
 
 const motions = motionSections.map(e => e[0])
    
 const arpTypeOptions = ["Off", "Rise 1", "Rise 2", "Rise 3", "Fall 1", "Fall 2", "Fall 3", "Rand 1", "Rand 2", "Rand 3"]
 const arpDivOptions = ["1/12", "1/8", "1/4", "1/3", "1/2", "2/3", "1/1", "3/2", "2/1", "3/1", "4/1"]
 
 const pitchIso = Miso.noteName(zeroNote: "C-2")
 
 const gateIso = Miso.switcher([
   .range(0...72, Miso.m(100/72) >>> Miso.round() >>> Miso.unitFormat("%")),
   .range(73...126, Miso.str("100%%")),
   .int(127, "Tie")
 ])
 
const parms = [
  { prefix: '', count: 16, i => [
    ['on', { b: 6 + (i / 8), bit: i % 8 }],
    ['active', { b: 12 + (i / 8), bit: i % 8 }],
  ] },
  ['pgm', { b: 9, max: 63 }],
  
  { prefixes: motions, bx: 2, block: [
    ['on', { b: 16, bit: 0 }],    
    { prefix: '', count: 16, block: i => [
      ['$0', { b: 42 + (i / 8), bit: i % 8 }],      
    ] },
  ] },
  
  ['motion/on', { b: 68, bit: 0 }],
  ['smooth', { b: 68, bit: 1 }],
  ['warp/active', { b: 68, bit: 2 }],
  ['tempo', { b: 68, bits: 3...4, opts: ["1/1", "1/2", "1/4"] }],
  ['mono', { b: 68, bit: 5 }],
  ['unison', { b: 68, bit: 6 }],
  ['chorus/on', { b: 68, bit: 7 }],
  
  ['arp/on', { b: 69, bit: 0 }],
  ['transpose/note', { b: 69, bit: 1 }],
  ['reverb/on', { b: 69, bit: 2 }],
  
  ['arp/type', { b: 70, opts: arpTypeOptions }],
  ['arp/divide', { b: 71, opts: arpDivOptions }],
  ['chorus/depth', { b: 72 }],
  ['reverb/depth', { b: 73 }],

  p += 16.flatMap { step in
    let off = 80 + 112 * step
    var q = [Parm]()
    q += 6.flatMap { n in
      .offset(b: off, block: {
        .prefix("note/n") { [
          ['pitch/step', { n * 2, .iso(pitchIso) }],
          ['velo/step', { 18 + n }],
          ['gate/step', { 24 + n, bits: 0...6, .iso(gateIso) }],
          ['trigger/step', { 24 + n, bit: 7 }],
        ] }
      })
    }
    q += .prefixes(motions, bx: 5, block: { _ in
      5.map { ['step/step/data/$0', { off + 43 + $0 }] }
    })
    return q
  }

  { prefix: 'motion/transpose', count: 16, bx: 1, block: [
    ['', { b: 1872, max: 1 }]
  ] }
]


const patchTruss = {
  single: 'sequence',
  parms: parms,
  initFile: "volca-fm2-sequence-init",
  defaultName: "Sequence",
  parseBody: [
    ['bytes', { start: -2196, count: 2195 }],
    'unpack87',
  ],
  validSizes: [2203, 2204],
}
//storeHeaderByte: 0x4c, tempHeaderByte: 0x40
     
 const sendPatch: EditorValueTransform = .value("global", "send/patch")
 const latestPatch: EditorValueTransform = .patch("patch")
 
 const patchTransform: MidiTransform = .singleDict(throttle: 500, [sendPatch, latestPatch], .wholePatch({ editorVal, bodyData in
   guard let send = editorVal[sendPatch] as? Int,
         let patch = editorVal[latestPatch] as? SingleSysexPatch else { return [] }
   
   let seqMsg = patchWerk.sysexData(bodyData, channel: 0)
   if send == 1 {
     return [
       (seqMsg, 50),
       (Voice.patchWerk.sysexData(patch.bodyData, channel: 0), 0),
     ]
   }
   else {
     return [(seqMsg, 0)]
   }
 }))
   
 const bankTruss: SingleBankTruss = {
   let patchCount: Int = 16
   
   let createFileData = SingleBankTrussWerk.createFileDataWithLocationMap({ patchWerk.sysexData($0, channel: 0, location: UInt8($1)).bytes() })
   let parseBodyData = SingleBankTrussWerk.sortAndParseBodyDataWithLocationIndex(7, patchTruss: patchTruss, patchCount: patchCount)
   return SingleBankTruss(patchTruss: patchTruss, patchCount: patchCount, createFileData: createFileData, parseBodyData: parseBodyData, validBundle: SingleBankTruss.Core.validBundle(counts: [patchCount * 2204]))
 }()
 
 const refTruss: FullRefTruss = {
    let refPath: SynthPath = "perf"
    
    let trussMap: [(SynthPath, any SysexTruss)] = [
      ("perf", Sequence.patchTruss),
      ("patch", Voice.patchTruss),
    ]
 
    let pathForData: FullRefTruss.PathForDataFn = {
      guard $0.count > 6 else { return nil }
      switch $0[6] {
      case 0x40:
        return "perf"
      case 0x42:
        return "patch"
      default:
        return nil
      }
    }
 
    let createFileData = FullRefTruss.defaultCreateFileData(trussMap: trussMap)
 
    let isos: FullRefTruss.Isos = [
      "patch" : .basic(path: [], location: "pgm", pathMap: ["bank"])
    ]
    
    return FullRefTruss("Full Sequence", trussMap: trussMap, refPath: refPath, isos: isos, sections: [
      ("Sequence", ["perf"]),
      ("Patch", ["patch"]),
    ], initFile: "volca-fm2-full-perf-init", createFileData: createFileData, pathForData: pathForData)
 
  }()
  
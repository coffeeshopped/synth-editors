require('../../core/NumberUtils.js')

const baseParms = {
  osc: [
    {
      prefix: 'osc', count: 2, bx: 6, px: 5, block: {
        incB: 0, p: 0, block: [
          ["semitone", { max: 120, isoS: ['noteName', "C0"] }],
          ["detune", { max: 100, dispOff: -50 }],
          ["shape", { max: 103 }],
          ["glide", { }],
          ["keyTrk", { max: 1 }],
        ]
      }
    },
    {
      prefix: "osc", count: 2, bx: 6, px: 1, block: [
        ["sub", { b: 5, p: 114 }],
      ]
    },
  ],
    
  filter: {
    incB: 20, p: 15, block: [
      [
        ["cutoff", {max: 164}],
        ["reson", {}],
      ],
      {
        prefix: "filter", block: [
          [
            [["keyTrk"], {}],
            [["extAudio"], {}],
            [["fourPole"], {max: 1}],
          ],
          {
            prefix: "env", block: [
              ["amt", {max: 254, dispOff: -127}],
              ["velo", {}],
              ["delay", {}],
              ["attack", {}],
              ["decay", {}],
              ["sustain", {}],
              ["release", {}],
            ]
          }
        ]
      },
    ]
  },
     
  ampEnv: [
    [
      [["amp", "level"], {b: 32, p: 27}],
    ],
    {
      prefix: "amp/env", block: {
        incB: 33, p: 30, block: [
          ["amt", {}],
          ["velo", {}],
          ["delay", {}],
          ["attack", {}],
          ["decay", {}],
          ["sustain", {}],
          ["release", {}],
        ]
      }
    }
  ],
  
  lfo: (b, obj) => ({
    prefix: "lfo", count: 4, bx: 5, px: 5, block: {
      incB: b, p: 37, block: [
        ["freq", {max: 166}],
        ["shape", {opts: obj.lfoWaveOptions}],
        ["amt", {}],
        ["dest", {opts: obj.modDestOptions}],
        ["key/sync", {max: 1}],
      ]
    }
  }),
  
  env3: (b, repB, obj) => ({
    prefix: "env/2", block: [
      {
        incB: b, p: 57, block: [
          ["dest", {opts: obj.modDestOptions}],
          ["amt", {max: 254, dispOff: -127}],
          ["velo", {}],
          ["delay", {}],
          ["attack", {}],
          ["decay", {}],
          ["sustain", {}],
          ["release", {}],
        ]
      },
      [
        ["rrepeat", {b: repB, p: 98, max: 1}],
      ]
    ]
  }),
  
  mods: (b, obj) => ({
    prefix: "mod", count: 4, bx: 3, px: 3, block: {
      incB: b, p: 65, block: [
        ["src", {opts: obj.modSrcOptions}],
        ["amt", {max: 254, dispOff: -127}],
        ["dest", {opts: obj.modDestOptions}],
      ]
    }
  }),
  
  ctrls: (b, obj) => ({
    prefixes: ["modWheel", "pressure", "breath", "velo", "foot"], bx: 2, px: 2, block: {
      incB: b, p: 81, block: [
        [["amt"], {max: 254, dispOff: -127}],
        [["dest"], {opts: obj.modDestOptions}],
      ]
    }
  }),
  
  pushIt: (b, obj) => ({
    prefix: "pushIt", block: {
      incB: b, p: 111, block: [
        ["note", {max: 120, isoS: ['noteName', "C0"] }],
        ["velo", {}],
        ["mode", {opts: obj.pushItModeOptions}],
      ]
    }
  }),
  
  tempoArpSeq: (b, obj) => ({
    incB: b, block: [
      [["tempo"], {p: 91, min: 30, max: 250}],
      [["clock", "divide"], {p: 92, opts: obj.clockDivOptions}],
      [["arp", "mode"], {p: 97, opts: obj.arpModeOptions}],
      [["arp", "on"], {p: 100, max: 1}],
      [["seq", "trigger"], {p: 94, opts: obj.seqTrigOptions}],
      [["seq", "on"], {p: 101, max: 1}],
    ],
  }),
  
  seqSteps: {
    prefix: "seq", count: 4, bx: 16, px: 16, block: {
      prefix: "step", count: 16, bx: 1, px: 1, block: [
        ["", {b: 120, p: 120}],
      ]  
    }
  },
  
  unison: (b) => ({
    incB: b, block: [
      [["unison", "mode"], {p: 95, opts: obj.unisonModeOptions}], // NEW
      [["keyAssign"], {p: 96, opts: obj.keyAssignOptions}],
      [["unison"], {p: 99, max: 1}], // NEW
    ]
  })
}

const mophoTypePatch = (obj) => {
  const expandedBodyCount = obj.fileDataCount - 5
  const bodyCount = obj.bodyCount
  const idByte = obj.idByte
  
  const sysexData = (bytes, headerBytes) => {
    const packedBytes = Byte.pack78(bytes, expandedBodyCount)
    return ([0xf0, 0x01, idByte]).concat(headerBytes).concat(packedBytes).concat([0xf7])
  }

  return Object.assign(obj, {
    type: "singlePatch",
    id: "voice",
    bodyDataCount: bodyCount,
    namePack: [184, 200],
    
    // isValid(fileSize) {
    //   return [fileDataCount, fileDataCount + 2].contains(fileSize)
    // }
    // 
    parseBody: (fileData) => {
      // make dependent on data count, since it can be 298 or 300 (300 is from bank)
      const start = fileData.length - (expandedBodyCount + 1)
      if (start < 0) {
        return (bodyCount).map(() => 0)
        // throw "fileData was too short: "+fileData.length
      }
      return Byte.unpack87(fileData, bodyCount, start, start + expandedBodyCount)
    },
    
    sysexData: (bytes, headerBytes) => sysexData(bytes, headerBytes),
    sysexWriteData: (bytes, bank, location) => sysexData(bytes, [0x02, bank, location]),
    createFile: (bytes) => sysexData(bytes, [0x03]),
    
  })
}

const voicePatch = {
  idByte: 0x25,
  fileDataCount: 298,
  bodyCount: 256,
    
  initFile: "Mopho-init",
  
  randomize: () => [
    ["amp/level", 0],
    ["volume", 127],
    ["amp/env/delay", 0],
    ["amp/env/amt", 127],    
  ],
    
  keyAssignOptions: ["Low Note","Low Note w/ retrig","High Note","High Note w/ retrig","Last Note","Last Note w/ retrig"],
  
  waveOptions: ["Off","Saw","Tri","Saw/Tri","Square"],
  
  glideOptions: ["Fixed Rate", "Fixed Rate Auto","Fixed Time","Fixed Time Auto"],
  
  mixIso: [
    ["range", 0, 63, [['m', -1], ['a', 64], ['str', "O1 +%g"]]],
    ["int", 64, "Bal"],
    ["range", 65, 127, [['a', -64], ['str', "O2 +%g"]]],
  ],
    
  lfoFreqOptions: ["Unsynced","32 steps","16 steps","8 steps","6 steps","4 steps","3 steps","2 steps","1.5 steps","1 step","2/3 step","1/2 step","1/3 step","1/4 step","1/6 step","1/8 step","1/16 step"],
  
  lfoWaveOptions: ["Tri","Rev Saw","Saw","Square","Random"],
  
  pushItModeOptions: ["Normal","Toggle","Audio In"],
  
  clockDivOptions: ["1/2","1/4","1/8","1/8 half swing","1/8 full swing","1/8 triplets","1/16","1/16 half swing","1/16 full swing","1/16 triplets","1/32","1/32 triplets","1/64 triplets"],
  
  arpModeOptions: ["Up","Down","Up/Down","Assign"],
  
  seqTrigOptions: ["Normal","Normal no reset","No Gate","No Gate no reset","Key Step","Audio In"],
  
  modDestOptions: ["Off", "Osc 1 Freq", "Osc 2 Freq", "Osc 1/2 Freq", "Osc Mix", "Noise Level", "Osc 1 PW", "Osc 2 PW", "Osc 1/2 PW", "Filter Cutoff", "Resonance", "Filter Audio Mod", "VCA Level", "Pan Spread", "LFO 1 Freq", "LFO 2 Freq", "LFO 3 Freq", "LFO 4 Freq", "All LFO Freq", "LFO 1 Amt", "LFO 2 Amt", "LFO 3 Amt", "LFO 4 Amt", "All LFO Amt", "Filter Env Amt", "Amp Env Amt", "Env 3 Amt", "All Env Amts", "Env 1 Attack", "Env 2 Attack", "Env 3 Attack", "All Env Attacks", "Env 1 Decay", "Env 2 Decay", "Env 3 Decay", "All Env Decays", "Env 1 Release", "Env 2 Release", "Env 3 Release", "All Env Releases", "Mod 1 Amt", "Mod 2 Amt", "Mod 3 Amt", "Mod 4 Amt", "Ext Audio Level", "Sub Osc 1 Level", "Sub Osc 2 Level"],
  
  modSrcOptions: ["Off", "Seq Track 1", "Seq Track 2", "Seq Track 3", "Seq Track 4", "LFO 1", "LFO 2", "LFO 3", "LFO 4", "Filter Env", "Amp Env", "Env 3", "Pitch Bend", "Mod Wheel", "Pressure", "MIDI Breath", "MIDI Foot", "MIDI Expression", "Velocity", "Note Number", "Noise", "Audio In Env Follow", "Audio In Peak Hold"],
  
  unisonModeOptions: [],
  
  knobAssignOptions: ["Osc 1 Freq", "Osc 1 Fine", "Osc 1 Shape", "Osc 1 Glide", "Osc 1 Key", "Sub Osc 1 Level", "Osc 2 Freq", "Osc 2 Fine", "Osc 2 Shape", "Osc 2 Glide", "Osc 2 Key", "Sub Osc 2 Level", "Sync", "Glide Mode", "Osc Slop", "Bend Range", "Key Assign Mode", "Osc Mix", "Noise Level", "Ext Aud In Level", "Filter Freq", "Resonance", "Filter Key Amt", "Filter Aud Mod", "Filter 4-pole", "Filter Env Amt", "Filter Env Velo", "Filter Env Delay", "Filter Env Attack", "Filter Env Decay", "Filter Env Sustain", "Filter Env Release", "VCA Initial Level", "VCA Env Amt", "VCA Env Velo Amt", "VCA Env Delay", "VCA Env Attack", "VCA Env Decay", "VCA Env Sustain", "VCA Env Release", "Voice Volume", "LFO 1 Freq", "LFO 1 Shape", "LFO 1 Amount", "LFO 1 Mod Dest", "LFO 1 Key Sync", "LFO 2 Freq", "LFO 2 Shape", "LFO 2 Amount", "LFO 2 Mod Dest", "LFO 2 Key Sync", "LFO 3 Freq", "LFO 3 Shape", "LFO 3 Amount", "LFO 3 Mod Dest", "LFO 3 Key Sync", "LFO 4 Freq", "LFO 4 Shape", "LFO 4 Amount", "LFO 4 Mod Dest", "LFO 4 Key Sync", "Env 3 Mod Destination", "Env 3 Amt", "Env 3 Velo Amt", "Env 3 Delay", "Env 3 Attack", "Env 3 Decay", "Env 3 Sustain", "Env 3 Release", "Env 3 Repeat", "Mod 1 Source", "Mod 1 Amount", "Mod 1 Destination", "Mod 2 Source", "Mod 2 Amount", "Mod 2 Destination", "Mod 3 Source", "Mod 3 Amount", "Mod 3 Destination", "Mod 4 Source", "Mod 4 Amount", "Mod 4 Destination", "Mod Wheel Amt", "Mod Wheel Destination", "Pressure Amt", "Pressure Destination", "Breath Amt", "Breath Destination", "Velocity Amt", "Velocity Destination", "Foot Amt", "Foot Destination", "Push It Note", "Push It Velo", "Push It Mode", "Tempo", "Clock Divide", "Arp Mode", "Arp On/Off", "Seq Trigger", "Seq On/Off", "Seq 1 Destination", "Seq 2 Destination", "Seq 3 Destination", "Seq 4 Destination"],
}

mophoTypePatch(voicePatch)

voicePatch.parms = [
  baseParms.osc,
  {
    incB: 12, block: [
      [["sync"], {p: 10, max: 1}],
      [["glide"], {p: 11, opts: voicePatch.glideOptions}],
      [["slop"], {p: 12, max: 5}],
      [["bend"], {p: 93, max: 12}],
      [["keyAssign"], {p: 96, opts: voicePatch.keyAssignOptions}],
      [["mix"], {p: 13, dispOff: -64, isoS: voicePatch.mixIso}],
      [["noise"], {p: 14}],
      [["extAudio"], {p: 116}],
    ]
  },
  baseParms.filter,
  baseParms.ampEnv,
  [
    [["volume"], {b: 40, p: 29}]
  ],
  baseParms.lfo(41, voicePatch),
  baseParms.env3(61, 69, voicePatch),
  baseParms.mods(70, voicePatch),
  baseParms.ctrls(82, voicePatch),
  baseParms.pushIt(92, voicePatch),
  baseParms.tempoArpSeq(95, voicePatch),
  {
    prefix: "seq", count: 4, bx: 1, px: 1, block: [
      ["dest", {b: 101, p: 77, opts: voicePatch.modDestOptions}],
    ]
  },
  baseParms.seqSteps,
  {
    prefix: "knob", count: 4, bx: 1, block: [
      ["", {b: 105, opts: voicePatch.knobAssignOptions}],
    ]
  },
]


module.exports = {
  baseParms: baseParms,
}

console.log(voicePatch)
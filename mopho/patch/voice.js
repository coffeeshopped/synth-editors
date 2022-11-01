const { inc, prefix, prefixes } = require('/core/ParamOptions.js')
require('/core/NumberUtils.js')

module.exports = {

  mophoTypePatch: function(obj) {
    const expandedBodyCount = obj.fileDataCount - 5
    const bodyCount = obj.bodyCount
    const idByte = obj.idByte
    
    function sysexData(bytes, headerBytes) {
      const packedBytes = Byte.pack78(bytes, expandedBodyCount)
      return ([0xf0, 0x01, idByte]).concat(headerBytes).concat(packedBytes).concat([0xf7])
      // return .sysex(data)
    }
  
    return Object.assign(obj, {
      trussType: "SinglePatch",
      localType: "Patch",
      
      nameByteRange: [184, 200],
      
      // isValid(fileSize) {
      //   return [fileDataCount, fileDataCount + 2].contains(fileSize)
      // }
      // 
      bytes: function(fileData) {
        // make dependent on data count, since it can be 298 or 300 (300 is from bank)
        const exp = expandedBodyCount
        const start = fileData.length - (exp + 1)
        if (start < 0) {
          return (bodyCount).map(() => 0)
          // throw "fileData was too short: "+fileData.length
        }
        return Byte.unpack87(fileData, bodyCount, start, start + exp)
      },
      
      sysexData: (bytes, headerBytes) => sysexData(bytes, headerBytes),
      sysexWriteData: (bytes, bank, location) => sysexData(bytes, [0x02, bank, location]),
      fileData: (bytes) => sysexData(bytes, [0x03]),
      
      // func tamedRandomVoice() -> [SynthPath:Int] {
      //   return [
      //     [.amp, .level] : 0,
      //     [.volume] : 127,
      //     [.amp, .env, .delay] : 0,
      //     [.amp, .env, .amt] : 127,
      //   ]
      // }
      // 
    })
  },
    
  osc: function*() {
    yield prefix(["osc"], { count: 2, bx: 6, px: 5 },
      inc({ b: 0, p: 0 }, [
        [["semitone"], { max: 120, isoS: Jiso.noteName("C0") }],
        [["detune"], { max: 100, dispOff: -50 }],
        [["shape"], { max: 103 }],
        [["glide"], { }],
        [["keyTrk"], { max: 1 }],
      ])
    )
    yield prefix(["osc"], { count: 2, bx: 6, px: 1 }, [
      [["sub"], { b: 5, p: 114 }],
    ])
  },
  
  filter: inc({b: 20, p: 15}, function*() {
    yield [
      [["cutoff"], {max: 164}],
      [["reson"], {}],
    ]
    yield prefix(["filter"], {}, function*() {
      yield [
        [["keyTrk"], {}],
        [["extAudio"], {}],
        [["fourPole"], {max: 1}],
      ]
      yield prefix(["env"], {}, [
        [["amt"], {max: 254, dispOff: -127}],
        [["velo"], {}],
        [["delay"], {}],
        [["attack"], {}],
        [["decay"], {}],
        [["sustain"], {}],
        [["release"], {}],
      ])
    })
  }),
  
  ampEnv: function*() {
    yield [
      [["amp", "level"], {b: 32, p: 27}],
    ]
    yield prefix(["amp", "env"], {},
      inc({b: 33, p: 30}, [
        [["amt"], {}],
        [["velo"], {}],
        [["delay"], {}],
        [["attack"], {}],
        [["decay"], {}],
        [["sustain"], {}],
        [["release"], {}],
      ])
    )
  },
  
  lfo: (b, obj) => prefix(["lfo"], {count: 4, bx: 5, px: 5},
    inc({b: b, p: 37}, [
      [["freq"], {max: 166}],
      [["shape"], {opts: obj.lfoWaveOptions}],
      [["amt"], {}],
      [["dest"], {opts: obj.modDestOptions}],
      [["key", "sync"], {max: 1}],
    ])
  ),
  
  env3: (b, repB, obj) => prefix(["env", 2], {}, function *() {
    yield inc({b: b, p: 57}, [
      [["dest"], {opts: obj.modDestOptions}],
      [["amt"], {max: 254, dispOff: -127}],
      [["velo"], {}],
      [["delay"], {}],
      [["attack"], {}],
      [["decay"], {}],
      [["sustain"], {}],
      [["release"], {}],
    ])
    yield [
      [["rrepeat"], {b: repB, p: 98, max: 1}],
    ]
  }),
  
  mods: (b, obj) => prefix(["mod"], {count: 4, bx: 3, px: 3},
    inc({b: b, p: 65}, [
      [["src"], {opts: obj.modSrcOptions}],
      [["amt"], {max: 254, dispOff: -127}],
      [["dest"], {opts: obj.modDestOptions}],
    ])
  ),
  
  ctrls: (b, obj) => prefixes([["modWheel"], ["pressure"], ["breath"], ["velo"], ["foot"]], {bx: 2, px: 2},
    inc({b: b, p: 81}, [
      [["amt"], {max: 254, dispOff: -127}],
      [["dest"], {opts: obj.modDestOptions}],
    ])
  ),
  
  pushIt: (b, obj) => prefix(["pushIt"], {},
    inc({b: b, p: 111}, [
      [["note"], {max: 120, isoS: Jiso.noteName("C0")}],
      [["velo"], {}],
      [["mode"], {opts: obj.pushItModeOptions}],
    ])
  ),
  
  tempoArpSeq: function(b, obj) {
    return inc({b: b}, [
      [["tempo"], {p: 91, min: 30, max: 250}],
      [["clock", "divide"], {p: 92, opts: obj.clockDivOptions}],
      [["arp", "mode"], {p: 97, opts: obj.arpModeOptions}],
      [["arp", "on"], {p: 100, max: 1}],
      [["seq", "trigger"], {p: 94, opts: obj.seqTrigOptions}],
      [["seq", "on"], {p: 101, max: 1}],
    ])
  },
  
  seqSteps: prefix(["seq"], {count: 4, bx: 16, px: 16}, 
    prefix(["step"], {count: 16, bx: 1, px: 1}, [
      [[], {b: 120, p: 120}],
    ])
  ),
  
  // func unison(b: Int) -> [ParamOptions] {
  //   inc(b: b) {[
  //     [["unison", "mode"], p: 95, opts: unisonModeOptions), // NEW
  //     [["keyAssign"], p: 96, opts: keyAssignOptions),
  //     [["unison"], p: 99, max: 1), // NEW
  //   ]}
  // 
  // }
} 
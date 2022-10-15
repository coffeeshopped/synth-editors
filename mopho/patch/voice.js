const { inc, prefix, prefixes } = require('/core/ParamOptions.js')
require('/core/NumberUtils.js')

function MophoTypePatch(idByte) {
  return class {
    static trussType = "SinglePatch"
    static localType = "Patch"
    
    static fileDataCount = 298
    static nameByteRange = [184, 200]
    static sysexHeader = [0xf0, 0x01, idByte]
    static bodyCount = 256

    static expandedBodyCount = function() {
      return this.fileDataCount - 5
    }
    
    // static isValid(fileSize) {
    //   return [fileDataCount, fileDataCount + 2].contains(fileSize)
    // }
    // 
    static bytes = function(fileData) {
      // make dependent on data count, since it can be 298 or 300 (300 is from bank)
      const exp = this.expandedBodyCount()
      const start = fileData.length - (exp + 1)
      if (start < 0) {
        return (this.bodyCount).map(() => 0)
        // throw "fileData was too short: "+fileData.length
      }
      return Byte.unpack87(fileData, this.bodyCount, start, start + exp)
    }
    
    
    static sysexData = function(bytes, headerBytes) {
      const packedBytes = Byte.pack78(bytes, this.expandedBodyCount())
      return this.sysexHeader.concat(headerBytes).concat(packedBytes).concat([0xf7])
      // return .sysex(data)
    }
    
    static sysexWriteData = function(bytes, bank, location) {
      return this.sysexData(bytes, [0x02, bank, location])
    }
    
    static fileData = function(bytes) {
      return this.sysexData(bytes, [0x03])
    }
    
    // static func tamedRandomVoice() -> [SynthPath:Int] {
    //   return [
    //     [.amp, .level] : 0,
    //     [.volume] : 127,
    //     [.amp, .env, .delay] : 0,
    //     [.amp, .env, .amt] : 127,
    //   ]
    // }
    // 
      
    static osc = function*() {
      yield prefix(["osc"], { count: 2, bx: 6, px: 5 }, function*() {
        yield inc({ b: 0, p: 0 }, function*() { 
          yield [
            [["semitone"], { max: 120, isoS: Jiso.noteName("C0") }],
            [["detune"], { max: 100, dispOff: -50 }],
            [["shape"], { max: 103 }],
            [["glide"], { }],
            [["keyTrk"], { max: 1 }],
          ] 
        })
      })
      yield prefix(["osc"], { count: 2, bx: 6, px: 1 }, function*() {
        yield [
          [["sub"], { b: 5, p: 114 }],
        ]
      })
    }
    
    static filter = function*() {
      yield inc({b: 20, p: 15}, function*() {
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
          yield prefix(["env"], {}, function*() {
            yield [
              [["amt"], {max: 254, dispOff: -127}],
              [["velo"], {}],
              [["delay"], {}],
              [["attack"], {}],
              [["decay"], {}],
              [["sustain"], {}],
              [["release"], {}],
            ]
          })
        })
      })
    }
    
    static ampEnv = function*() {
      yield [
        [["amp", "level"], {b: 32, p: 27}],
      ]
      yield prefix(["amp", "env"], {}, function*() {
        yield inc({b: 33, p: 30}, function*() { 
          yield [
            [["amt"], {}],
            [["velo"], {}],
            [["delay"], {}],
            [["attack"], {}],
            [["decay"], {}],
            [["sustain"], {}],
            [["release"], {}],
          ]
        })
      })
    }
    
    static lfo = function*(b, self) {
      yield prefix(["lfo"], {count: 4, bx: 5, px: 5}, function*() {
        yield inc({b: b, p: 37}, function*() { 
          yield [
            [["freq"], {max: 166}],
            [["shape"], {opts: self.lfoWaveOptions}],
            [["amt"], {}],
            [["dest"], {opts: self.modDestOptions}],
            [["key", "sync"], {max: 1}],
          ] 
        })
      })
    }
    
    static env3 = function*(b, repB, self) {
      yield prefix(["env", 2], {}, function *() {
        yield inc({b: b, p: 57}, function *() {
          yield [
            [["dest"], {opts: self.modDestOptions}],
            [["amt"], {max: 254, dispOff: -127}],
            [["velo"], {}],
            [["delay"], {}],
            [["attack"], {}],
            [["decay"], {}],
            [["sustain"], {}],
            [["release"], {}],
          ]
        })
        yield [
          [["rrepeat"], {b: repB, p: 98, max: 1}],
        ]
      })
    }
    
    static mods = function*(b, self) {
      yield prefix(["mod"], {count: 4, bx: 3, px: 3}, function*() {
        yield inc({b: b, p: 65}, function*() {
          yield [
            [["src"], {opts: self.modSrcOptions}],
            [["amt"], {max: 254, dispOff: -127}],
            [["dest"], {opts: self.modDestOptions}],
          ]
        })
      })
    }
    
    static ctrls = function*(b, self) {
      yield prefixes([["modWheel"], ["pressure"], ["breath"], ["velo"], ["foot"]], {bx: 2, px: 2}, function*() {
        yield inc({b: b, p: 81}, function*() {
          yield [
            [["amt"], {max: 254, dispOff: -127}],
            [["dest"], {opts: self.modDestOptions}],
          ]
        })
      })
    }
    
    static pushIt = function*(b, self) {
      yield prefix(["pushIt"], {}, function*() {
        yield inc({b: b, p: 111}, function*() {
          yield [
            [["note"], {max: 120, isoS: Jiso.noteName("C0")}],
            [["velo"], {}],
            [["mode"], {opts: self.pushItModeOptions}],
          ]
        })
      })
    }
    
    static tempoArpSeq = function*(b, self) {
      yield inc({b: b}, function*() {
        yield [
          [["tempo"], {p: 91, min: 30, max: 250}],
          [["clock", "divide"], {p: 92, opts: self.clockDivOptions}],
          [["arp", "mode"], {p: 97, opts: self.arpModeOptions}],
          [["arp", "on"], {p: 100, max: 1}],
          [["seq", "trigger"], {p: 94, opts: self.seqTrigOptions}],
          [["seq", "on"], {p: 101, max: 1}],
        ]
      })
    }
    
    static seqSteps = function*() {
      yield prefix(["seq"], {count: 4, bx: 16, px: 16}, function*() {
        yield prefix(["step"], {count: 16, bx: 1, px: 1}, function*() {
          yield [
            [[], {b: 120, p: 120}],
          ]
        })
      })
    }
    
    // static func unison(b: Int) -> [ParamOptions] {
    //   inc(b: b) {[
    //     [["unison", "mode"], p: 95, opts: unisonModeOptions), // NEW
    //     [["keyAssign"], p: 96, opts: keyAssignOptions),
    //     [["unison"], p: 99, max: 1), // NEW
    //   ]}
    // 
    // }

  }
}


module.exports = MophoTypePatch 
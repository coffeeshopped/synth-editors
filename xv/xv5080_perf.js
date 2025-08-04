const XVPerf = require('./xv_perf.js')
const XV5050Perf = require('./xv5050_perf.js')
const FX = require('./xv5080_fx.js')

const commonParms = XV5050Perf.commonParms.concat([
  ['solo', { b: 0x0c, iso: XVPerf.soloIso, max: 32 }],
  ['fx/0/src', { b: 0x30, iso: XVPerf.srcIso, max: 32 }],
  ['fx/1/src', { b: 0x31, iso: XVPerf.srcIso, max: 32 }],
  ['fx/2/src', { b: 0x32, iso: XVPerf.srcIso, max: 32 }],
  ['chorus/src', { b: 0x33, iso: XVPerf.srcIso, max: 32 }],
  ['reverb/src', { b: 0x34, iso: XVPerf.srcIso, max: 32 }],
])

const partParms = XV3080Perf.partParms.concat([
  ['out/assign', { b: 0x1f, opts: outAssignOptions }],
  ['out/fx', { b: 0x20, opts: ["A","B","C"] }],
])

const commonPatchWerk = XVPerf.commonPatchWerk(commonParms)

const partPatchWerk = XVPerf.partPatchWerk(partParms, 0x21)

const partConfig = XV3080Perf.partConfig
partConfig.voicePartGroups = internalPartGroupOptions <<< XV.Perf.Part.srjvPartGroupOptions <<< XV.Perf.Part.srxPartGroupOptions


const patchWerk = XVPerf.patchWerk(32, {
  common: commonPatchWerk, 
  part: partPatchWerk, 
  fx: FX.patchWerk, 
  chorus: FX.chorusPatchWerk, 
  reverb: FX.reverbPatchWerk,
}, [], "xv5050-perf-init")

const bankWerk = XVPerf.bankWerk(patchWerk, "xv3080-perf-bank-init")

module.exports = {
  patchWerk,
  bankWerk,
}

extension XV5080 {
  
  enum Perf {
    
    const fullRefTruss = XV.Perf.Full.refTruss(32, perf: patchWerk, voice: Voice.patchWerk, rhythm: rhythmPatchWerk)

    enum Part {
      
      const outAssignOptions = Voice.Tone.outAssignOptions <<<
        [13 : "Patch"]
      
      const internalPartGroupOptions: [Int:String] = {
        let ids = [
          [],
          "int/user",
          "int/preset/0",
          "int/preset/1",
          "int/preset/2",
          "int/preset/3",
          "int/preset/4",
          "int/preset/5",
          "int/preset/6",
          "int/gm2",
        ]
        return ids.dict {
          [XV.Perf.Part.value(forSynthPath: $0) : XV.Perf.Part.internalGroupsMap[$0] ?? ""]
        }
      }()
      

    }
  }
  
}

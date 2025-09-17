const noteIso = ['noteName', "C-2"]

function createParms(instMap, chorusMax) {

  var reverseInstMap = []
  instMap.forEach((item, index) => {
    if (reverseInstMap[item[1]] == null) {
      reverseInstMap[item[1]] = []
    }
    reverseInstMap[item[1]][item[0]] = index
  })
  
  return [
    { prefix: "link", count: 3, bx: 0, px: 1, block: [
      ['', { p: 12 }],
    ] },
    { prefix: "key/lo", count: 4, bx: 0, px: 1, block: [
      ['', { p: 15, iso: noteIso }],
    ] },
    { prefix: "key/hi", count: 4, bx: 0, px: 1, block: [
      ['', { p: 19, iso: noteIso }],
    ] },
    { prefix: '', count: 2, bx: 0, px: 18, block: (i) => [
      ['wave', { p: 23, packIso: instPackIso(23 + i * 18, instMap, reverseInstMap),opts: instMap.map(m => m[2]) }],
      ['start', { p: 24 }],
      ['coarse', { p: 25, rng: [-36, 36] }],
      ['fine', { p: 26, rng: [-64, 64] }],
      ['volume', { p: 27 }],
      ['pan', { p: 28, rng: [-7, 7] }],
      ['delay', { p: 29 }],
      ['key/lo', { p: 30, iso: noteIso }],
      ['key/hi', { p: 31, iso: noteIso }],
      ['attack', { p: 32, rng: [0, 99] }],
      ['hold', { p: 33, rng: [0, 99] }],
      ['decay', { p: 34, rng: [0, 99] }],
      ['sustain', { p: 35, rng: [0, 99] }],
      ['release', { p: 36, rng: [0, 99] }],
      ['env/on', { p: 37, max: 1 }],
      ['solo', { p: 38 }],
      ['chorus', { p: 39, max: chorusMax }],
      ['reverse', { p: 40 }],
    ] },
    ['cross/mode', { p: 59, opts: ["Off", "XFade", "XSwitch"] }],
    ['cross/direction', { p: 60, opts: ["Pri>Sec", "Sec>Pri"] }],
    ['cross/balance', { p: 61 }],
    ['cross/amt', { p: 62, max: 255 }],
    ['cross/pt', { p: 63, iso: noteIso }],
    { prefix: "lfo", count: 2, bx: 0, px: 5, block: [
      ['shape', { p: 64, opts: ["Rand", "Tri", "Sine", "Saw", "Square"] }],
      ['freq', { p: 65 }],
      ['delay', { p: 66 }],
      ['mod', { p: 67 }],
      ['amt', { p: 68, rng: [-128, 127] }],
    ] },
    ['extra/delay', { p: 74, max: 127 }],
    ['extra/attack', { p: 75, max: 99 }],
    ['extra/hold', { p: 76, max: 99 }],
    ['extra/decay', { p: 77, max: 99 }],
    ['extra/sustain', { p: 78, max: 99 }],
    ['extra/release', { p: 79, max: 99 }],
    ['extra/amt', { p: 80, rng: [-128, 127] }],
    { prefix: "key/velo", count: 6, bx: 0, px: 1, block: [
      ['src', { p: 81, opts: ["Key", "Velo"] }],
      ['dest', { p: 87, opts: ["Off", "Pitch", "Pitch P", "Pitch S", "Volume", "Volume P", "Volume S", "Attack", "Attack P", "Attack S", "Decay", "Decay P", "Decay S", "Release", "Release P", "Release S", "XFade", "LFO 1 Amt", "LFO 1 Rate", "LFO 2 Amt", "LFO 2 Rate", "Aux Amt", "Aux Attack", "Aux Decay", "Aux Release", "Start", "Start P", "Start S", "Pan", "Pan P", "Pan S", "Tone", "Tone P", "Tone S"] }],
      ['amt', { p: 93, rng: [-128, 127] }],
    ] },
    { prefix: "mod", count: 8, bx: 0, px: 1, block: [
      ['src', { p: 99, opts: ["Pitch Whl", "Ctrl A", "Ctrl B", "Ctrl C", "Ctrl D", "Mono Press", "Poly Press", "LFO 1", "LFO 2", "Aux"] }],
      ['dest', { p: 107, opts: ["Off", "Pitch", "Pitch P", "Pitch S", "Volume", "Volume P", "Volume S", "Attack", "Attack P", "Attack S", "Decay", "Decay P", "Decay S", "Release", "Release P", "Release S", "Crossfade", "LFO 1 Amount", "LFO 1 Rate", "LFO 2 Amount", "LFO 2 Rate", "Aux Amount", "Aux Attack", "Aux Decay", "Aux Release"] }],
    ] },
    { prefix: "foot", count: 3, bx: 0, px: 1, block: [
      ['dest', { p: 115, opts: ["Off", "Sustain", "Sustain P", "Sustain S", "Alt Env", "Alt Env P", "Alt Env S", "Alt Rel", "Alt Rel P", "Alt Rel S", "XSwitch"] }],
    ] },
    { prefix: "ctrl", count: 4, bx: 0, px: 1, block: [
      ['amt', { p: 118, rng: [-128, 127] }],
    ] },
    ['pressure/amt', { p: 122, rng: [-128, 127] }],
    ['bend', { p: 123, opts: 14.map { $0 > 12 ? "Global" : "+/-\($0)" } }],
    ["velo/curve", { p: 124, opts: (6).map(i => i == 0 ? "Off" : i == 5 ? "Global" : `${i}`)],
    ['key/mid', { p: 125, iso: noteIso }],
    ['mix', { p: 126, opts: ["Main", "Sub1", "Sub2"] }],
    ['tune', { p: 127, opts: ["Equal", "Just C", "Vallotti", "19-Tone", "Gamelan", "User"] }],
  ]
  
}

function createPatchTruss(proteus, parms, initFile) {
  return {
    single: `proteus${proteus}.voice`,
    bodyDataCount: 256,
    parms: parms,
    initFile: initFile,
    namePackIso: namePackIso,
    createFileData: {
      sysexData($0, deviceId: 0).flatMap { $0 }
    }, 
    parseBodyData: {
      switch $0.count {
      case 265:
        return [UInt8]($0[7..<263]) // 256 data bytes
      default:
        var bytes = [UInt8](repeating: 0, count: 256)
        SysexData(data: $0.data()).forEach { msg in
          guard msg.count > 8 else { return }
          let off = Int(msg[5]) + (Int(msg[6]) << 7)
          guard off >= 0 && off * 2 + 1 < bytes.count else { return }
          bytes[off * 2] = msg[7]
          bytes[off * 2 + 1] = msg[8]
        }
        return bytes
      }
    }, 
    validSizes: ['auto', 1280, 265],
    pack: (parm, value) => Proteus.pack(parm.p, value),
    unpack: (parm) => Proteus.unpack(parm.p),
  }
}

function createBankTruss(patchTruss, initFile) {
  const patchCount = 64
  return {
    singleBank: patchTruss,
    patchCount: patchCount, 
    initFile: initFile, 
    fileDataCount: patchCount * 265, 
    createFileData: SingleBankTrussWerk.createFileDataWithLocationMap {
      sysexData($0, deviceId: 0, location: $1 + 64)
    }, 
    parseBodyData: SingleBankTrussWerk.sortAndParseBodyDataWithLocationMap({
      0.set(bits: 0...6, value: $0[5]).set(bits: 7...13, value: $0[6]) % 64
    }, 
    patchCount: patchCount,
  }
}
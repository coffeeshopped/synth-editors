
const osc1WaveOptions = ["Square","Saw","Triangle","Sine"]

const osc2WaveOptions = ["Square","Saw","Triangle","Noise"]

const filterTypeOptions = ["Lo-Pass 12dB","Lo-Pass 24dB", "Hi-Pass","Bandpass","Notch + LP", "Secret"]

const filterKeyTrackOptions = ["Off","1/3","2/3","Full"]

const lfo1WaveOptions = ["Random","Saw","Triangle","Square","Smooth Random"]

const lfo1DestOptions = ["PW","Filter","Osc 2","Osc 1+2","FM"]

const voiceModeOptions = ["Mono","Legato","Poly"]

const modWheelDestOptions = ["Filter","FM","Osc 2","LFO 1","Morph"]

const mEnvDestOptions = ["Osc 2","FM","PW","Off"]

const lfo2DestOptions = ["Arp: Down","Arp: Up","Arp: Up & Down","LFO: Amp","LFO: Osc 1+2","Arp: Random","Arp: Echo","LFO: Filter"]

const mixOptions = OptionsParam.makeOptions(
  ([0, 63]).map { `+${64-$0} O1` } + ["0"] +
  ([65, 127]).map { `+${$0-64} O2` })
  
const parms = [
  ["osc/1/pitch", { p: 78, b: 0, max: 120, dispOff: -60 }],
  ["osc/1/fine", { p: 33, b: 1, dispOff: -64 }],
  ["mix", { p: 8, b: 2, opts: mixOptions }],
  ["filter/cutoff", { p: 74, b: 3 }],
  ["filter/reson", { p: 42, b: 4 }],
  ["filter/env/amt", { p: 43, b: 5 }],
  ["pw", { p: 79, b: 6 }],
  ["fm/amt", { p: 70, b: 7 }],
  ["filter/env/attack", { p: 38, b: 8 }],
  ["filter/env/decay", { p: 39, b: 9 }],
  ["filter/env/sustain", { p: 40, b: 10 }],
  ["filter/env/release", { p: 41, b: 11 }],
  ["amp/env/attack", { p: 73, b: 12 }],
  ["amp/env/decay", { p: 36, b: 13 }],
  ["amp/env/sustain", { p: 37, b: 14 }],
  ["amp/env/release", { p: 72, b: 15 }],
  ["porta", { p: 5, b: 16 }],
  ["amp/gain", { p: 7, b: 17 }],
  ["mod/env/attack", { p: 26, b: 18 }],
  ["mod/env/decay", { p: 27, b: 19 }],
  ["mod/env/amt", { p: 29, b: 20, dispOff: -64 }],
  ["lfo/0/rate", { p: 19, b: 21 }],
  ["lfo/0/amt", { p: 22, b: 22 }],
  ["lfo/1/rate", { p: 23, b: 23 }],
  ["arp/range", { p: 25, b: 24 }],
  ["osc/1/pitch/sens", { b: 25 }],
  ["osc/1/fine/sens", { b: 26 }],
  ["mix/sens", { b: 27 }],
  ["cutoff/sens", { b: 28 }],
  ["reson/sens", { b: 29 }],
  ["filter/env/amt/sens", { b: 30 }],
  ["pw/sens", { b: 31 }],
  ["fm/amt/sens", { b: 32 }],
  ["filter/env/attack/sens", { b: 33 }],
  ["filter/env/decay/sens", { b: 34 }],
  ["filter/env/sustain/sens", { b: 35 }],
  ["filter/env/release/sens", { b: 36 }],
  ["amp/env/attack/sens", { b: 37 }],
  ["amp/env/decay/sens", { b: 38 }],
  ["amp/env/sustain/sens", { b: 39 }],
  ["amp/env/release/sens", { b: 40 }],
  ["porta/sens", { b: 41 }],
  ["gain/sens", { b: 42 }],
  ["mod/env/attack/sens", { b: 43 }],
  ["mod/env/decay/sens", { b: 44 }],
  ["mod/env/amt/sens", { b: 45 }],
  ["lfo/0/rate/sens", { b: 46 }],
  ["lfo/0/amt/sens", { b: 47 }],
  ["lfo/1/rate/sens", { b: 48 }],
  ["arp/range/sens", { b: 49 }],
  ["osc/0/wave", { p: 30, b: 50, opts: osc1WaveOptions }],
  ["osc/1/wave", { p: 31, b: 51, opts: osc2WaveOptions }],
  ["sync", { p: 35, b: 52, bit: 0 }],
  ["ringMod", { b: 52, bit: 1 }],
  ["filter/dist", { p: 80, b: 52, bit: 4 }],
  ["filter/type", { p: 44, b: 53, opts: filterTypeOptions }],
  ["osc/1/keyTrk", { p: 34, b: 54, max: 1 }],
  ["filter/keyTrk", { p: 46, b: 55, opts: filterKeyTrackOptions }],
  ["lfo/0/wave", { p: 20, b: 56, opts: lfo1WaveOptions }],
  ["lfo/0/dest", { p: 21, b: 57, opts: lfo1DestOptions }],
  ["voice/mode", { p: 15, b: 58, opts: voiceModeOptions }],
  ["modWheel/dest", { p: 18, b: 59, opts: modWheelDestOptions }],
  ["unison", { p: 16, b: 60, max: 1 }],
  ["mod/env/dest", { p: 28, b: 61, opts: mEnvDestOptions }],
  ["auto", { p: 65, b: 62, max: 1 }],
  ["filter/velo", { p: 45, b: 63, max: 1 }],
  ["octave/shift", { p: 17, b: 64, max: 4 }],
  ["lfo/1/dest", { p: 24, b: 65, opts: lfo2DestOptions }],
]

static func bank(forData data: Data) -> Int { return Int(data[4]) }
static func location(forData data: Data) -> Int { return Int(data[5]) }

// bank: 0 = temp, [1, 4] = bank 1-4
// location: temp: [0, 3] (A-D)

func fileData() -> Data {
  return sysexData(deviceId: 0, bank: 0, location: 0)
}

const patchTruss = {
  single: 'voice',
  initFile: "Nord-Lead-init",
  parms: parms,
  parseBody: ['>',
    ['bytes', { start: 6, count: 132 }],
    'denibblizeLSB',
  ],
}

const bankTruss = {
  singleBank: patchTruss,
  patchCount: 99,
  initFile: "nl2-voice-bank-init",
}

  override func fileData() -> Data {
  return sysexData { $0.sysexData(deviceId: 0, bank: 1, location: $1) }
}


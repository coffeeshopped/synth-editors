

const midFreqExpPartIso = Miso.m(0.05594567) >>> Miso.exp() >>> Miso.m(19.71256116) >>> Miso.a(-0.60837824)
const midFreqIso = Miso.switcher([
  .range([0, 112], midFreqExpPartIso),
  .range([113, 126], Miso.a(1) >>> midFreqExpPartIso)
]) >>> Miso.round() >>> Miso.str()


const modSrcOptions = ["Off", "Pitch Bend", "Chan Press", "Mod Wheel", "Breath", "Ctrlr 3", "Foot Pedal", "Data Entry", "Balance", "Ctrlr 9", "Expression", "Ctlr 12", "Ctlr 13", "Ctlr 14", "Ctlr 15", "Ctlr 16", "Hold Pedal", "Porta Sw", "Sus Pedal", "Amp Env", "Filt Env", "LFO 1", "LFO 2", "LFO 3", "Velo On", "Velo Off", "Key Follow", "Random"]

const modDestOptions = ["Off", "Patch Vol", "Chan Vol", "Pan", "Transpose", "Porta", "Osc 1 Shape", "Osc 1 PW", "Osc 1 Wave Sel", "Osc 1 Pitch", "Osc 1 KeyFol", "Osc 2 Shape", "Osc 2 PW", "Osc 2 Wave Sel", "Osc 2 Pitch", "Osc 2 Detune", "Osc 2 FM Amt", "Filt Env>Osc 2 Pitch", "Filt Env>FM/Sync", "Osc 2 KeyFol", "Osc Balance", "Sub Volume", "Osc Volume", "Noise Volume", "Filter 1 Cutoff", "Filter 2 Cutoff", "Filter 1 Reson", "Filter 2 Reson", "F1 Env Amt", "F2 Env Amt",
                             
    "F1 KeyFol", "F2 KeyFol", "Filter Balance", "F Env Attack", "F Env Decay", "F Env Sustain", "F Env Sus Time", "F Env Release", "Amp Env Attack", "Amp Env Decay", "Amp Env Sustain", "Amp Env Sus Time", "Amp Env Release", "LFO 1 Rate", "LFO 1 Contour", "LFO 1>Osc 1 Pitch", "LFO 1>Osc 2 Pitch", "LFO 1>PW", "LFO 1>Reson", "LFO 1>Filter Gain", "LFO 2 Rate", "LFO 2 Contour", "LFO2>Shape", "LFO2>FM Amt", "LFO2>Cutoff 1", "LFO2>Cutoff 2", "LFO2>Pan", "LFO 3 Rate", "LFO 3 Assign Amt", "Unison Detune",
    
    "Uni Spread", "Unison LFO Phase", "Chorus Mix", "Chorus Rate", "Chorus Depth", "Chorus Delay", "Chorus Feedback", "FX Send", "Delay Time", "Delay Feedback", "Delay Rate", "Delay Depth", "Velo>Osc1 Sh", "Velo>Osc2 Sh", "Velo>PW", "Velo>FM", "Velo>F1 Env", "Velo>F2 Env", "Velo>Reso 1", "Velo>Reso 2", "Velo>Amp", "Velo Pan", "Assign 1 Amt 1", "Assign 2 Amt 1", "Assign 2 Amt 2", "Assign 3 Amt 1", "Assign 3 Amt 2", "Assign 3 Amt 3", "Osc Init Phase", "Punch Intens",
    
    "Ring Mod", "Noise Color", "Delay Color", "A Boost Int", "A Boost Tune", "Dist Intens", "Ringmod Mix", "Osc 3 Volume", "Osc 3 Pitch", "Osc 3 Detune", "LFO 1 Assign Amt", "LFO 2 Assign Amt", "Phaser Mix", "Phaser Rate", "Phaser Depth", "Phaser Freq", "Phaser Feedbk", "Phaser Spread", "Reverb Decay", "Reverb Damp", "Reverb Color", "Reverb PreDelay", "Reverb Feedbk", "Sec Balance", "Arp Note Length", "Arp Swing Factor", "Arp Pattern", "EQ Mid Gain", "EQ Mid Freq", "EQ Mid Q", "Assign 4 Amt", "Assign 5 Amt", "Assign 6 Amt"]

const knobNames = [">Para", "+3rds", "+4ths", "+5ths", "+7ths", "+Octave", "Access", "ArpMode", "ArpOct", "Attack", "Balance", "Chorus", "Cutoff", "Decay", "Delay", "Depth", "Destroy", "Detune", "Disolve", "Distort", "Dive", "Effects", "Elevate", "Energy", "EqHigh", "EqLow", "EqMid", "Fast", "Fear", "Filter", "FM", "Glide", "Hold", "Hype", "Infect", "Length", "Mix", "Morph", "Mutate", "Noise", "Open", "Orbit", "Pan", "Phaser", "Phatter", "Pitch", "Pulsate", "Push", "PWM", "Rate", "Release", "Reso", "Reverb", "Scream", "Shape", "Sharpen", "Slow", "Soften", "Speed", "SubOsc", "Sustain", "Sweep", "Swing", "Tempo", "Thinner", "Tone", "Tremolo", "Vibrato", "WahWah", "Warmth", "Warp", "Width"]

const knobOptions = ["Off", "Mod Wheel", "Breath", "Ctrl 3", "Foot", "Data", "Balance", "Ctrl 9", "Expression", "Ctrl 12", "Ctrl 13", "Ctrl 14", "Ctrl 15", "Ctrl 16", "Patch Volume", "Channel Volume", "Pan", "Transpose", "Portamento", "Unison Detune", "Unison Pan Sprd", "Unison Lfo Phase", "Chorus Mix", "Chorus Rate", "Chorus Depth", "Chorus Delay", "Chorus Feedback", "Effect Send", "Delay Time", "Delay Feedback", "Delay Rate", "Delay Depth", "Osc1 Wav Select", "Osc1 Pulse Width", "Osc1 Semitone", "Osc1 Keyfollow", "Osc2 Wav Select", "Osc2 Pulse Width", "Osc2 Env Amount", "Fm Env Amount", "Osc2 Keyfollow", "Noise Volume", "Filt1 Resonance", "Filt2 Resonance", "Filt1 Env Amount", "Filt2 Env Amount", "Filt1 Keyfollow", "Filt2 Keyfollow", "Lfo1 Contour", "Lfo1>Osc1", "Lfo1>Osc2", "Lfo1>Puls Width", "Lfo1>Resonance", "Lfo1>Filt Gain", "Lfo2 Contour", "Lfo2>Shape", "Lfo2>Fm Amount", "Lfo2>Cutoff1", "Lfo2>Cutoff2", "Lfo2>Pan", "Lfo3 Rate", "Lfo3 Osc Amount", "Osc1 Shape Vel", "Osc2 Shape Vel", "Puls Width Vel", "Fm Amount Vel", "Filt1 Env Vel", "Filt2 Env Vel", "Resonance1 Vel", "Resonance2 Vel", "Amplifier Vel", "Pan Vel", "Assign1 Amt1", "Assign2 Amt1", "Assign2 Amt2", "Assign3 Amt1", "Assign3 Amt2", "Assign3 Amt3", "Clock Tempo", "Input Thru", "Osc Init Phase", "Punch Intensity", "Ringmodulator", "Noise Color", "Delay Color", "Analog Boost Int", "Analog Bst Tune", "Distortion Int", "Ring Mod Mix", "Osc3 Volume", "Osc3 Semitone", "Osc3 Detune", "Lfo1 Assign Amt", "Lfo2 Assign Amt", "Phaser Mix", "Phaser Rate", "Phaser Depth", "Phaser Frequenc", "Phaser Feedback", "Phaser Spread", "Rev Decay Time", "Reverb Damping", "Reverb Color", "Reverb Feedback", "Second Balance", "Arp Mode", "Arp Pattern", "Arp Clock", "Arp Note Length", "Arp Swing", "Arp Octaves", "Arp Hold", "Eq Mid Gain", "Eq Mid Freq", "Eq Mid Q", "Assign4 Amt", "Assign5 Amt", "Assign6 Amt"]

const distortModes = ["Off", "Light", "Soft", "Middle", "Hard", "Digital", "Shaper", "Rectifier", "Bit Reducer", "Rate Reducer", "Low Pass", "High Pass"]

const arpResolutionOptions = ["1/64", "1/32", "1/16", "1/8", "1/4", "1/2", "3/64", "3/32", "3/16", "3/8", "1/24", "1/12", "1/6", "1/3", "2/3", "3/4", "1/1"]

const unisonModeIso = Miso.switcher([
  .int(0, "Off"),
  .int(1, "Twin")
], default: Miso.a(1) >>> Miso.str())

const vocoderModes = VirusTIVoice.vocoderModes + ["Aux1 L", "Aux1 L+R", "Aux1 R", "Aux2 L", "Aux2 L+R", "Aux2 R"]

const delayModeOptions = ["Off", "Delay", "Reverb", "Reverb+Fdbk1", "Reverb+Fdbk2", "Delay 2:1", "Delay 4:3", "Delay 4:1", "Delay 8:7", "Pattern 1+1", "Pattern 2+1", "Pattern 3+1", "Pattern 4+1", "Pattern 5+1", "Pattern 2+3", "Pattern 2+5", "Pattern 3+2", "Pattern 3+3", "Pattern 3+4", "Pattern 3+5", "Pattern 4+3", "Pattern 4+5", "Pattern 5+2", "Pattern 5+3", "Pattern 5+4", "Pattern 5+5"]

const categoryOptions = ["Off", "Lead", "Bass", "Pad", "Decay", "Pluck", "Acid", "Classic", "Arpeggiator", "EFX", "Drums", "Percussion", "Input", "Vocoder", "Favourites 1", "Favourites 2", "Favourites 3", "Organ", "Piano", "String", "FM", "Digital"]

const smoothOptions = ["Off", "On", "Auto", "Note"]

const parms = [
  ["porta", { b: 5, iso: VirusTIVoice.noiseVolIso }],
  ["pan", { b: 10, dispOff: -64 }],
  ["osc/0/shape", { b: 17, iso: VirusTIVoice.oscShapeIso }],
  ["osc/0/pw", { b: 18, iso: VirusTIVoice.pwIso }],
  ["osc/0/wave", { b: 19, max: 63, iso: VirusTIVoice.waveSelectIso }],
  ["osc/0/semitone", { b: 20, rng: [16, 112], dispOff: -64 }],
  ["osc/0/keyTrk", { b: 21, iso: VirusTIVoice.keyFollowIso }],
  ["osc/1/shape", { b: 22, iso: VirusTIVoice.oscShapeIso }],
  ["osc/1/pw", { b: 23, iso: VirusTIVoice.pwIso }],
  ["osc/1/wave", { b: 24, max: 63, iso: VirusTIVoice.waveSelectIso }],
  ["osc/1/semitone", { b: 25, rng: [16, 112], dispOff: -64 }],
  ["osc/1/detune", { b: 26 }],
  ["fm/amt", { b: 27 }],
  ["osc/0/sync", { b: 28 }],
  ["filter/env/pitch", { b: 29, dispOff: -64 }],
  ["filter/env/fm", { b: 30, dispOff: -64 }],
  ["osc/1/keyTrk", { b: 31, iso: VirusTIVoice.keyFollowIso }],
  ["osc/balance", { b: 33, dispOff: -64 }],
  ["sub/level", { b: 34 }],
  ["sub/shape", { b: 35, opts: ["Square", "Triangle"] }],
  ["osc/level", { b: 36, dispOff: -64 }],
  ["noise/level", { b: 37, iso: VirusTIVoice.noiseVolIso }],
  ["noise/color", { b: 39, dispOff: -64 }],
  ["filter/0/cutoff", { b: 40 }],
  ["filter/1/cutoff", { b: 41 }],
  ["filter/reson", { b: 42 }],
  ["filter/reson/extra", { b: 43 }],
  ["filter/env/amt", { b: 44 }],
  ["filter/env/extra", { b: 45 }],
  ["filter/keyTrk", { b: 46, dispOff: -64 }],
  ["filter/keyTrk/extra", { b: 47, dispOff: -64 }],
  ["filter/balance", { b: 48, dispOff: -64 }],
  ["saturation/type", { b: 49, opts: ["Off", "Light", "Soft", "Middle", "Hard", "Digital", "Waveshaper", "Rectifier", "Bit Reducer", "Rate Reducer", "Rate+Follow", "Low Pass", "Low+Follow", "High Pass", "High+Follow"] }],
  ["ringMod/level", { b: 50, iso: VirusTIVoice.noiseVolIso }],
  ["filter/0/mode", { b: 51, opts: ["Low Pass", "Hi Pass", "Band Pass", "Band Stop", "Analog 1 Pole", "Analog 2 Pole", "Analog 3 Pole", "Analog 4 Pole"] }],
  ["filter/1/mode", { b: 52, opts: ["Low Pass", "Hi Pass", "Band Pass", "Band Stop"] }],
  ["filter/routing", { b: 53, opts: ["Serial 4", "Serial 6", "Parallel 4", "Split Mode"] }],
  ["filter/env/attack", { b: 54 }],
  ["filter/env/decay", { b: 55 }],
  ["filter/env/sustain", { b: 56 }],
  ["filter/env/sustain/slop", { b: 57, dispOff: -64 }],
  ["filter/env/release", { b: 58 }],
  ["amp/env/attack", { b: 59 }],
  ["amp/env/decay", { b: 60 }],
  ["amp/env/sustain", { b: 61 }],
  ["amp/env/sustain/slop", { b: 62, dispOff: -64 }],
  ["amp/env/release", { b: 63 }],
  ["lfo/0/rate", { b: 67 }],
  ["lfo/0/shape", { b: 68, max: 67, iso: VirusTIVoice.lfoShapeIso }],
  ["lfo/0/env/mode", { b: 69, max: 1 }],
  ["lfo/0/mode", { b: 70, opts: ["Poly", "Mono"] }],
  ["lfo/0/curve", { b: 71, dispOff: -64 }],
  ["lfo/0/keyTrk", { b: 72 }],
  ["lfo/0/trigger", { b: 73, iso: VirusTIVoice.noiseVolIso }],
  ["lfo/0/osc", { b: 74, dispOff: -64 }],
  ["lfo/0/osc/1", { b: 75, dispOff: -64 }],
  ["lfo/0/pw", { b: 76, dispOff: -64 }],
  ["lfo/0/filter/reson", { b: 77, dispOff: -64 }],
  ["lfo/0/filter/env", { b: 78, dispOff: -64 }],
  ["lfo/1/rate", { b: 79 }],
  ["lfo/1/shape", { b: 80, max: 67, iso: VirusTIVoice.lfoShapeIso }],
  ["lfo/1/env/mode", { b: 81, max: 1 }],
  ["lfo/1/mode", { b: 82, opts: ["Poly", "Mono"] }],
  ["lfo/1/curve", { b: 83, dispOff: -64 }],
  ["lfo/1/keyTrk", { b: 84 }],
  ["lfo/1/trigger", { b: 85, iso: VirusTIVoice.noiseVolIso }],
  ["lfo/1/osc/shape", { b: 86, dispOff: -64 }],
  ["lfo/1/fm", { b: 87, dispOff: -64 }],
  ["lfo/1/cutoff", { b: 88, dispOff: -64 }],
  ["lfo/1/cutoff/1", { b: 89, dispOff: -64 }],
  ["lfo/1/pan", { b: 90, dispOff: -64 }],
  ["volume", { b: 91 }],
  ["transpose", { b: 93, dispOff: -64 }],
  ["osc/key/mode", { b: 94, opts: ["Poly", "Mono 1", "Mono 2", "Mono 3", "Mono 4", "Hold"] }],
  
  // in Virus TI, these are elsewhere.
  ["unison/mode", { b: 97, rng: [0, 15], iso: unisonModeIso }],
  ["unison/detune", { b: 98 }],
  ["unison/pan", { b: 99 }],
  ["unison/phase", { b: 100, dispOff: -64 }],
  ["input/mode", { b: 101, opts: ["Off", "Dynamic", "Static", "To FX"] }],
  ["input/select", { b: 102, opts: ["In L", "In L + R", "In R", "Aux1 L", "Aux1 L + R", "Aux1 R", "Aux2 L", "Aux2 L + R", "Aux2 R"] }],
  
  ["chorus/mix", { b: 105, iso: VirusTIVoice.noiseVolIso }],
  ["chorus/rate", { b: 106 }],
  ["chorus/depth", { b: 107 }],
  ["chorus/delay", { b: 108 }],
  ["chorus/feedback", { b: 109, dispOff: -64 }],
  ["chorus/shape", { b: 110, opts: VirusTIVoice.delayLFOWaveOptions }],

  ["delay/mode", { b: 112, opts: delayModeOptions }],
  ["delay/send", { b: 113 }],
  ["delay/time", { b: 114, iso: VirusTIVoice.delayTimeIso }],
  ["delay/feedback", { b: 115 }],
  ["delay/rate", { b: 116 }],
  ["delay/depth", { b: 117 }],
  ["delay/shape", { b: 118, opts: VirusTIVoice.delayLFOWaveOptions }],
  ["delay/color", { b: 119, dispOff: -64 }],
//    ["local", { b: 122 }],

  ["arp/mode", { b: 129, opts: ["Off", "Up", "Down", "Up&Down", "As Played", "Random", "Chord"] }],
  ["arp/pattern", { b: 130, max: 63, dispOff: 1 }],
  ["arp/range", { b: 131, max: 3, dispOff: 1 }],
  ["arp/hold", { b: 132 }],
  ["arp/note/length", { b: 133, dispOff: -64 }],
  ["arp/swing", { b: 134, iso: VirusTIVoice.arpSwingIso }],
  ["lfo/2/rate", { b: 135 }],
  ["lfo/2/shape", { b: 136, max: 67, iso: VirusTIVoice.lfoShapeIso }],
  ["lfo/2/mode", { b: 137, opts: ["Poly", "Mono"] }],
  ["lfo/2/keyTrk", { b: 138 }],
  ["lfo/2/dest", { b: 139, opts: ["Osc 1 Pitch", "Osc 1+2 Pitch", "Osc 2 Pitch", "Osc 1 PW", "Osc 1+2 PW", "Osc 2 PW", "Sync Phase"] }],
  ["lfo/2/dest/amt", { b: 140 }],
  ["lfo/2/fade", { b: 141 }],
//    ["arp/mode", { b: 143, opts: ["Off", "Up", "Down", "Up&Down", "As Played", "Random", "Chord", "Arp>Matrix"] }],
  ["tempo", { b: 144, dispOff: 63 }],
  ["arp/clock", { b: 145, opts: arpResolutionOptions, startIndex: 1 }],
  ["lfo/0/clock", { b: 146, opts: VirusTIVoice.lfoClockOptions }],
  ["lfo/1/clock", { b: 147, opts: VirusTIVoice.lfoClockOptions }],
  ["delay/clock", { b: 148, opts: VirusTIVoice.delayClockOptions }],
  ["lfo/2/clock", { b: 149, opts: VirusTIVoice.lfoClockOptions }],
  ["param/smooth", { b: 153, opts: smoothOptions }],
  ["bend/up", { b: 154, dispOff: -64 }],
  ["bend/down", { b: 155, dispOff: -64 }],
  ["bend/scale", { b: 156, opts: ["Linear", "Expon"] }],
  ["filter/0/env/polarity", { b: 158, opts: ["Negative", "Positive"] }],
  ["filter/1/env/polarity", { b: 159, opts: ["Negative", "Positive"] }],
  ["filter/cutoff/link", { b: 160 }],
  ["filter/keyTrk/start", { b: 161, iso: Miso.noteName(zeroNote: "C-2") }],
  ["fm/mode", { b: 162, opts: ["Pos Tri", "Triangle", "Wave", "Noise", "In L", "In L+R", "In R", "Aux1 L", "Aux1 L+R", "Aux1 R", "Aux2 L", "Aux2 L+R", "Aux2 R", ] }],
  ["osc/innit/phase", { b: 163, iso: VirusTIVoice.noiseVolIso }],
  ["osc/pushIt", { b: 164 }],
  ["input/follow", { b: 166 }],
  ["vocoder/mode", { b: 167, opts: vocoderModes }],
  ["osc/2/mode", { b: 169, rng: [0, 67], iso: VirusTIVoice.osc2WaveIso }],
  ["osc/2/level", { b: 170 }],
  ["osc/2/semitone", { b: 171, rng: [16, 112], dispOff: -64 }],
  ["osc/2/fine", { b: 172, iso: Miso.switcher(`int(0/${0)}`, default: Miso.m(-1)) >>> Miso.str() }],
  ["eq/lo/freq", { b: 173, iso: VirusTIVoice.loFreqIso }],
  ["eq/hi/freq", { b: 174, iso: VirusTIVoice.hiFreqIso }],
  ["osc/0/shape/velo", { b: 175, dispOff: -64 }],
  ["osc/1/shape/velo", { b: 176, dispOff: -64 }],
  ["velo/pw", { b: 177, dispOff: -64 }],
  ["velo/fm", { b: 178, dispOff: -64 }],
  ["knob/0/name", { b: 179, opts: knobNames }],
  ["knob/1/name", { b: 180, opts: knobNames }],
  ["velo/filter/0/env", { b: 182, dispOff: -64 }],
  ["velo/filter/1/env", { b: 183, dispOff: -64 }],
  ["velo/filter/0/reson", { b: 184, dispOff: -64 }],
  ["velo/filter/1/reson", { b: 185, dispOff: -64 }],
  ["surround/balance", { b: 186 }],
  ["velo/volume", { b: 188, dispOff: -64 }],
  ["velo/pan", { b: 189, dispOff: -64 }],
  ["knob/0/dest", { b: 190, opts: knobOptions }],
  ["knob/1/dest", { b: 191, opts: knobOptions }],

  ["mod/0/src", { b: 192, opts: modSrcOptions }],
  ["mod/0/dest/0", { b: 193, opts: modDestOptions }],
  ["mod/0/amt/0", { b: 194, dispOff: -64 }],
  ["mod/1/src", { b: 195, opts: modSrcOptions }],
  ["mod/1/dest/0", { b: 196, opts: modDestOptions }],
  ["mod/1/amt/0", { b: 197, dispOff: -64 }],
  ["mod/1/dest/1", { b: 198, opts: modDestOptions }],
  ["mod/1/amt/1", { b: 199, dispOff: -64 }],
  ["mod/2/src", { b: 200, opts: modSrcOptions }],
  ["mod/2/dest/0", { b: 201, opts: modDestOptions }],
  ["mod/2/amt/0", { b: 202, dispOff: -64 }],
  ["mod/2/dest/1", { b: 203, opts: modDestOptions }],
  ["mod/2/amt/1", { b: 204, dispOff: -64 }],
  ["mod/2/dest/2", { b: 205, opts: modDestOptions }],
  ["mod/2/amt/2", { b: 206, dispOff: -64 }],

  ["lfo/0/dest", { b: 207, opts: modDestOptions }],
  ["lfo/0/dest/amt", { b: 208, dispOff: -64 }],
  ["lfo/1/dest", { b: 209, opts: modDestOptions }],
  ["lfo/1/dest/amt", { b: 210, dispOff: -64 }],
  ["phase/mode", { b: 212, max: 5, dispOff: 1 }],
  ["phase/mix", { b: 213, iso: VirusTIVoice.noiseVolIso }],
  ["phase/rate", { b: 214 }],
  ["phase/depth", { b: 215 }],
  ["phase/freq", { b: 216 }],
  ["phase/feedback", { b: 217, dispOff: -64 }],
  ["phase/pan", { b: 218 }],
  ["eq/mid/gain", { b: 220, iso: VirusTIVoice.eqGainIso }],
  ["eq/mid/freq", { b: 221, rng: [0, 126], iso: VirusTIVoice.midFreqIso }],
  ["eq/mid/q", { b: 222, iso: VirusTIVoice.midQIso }],
  ["eq/lo/gain", { b: 223, iso: VirusTIVoice.eqGainIso }],
  ["eq/hi/gain", { b: 224, iso: VirusTIVoice.eqGainIso }],
  ["character/amt", { b: 225, iso: VirusTIVoice.fullPercIsoWOff }],
  ["character/tune", { b: 226 }],
  ["ringMod/mix", { b: 227 }],
  ["dist/type", { b: 228, opts: distortModes }],
  ["dist/amt", { b: 229 }],
  ["mod/3/src", { b: 231, opts: modSrcOptions }],
  ["mod/3/dest/0", { b: 232, opts: modDestOptions }],
  ["mod/3/amt/0", { b: 233, dispOff: -64 }],
  ["mod/4/src", { b: 234, opts: modSrcOptions }],
  ["mod/4/dest/0", { b: 235, opts: modDestOptions }],
  ["mod/4/amt/0", { b: 236, dispOff: -64 }],
  ["mod/5/src", { b: 237, opts: modSrcOptions }],
  ["mod/5/dest/0", { b: 238, opts: modDestOptions }],
  ["mod/5/amt/0", { b: 239, dispOff: -64 }],
  ["filter/select", { b: 250, opts: ["Filter 1", "Filter 2", "Filter 1+2"] }],
  ["category/0", { b: 251, opts: categoryOptions }],
  ["category/1", { b: 252, opts: categoryOptions }],
]

func sysexData(deviceId: UInt8, bank: UInt8, part: UInt8) -> Data {
  var data = Data(VirusTI.sysexHeader)
  var b1 = [deviceId, 0x10, bank, part] // these are included in checksum
  b1.append(contentsOf: bytes)
  data.append(contentsOf: b1)
  
  let checksum = b1.map{ Int($0) }.reduce(0, +) & 0x7f
  data.append(UInt8(checksum))
  
  data.append(0xf7)
  return data
}

const patchTruss = {
  single: 'voice',
  parms: parms,
  initFile: "virusc-voice-init",
  parseBody: ['bytes', { start: 9, count: 256 }],
}

  // TODO
  func randomize() {
    let keys: [SynthPath] = [
      "osc/0/shape",
      "osc/0/pw",
      "osc/0/wave",
      "osc/1/shape",
      "osc/1/pw",
      "osc/1/wave",
      "osc/1/semitone",
      "osc/1/detune",
      "fm/amt",
      "osc/0/sync",
      "filter/env/pitch",
      "filter/env/fm",
      "osc/balance",
      "sub/level",
      "sub/shape",
//      "osc/level",
      "noise/level",
      "noise/color",
      "filter/0/cutoff",
      "filter/1/cutoff",
      "filter/reson",
      "filter/reson/extra",
      "filter/env/amt",
      "filter/env/extra",
      "filter/keyTrk",
      "filter/keyTrk/extra",
      "filter/balance",
      "saturation/type",
      "ringMod/level",
      "filter/0/mode",
      "filter/1/mode",
      "filter/routing",
      "filter/env/attack",
      "filter/env/decay",
      "filter/env/sustain",
      "filter/env/sustain/slop",
      "filter/env/release",
      "amp/env/attack",
      "amp/env/decay",
      "amp/env/sustain",
      "amp/env/sustain/slop",
      "amp/env/release",

      "lfo/0/rate",
      "lfo/0/shape",
      "lfo/0/env/mode",
      "lfo/0/mode",
      "lfo/0/curve",
      "lfo/0/keyTrk",
      "lfo/0/trigger",
      "lfo/0/osc",
      "lfo/0/osc/1",
      "lfo/0/pw",
      "lfo/0/filter/reson",
      "lfo/0/filter/env",
      "lfo/1/rate",
      "lfo/1/shape",
      "lfo/1/env/mode",
      "lfo/1/mode",
      "lfo/1/curve",
      "lfo/1/keyTrk",
      "lfo/1/trigger",
      "lfo/1/osc/shape",
      "lfo/1/fm",
      "lfo/1/cutoff",
      "lfo/1/cutoff/1",
      "lfo/1/pan",

      "osc/key/mode",

      "chorus/mix",
      "chorus/rate",
      "chorus/depth",
      "chorus/delay",
      "chorus/feedback",
      "chorus/shape",

      "delay/mode",
      "delay/send",
      "delay/time",
      "delay/feedback",
      "delay/rate",
      "delay/depth",
      "delay/shape",
      "delay/color",

      "lfo/2/rate",
      "lfo/2/shape",
      "lfo/2/mode",
      "lfo/2/keyTrk",
      "lfo/2/dest",
      "lfo/2/dest/amt",
      "lfo/2/fade",

      "tempo",

      "lfo/0/clock",
      "lfo/1/clock",
      "delay/clock",
      "lfo/2/clock",

      "filter/0/env/polarity",
      "filter/1/env/polarity",
      "filter/cutoff/link",
      "filter/keyTrk/start",
      "fm/mode",
      "osc/innit/phase",
      "osc/pushIt",

      "osc/2/mode",
      "osc/2/level",
      "osc/2/semitone",
      "osc/2/fine",
      "eq/lo/freq",
      "eq/hi/freq",
      "osc/0/shape/velo",
      "osc/1/shape/velo",
      "velo/pw",
      "velo/fm",

      "velo/filter/0/env",
      "velo/filter/1/env",
      "velo/filter/0/reson",
      "velo/filter/1/reson",

      "velo/volume",
      "velo/pan",

      "phase/mode",
      "phase/mix",
      "phase/rate",
      "phase/depth",
      "phase/freq",
      "phase/feedback",
      "phase/pan",
      "eq/mid/gain",
      "eq/mid/freq",
      "eq/mid/q",
      "eq/lo/gain",
      "eq/hi/gain",
      "character/amt",
      "character/tune",

      "dist/type",
      "dist/amt",

    ]
    keys.forEach {
      self[$0] = Self.param($0)?.randomize() ?? 0
    }

//    randomizeAllParams()
//    self["porta"] = 0
//    self["vocoder/mode"] = 0
//    self["volume"] = 127
//    self["osc/0/keyTrk"] = 96
//    self["osc/1/keyTrk"] = 96
//    self["arp/mode"] = 0
//    self["input/mode"] = 0
}


const bankTruss = {
  singleBank: patchTruss,
  patchCount: 128,
  initFile: "virusc-voice-bank-init",
}

class VirusCVoiceBank : TypicalTypedSysexPatchBank<VirusCVoicePatch>, VoiceBank {
  

  func sysexData(deviceId: UInt8, bank: UInt8) -> Data {
    return sysexData { $0.sysexData(deviceId: deviceId, bank: bank, part: UInt8($1)) }
  }
  
  override func fileData() -> Data {
    return sysexData(deviceId: 16, bank: 1)
  }
}

  
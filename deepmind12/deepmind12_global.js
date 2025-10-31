
const channelIso = Miso.switcher(`int(0/${"All")}`, default: Miso.str())
const sendChannelIso = Miso.switcher(`int(0/${"RxCh")}`, default: Miso.str())

const fixedVeloIso = Miso.switcher(`int(0/${"Off")}`, default: Miso.str())

const chainRangeIso = Miso.noteName(zeroNote: "C0")

const parms = [
  // 0, 1
  ["deviceId", { b: 2, max: 15, dispOff: 1 }],
  // 3
  ["midi/channel/rcv", { b: 4, max: 16, iso: channelIso }],
  ["midi/channel/send", { b: 5, max: 16, iso: sendChannelIso }],
  ["midi/pgm", { b: 6, opts: ["Rx", "Tx", "Rx-Tx", "None"] }],
  ["midi/ctrl", { b: 7, opts: ["Off", "CC", "NRPN"] }],
  ["midi/thru", { b: 8, max: 1 }], // SOFT THRU
  ["midi/usb/thru", { b: 9, max: 1 }],
  ["midi/wifi/thru", { b: 10, max: 1 }],
  // 11
  ["usb/channel/rcv", { b: 12, max: 16, iso: channelIso) // 02 0x56 (86 }],
  ["usb/channel/send", { b: 13, max: 16, iso: sendChannelIso) // 02 0x57 (87 }],
  ["usb/pgm", { b: 14, opts: ["Rx", "Tx", "Rx-Tx", "None"] }],
  ["usb/ctrl", { b: 15, opts: ["Off", "CC", "NRPN"] }],
  ["usb/midi/thru", { b: 16, max: 1 }],
  ["usb/wifi/thru", { b: 17, max: 1 }],
  // 18
  ["wifi/channel/rcv", { b: 19, max: 16, iso: channelIso }],
  ["wifi/channel/send", { b: 20, max: 16, iso: sendChannelIso }],
  ["wifi/pgm", { b: 21, opts: ["Rx", "Tx", "Rx-Tx", "None"] }],
  ["wifi/ctrl", { b: 22, opts: ["Off", "CC", "NRPN"] }],
  ["wifi/midi/thru", { b: 23, max: 1 }],
  ["wifi/usb/thru", { b: 24, max: 1 }],
  // 25
  ["local", { b: 26, max: 1 }],
  p["fixed/velo/on"]  = MisoParam.make(byte: 27, iso: fixedVeloIso)
  p["fixed/velo/off"]  = MisoParam.make(byte: 28, iso: fixedVeloIso)
  ["velo/curve", { b: 29, opts: ["Soft", "Med", "Hard"] }],
  ["aftertouch/curve", { b: 30, opts: ["Soft", "Med", "Hard"] }],
  ["tune", { b: 31, max: 255, dispOff: -128 }],
  ["pedal", { b: 32, opts: ["Foot", "Mod Wheel", "Breath", "Volume", "Expression", "Porta Time", "Aftertouch" ] }],
  ["sustain", { b: 33, opts: ["Norm-open", "Norm-closed", "Tap-N.O", "Tap-N.C", "Arp+Gate", "Arp-Gate", "Seq+Gate", "Seq-Gate", "Arp&Seq+Gate", "Arp&Seq-Gate"] }],
  ["panel/local", { b: 34, max: 1 }],
  ["fade/mode", { b: 35, opts: ["Pass-thru", "Jump"] }],
  p["brilliance"]  = MisoParam.make(byte: 36, maxVal: 9, iso: Miso.a(1) >>> Miso.m(10) >>> Miso.str())
  ["contrast", { b: 37, max: 10 }],
  // 38
  ["modWheel/light", { b: 39, opts: ["Off", "On", "Auto"] }],
  ["info", { b: 40, max: 1) // 0x02 0x72??? (114 }],
  ["cycle/pgm", { b: 41, max: 1 }],
  ["memory/panel", { b: 42, max: 1 }], // remember pages
  // 43, 44, 45
  ["sustain/mode", { b: 46, opts: ["Sustain", "Sostenuto"] }],
  // 47
  ["amp/mode", { b: 47, opts: ["Transparent", "Ballsy"] }],
  ["chain/poly", { b: 48, max: 1 }],
  ["chain/pgm/link", { b: 49, max: 1 }],
  ["chain/key/range", { b: 50, max: 1 }],
  p["chain/key/range/lo"]  = MisoParam.make(byte: 51, iso: chainRangeIso)
  p["chain/key/range/hi"]  = MisoParam.make(byte: 52, iso: chainRangeIso)
  ["key/transpose", { b: 53, max: 96, dispOff: -48 }],
  ["bend/mode", { b: 54, opts: ["All", "Held"] }],
]

const sysexData = [Deepmind12.sysexHeader, 0x06, 0x07, ['pack78' 'b', 64], 0xf7]

const patchTruss = {
  single: 'global',
  parms: parms,
  initFile: "deepmind12-global-init",
  parseBody: ['unpack87', { count: 56, range: [8, 71] }],
  createFile: sysexData,
}

const patchTransform = {
  throttle: 50,
  param: (path, parm, value) => {
    guard let param = type(of: patch).params[path] else { return nil }
    let channel = UInt8(self.channel)
    
    let msgs: [MidiMessage] = [
      .cc(channel: channel, number: 99, value: 0x02),
      .cc(channel: channel, number: 98, value: UInt8(param.byte + 44)),
      .cc(channel: channel, number: 6, value: UInt8(value >> 7)),
      .cc(channel: channel, number: 38, value: UInt8(value & 0x7f))
    ]
    
    return msgs.map { Data($0.bytes()) }
  },
  singlePatch: [[sysexData, 10]], 
}
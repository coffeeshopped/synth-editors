
class Deepmind12GlobalPatch : ByteBackedSysexPatch, GlobalPatch {

  static let initFileName = "deepmind12-global-init"
  static let fileDataCount = 73
    
  var bytes: [UInt8]
  
  required init(data: Data) {
    bytes = data.unpack87(count: 56, inRange: 8..<72)
  }
    
  func sysexData(channel: Int) -> Data {
    var data = Data(Deepmind12.sysexHeader(deviceId: UInt8(channel)) + [0x06, 0x07])
    data.append(Data.pack78(bytes: bytes, count: 64))
    data.append(0xf7)
    return data
  }
    
  func fileData() -> Data {
    return sysexData(channel: 0)
  }

  func randomize() {
    randomizeAllParams()
//
//    self[[.extra]] = 0
//    self[[.micro, .tune]] = 0
//    self[[.arp, .on]] = 0
  }

    
  static let params: SynthPathParam = {
    var p = SynthPathParam()
    
    // 0, 1
    p[[.deviceId]] = RangeParam(byte: 2, maxVal: 15, displayOffset: 1)
    // 3
    p[[.midi, .channel, .rcv]] = MisoParam.make(byte: 4, maxVal: 16, iso: channelIso)
    p[[.midi, .channel, .send]] = MisoParam.make(byte: 5, maxVal: 16, iso: sendChannelIso)
    p[[.midi, .pgm]]  = OptionsParam(byte: 6, options: ["Rx", "Tx", "Rx-Tx", "None"])
    p[[.midi, .ctrl]]  = OptionsParam(byte: 7, options: ["Off", "CC", "NRPN"])
    p[[.midi, .thru]]  = RangeParam(byte: 8, maxVal: 1) // SOFT THRU
    p[[.midi, .usb, .thru]]  = RangeParam(byte: 9, maxVal: 1)
    p[[.midi, .wifi, .thru]]  = RangeParam(byte: 10, maxVal: 1)
    // 11
    p[[.usb, .channel, .rcv]] = MisoParam.make(byte: 12, maxVal: 16, iso: channelIso) // 02 0x56 (86)
    p[[.usb, .channel, .send]] = MisoParam.make(byte: 13, maxVal: 16, iso: sendChannelIso) // 02 0x57 (87)
    p[[.usb, .pgm]]  = OptionsParam(byte: 14, options: ["Rx", "Tx", "Rx-Tx", "None"])
    p[[.usb, .ctrl]]  = OptionsParam(byte: 15, options: ["Off", "CC", "NRPN"])
    p[[.usb, .midi, .thru]]  = RangeParam(byte: 16, maxVal: 1)
    p[[.usb, .wifi, .thru]]  = RangeParam(byte: 17, maxVal: 1)
    // 18
    p[[.wifi, .channel, .rcv]] = MisoParam.make(byte: 19, maxVal: 16, iso: channelIso)
    p[[.wifi, .channel, .send]] = MisoParam.make(byte: 20, maxVal: 16, iso: sendChannelIso)
    p[[.wifi, .pgm]]  = OptionsParam(byte: 21, options: ["Rx", "Tx", "Rx-Tx", "None"])
    p[[.wifi, .ctrl]]  = OptionsParam(byte: 22, options: ["Off", "CC", "NRPN"])
    p[[.wifi, .midi, .thru]]  = RangeParam(byte: 23, maxVal: 1)
    p[[.wifi, .usb, .thru]]  = RangeParam(byte: 24, maxVal: 1)
    // 25
    p[[.local]]  = RangeParam(byte: 26, maxVal: 1)
    p[[.fixed, .velo, .on]]  = MisoParam.make(byte: 27, iso: fixedVeloIso)
    p[[.fixed, .velo, .off]]  = MisoParam.make(byte: 28, iso: fixedVeloIso)
    p[[.velo, .curve]]  = OptionsParam(byte: 29, options: ["Soft", "Med", "Hard"])
    p[[.aftertouch, .curve]]  = OptionsParam(byte: 30, options: ["Soft", "Med", "Hard"])
    p[[.tune]]  = RangeParam(byte: 31, maxVal: 255, displayOffset: -128)
    p[[.pedal]]  = OptionsParam(byte: 32, options: ["Foot", "Mod Wheel", "Breath", "Volume", "Expression", "Porta Time", "Aftertouch" ])
    p[[.sustain]]  = OptionsParam(byte: 33, options: ["Norm-open", "Norm-closed", "Tap-N.O", "Tap-N.C", "Arp+Gate", "Arp-Gate", "Seq+Gate", "Seq-Gate", "Arp&Seq+Gate", "Arp&Seq-Gate"])
    p[[.panel, .local]]  = RangeParam(byte: 34, maxVal: 1)
    p[[.fade, .mode]]  = OptionsParam(byte: 35, options: ["Pass-thru", "Jump"])
    p[[.brilliance]]  = MisoParam.make(byte: 36, maxVal: 9, iso: Miso.a(1) >>> Miso.m(10) >>> Miso.str())
    p[[.contrast]]  = RangeParam(byte: 37, maxVal: 10)
    // 38
    p[[.modWheel, .light]]  = OptionsParam(byte: 39, options: ["Off", "On", "Auto"])
    p[[.info]]  = RangeParam(byte: 40, maxVal: 1) // 0x02 0x72??? (114)
    p[[.cycle, .pgm]]  = RangeParam(byte: 41, maxVal: 1)
    p[[.memory, .panel]]  = RangeParam(byte: 42, maxVal: 1) // remember pages
    // 43, 44, 45
    p[[.sustain, .mode]]  = OptionsParam(byte: 46, options: ["Sustain", "Sostenuto"])
    // 47
    p[[.amp, .mode]]  = OptionsParam(byte: 47, options: ["Transparent", "Ballsy"])
    p[[.chain, .poly]]  = RangeParam(byte: 48, maxVal: 1)
    p[[.chain, .pgm, .link]]  = RangeParam(byte: 49, maxVal: 1)
    p[[.chain, .key, .range]]  = RangeParam(byte: 50, maxVal: 1)
    p[[.chain, .key, .range, .lo]]  = MisoParam.make(byte: 51, iso: chainRangeIso)
    p[[.chain, .key, .range, .hi]]  = MisoParam.make(byte: 52, iso: chainRangeIso)
    p[[.key, .transpose]]  = RangeParam(byte: 53, maxVal: 96, displayOffset: -48)
    p[[.bend, .mode]]  = OptionsParam(byte: 54, options: ["All", "Held"])

    return p
  }()
  
  static let channelIso = Miso.switcher([.int(0, "All")], default: Miso.str())
  static let sendChannelIso = Miso.switcher([.int(0, "RxCh")], default: Miso.str())

  static let fixedVeloIso = Miso.switcher([.int(0, "Off")], default: Miso.str())
  
  static let chainRangeIso = Miso.noteName(zeroNote: "C0")

  
}

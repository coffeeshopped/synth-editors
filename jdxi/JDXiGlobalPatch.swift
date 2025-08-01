
extension JDXi {
  
  enum Global {

    static let patchWerk = multiPatchWerk("Global", [
      ([.common], 0x0000, Common.patchWerk),
  //    ([.ctrl], 0x0300, CtrlrPatch.self),
    ], start: 0x02000000)

    // Fetch for the ControllerPatch doesn't work as of the latest firmware (1.52)
    // It just returns nothing.
    
    enum Common {
      static let patchWerk = singlePatchWerk("Global Common", parms.params(), size: 0x2b, start: 0x0000)

      static let parms: [Parm] = [
        .p([.tune], 0x00, packIso: JDXi.multiPack(0x00), .iso(tuneIso, 24...2024)),
        .p([.key, .shift], 0x04, .rng(40...88, dispOff: -64)),
        .p([.level], 0x05),
        .p([.pgmChange, .channel], 0x11, .opts(17.map { $0 == 16 ? "Off" : "\($0+1))" })),
        .p([.rcv, .pgmChange], 0x29, .max(1)),
        .p([.rcv, .bank, .select], 0x2a, .max(1)),
      ]
      
      static let tuneIso = Miso.a(-1024) >>> Miso.m(0.001 * (1/12)) >>> Miso.pow(base: 2) >>> Miso.m(440) >>> Miso.round(1)
    }
    
    enum Ctrlr {
      
      static let patchWerk = singlePatchWerk("Global Controller", params, size: 0x11, start: 0x0300)
      
      static let params: SynthPathParam = [
        [.send, .pgmChange] : RangeParam(byte: 0x00, maxVal: 1),
        [.send, .bank, .select] : RangeParam(byte: 0x01, maxVal: 1),
        [.velo] : OptionsParam(byte: 0x02, options: OptionsParam.makeOptions(128.map {
          $0 == 0 ? "Real" : "\($0)"
        })),
        [.velo, .curve] : OptionsParam(byte: 0x03, options: [
          1 : "Light",
          2 : "Medium",
          3 : "Heavy"
          ]),
        [.velo, .curve, .offset] : RangeParam(byte: 0x04, range: 54...73, displayOffset: -64),
      ]
    }
  }
  
}

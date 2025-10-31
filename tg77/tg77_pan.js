
class TG77PanPatch: TG77Patch, BankablePatch {
  
  static func location(forData data: Data) -> Int { return Int(data[31] & 0x1f) }
  
  const headerString: String = "LM  8101PN"
  const srcOptions = ["Velo","Note #","LFO"]
}

const parms = [
  ["src", { p: 0x0a00, parm2: 0x0000, b: 0, opts: srcOptions }],
  ["depth", { p: 0x0a00, parm2: 0x0001, b: 1, max: 99 }],
  ["hold/time", { p: 0x0a00, parm2: 0x0002, b: 2, max: 63 }],
  ["rate/0", { p: 0x0a00, parm2: 0x0003, b: 3, max: 63 }],
  ["rate/1", { p: 0x0a00, parm2: 0x0004, b: 4, max: 63 }],
  ["rate/2", { p: 0x0a00, parm2: 0x0005, b: 5, max: 63 }],
  ["rate/3", { p: 0x0a00, parm2: 0x0006, b: 6, max: 63 }],
  ["release/rate/0", { p: 0x0a00, parm2: 0x0007, b: 7, max: 63 }],
  ["release/rate/1", { p: 0x0a00, parm2: 0x0008, b: 8, max: 63 }],
  ["level/-1", { p: 0x0a00, parm2: 0x0009, b: 9, max: 63, dispOff: -32 }],
  ["level/0", { p: 0x0a00, parm2: 0x000a, b: 10, max: 63, dispOff: -32 }],
  ["level/1", { p: 0x0a00, parm2: 0x000b, b: 11, max: 63, dispOff: -32 }],
  ["level/2", { p: 0x0a00, parm2: 0x000c, b: 12, max: 63, dispOff: -32 }],
  ["level/3", { p: 0x0a00, parm2: 0x000d, b: 13, max: 63, dispOff: -32 }],
  ["release/level/0", { p: 0x0a00, parm2: 0x000e, b: 14, max: 63, dispOff: -32 }],
  ["release/level/1", { p: 0x0a00, parm2: 0x000f, b: 15, max: 63, dispOff: -32 }],
  ["loop/pt", { p: 0x0a00, parm2: 0x0010, b: 16, max: 3, dispOff: 1 }],
]

const patchTruss = {
  single: 'pan',
  parms: parms, 
  initFile: "tg77-pan-init",
  namePack: [17, 26],
  parseBody: ['bytes', { start: 32, count: 27 }],
}

  override func fileData() -> Data {
  return sysexData { $0.sysexData(channel: 0, location: $1) }
}

const emptyBankOptions = OptionsParam.makeOptions((1...32).map { "\($0)" })

const bankOptions = ["P1. Center", "P2. Right 6", "P3. Right 5", "P4. Right 4", "P5. Right 3", "P6. Right 2", "P7. Right 1", "P8. Left 6", "P9. Left 5", "P10. Left 4", "P11. Left 3", "P12. Left 2", "P13. Left 1", "P14. L>R slow", "P15. L>R", "P16. L>R fast", "P17. R>L slow", "P18. R>L", "P19. R>L fast", "P20. C>R slow", "P21. C>R", "P22. C>R fast", "P23. C->R slow", "P24. C->R", "P25. C->R fast", "P26. C>L slow", "P27. C>L", "P28. C>L fast", "P29. C->L slow", "P30. C->L", "P31. C->L fast", "P32. L<>R slow", "P33. L<>R", "P34. L<>R narrow", "P35. L<>R fast", "P36. R<>L slow", "P37. R<>L", "P38. R<>L narrow", "P39. R<>L fast", "P40. C>R<>L slw", "P41. C>R<>L s&n", "P42. C>R<>L", "P43. C>R<>L fst", "P44. C->R<>L sl", "P45. C->R<>L", "P46. C->R<>L fs", "P47. C>L<>R slw", "P48. C>L<>R s&n", "P49. C>L<>R", "P50. C>L<>R fst", "P51. C->L<>R sl", "P52. C->L<>R", "P53. C->L<>R fs", "P54. LFO MWheel", "P55. LFO wide", "P56. Note wide", "P57. Note narrw", "P58. Notew+EG n", "P59. Noten+EG w", "P60. Vel wide", "P61. Vel narrow", "P62. Vel w+EG n", "P63. R&L 1", "P64. R&L 2"]

const bankTruss = {
  singleBank: patchTruss,
  patchCount: 32,
  initFile: "tg77-pan-bank-init",
}

const patchTransform = ({
  throttle: 100,
  param: (path, parm, value) => {
    let parm = 0x0a00 + self.tempPan
    return [self.paramData(parm: parm, parm2: param.parm2, value: value)]
  },
  singlePatch: [[patch.sysexData(channel: self.deviceId, location: self.tempPan), 10]],
  name: { (patch, path, name) -> [Data]? in
    let parm = 0x0a00 + self.tempPan
    return name.bytes(forCount: 10).enumerated().map {
      self.paramData(parm: parm, parm2: Int($0.offset) + 0x11, value: Int($0.element))
      }
  },
})

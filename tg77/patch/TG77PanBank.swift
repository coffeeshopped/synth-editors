
class TG77PanBank : TypicalTypedSysexPatchBank<TG77PanPatch> {
  
  override class var patchCount: Int { return 32 }
  override class var initFileName: String { return "tg77-pan-bank-init" }
  
  override func fileData() -> Data {
    return sysexData { $0.sysexData(channel: 0, location: $1) }
  }
  
  static let emptyBankOptions = OptionsParam.makeOptions((1...32).map { "\($0)" })
  
  static let bankOptions = ["P1. Center", "P2. Right 6", "P3. Right 5", "P4. Right 4", "P5. Right 3", "P6. Right 2", "P7. Right 1", "P8. Left 6", "P9. Left 5", "P10. Left 4", "P11. Left 3", "P12. Left 2", "P13. Left 1", "P14. L>R slow", "P15. L>R", "P16. L>R fast", "P17. R>L slow", "P18. R>L", "P19. R>L fast", "P20. C>R slow", "P21. C>R", "P22. C>R fast", "P23. C->R slow", "P24. C->R", "P25. C->R fast", "P26. C>L slow", "P27. C>L", "P28. C>L fast", "P29. C->L slow", "P30. C->L", "P31. C->L fast", "P32. L<>R slow", "P33. L<>R", "P34. L<>R narrow", "P35. L<>R fast", "P36. R<>L slow", "P37. R<>L", "P38. R<>L narrow", "P39. R<>L fast", "P40. C>R<>L slw", "P41. C>R<>L s&n", "P42. C>R<>L", "P43. C>R<>L fst", "P44. C->R<>L sl", "P45. C->R<>L", "P46. C->R<>L fs", "P47. C>L<>R slw", "P48. C>L<>R s&n", "P49. C>L<>R", "P50. C>L<>R fst", "P51. C->L<>R sl", "P52. C->L<>R", "P53. C->L<>R fs", "P54. LFO MWheel", "P55. LFO wide", "P56. Note wide", "P57. Note narrw", "P58. Notew+EG n", "P59. Noten+EG w", "P60. Vel wide", "P61. Vel narrow", "P62. Vel w+EG n", "P63. R&L 1", "P64. R&L 2"]
}


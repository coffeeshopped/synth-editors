
//extension VolcaFM2 {
//
//  static let backupTruss = BackupTruss("Volca FM 2", map: [
//    ([.bank], Voice.bankTruss),
//    ([.perf, .bank], Sequence.bankTruss),
//  ], pathForData: {
//    guard $0.count > 6 else { return nil }
//    switch $0[6] {
//    case 0x4e:
//      return [.bank]
//    case 0x4c:
//      return [.perf, .bank]
//    default:
//      return nil
//    }
//  })
//  
//    
//}

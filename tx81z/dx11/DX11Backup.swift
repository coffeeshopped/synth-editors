
extension DX11 {
  
  static let backupTruss = BackupTruss("DX11", map: [
    ([.micro, .octave], Op4.Micro.Oct.werk.patchWerk.truss),
    ([.micro, .key], Op4.Micro.Full.werk.patchWerk.truss),
    ([.bank], Voice.bankTruss),
    ([.bank, .perf], Perf.bankTruss),
  ], pathForData: TX81Z.backupPathForData)

}

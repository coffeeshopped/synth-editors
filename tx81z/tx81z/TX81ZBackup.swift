
extension TX81Z {
  
  static let backupTruss = BackupTruss(synth.name, map: [
    ([.micro, .octave], Op4.Micro.Oct.werk.patchWerk.truss),
    ([.micro, .key], Op4.Micro.Full.werk.patchWerk.truss),
    ([.bank], Voice.bankTruss),
    ([.bank, .perf], Perf.bankTruss),
  ], pathForData: backupPathForData)
  
  static let backupPathForData: BackupTruss.PathForDataFn = {
    switch $0.count {
    case 42:
      return [.micro, .octave]
    case 274:
      return [.micro, .key]
    case 4104:
      return [.bank]
    case 2450:
      return [.bank, .perf]
    default:
      return nil
    }
  }

}

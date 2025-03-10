
extension JDXi {

  static let backupPaths: [SynthPath] = [[.global]]
    + mapItems(prefix: .perf, count: 2)
    + mapItems(prefix: .digital, count: 4)
    + mapItems(prefix: .analog, count: 2)
    + mapItems(prefix: .rhythm, count: 2)

  // 3110713: what got pulled during testing.
  // 3114553: old backup size
  static let backupTruss = Editor.werk.backupTruss(JDXi.sysexWerk, start: 0x0 /*Global.patchWerk.start*/,
                                                   paths: backupPaths, otherValidSizes: [3110713])  
  
  private static func mapItems(prefix: SynthPathItem, count: Int) -> [SynthPath] {
    count.map { [.bank, prefix, .i($0)] }
  }
  
}

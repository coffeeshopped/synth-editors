//
//  FS1RBackup.swift
//  Yamaha
//
//  Created by Chadwick Wood on 4/21/22.
//  Copyright © 2022 Coffeeshopped LLC. All rights reserved.
//

import Foundation
import PBAPI

extension FS1R {
  
  static let backupTruss = BackupTruss("FS1R", map: [
    ([.global], Global.patchTruss),
    ([.bank, .voice], Voice.Bank.bankTruss),
    ([.bank, .perf], Perf.Bank.bankTruss),
  ], pathForData: backupPathForData)

  static let backup64Truss = BackupTruss("FS1R", map: [
    ([.global], Global.patchTruss),
    ([.bank, .voice], Voice.Bank64.bankTruss),
    ([.bank, .perf], Perf.Bank.bankTruss),
    ([.bank, .fseq], Fseq.Bank.bankTruss),
  ], pathForData: backupPathForData)

  
  static let backupPathForData: BackupTruss.PathForDataFn = {
    guard $0.count > 6 else { return nil }
    switch $0[6] {
    case 0x00:
      return [.global]
    case 0x11:
      return [.bank, .perf]
    case 0x51:
      return [.bank, .voice]
    case 0x61:
      return [.bank, .fseq]
    default:
      return nil
    }
  }

}


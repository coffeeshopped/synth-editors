//
//  FS1RVoiceEditor.swift
//  Patch Base
//
//  Created by Chadwick Wood on 1/19/18.
//  Copyright © 2018 Coffeeshopped LLC. All rights reserved.
//

import Foundation
import RxSwift
import PBAPI
import YamahaCore

extension FS1R {
  
  enum Editor {
    
    static let truss: BasicEditorTruss = {
      var t = BasicEditorTruss("FS1R", truss: trussMap)
      
      t.fetchTransforms = [
        [.global] : patchFetch([0x00, 0x00, 0x00]),
        [.perf]: patchFetch([0x10, 0x00, 0x00]),
        [.fseq]: patchFetch([0x60, 0x00, 0x00]),
        [.bank, .voice]: bankFetch({[0x51, 0x00, $0] }),
        [.bank, .perf] : bankFetch({ [0x11, 0x00, $0] }),
        [.bank, .fseq] : bankFetch({ [0x61, 0x00, $0] }),
        [.bank, .voice, .extra]: bankFetch({[0x51, 0x00, $0] }),
      ]
      <<< 4.dict { [[.part, .i($0)] : patchFetch([0x40 + UInt8($0), 0x00, 0x00])] }
      t.compositeFetchWaitInterval = 10
      t.extraParamOuts = extraParamOuts
      t.midiOuts = [
        ([.global], Global.patchChangeTransform),
        ([.perf], Perf.patchChangeTransform),
        ([.fseq], Fseq.patchChangeTransform),
        ([.bank, .voice], Voice.bankChangeTransform),
        ([.bank, .perf], Perf.bankChangeTransform),
        ([.bank, .fseq], Fseq.bankChangeTransform),
        ([.bank, .voice, .extra], Voice.bankChangeTransform),
      ]
      + 4.map {
        ([.part, .i($0)], Voice.patchChangeTransform(part: $0))
      }

      let chMap: (Int) -> Int = { $0 > 15 ? 0 : $0 }
      t.midiChannels = 4.dict { p in
        [[.part, .i(p)] : .patch([.perf], [.part, .i(p), .channel], map: chMap)]
      }
      
      let banks = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K"]
      let userXform: MemSlot.Transform = .user({ "Int-\($0 + 1)" })
      t.slotTransforms = 11.dict { b in
        [[.preset, .voice, .i(b)] : .preset({ "Pr\(banks[b])-\($0)" }, names: Voice.ramBanks[b])]
      }
      <<< [
        [.preset, .fseq] : .preset({ "Pre-\($0)" }, names: Fseq.presets),
        [.bank, .voice] : userXform,
        [.bank, .perf] : userXform,
        [.bank, .fseq] : userXform,
        [.bank, .voice, .extra] : userXform,
      ]
      
      t.commandEffects = commandEffects
      t.pathTransforms = pathTransforms
      
      t.compositeSendWaitInterval = 300

      return t
    }()

    static let trussMap: [(SynthPath, any SysexTruss)] = [
      ([.global], Global.patchTruss),
      ([.perf], Perf.patchTruss),
      ([.fseq], Fseq.patchTruss),
      ([.bank, .voice], Voice.Bank.bankTruss),
      ([.bank, .perf], Perf.Bank.bankTruss),
      ([.bank, .fseq], Fseq.Bank.bankTruss),
      ([.bank, .voice, .extra], Voice.Bank64.bankTruss),
      ([.backup], backupTruss),
      ([.backup, .extra], backup64Truss),
      ([.extra, .perf], Perf.Full.refTruss),
    ]
    + 4.map { ([.part, .i($0)], Voice.patchTruss) }
        
    
    // MARK: MIDI I/O
    
    private static func fetch(_ deviceIdRaw: Int, _ address: [UInt8]) -> [UInt8] {
      Yamaha.fetchRequestBytes(channel: Int(deviceIdMap(deviceIdRaw)), cmdBytes: [0x5e] + address)
    }
    
    private static func patchFetch(_ address: [UInt8]) -> FetchTransform {
      .truss(deviceId, { fetch($0, address) })
    }

    private static func bankFetch(_ fn: @escaping (UInt8) -> [UInt8]) -> FetchTransform {
      .bankTruss(deviceId, { fetch($0, fn(UInt8($1))) })
    }
        
    // check system settings "memory" to map to which bank/backup format we're using

    private static func extra(_ path: SynthPath) -> (Int) -> SynthPath? {
      { path + ($0 == 0 ? [] : [.extra]) } // mem > 0 -> voice bank of 64 (no fseqs)
    }

    static let pathTransforms: [SynthPath:EditorPathTransform] = [
      [.backup] : .patchParam([.global], [.memory], extra([.backup])),
      [.bank, .voice] : .patchParam([.global], [.memory], extra([.bank, .voice])),
    ]
        
    static let extraParamOuts: [(path: SynthPath, transform: ParamOutTransform)] = [
      ([.perf], .bankNames([.bank, .voice], [.patch, .name])),
      ([.perf], .bankNames([.bank, .fseq], [.fseq, .name])),
    ] + 4.map { part in
      ([.part, .i(part)], .patchOut([.perf], { change, patch in
        var out = SynthPathParam()
        if let v = change.value([.part, .i(part), .filter, .on]) {
          out[[.filter, .on]] = .p([.filter, .on], p: v)
        }
        if let v = change.value([.fseq, .part]) {
          out[[.fseq, .on]] = .p([.fseq, .on], p: v == part + 1 ? 1 : 0)
        }
        return out
      }))
    }
    
    //  override func onSave(toBankPath bankPath: SynthPath, index: Int, fromPatchPath patchPath: SynthPath) {
    //    // side effect: if saving from a part editor, update the perf
    //    guard patchPath.first == .part else { return }
    //    let params: [SynthPath:Int] = [
    //      patchPath + [.bank] : 1, // Internal bank
    //      patchPath + [.pgm] : index
    //    ]
    //    changePatch(forPath: [.perf], .paramsChange(params), transmit: true)
    //  }
    
    static let commandEffects: [EditorCommandEffect] = 4.map { part in
      // if channel is changed, update channel max (as synth does)
      .patchParamChange([.perf], [.part, .i(part), .channel]) { value, transmit in
        let chanMax = value < 16 ? value : 0x7f
        return ([[.part, .i(part), .channel, .hi] : chanMax], false)
      }
    }
    + 4.map {
      // algo change sets level adjusts back to 0 on synth
      .patchParamChange([.part, .i($0)], [.algo]) { value, transmit in
        (.init(8.dict { [[.adjust, .op, .i($0), .level] : 0] }), false)
      }
    }
    
  }
  
  
}


//
//  FS1RGlobalPatch.swift
//  Patch Base
//
//  Created by Chadwick Wood on 6/12/18.
//  Copyright © 2018 Coffeeshopped LLC. All rights reserved.
//

import Foundation
import PBAPI

extension FS1R {
  
  enum Global {
    
    static func sysexData(_ bytes: [UInt8], deviceId: UInt8) -> MidiMessage {
      FS1R.sysexData(bytes, deviceId: deviceId, address: [0x00, 0x00, 0x00])
    }
    
    static let patchTruss = try! SinglePatchTruss("global", 76, params: params, createFileData: {
      sysexData($0, deviceId: 0).bytes()
    }, parseOffset: 9)
    
    static let patchChangeTransform: MidiTransform = .single(throttle: 100, deviceId, .patch(param: { editorVal, bodyData, path, value in
      guard let param = patchTruss.params[path] else { return nil }
      let deviceId = deviceIdMap(editorVal)
      return [(dataSetMsg(deviceId: deviceId, address: [0x00, 0x00, UInt8(param.byte)], value: value), 30)]
    }, patch: { editorVal, bodyData in
      [(sysexData(bodyData, deviceId: deviceIdMap(editorVal)), 100)]
    }, name: nil))
        
    static let params: SynthPathParam = {
      var p = SynthPathParam()
      
      p[[.detune]] = RangeParam(byte: 0x0, displayOffset: -64)
      p[[.note, .shift]] = RangeParam(byte: 0x06, displayOffset: -64)
      p[[.dump, .interval]] = OptionsParam(byte: 0x07, options: ["50","100","150","200","300"])
      p[[.pgmChange, .mode]] = OptionsParam(byte: 0x08, options: ["Performance","Multi"])
      p[[.perf, .channel]] = OptionsParam(byte: 0x09, options: {
        var opts = [Int:String]()
        (0..<16).forEach { opts[$0] = "\($0 + 1)" }
        opts[0x10] = "All"
        opts[0x7f] = "Off"
        return opts
      }())
      p[[.knob, .mode]] = OptionsParam(byte: 0x0b, options: ["Abs","Rel"])
      p[[.breath, .curve]] = OptionsParam(byte: 0x0d, options: ["Thru","1","2","3"])
      p[[.velo, .curve]] = OptionsParam(byte: 0x0e, options: ["thru", "sft1", "sft2", "wid", "hrd"])
      p[[.rcv, .sysex]] = RangeParam(byte: 0x10, maxVal: 1)
      p[[.rcv, .note]] = OptionsParam(byte: 0x11, options: ["All","Odd","Even"])
      p[[.rcv, .bank, .select]] = RangeParam(byte: 0x12, maxVal: 1)
      p[[.rcv, .pgmChange]] = RangeParam(byte: 0x13, maxVal: 1)
      p[[.rcv, .knob]] = RangeParam(byte: 0x14, maxVal: 1)
      p[[.send, .knob]] = RangeParam(byte: 0x15, maxVal: 1)
      (0..<4).forEach {
        p[[.knob, .ctrl, .i($0), .number]] = OptionsParam(byte: 0x16 + $0, options: ctrlOptions)
        p[[.midi, .ctrl, .i($0), .number]] = OptionsParam(byte: 0x1a + $0, options: ctrlOptions)
      }
      p[[.foot, .ctrl, .number]] = OptionsParam(byte: 0x1e, options: ctrlOptions)
      p[[.breath, .ctrl, .number]] = OptionsParam(byte: 0x1f, options: ctrlOptions)
      p[[.formant, .ctrl, .number]] = OptionsParam(byte: 0x20, options: ctrlOptions)
      p[[.fm, .ctrl, .number]] = OptionsParam(byte: 0x21, options: ctrlOptions)
      (0..<4).forEach {
        p[[.preview, .note, .i($0)]] = RangeParam(byte: 0x22 + 2*$0)
        p[[.preview, .velo, .i($0)]] = RangeParam(byte: 0x23 + 2*$0)
      }
      p[[.memory]] = OptionsParam(byte: 0x47, options: ["128 Voice", "64 Voice / 6 Fseq"])
      p[[.deviceId]] = RangeParam(byte: 0x49, maxVal: 15, displayOffset: 1)

      return p
    }()
    
    static let ctrlOptions: [Int:String] = {
      var opts = [Int:String]()
      (1...31).forEach { opts[$0] = "\($0)" }
      opts[32] = "Invalid"
      (33...95).forEach { opts[$0] = "\($0)" }
      return opts
    }()

  }
}

//
//  FS1RVoicePatch.swift
//  Patch Base
//
//  Created by Chadwick Wood on 12/21/17.
//  Copyright © 2017 Coffeeshopped LLC. All rights reserved.
//

import Foundation
import PBAPI

extension FS1R {
  
  enum Voice {

    static let patchTruss = try! SinglePatchTruss("voice", 608, namePackIso: .basic(0..<10), params: params, initFile: "fs1r-init", createFileData: {
      tempSysexData($0, deviceId: 0, part: 0).bytes()
    }, parseOffset: parseOffset)
        
    /// sysex bytes for patch as temp voice
    static func tempSysexData(_ bytes: [UInt8], deviceId: UInt8, part: Int) -> MidiMessage {
      FS1R.sysexData(bytes, deviceId: deviceId, address: [0x40 + UInt8(part), 0x00, 0x00])
    }

    /// sysex bytes for patch as stored in memory location
    static func sysexData(_ bytes: [UInt8], deviceId: UInt8, location: Int) -> MidiMessage {
      FS1R.sysexData(bytes, deviceId: deviceId, address: [0x51, 0x00, UInt8(location)])
    }

    enum Bank {
      
      static let validBundle = SingleBankTruss.Core.validBundle(counts: [79232, 39616])
      
      static let bankTruss = SingleBankTruss(patchTruss: patchTruss, patchCount: 128, createFileData: bankCreateFileData(sysexData), parseBodyData: bankParseBodyData(patchTruss: patchTruss, patchCount: 128), validBundle: validBundle)
    }

    // for a bank of only 64 voices (used when internal fseq storage is turned on)
    enum Bank64 {

      static let bankTruss = SingleBankTruss(patchTruss: patchTruss, patchCount: 64, createFileData: bankCreateFileData(sysexData), parseBodyData: bankParseBodyData(patchTruss: patchTruss, patchCount: 64), validBundle: Bank.validBundle)

    }


  //  func randomize() {
  //    randomizeAllParams()
  //
  //    // find the output ops and set level 4 to 0
  //    let algos = Self.algorithms()
  //    let algoIndex = self[[.algo]]!
  //
  //    let algo = algos[algoIndex]
  //
  //    self[[.lfo, .i(0), .pitch]] = (0...1).random()!
  //
  //    (0..<8).forEach { op in
  //      self[[.op, .i(op), .voiced, .amp, .env, .hold]] = 0
  //      self[[.op, .i(op), .unvoiced, .amp, .env, .hold]] = 0
  //
  //      self[[.adjust, .op, .i(op), .level]] = 0
  //    }
  //
  //    algo.outputOps.forEach { op in
  //
  //      self[[.op, .i(op), .voiced, .pitch, .mod, .sens]] = (0...1).random()!
  //
  //      self[[.op, .i(op), .voiced, .freq, .env, .innit]] = 50
  //      self[[.op, .i(op), .voiced, .freq, .env, .attack, .level]] = 50
  //
  //      self[[.op, .i(op), .voiced, .amp, .env, .level, .i(0)]] = 90 + (0...9).random()!
  //      self[[.op, .i(op), .voiced, .amp, .env, .time, .i(0)]] = (0...19).random()!
  //      self[[.op, .i(op), .voiced, .amp, .env, .level, .i(2)]] = 80+(0...19).random()!
  //      self[[.op, .i(op), .voiced, .amp, .env, .level, .i(3)]] = 0
  //      self[[.op, .i(op), .voiced, .amp, .env, .time, .i(3)]] = (0...69).random()!
  //
  //      self[[.op, .i(op), .voiced, .amp, .env, .level]] = 90+(0...9).random()!
  //
  //      self[[.op, .i(op), .unvoiced, .amp, .env, .level, .i(0)]] = 90 + (0...9).random()!
  //      self[[.op, .i(op), .unvoiced, .amp, .env, .time, .i(0)]] = (0...19).random()!
  //      self[[.op, .i(op), .unvoiced, .amp, .env, .level, .i(2)]] = 80+(0...19).random()!
  //      self[[.op, .i(op), .unvoiced, .amp, .env, .level, .i(3)]] = 0
  //      self[[.op, .i(op), .unvoiced, .amp, .env, .time, .i(3)]] = (0...69).random()!
  //
  //
  //      self[[.op, .i(op), .voiced, .level, .scale, .left, .depth]] = (0...9).random()!
  //      self[[.op, .i(op), .voiced, .level, .scale, .right, .depth]] = (0...9).random()!
  //    }
  //
  //    // for one out, make it harmonic and louder
  //    let randomOut = algo.outputOps[(0..<algo.outputOps.count).random()!]
  //    self[[.op, .i(randomOut), .voiced, .osc, .mode]] = 0
  //    self[[.op, .i(randomOut), .voiced, .coarse]] = 0
  //    self[[.op, .i(randomOut), .voiced, .fine]] = 1
  //
  //    // flat pitch env
  //    (-1...3).forEach { i in
  //      self[[.pitch, .env, .level, .i(i)]] = 50
  //    }
  //  }
  //
    
    static func algorithms() -> [DXAlgorithm] { Algorithms.all }
    
    
    static func patchChangeTransform(part: Int) -> MidiTransform {
      return .single(throttle: 30, deviceId, .patch(param: { editorVal, bodyData, path, value in
        guard let param = patchTruss.params[path] else { return nil }
        let deviceId = deviceIdMap(editorVal)
        
        // special check for fseq on/off for op, since that's a COMMON param...
        if !(path.count == 4 && path[3] == .fseq),
          let op = path[0] == .op ? path.i(1) : nil {
          return [(opParamData(deviceId, bodyData: bodyData, part: part, param: param, op: op), 30)]
        }
        else {
          // common params have param address stored in .byte
          return [(commonParamData(deviceId, bodyData: bodyData, part: part, paramAddress: param.byte), 30)]
        }
      }, patch: { editorVal, bodyData in
        [(tempSysexData(bodyData, deviceId: deviceIdMap(editorVal), part: part), 100)]
      }, name: { editorVal, bodyData, path, name in
        let deviceId = deviceIdMap(editorVal)
        return patchTruss.namePackIso?.byteRange.map {
          (commonParamData(deviceId, bodyData: bodyData, part: part, paramAddress: $0), 30)
        }
      }))
    }

    static func commonParamData(_ deviceId: UInt8, bodyData: [UInt8], part: Int, paramAddress: Int) -> MidiMessage {
      // instead of sending <value>, we send the byte from the bytes array, because some params share bytes with others
      dataSetMsg(deviceId: deviceId, address: [0x40 + UInt8(part), 0x00, UInt8(paramAddress)], value: Int(bodyData[paramAddress]))
    }
    
    static func opParamData(_ deviceId: UInt8, bodyData: [UInt8], part: Int, param: Param, op: Int) -> MidiMessage {
      // instead of sending <value>, we send the byte from the bytes array, because some params share bytes with others
      dataSetMsg(deviceId: deviceId, address: [0x60 + UInt8(part), UInt8(op), UInt8(param.parm)], value: Int(bodyData[param.byte]))
    }
    
    static let bankChangeTransform: MidiTransform = .single(throttle: 0, deviceId, .bank({
      [(sysexData($1, deviceId: deviceIdMap($0), location: $2), 100)]
    }))
    
    static func voicedFreq(oscMode: Int, spectralForm: Int, coarse: Int, fine: Int) -> Float {
      if oscMode == 0 && spectralForm < 7 {
        // ratio
        let c = (coarse == 0 ? 0.5 : Float(coarse))
        let f = (Float(fine) * c) / 100
        return c + f
      }
      else {
        // fixed
        return fixedFreq(coarse: coarse, fine: fine)
      }
    }
    
    static func fixedFreq(coarse: Int, fine: Int) -> Float {
      guard coarse > 0 else { return 0 }
      let c = min(coarse, 21)
      return 14088 / powf(2, 21-(Float(c)+(Float(fine)/128)))
    }
    
    static let params: SynthPathParam = {
      var p = SynthPathParam()
      
      p[[.category]] = OptionsParam(byte: 0x0e, options: categoryOptions)
      p[[.lfo, .i(0), .wave]] = OptionsParam(byte: 0x10, options: lfoWaveOptions)
      p[[.lfo, .i(0), .rate]] = RangeParam(byte: 0x11, maxVal: 99)
      p[[.lfo, .i(0), .delay]] = RangeParam(byte: 0x12, maxVal: 99)
      p[[.lfo, .i(0), .key, .sync]] = RangeParam(byte: 0x13, maxVal: 1)
      p[[.lfo, .i(0), .pitch]] = RangeParam(byte: 0x15, maxVal: 99)
      p[[.lfo, .i(0), .amp]] = RangeParam(byte: 0x16, maxVal: 99)
      p[[.lfo, .i(0), .freq]] = RangeParam(byte: 0x17, maxVal: 99)
      p[[.lfo, .i(1), .wave]] = OptionsParam(byte: 0x18, options: lfoWaveOptions)
      p[[.lfo, .i(1), .rate]] = RangeParam(byte: 0x19)
      p[[.lfo, .i(1), .phase]] = OptionsParam(byte: 0x1c, options: OptionsParam.makeOptions(["0","90","180","270"]))
      p[[.lfo, .i(1), .key, .sync]] = RangeParam(byte: 0x1d, maxVal: 1)
      p[[.note, .shift]] = RangeParam(byte: 0x1e, maxVal: 48, displayOffset: -24)
      let pEnv: SynthPath = [.pitch, .env]
      p[pEnv + [.level, .i(-1)]] = RangeParam(byte: 0x1f, maxVal: 100, displayOffset: -50)
      p[pEnv + [.level, .i(0)]] = RangeParam(byte: 0x20, maxVal: 100, displayOffset: -50)
      p[pEnv + [.level, .i(1)]] = RangeParam(byte: 0x21, maxVal: 100, displayOffset: -50)
      p[pEnv + [.level, .i(3)]] = RangeParam(byte: 0x22, maxVal: 100, displayOffset: -50)
      p[pEnv + [.time, .i(0)]] = RangeParam(byte: 0x23, maxVal: 99)
      p[pEnv + [.time, .i(1)]] = RangeParam(byte: 0x24, maxVal: 99)
      p[pEnv + [.time, .i(2)]] = RangeParam(byte: 0x25, maxVal: 99)
      p[pEnv + [.time, .i(3)]] = RangeParam(byte: 0x26, maxVal: 99)
      p[pEnv + [.velo]] = RangeParam(byte: 0x27, maxVal: 7)
      p[[.op, .i(7), .voiced, .fseq]] = RangeParam(byte: 0x28, bit: 0)
      p[[.op, .i(7), .unvoiced, .fseq]] = RangeParam(byte: 0x2a, bit: 0)
      for i in 0...6 {
        p[[.op, .i(i), .voiced, .fseq]] = RangeParam(byte: 0x29, bit: i)
        p[[.op, .i(i), .unvoiced, .fseq]] = RangeParam(byte: 0x2b, bit: i)
      }
      p[[.algo]] = RangeParam(byte: 0x2c, maxVal: 87, displayOffset: 1)
      let levelAdjustOptions = OptionsParam.makeOptions((0...15).map { "-\(Float($0)*1.5) dB" })
      for i in 0..<8 {
        p[[.adjust, .op, .i(i), .level]] = OptionsParam(byte: 0x2d + i, options: levelAdjustOptions)
      }
      p[pEnv + [.range]] = OptionsParam(byte: 0x3b, options: ["8oct","2oct","1oct","1/2oct"])
      p[pEnv + [.time, .scale]] = RangeParam(byte: 0x3c, maxVal: 7)
      p[[.feedback]] = RangeParam(byte: 0x3d, maxVal: 7)
      p[pEnv + [.level,.i(2)]] = RangeParam(byte: 0x3e, maxVal: 100, displayOffset: -50)
      for i in 0..<5 {
        p[[.formant, .ctrl, .i(i), .dest]] = OptionsParam(byte: 0x40+i, bits: 4...5, options: knobDestOptions)
        p[[.formant, .ctrl, .i(i), .unvoiced]] = OptionsParam(byte: 0x40+i, bit: 3, options: ["Voiced","Unvoiced"])
        p[[.formant, .ctrl, .i(i), .op]] = RangeParam(byte: 0x40+i, bits: 0...2, maxVal: 7, displayOffset: 1)
        p[[.formant, .ctrl, .i(i), .depth]] = RangeParam(byte: 0x45+i, displayOffset: -64)
        
        p[[.fm, .ctrl, .i(i), .dest]] = OptionsParam(byte: 0x4a+i, bits: 4...5, options: knobDestOptions)
        p[[.fm, .ctrl, .i(i), .unvoiced]] = OptionsParam(byte: 0x4a+i, bit: 3, options: ["Voiced","Unvoiced"])
        p[[.fm, .ctrl, .i(i), .op]] = RangeParam(byte: 0x4a+i, bits: 0...2, maxVal: 7, displayOffset: 1)
        p[[.fm, .ctrl, .i(i), .depth]] = RangeParam(byte: 0x4f+i, displayOffset: -64)
      }
      p[[.filter, .type]] = OptionsParam(byte: 0x54, options: ["LFP24","LPF18","LPF12","HPF","BPF","BEF"])
      p[[.reson]] = RangeParam(byte: 0x55)
      p[[.reson, .velo]] = RangeParam(byte: 0x56, maxVal: 14, displayOffset: -7)
      p[[.cutoff]] = RangeParam(byte: 0x57)
      let fEnv: SynthPath = [.filter, .env]
      p[fEnv + [.depth, .velo]] = RangeParam(byte: 0x58, maxVal: 14, displayOffset: -7)
      p[[.cutoff, .lfo, .i(0)]] = RangeParam(byte: 0x59, maxVal: 99)
      p[[.cutoff, .lfo, .i(1)]] = RangeParam(byte: 0x5a, maxVal: 99)
      p[[.cutoff, .key, .scale, .depth]] = RangeParam(byte: 0x5b, displayOffset: -64)
      p[[.cutoff, .key, .scale, .pt]] = RangeParam(byte: 0x5c)
      p[[.filter, .gain]] = RangeParam(byte: 0x5d, maxVal: 24, displayOffset: -12)
      p[fEnv + [.depth]] = RangeParam(byte: 0x64, displayOffset: -64)
      (0..<4).forEach {
        p[fEnv + [.level, .i($0)]] = RangeParam(byte: 0x66+$0, maxVal: 100, displayOffset: -50)
        p[fEnv + [.time, .i($0)]] = RangeParam(byte: 0x69+$0, maxVal: 99)
      }
      p[fEnv + [.attack, .velo]] = RangeParam(byte: 0x6e, bits: 0...2, maxVal: 7)
      p[fEnv + [.time, .scale]] = RangeParam(byte: 0x6e, bits: 3...5, maxVal: 7)
      
      for i in 0..<8 {
        let opV: SynthPath = [.op, .i(i), .voiced]
        p[opV + [.key, .sync]] = rng(op: i, parm: 0x00, bit: 6)
        p[opV + [.transpose]] = rng(op: i, parm: 0x00, bits: 0...5, maxVal: 48, displayOffset: -24)
        p[opV + [.coarse]] = rng(op: i, parm: 0x01, maxVal: 31)
        p[opV + [.fine]] = rng(op: i, parm: 0x02, maxVal: 99)
        p[opV + [.note, .scale]] = rng(op: i, parm: 0x03, maxVal: 99)
        p[opV + [.bw, .bias, .sens]] = rng(op: i, parm: 0x04, bits: 3...6, maxVal: 14, displayOffset: -7)
        p[opV + [.spectral, .form]] = opt(op: i, parm: 0x04, bits: 0...2, options: ["Sine", "All 1", "All 2", "Odd 1", "Odd 2", "Res 1", "Res 2", "Formant"])
        p[opV + [.osc, .mode]] = opt(op: i, parm: 0x05, bit: 6, options: ["Ratio","Fixed"])
        p[opV + [.spectral, .skirt]] = rng(op: i, parm: 0x05, bits: 3...5, maxVal: 7)
        p[opV + [.fseq, .trk]] = rng(op: i, parm: 0x05, bits: 0...2, maxVal: 7, displayOffset: 1)
        p[opV + [.freq, .ratio, .spectral]] = rng(op: i, parm: 0x06, maxVal: 99)
        p[opV + [.detune]] = rng(op: i, parm: 0x07, maxVal: 30, displayOffset: -15)
        let freqEnv: SynthPath = [.freq, .env]
        p[opV + freqEnv + [.innit]] = rng(op: i, parm: 0x08, maxVal: 100, displayOffset: -50)
        p[opV + freqEnv + [.attack, .level]] = rng(op: i, parm: 0x09, maxVal: 100, displayOffset: -50)
        p[opV + freqEnv + [.attack]] = rng(op: i, parm: 0x0a, maxVal: 99)
        p[opV + freqEnv + [.decay]] = rng(op: i, parm: 0x0b, maxVal: 99)
        let aEnv: SynthPath = [.amp, .env]
        (0..<4).forEach {
          p[opV + aEnv + [.level, .i($0)]] = rng(op: i, parm: 0x0c+$0, maxVal: 99)
          p[opV + aEnv + [.time, .i($0)]] = rng(op: i, parm: 0x10+$0, maxVal: 99)
        }
        p[opV + aEnv + [.hold]] = rng(op: i, parm: 0x14, maxVal: 99)
        p[opV + aEnv + [.time, .scale]] = rng(op: i, parm: 0x15, maxVal: 7)
        p[opV + aEnv + [.level]] = rng(op: i, parm: 0x16, maxVal: 99)
        p[opV + [.level, .scale, .brk, .pt]] = rng(op: i, parm: 0x17, maxVal: 99)
        p[opV + [.level, .scale, .left, .depth]] = rng(op: i, parm: 0x18, maxVal: 99)
        p[opV + [.level, .scale, .right, .depth]] = rng(op: i, parm: 0x19, maxVal: 99)
        let lsCurves = OptionsParam.makeOptions(["-lin","-exp","+exp","+lin"])
        p[opV + [.level, .scale, .left, .curve]] = opt(op: i, parm: 0x1a, options: lsCurves)
        p[opV + [.level, .scale, .right, .curve]] = opt(op: i, parm: 0x1b, options: lsCurves)
        p[opV + [.freq, .bias, .sens]] = rng(op: i, parm: 0x1f, bits: 3...6, maxVal: 14, displayOffset: -7)
        p[opV + [.pitch, .mod, .sens]] = rng(op: i, parm: 0x1f, bits: 0...2, maxVal: 7)
        p[opV + [.freq, .mod, .sens]] = rng(op: i, parm: 0x20, bits: 4...6, maxVal: 7)
        p[opV + [.freq, .velo]] = rng(op: i, parm: 0x20, bits: 0...3, maxVal: 14, displayOffset: -7)
        p[opV + [.amp, .env, .mod, .sens]] = rng(op: i, parm: 0x21, bits: 4...6, maxVal: 7)
        p[opV + [.amp, .env, .velo]] = rng(op: i, parm: 0x21, bits: 0...3, maxVal: 14, displayOffset: -7 )
        p[opV + [.amp, .env, .bias, .sens]] = rng(op: i, parm: 0x22, maxVal: 14, displayOffset: -7)
        
        let opN: SynthPath = [.op, .i(i), .unvoiced]
        p[opN + [.transpose]] = rng(op: i, parm: 0x23, maxVal: 48, displayOffset: -24)
        p[opN + [.mode]] = opt(op: i, parm: 0x24, bits: 5...6, options: ["Normal","Link FO", "Link FF"])
        p[opN + [.coarse]] = rng(op: i, parm: 0x24, bits: 0...4, maxVal: 31)
        p[opN + [.fine]] = rng(op: i, parm: 0x25, maxVal: 99)
        p[opN + [.note, .scale]] = rng(op: i, parm: 0x26, maxVal: 99)
        p[opN + [.bw]] = rng(op: i, parm: 0x27, maxVal: 99)
        p[opN + [.bw, .bias, .sens]] = rng(op: i, parm: 0x28, maxVal: 14, displayOffset: -7)
        p[opN + [.reson]] = rng(op: i, parm: 0x29, bits: 3...5, maxVal: 7)
        p[opN + [.skirt]] = rng(op: i, parm: 0x29, bits: 0...2, maxVal: 7)
        p[opN + freqEnv + [.innit]] = rng(op: i, parm: 0x2a, maxVal: 100, displayOffset: -50)
        p[opN + freqEnv + [.attack, .level]] = rng(op: i, parm: 0x2b, maxVal: 100, displayOffset: -50)
        p[opN + freqEnv + [.attack]] = rng(op: i, parm: 0x2c, maxVal: 99)
        p[opN + freqEnv + [.decay]] = rng(op: i, parm: 0x2d, maxVal: 99)
        p[opN + [.amp, .env, .level]] = rng(op: i, parm: 0x2e, maxVal: 99)
        p[opN + [.level, .key, .scale]] = rng(op: i, parm: 0x2f, maxVal: 14, displayOffset: -7)
        (0..<4).forEach {
          p[opN + aEnv + [.level, .i($0)]] = rng(op: i, parm: 0x30+$0, maxVal: 99)
          p[opN + aEnv + [.time, .i($0)]] = rng(op: i, parm: 0x34+$0, maxVal: 99)
        }
        p[opN + aEnv + [.hold]] = rng(op: i, parm: 0x38, maxVal: 99)
        p[opN + aEnv + [.time, .scale]] = rng(op: i, parm: 0x39, maxVal: 7)
        p[opN + [.freq, .bias, .sens]] = rng(op: i, parm: 0x3a, maxVal: 14, displayOffset: -7)
        p[opN + [.freq, .mod, .sens]] = rng(op: i, parm: 0x3b, bits: 4...6, maxVal: 7)
        p[opN + [.freq, .velo]] = rng(op: i, parm: 0x3b, bits: 0...3, maxVal: 14, displayOffset: -7)
        p[opN + [.amp, .env, .mod, .sens]] = rng(op: i, parm: 0x3c, bits: 4...6, maxVal: 7)
        p[opN + [.amp, .env, .velo]] = rng(op: i, parm: 0x3c, bits: 0...3, maxVal: 14, displayOffset: -7)
        p[opN + [.amp, .env, .bias, .sens]] = rng(op: i, parm: 0x3d, maxVal: 14, displayOffset: -7)
      }
      
      return p
    }()
    
    private static func rng(op: Int, parm p: Int = 0, bits bts: ClosedRange<Int>? = nil, range r: ClosedRange<Int> = 0...127, displayOffset off: Int = 0) -> RangeParam {
      let boff = 0x70 + op * 62
      return RangeParam(parm: p, byte: p + boff, bits: bts, range: r, displayOffset: off)
    }

    private static func rng(op: Int, parm p: Int = 0, bits bts: ClosedRange<Int>? = nil, maxVal: Int, displayOffset off: Int = 0) -> RangeParam {
      let boff = 0x70 + op * 62
      return RangeParam(parm: p, byte: p + boff, bits: bts, maxVal: maxVal, displayOffset: off)
    }
    
    private static func rng(op: Int, parm p: Int = 0, bit bt: Int) -> RangeParam {
      let boff = 0x70 + op * 62
      return RangeParam(parm: p, byte: p + boff, bit: bt)
    }

    private static func opt(op: Int, parm p: Int = 0, bits bts: ClosedRange<Int>? = nil, options opts: [Int:String]) -> OptionsParam {
      let boff = 0x70 + op * 62
      return OptionsParam(parm: p, byte: p + boff, bits: bts, options: opts)
    }

    private static func opt(op: Int, parm p: Int = 0, bit bt: Int, options opts: [Int:String]) -> OptionsParam {
      let boff = 0x70 + op * 62
      return OptionsParam(parm: p, byte: p + boff, bit: bt, options: opts)
    }

    static let categoryOptions = OptionsParam.makeOptions([
      "None",
      "Pf - Piano",
      "Cp - Chromatic Percussion",
      "Or - Organ",
      "Gt - Guitar",
      "Ba - Bass",
      "St - Strings/Orchestral",
      "En - Ensemble",
      "Br - Brass",
      "Rd - Reed",
      "Pi - Pipe",
      "Ld - Synth Lead",
      "Pd - Synth Pad",
      "Fx - Synth Sound Effects",
      "Et - Ethnic",
      "Pc - Percussive",
      "Se - Sound Effects",
      "Dr - Drums",
      "Sc - Synth Comping",
      "Vo - Vocal",
      "Co - Combination",
      "Wv - Material Wave",
      "Sq - Sequence",
      ])
    static let lfoWaveOptions = OptionsParam.makeOptions(["Triangle", "Saw Down", "Saw Up", "Square", "Sine", "S&H"])

    static let knobDestOptions = OptionsParam.makeOptions(["Off","Out","Freq","Width"])

  }
  
}


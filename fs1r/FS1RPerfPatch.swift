//
//  FS1RPerfPatch.swift
//  Patch Base
//
//  Created by Chadwick Wood on 6/13/18.
//  Copyright © 2018 Coffeeshopped LLC. All rights reserved.
//

import Foundation
import PBAPI
import YamahaCore

extension FS1R {
  
  enum Perf {

    static let patchTruss = try! SinglePatchTruss("perf", 400, namePackIso: .basic(0..<0x0c), params: params, initFile: "fs1r-perf-init", createFileData: { sysexData($0, deviceId: 0).bytes() }, parseOffset: parseOffset)

    /// sysex bytes for patch as temp perf
    static func sysexData(_ bytes: [UInt8], deviceId: UInt8) -> MidiMessage {
      FS1R.sysexData(bytes, deviceId: deviceId, address: [0x10, 0x00, 0x00])
    }
    
    /// sysex bytes for patch as stored in memory location
    static func sysexData(_ bytes: [UInt8], deviceId: UInt8, location: Int) -> MidiMessage {
      FS1R.sysexData(bytes, deviceId: deviceId, address: [0x11, 0x00, UInt8(location)])
    }
    
    enum Bank {
      static let bankTruss = SingleBankTruss(patchTruss: patchTruss, patchCount: 128, createFileData: bankCreateFileData(sysexData), parseBodyData: bankParseBodyData(patchTruss: patchTruss, patchCount: 128))
    }

    
    
    enum Full {

      static let refTruss: FullRefTruss = {

        let refPath: SynthPath = [.perf]
        let sections: [(String, [SynthPath])] = [
          ("Performance", [[.perf]]),
          ("Parts", 4.map { [.part, .i($0)] }),
          ("Fseq", [[.fseq]]),
        ]

        let createFileData: FullRefTruss.Core.ToMidiFn = { bodyData in
          // map over the types to ensure ordering of data
          try trussMap.compactMap {
            guard case .single(let d) = bodyData[$0.0] else { return nil }
            switch $0.1.displayId {
            case Voice.patchTruss.displayId:
              return Voice.tempSysexData(d, deviceId: 0, part: $0.0.endex).bytes()
            default:
              return try $0.1.createFileData(anyBodyData: .single(d))
            }
          }.reduce([], +)
        }

        let isos: FullRefTruss.Isos = [
          [.fseq] : .basic(path: [.fseq, .bank], location: [.fseq, .number], pathMap: [
            [.bank, .fseq], [.preset, .fseq],
          ])
        ]
        <<< 4.dict {
          let part: SynthPath = [.part, .i($0)]
          return [part : .basic(path: part + [.bank], location: part + [.pgm], pathMap: [
            [], [.bank, .voice],
          ] + 11.map { [.preset, .voice, .i($0)] })]
        }

        return FullRefTruss("perf.full", trussMap: trussMap, refPath: refPath, isos: isos, sections: sections, initFile: "fs1r-full-perf-init", createFileData: createFileData, pathForData: path(forData:))
      }()

      static let trussMap: [(SynthPath, any SysexTruss)] = [
        ([.perf], Perf.patchTruss),
      ] + 4.map { ([.part, .i($0)], Voice.patchTruss)} + [
        ([.fseq], Fseq.patchTruss)
      ]

      static func path(forData data: [UInt8]) -> SynthPath? {
        guard data.count > 6 else { return nil }
        switch data[6] {
        case 0x10:
          return [.perf]
        case 0x40...0x43:
          return [.part, .i(Int(data[6]) - 0x40)]
        case 0x60:
          return [.fseq]
        default:
          return nil
        }
      }

    }

    
    static let patchChangeTransform: MidiTransform = .single(throttle: 30, deviceId, .patch(param: { editorVal, bodyData, path, value in
      guard let param = patchTruss.params[path] else { return nil }
      let deviceId = deviceIdMap(editorVal)
      
      if let part = path[0] == .part ? path.i(1) : nil {
        return [(partParamData(deviceId, bodyData: bodyData, part: part, param: param), 30)]
      }
      else {
        // common params have param address stored in .byte
        var byte = param.byte
        var byteCount = param.packIso != nil ? 2 : 1
        if (0x30..<0x40).contains(byte) {
          // special treatment for src bits
          byte = byte - (byte % 2)
          byteCount = 2
        }
        return [(commonParamData(deviceId, bodyData: bodyData, paramAddress: byte, byteCount: byteCount), 30)]
      }
    }, patch: { editorVal, bodyData in
      [(sysexData(bodyData, deviceId: deviceIdMap(editorVal)), 100)]
    }, name: { editorVal, bodyData, path, name in
      let deviceId = deviceIdMap(editorVal)
      return patchTruss.namePackIso?.byteRange.map {
        (commonParamData(deviceId, bodyData: bodyData, paramAddress: $0, byteCount: 1), 30)
      }
    }))
    
    // instead of sending <value>, we send the byte from the bytes array, because some params share bytes with others
    static func commonParamData(_ deviceId: UInt8, bodyData: [UInt8], paramAddress: Int, byteCount: Int) -> MidiMessage {
      let v = byteCount == 1 ? Int(bodyData[paramAddress]) : (Int(bodyData[paramAddress]) << 7) + Int(bodyData[paramAddress + 1])
      let paramBytes = RolandAddress(intValue: paramAddress).sysexBytes(count: 2)
      return dataSetMsg(deviceId: deviceId, address: [0x10] + paramBytes, value: v)
    }
    
    static func partParamData(_ deviceId: UInt8, bodyData: [UInt8], part: Int, param: Param) -> MidiMessage {
      let v = Int(bodyData[param.byte])
      return dataSetMsg(deviceId: deviceId, address: [0x30 + UInt8(part), 0x00, UInt8(param.parm)], value: v)
    }
    
    static let bankChangeTransform: MidiTransform = .single(throttle: 0, deviceId, .bank({ 
      [(sysexData($1, deviceId: deviceIdMap($0), location: $2), 100)]
    }))

    
    
    static let params: SynthPathParam = {
      var p = SynthPathParam()
      
      p[[.category]] = OptionsParam(byte: 0x0e, options: Voice.categoryOptions)
      p[[.volume]] = RangeParam(byte: 0x10)
      p[[.pan]] = RangeParam(byte: 0x11, range: 1...127, displayOffset: -64)
      p[[.note, .shift]] = RangeParam(byte: 0x12, range: 0...48, displayOffset: -24)
      p[[.part, .out]] = OptionsParam(byte: 0x14, options: ["Off","Pre Ins","Post Ins"])
      p[[.fseq, .part]] = OptionsParam(byte: 0x15, options: ["Off","1","2","3","4"])
      p[[.fseq, .bank]] = OptionsParam(byte: 0x16, options: ["Int","Pre"])
      p[[.fseq, .number]] = RangeParam(byte: 0x17, maxVal: 89, displayOffset: 1)
      p[[.fseq, .speed]] = OptionsParam(byte: 0x18, options: fseqSpeedOptions, packIso: multiPack(0x18))
      p[[.fseq, .start]] = RangeParam(byte: 0x1a, packIso: multiPack(0x1a))
      p[[.fseq, .loop, .start]] = RangeParam(byte: 0x1c, packIso: multiPack(0x1c))
      p[[.fseq, .loop, .end]] = RangeParam(byte: 0x1e, packIso: multiPack(0x1e))
      p[[.fseq, .loop]] = OptionsParam(byte: 0x20, options: ["1-way","Round"])
      p[[.fseq, .mode]] = OptionsParam(byte: 0x21, options: [1 : "Scratch",2 : "Fseq"])
      p[[.fseq, .speed, .velo]] = RangeParam(byte: 0x22, maxVal: 7)
      p[[.fseq, .formant, .pitch]] = OptionsParam(byte: 0x23, options: ["Fseq","Fixed"])
      p[[.fseq, .trigger]] = OptionsParam(byte: 0x24, options: ["First","All"])
      p[[.fseq, .formant, .seq, .delay]] = RangeParam(byte: 0x26, maxVal: 99)
      p[[.fseq, .level, .velo]] = RangeParam(byte: 0x27, displayOffset: -64)
      
      for ctrl in 0..<8 {
        for part in 0..<4 {
          p[[.ctrl, .i(ctrl), .part, .i(part)]] = RangeParam(byte: 0x28+ctrl, bit: part)
        }

        let srcs: [SynthPath] = [
          [.knob, .i(0)],
          [.knob, .i(1)],
          [.knob, .i(2)],
          [.knob, .i(3)],
          [.midi, .ctrl, .i(0)],
          [.midi, .ctrl, .i(1)],
          [.bend],
          
          [.channel, .aftertouch],
          [.poly, .aftertouch],
          [.foot],
          [.breath],
          [.midi, .ctrl, .i(2)],
          [.modWheel],
          [.midi, .ctrl, .i(3)],
          ]
        
        for src in srcs.enumerated() {
          let byte = 0x30 + (2 * ctrl) + (src.0 < 7 ? 1 : 0)
          p[[.ctrl, .i(ctrl)] + src.1] = RangeParam(byte: byte, bit: src.0 % 7)
        }

        p[[.ctrl, .i(ctrl), .dest]] = OptionsParam(byte: 0x40 + ctrl, options: destOptions)
        p[[.ctrl, .i(ctrl), .depth]] = RangeParam(byte: 0x48 + ctrl, displayOffset: -64)
      }
      
      (0..<8).forEach { p[[.reverb, .i($0)]] = RangeParam(byte: 0x50 + 2 * $0, packIso: multiPack(0x50 + 2 * $0)) }
      (8..<16).forEach { p[[.reverb, .i($0)]] = RangeParam(byte: 0x60 + $0 - 8) }
      
      (0..<16).forEach {
        p[[.vary, .i($0)]] = RangeParam(parm: 2, byte: 0x68 + 2*$0)
        p[[.insert, .i($0)]] = RangeParam(parm: 2, byte: addr(0x108) + 2*$0)
      }
      
      p[[.reverb, .type]] = OptionsParam(byte: addr(0x128), options: reverbOptions)
      p[[.reverb, .pan]] = RangeParam(byte: addr(0x129), range: 1...127, displayOffset: -64)
      p[[.reverb, .level]] = RangeParam(byte: addr(0x12a))
      p[[.vary, .type]] = OptionsParam(byte: addr(0x12b), options: varyOptions)
      p[[.vary, .pan]] = RangeParam(byte: addr(0x12c), range: 1...127, displayOffset: -64)
      p[[.vary, .level]] = RangeParam(byte: addr(0x12d))
      p[[.vary, .reverb]] = RangeParam(byte: addr(0x12e))
      p[[.insert, .type]] = OptionsParam(byte: addr(0x12f), options: insertOptions)
      p[[.insert, .pan]] = RangeParam(byte: addr(0x130), range: 1...127, displayOffset: -64)
      p[[.insert, .reverb]] = RangeParam(byte: addr(0x131))
      p[[.insert, .vary]] = RangeParam(byte: addr(0x132))
      p[[.insert, .level]] = RangeParam(byte: addr(0x133))
      
      p[[.lo, .gain]] = RangeParam(byte: addr(0x134), range: 52...76, displayOffset: -64)
      p[[.lo, .freq]] = OptionsParam(byte: addr(0x135), options: optionsDict(4...40, cutoffOptions))
      p[[.lo, .q]] = OptionsParam(byte: addr(0x136), options: eqQOptions)
      p[[.lo, .shape]] = OptionsParam(byte: addr(0x137), options: eqShapeOptions)
      p[[.mid, .gain]] = RangeParam(byte: addr(0x138), range: 52...76, displayOffset: -64)
      p[[.mid, .freq]] = OptionsParam(byte: addr(0x139), options: optionsDict(14...54, cutoffOptions))
      p[[.mid, .q]] = OptionsParam(byte: addr(0x13a), options: eqQOptions)
      p[[.hi, .gain]] = RangeParam(byte: addr(0x13b), range: 52...76, displayOffset: -64)
      p[[.hi, .freq]] = OptionsParam(byte: addr(0x13c), options: optionsDict(28...58, cutoffOptions))
      p[[.hi, .q]] = OptionsParam(byte: addr(0x13d), options: eqQOptions)
      p[[.hi, .shape]] = OptionsParam(byte: addr(0x13e), options: eqShapeOptions)
      
      for part in 0..<4 {
        let pre: SynthPath = [.part, .i(part)]
        p[pre + [.note, .reserve]] = range(part, parm: 0x0)
        p[pre + [.bank]] = options(part, parm: 0x01, options: bankOptions)
        p[pre + [.pgm]] = range(part, parm: 0x02)
        p[pre + [.channel, .hi]] = options(part, parm: 0x03, options: channelMaxOptions)
        p[pre + [.channel]] = options(part, parm: 0x04, options: channelOptions)
        p[pre + [.poly]] = options(part, parm: 0x05, options: ["Mono","Poly"])
        p[pre + [.mono, .priority]] = options(part, parm: 0x06, options: ["Last","Top","Bottom","First"])
        p[pre + [.filter, .on]] = range(part, parm: 0x07, maxVal: 1)
        p[pre + [.note, .shift]] = range(part, parm: 0x08, maxVal: 48, displayOffset: -24)
        p[pre + [.detune]] = range(part, parm: 0x09, displayOffset: -64)
        p[pre + [.voiced, .unvoiced]] = range(part, parm: 0x0a, displayOffset: -64)
        p[pre + [.volume]] = range(part, parm: 0x0b)
        p[pre + [.velo, .depth]] = range(part, parm: 0x0c)
        p[pre + [.velo, .offset]] = range(part, parm: 0x0d)
        p[pre + [.pan]] = options(part, parm: 0x0e, options: panOptions)
        p[pre + [.note, .lo]] = range(part, parm: 0x0f)
        p[pre + [.note, .hi]] = range(part, parm: 0x10)
        p[pre + [.level]] = range(part, parm: 0x11)
        p[pre + [.vary]] = range(part, parm: 0x12)
        p[pre + [.reverb]] = range(part, parm: 0x13)
        p[pre + [.insert]] = range(part, parm: 0x14)
        p[pre + [.lfo, .i(0), .rate]] = range(part, parm: 0x15, displayOffset: -64)
        p[pre + [.lfo, .i(0), .pitch, .mod]] = range(part, parm: 0x16, displayOffset: -64)
        p[pre + [.lfo, .i(0), .delay]] = range(part, parm: 0x17, displayOffset: -64)
        p[pre + [.cutoff]] = range(part, parm: 0x18, displayOffset: -64)
        p[pre + [.reson]] = range(part, parm: 0x19, displayOffset: -64)
        p[pre + [.env, .attack]] = range(part, parm: 0x1a, displayOffset: -64)
        p[pre + [.env, .decay]] = range(part, parm: 0x1b, displayOffset: -64)
        p[pre + [.env, .release]] = range(part, parm: 0x1c, displayOffset: -64)
        p[pre + [.formant]] = range(part, parm: 0x1d, displayOffset: -64)
        p[pre + [.fm]] = range(part, parm: 0x1e, displayOffset: -64)
        p[pre + [.filter, .env, .depth]] = range(part, parm: 0x1f, displayOffset: -64)
        p[pre + [.pitch, .env, .innit]] = range(part, parm: 0x20, displayOffset: -64)
        p[pre + [.pitch, .env, .attack]] = range(part, parm: 0x21, displayOffset: -64)
        p[pre + [.pitch, .env, .release, .level]] = range(part, parm: 0x22, displayOffset: -64)
        p[pre + [.pitch, .env, .release, .time]] = range(part, parm: 0x23, displayOffset: -64)
        p[pre + [.porta]] = options(part, parm: 0x24, options: [0:"Off",1:"Fingered",3:"Fulltime"])
        p[pre + [.porta, .time]] = range(part, parm: 0x25)
        p[pre + [.bend, .hi]] = range(part, parm: 0x26, range: 0x10...0x58, displayOffset: -64)
        p[pre + [.bend, .lo]] = range(part, parm: 0x27, range: 0x10...0x58, displayOffset: -64)
        p[pre + [.pan, .scale]] = range(part, parm: 0x028, maxVal: 100, displayOffset: -50)
        p[pre + [.pan, .lfo, .depth]] = range(part, parm: 0x29, maxVal: 99)
        p[pre + [.velo, .lo]] = range(part, parm: 0x2a, range: 1...127)
        p[pre + [.velo, .hi]] = range(part, parm: 0x2b, range: 1...127)
        p[pre + [.pedal, .lo]] = range(part, parm: 0x2c)
        p[pre + [.sustain, .rcv]] = range(part, parm: 0x2d, maxVal: 1)
        p[pre + [.lfo, .i(1), .rate]] = range(part, parm: 0x2e, displayOffset: -64)
        p[pre + [.lfo, .i(1), .depth]] = range(part, parm: 0x2f, displayOffset: -64)
      }
      
      return p
    }()
        
    private static func multiPack(_ byte: Int) -> PackIso {
      PackIso.splitter([
        (byte: byte, byteBits: nil, valueBits: 7...13),
        (byte: byte + 1, byteBits: nil, valueBits: 0...6),
      ])
    }
        
    private static func addr(_ i: Int) -> Int { RolandAddress(i).intValue() }
    
    private static func range(_ part: Int, parm p: Int = 0, bits bts: ClosedRange<Int>? = nil, range r: ClosedRange<Int> = 0...127, displayOffset off: Int = 0) -> RangeParam {
      let boff = RolandAddress(0x140).intValue() + part * 52
      return RangeParam(parm: p, byte: p + boff, bits: bts, range: r, displayOffset: off)
    }
    
    private static func range(_ part: Int, parm p: Int = 0, bits bts: ClosedRange<Int>? = nil, maxVal: Int, displayOffset off: Int = 0) -> RangeParam {
      let boff = RolandAddress(0x140).intValue() + part * 52
      return RangeParam(parm: p, byte: p + boff, bits: bts, maxVal: maxVal, displayOffset: off)
    }
    
    private static func range(_ part: Int, parm p: Int = 0, bit bt: Int) -> RangeParam {
      let boff = RolandAddress(0x140).intValue() + part * 52
      return RangeParam(parm: p, byte: p + boff, bit: bt)
    }
    
    private static func options(_ part: Int, parm p: Int = 0, bits bts: ClosedRange<Int>? = nil, options opts: [Int:String]) -> OptionsParam {
      let boff = RolandAddress(0x140).intValue() + part * 52
      return OptionsParam(parm: p, byte: p + boff, bits: bts, options: opts)
    }
    
    private static func options(_ part: Int, parm p: Int = 0, bit bt: Int, options opts: [Int:String]) -> OptionsParam {
      let boff = RolandAddress(0x140).intValue() + part * 52
      return OptionsParam(parm: p, byte: p + boff, bit: bt, options: opts)
    }
    
    static let presetFseqOptions = OptionsParam.makeNumberedOptions(["ShoobyDo", "2BarBeat", "D&B", "D&B Fill", "4BarBeat", "YouCanG", "EBSayHey", "RtmSynth", "VocalRtm", "WooWaPa", "UooLha", "FemRtm", "ByonRole", "WowYeah", "ListenVo", "YAMAHAFS", "Laugh", "Laugh2", "AreYouR", "Oiyai", "Oiaiuo", "UuWaUu", "Wao", "RndArp1", "FiltrArp", "RndArp2", "TechArp", "RndArp3", "Voco-Seq", "PopTech", "1BarBeat", "1BrBeat2", "Undo", "RndArp4", "VoclRtm2", "Reiyowha", "RndArp5", "VocalArp", "CanYouGi", "Pu-Yo", "Yaof", "MyaOh", "ChuckRtm", "ILoveYou", "Jan-On", "Welcome", "One-Two", "Edokko", "Everybdy", "Uwau", "YEEAAH", "4-3-2-1", "Test123", "CheckSnd", "ShavaDo", "R-M-H-R", "HiSchool", "M.Blastr", "L&G MayI", "Hellow", "ChowaUu", "Everybd2", "Dodidowa", "Check123", "BranNewY", "BoomBoom", "Hi=Woo", "FreeForm", "FreqPad", "YouKnow", "OldTech", "B/M", "MiniJngl", "EveryB-S", "IYaan", "Yeah", "ThankYou", "Yes=No", "UnWaEDon", "MouthPop", "Fire", "TBLine", "China", "Aeiou", "YaYeYiYo", "C7Seq", "SoundLib", "IYaan2", "Relax", "PSYAMAHA"], offset: 1)
    
    static let bankOptions = OptionsParam.makeOptions(["Off","Int","PrA","PrB","PrC", "PrD","PrE","PrF","PrG","PrH","PrI","PrJ","PrK"])

    static let channelOptions: [Int:String] = {
      var options = OptionsParam.makeOptions((0..<16).map { "\($0+1)"} )
      options[0x10] = "Pfm"
      options[0x7f] = "Off"
      return options
    }()

    static let channelMaxOptions: [Int:String] = {
      var options = OptionsParam.makeOptions((0..<16).map { "\($0+1)"} )
      options[0x7f] = "Off"
      return options
    }()

    static let fseqMidiSpeedOptions = ["Midi 1/4","Midi 1/2","Midi","Midi 2/1","Midi 4/1"]
    static let fseqSpeedOptions: [Int:String] = {
      var opts = ["Midi 1/4","Midi 1/2","Midi","Midi 2/1","Midi 4/1"]
      opts.append(contentsOf: [String](repeating: "10.0%", count: 95))
      opts.append(contentsOf: (100...5000).map { String(format: "%.1f%%", (Float($0) * 0.1)) })
      return OptionsParam.makeOptions(opts)
    }()
    
    static let panOptions: [Int:String] = {
      var options = [Int:String]()
      options[0] = "Random"
      (1..<128).forEach { options[$0] = "\($0-64)"}
      return options
    }()
    
    static let destOptions = OptionsParam.makeOptions(["Off","Insert Param 1", "Insert Param 2", "Insert Param 3", "Insert Param 4", "Insert Param 5", "Insert Param 6", "Insert Param 7", "Insert Param 8", "Insert Param 9", "Insert Param 10", "Insert Param 11", "Insert Param 12", "Insert Param 13", "Insert Param 14", "Ins->Rev", "Ins->Vari", "Volume", "Pan", "Rev Send", "Var Send", "Flt Cutoff", "Flt Reson", "Flt EG Depth", "Attack", "Decay", "Release", "Pitch EG Init", "Pitch EG Attack", "Pitch EG Rel Level", "Pitch EG Rel Time", "V/N Balance", "Formant", "FM", "Pitch Bias", "Amp EG Bias", "Freq Bias", "Voiced BW", "Unvoiced BW", "LFO1 Pitch Mod", "LFO1 Amp Mod", "LFO1 Freq Mod", "LFO1 Filter Mod", "LFO1 Speed", "LFO2 Filter Mod", "LFO2 Speed", "Fseq Speed", "Formant Scratch"])
    
    static let reverbOptions = OptionsParam.makeOptions(["None", "Hall 1", "Hall 2", "Room 1", "Room 2", "Room 3", "Stage 1", "Stage 2", "Plate", "White Room", "Tunnel", "Basement", "Canyon", "Delay LCR", "Delay L,R", "Echo", "Cross Delay",])

    static let varyOptions = OptionsParam.makeOptions(["None", "Chorus", "Celeste", "Flanger", "Symphonic", "Phaser 1", "Phaser 2", "Ens Detune", "Rotary Sp", "Tremolo", "Auto Pan", "Auto Wah", "Touch Wah", "3-Band EQ", "HM Enhancer", "Noise Gate", "Compressor", "Distortion", "Overdrive", "Amp Sim", "Delay LCR", "Delay L,R", "Echo", "Cross Delay", "Karaoke", "Hall", "Room", "Stage", "Plate"])

    static let insertOptions = OptionsParam.makeOptions(["Thru", "Chorus", "Celeste", "Flanger", "Symphonic", "Phaser 1", "Phaser 2", "Pitch Chng", "Ens Detune", "Rotary Sp", "2 Way Rotary", "Tremolo", "Auto Pan", "Ambience", "A-Wah+Dist", "A-Wah+Odrv", "T-Wah+Dist", "T-Wah+Odrv", "Wah+DS+Dly", "Wah+OD+Dly", "Lo-Fi", "3-Band EQ", "HM Enhncr", "Noise Gate", "Compressor", "Comp+Dist", "Cmp+DS+Dly", "Cmp+OD+Dly", "Distortion", "Dist+Dly", "Overdrive", "Ovdrv+Dly", "Amp Sim", "Delay LCR", "Delay L,R", "Echo", "CrossDelay", "ER 1", "ER 2", "Gate Rev", "Revrs Gate"])
    
    static let eqShapeOptions = OptionsParam.makeOptions(["Shelv", "Peak"])
    static let eqQOptions = optionsDict(1...120) { String(format: "%.1f", Float($0) / 10) }
    
    static let reverbTimeParam = OptionsParam(options: OptionsParam.makeOptions({
      var options = [String]()
      options += (0...47).map { "\(0.3 + Float($0) * 0.1)"}
      options += (48...57).map { "\(5.0 + Float($0-47) * 0.5)"}
      options += (58...67).map { "\(10.0 + Float($0-57) * 1)"}
      options += (68...69).map { "\(20.0 + Float($0-67) * 5)"}
      return options
    }()))
    
    static let delay200Param = OptionsParam(options: OptionsParam.makeOptions({
      return (0...127).map { String(format: "%.1f", (0.1 + (Float($0)/127) * 199.9))}
    }()))

    static let revDelayParam = OptionsParam(options: OptionsParam.makeOptions({
      return (0...63).map { String(format: "%.1f", (0.1 + (Float($0)/63) * 99.2))}
      }()))
    
    static let hiDampParam = OptionsParam(options: {
      var opts = [Int:String]()
      (1...10).forEach { opts[$0] = String(format: "%.1f", (Float($0) * 0.1))}
      return opts
      }())
    
    static let gainParam = RangeParam(range: 52...76, displayOffset: -64)

    static let cutoffOptions = ["thru","22","25","28","32","36","40","45","50","56","63","70", "80","90","100","110","125","140","160","180","200","225","250","280","315","355","400","450","500","560", "630","700","800","900","1.0k","1.1k","1.2k","1.4k","1.6k","1.8k","2.0k","2.2k","2.5k", "2.8k","3.2k","3.6k","4.0k","4.5k","5.0k","5.6k","6.3k","7.0k","8.0k","9.0k", "10.0k", "11.0k", "12.0k", "14.0k", "16.0k", "18.0k", "thru"]

    static func optionsDict(_ range: CountableClosedRange<Int>, _ options: [String]) -> [Int:String] {
      var o = [Int:String]()
      range.forEach { o[$0] = options[$0] }
      return o
    }
    
    static func optionsDict(_ range: CountableClosedRange<Int>, _ transform: (Int) -> String) -> [Int:String] {
      var opts = [Int:String]()
      range.forEach { opts[$0] = transform($0) }
      return opts
    }
    
    static let hpfCutoffParam = OptionsParam(options: optionsDict(0...52, cutoffOptions))
    static let lpfCutoffParam = OptionsParam(options: optionsDict(34...60, cutoffOptions))
    static let eqLoFreqParam = OptionsParam(options: optionsDict(4...40, cutoffOptions))
    static let eqHiFreqParam = OptionsParam(options: optionsDict(28...58, cutoffOptions))
    static let eqMidFreqParam = OptionsParam(options: optionsDict(14...54, cutoffOptions))

    static let qParam = OptionsParam(options: optionsDict(10...120, { String(format: "%.1f", Float($0) / 10) }))

    static let erRevParam = OptionsParam(options: {
      var opts = [Int:String]()
      (1...63).forEach { opts[$0] = "E\(64-$0)>R"}
      opts[64] = "E=R"
      (65...127).forEach { opts[$0] = "E<R\($0-64)"}
      return opts
      }())
    
    static let dimOptions = ["0.5", "0.8", "1.0", "1.3", "1.5", "1.8", "2.0", "2.3", "2.6", "2.8", "3.1", "3.3", "3.6", "3.9", "4.1", "4.4", "4.6", "4.9", "5.2", "5.4", "5.7", "5.9", "6.2", "6.5", "6.7", "7.0", "7.2", "7.5", "7.8", "8.0", "8.3", "8.6", "8.8", "9.1", "9.4", "9.6", "9.9", "10.2", "10.4", "10.7", "11.0", "11.2", "11.5", "11.8", "12.1", "12.3", "12.6", "12.9", "13.1", "13.4", "13.7", "14.0", "14.2", "14.5", "14.8", "15.1", "15.4", "15.6", "15.9", "16.2", "16.5", "16.8", "17.1", "17.3", "17.6", "17.9", "18.2", "18.5", "18.8", "19.1", "19.4", "19.7", "20.0", "20.2", "20.5", "20.8", "21.1", "21.4", "21.7", "22.0", "22.4", "22.7", "23.0", "23.3", "23.6", "23.9", "24.2", "24.5", "24.9", "25.2", "25.5", "25.8", "26.1", "26.5", "26.8", "27.1", "27.5", "27.8", "28.1", "28.5", "28.8", "29.2", "29.5", "29.9", "30.2"]
    static let widthParam = OptionsParam(options: {
      var options = [Int:String]()
      (0...37).forEach { options[$0] = dimOptions[$0] }
      return options
    }())
    static let heightParam = OptionsParam(options: {
      var options = [Int:String]()
      (0...73).forEach { options[$0] = dimOptions[$0] }
      return options
    }())
    static let depthParam = OptionsParam(options: {
      var options = [Int:String]()
      (0...104).forEach { options[$0] = dimOptions[$0] }
      return options
    }())

    static let delay1365Param = OptionsParam(options: {
      var opts = [Int:String]()
      (1...13650).forEach { opts[$0] = String(format: "%.1f", (Float($0) / 10))}
      return opts
    }())
    // 1: 0.1

    private struct Pairs {
      static let loFreq: (String,Param) = ("EQ LowFreq", eqLoFreqParam)
      static let loGain: (String,Param) = ("EQ Low Gain", gainParam)
      static let hiFreq: (String,Param) = ("EQ HiFreq", eqHiFreqParam)
      static let hiGain: (String,Param) = ("EQ Hi Gain", gainParam)
      static let hiDamp: (String,Param) = ("High Damp", hiDampParam)

      static let midFreq: (String,Param) = ("Mid Freq", eqMidFreqParam)
      static let midGain: (String,Param) = ("Mid Gain", gainParam)
      static let midQ: (String,Param) = ("Mid Q", qParam)

      static let lfoFreq: (String,Param) = ("LFO Freq", RangeParam())
      static let lfoDepth: (String,Param) = ("LFO Depth", RangeParam())
      static let fbLevel: (String,Param) = ("FB Level", RangeParam(range: 1...127, displayOffset: -64))
      static let mode: (String,Param) = ("Mode", RangeParam())

      static let delayOffset: (String,Param) = ("Delay Ofst", RangeParam())
      static let phaseShift: (String,Param) = ("Phase Shift", RangeParam())

      static let dryWet: (String,Param) = ("Dry/Wet", RangeParam())

      static let drive: (String,Param) = ("Drive", RangeParam())
      static let distLoGain: (String,Param) = ("DS Low Gain", gainParam)
      static let distMidGain: (String,Param) = ("DS Mid Gain", gainParam)
      static let lpfCutoff: (String,Param) = ("LPF Cutoff", RangeParam())
      static let outLevel: (String,Param) = ("Output Level", RangeParam())

      static let cutoff: (String,Param) = ("Cutoff", RangeParam())
      static let reson: (String,Param) = ("Reson", RangeParam())
      static let sens: (String,Param) = ("Sensitivity", RangeParam())

      static let delay: (String,Param) = ("Delay", RangeParam())
      static let leftDelay: (String,Param) = ("LchDelay", delay1365Param)
      static let rightDelay: (String,Param) = ("RchDelay", delay1365Param)
      static let centerDelay: (String,Param) = ("CchDelay", delay1365Param)
      static let fbDelay: (String,Param) = ("FB Delay", delay1365Param)

    }
    
    // MARK: Reverb Params
    
    static let reverbParams: [[Int:(String,Param)]] = [
      [:],
      hallParams, // hall 1
      hallParams, // hall 2
      hallParams, // room 1
      hallParams, // room 2
      hallParams, // room 3
      hallParams, // stage 1
      hallParams, // stage 2
      hallParams, // plate
      whiteRoomParams, // white room
      whiteRoomParams, // tunnel
      whiteRoomParams, // basement
      whiteRoomParams, // canyon
      delayLCRParams,
      delayLRParams,
      echoParams,
      crossDelayParams,
    ]
    
    static let hallParams: [Int:(String,Param)] = [
      0 : ("Time", reverbTimeParam),
      1 : ("Diffusion", RangeParam(maxVal: 10)),
      2 : ("InitDelay", delay200Param),
      3 : ("HPF Cutoff", hpfCutoffParam),
      4 : ("LPF Cutoff", lpfCutoffParam),
      10 : ("Rev Delay", revDelayParam),
      11 : ("Density", RangeParam(maxVal: 4)),
      12 : ("ER/Rev", erRevParam),
      13 : Pairs.hiDamp,
      14 : Pairs.fbLevel,
    ]
    
    static let whiteRoomParams: [Int:(String,Param)] = [
      0 : ("Time", reverbTimeParam),
      1 : ("Diffusion", RangeParam(maxVal: 10)),
      2 : ("InitDelay", delay200Param),
      3 : ("HPF Cutoff", hpfCutoffParam),
      4 : ("LPF Cutoff", lpfCutoffParam),
      5 : ("Width", widthParam),
      6 : ("Height", heightParam),
      7 : ("Depth", depthParam),
      8 : ("Wall Vary", RangeParam(maxVal: 30)),
      10 : ("Rev Delay", revDelayParam),
      11 : ("Density", RangeParam(maxVal: 4)),
      12 : ("ER/Rev", erRevParam),
      13 : Pairs.hiDamp,
      14 : Pairs.fbLevel,
      ]

    static let delayLCRParams: [Int:(String,Param)] = [
      0 : Pairs.leftDelay,
      1 : Pairs.rightDelay,
      2 : Pairs.centerDelay,
      3 : Pairs.fbDelay,
      4 : Pairs.fbLevel,
      5 : ("CchLevel", RangeParam()),
      6 : Pairs.hiDamp,
      12 : Pairs.loFreq,
      13 : Pairs.loGain,
      14 : Pairs.hiFreq,
      15 : Pairs.hiGain,
      ]

    static let delayLRParams: [Int:(String,Param)] = [
      0 : Pairs.leftDelay,
      1 : Pairs.rightDelay,
      2 : ("FBDelay1", RangeParam()),
      3 : ("FBDelay2", RangeParam()),
      4 : Pairs.fbLevel,
      5 : Pairs.hiDamp,
      12 : Pairs.loFreq,
      13 : Pairs.loGain,
      14 : Pairs.hiFreq,
      15 : Pairs.hiGain,
      ]
    
    static let echoParams: [Int:(String,Param)] = [
      0 : Pairs.leftDelay,
      1 : ("Lch FB Lvl", RangeParam()),
      2 : Pairs.rightDelay,
      3 : ("Rch FB Lvl", RangeParam()),
      4 : Pairs.hiDamp,
      5 : ("LchDelay2", RangeParam()),
      6 : ("RchDelay2", RangeParam()),
      7 : ("Delay2 Lvl", RangeParam()),
      12 : Pairs.loFreq,
      13 : Pairs.loGain,
      14 : Pairs.hiFreq,
      15 : Pairs.hiGain,
      ]

    static let crossDelayParams: [Int:(String,Param)] = [
      0 : ("L>R Delay", RangeParam()),
      1 : ("R>L Delay", RangeParam()),
      2 : Pairs.fbLevel,
      3 : ("InputSelect", RangeParam()),
      4 : Pairs.hiDamp,
      12 : Pairs.loFreq,
      13 : Pairs.loGain,
      14 : Pairs.hiFreq,
      15 : Pairs.hiGain,
      ]
    
    // MARK: Variation Params
    
    static let varyParams: [[Int:(String,Param)]] = [
      [:],
      chorusParams,
      chorusParams, // celeste
      flangerParams,
      symphParams,
      phaser1Params,
      phaser2Params,
      ensDetuneParams,
      rotarySpParams,
      tremoloParams,
      autoPanParams,
      autoWahParams,
      touchWahParams,
      triBandEQParams,
      hmEnhancerParams,
      noiseGateParams,
      compressorParams,
      distortionParams,
      distortionParams, // overdrive
      ampSimParams,
      delayLCRParams,
      delayLRParams,
      echoParams,
      crossDelayParams,
      karaokeParams,
      hallParams, // hall
      hallParams, // room
      hallParams, // stage
      hallParams, // plate
      ]
    
    static let chorusParams: [Int:(String,Param)] = [
      0 : Pairs.lfoFreq,
      1 : Pairs.lfoDepth,
      2 : Pairs.fbLevel,
      3 : Pairs.delayOffset,
      5 : Pairs.loFreq,
      6 : Pairs.loGain,
      7 : Pairs.hiFreq,
      8 : Pairs.hiGain,
      14 : Pairs.mode,
      ]

    static let flangerParams: [Int:(String,Param)] = [
      0 : Pairs.lfoFreq,
      1 : Pairs.lfoDepth,
      2 : Pairs.fbLevel,
      3 : Pairs.delayOffset,
      5 : Pairs.loFreq,
      6 : Pairs.loGain,
      7 : Pairs.hiFreq,
      8 : Pairs.hiGain,
      13 : ("LFO Phase", RangeParam()),
    ]

    static let symphParams: [Int:(String,Param)] = [
      0 : Pairs.lfoFreq,
      1 : Pairs.lfoDepth,
      2 : Pairs.delayOffset,
      5 : Pairs.loFreq,
      6 : Pairs.loGain,
      7 : Pairs.hiFreq,
      8 : Pairs.hiGain,
      ]
    
    static let phaser1Params: [Int:(String,Param)] = [
      0 : Pairs.lfoFreq,
      1 : Pairs.lfoDepth,
      2 : Pairs.phaseShift,
      3 : Pairs.fbLevel,
      10 : ("Stage",RangeParam()),
      11 : ("Diffuse",RangeParam()),
      5 : Pairs.loFreq,
      6 : Pairs.loGain,
      7 : Pairs.hiFreq,
      8 : Pairs.hiGain,
      ]

    static let phaser2Params: [Int:(String,Param)] = [
      0 : Pairs.lfoFreq,
      1 : Pairs.lfoDepth,
      2 : Pairs.phaseShift,
      3 : Pairs.fbLevel,
      10 : ("Stage",RangeParam()),
      12 : ("LFO Phase", RangeParam()),
      5 : Pairs.loFreq,
      6 : Pairs.loGain,
      7 : Pairs.hiFreq,
      8 : Pairs.hiGain,
      ]

    static let ensDetuneParams: [Int:(String,Param)] = [
      0 : ("Detune",RangeParam()),
      1 : ("InitDelayL",RangeParam()),
      2 : ("InitDelayR",RangeParam()),
      10 : Pairs.loFreq,
      11 : Pairs.loGain,
      12 : Pairs.hiFreq,
      13 : Pairs.hiGain,
      ]
    
    static let rotarySpParams: [Int:(String,Param)] = [
      0 : Pairs.lfoFreq,
      1 : Pairs.lfoDepth,
      5 : Pairs.loFreq,
      6 : Pairs.loGain,
      7 : Pairs.hiFreq,
      8 : Pairs.hiGain,
      ]
    
    static let tremoloParams: [Int:(String,Param)] = [
      0 : Pairs.lfoFreq,
      1 : ("AM Depth", RangeParam()),
      2 : ("PM Depth", RangeParam()),
      13 : ("LFO Phase", RangeParam()),
      5 : Pairs.loFreq,
      6 : Pairs.loGain,
      7 : Pairs.hiFreq,
      8 : Pairs.hiGain,
      14 : Pairs.mode,
    ]
    
    static let autoPanParams: [Int:(String,Param)] = [
      0 : Pairs.lfoFreq,
      1 : ("L/R Depth", RangeParam()),
      2 : ("F/R Depth", RangeParam()),
      3 : ("Pan Dir", RangeParam()),
      5 : Pairs.loFreq,
      6 : Pairs.loGain,
      7 : Pairs.hiFreq,
      8 : Pairs.hiGain,
    ]
    
    static let autoWahParams: [Int:(String,Param)] = [
      0 : Pairs.lfoFreq,
      1 : Pairs.lfoDepth,
      2 : ("Cutoff", RangeParam()),
      3 : ("Reson", RangeParam()),
      5 : Pairs.loFreq,
      6 : Pairs.loGain,
      7 : Pairs.hiFreq,
      8 : Pairs.hiGain,
    ]
    
    static let touchWahParams: [Int:(String,Param)] = [
      0 : ("Sensitivity", RangeParam()),
      1 : ("Cutoff", RangeParam()),
      2 : ("Reson", RangeParam()),
      5 : Pairs.loFreq,
      6 : Pairs.loGain,
      7 : Pairs.hiFreq,
      8 : Pairs.hiGain,
    ]
    
    static let triBandEQParams: [Int:(String,Param)] = [
      5 : Pairs.loFreq,
      0 : Pairs.loGain,
      1 : Pairs.midFreq,
      2 : Pairs.midGain,
      3 : Pairs.midQ,
      6 : Pairs.hiFreq,
      4 : Pairs.hiGain,
      14 : Pairs.mode,
    ]
    
    static let hmEnhancerParams: [Int:(String,Param)] = [
      0 : ("HPF Cutoff", RangeParam()),
      1 : ("Drive", RangeParam()),
      2 : ("Mix Level", RangeParam()),
    ]
    
    static let noiseGateParams: [Int:(String,Param)] = [
      0 : ("Attack", RangeParam()),
      1 : ("Release", RangeParam()),
      2 : ("Threshold", RangeParam()),
      3 : ("Output Level", RangeParam()),
    ]
    
    static let compressorParams: [Int:(String,Param)] = [
      0 : ("Attack", RangeParam()),
      1 : ("Release", RangeParam()),
      2 : ("Threshold", RangeParam()),
      3 : ("Ratio", RangeParam()),
      4 : ("Output Level", RangeParam()),
    ]
    
    static let distortionParams: [Int:(String,Param)] = [
      0 : Pairs.drive,
      1 : Pairs.loFreq,
      2 : Pairs.loGain,
      6 : Pairs.midFreq,
      7 : Pairs.midGain,
      8 : Pairs.midQ,
      3 : Pairs.lpfCutoff,
      10 : ("Edge", RangeParam()),
      4 : Pairs.outLevel,
    ]
    
    static let ampSimParams: [Int:(String,Param)] = [
      0 : Pairs.drive,
      1 : ("Amp Type", RangeParam()),
      2 : Pairs.lpfCutoff,
      10 : ("Edge", RangeParam()),
      3 : Pairs.outLevel,
    ]
    
    static let karaokeParams: [Int:(String,Param)] = [
      0 : ("Delay Time", RangeParam()),
      1 : Pairs.fbLevel,
      2 : ("HPF Cutoff", RangeParam()),
      3 : ("LPF Cutoff", RangeParam()),
      ]
    
    // MARK: Insert Params
    
    static let insertParams: [[Int:(String,Param)]] = [
      [:],
      Insert.chorusParams,
      Insert.chorusParams, // celeste
      Insert.flangerParams,
      Insert.symphParams,
      Insert.phaser1Params,
      Insert.phaser2Params,
      Insert.pitchChangeParams,
      Insert.ensDetuneParams,
      Insert.rotarySpParams,
      Insert.twoWayRotaryParams,
      Insert.tremoloParams,
      Insert.autoPanParams,
      Insert.ambienceParams,
      Insert.autoWahDistParams,
      Insert.autoWahDistParams, // autowah/OD
      Insert.touchWahDistParams,
      Insert.touchWahDistParams, // touchwah/OD
      Insert.wahDistDelayParams,
      Insert.wahDistDelayParams, // wah/OD/delay
      Insert.loFiParams,
      Insert.triBandEQParams,
      Insert.hmEnhancerParams,
      noiseGateParams,
      compressorParams,
      Insert.compDistParams,
      Insert.compDistDelayParams,
      Insert.compDistDelayParams, // comp/OD/delay
      Insert.distortionParams,
      Insert.distDelayParams,
      Insert.distortionParams, // overdrive
      Insert.distDelayParams, // OD/delay
      Insert.ampSimParams,
      Insert.delayLCRParams,
      Insert.delayLRParams,
      Insert.echoParams,
      Insert.crossDelayParams,
      Insert.er1Params,
      Insert.er1Params, // ER 2
      Insert.gateRevParams,
      Insert.gateRevParams, // reverse gate
    ]
    
    private struct Insert {
      
      static let chorusParams: [Int:(String,Param)] = [
        0 : Pairs.lfoFreq,
        1 : Pairs.lfoDepth,
        2 : Pairs.fbLevel,
        3 : Pairs.delayOffset,
        5 : Pairs.loFreq,
        6 : Pairs.loGain,
        10 : Pairs.midFreq,
        11 : Pairs.midGain,
        12 : Pairs.midQ,
        7 : Pairs.hiFreq,
        8 : Pairs.hiGain,
        14 : Pairs.mode,
        9 : Pairs.dryWet,
      ]
      
      static let flangerParams: [Int:(String,Param)] = [
        0 : Pairs.lfoFreq,
        1 : Pairs.lfoDepth,
        2 : Pairs.fbLevel,
        3 : Pairs.delayOffset,
        5 : Pairs.loFreq,
        6 : Pairs.loGain,
        10 : Pairs.midFreq,
        11 : Pairs.midGain,
        12 : Pairs.midQ,
        7 : Pairs.hiFreq,
        8 : Pairs.hiGain,
        13 : ("LFO Phase", RangeParam()),
        9 : Pairs.dryWet,
      ]
      
      static let symphParams: [Int:(String,Param)] = [
        0 : Pairs.lfoFreq,
        1 : Pairs.lfoDepth,
        2 : Pairs.delayOffset,
        5 : Pairs.loFreq,
        6 : Pairs.loGain,
        10 : Pairs.midFreq,
        11 : Pairs.midGain,
        12 : Pairs.midQ,
        7 : Pairs.hiFreq,
        8 : Pairs.hiGain,
        9 : Pairs.dryWet,
      ]
      
      static let phaser1Params: [Int:(String,Param)] = [
        0 : Pairs.lfoFreq,
        1 : Pairs.lfoDepth,
        2 : Pairs.phaseShift,
        3 : Pairs.fbLevel,
        10 : ("Stage",RangeParam()),
        11 : ("Diffuse",RangeParam()),
        5 : Pairs.loFreq,
        6 : Pairs.loGain,
        7 : Pairs.hiFreq,
        8 : Pairs.hiGain,
        9 : Pairs.dryWet,
      ]
      
      static let phaser2Params: [Int:(String,Param)] = [
        0 : Pairs.lfoFreq,
        1 : Pairs.lfoDepth,
        2 : Pairs.phaseShift,
        3 : Pairs.fbLevel,
        10 : ("Stage",RangeParam()),
        12 : ("LFO Phase", RangeParam()),
        5 : Pairs.loFreq,
        6 : Pairs.loGain,
        7 : Pairs.hiFreq,
        8 : Pairs.hiGain,
        9 : Pairs.dryWet,
        ]
      
      static let pitchChangeParams: [Int:(String,Param)] = [
        0 : ("Pitch",RangeParam()),
        1 : ("Init Delay", RangeParam()),
        2 : ("Fine 1",RangeParam()),
        3 : ("Fine 2", RangeParam()),
        4 : Pairs.fbLevel,
        10 : ("Pan 1", RangeParam()),
        11 : ("Out Level 1", RangeParam()),
        12 : ("Pan 2",RangeParam()),
        13 : ("Out Level 2", RangeParam()),
        9 : Pairs.dryWet,
      ]
      
      static let ensDetuneParams: [Int:(String,Param)] = [
        0 : ("Detune",RangeParam()),
        1 : ("InitDelayL",RangeParam()),
        2 : ("InitDelayR",RangeParam()),
        10 : Pairs.loFreq,
        11 : Pairs.loGain,
        12 : Pairs.hiFreq,
        13 : Pairs.hiGain,
        9 : Pairs.dryWet,
      ]
      
      static let rotarySpParams: [Int:(String,Param)] = [
        0 : Pairs.lfoFreq,
        1 : Pairs.lfoDepth,
        5 : Pairs.loFreq,
        6 : Pairs.loGain,
        10 : Pairs.midFreq,
        11 : Pairs.midGain,
        12 : Pairs.midQ,
        7 : Pairs.hiFreq,
        8 : Pairs.hiGain,
        9 : Pairs.dryWet,
      ]
      
      static let twoWayRotaryParams: [Int:(String,Param)] = [
        0 : ("Rotor Spd",RangeParam()),
        1 : ("Drive Low",RangeParam()),
        2 : ("Drive Hi",RangeParam()),
        3 : ("Low/High",RangeParam()),
        11 : ("Mic Angle",RangeParam()),
        10 : ("CrossFreq",RangeParam()),
        5 : Pairs.loFreq,
        6 : Pairs.loGain,
        7 : Pairs.hiFreq,
        8 : Pairs.hiGain,
      ]
      
      static let tremoloParams: [Int:(String,Param)] = [
        0 : Pairs.lfoFreq,
        1 : ("AM Depth", RangeParam()),
        2 : ("PM Depth", RangeParam()),
        13 : ("LFO Phase", RangeParam()),
        5 : Pairs.loFreq,
        6 : Pairs.loGain,
        10 : Pairs.midFreq,
        11 : Pairs.midGain,
        12 : Pairs.midQ,
        7 : Pairs.hiFreq,
        8 : Pairs.hiGain,
        14 : Pairs.mode,
      ]
      
      static let autoPanParams: [Int:(String,Param)] = [
        0 : Pairs.lfoFreq,
        1 : ("L/R Depth", RangeParam()),
        2 : ("F/R Depth", RangeParam()),
        3 : ("Pan Dir", RangeParam()),
        5 : Pairs.loFreq,
        6 : Pairs.loGain,
        10 : Pairs.midFreq,
        11 : Pairs.midGain,
        12 : Pairs.midQ,
        7 : Pairs.hiFreq,
        8 : Pairs.hiGain,
      ]
      
      static let ambienceParams: [Int:(String,Param)] = [
        0 : ("Delay Time", RangeParam()),
        1 : ("Phase", RangeParam()),
        5 : Pairs.loFreq,
        6 : Pairs.loGain,
        7 : Pairs.hiFreq,
        8 : Pairs.hiGain,
        9 : Pairs.dryWet,
      ]
      
      static let autoWahDistParams: [Int:(String,Param)] = [
        0 : Pairs.lfoFreq,
        1 : Pairs.lfoDepth,
        2 : Pairs.cutoff,
        3 : Pairs.reson,
        5 : Pairs.loFreq,
        6 : Pairs.loGain,
        7 : Pairs.hiFreq,
        8 : Pairs.hiGain,
        10 : Pairs.drive,
        11 : Pairs.distLoGain,
        12 : Pairs.distMidGain,
        13 : Pairs.lpfCutoff,
        14 : Pairs.outLevel,
        9 : Pairs.dryWet,
      ]
      
      static let touchWahDistParams: [Int:(String,Param)] = [
        0 : Pairs.sens,
        1 : Pairs.cutoff,
        2 : Pairs.reson,
        15 : ("Release", RangeParam()),
        5 : Pairs.loFreq,
        6 : Pairs.loGain,
        7 : Pairs.hiFreq,
        8 : Pairs.hiGain,
        10 : Pairs.drive,
        11 : Pairs.distLoGain,
        12 : Pairs.distMidGain,
        13 : Pairs.lpfCutoff,
        14 : Pairs.outLevel,
        9 : Pairs.dryWet,
      ]
      
      static let wahDistDelayParams: [Int:(String,Param)] = [
        10 : Pairs.sens,
        11 : Pairs.cutoff,
        12 : Pairs.reson,
        13 : ("Release", RangeParam()),
        3 : Pairs.drive,
        4 : Pairs.outLevel,
        5 : Pairs.distLoGain,
        6 : Pairs.distMidGain,
        0 : Pairs.delay,
        1 : Pairs.fbLevel,
        2 : ("Delay Mix", RangeParam()),
        9 : Pairs.dryWet,
      ]
      
      static let loFiParams: [Int:(String,Param)] = [
        0 : ("Smpl Freq", RangeParam()),
        1 : ("Word Length", RangeParam()),
        2 : ("Output Gain", RangeParam()),
        3 : Pairs.lpfCutoff,
        5 : ("LPF Reso", RangeParam()),
        4 : ("Filter", RangeParam()),
        6 : ("Bit Assign", RangeParam()),
        7 : ("Emphasis", RangeParam()),
        9 : Pairs.dryWet,
      ]
      
      static let triBandEQParams: [Int:(String,Param)] = [
        5 : Pairs.loFreq,
        0 : Pairs.loGain,
        1 : Pairs.midFreq,
        2 : Pairs.midGain,
        3 : Pairs.midQ,
        6 : Pairs.hiFreq,
        4 : Pairs.hiGain,
        14 : Pairs.mode,
      ]
      
      static let hmEnhancerParams: [Int:(String,Param)] = [
        0 : ("HPF Cutoff", RangeParam()),
        1 : Pairs.drive,
        2 : ("Mix Level", RangeParam()),
      ]
      
      static let compDistParams: [Int:(String,Param)] = [
        11 : ("Attack", RangeParam()),
        12 : ("Release", RangeParam()),
        13 : ("Threshold", RangeParam()),
        14 : ("Ratio", RangeParam()),
        0 : Pairs.drive,
        1 : Pairs.loFreq,
        2 : Pairs.loGain,
        6 : Pairs.midFreq,
        7 : Pairs.midGain,
        8 : Pairs.midQ,
        3 : Pairs.lpfCutoff,
        10 : ("Edge", RangeParam()),
        4 : Pairs.outLevel,
        9 : Pairs.dryWet,
      ]
      
      static let compDistDelayParams: [Int:(String,Param)] = [
        10 : ("Attack", RangeParam()),
        11 : ("Release", RangeParam()),
        12 : ("Threshold", RangeParam()),
        13 : ("Ratio", RangeParam()),
        3 : Pairs.drive,
        4 : Pairs.outLevel,
        5 : Pairs.distLoGain,
        6 : Pairs.distMidGain,
        0 : Pairs.delay,
        1 : Pairs.fbLevel,
        2 : ("Delay Mix", RangeParam()),
        9 : Pairs.dryWet,
      ]
      
      static let distortionParams: [Int:(String,Param)] = [
        0 : Pairs.drive,
        1 : Pairs.loFreq,
        2 : Pairs.loGain,
        6 : Pairs.midFreq,
        7 : Pairs.midGain,
        8 : Pairs.midQ,
        3 : Pairs.lpfCutoff,
        10 : ("Edge", RangeParam()),
        4 : Pairs.outLevel,
        9 : Pairs.dryWet,
      ]
      
      static let distDelayParams: [Int:(String,Param)] = [
        5 : Pairs.drive,
        7 : Pairs.distLoGain,
        8 : Pairs.distMidGain,
        0 : ("LchDelay", RangeParam()),
        1 : ("RchDelay", RangeParam()),
        2 : ("FB Delay", RangeParam()),
        3 : Pairs.fbLevel,
        4 : ("Delay Mix", RangeParam()),
        6 : Pairs.outLevel,
        9 : Pairs.dryWet,
        ]
      
      static let ampSimParams: [Int:(String,Param)] = [
        0 : Pairs.drive,
        1 : ("Amp Type", RangeParam()),
        2 : Pairs.lpfCutoff,
        10 : ("Edge", RangeParam()),
        3 : Pairs.outLevel,
        9 : Pairs.dryWet,
      ]
      
      static let delayLCRParams: [Int:(String,Param)] = [
        0 : Pairs.leftDelay,
        1 : Pairs.rightDelay,
        2 : Pairs.centerDelay,
        3 : Pairs.fbDelay,
        4 : Pairs.fbLevel,
        5 : ("CchLevel", RangeParam()),
        6 : Pairs.hiDamp,
        12 : Pairs.loFreq,
        13 : Pairs.loGain,
        14 : Pairs.hiFreq,
        15 : Pairs.hiGain,
        9 : Pairs.dryWet,
      ]
      
      static let delayLRParams: [Int:(String,Param)] = [
        0 : Pairs.leftDelay,
        1 : Pairs.rightDelay,
        2 : ("FBDelay1", RangeParam()),
        3 : ("FBDelay2", RangeParam()),
        4 : Pairs.fbLevel,
        5 : Pairs.hiDamp,
        12 : Pairs.loFreq,
        13 : Pairs.loGain,
        14 : Pairs.hiFreq,
        15 : Pairs.hiGain,
        9 : Pairs.dryWet,
      ]
      
      static let echoParams: [Int:(String,Param)] = [
        0 : Pairs.leftDelay,
        1 : ("Lch FB Lvl", RangeParam()),
        2 : Pairs.rightDelay,
        3 : ("Rch FB Lvl", RangeParam()),
        4 : Pairs.hiDamp,
        5 : ("LchDelay2", RangeParam()),
        6 : ("RchDelay2", RangeParam()),
        7 : ("Delay2 Lvl", RangeParam()),
        12 : Pairs.loFreq,
        13 : Pairs.loGain,
        14 : Pairs.hiFreq,
        15 : Pairs.hiGain,
        9 : Pairs.dryWet,
      ]
      
      static let crossDelayParams: [Int:(String,Param)] = [
        0 : ("L>R Delay", RangeParam()),
        1 : ("R>L Delay", RangeParam()),
        2 : Pairs.fbLevel,
        3 : ("InputSelect", RangeParam()),
        4 : Pairs.hiDamp,
        12 : Pairs.loFreq,
        13 : Pairs.loGain,
        14 : Pairs.hiFreq,
        15 : Pairs.hiGain,
        9 : Pairs.dryWet,
      ]
      
      static let er1Params: [Int:(String,Param)] = [
        0 : ("Early Type", RangeParam()),
        1 : ("Room Size", RangeParam()),
        2 : ("Diffusion", RangeParam()),
        3 : ("Init Delay", delay200Param),
        4 : Pairs.fbLevel,
        5 : ("HPF Cutoff", RangeParam()),
        6 : Pairs.lpfCutoff,
        10 : ("Liveness", RangeParam()),
        11 : ("Density", RangeParam()),
        12 : Pairs.hiDamp,
        9 : Pairs.dryWet,
      ]
      
      static let gateRevParams: [Int:(String,Param)] = [
        0 : ("Gate Type", RangeParam()),
        1 : ("Room Size", RangeParam()),
        2 : ("Diffusion", RangeParam()),
        3 : ("Init Delay", delay200Param),
        4 : Pairs.fbLevel,
        5 : ("HPF Cutoff", RangeParam()),
        6 : Pairs.lpfCutoff,
        10 : ("Liveness", RangeParam()),
        11 : ("Density", RangeParam()),
        12 : Pairs.hiDamp,
        9 : Pairs.dryWet,
      ]
      
      
    }
  }
  
}

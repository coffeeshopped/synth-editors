
class WavestationSRWaveSeqBank : WavestationPatch {
  
  static let initFileName = "wavestationsr-waveseq-init"
  static let fileDataCount = 17576

  var name = ""
  var bytes: [UInt8]

  required init(data: Data) {
    // 8784 bytes
    bytes = stride(from: 6, to: 17574, by: 2).map { data[$0] + (data[$0 + 1] << 4) }
    (0..<32).forEach { updatePseudos(seq: $0) }
  }

  // ... so that pseudos get init'ed
  func copy() -> Self {
    let p = type(of: self).init(rawBytes: bytes)
    (0..<32).forEach { p.updatePseudos(seq: $0) }
    seqInfo(4)
    p.name = name
    return p
  }

  
  private let nameBytesStart = 8528
  
  func allNames() -> [SynthPath:String] {
    var names: [SynthPath:String] = [[] : name]
    (0..<32).forEach {
      let p: SynthPath = [.seq, .i($0), .name]
      names[p] = name(forPath: p)
    }
    return names
  }

  func name(forPath path: SynthPath) -> String? {
    guard let index = path.i(1) else { return nil }
    return name(index)
  }
  
  func name(_ index: Int) -> String? {
    guard index < 32 else { return nil }
    // names start at 8528
    let off = nameBytesStart + (index * 8)
    return type(of: self).name(forRange: off..<(off+8), bytes: bytes)
  }
  
  func set(name n: String, forPath path: SynthPath) {
    guard let index = path.i(1),
      index < 32 else { return }
    let off = nameBytesStart + (index * 8)
    set(string: n, forByteRange: off..<(off+8))
  }
    
  private var pseudoValues = [SynthPath:Int]()

  private func updatePseudos(seq: Int) {
    let pre: SynthPath = [.seq, .i(seq)]
    var step = 0
    var nextMem = self[pre + [.start, .link]] ?? 0
    while nextMem > 0 {
      let stepPre: SynthPath = pre + [.step, .i(step)]
      let stepMemPre: SynthPath = [.step, .i(nextMem)]
//      debugPrint("Step \(step) is at \(nextMem). Follow is: \(self[stepMemPre + [.follow, .link]]!)")
      pseudoValues[stepPre + [.memory]] = nextMem
      pseudoValues[stepPre + [.wave]] = self[stepMemPre + [.wave]] ?? 0
      pseudoValues[stepPre + [.coarse]] = self[stepMemPre + [.coarse]] ?? 0
      pseudoValues[stepPre + [.fine]] = self[stepMemPre + [.fine]] ?? 0
      pseudoValues[stepPre + [.fade]] = self[stepMemPre + [.fade]] ?? 0
      pseudoValues[stepPre + [.time]] = self[stepMemPre + [.time]] ?? 0
      pseudoValues[stepPre + [.level]] = self[stepMemPre + [.level]] ?? 0

      nextMem = self[stepMemPre + [.follow, .link]] ?? 0
      step += 1
    }

    pseudoValues[pre + [.step, .number]] = step
  }
  
  func seqInfo(_ seq: Int) {
    let pre: SynthPath = [.seq, .i(seq)]
    let loopStart = self[pre + [.loop, .start]]!
    let loopEnd = self[pre + [.loop, .end]]!
    debugPrint("Seq \(seq): loop: \(loopStart) -- \(loopEnd)")
    (0..<self[pre + [.step, .number]]!).forEach { step in
      let stepMem = pseudoValues[pre + [.step, .i(step), .memory]]!
      let stepPre: SynthPath = [.step, .i(stepMem)]
      let bLink = self[stepPre + [.pre, .link]]!
      let fLink = self[stepPre + [.follow, .link]]!
      let lLink = self[stepPre + [.loop, .link]]!
      debugPrint("Step \(step) (mem \(stepMem): bLink: \(bLink) fLink: \(fLink) lLink: \(lLink)")
    }
  }

    subscript(path: SynthPath) -> Int? {
      get {
        if let value = pseudoValues[path] {
          return value
        }
        
        guard let param = type(of: self).params[path] else { return nil }

        if path[0] == .seq && path[2] == .step,
          let seq = path.i(1) {
          switch path[3] {
          case .number:
            return pseudoValues[[.seq, .i(seq), .step, .number]]
          case .i(let step):
            let stepMem = pseudoValues[[.seq, .i(seq), .step, .i(step), .memory]]!
            return self[[.step, .i(stepMem), path[4]]]
          default:
            break
          }
        }
        else if path[0] == .step,
          let step = path.i(1) {
          switch path[2] {
          case .wave:
            // get wave
            var baseWave = unpack(param: param) ?? 0
            if baseWave > 32767 {
              baseWave -= 32768 // top bit of top byte is 1 for some reason?
            }
            // get coarse and look if expanded
            let coarse = unpack(param: type(of: self).params[[.step, .i(step), .coarse]]!)!
            return coarse >= 48 ? baseWave + 365 : baseWave
          case .coarse:
            let baseCoarse = unpack(param: param) ?? 0
            return baseCoarse >= 48 ? baseCoarse - 72 : baseCoarse
          default:
            break
          }
        }
        
        return unpack(param: param)
      }
      set {
        guard let newValue = newValue else { return }
        
        if path[0] == .seq && path[2] == .step {
          guard let seq = path.i(1) else { return }
          
          if let step = path.i(3),
            let stepMem = pseudoValues[[.seq, .i(seq), .step, .i(step), .memory]] {
            switch path.last! {
            case .wave, .time, .fade, .level, .coarse, .fine:
              // setting pseudo param for a specific step
              return self[[.step, .i(stepMem), path.last!]] = newValue
            default:
              break
            }
          }

          // get a bunch of values we might need
          guard let stepMem = pseudoValues[[.seq, .i(seq), .step, .i(newValue), .memory]],
            let fLink = self[[.step, .i(stepMem), .follow, .link]],
            let bLink = self[[.step, .i(stepMem), .pre, .link]],
            let lLink = self[[.step, .i(stepMem), .loop, .link]],
            let stepCount = self[[.seq, .i(seq), .step, .number]] else { return }
          let bStepMem = pseudoValues[[.seq, .i(seq), .step, .i(newValue - 1), .memory]]
          let fStepMem = pseudoValues[[.seq, .i(seq), .step, .i(newValue + 1), .memory]]
          
          switch path[3] {
          case .insert:
            // find the first empty step
            var newStepMem = -1
            for i in 0..<501 {
              // Wavestation Dev FAQ says fLink and bLink are 0xffff on empty steps
              // BUT, on my wavestation, only fLink is consistently.
              if self[[.step, .i(i), .follow, .link]] == 0xffff {
                newStepMem = i
                break
              }
            }
            
            guard newStepMem >= 0 else { return }
            
            // set its flink to me
            self[[.step, .i(newStepMem), .follow, .link]] = stepMem
            // set its blink to my blink
            self[[.step, .i(newStepMem), .pre, .link]] = bLink

            if newValue > 0,
              let bStepMem = bStepMem { // if not first step
              // set prev step's flink to new step
              self[[.step, .i(bStepMem), .follow, .link]] = newStepMem
            }
            else { // if i was first step
              // now point start to new step
              self[[.seq, .i(seq), .start, .link]] = newStepMem
            }
            
            // set my blink to new step
            self[[.step, .i(stepMem), .pre, .link]] = newStepMem

            // set default values for new step based on this step
            let preWave = self[[.step, .i(stepMem), .wave]] ?? 0
            self[[.step, .i(newStepMem), .wave]] = preWave == 0 ? 0 : preWave - 1
            self[[.step, .i(newStepMem), .time]] = self[[.step, .i(stepMem), .time]]
            self[[.step, .i(newStepMem), .fade]] = self[[.step, .i(stepMem), .fade]]
            self[[.step, .i(newStepMem), .level]] = self[[.step, .i(stepMem), .level]]
            self[[.step, .i(newStepMem), .coarse]] = self[[.step, .i(stepMem), .coarse]]
            self[[.step, .i(newStepMem), .fine]] = self[[.step, .i(stepMem), .fine]]
            
            // update pseudoValues
            updatePseudos(seq: seq)

            updateWSMod(seq: seq)
          case .dump:
            if newValue > 0,
              let bStepMem = bStepMem {
              // set fLink and lLink of prev step. also handles case where this was last step
              self[[.step, .i(bStepMem), .follow, .link]] = fLink
              self[[.step, .i(bStepMem), .loop, .link]] = lLink
            }
            
            if newValue + 1 < stepCount,
              let fStepMem = fStepMem {
              // set bLink of next step
              self[[.step, .i(fStepMem), .pre, .link]] = bLink
            }
            
            // TODO: if deleted first step, need to update .start, .link for this seq
            
            // An empty step has WS_Flink and WS_Blink set to 0xffff
            self[[.step, .i(stepMem), .follow, .link]] = 0xffff
            self[[.step, .i(stepMem), .pre, .link]] = 0xffff
            
            // update pseudoValues
            updatePseudos(seq: seq)
            
            updateWSMod(seq: seq)
          case .solo:
            break
          default:
            break
          }
          
        }
        
        // TODO: test this
        if path.suffix(from: 2) == [.mod, .start, .step],
          let seq = path.i(1) {
          self[[.seq, .i(seq), .mod, .start, .link]] = pseudoValues[[.seq, .i(seq), .step, .i(newValue), .memory]]
          updateWSMod(seq: seq)
        }

        if path.suffix(from: 2) == [.mod, .amt],
          let seq = path.i(1) {
          updateWSMod(seq: seq)
        }

        if path.suffix(from: 2) == [.loop, .start],
          let seq = path.i(1) {
          // set loop link of old loop start step to 0xffff
          let oldLoopStartMem = memoryIndex(seq: seq, path: [.loop, .start])
          self[[.step, .i(oldLoopStartMem), .loop, .link]] = 0xffff

          let stepMem = pseudoValues[[.seq, .i(seq), .step, .i(newValue), .memory]]!
          self[[.step, .i(stepMem), .loop, .link]] = 0xfffe
        }
        
        
        if path.suffix(from: 2) == [.loop, .end],
          let seq = path.i(1) {
          // set loop link of old loop end step to 0xffff
          let oldLoopEndMem = memoryIndex(seq: seq, path: [.loop, .end])
          self[[.step, .i(oldLoopEndMem), .loop, .link]] = 0xffff
          
          // set the loop link of this step in memory to the loop begin memory index
          let loopStartMem = memoryIndex(seq: seq, path: [.loop, .start])
          let stepMem = pseudoValues[[.seq, .i(seq), .step, .i(newValue), .memory]]!
          self[[.step, .i(stepMem), .loop, .link]] = loopStartMem
        }

        guard let param = type(of: self).params[path] else { return }
        pack(value: newValue, forParam: param)
      }
    }
  
  // need to update WSMod when the following change:
  // modStartStep, modAmount, step insert or delete
  private func updateWSMod(seq: Int) {
    let pre: SynthPath = [.seq, .i(seq)]
    
    let link = self[pre + [.start, .link]]!
    guard link > 0 else { return }
    
    let startstep = self[pre + [.mod, .start, .step]]!
    var modamount = self[pre + [.mod, .amt]]!
    if modamount < 0 {
      modamount = -modamount
    }
        
    /* Are we doing static or dynamic style of modulation */
    let modSrc = self[pre + [.mod, .src]]!
    guard (127 & modSrc) <= 3 else { return }
    
    var stepcount = 0
    let steptotal = pseudoValues[pre + [.step, .number]]!
    var stepMem = link
    while stepMem != 0 {
      let modInc: Int
      if modamount == 0 {
        modInc = 127
      }
      else if stepcount >= startstep {
        modInc = (8191 / modamount) * (stepcount - startstep) / (steptotal - startstep)
      }
      else {
        modInc = (8191 / modamount) * (startstep - stepcount) / startstep
      }
      self[[.step, .i(stepMem), .mod, .inc]] = min(modInc, 127)

      stepcount += 1
      stepMem = self[[.step, .i(stepMem), .follow, .link]]!
    }
  }

  
  private func memoryIndex(seq: Int, path: SynthPath) -> Int {
    let value = self[[.seq, .i(seq)] + path]!
    return pseudoValues[[.seq, .i(seq), .step, .i(value), .memory]]!
  }
  
  func sysexData(channel: Int, bank: Int) -> Data {
    var data = Data(sysexHeader(channel: channel) + [0x54, UInt8(bank)])
    let bodyData = sysexBodyData()
    data.append(bodyData)
    data.append(checksum(bodyData))
    data.append(0xf7)
    return data
  }
        
  func fileData() -> Data {
    return sysexData(channel: 0, bank: 0)
  }

  // TODO
  func randomize() {
    randomizeAllParams()
//    self[[.structure]] = (0...10).random()!
  }

  
  static let ByteCount = 0

  static let params: SynthPathParam = {
    var p = SynthPathParam()

    (0..<32).forEach {
      let pre: SynthPath = [.seq, .i($0)]
      let off = $0 * 16
      p[pre + [.start, .link]] = RangeParam(parm: 0, byte: 0 + off, extra: [ByteCount:2]) // Link
      p[pre + [.mod, .start, .link]] = RangeParam(parm: 0, byte: 2 + off, extra: [ByteCount:2]) // SLink
      p[pre + [.loop, .start]] = RangeParam(parm: 187, byte: 4 + off, displayOffset: 1)
      p[pre + [.loop, .end]] = RangeParam(parm: 188, byte: 5 + off, displayOffset: 1)
      p[pre + [.loop, .number]] = RangeParam(parm: 189, byte: 6 + off, bits: 0...6, maxVal: 127, formatter: {
        switch $0 {
        case 0: return "Off"
        case 127: return "Inf"
        default: return "\($0)"
        }
      })
      p[pre + [.loop, .direction]] = OptionsParam(parm: 338, byte: 6 + off, bit: 7, options: ["Fwd", "B/F"])
      p[pre + [.mod, .start, .step]] = RangeParam(parm: 190, byte: 7 + off, displayOffset: 1) // Start Step
      p[pre + [.mod, .src]] = OptionsParam(parm: 191, byte: 8 + off, bits: 0...6, options: WavestationSRPatchPatch.srcOptions)
      p[pre + [.mod, .amt]] = RangeParam(parm: 192, byte: 9 + off, range: -127...127)
      p[pre + [.mod, .inc]] = RangeParam(parm: 0, byte: 10 + off, extra: [ByteCount:2]) // Dyno_Mod
      p[pre + [.start, .time]] = RangeParam(parm: 0, byte: 12 + off, extra: [ByteCount:2]) // Start_Time
      p[pre + [.time]] = RangeParam(parm: 0, byte: 14 + off, extra: [ByteCount:2])
    }
    
    (0..<501).forEach {
      let pre: SynthPath = [.step, .i($0)]
      let off = 512 + $0 * 16
      p[pre + [.follow, .link]] = RangeParam(parm: 0, byte: 0 + off, extra: [ByteCount:2]) // Flink
      p[pre + [.pre, .link]] = RangeParam(parm: 0, byte: 2 + off, extra: [ByteCount:2]) // Blink
      p[pre + [.loop, .link]] = RangeParam(parm: 0, byte: 4 + off, extra: [ByteCount:2]) // Llink
      // docs say it's byte 6 and 2 bytes, but the high byte is non-zero and seems useless
      p[pre + [.wave]] = OptionsParam(parm: 180, byte: 6 + off, extra: [ByteCount:2], options: WavestationSRPatchPatch.waveOptions) // Wave_Num
      p[pre + [.coarse]] = RangeParam(parm: 182, byte: 8 + off, range: -24...24) // interplays with wave number (expanded)
      p[pre + [.fine]] = RangeParam(parm: 183, byte: 9 + off, range: -99...99)
      p[pre + [.fade]] = RangeParam(parm: 186, byte: 10 + off, extra: [ByteCount:2], maxVal: 64)
      p[pre + [.time]] = RangeParam(parm: 185, byte: 12 + off, extra: [ByteCount:2], maxVal: 499, formatter: {
        switch $0 {
        case 0: return "Gat"
        default: return "\($0)"
        }
      }) // Duration
      p[pre + [.level]] = RangeParam(parm: 184, byte: 14 + off, maxVal: 99)
      p[pre + [.mod, .inc]] = RangeParam(parm: 0, byte: 15 + off) // Mod_Index
    }
        
    return p
  }()
  
}

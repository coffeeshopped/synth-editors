
protocol MophoVoiceTypePatch : SinglePatchTemplate, VoicePatch {
  static var idByte: UInt8 { get }
  /// # of bytes in body
  static var bodyCount: Int { get }
  
  static var lfoWaveOptions: [Int:String] { get }
  static var modSrcOptions: [Int:String] { get }
  static var modDestOptions: [Int:String] { get }
  static var pushItModeOptions: [Int:String] { get }
  static var clockDivOptions: [Int:String] { get }
  static var seqTrigOptions: [Int:String] { get }
  static var arpModeOptions: [Int:String] { get }
  static var unisonModeOptions: [Int:String] { get }
  static var keyAssignOptions: [Int:String] { get }
}

extension MophoVoiceTypePatch {

  static var fileDataCount: Int { 298 }
  static var nameByteRange: CountableRange<Int>? { 184..<200 }
  static var expandedBodyCount: Int { fileDataCount - 5 }
  static var sysexHeader: [UInt8] { [0xf0, 0x01, idByte] }
  static var bodyCount: Int { return 256 }
  
  static func isValid(fileSize: Int) -> Bool {
    return [fileDataCount, fileDataCount + 2].contains(fileSize)
  }

  static func bytes(data: Data) -> [UInt8] {
    // make dependent on data count, since it can be 298 or 300 (300 is from bank)
    let start = data.count - (expandedBodyCount + 1)
    return data.unpack87(count: bodyCount, inRange: start..<(start + expandedBodyCount))
  }


  static func sysexData(_ bytes: [UInt8], headerBytes: [UInt8]) -> MidiMessage {
    let data = sysexHeader + headerBytes + bytes.pack78(count: expandedBodyCount) + [0xf7]
    return .sysex(data)
  }

  static func sysexData(_ bytes: [UInt8], bank: Int, location: Int) -> MidiMessage {
    sysexData(bytes, headerBytes: [0x02, UInt8(bank), UInt8(location)])
  }

  static func fileData(_ bytes: [UInt8]) -> [UInt8] {
    sysexData(bytes, headerBytes: [0x03]).bytes()
  }
  
  static func tamedRandomVoice() -> [SynthPath:Int] {
    return [
      [.amp, .level] : 0,
      [.volume] : 127,
      [.amp, .env, .delay] : 0,
      [.amp, .env, .amt] : 127,
    ]
  }
  
    
  static func osc() -> [ParamOptions] {
    prefix([.osc], count: 2, bx: 6, px: 5) { _ in
      inc(b: 0, p: 0) { [
        o([.semitone], max: 120, isoS: Miso.noteName(zeroNote: "C0")),
        o([.detune], max: 100, dispOff: -50),
        o([.shape], max: 103),
        o([.glide]),
        o([.keyTrk], max: 1),
      ] }
    }
    <<< prefix([.osc], count: 2, bx: 6, px: 1) { _ in
      [
        o([.sub], 5, p: 114),
      ]
    }
  }
  
  static func filter() -> [ParamOptions] {
    inc(b: 20, p: 15) {
      [
        o([.cutoff], max: 164),
        o([.reson]),
      ]
      <<< prefix([.filter]) {
        [
          o([.keyTrk]),
          o([.extAudio]),
          o([.fourPole], max: 1),
        ]
        <<< prefix([.env]) {
          [
            o([.amt], max: 254, dispOff: -127),
            o([.velo]),
            o([.delay]),
            o([.attack]),
            o([.decay]),
            o([.sustain]),
            o([.release]),
          ]
        }
      }
    }
  }
  
  static func ampEnv() -> [ParamOptions] {
    [
      o([.amp, .level], 32, p: 27),
    ]
    <<< prefix([.amp, .env]) {
      inc(b: 33, p: 30) { [
        o([.amt]),
        o([.velo]),
        o([.delay]),
        o([.attack]),
        o([.decay]),
        o([.sustain]),
        o([.release]),
      ] }
    }
  }
  
  static func lfo(b: Int) -> [ParamOptions] {
    prefix([.lfo], count: 4, bx: 5, px: 5) { _ in
      inc(b: b, p: 37) { [
        o([.freq], max: 166),
        o([.shape], opts: lfoWaveOptions),
        o([.amt]),
        o([.dest], opts: modDestOptions),
        o([.key, .sync], max: 1),
      ] }
    }
  }
  
  static func env3(b: Int, repB: Int) -> [ParamOptions] {
    prefix([.env, .i(2)]) {
      inc(b: b, p: 57) {[
        o([.dest], opts: modDestOptions),
        o([.amt], max: 254, dispOff: -127),
        o([.velo]),
        o([.delay]),
        o([.attack]),
        o([.decay]),
        o([.sustain]),
        o([.release]),
      ]}
      + [
        o([.rrepeat], repB, p: 98, max: 1),
      ]
    }
  }
  
  static func mods(b: Int) -> [ParamOptions] {
    prefix([.mod], count: 4, bx: 3, px: 3) { _ in
      inc(b: b, p: 65) {[
        o([.src], opts: modSrcOptions),
        o([.amt], max: 254, dispOff: -127),
        o([.dest], opts: modDestOptions),
      ]}
    }
  }
  
  static func ctrls(b: Int) -> [ParamOptions] {
    prefixes([[.modWheel], [.pressure], [.breath], [.velo], [.foot]], bx: 2, px: 2) { _ in
      inc(b: b, p: 81) {[
        o([.amt], max: 254, dispOff: -127),
        o([.dest], opts: modDestOptions),
      ]}
    }
  }
  
  static func pushIt(b: Int) -> [ParamOptions] {
    prefix([.pushIt]) {
      inc(b: b, p: 111) {[
        o([.note], max: 120, isoS: Miso.noteName(zeroNote: "C0")),
        o([.velo]),
        o([.mode], opts: pushItModeOptions),
      ]}
    }
  }
  
  static func tempoArpSeq(b: Int) -> [ParamOptions] {
    inc(b: b) {[
      o([.tempo], p: 91, range: 30...250),
      o([.clock, .divide], p: 92, opts: clockDivOptions),
      o([.arp, .mode], p: 97, opts: arpModeOptions),
      o([.arp, .on], p: 100, max: 1),
      o([.seq, .trigger], p: 94, opts: seqTrigOptions),
      o([.seq, .on], p: 101, max: 1),
    ]}
  }
  
  static func seqSteps() -> [ParamOptions] {
    prefix([.seq], count: 4, bx: 16, px: 16) { _ in
      prefix([.step], count: 16, bx: 1, px: 1) { _ in
        [
          o([], 120, p: 120),
        ]
      }
    }
  }
  
  static func unison(b: Int) -> [ParamOptions] {
    inc(b: b) {[
      o([.unison, .mode], p: 95, opts: unisonModeOptions), // NEW
      o([.keyAssign], p: 96, opts: keyAssignOptions),
      o([.unison], p: 99, max: 1), // NEW
    ]}

  }
}


struct TG77Chorus {
  
  static func options(_ values: [String]) -> OptionsParam {
    return OptionsParam(options: OptionsParam.makeOptions(values))
  }

  static let percParam = RangeParam(range: 0...100)
  
  static let modFreqParam = options(
    (0...99).map { String(format: "%.1f Hz", Float($0+1) * 0.2) }
  )
  
  static let delayParam = options(
    (0...74).map { String(format: "%.1f ms", Float($0+1) * 0.2) }
  )

  static let chorusParams: [Int:(String,Param)] = [
    0 : ("Mod Freq", modFreqParam),
    1 : ("Pitch Mod", percParam),
    2 : ("Amp Mod", percParam),
    ]

  static let flangeParams: [Int:(String,Param)] = [
    0 : ("Mod Freq", modFreqParam),
    1 : ("Mod Depth", percParam),
    2 : ("Delay", delayParam),
    3 : ("Feedback", RangeParam(range: 0...99)),
    ]
  
  static let symphParams: [Int:(String,Param)] = [
    0 : ("Mod Freq", modFreqParam),
    1 : ("Mod Depth", percParam),
    ]
  
  static let tremoloParams: [Int:(String,Param)] = [
    0 : ("Mod Freq", modFreqParam),
    1 : ("Mod Depth", percParam),
    2 : ("Phase", RangeParam(range: 0...16, displayOffset: -8)),
    ]
  
  static let paramMap: [[Int:(String,Param)]] = [
    [:],
    chorusParams,
    flangeParams,
    symphParams,
    tremoloParams,
    ]
  
}

struct TG77Reverb {
  
  static func options(_ values: [String]) -> OptionsParam {
    return OptionsParam(options: OptionsParam.makeOptions(values))
  }
  
  static let percParam = RangeParam(range: 0...100)
  static let fbParam = RangeParam(range: 0...99)
  static let gainParam = RangeParam(range: 0...24, displayOffset: -12)
  
  static let rev10Param = options({
    var options = (0..<17).map { String(format: "%.1f s", 0.3 + Float($0) * 0.1) }
    options += (17..<27).map { String(format: "%.1f s", 2 + Float($0-17) * 0.2) }
    options += (27..<33).map { String(format: "%.1f s", 4 + Float($0-27) * 0.5) }
    options += (33..<37).map { String(format: "%.1f s", 7 + Float($0-33)) }
    return options
    }())
  
  static let delay300Param = options(
    ["0.1 ms"] + (1...75).map { "\($0 * 4) ms" }
    )

  static let delay152Param = options(
    ["0.1 ms"] + (1...38).map { "\($0 * 4) ms" }
    )
  
  static let delay50Param = options(
    ["0.1 ms"] + (1...100).map { String(format: "%.1f ms", Float($0) * 0.5) }
    )
    
  static let delay80Param = options(
    ["0.1 ms"] + (1...20).map { "\($0 * 4) ms" }
    )

  static let roomSizeParam = options(
    (0...27).map { String(format: "%.1f ms", 0.5 + Float($0) * 0.1) }
  )

  static let brillParam = RangeParam(range: 0...12)
  
  static let lpfParam = options(
    [1.25, 1.6, 2.0, 2.5, 3.15, 4, 5, 6, 7, 8, 9, 10, 11, 12].map { "\($0) kHz" } + ["Thru"]
  )

  static let hpfParam = options(
    ["Thru"] + [160, 250, 315, 400, 500, 630, 800, 1000].map { "\($0) Hz" }
  )

  static let reverbParams: [Int:(String,Param)] = [
    0 : ("Time", rev10Param),
    1 : ("LPF", lpfParam),
    2 : ("Init Delay", delay50Param),
    ]
  
  static let delay1Params: [Int:(String,Param)] = [
    0 : ("Time", delay300Param),
    1 : ("FB Time", delay300Param),
    2 : ("Feedback", fbParam),
    ]
  
  static let delayLRParams: [Int:(String,Param)] = [
    0 : ("L Delay", delay300Param),
    1 : ("R Delay", delay300Param),
    2 : ("Feedback", fbParam),
    ]
  
  static let echoParams: [Int:(String,Param)] = [
    0 : ("L Delay", delay152Param),
    1 : ("R Delay", delay152Param),
    2 : ("Feedback", fbParam),
    ]
  
  static let doubler1Params: [Int:(String,Param)] = [
    0 : ("Delay", delay50Param),
    1 : ("HPF", hpfParam),
    2 : ("LPF", lpfParam),
    ]
  
  static let doubler2Params: [Int:(String,Param)] = [
    0 : ("L Delay", delay50Param),
    1 : ("R Delay", delay50Param),
    2 : ("LPF", lpfParam),
    ]
  
  static let pingPongParams: [Int:(String,Param)] = [
    0 : ("Delay", delay152Param),
    1 : ("Pre-Delay", delay80Param),
    2 : ("Feedback", fbParam),
    ]
  
  static let panReflectParams: [Int:(String,Param)] = [
    0 : ("Room Size", roomSizeParam),
    1 : ("Feedback", fbParam),
    2 : ("Direction", options(["L->R","R->L"])),
    ]
  
  static let earlyReflectParams: [Int:(String,Param)] = [
    0 : ("Room Size", roomSizeParam),
    1 : ("LPF", lpfParam),
    2 : ("Init Delay", delay50Param),
    ]
  
  static let fbEarlyReflectParams: [Int:(String,Param)] = [
    0 : ("Room Size", roomSizeParam),
    1 : ("LPF", lpfParam),
    2 : ("Feedback", fbParam),
    ]
  
  static let delay1RevParams: [Int:(String,Param)] = [
    0 : ("Reverb", rev10Param),
    1 : ("Delay", delay152Param),
    2 : ("Feedback", fbParam),
    ]
  
  static let delayLRRevParams: [Int:(String,Param)] = [
    0 : ("Reverb", rev10Param),
    1 : ("L Delay", delay152Param),
    2 : ("R Delay", delay152Param),
    ]
  
  static let tunnelParams: [Int:(String,Param)] = [
    0 : ("Reverb", rev10Param),
    1 : ("Delay", delay152Param),
    2 : ("Feedback", fbParam),
    ]
  
  static let tone1Params: [Int:(String,Param)] = [
    0 : ("Low", gainParam),
    1 : ("Mid", gainParam),
    2 : ("High", gainParam),
    ]
  
  static let delayTone1Params: [Int:(String,Param)] = [
    0 : ("Brilliance", brillParam),
    1 : ("Delay", delay300Param),
    2 : ("Feedback", fbParam),
    ]
  
  static let tone2Params: [Int:(String,Param)] = [
    0 : ("HPF", hpfParam),
    1 : ("Mid", gainParam),
    2 : ("LPF", lpfParam),
    ]
  
  static let delayTone2Params: [Int:(String,Param)] = [
    0 : ("Brilliance", brillParam),
    1 : ("Delay", delay300Param),
    2 : ("Feedback", fbParam),
    ]
  
  static let distRevParams: [Int:(String,Param)] = [
    0 : ("Reverb", rev10Param),
    1 : ("Distortion", percParam),
    2 : ("Balance", percParam),
    ]
  
  static let distDelayParams: [Int:(String,Param)] = [
    0 : ("Delay", delay300Param),
    1 : ("Feedback", fbParam),
    2 : ("Distortion", percParam),
    ]
  
  static let distParams: [Int:(String,Param)] = [
    0 : ("Distortion", percParam),
    1 : ("HPF", hpfParam),
    2 : ("LPF", lpfParam),
    ]
  
  static let indDelayParams: [Int:(String,Param)] = [
    0 : ("L Delay", delay152Param),
    1 : ("R Delay", delay152Param),
    2 : ("Feedback", fbParam),
    ]
  
  static let indToneParams: [Int:(String,Param)] = [
    0 : ("L Brill", brillParam),
    1 : ("R Brill", brillParam),
    2 : ("Mid", gainParam),
    ]
  
  static let indDistParams: [Int:(String,Param)] = [
    0 : ("L Dist", percParam),
    1 : ("R Dist", percParam),
    2 : ("LPF", lpfParam),
    ]
  
  static let indRevParams: [Int:(String,Param)] = [
    0 : ("L Reverb", rev10Param),
    1 : ("R Reverb", rev10Param),
    2 : ("High Ctrl", options(
      (0...9).map { "\(0.1 + Float($0) * 0.1) ms" }
    )),
    ]
  
  static let indDelayRevParams: [Int:(String,Param)] = [
    0 : ("L Delay", delay152Param),
    1 : ("L Feedback", fbParam),
    2 : ("R Reverb", rev10Param),
    ]
  
  static let indRevDelayParams: [Int:(String,Param)] = [
    0 : ("L Reverb", rev10Param),
    1 : ("R Delay", delay152Param),
    2 : ("R Feedback", fbParam),
    ]
  
  static let paramMap: [[Int:(String,Param)]] = [
    [:],
    reverbParams, // 1
    reverbParams, // 2
    reverbParams, // 3
    reverbParams, // 4
    reverbParams, // 5
    reverbParams, // 6
    reverbParams, // 7
    reverbParams, // 8
    delay1Params, // 9
    delayLRParams, // 10
    echoParams, // 11
    doubler1Params, // 12
    doubler2Params, // 13
    pingPongParams, // 14
    panReflectParams, // 15
    earlyReflectParams, // 16
    earlyReflectParams, // 17
    earlyReflectParams, // 18
    fbEarlyReflectParams, // 19
    fbEarlyReflectParams, // 20
    fbEarlyReflectParams, // 21
    delay1RevParams, // 22
    delayLRRevParams, // 23
    tunnelParams, // 24
    tone1Params, // 25
    delayTone1Params, // 26
    delayTone1Params, // 27
    tone2Params, // 28
    delayTone2Params, // 29
    delayTone2Params, // 30
    distRevParams, // 31
    distDelayParams, // 32
    distDelayParams, // 33
    distParams, // 34
    indDelayParams, // 35
    indToneParams, // 36
    indDistParams, // 37
    indRevParams, // 38
    indDelayRevParams, // 39
    indRevDelayParams, // 40
  ]

}

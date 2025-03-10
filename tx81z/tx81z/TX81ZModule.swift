
extension TX81Z {
  
  public enum Module {
          
    public static let truss = BasicModuleTruss(Editor.truss, manu: Manufacturer.yamaha, model: "TX81Z", subid: "tx81z", sections: sections, dirMap: directoryMap, colorGuide: colorGuide)
    
    static let colorGuide = ColorGuide([
      "#a2cd50",
      "#f93d31",
      "#00d053",
    ])
    
    static let sections: [ModuleTrussSection] = [
      .first([
        .channel(),
        .voice("Voice", Voice.Controller.controller),
        .perf(Perf.Controller.controller(Perf.presetVoices)),
        .voice("Micro Oct", path: [.micro, .octave], Op4.Micro.Controller.octController),
        .voice("Micro Full", path: [.micro, .key], Op4.Micro.Controller.fullController),
        ]),
      .banks([
        .bank("Voice Bank", [.bank]),
        .bank("Perf Bank", [.bank, .perf]),
      ]),
      .backup,
      ]
        
    static let directoryMap: [SynthPath:String] = [
      [.bank] : "Voice Bank",
      [.micro, .octave] : "Micro Octave*",
      [.micro, .key] : "Micro Full*",
      [.bank, .perf] : "Perf Bank",
    ]

  }
}

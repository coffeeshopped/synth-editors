
extension DX11 {
  
  public enum Module {
    
    public static let truss = BasicModuleTruss(Editor.truss, manu: Manufacturer.yamaha, model: "DX11", subid: "dx11", sections: sections, dirMap: TX81Z.Module.directoryMap, colorGuide: colorGuide)
    
    static let colorGuide = ColorGuide([
      "#ca5e07",
      "#07afca",
      "#fa925f",
    ])
        
    static let sections: [ModuleTrussSection] = [
      .first([
        .channel(),
        .voice("Voice", Voice.Controller.controller),
        .perf(TX81Z.Perf.Controller.controller(Perf.presetVoices)),
        .voice("Micro Oct", path: [.micro, .octave], Op4.Micro.Controller.octController),
        .voice("Micro Full", path: [.micro, .key], Op4.Micro.Controller.fullController),
        ]),
      .banks([
        .bank("Voice Bank", [.bank]),
        .bank("Perf Bank", [.bank, .perf]),
      ]),
      .backup,
      ]
    
  }
}

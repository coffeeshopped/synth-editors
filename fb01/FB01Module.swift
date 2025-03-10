
extension FB01 {
  
  public enum Module {
    
    public static let truss = BasicModuleTruss(Editor.truss, manu: Manufacturer.yamaha, model: "FB-01", subid: "fb01", sections: sections, dirMap: directoryMap, colorGuide: colorGuide)
    
    static let colorGuide = ColorGuide([
      "#10ed7d",
      "#ff260f",
      "#8afc38",
    ])
    
    static let sections: [ModuleTrussSection] = [
      .first([
        .channel(),
        .perf(Perf.Controller.controller),
        ]),
      .basic("Voices", .perfParts(8, { "Instrument \($0 + 1)" }, Voice.Controller.controller)),
      .banks([
        .bank("Voice Bank 1", [.bank, .i(0)]),
        .bank("Voice Bank 2", [.bank, .i(1)]),
        .bank("Perf Bank", [.bank, .perf]),
      ]),
      ]
        
    static let directoryMap: [SynthPath:String] = [
      [.part] : "Patch",
      [.bank] : "Patch Bank",
      [.bank, .perf] : "Perf Bank",
    ]
    
  }
}

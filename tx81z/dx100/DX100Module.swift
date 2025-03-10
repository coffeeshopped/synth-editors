
extension DX100 {
  
  public enum Module {
          
    public static let truss = BasicModuleTruss(Editor.truss, manu: Manufacturer.yamaha, model: "DX100", subid: "dx100", sections: sections, dirMap: TX81Z.Module.directoryMap, colorGuide: colorGuide)
    
    static let colorGuide = ColorGuide([
      "#ca5e07",
      "#07afca",
      "#fa925f",
    ])
    
    static let sections: [ModuleTrussSection] = [
      .first([
        .channel(),
        .voice("Voice", Voice.Controller.controller),
        ]),
      .banks([
        .bank("Voice Bank", [.bank]),
      ]),
    ]
    
  }
}


extension Blofeld {

  public enum Module {
          
    public static let truss = BasicModuleTruss(Editor.truss, manu: .waldorf, model: "Blofeld", subid: Blofeld.displayId, sections: sections, dirMap: directoryMap, colorGuide: colorGuide)
    
    static let colorGuide = ColorGuide([
      "#3975d7",
      "#e49031",
      "#e43190",
      "#34f190",
    ])
        
    static let sections: [ModuleTrussSection] = [
      .first([
        .global(Global.Controller.ctrlr),
        .voice("Temp Voice", path: [.voice], Voice.ctrlr),
        ]),
      .basic("Multi Mode", [
        .fullRef(title: "Full Multi"),
        .perf(title: "Multi", MultiMode.Controller.ctrlr),
      ] +
        .perfParts(16, { "Part \($0 + 1)" }, Voice.ctrlr)
      ),
      .banks(
        .banks(8, { "Bank \(Voice.bankLetter($0))" }, [.bank]) + [
        .bank("Multi Bank", [.perf, .bank]),
        ]),
      .backup,
      ]
    
    
    static let directoryMap: [SynthPath:String] = [
      [.perf] : "MultiMode*",
      [.perf, .bank] : "Multi Bank",
      [.part] : "Patch",
      [.bank] : "Voice Bank",
    ]
          
  }

}

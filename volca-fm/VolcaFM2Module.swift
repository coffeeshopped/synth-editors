
//extension VolcaFM2 {
//
//  public enum Module {
//
//    public static let truss = BasicModuleTruss(Editor.truss, manu: .korg, model: "Volca FM2", subid: "volcafm2", sections: sections, dirMap: directoryMap, colorGuide: colorGuide)
//    
//    static let colorGuide = ColorGuide([
//      "#6fadd6",
//      "#d0a76c",
//      "#3b44bb",
//      "#eb0f32",
//      ])
//
//    static let sections: [ModuleTrussSection] = [
//      .first([
//        .global(GlobalController.ctrlr),
//        .voice("Voice", VoiceController.ctrlr),
//        .custom("Sequence", [.perf], Sequence.Controller.controller()),
//        .fullRef(),
//        ]),
//      .banks([
//        .bank("Voice Bank", [.bank]),
//        .bank("Seq Bank", [.perf, .bank]),
//        ]),
//      .backup,
//    ]
//    
//    static let directoryMap: [SynthPath:String] = [
//      [.perf] : "Sequence",
//      [.bank] : "Voice Bank",
//    ]
//
//    
//  }
//
//
//}

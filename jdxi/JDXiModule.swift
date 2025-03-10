
extension JDXi {
  
  public enum Module {
    
    public static let truss = BasicModuleTruss(Editor.truss, manu: Manufacturer.roland, model: "JD-Xi", subid: "jdxi", sections: sections, dirMap: directoryMap, colorGuide: colorGuide, indexPath: IndexPath(item: 0, section: 1))
    
    static let colorGuide = ColorGuide([
      "#00c76f",
      "#f23518",
      "#1868f2",
      "#abe817",
      ])

    static let sections: [ModuleTrussSection] = [
      .first([
        .global(Global.Controller.controller),
        .perf(title: "Program", Program.Controller.controller),
        .fullRef(title: "Full Program"),
        ]),
      .basic("Parts", [
        .voice("Digital 1", path: [.digital, .i(0)], Digital.Controller.controller),
        .voice("Digital 2", path: [.digital, .i(1)], Digital.Controller.controller),
        .voice("Analog", path: [.analog], Analog.Controller.controller),
        .custom("Drums", [.rhythm], Drum.Controller.controller),
        ]),
      .banks(
        .banks(2, { "Prgm Bank \($0 + 1)" }, [.bank, .perf]) +
        .banks(4, { "Digital Bank \($0 + 1)" }, [.bank, .digital]) +
        .banks(2, { "Analog Bank \($0 + 1)" }, [.bank, .analog]) +
        .banks(2, { "Drum Bank \($0 + 1)" }, [.bank, .rhythm])
      ),
      .backup,
    ]

    static let directoryMap: [SynthPath:String] = [
      [.digital] : "Digital*",
      [.analog] : "Analog*",
      [.perf] : "Program",
      [.rhythm] : "Drum",
      [.rhythm, .partial] : "Drum Partial"
    ]
  }
  
}


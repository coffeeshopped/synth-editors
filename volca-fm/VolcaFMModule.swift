
//public class VolcaFMModule : DX7Module {
//  
//  override public class var manufacturer: String { "Korg" }
//  override public class var model: String { "Volca FM" }
//  override public class var productId: String { "k".o.r.g.dot.v.o.l.c.a.f.m }
//  
//  private static let _colorGuide = ColorGuide(colors: [
//    PBColor(hexString: "#6fadd6"),
//    PBColor(hexString: "#d0a76c"),
//    PBColor(hexString: "#fb948b")
//    ])
//  override public class var colorGuide: ColorGuide { _colorGuide }
//
//  override public func initEditor() {
//    synthEditor = VolcaFMEditor(baseURL: tempURL)
//  }
//
//  override public func path(forSysexType sysexType: Sysexible.Type) -> String? {
//    switch sysexType {
//    case is VolcaFMPatch.Type:
//      return "Patches"
//    case is VolcaFMVoiceBank.Type:
//      return "Voice Banks"
//    default:
//      return super.path(forSysexType: sysexType)
//    }
//  }
//  
//  public override func filteredToolbarIdentifiers(forIndexPath indexPath: IndexPath) -> [String] {
//    defaultFilteredToolbarIdentifiers(forIndexPath: indexPath) + ["fetch"]
//  }
//
//}

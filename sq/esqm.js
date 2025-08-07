
public class ESQMModule : ESQ1Module {

  override public class var model: String { "ESQ-M" }
  override public class var productId: String { "e".n.s.o.n.i.q.dot.e.s.q.m }
  
  override func initEditor() {
    synthEditor = ESQMEditor(baseURL: tempURL)
  }

}

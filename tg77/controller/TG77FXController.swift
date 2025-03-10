
class TG77FXController : NewPatchEditorController {
  
  fileprivate let typeSelect = PBSelect(label: "")
  fileprivate let balance = PBKnob(label: "Balance")
  fileprivate let out = PBKnob(label: "Out Level")
  
  func addTypeBlock(params: [PBKnob], paramMap: [[Int:(String, Param)]]) {
    addPatchChangeBlock(path: [.type]) { [weak self] in
      let info = paramMap[$0]
      let hidden = info.count == 0
      self?.balance.isHidden = hidden
      self?.out.isHidden = hidden

      params.enumerated().forEach { (i, ctrl) in
        guard let pair = info[i] else { return ctrl.isHidden = true }
        ctrl.label = pair.0
        self?.defaultConfigure(control: ctrl, forParam: pair.1)
        ctrl.isHidden = false
      }
    }
  }
  
}

class TG77ChorusController : TG77FXController {
  
  override var index: Int {
    didSet { typeSelect.label = "Chorus \(index + 1)" }
  }
  
  override var prefix: SynthPath? { return [.fx, .chorus, .i(index)] }

  override func loadView(_ view: PBView) {
    let params = (0..<4).map { PBKnob(label: "\($0+1)") }
    
    grid(view: view, items: [[
      (typeSelect, [.type]),
      (balance, [.balance]),
      (out, [.level]),
      (params[0], [.param, .i(0)]),
      (params[1], [.param, .i(1)]),
      (params[2], [.param, .i(2)]),
      (params[3], [.param, .i(3)]),
      ]])
    
    addTypeBlock(params: params, paramMap: TG77Chorus.paramMap)
    addColor(view: view)
  }
}

class TG77ReverbController : TG77FXController {
  
  override var index: Int {
    didSet { typeSelect.label = "Reverb \(index + 1)" }
  }
  
  override var prefix: SynthPath? { return [.fx, .reverb, .i(index)] }

  override func loadView(_ view: PBView) {
    let params = (0..<3).map { PBKnob(label: "\($0+1)") }
    
    grid(view: view, items: [[
      (typeSelect, [.type]),
      (balance, [.balance]),
      (out, [.level]),
      (params[0], [.param, .i(0)]),
      (params[1], [.param, .i(1)]),
      (params[2], [.param, .i(2)]),
      ]])
    
    addTypeBlock(params: params, paramMap: TG77Reverb.paramMap)
    addColor(view: view)
  }
}

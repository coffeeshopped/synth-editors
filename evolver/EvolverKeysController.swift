
public class EvolverKeysController : BasicKeysViewController {
  
  override public class func defaultInstance() -> BasicKeysViewController {
    return EvolverKeysController()
  }
  
  @IBOutlet var startStopButton: PBButton!
  
  public override func loadView() {
    let view = PBLayerView()
    
    view.backgroundColor = bgColor
    
    initControls(view)
    
    startStopButton = PBButton()
    startStopButton.title = "▶️"
    #if os(iOS)
    startStopButton.titleLabel?.font = PBFont.systemFont(ofSize: 31)
    #else
    startStopButton.bezelStyle = .roundRect
    startStopButton.isBordered = false
    startStopButton.font = PBFont.systemFont(ofSize: 31)
    #endif
    startStopButton.addClickTarget(self, action: #selector(startStopTap(_:)))
    view.addSubview(startStopButton)
    startStopButton.setContentHuggingPriority(.init(rawValue: 1), for: .vertical)
    startStopButton.setContentHuggingPriority(.init(rawValue: 1), for: .horizontal)
    layout.addView(startStopButton, forLayoutKey: "start")
  
    layout.addConstraints(withVisualFormat: "|-4-[start(44)]-[oct(60)]-[velo(==start)]-[keys(>=60)]-[panic(44)]-4-|", options: [.alignAllTop, .alignAllBottom])
    layout.addConstraints(withVisualFormat: "V:|-<=4-[oct]-<=4-|", options: [])
    layout.activateConstraints()
    
    self.view = view
  }

  @IBAction func startStopTap(_ sender: PBButton) {
    transmitter?.send(bytes: [0xf0, 0x01, 0x20, 0x01, 0x12, 0xf7])
  }
  
}

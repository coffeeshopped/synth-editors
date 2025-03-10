
class WavestationSRWaveSeqBankStepController : NewPatchEditorController, PBCollectionViewDelegate, PBCollectionViewDataSource, PBCollectionViewDelegateFlowLayout, NSDraggingDestination {


  @IBOutlet var myView: NSView!
  @IBOutlet var collectionView: NSCollectionView!
  
  open override func loadView() {
    let nib = NSNib(nibNamed: "WaveSeqStepEditor", bundle: Bundle(for: type(of: self)))
    nib?.instantiate(withOwner: self, topLevelObjects: nil)
    
    addPatchChangeBlock { [weak self] (changes) in
      if let count = Self.updatedValue(path: [.step, .number], state: changes) {
        self?.itemCount = count
        self?.collectionView.reloadData()
      }

      if let deletedIndex = Self.updatedValue(path: [.step, .dump], state: changes) {
        self?.itemCount -= 1
        self?.collectionView.animator().deleteItems(at: [IndexPath(item: deletedIndex, section: 0)])
        self?.updateCells(startingAt: deletedIndex)
      }
      
      if let insertedIndex = Self.updatedValue(path: [.step, .insert], state: changes) {
        self?.itemCount += 1
        self?.collectionView.animator().insertItems(at: [IndexPath(item: insertedIndex, section: 0)])
        self?.updateCells(startingAt: insertedIndex + 1)
      }

      guard let itemCount = self?.itemCount,
        let self = self else { return }
      (0..<itemCount).forEach { step in
        guard let cell = self.collectionView.cellForItem(at: IndexPath(item: step, section: 0)) as? WavestationSRWaveSeqViewCell else { return }
        cell.update(source: self, changes: changes)
      }
    }
    
//    layout.activateConstraints()
    self.view = myView
  }

  public override func viewDidLoad() {
    super.viewDidLoad()
    collectionView.register(WavestationSRWaveSeqViewCell.self, forItemWithIdentifier: NSUserInterfaceItemIdentifier("cell"))
    collectionView.delegate = self
    collectionView.dataSource = self
  }
  
  private var tintColor = PBColor.blue
  private var valueBackground = PBColor.red
  private var secondaryBackground = PBColor.green
  private var textColor = PBColor.purple
  
//  override func apply(colorGuide: ColorGuide) {
//    collectionView.backgroundColors = [Self.backgroundColor(forColorGuide: colorGuide)]
//    tintColor = Self.tintColor(forColorGuide: colorGuide)
//    valueBackground = Self.tertiaryBackgroundColor(forColorGuide: colorGuide)
//    secondaryBackground = Self.secondaryBackgroundColor(forColorGuide: colorGuide)
//    textColor = Self.textColor(forColorGuide: colorGuide)
//    
//    collectionView.reloadData()
//  }
  
  private func updateCells(startingAt index: Int) {
    (index..<itemCount).forEach { step in
      guard let cell = collectionView.item(at: IndexPath(item: step, section: 0)) as? WavestationSRWaveSeqViewCell else { return }
      cell.update(index: step, source: self)
    }
  }
  
  public func collectionView(_ collectionView: PBCollectionView, numberOfItemsInSection section: Int) -> Int {
    return itemCount
  }
  
  private var itemCount = 0
  
  public func collectionView(_ collectionView: PBCollectionView, cellForItemAt indexPath: IndexPath) -> PBCollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! WavestationSRWaveSeqViewCell
    
    cell.stepController = self
    cell.update(index: indexPath.item, source: self)
    cell.updateColors(value: tintColor, valueBackground: valueBackground, background: secondaryBackground, label: textColor)

    return cell
  }
  
  public func collectionView(_ colView: PBCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> PBCollectionViewCell {
    return collectionView(colView, cellForItemAt: indexPath)
  }
  
  public func collectionView(_ collectionView: NSCollectionView, willDisplay item: NSCollectionViewItem, forRepresentedObjectAt indexPath: IndexPath) {
    guard let item = item as? WavestationSRWaveSeqViewCell else { return }
    
    item.updateColors(value: tintColor, valueBackground: valueBackground, background: secondaryBackground, label: textColor)
  }
  
}

class WavestationSRWaveSeqViewCell : PBCollectionViewCell {
  
  var index = 0 {
    didSet { wave.label = "Step \(index + 1)" }
  }
  
  fileprivate weak var stepController: WavestationSRWaveSeqBankStepController?

  private let layout = ShorthandLayout()
  private let wave = PBSelect(label: "Wave")
  private let dur = PBKnob(label: "Dur")
  private let xfad = PBKnob(label: "XFad")
  private let level = PBKnob(label: "Level")
  private let semi = PBKnob(label: "Semi")
  private let fine = PBKnob(label: "Fine")
  private var menuButton: PBButton!
  
  private var ctrlMap = [PBLabeledControl:SynthPathItem]()
  
  private static let stepMenu: NSMenu = {
    let menu = NSMenu()
    menu.addItem(withTitle: "Insert Before", action: #selector(insert(_:)), keyEquivalent: "")
    menu.addItem(withTitle: "Delete", action: #selector(delete(_:)), keyEquivalent: "")
    menu.addItem(withTitle: "Solo", action: #selector(solo(_:)), keyEquivalent: "")
    return menu
  }()
  
  override func loadView() {
    let view = PBLayerView(frame: CGRect(x: 0, y: 0, width: 200, height: 60))
    
    #if os(iOS)
    menuButton = PBButton(type: .custom)
    menuButton.setTitle(title, for: .normal)
    #else
    menuButton = PBButton()
    if menuButton.font != nil {
      menuButton.font = PBFont.systemFont(ofSize: 15)
    }
    menuButton.bezelStyle = .roundRect
    menuButton.isBordered = false
    menuButton.title = "Step"
    #endif
    menuButton.addClickTarget(self, action: #selector(showMenu(_:)))

    wave.wantsGridWidth = 4
    layout.quickGrid(view: view, pinMargin: "-s1-", itemsAndHeights: [
      (row: [
        (wave, [.wave], nil),
        (dur, [.time], nil),
        (xfad, [.fade], nil),
        (level, [.level], nil),
        (semi, [.coarse], nil),
        (fine, [.fine], nil),
        (menuButton, nil, "menu")
      ], height: 1)
    ])
    layout.activateConstraints()
    
    wave.options = WavestationSRPatchPatch.waveOptions
    let params = WavestationSRWaveSeqBank.params
    
    ctrlMap = [
      wave : .wave,
      dur : .time,
      xfad : .fade,
      level : .level,
      semi : .coarse,
      fine : .fine,
    ]
    ctrlMap.forEach { (ctrl, pathItem) in
//      BaseSysexEditorViewController.configure(control: ctrl, forParam: params[[.step, .i(0), pathItem]]!)
      ctrl.addValueChangeTarget(self, action: #selector(controlChange(_:)))
    }

    self.view = view
  }
  
  @objc func controlChange(_ sender: PBLabeledControl) {
    guard let pathItem = ctrlMap[sender] else { return }
    stepController?.pushPatchChange(.paramsChange([[.step, .i(index), pathItem] : sender.value]))
  }
  
  @objc func showMenu(_ sender: Any) {
    if let event = NSApplication.shared.currentEvent {
      NSMenu.popUpContextMenu(type(of: self).stepMenu, with: event, for: menuButton)
    }
  }
  
  @objc func insert(_ sender: Any) {
    stepController?.pushPatchChange(.paramsChange([[.step, .insert] : index]))
  }
  
  @objc func delete(_ sender: Any) {
    stepController?.pushPatchChange(.paramsChange([[.step, .dump] : index]))
  }
  
  @objc func solo(_ sender: Any) {
    stepController?.pushPatchChange(.paramsChange([[.step, .solo] : index]))
  }
  
  func updateColors(value: PBColor, valueBackground: PBColor, background: PBColor, label: PBColor) {
    backgroundColor = background
    view.cornerRadius = 4
    view.clipsToBounds = true

    ctrlMap.keys.forEach {
      $0.valueColor = value
      $0.valueBackgroundColor = valueBackground
      $0.backgroundColor = background
      $0.labelColor = label
    }

    if let menuButton = menuButton {
      #if os(OSX)
      let colorTitle = NSMutableAttributedString(attributedString: menuButton.attributedTitle)
      let titleRange = NSRange(location: 0, length: colorTitle.length)
      colorTitle.addAttribute(.foregroundColor, value: value, range: titleRange)
      menuButton.attributedTitle = colorTitle

      #elseif os(iOS)
      menuButton.setTitleColor(value, for: .normal)
      #endif
    }
  }
  
  func update(index: Int, source: NewPatchEditorController) {
    self.index = index

    ctrlMap.forEach { (ctrl, pathItem) in
      guard let value = source.latestValue(path: [.step, .i(index), pathItem]) else { return }
      ctrl.value = value
    }
  }
  
  func update(source: NewPatchEditorController, changes: PatchControllerChanges) {
    ctrlMap.forEach { (ctrl, pathItem) in
      guard let value = NewPatchEditorController.updatedValue(path: [.step, .i(index), pathItem], state: changes) else { return }
      ctrl.value = value
    }
  }
  
}

class WavestationSRWaveSeqFlowLayout : NSCollectionViewFlowLayout {
    
  override init() {
    super.init()
    initLayout()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    initLayout()
  }
  
  private func initLayout() {
    sectionInset = PBEdgeInsets(top: 0, left: 25, bottom: 0, right: 25)
    itemSize = CGSize(width: minCellWidth, height: cellHeight)
    minimumInteritemSpacing = 5
    minimumLineSpacing = 5
  }
  
  private let minCellWidth: CGFloat = 300
  private let cellHeight: CGFloat = 60
  
  override func shouldInvalidateLayout(forBoundsChange newBounds: NSRect) -> Bool {
    return true
  }
  
  override func prepare() {
    super.prepare()
    
    guard let view = collectionView else { return }
    let availableWidth = view.frame.width - (sectionInset.left + sectionInset.right)
    let columns = floor(availableWidth / minCellWidth)
    guard columns > 0 else { return }
    let cellWidth = CGFloat(floor((availableWidth - minimumInteritemSpacing * (columns - 1)) / columns))
    if cellWidth != itemSize.width {
      itemSize = CGSize(width: cellWidth, height: cellHeight)
    }
  }
  
}

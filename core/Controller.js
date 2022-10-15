
function ctrlr(subFn, ...args) {
  return Controller.activated(vc => { subFn(vc, ...args) })
}

function pageCtrlr(subFn, ...args) {
  return PageController.activated(vc => { subFn(vc, ...args) })
}

exports.ctrlr = ctrlr
exports.pageCtrlr = pageCtrlr
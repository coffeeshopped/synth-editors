
function ctrlr(subFn, ...args) {
  return Controller.activated(vc => { subFn(vc, ...args) })
}

function pageCtrlr(subFn, ...args) {
  return PageController.activated(vc => { subFn(vc, ...args) })
}

function bankCtrlr() {
  return BankController.controller()
}

function backupCtrlr() {
  return BackupController.controller()
}



exports.ctrlr = ctrlr
exports.pageCtrlr = pageCtrlr
exports.bankCtrlr = bankCtrlr
exports.backupCtrlr = backupCtrlr
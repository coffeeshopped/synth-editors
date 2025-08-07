const ESQ1Editor = require('./esq1_editor.js')
const Voice = require('./sq80_patch.js')

const editor = ESQ1Editor.editor
editor.trussMap = [
  ["global", 'channel'],
  ["patch", Voice.patchTruss],
  ["bank", Voice.bankTruss],
]

module.exports = {
  editor,
}
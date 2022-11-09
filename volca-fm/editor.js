require('/core/NumberUtils.js')
require('/core/ArrayUtils.js')
const DX7VoicePatch = require('/dx7/patch/voice.js')
const DX7VoiceBank = require('/dx7/patch/voiceBank.js')

function channel(editor) {
  return editor.patch(["global"])?.get(["channel"]) ?? 0
}

const dx7Editor = require('/dx7/editor.js')

module.exports = {
  sysexMap: dx7Editor.sysexMap,
  
  fetchCommands: () => null, // no fetch

  midiChannel: dx7Editor.midiChannel,
  
  midiOuts: editor => [
    {
      path: ["patch"],
      outType: "wholePatch",
      throttle: 400,
      patchTransform: bytes => [[["sx", DX7VoicePatch.sysexData(bytes, channel(editor))], 0]],
    },
    {
      path: ["bank"],
      outType: "wholeBank",
      bankTransform: bytesArray => [["sx", [DX7VoiceBank.sysexData(bytesArray, channel(editor))], 0]],
    },
  ],

  bankInfo: dx7Editor.bankInfo,
}


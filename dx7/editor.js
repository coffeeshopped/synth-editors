require('/core/NumberUtils.js')
require('/core/ArrayUtils.js')
const DX7VoicePatch = require('patch/voice.js')

class RxMidi {
  static FetchCommand = class { 
    static request(bytes) {
      return bytes
    }
  }
}

function channel(editor) {
  return editor.patch(["global"])?.get(["channel"]) ?? 0
}

function paramData(ch, parm, value) {
  return ["sx", [0xf0, 0x43, 0x10 + ch, parm >> 7, parm & 0x7f, value, 0xf7]]
}

function voiceOut(editor) {
  return {
    path: ["patch"],
    outType: "patchChange",
    throttle: 100,
    paramTransform: function(bytes, path, value) {
      const ch = channel(editor)
      let parm = 0
      let v = 0
      if (path.length == 3 && path[0] == "op" && path[2] == "on") {
        parm = 155
        v = (6).map(i => editor.getExtra(["op", i]) == 1 ? 1 << (5 - i) : 0).sum()
      }
      else {
        const param = DX7VoicePatch.params[path.join("/")]
        if (!param) { return null }
        parm = param.b
        v = bytes[parm]
      }
      return [[paramData(ch, parm, v), 0]]
      // return [[paramData(ch, parm, v), 0]]
    },
    patchTransform: function(bytes) {
      const ch = channel(editor)
      return [[["sx", DX7VoicePatch.sysexData(bytes, ch)], 0]]
    },
    nameTransform: function(bytes, path, name) {
      const ch = channel(editor)
      const data = DX7VoicePatch.nameByteRange.rangeMap(i => paramData(ch, i, bytes[i]))
      return data.map(msg => [msg, 0.03])
    },
  }
}

function bankOut(editor) {
  return {
    path: ["bank"],
    outType: "wholeBank",
    bankTransform: function(bytesArray) {
      const ch = channel(editor)
      return [["sx", [DX7VoiceBank.sysexData(ch, bytesArray)], 0]]
    },
  }
}


const editor = {
  
  sysexMap: [
      // [.global] : ChannelSettingsPatch,
      [["patch"], DX7VoicePatch],
      // [.bank] : DX7VoiceBank,
  ],
  
  fetchCommands: function(editor, path) {
    let byte = 0
    switch (path[0]) {
    case "patch":
      byte = 0x00
      break
    case "bank":
      byte = 0x09
      break
    default:
      return null
    }
    return [RxMidi.FetchCommand.request([0xf0, 0x43, 0x20 + channel(editor), byte, 0xf7])]
  },

  midiChannel: (editor, path) => channel(editor),
  
  // returns an array of objects to be used to construct streams/connections from editor->midi
  midiOuts: function(editor) {
    return [
      voiceOut(editor),
      bankOut(editor),
    ]
  },


  bankInfo(templateType) {
    switch(templateType) {
      case "Patch":
        return [
          [["bank"], "Voice Bank"],
        ]
      default:
        return []
    }
  }
}

module.exports = editor

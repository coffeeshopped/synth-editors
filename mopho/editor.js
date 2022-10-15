require('/core/NumberUtils.js')
require('/core/ArrayUtils.js')

class RxMidi {
  static FetchCommand = class { 
    static request(bytes) {
      return bytes
    }
  }
}

function channel(editor) {
  // value of 0 == global
  let ch = editor.patch(["global"])?.get(["channel"]) ?? 0
  return ch > 0 ? ch - 1 : 0
}

function nrpnData(channel, index, value) {
  return [
    ["cc", channel, 0x63, index.bit(7)],
    ["cc", channel, 0x62, index.bits(0, 6)],
    ["cc", channel, 0x06, value.bit(7)],
    ["cc", channel, 0x26, value.bits(0, 6)],
    ["cc", channel, 0x25, 0x3f],
    ["cc", channel, 0x24, 0x3f],
  ]
}

function nrpnOut(editor, path, patchType, nameParmOffset) {
  return {
    path: path,
    outType: "patchChange",
    throttle: 100, 
    paramTransform: function(bytes, path, value) {
      // TODO: get truss for path from editor to cache params?
      let param = patchType.params[path.join("/")]
      if (!param) { return null }
      let ch = channel(editor)
      return nrpnData(ch, param.p, value).map(msg => [msg, 0.03])
    },
    patchTransform: function(bytes) {
      return [[["sx", patchType.fileData(bytes)], 0]]
    },
    nameTransform: function(bytes, path, name) {
      if (patchType.nameByteRange.length <= 0) { return null }
      // let parmOffset = patchType == TetraComboPatch ? 512 : 0
      let ch = channel(editor)
      return patchType.nameByteRange.rangeMap(
        i => nrpnData(ch, i + nameParmOffset, bytes[i])
      ).flat().map(msg => [msg, 0.01])
    },
  }
}

function bankOut(editor, path, patchType, bankIndex) {
  return {
    path: path,
    outType: "partialBank",
    patchTransform: function(bytes, location) {
      return [[["sx", patchType.sysexWriteData(bytes, bankIndex, location)], 0]]
    }
  }
}

function MophoTypeEditor(GlobalPatch, VoicePatch, VoiceBank) {
  return class {
  
    static sysexMap = (function() {
      return [
        [["global"], GlobalPatch],
        [["patch"], VoicePatch],
      ].concat((3).map(i => [["bank", i], VoiceBank]))
    })()

    static compositeMap = [
      [["backup"], require('patch/backup.js')(GlobalPatch, VoiceBank)],
    ]

    // MARK: MIDI I/O
    
    static request = (bytes) => 
      RxMidi.FetchCommand.request(VoicePatch.sysexHeader.concat(bytes, 0xf7))
    
    static fetchCommands(editor, path) {
      switch (path[0]) {
      case "global":
        return [this.request([0x0e])]
      case "patch":
        return [this.request([0x06])]
      case "bank":
        var bank = path[1]
        return (128).map(i => this.request([0x05, bank, i]))
      default:
        return null
      }
    }
      
    static midiChannel = function(editor, path) { return channel(editor) }
  
    static bankInfo(templateType) {
      switch (templateType) {
      case VoicePatch:
        return [
          [["bank", 0], "Bank 1"],
          [["bank", 1], "Bank 2"],
          [["bank", 2], "Bank 3"],
          ]
      default:
        return []
      }
    }

    // returns an array of objects to be used to construct streams/connections from editor->midi
    static midiOuts(editor) {
      return [
        nrpnOut(editor, ["global"], GlobalPatch, 0),
        nrpnOut(editor, ["patch"], VoicePatch, 0),
      ].concat((3).map(i => bankOut(editor, ["bank", i], VoicePatch, i)))
    }

  }  
}

const MophoGlobalPatch = require('patch/globalPatch.js')
const MophoVoicePatch = require('patch/voicePatch.js')
const MophoVoiceBank = require('patch/voiceBank.js')
class MophoKeyGlobalPatch { }
class MophoKeyVoicePatch { }
class MophoKeyVoiceBank { }

const MophoEditor = MophoTypeEditor(MophoGlobalPatch, MophoVoicePatch, MophoVoiceBank)
const MophoKeyEditor = MophoTypeEditor(MophoKeyGlobalPatch, MophoKeyVoicePatch, MophoKeyVoiceBank)

exports.MophoEditor = MophoEditor
exports.MophoKeyEditor = MophoKeyEditor


const ctrlr = {
  builders: [
    ['panel', 'tone', { }, [[
      [{select: "Tone"}, "tone"],
    ]]],
    ['panel', 'key', { }, [[
      ["Key Lo", "key/lo"],
      ["Key Hi", "key/hi"],
    ]]],
    ['panel', 'porta', { }, [[
      [{checkbox: "Porta"}, "porta"],
      ["Time", "porta/time"],
    ]]]
    ['panel', 'assign', { }, [[
      [{switch: "Key Assign"}, "key/assign"],
    ]]]
    ['panel', 'transpose', { }, [[
      ["Key Shift", "transpose"],
      ["Detune", "detune"],
    ]]]
    ['panel', 'bend', { }, [[
      ["Mono Bend", "bend"],
      ["Mod Sens", "mod/amt"],
      ["Volume", "volume"],
      ["Chord Mem", "chord"],
    ]]]
    ['panel', 'ctrl', { }, [[
      [{checkbox: "MIDI After"}, "aftertouch"],
      [{checkbox: "MIDI Bend"}, "bend/ctrl"],
      [{checkbox: "MIDI Hold"}, "hold"],
      [{checkbox: "MIDI Mod Wh"}, "modWheel"],
      [{checkbox: "MIDI Volume"}, "volume/ctrl"],
      [{checkbox: "MIDI Porta"}, "porta/ctrl"],
    ]]]
  ],
  effects: [
    ['patchChange', "key/assign", v => ['hideItem', v != 2, 'chord']],
  ],
  layout: [
    ['row', [["tone", 1.5], ["key", 2], ["porta", 2], ["assign", 1]]],
    ['row', [["transpose", 2], ["bend", 4.5]]],
    ['row', [["ctrl", 1]]],
    ['col', [["tone", 1], ["transpose", 1], ["ctrl", 1]]],
  ]
}

addParamChangeBlock { (params) in
  var toneNameOptions = tone.options
  (0..<2).forEach { bank in
    guard let param = params.params["tone/name/bank"] as? OptionsParam else { return }
    param.options.forEach { toneNameOptions[$0.key + (bank * 64)] = $0.value }
  }
  tone.options = toneNameOptions
}



let miso = Miso.switcher([
  .int(35, "Off"),
  .range(36...60, Miso.a(-60) >>> Miso.str()),
  .range(61...84, Miso.a(-60) >>> Miso.str("+%g")),
])
let misoParam = MisoParam.make(range: 35...84, iso: miso)


const ctrlr = {
  builders: [
    ['panel', 'notes', { }, [
      notes.map(n => [{ knob: `Note ${n+1}`, id: ['note', i] }, null])
    ]]
  ],
  effects: [
    (6).map(i => [
      
    ])
    notes.enumerated().forEach {
      let knob = $0.element
      defaultConfigure(control: knob, forParam: misoParam)
      ['patchChange', "note/$0.offset",  { knob.value = $0 == 127 ? 35 : $0 }
      addDefaultControlChangeBlock(control: knob, path: "note/$0.offset") {
        knob.value == 35 ? 127 : knob.value
      }
    }

  ],
  simpleGridLayout: [
    [["notes", 1]],
  ]
}



const patchTruss = EvolverVoice.patchTruss
patchTruss.parms = patchTruss.parms.concat([
  // "Keybd" instead of "MIDI" in a couple of options
  ["trigger", { b: 54, opts: ["All", "Seq Only", "Keybd Only", "Keybd Reset", "Combo", "Combo Reset", "Ext In Env", "Ext In Env Reset", "Ext In Seq", "Ext In Seq Reset", "Key Seq Once", "Key Seq Reset", "Ext Trig", "Key Seq"] }],
  // now contains poly/mono etc setting as well 
  ["key/mode", { b: 71, max: 23 }],
])

const romBanks = [
  ["Brass", "Horn", "Trumpet", "LoStrig", "Strings", "Piano", "NewEP", "EGrand", "Jazz Gt", "EBass", "WodBass", "EOrgan1", "EOrgan2", "POrgan1", "POrgan2", "Flute", "Picolo", "Oboe", "Clarine", "Glocken", "Vibes", "Xylophn", "Koto", "Zither", "Clav", "Harpsic", "Bells", "Harp", "SmadSyn", "Harmoni", "SteelDr", "Timpani", "LoStrg2", "Horn Lo", "Whistle", "zingPip", "Metal", "Heavy", "FunkSyn", "Voices", "Marimba", "EBass2", "SnareDr", "RD Cymb", "Tom Tom", "Mars to", "Storm", "Windbel"],
  
  ["UpPiano", "Spiano", "Piano2", "Piano3", "Piano4", "Piano5", "PhGrand", "Grand", "DpGrand", "LPiano1", "LPiano2", "EGrand2", "Honkey1", "Honkey2", "Pfbell", "PfVibe", "NewEP2", "NewEP3", "NewEP4", "NewEP5", "EPiano1", "EPiano2", "EPiano3", "EPiano4", "EPiano5", "HighTin", "HardTin", "PercPf", "Woodpf", "EPStrng", "EPBrass", "Clav2", "Clav3", "Clav4", "FuzzClv", "MuteClv", "MuteCl2", "SynClv1", "SynClv2", "SynClv3", "SynClv4", "Harpsi2", "Harpsi3", "Harpsi4", "Harpsi5", "Circust", "Celeste", "Squeeze"],
  ["Horn2", "Horn3", "Horns", "Flugeln", "Trombon", "Trumpt2", "Brass2", "Brass3", "HardBr1", "HardBr2", "HardBr3", "HardBr4", "HuffBrs", "PercBr1", "PercBr2", "String1", "String2", "String3", "String4", "SoloVio", "RichSt1", "RichSt2", "RichSt3", "RichSt4", "Cello1", "Cello2", "LoStrg3", "LoStrg4", "LoStrg5", "Orchest", "5th Str", "Pizzic1", "Pizzic2", "Flute2", "Flute3", "Flute4", "Pan Flt", "SlowFlt", "5th Flt", "Oboe2", "Bassoon", "Reed", "Harmon2", "Harmon3", "Harmon4", "MonoSax", "Sax 1", "Sax 2"],
  
  ["FnkSyn2", "FnkSyn3", "SynOrgn", "SynFeed", "SynHarm", "SynClar", "SynLead", "HuffTak", "SoHeavy", "Hollow", "Schmooh", "MonoSyn", "Cheeky", "SynBell", "SynPluk", "EBass3", "RubBass", "SolBass", "PlukBas", "UprtBas", "Fretles", "Flaps", "MonoBas", "SynBas1", "SynBas2", "SynBas3", "SynBas4", "SynBas5", "SynBas6", "SynBas7", "Marimb2", "Marimb3", "Xyloph2", "Vibe2", "Vibe3", "Glockn2", "TubeBe1", "TubeBe2", "Bells2", "Temple", "SteelDr", "ElectDr", "HandDr", "SynTimp", "clock", "Heifer", "SnareD2", "SnareD3"],
  
  ["JOrgan1", "JOrgan2", "COrgan1", "COrgan2", "EOrgan3", "EOrgan4", "EOrgan5", "EOrgan6", "EOrgan7", "EOrgang", "SmiPipe", "MidPipe", "BigPipe", "SftPipe", "Organ", "Guitar", "FolkGt", "PluckGt", "Britet", "FuzzGt", "Zither2", "Lute", "Banjo", "SftHarp", "Harp2", "Harp3", "Sftkoto", "Hitkoto", "Sitar1", "Sitar2", "Huffsyn", "Fantasy", "Synvoic", "M.Voice", "VSAR", "Racing", "Water", "WildWar", "Ghostie", "Wave", "Space 1", "SpChime", "SpTalk", "Winds", "Smash", "Alarm", "Helicop", "SineWav"]
]

const partController = ['index', "part", "part", i => `${i + 1}`, {
  color: 2,
  builders: [
    ['grid', [[
      ["MIDI Ch", "channel"],
      ["Note Rsrv", "voice/reserve"],
    ],[
      ["Low N", "key/lo"],
      ["Hi N", "key/hi"],
    ],[
      [{select: "Bank"}, "bank"],
      [{select: "Pgm", width: 5}, "pgm"],
    ],[
      ["Octave", "octave"],
      ["Detune", "detune"],
    ],[
      ["Level", "level"],
      [{switch: "Pan"}, "pan"],
    ],[
      [{checkbox: "LFO"}, "lfo/on"],
      ["Porta", "porta"],
    ],[
      ["Bend", "bend"],
      [{checkbox: "Mono"}, "mono"],
    ],[
      [{select: "Pitch Ctrl"}, "pitch/mod/depth/ctrl"],
      { l: "?", id: "part", width: 1 },
    ]]]
  ], 
  effects: [
    ['patchSelector', "pgm", {
      bankValue: "bank", 
      paramMap: b => 
        b < 2 ? ['fullPath', "patch/name/bank"] :  { opts: romBanks[b - 2] }
    }],
  ],
}]

module.exports = {
  ctrlr: {
    builders: [
      ['children', 8, "p", partController],
      ['panel', 'voice', { color: 1 }, [[
        [{checkbox: "Voice F Combi"}, "voice/load/mode"],
        [{switsch: "Key Rcv"}, "key/rcv/mode"],
      ]]],
      ['panel', 'lfo', { color: 1 }, [[
        [{select: "LFO Wave"}, "lfo/wave"],
        ["Speed", "lfo/speed"],
        ["AMD", "amp/mod/depth"],
        ["PMD", "pitch/mod/depth"],
      ]]],
    ], 
    layout: [
      ['row', [["voice",3],["lfo",5]]],
      ['row', (8).map(i => [`p${i}`,1])],
      ['col', [["voice",1],["p0",8]]],
    ]
  }
}

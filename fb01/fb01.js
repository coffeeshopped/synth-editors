
const paramData = (instrument, bodyBytes) =>
  ['yamSyx', [0x75, 'channel', 0x18 + instrument, bodyBytes]]

const voiceRamBanks = [
  ["Brass", "Horn", "Trumpet", "LoStrig", "Strings", "Piano", "NewEP", "EGrand", "Jazz Gt", "EBass", "WodBass", "EOrgan1", "EOrgan2", "POrgan1", "POrgan2", "Flute", "Picolo", "Oboe", "Clarine", "Glocken", "Vibes", "Xylophn", "Koto", "Zither", "Clav", "Harpsic", "Bells", "Harp", "SmadSyn", "Harmoni", "SteelDr", "Timpani", "LoStrg2", "Horn Lo", "Whistle", "zingPip", "Metal", "Heavy", "FunkSyn", "Voices", "Marimba", "EBass2", "SnareDr", "RD Cymb", "Tom Tom", "Mars to", "Storm", "Windbel"],
  
  ["UpPiano", "Spiano", "Piano2", "Piano3", "Piano4", "Piano5", "PhGrand", "Grand", "DpGrand", "LPiano1", "LPiano2", "EGrand2", "Honkey1", "Honkey2", "Pfbell", "PfVibe", "NewEP2", "NewEP3", "NewEP4", "NewEP5", "EPiano1", "EPiano2", "EPiano3", "EPiano4", "EPiano5", "HighTin", "HardTin", "PercPf", "Woodpf", "EPStrng", "EPBrass", "Clav2", "Clav3", "Clav4", "FuzzClv", "MuteClv", "MuteCl2", "SynClv1", "SynClv2", "SynClv3", "SynClv4", "Harpsi2", "Harpsi3", "Harpsi4", "Harpsi5", "Circust", "Celeste", "Squeeze"],
  ["Horn2", "Horn3", "Horns", "Flugeln", "Trombon", "Trumpt2", "Brass2", "Brass3", "HardBr1", "HardBr2", "HardBr3", "HardBr4", "HuffBrs", "PercBr1", "PercBr2", "String1", "String2", "String3", "String4", "SoloVio", "RichSt1", "RichSt2", "RichSt3", "RichSt4", "Cello1", "Cello2", "LoStrg3", "LoStrg4", "LoStrg5", "Orchest", "5th Str", "Pizzic1", "Pizzic2", "Flute2", "Flute3", "Flute4", "Pan Flt", "SlowFlt", "5th Flt", "Oboe2", "Bassoon", "Reed", "Harmon2", "Harmon3", "Harmon4", "MonoSax", "Sax 1", "Sax 2"],
  
  ["FnkSyn2", "FnkSyn3", "SynOrgn", "SynFeed", "SynHarm", "SynClar", "SynLead", "HuffTak", "SoHeavy", "Hollow", "Schmooh", "MonoSyn", "Cheeky", "SynBell", "SynPluk", "EBass3", "RubBass", "SolBass", "PlukBas", "UprtBas", "Fretles", "Flaps", "MonoBas", "SynBas1", "SynBas2", "SynBas3", "SynBas4", "SynBas5", "SynBas6", "SynBas7", "Marimb2", "Marimb3", "Xyloph2", "Vibe2", "Vibe3", "Glockn2", "TubeBe1", "TubeBe2", "Bells2", "Temple", "SteelDr", "ElectDr", "HandDr", "SynTimp", "clock", "Heifer", "SnareD2", "SnareD3"],
  
  ["JOrgan1", "JOrgan2", "COrgan1", "COrgan2", "EOrgan3", "EOrgan4", "EOrgan5", "EOrgan6", "EOrgan7", "EOrgang", "SmiPipe", "MidPipe", "BigPipe", "SftPipe", "Organ", "Guitar", "FolkGt", "PluckGt", "Britet", "FuzzGt", "Zither2", "Lute", "Banjo", "SftHarp", "Harp2", "Harp3", "Sftkoto", "Hitkoto", "Sitar1", "Sitar2", "Huffsyn", "Fantasy", "Synvoic", "M.Voice", "VSAR", "Racing", "Water", "WildWar", "Ghostie", "Wave", "Space 1", "SpChime", "SpTalk", "Winds", "Smash", "Alarm", "Helicop", "SineWav"]
]

module.exports = {
  paramData,
  voiceRamBanks,
}
const TX81ZPerf = require('./tx81z_perf.js')

const fxOptions = ["Off",
  "Delay 1", "Pan 1", "Chord 1",
  "Delay 2", "Pan 2", "Chord 2",
  "Delay 3", "Pan 3", "Chord 3",
  "Delay 4", "Pan 4", "Chord 4",
]

// user value -> stored bits
const fxMap = [0, 
  1, 2, 3,
  5, 6, 7, 
  9, 10, 11, 
  13, 14, 15,
]

const bankFxPackIso = ['>', {
  forward: v => fxMap[v] || 0, 
  backward: b => Math.abs(fxMap.indexOf(v)),
}, ['splitter', [
  { byte: 64, byteBits: [4, 5], valueBits: [2, 3] },
  { byte: 65, byteBits: [1, 2], valueBits: [0, 1] },
]]]

const parms = TX81ZPerf.parms.concat([
  ['fx', { b: 98, opts: fxOptions }],  
])

const compactParms = TX81ZPerf.compactParms.concat([
  ['fx', { b: 64, packIso: bankFxPackIso }],
])

const presetVoices = ["A1. Syn.Str 1", "A2. Syn.Str 2", "A3. Sy.Brass 1", "A4. Sy.Brass 2", "A5. Sy.Brass 3", "A6. Sy.Brass 4", "A7. Sy.Ensem. 1", "A8. Sy.Ensem. 2", "A9. Sy.Ensem. 3", "A10. Sy.Ensem. 4", "A11. Sy.Ensem. 5", "A12. Sy.Perc. 1", "A13. Sy.Perc. 2", "A14. Sy.Perc. 3", "A15. Sy.Perc. 4", "A16. Sy.Bass 1", "A17. Sy.Bass 2", "A18. Sy.Bass 3", "A19. Sy.Bass 4", "A20. Sy.Bass 5", "A21. Sy.Organ 1", "A22. Sy.Organ 2", "A23. Sy.Solo 1", "A24. Sy.Solo 2", "A25. Sy.Solo 3", "A26. Sy.Solo 4", "A27. Sy.Voice 1", "A28. Sy.Voice 2", "A29. Sy.Decay 1", "A30. Sy.Decay 2", "A31. Sy.Sitar", "A32. Sy.AftrTch", "B1. DX7 EP", "B2. Old Rose", "B3. E.Piano 1", "B4. E.Piano 2", "B5. Grand PF", "B6. Upright", "B7. Flamenco", "B8. A.Guitar", "B9. F.Guitar", "B10. Banjo", "B11. E.Guitar", "B12. Mute Gtr", "B13. Harp 1", "B14. Harp 2", "B15. Harpsichrd", "B16. Clavi", "B17. Koto", "B18. Syamisen", "B19. Marimba", "B20. Xylophone", "B21. Vibe.", "B22. Glocken", "B23. Tube Bell", "B24. Toy Piano", "B25. Pizz. 1", "B26. Pizz. 2", "B27. E.Bass 1", "B28. E.Bass 2", "B29. E.Bass 3", "B30. Wood Bass", "B31. Bell", "B32. Steel Drum", "C1. Strings 1", "C2. Strings 2", "C3. Ensemble 1", "C4. Ensemble 2", "C5. Violin 1", "C6. Violin 2", "C7. Cello 1", "C8. Cello 2", "C9. Brass 1", "C10. Brass 2", "C11. Trumpet 1", "C12. Trumpet 2", "C13. Trombone", "C14. Horn", "C15. Tuba", "C16. Sax 1", "C17. Sax 2", "C18. Wood Wind", "C19. Clarinet 1", "C20. Clarinet 2", "C21. Oboe", "C22. Flute 1", "C23. Flute 2", "C24. Recorder", "C25. Harmonica", "C26. E.Organ 1", "C27. E.Organ 2", "C28. E.Organ 3", "C29. E.Organ 4", "C30. P.Organ 1", "C31. P.Organ 2", "C32. Accordion", "D1. Bass Drum 1", "D2. Bass Drum 2", "D3. Snare 1", "D4. Snare 2", "D5. Tom 1", "D6. Tom 2", "D7. Tom 3", "D8. Tom 4", "D9. Hi! Hat!", "D10. Cow Bell", "D11. Agogo Bell", "D12. Wood Block", "D13. Castanet", "D14. SyBon", "D15. BoConga", "D16. Tom-Pany", "D17. SynGameran", "D18. Mouse-Tom", "D19. Carnival!", "D20. Air imba", "D21. SplashClav", "D22. BamboBlock", "D23. Terror!", "D24. Wind Voice", "D25. GuiRoach::", "D26. Spac BUG?", "D27. Passing By", "D28. Earthquake", "D29. TAP TAP<<<", "D30. Space Gong", "D31. RADIATION?", "D32. White Blow"]

module.exports = {
  parms,
  compactParms,
  patchCount: 32,  
  presetVoices,
}

enum DXX {

  static let sysexWerk = RolandSysexTrussWerk(modelId: [0x16], addressCount: 3)

  static func compactSingleBankWerk(patchWerk: RolandSinglePatchTrussWerk, start: RolandAddress, defaultName: String? = nil, patchCount: Int, validSizes: [Int]) -> RolandSingleBankTrussWerk {
    sysexWerk.compactSingleBankWerk(patchWerk, patchCount, start: start, defaultName: defaultName, iso: .init(address: {
      patchWerk.size * Int($0)
    }, location: {
      guard $0 >= start else { return 0 }
      return UInt8(($0 - start) / patchWerk.size)
    }), validBundle: SingleBankTruss.fileDataCountBundle(patchTruss: patchWerk.truss, patchCount: patchCount, validSizes: validSizes, includeFileDataCount: true))
  }
  
  
  
  static let presetA = ["1. AcouPiano1", "2. AcouPiano2", "3. AcouPiano3", "4. Honky-Tonk", "5. ElecPiano1", "6. ElecPiano2", "7. ElecPiano3", "8. ElecPiano4", "9. ElecOrgan1", "10. ElecOrgan2", "11. ElecOrgan3", "12. ElecOrgan4", "13. PipeOrgan1", "14. PipeOrgan2", "15. PipeOrgan3", "16. Accordion", "17. Harpsi 1", "18. Harpsi 2", "19. Harpsi 3", "20. Clav 1", "21. Clav 2", "22. Clav 3", "23. Celesta 1", "24. Celesta 2", "25. Violin 1", "26. Violin 2", "27. Cello 1", "28. Cello 2", "29. Contrabass", "30. Pizzicato", "31. Harp 1", "32. Harp 2", "33. Strings 1", "34. Strings 2", "35. Strings 3", "36. Strings 4", "37. Brass 1", "38. Brass 2", "39. Brass 3", "40. Brass 4", "41. Trumpet 1", "42. Trumpet 2", "43. Trombone 1", "44. Trombone 2", "45. Horn", "46. Fr Horn", "47. Engl Horn", "48. Tuba", "49. Flute 1", "50. Flute 2", "51. Piccolo", "52. Recorder", "53. Pan Pipes", "54. Bottleblow", "55. Breathpipe", "56. Whistle", "57. Sax 1", "58. Sax 2", "59. Sax 3", "60. Clarinet 1", "61. Clarinet 2", "62. Oboe", "63. Bassoon", "64. Harmonica"]
  
  static let presetB = ["1. Fantasy", "2. Harmo Pan", "3. Chorale", "4. Glasses", "5. Soundtrack", "6. Atmosphere", "7. Warm Bell", "8. Space Horn", "9. Echo Bell", "10. Ice Rains", "11. Oboe 2002", "12. Echo Pan", "13. Bell Swing", "14. Reso Synth", "15. Steam Pad", "16. VibeString", "17. Syn Lead 1", "18. Syn Lead 2", "19. Syn Lead 3", "20. Syn Lead 4", "21. Syn Bass 1", "22. Syn Bass 2", "23. Syn Bass 3", "24. Syn Bass 4", "25. AcouBass 1", "26. AcouBass 2", "27. ElecBass 1", "28. ElecBass 2", "29. SlapBass 1", "30. SlapBass 2", "31. Fretless 1", "32. Fretless 2", "33. Vibe", "34. Glock", "35. Marimba", "36. Xylophone", "37. Guitar 1", "38. Guitar 2", "39. Elec Gtr 1", "40. Elec Gtr 2", "41. Koto", "42. Shamisen", "43. Jamisen", "44. Sho", "45. Shakuhachi", "46. WadaikoSet", "47. Sitar", "48. Steel Drum", "49. Tech Snare", "50. Elec Tom", "51. Revrse Cym", "52. Ethno Hit", "53. Timpani", "54. Triangle", "55. Wind Bell", "56. Tube Bell", "57. Orche Hit", "58. Bird Tweet", "59. OneNoteJam", "60. Telephone", "61. Typewriter", "62. Insect", "63. WaterBells", "64. JungleTune"]
  
  static let presetR = ["1. Cl HighHat 1", "2. Cl HighHat 2", "3. Op HighHat 1", "4. Op HighHat 2", "5. Crash Cymbal", "6. Crash (short)", "7. Crash (mute)", "8. Ride Cymbal", "9. Ride (short)", "10. Ride (mute)", "11. Cup", "12. Cup (mute)", "13. China Cymbal", "14. Splash Cymbal", "15. Bass Drum 1", "16. Bass Drum 2", "17. Bass Drum 3", "18. Bass Drum 4", "19. Snare Drum 1", "20. Snare Drum 2", "21. Snare Drum 3", "22. Snare Drum 4", "23. Snare Drum 5", "24. Snare Drum 6", "25. Rim Shot", "26. Brush 1", "27. Brush 2", "28. High Tom 1", "29. Mid Tom 1", "30. Low Tom 1", "31. High Tom 2", "32. Mid Tom 2", "33. Low Tom 2", "34. High Tom 3", "35. Mid Tom 3", "36. Low Tom 3", "37. Hi Pitch Tom 1", "38. Hi Pitch Tom 2", "39. Hand Clap", "40. Tambourine", "41. Cowbell", "42. High Bongo", "43. Low Bongo", "44. High Conga (mute)", "45. High Conga", "46. Low Conga", "47. High Timbale", "48. Low Timbale", "49. High Agogo", "50. Low Agogo", "51. Cabasa", "52. Maracas", "53. Short Whistle", "54. Long Whistle", "55. Quijada", "56. Claves", "57. Castanets", "58. Triangle", "59. Wood Block", "60. Bell", "61. Native Drum 1", "62. Native Drum 2", "63. Native Drum 3", "64. Off"]
}

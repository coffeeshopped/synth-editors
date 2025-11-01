
const fetchCommand = (byte) =>
  ['truss', [0xf0, 0x42, ['+', 0x30, 'channel'], 0x58, byte, 0xf7]]

const editor = {
  name: "",
  trussMap: [
    ["global", Global.patchTruss],
    ['patch', Voice.patchTruss],
    ['bank', Voice.bankTruss],
  ],
  fetchTransforms: [
    ["global", fetchCommand(0x0e)],
    ['patch', fetchCommand(0x10)],
    // looks like for microkorg s, fetch is:
    // F0 42 30 00 01 40 10 F7
    ['bank', fetchCommand(0x1c)],
  ],

  midiOuts: [
    ["global", Global.patchTransform],
    ['patch', Voice.patchTransform],
    ['bank', Voice.bankTransform],
  ],
  midiChannels: [
    ["patch", "basic"],
  ],
  slotTransforms: [
    ['bank', ['user', i => {
      const letter = i < 64 ? "A" : "B"
      const bank = (i % 64) / 8 + 1
      const slot = i % 8 + 1
      return `${letter}${bank}${slot}`
    }]]
  ],
}

extension MicrokorgEditor {

  static let arpGateMap = [0, 0, 1, 2, 3, 3, 4, 5, 6, 7, 7, 8, 9, 10, 11, 11, 12, 13, 14, 14, 15, 16, 17, 18, 18, 19, 20, 21, 22, 22, 23, 24, 25, 26, 26, 27, 28, 29, 29, 30, 31, 32, 33, 33, 34, 35, 36, 37, 37, 38, 39, 40, 41, 41, 42, 43, 44, 44, 45, 46, 47, 48, 48, 49, 50, 51, 52, 52, 53, 54, 55, 56, 56, 57, 58, 59, 59, 60, 61, 62, 63, 63, 64, 65, 66, 67, 67, 68, 69, 70, 71, 71, 72, 73, 74, 74, 75, 76, 77, 78, 78, 79, 80, 81, 82, 82, 83, 84, 85, 86, 86, 87, 88, 89, 89, 90, 91, 92, 93, 93, 94, 95, 96, 97, 97, 98, 99, 100]
  
  static let semitoneMap = [-24, -24, -24, -23, -23, -23, -22, -22, -21, -21, -21, -20, -20, -20, -19, -19, -18, -18, -18, -17, -17, -16, -16, -16, -15, -15, -15, -14, -14, -13, -13, -13, -12, -12, -11, -11, -11, -10, -10, -10, -9, -9, -8, -8, -8, -7, -7, -7, -6, -6, -5, -5, -5, -4, -4, -3, -3, -3, -2, -2, -2, -1, -1, 0, 0, 0, 1, 1, 2, 2, 2, 3, 3, 3, 4, 4, 5, 5, 5, 6, 6, 7, 7, 7, 8, 8, 8, 9, 9, 10, 10, 10, 11, 11, 11, 12, 12, 13, 13, 13, 14, 14, 15, 15, 15, 16, 16, 16, 17, 17, 18, 18, 18, 19, 19, 20, 20, 20, 21, 21, 21, 22, 22, 23, 23, 23, 24, 24]

  
}

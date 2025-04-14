
const ctrlr =  {
  color: 1, 
  builders: [
    ['panel', 'mode', [[
      [{switsch: "Mode"}, "mode"],
      ["Tune", "tune"],
      ["Key Transpose", "key/transpose"],
      [{checkbox: "Transpose"}, "transpose"],
      ]]],
    ['panel', 'fx', [[
      [{checkbox: "Reverb"}, "reverb"],
      [{checkbox: "Chorus"}, "chorus"],
      ]]],
    ['panel', 'hold', [[
      [{switsch: "Hold Pol"}, "hold/polarity"],
      ]]],
    ['panel', 'pedal1', [[
      [{switsch: "Pedal 1 Pol"}, "pedal/0/polarity"],
      [{switsch: "Mode"}, "pedal/0/mode"],
      [{select: "Assign"}, "pedal/0/assign"],
      ]]],
    ['panel', 'pedal2', [[
      [{switsch: "Pedal 2 Pol"}, "pedal/1/polarity"],
      [{switsch: "Mode"}, "pedal/1/mode"],
      [{select: "Assign"}, "pedal/1/assign"],
      ]]],
    ['panel', 'ctrl', [[
      [{switsch: "C1 Mode"}, "ctrl/mode"],
      [{select: "Assign"}, "ctrl/assign"],
      ]]],
    ['panel', 'after', [[
      ["Aftert Thresh", "aftertouch/threshold"],
      ]]],
    ['panel', 'rx', [[
      [{checkbox: "RX Volume"}, "rcv/volume"],
      [{checkbox: "CC"}, "rcv/ctrl/change"],
      [{checkbox: "Ch Press"}, "rcv/aftertouch"],
      [{checkbox: "Mod"}, "rcv/mod"],
      [{checkbox: "Bend"}, "rcv/bend"],
      [{checkbox: "Pgm Ch"}, "rcv/pgmChange"],
      [{checkbox: "Bank Sel"}, "rcv/bank/select"],
      ["Patch Channel", "patch/channel"],
      ]]],
    ['panel', 'etc', [[
      ["Ctrl Chan", "ctrl/channel"],
      ]]],
    ['panel', 'tx', [[
      [{checkbox: "TX Volume"}, "send/volume"],
      [{checkbox: "CC"}, "send/ctrl/change"],
      [{checkbox: "Ch Press"}, "send/aftertouch"],
      [{checkbox: "Mod"}, "send/mod"],
      [{checkbox: "Bend"}, "send/bend"],
      [{checkbox: "Pgm Ch"}, "send/pgmChange"],
      [{checkbox: "Bank Sel"}, "send/bank/select"],
      ["TX Patch Channel", "patch/send/channel"],
      ]]],
  ],
  layout: [
    ['row', [["mode",4], ["fx",2], ["hold",1], ["pedal1",3], ["pedal2",3]]],
    ['row', [["rx",8], ["ctrl",2], ["after",1]]],
    ['row', [["tx",8], ["etc",3]]],
    ['col', [["mode",1], ["rx",1], ["tx",1]]],
  ],
}

module.exports = {
  ctrlr,
}
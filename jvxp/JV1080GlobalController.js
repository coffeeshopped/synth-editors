const controller = {
  color: 1,
  builders: [
    ['panel', 'modes', [[
      [{ switsch: null }, 'mode'],
      ['Tune', 'tune'],
      [{ checkbox: null }, 'scale/tune'],
      [{ checkbox: 'FX' }, 'fx'],
      [{ checkbox: null }, 'chorus'],
      [{ checkbox: null }, 'reverb'],
      [{ checkbox: null }, 'patch/remain'],
      [{ switsch: 'Clock Src' }, 'clock'],
      [{ switsch: null }, 'rhythm/edit'],
    ]]],
    ['panel', 'src', [[
      [{ select: 'Tap Ctrl' }, 'tap'],
      [{ select: 'Hold Ctrl' }, 'hold'],
      [{ select: 'Peak Ctrl' }, 'peak'],
      [{ switsch: 'Vol Ctrl' }, 'volume'],
      [{ switsch: 'Aftert Ctrl' }, 'aftertouch'],
      ['Ctrl 1', 'ctrl/0'],
      ['Ctrl 2', 'ctrl/1'],
      ['Ctrl Channel', 'ctrl/channel'],
      ['Patch Channel', 'patch/channel'],
    ]]],
    ['panel', 'rcv', [[
      [{ checkbox: 'Rcv PgmCh' }, 'rcv/pgmChange'],
      [{ checkbox: 'Rcv Bank Sel' }, 'rcv/bank/select'],
      [{ checkbox: 'Rcv Ctrl Ch' }, 'rcv/ctrl/change'],
      [{ checkbox: null }, 'rcv/mod'],
      [{ checkbox: 'Rcv Vol' }, 'rcv/volume'],
      [{ checkbox: null }, 'rcv/hold'],
      [{ checkbox: null }, 'rcv/bend'],
      [{ checkbox: 'Rcv After' }, 'rcv/aftertouch'],
    ]]],
    ['panel', 'prev', [[
      [{ switsch: 'Preview' }, 'preview/mode'],
      ['Key 1', 'preview/key/0'],
      ['Velo 1', 'preview/velo/0'],
      ['Key 2', 'preview/key/1'],
      ['Velo 2', 'preview/velo/1'],
      ['Key 3', 'preview/key/2'],
      ['Velo 3', 'preview/velo/2'],
      ['Key 4', 'preview/key/3'],
      ['Velo 4', 'preview/velo/3'],
    ]]],
  ],
  simpleGridLayout: [
    [['modes', 1]],
    [['src', 1]],
    [['rcv', 1]],
    [['prev', 1]],
  ],
}

module.exports = {
  controller,
}

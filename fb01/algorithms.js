// copied from TX81Z editor.
const algorithms = [
  // 1
  [
    { },
    { "outs": [1] },
    { "outs": [2] },
    { "outs": [3], "feedOuts": [4] }
  ],
  // 2
  [
    { },
    { "outs": [1] },
    { "outs": [2] },
    { "outs": [2], "feedOuts": [4] }
  ],
  // 3
  [
    { },
    { "outs": [1] },
    { "outs": [2] },
    { "outs": [1], "feedOuts": [4] }
  ],
  // 4
  [
    { },
    { "outs": [1] },
    { "outs": [1] },
    { "outs": [3], "feedOuts": [4] }
  ],
  // 5
  [
    { },
    { "outs": [1] },
    { },
    { "outs": [3], "feedOuts": [4] }
  ],
  // 6
  [
    { },
    { },
    { },
    { "outs": [1,2,3], "feedOuts": [4] }
  ],
  // 7
  [
    { },
    { },
    { },
    { "outs": [3], "feedOuts": [4] }
  ],
  // 8
  [
    { },
    { },
    { },
    { "feedOuts": [4] }
  ]
]

module.exports = {
  algorithms: algorithms,
}
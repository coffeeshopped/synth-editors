
module.exports = {
  toneSlotTransform: ['user', 
    loc => `${(loc / 8) + 1}${(loc % 8) + 1}`
  ]
}

Number.prototype.rand = function() {
  return Math.floor(Math.random() * this);
}

Number.prototype.map = function(mapFn) {
  var arr = []
  for(let i=0; i<this; ++i) {
    arr.push(mapFn(i))
  }
  return arr
}

Number.prototype.flatMap = function(mapFn) {
  var arr = []
  for(let i=0; i<this; ++i) {
    arr = arr.concat(mapFn(i))
  }
  return arr
}


Number.prototype.forEach = function(mapFn) {
  for(let i=0; i<this; ++i) {
    mapFn(i)
  }
}

Number.prototype.bit = function(index) {
  return (this >> index) & 0x1
}

// hi is 1 greater than the top index we read
Number.prototype.bits = function(lo, hi) {
  const bitlen = hi - lo
  const bitmask = (1 << bitlen) - 1 // all 1's
  return (this >> lo) & bitmask
}

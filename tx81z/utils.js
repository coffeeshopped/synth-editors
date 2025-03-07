Array.prototype.mapWithIndex = function(mapFn) {
  var arr = []
  for(let i=0; i<this.length; ++i) {
    arr.push(mapFn(this[i], i))
  }
  return arr
}

// NOTE: all ranges are treated as open (up to but not including the upper bound)
Array.prototype.rangeMap = function(mapFn) {
  if (this.length < 2 || this[1] < this[0]) { return [] }
  var arr = []
  for (let i=this[0]; i<this[1]; ++i) {
    arr.push(mapFn(i))
  }
  return arr
}

Array.prototype.sum = function() {
  return this.reduce((a, b) => a + b, 0)
}

Number.prototype.map = function(mapFn) {
  var arr = []
  for(let i=0; i<this; ++i) {
    arr.push(mapFn(i))
  }
  return arr
}

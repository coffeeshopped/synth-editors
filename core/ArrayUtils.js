Array.prototype.mapWithIndex = function(mapFn) {
  var arr = []
  for(let i=0; i<this.length; ++i) {
    arr.push(mapFn(this[i], i))
  }
  return arr
}

Array.prototype.forEachWithIndex = function(mapFn) {
  for(let i=0; i<this.length; ++i) {
    mapFn(this[i], i)
  }
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

Array.prototype.rangeLength = function() {
  return this[1] - this[0]
}

Array.prototype.safeBytes = function(range) {
  return range.rangeMap((i) => i < this.length ? this[i] : 0)
}

Array.prototype.sum = function() {
  return this.reduce((a, b) => a + b, 0)
}
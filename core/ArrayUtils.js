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

Array.prototype.sum = function() {
  return this.reduce((a, b) => a + b, 0)
}

Array.prototype.compactMap = function(mapFn) {
  var arr = []
  for(let i=0; i<this.length; ++i) {
    const e = mapFn(this[i]) 
    if (e !== null) {
      arr.push(e)
    }
  }
  return arr
}

Array.prototype.slices = function(size, offset = 0) {
  var arr = [];
  for (let i = offset + size; i < this.length; i += size) {
    arr.push(this.slice(i - size, i));
  }
  return arr  
}

// create a sparse array from an array of arrays.
// each sub-array is two elements: [index, element]
Array.sparse = (arr) => {
  const a = Array()
  arr.forEach(e => a[e[0]] = e[1])
  return a
}

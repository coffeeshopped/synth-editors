Array.prototype.mapWithIndex = function(mapFn) {
  var arr = []
  for(let i=0; i<this.length; ++i) {
    arr.push(mapFn(this[i], i))
  }
  return arr
}

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

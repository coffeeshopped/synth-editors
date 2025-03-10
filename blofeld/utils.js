// create a sparse array from an array of arrays.
// each sub-array is two elements: [index, element]
Array.sparse = (arr) => {
  const a = Array()
  arr.forEach(e => a[e[0]] = e[1])
  return a
}

Number.prototype.map = function(mapFn) {
  var arr = []
  for(let i=0; i<this; ++i) {
    arr.push(mapFn(i))
  }
  return arr
}

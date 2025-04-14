// 
// // NOTE: all ranges are treated as open (up to but not including the upper bound)
// Array.prototype.rangeMap = function(mapFn) {
//   if (this.length < 2 || this[1] < this[0]) { return [] }
//   var arr = []
//   for (let i=this[0]; i<this[1]; ++i) {
//     arr.push(mapFn(i))
//   }
//   return arr
// }
// 
// // create a sparse array from an array of arrays.
// // each sub-array is two elements: [index, element]
// Array.sparse = (arr) => {
//   const a = Array()
//   arr.forEach(e => a[e[0]] = e[1])
//   return a
// }
// 
// // returns a copy!
// Array.prototype.mergeSparse = function(arr) {
//   const c = Array.from(this)
//   arr.forEach((e) => c[e[0]] = e[1])
//   return c
// }
// 
Number.prototype.map = function(mapFn) {
  var arr = []
  for(let i=0; i<this; ++i) {
    arr.push(mapFn(i))
  }
  return arr
}

// Number.prototype.flatMap = function(mapFn) {
//   var arr = []
//   for(let i=0; i<this; ++i) {
//     arr = arr.concat(mapFn(i))
//   }
//   return arr
// }

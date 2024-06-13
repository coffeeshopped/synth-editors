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

Array.prototype.safeBytes = function(offset, count) {
  return ([offset, offset + count]).rangeMap((i) => i < this.length ? this[i] : 0)
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

// break an array of ints into an array of array of ints (sysex msgs)
// each starting with 0xf0 and ending with 0xf7
Array.prototype.sysex = function() {
  var msgs = []
  var msgStart = -1
  var msgEndPlusOne = -1
  
  while (msgEndPlusOne < this.length) {
    msgStart = this.indexOf(0xf0, msgEndPlusOne < 0 ? 0 : msgEndPlusOne)
    msgEndPlusOne = this.indexOf(0xf7, msgEndPlusOne < 0 ? 0 : msgEndPlusOne)
    
    // if beginning or end not found, we're done
    if (msgStart < 0 || msgEndPlusOne < 0) {
      break
    }
    
    msgs.push(this.slice(msgStart, msgEndPlusOne))
  }
  
  return msgs  
}

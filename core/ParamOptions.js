require('/core/ArrayUtils.js')

function reduce(genFn, itemMapFn = ((item) => item)) {
  // genFn can also just be an array, in which case, return it.
  if (Array.isArray(genFn)) {
    return genFn.mapWithIndex(itemMapFn)
  }
  
  // each call to generator should yield an array of arrays of [path, optionsObject]  
  let opts = []
  for(let arr of genFn()) {
    opts.push(...arr);
  }
  return opts.mapWithIndex(itemMapFn)
}
  
function prefix(pfx, {count = null, bx = 0, px = null} = {}, genFn) {
  if (count === null) {
    return reduce(genFn, (item) => [pfx.concat(item[0]), item[1]])
  }
  else {
    return reduce(function*() {
      for (let i=0; i<count; ++i) {
        let p = px === null ? null : px * i
        yield prefix(pfx.concat([i]), {}, offset({ b: bx * i, p: p }, genFn))
      }
    })
  }
}

function prefixes(pfxs, {bx = 0, px = null} = {}, genFn) {
  let opts = []
  for (let i=0; i<pfxs.length; ++i) {
    const pfx = pfxs[i]
    let p = px == null ? null : px * i
    let item = prefix(pfx, {}, offset({ b: bx * i, p: p }, genFn))
    opts = opts.concat(item)
  }
  return opts
}

function offset({b = 0, p = 0} = {}, genFn) {
  return reduce(genFn, (item) => {
    // ensure that we're not altering the data that's passed in.
    const clone = item.slice()
    clone[1] = Object.assign({}, clone[1])
    if (clone[1].b !== null) {
      clone[1].b += b
    }
    if (clone[1].p !== null) {
      clone[1].p += p
    }          
    return clone
  })
}


function inc({b = null, p = null} = {}, genFn) {
  return reduce(genFn, (item, i) => {
    const clone = item.slice()
    clone[1] = Object.assign({}, clone[1])
    if (b !== null) {
      clone[1].b = b + i
    }
    if (p !== null) {
      clone[1].p = p + i
    }
    return clone   
  })
}

//   /// Transform array of ParamOptions to dictionary. Later entries in the array with duplicate paths will overwrite earlier entries in the resulting dictionary.
//   static func paramsFromOpts(_ ins: [ParamOptions]) -> [SynthPath:Param] {
//     var dict = [SynthPath:Param]()
//     ins.forEach { po in
//       dict[po.path] = po.param()
//     }
//     return dict
//   }
//   

module.exports = {
  reduce,
  prefix,
  prefixes,
  offset,
  inc,
}
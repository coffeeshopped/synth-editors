
class ParamOptions {
  
  static reduce(genFn, itemMapFn = ((item) => item)) {
    // each call to generator should yield an array of arrays of [path, optionsObject]
    let opts = []
    for(let arr of genFn()) {
      opts.push(...arr.map(itemMapFn));
    }
    return opts
  }
    
  static prefix = function(pfx, {count = null, bx = 0, px = null} = {}, genFn) {
    const self = ParamOptions
    if (count === null) {
      return self.reduce(genFn, (item) => [pfx.concat(item[0]), item[1]])
    }
    else {
      return self.reduce(function*() {
        for (let i=0; i<count; ++i) {
          let p = px === null ? null : px * i
          yield self.prefix(pfx.concat([i]), {}, function*() {
            yield self.offset({ b: bx * i, p: p }, genFn)
          })
        }
      })
    }
  }
  
    static prefixes(pfxs, {bx = 0, px = null} = {}, genFn) {
      const self = ParamOptions
      let opts = []
      for (let i=0; i<pfxs.length; ++i) {
        const pfx = pfxs[i]
        let p = px == null ? null : px * i
        let item = self.prefix(pfx, {}, function*() {
          yield self.offset({ b: bx * i, p: p }, genFn)
        })
        opts = opts.concat(item)
      }
      return opts
    }
  
    static offset({b = 0, p = 0} = {}, genFn) {
      const self = ParamOptions
      return self.reduce(genFn, (item) => {
        if (item[1].b !== null) {
          item[1].b += b
        }
        if (item[1].p !== null) {
          item[1].p += p
        }          
        return item
      })
    }
    
  
    static inc({b = null, p = null} = {}, genFn) {
      let opts = []
      for(let arr of genFn()) {
        for (let i = 0; i < arr.length; ++i) {
          if (b !== null) {
            arr[i][1].b = b + i
          }
          if (p !== null) {
            arr[i][1].p = p + i
          }
          opts.push(arr[i]);
        }
      }
      return opts
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
}

module.exports = ParamOptions
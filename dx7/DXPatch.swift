
//public protocol DXPatch : YamahaSinglePatch {
//  var opOns: [Int] { get set }
//}
//
//public extension DXPatch {
//
//  subscript(path: SynthPath) -> Int? {
//    get {
//      guard let param = type(of: self).params[path] else { return nil }
//      guard param.parm > 0 else { return unpack(param: param) }
//      return opOns[path.i(1) ?? 0]
//    }
//    set {
//      guard let param = type(of: self).params[path],
//        let newValue = newValue else { return }
//      guard param.parm > 0 else { return pack(value: newValue, forParam: param) }
//      opOns[path.i(1) ?? 0] = newValue
//    }
//  }
//  
//}

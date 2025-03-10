
extension XV2020 {
  
  enum Global {
    
    static let patchWerk = XV.sysexWerk.multiPatchWerk("Global", [
      ([.common], 0x0000, XV5050.Global.Common.patchWerk),
    ], start: 0x02000000, initFile: "xv2020-global-init")
    
  }
  
}

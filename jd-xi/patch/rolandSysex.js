require('/core/ArrayUtils.js')

function rolandChecksum(address, dataBytes, addressCount) {
  const total = address.sysexBytes(addressCount).sum() + dataBytes.sum()
  return 0x7f & (128 - (total % 128))
}

function rolandSysex(obj, addressCount) {
  obj.addressCount = addressCount
  obj.checksum = (address, dataBytes) => rolandChecksum(address, dataBytes, addressCount)
}

// static func rolandTransform(_ sysexibles: [SynthPath:Sysexible]) -> [SynthPath:RolandTemplatedSysexible] {
//   let rArr: [(SynthPath, RolandTemplatedSysexible)] = sysexibles.compactMap {
//     guard let r = $0.value as? RolandTemplatedSysexible else { return nil }
//     return ($0.key, r)
//   }
//   return rArr.dictionary { [$0.0 : $0.1] }
// }

// public protocol RolandSinglePatchTemplate : RolandPatchTemplate, SinglePatchTemplate {
//   
//   static func sysexData(_ bytes: [UInt8], deviceId: UInt8, address: RolandAddress) -> [UInt8]
// 
//   /// Compose Int value from bytes (MSB first)
//   static func multiByteParamInt(from: [UInt8]) -> Int
//   /// Decompose Int to bytes (4 bits at a time)
//   static func multiByteParamBytes(from: Int, count: Int) -> [UInt8]
// 
// }

  /// Param parm > 1 -> multi-byte parameter
function defaultRolandUnpack(bodyData, param) {
  const byteCount = param.parm
  const byte = RolandAddress(param.byte).intValue()

  if (byteCount == 1)  {
    return defaultUnpack(byte, param.bits, bodyData)
  }
  
  if (byte + byteCount > bodyData.count) { return null }
  
  return multiByteParamInt(bodyData.safeBytes(byte, byte + byteCount))
}

/// Param parm > 1 -> multi-byte parameter
function defaultRolandPack(bodyData, param, value) {
  // NOTE: this multi-byte style is for JV-1080 (and beyond?)
  //  JD-800 uses all 7 bits of LSB, not just 4.
  const byteCount = param.parm
  // roland byte addresses in params are *Roland* addresses
  const byte = RolandAddress(param.byte).intValue()
  if (byteCount == 1) {
    bodyData[byte] = defaultPackedByte(value, param, bodyData[byte])
    return
  }
  
  let b = multiByteParamBytes(value, byteCount)
  b.forEachWithIndex((elem, i) => bodyData[byte + i] = elem)
}

// MARK: Roland Single Patch

/// Compose Int value from bytes (MSB first)
function multiByteParamInt(bytes) {
  const count = bytes.length
  if (count == 1) { return bytes[0] }
  return (count).map((i) => (bytes[i] << ((count - (i + 1)) * 4))).sum()
}

/// Decompose Int to bytes (4 bits at a time)
function multiByteParamBytes(from, count) {
  if (count == 0) { return [from] }
  return (count).map((i) => (from >> (((count + 1) - i) * 4)) & 0xf)
}


function rolandSinglePatch(obj) {
  // actual data size
  obj.realSize = obj.size.intValue()  
  obj.unpack = defaultRolandUnpack
  obj.pack = defaultRolandPack
  
  // 5 byte header (f0, manufac, model, deviceID, set cmd)
  // address bytes
  // data
  // checksum, end byte
  obj.fileDataCount = obj.dataSetHeaderCount + obj.realSize + 2
  
  obj.bytes = (fileData) => fileData.safeBytes(obj.dataSetHeaderCount, obj.dataSetHeaderCount + obj.realSize)

  obj.sysexData = function(bytes, deviceId, address) {
    return obj.dataSetHeader(deviceId) + address.sysexBytes(obj.addressCount) + bytes + [obj.checksum(address, bytes), 0xf7]
  }
  
  obj.fileData = (bodyData) => obj.sysexData(bodyData, 16, obj.startAddress(null))
}

  // static func paramSetData(_ bytes: [UInt8], deviceId: UInt8, address: RolandAddress, path: SynthPath) -> [UInt8] {
  //   guard let param = params[path],
  //     param.byte >= 0 else { return [] } // deviceId param is byte: -1
  //   let byte = RolandAddress(param.byte).intValue() // param.byte should be roland address
  //   let paramAddress = address + RolandAddress(param.byte)
  //   // parm == 0 is default for Param(), so set byteCount 1. Otherwise, whatever's specified.
  //   let byteCount = param.parm == 0 ? 1 : param.parm
  //   let valueBytes = Array(bytes[byte..<(byte + byteCount)])
  //   return dataSetHeader(deviceId: deviceId) + paramAddress.sysexBytes(count: addressCount) + valueBytes + [checksum(address: paramAddress, dataBytes: valueBytes), 0xf7]
  // }
  // 
  // static func nameSetData(_ bytes: [UInt8], deviceId: UInt8, address: RolandAddress) -> [UInt8] {
  //   guard let nameByteRange = nameByteRange else { return [] }
  //   let nameAddress = address + RolandAddress(intValue: nameByteRange.lowerBound)
  //   let nameBytes = Array(bytes[nameByteRange])
  //   return dataSetHeader(deviceId: deviceId) + nameAddress.sysexBytes(count: addressCount) + nameBytes + [checksum(address: nameAddress, dataBytes: nameBytes), 0xf7]
  // }
  
  // MARK: Roland Multi Patch
    
  public typealias RolandMapItem = (path: SynthPath, address: RolandAddress, patch: RolandPatchTemplate.Type)
  
  public protocol RolandMultiPatchTemplate : MultiPatchTemplate, RolandPatchTemplate {
    static var rolandMap: [RolandMapItem] { get }
    static func sysexData(_ sysexibles: [SynthPath:RolandTemplatedSysexible], deviceId: UInt8, address: RolandAddress) -> [[UInt8]]
  }
  
  public extension RolandMultiPatchTemplate {
    
    static var subpatchTypes: [(SynthPath, TemplatedPatch.Type)] {
      rolandMap.map { ($0.path, $0.patch.templatedPatchType) }
    }
    
    static func mapItem(path: SynthPath) -> RolandMapItem? {
      rolandMap.first { $0.path == path }
    }
  
    static var namePath: SynthPath? { [.common] }
    
    static var realSize: Int {
      rolandMap.map { $0.patch.realSize }.reduce(0, +)
    }
    
    static var size: RolandAddress {
      // take the largest address, and add the size of the corresponding subpatch
      guard let maxItem = rolandMap.sorted(by: { $0.address > $1.address }).first else { return 0 }
      return maxItem.address + maxItem.patch.size
    }
    
    static func subpatches(data: Data) -> [SynthPath : SysexPatch] {
      defaultAddressables(forData: data)
    }
      
    static func addressBytes(forSysex sysex: Data) -> [UInt8] {
      guard sysex.count >= dataSetHeaderCount else { return [] }
      return Array(sysex[(dataSetHeaderCount-addressCount)..<(dataSetHeaderCount)])
    }
  
    static func address(forSysex sysex: Data) -> RolandAddress {
      return RolandAddress(addressBytes(forSysex: sysex))
    }
  
    static func defaultAddressables(forData data: Data) -> [SynthPath:SysexPatch] {
      let sysex = SysexData(data: data)
  
      // determine the base address of the fetched data
      let baseAdd = sysex.map { address(forSysex: $0) }.sorted(by: { $0 < $1 }).first
      guard let baseAddress = baseAdd else {
        // if no base address found, init subpatches
        return rolandMap.dictionary { [$0.path : $0.patch.templatedPatchType.init()] }
      }
      
      var subpatchData = [Int:Data]()
      sysex.forEach { msg in
        let offsetAddress = address(forSysex: msg) - baseAddress
        // find key that matches the offset address
        guard let index = mapIndex(address: offsetAddress, sysex: msg) else { return }
        subpatchData[index] = (subpatchData[index] ?? Data()) + msg
      }
  
      var p = [SynthPath:SysexPatch]()
      subpatchData.forEach { (index, data) in
        let item = rolandMap[index]
        p[item.path] = item.patch.templatedPatchType.init(data: data)
      }
  
      // for any unfilled subpatches, init them
      rolandMap.forEach {
        guard p[$0.path] == nil else { return }
        p[$0.path] = $0.patch.templatedPatchType.init()
      }
  
      return p
    }
    
    static func mapIndex(address: RolandAddress, sysex: Data) -> Int? {
      for (i, item) in rolandMap.enumerated() {
        if let template = item.patch as? RolandSinglePatchTemplate.Type,
           address == item.address && template.isValid(sysex: sysex) {
          return i
        }
        else if let template = item.patch as? RolandMultiPatchTemplate.Type,
                template.mapIndex(address: address - item.address, sysex: sysex) != nil {
          return i
        }
      }
      return nil
    }
  
  
    static func sysexData(_ sysexibles: [SynthPath:RolandTemplatedSysexible], deviceId: UInt8, address: RolandAddress) -> [[UInt8]] {
      defaultSysexData(sysexibles, deviceId: deviceId, address: address)
    }
  
    static func defaultSysexData(_ subpatches: [SynthPath:RolandTemplatedSysexible], deviceId: UInt8, address: RolandAddress) -> [[UInt8]] {
      rolandMap.compactMap {
        subpatches[$0.path]?.sysexData(deviceId: deviceId, address: $0.address + address)
      }.reduce([], +)
    }
    
    static func fileData(_ subpatches: [SynthPath:SysexPatch]) -> [UInt8] {
      return sysexData(rolandTransform(subpatches), deviceId: UInt8(RolandDefaultDeviceId), address: startAddress(nil)).reduce([], +)
    }
  
  
    // MARK: Compact data
    
    static func addressables(forCompactData data: Data) -> [SynthPath:SysexPatch] {
      // if there's more than one sysex msg, we need to:
      // sort them by base address
      let sortedMsgs = SysexData(data: data).sorted { return address(forSysex: $0) < address(forSysex: $1) }
      // concat the meat of the sysex msgs (stuff without header and footer)
      let meat = sortedMsgs.map { $0[dataSetHeaderCount..<($0.count-2)] }.reduce(Data(), +)
      // then iterate through it, making subpatches
      var dataIndex = 0
  
      return rolandMap.sorted { $0.address < $1.address }.dictionary {
        let subdataMeatCount = $0.patch.fileDataCount - (dataSetHeaderCount + 2)
        let meatRange = dataIndex..<(dataIndex + subdataMeatCount)
        guard meatRange.endIndex <= meat.count else { return [:] }
        dataIndex += subdataMeatCount
  
        let subdata = dataSetHeaderCount.map { 0 } + [UInt8](meat[meatRange]) + [0, 0]
        return [$0.path : $0.patch.templatedPatchType.init(data: Data(subdata))]
      }
    }
    
    /// The size of a sysex file for this patch when stored in compact format (256 data bytes per msg except last)
    static var compactFileDataCount: Int {
      // the realsize of all the subpatches put together, plus header and footer
      let msgHeadFoot = dataSetHeaderCount + 2 // extra data per message
      let msgCount = Int(ceil(Float(realSize) / 256)) // the number of msgs this will need to be split into
      return realSize + (msgCount * msgHeadFoot)
    }
  
  }


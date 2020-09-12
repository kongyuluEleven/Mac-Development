//
//  ImageErrors.swift
//
//  Created by Evan Xie on 2019/5/28.
//

import Foundation
import CoreVideo

enum ImageError: Swift.Error {
    case coreMediaError(OSStatusWrapper)
    case coreVideoError(CVReturnWrapper)
    case errorWithReason(String)
    
    var localizedDescription: String {
        switch self {
        case .coreMediaError(let code):
            return code.description
        case .coreVideoError(let code):
            return code.description
        case .errorWithReason(let reason):
            return reason
        }
    }
}

/// `CVReturn` 的包装，你可以在 [Apple Error Codes Lookup](https://www.osstatus.com)
/// 找到所有 `CVReturn` 可能的数值及具体含义。
struct CVReturnWrapper: CustomStringConvertible, Equatable {
    
    let code: CVReturn
    
    var isSuccess: Bool {
        return code == kCVReturnSuccess
    }
    
    var fourCharCodeString: String {
        return code.fourCharCodeString
    }
    
    init(_ code: CVReturn) {
        self.code = code
    }
    
    var description: String {
        switch code {
        case kCVReturnInvalidArgument:
            return "\(code): At least one of the arguments passed in is not valid. Either out of range or the wrong type."
        case kCVReturnAllocationFailed:
            return "\(code): The allocation for a buffer or buffer pool failed. Most likely because of lack of resources."
        case kCVReturnInvalidPixelFormat:
            return "\(code): The requested pixelformat is not supported for the CVBuffer type."
        case kCVReturnInvalidSize:
            return "\(code): The requested size (most likely too big) is not supported for the CVBuffer type."
        case kCVReturnInvalidPixelBufferAttributes:
            return "\(code): A CVBuffer cannot be created with the given attributes."
        case kCVReturnPixelBufferNotOpenGLCompatible:
            return "\(code): The Buffer cannot be used with OpenGL as either its size, pixelformat or attributes are not supported by OpenGL."
        case kCVReturnPixelBufferNotMetalCompatible:
            return "\(code): The Buffer cannot be used with Metal as either its size, pixelformat or attributes are not supported by Metal."
        case kCVReturnWouldExceedAllocationThreshold:
            return "\(code): The allocation request failed because it would have exceeded a specified allocation threshold (see kCVPixelBufferPoolAllocationThresholdKey)."
        case kCVReturnPoolAllocationFailed:
            return "\(code): The allocation for the buffer pool failed. Most likely because of lack of resources. Check if your parameters are in range."
        case kCVReturnInvalidPoolAttributes:
            return "\(code): A CVBufferPool cannot be created with the given attributes."
        case kCVReturnRetry:
            return  "\(code): A scan hasn't completely traversed the CVBufferPool due to a concurrent operation. The client can retry the scan."
        default:
            return "\(code): \(fourCharCodeString))"
        }
    }
    
    static func == (lhs: CVReturnWrapper, rhs: CVReturnWrapper) -> Bool {
        return lhs.code == rhs.code
    }
    
    static func != (lhs: CVReturnWrapper, rhs: CVReturnWrapper) -> Bool {
        return lhs.code != rhs.code
    }
}

/// `OSStatus` 的包装，你可以在 [Apple Error Codes Lookup](https://www.osstatus.com)
/// 找到所有 `OSStatus` 可能的数值及具体含义。
struct OSStatusWrapper: CustomStringConvertible, Equatable {
    
    let code: OSStatus

    var isSuccess: Bool {
        return code == noErr
    }
    
    var fourCharCodeString: String {
        return code.fourCharCodeString
    }
    
    init(_ code: OSStatus) {
        self.code = code
    }
    
    var description: String {
        return "\(code): \(fourCharCodeString))"
    }
    
    static func == (lhs: OSStatusWrapper, rhs: OSStatusWrapper) -> Bool {
        return lhs.code == rhs.code
    }
    
    static func != (lhs: OSStatusWrapper, rhs: OSStatusWrapper) -> Bool {
        return lhs.code != rhs.code
    }
}

extension UInt32 {
    
    var fourCharCodeString: String {
        let utf16 = [
            UInt16((self >> 24) & 0xFF),
            UInt16((self >> 16) & 0xFF),
            UInt16((self >> 8) & 0xFF),
            UInt16((self & 0xFF))
        ]
        return String(utf16CodeUnits: utf16, count: 4)
    }
}

extension Int32 {
    
    var fourCharCodeString: String {
        return UInt32(self).fourCharCodeString
    }
}

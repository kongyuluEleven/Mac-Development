//
//  NSAppearance+base.swift
//  KYLMacUIKit
//
//  Created by kongyulu on 2021/11/27.
//

#if canImport(AppKit) && !targetEnvironment(macCatalyst)
import AppKit

public extension NSAppearance {
    
    /// 是否是暗黑模式，深色模式
    var isDarkMode: Bool { if #available(OSX 10.14, *) {
       return bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
    } else {
        // Fallback on earlier versions
        return false
    } }
}


#endif

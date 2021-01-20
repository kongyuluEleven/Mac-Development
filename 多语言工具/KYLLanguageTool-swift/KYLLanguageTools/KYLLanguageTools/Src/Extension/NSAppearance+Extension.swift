//
//  NSAppearance+Extension.swift
//  WSUIKit
//
//  Created by kongyulu on 2021/1/19.
//

#if canImport(AppKit) && !targetEnvironment(macCatalyst)
import AppKit

extension NSAppearance {
    
    /// 是否是暗黑模式，深色模式
    var isDarkMode: Bool { if #available(OSX 10.14, *) {
       return bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
    } else {
        // Fallback on earlier versions
        return false
    } }
}


#endif

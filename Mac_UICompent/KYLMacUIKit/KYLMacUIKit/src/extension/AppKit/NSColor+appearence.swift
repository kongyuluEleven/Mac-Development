//
//  NSColor+appearence.swift
//  KYLMacUIKit
//
//  Created by kongyulu on 2021/11/27.
//

#if canImport(AppKit) && !targetEnvironment(macCatalyst)
import AppKit

// MARK: - 换肤
public extension NSColor {
    
    /// 皮肤模式
    enum Appearance:String {
        //深色模式
        case dark = "dark"
        //浅色模式
        case light = "light"
        
        
        /// 根据深浅模式，获取完整图片名称，适配深浅模式
        /// - Parameter imageName: 原始图片名称
        /// - Returns: 根据深浅模式，适配后的完整图片名称
        func fullImageName(imageName:String) -> String {
            return imageName + "_\(self.rawValue)"
        }
    }
    
    
    /// 当前系统深浅模式
    /// - Returns: 返回当前系统设置的深浅模式
    class func currentAppearance() ->Appearance {
        if #available(OSX 10.14, *){
            if NSApp.appearance == NSAppearance(named: .aqua){
                return .light
            }
            if NSApp.appearance == nil ,NSAppearance.current == NSAppearance(named: .aqua){
                return .light
            }
        }
        return .dark
    }
}


#endif

//
//  NSFont+base.swift
//  KYLMacUIKit
//
//  Created by kongyulu on 2021/11/27.
//

#if canImport(UIKit)
import UIKit
/// WS: IOS Font
public typealias WSFont = UIFont
#endif

#if canImport(AppKit) && !targetEnvironment(macCatalyst)
import AppKit
/// WS: Mac Font
public typealias WSFont = NSFont
#endif

#if canImport(AppKit) && !targetEnvironment(macCatalyst)
import AppKit


/// 返回一个系统默认字体的NSFont对象
///
/// let font = systemFont(10)  => 返回一个大小为10号的系统默认字体
///
/// - Parameter size: 字体大小
/// - Returns: 一个系统默认字体，大小为size的NSFont对象
public func systemFont(_ size:CGFloat) ->NSFont {
    
    if #available(OSX 10.11, *) {
        return NSFont.systemFont(ofSize: size, weight: NSFont.Weight.regular)
    } else {
        return NSFont.init(name: "HelveticaNeue", size: size)!
    }
}

public func systemMediumFont(_ size:CGFloat) ->NSFont {
    
    if #available(OSX 10.11, *) {
        return NSFont.systemFont(ofSize: size, weight: NSFont.Weight.semibold)
    } else {
        return NSFont.init(name: "HelveticaNeue-Medium", size: size)!
    }
    
}

public func systemBoldFont(_ size:CGFloat) ->NSFont {
    
    if #available(OSX 10.11, *) {
        return NSFont.systemFont(ofSize: size, weight: NSFont.Weight.bold)
    } else {
        return NSFont.init(name: "HelveticaNeue-Bold", size: size)!
    }
}

public extension NSFont {
    class func normal(_ size:FontSize) ->NSFont {
        
        if #available(OSX 10.11, *) {
            return NSFont.systemFont(ofSize: convert(from:size), weight: NSFont.Weight.regular)
        } else {
            return NSFont(name: "HelveticaNeue", size: convert(from:size))!
        }
    }
    
    class func italic(_ size: FontSize) -> NSFont {
        return NSFontManager.shared.convert(.normal(size), toHaveTrait: .italicFontMask)
    }
    
    class func avatar(_ size: FontSize) -> NSFont {
        
        if let font = NSFont(name: ".SFCompactRounded-Semibold", size: convert(from:size)) {
            return font
        } else {
            return .medium(size)
        }
    }
    
    class func medium(_ size:FontSize) ->NSFont {
        
        if #available(OSX 10.11, *) {
            return NSFont.systemFont(ofSize: convert(from:size), weight: NSFont.Weight.medium)
        } else {
            return NSFont(name: "HelveticaNeue-Medium", size: convert(from:size))!
        }
        
    }
    
    class func bold(_ size:FontSize) ->NSFont {
        
        if #available(OSX 10.11, *) {
            return NSFont.systemFont(ofSize: convert(from:size), weight: NSFont.Weight.bold)
        } else {
            return NSFont(name: "HelveticaNeue-Bold", size: convert(from:size))!
        }
    }
    
    class func code(_ size:FontSize) ->NSFont {
        return NSFont(name: "Menlo-Regular", size: convert(from:size)) ?? NSFont.systemFont(ofSize: 17.0)
    }
}

public enum FontSize {
    case small
    case short
    case text
    case title
    case header
    case huge
    case custom(CGFloat)
}

fileprivate func convert(from s:FontSize) -> CGFloat {
    switch s {
    case .small:
        return 11.0
    case .short:
        return 12.0
    case .text:
        return 13.0
    case .title:
        return 14.0
    case .header:
        return 15.0
    case .huge:
        return 18.0
    case let .custom(size):
        return size
    }
}


#endif

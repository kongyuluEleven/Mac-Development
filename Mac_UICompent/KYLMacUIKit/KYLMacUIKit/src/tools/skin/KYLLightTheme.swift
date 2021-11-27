//
//  KYLLightTheme.swift
//  KYLMacUIKit
//
//  Created by kongyulu on 2021/11/27.
//

#if canImport(Foundation)
import Foundation

/// 浅色模式主题 (默认的主题).
@objc(KYLLightTheme)
public class KYLLightTheme: NSObject, KYLTheme {

    //MARK: -----------------public-------------------
    /// 主题唯一标识符  (static).
    @objc public static var identifier: String = "com.wondershare.WSUIKit.WSLightTheme"

    /// 主题唯一标识符
    public var identifier: String = KYLLightTheme.identifier

    /// 主题名称
    public var displayName: String = "Light Theme"

    /// 主题名称简写
    public var shortDisplayName: String = "Light"

    /// 是否暗黑模式
    public var isDarkTheme: Bool = false

    /// 描述信息，用于打印
    override public var description: String {
        return "<\(KYLLightTheme.self): \(themeDescription(self))>"
    }
    
    //MARK: -----------------private-------------------
    
    /// 不能在外部调用init()的方式，使用这种： `KYLThemeManager.lightTheme`
    internal override init() {
        super.init()
    }

    
}

#endif

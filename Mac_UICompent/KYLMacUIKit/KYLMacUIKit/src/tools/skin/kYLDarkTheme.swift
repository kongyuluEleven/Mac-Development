//
//  kYLDarkTheme.swift
//  KYLMacUIKit
//
//  Created by kongyulu on 2021/11/27.
//

#if canImport(Foundation)
import Foundation

/// 暗黑模式皮肤主题
@objc(KYLDarkTheme)
public class KYLDarkTheme: NSObject, KYLTheme {

    //MARK: -----------------public-------------------
    /// 主题唯一标识符
    @objc public static var identifier: String = "com.wondershare.WSUIKit.WSDarkTheme"

    /// 主题唯一标识符
    public var identifier: String = KYLDarkTheme.identifier

    /// 主题名称
    public var displayName: String = "Dark Theme"

    /// 主题名称简写
    public var shortDisplayName: String = "Dark"

    /// 是否是暗黑模式
    public var isDarkTheme: Bool = true

    /// 主题描述，用于打印信息
    override public var description: String {
        return "<\(KYLDarkTheme.self): \(themeDescription(self))>"
    }
    
    //MARK: -----------------private-------------------
    /// 不能在外部调用Init() 方法创建， 使用：`KYLThemeManager.darkTheme` 替换
    internal override init() {
        super.init()
    }
}

#endif


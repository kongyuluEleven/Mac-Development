//
//  NSApplication+base.swift
//  KYLMacUIKit
//
//  Created by kongyulu on 2021/11/27.
//

#if canImport(AppKit) && !targetEnvironment(macCatalyst)
import AppKit

// MARK: - 环境变量

public extension NSApplication {

    enum Environment {
        /// 调试模式
        case debug
        /// Web版本 release
        case release
        /// appstore debug
        case appStoreDebug
        /// appstore release
        case appStoreRelease
    }

    /// 当前运行环境
    var inferredEnvironment: Environment {
        #if DEBUG
            #if APPSTORE
            return .appStoreDebug
            #else
            return .debug
            #endif
        #else
            #if APPSTORE
            return .appStoreRelease
            #else
            return .release
            #endif
        #endif
    }
    
    /// 应用程序名称(如果适用)。
    var displayName: String? {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
    }

    /// 应用程序当前构建号(如果适用)。
    var buildNumber: String? {
        return Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as? String
    }

    /// 应用程序的当前版本号(如果适用)。
    var version: String? {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
    }
}

#endif

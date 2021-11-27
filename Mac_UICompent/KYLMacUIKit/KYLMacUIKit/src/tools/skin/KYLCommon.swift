//
//  KYLCommon.swift
//  KYLMacUIKit
//
//  Created by kongyulu on 2021/11/27.
//

#if canImport(Foundation)
import Foundation

#if canImport(AppKit) && !targetEnvironment(macCatalyst)
import AppKit
#endif

func CacheKey(selector: Selector) -> NSNumber {
    return CacheKey(selector: selector, colorSpace: nil, theme: nil)
}

func CacheKey(selector: Selector, colorSpace: NSColorSpace?) -> NSNumber {
    return CacheKey(selector: selector, colorSpace: colorSpace, theme: nil)
}

func CacheKey(selector: Selector, theme: KYLTheme?) -> NSNumber {
    return CacheKey(selector: selector, colorSpace: nil, theme: theme)
}

func CacheKey(selector: Selector, colorSpace: NSColorSpace?, theme: KYLTheme?) -> NSNumber {
    let hashValue = selector.hashValue ^ (colorSpace == nil ? 0 : (colorSpace!.hashValue << 4)) ^ (theme == nil ? 0 : (theme!.hash << 8))
    return NSNumber(value: hashValue)
}

#endif

//
//  Locale+Extension.swift
//  WSUIKit
//
//  Created by kongyulu on 2021/1/8.
//

#if canImport(Foundation)
import Foundation

// MARK: - 属性

public extension Locale {
    /// UNIX语言环境表示通常用于规范化
    static var posix: Locale {
        return Locale(identifier: "en_US_POSIX")
    }

    /// 返回bool值，指示区域设置是否为12h格式。
    var is12HourTimeFormat: Bool {
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .short
        dateFormatter.dateStyle = .none
        dateFormatter.locale = self
        let dateString = dateFormatter.string(from: Date())
        return dateString.contains(dateFormatter.amSymbol) || dateString.contains(dateFormatter.pmSymbol)
    }
}

// MARK: - 方法

public extension Locale {
    /// 获取给定国家和地区代码的旗帜表情符号。
    ///
    ///  let emoji = Locale.flagEmoji(forRegionCode: "CN")
    ///  print("\(String(describing: emoji))") => Optional("🇨🇳")
    ///
    /// - Parameter isoRegionCode: ISO区域码。
    ///
    /// Adapted from https://stackoverflow.com/a/30403199/1627511
    static func flagEmoji(forRegionCode isoRegionCode: String) -> String? {
        #if !os(Linux)
        guard isoRegionCodes.contains(isoRegionCode) else { return nil }
        #endif

        return isoRegionCode.unicodeScalars.reduce(into: String()) {
            guard let flagScalar = UnicodeScalar(UInt32(127_397) + $1.value) else { return }
            $0.unicodeScalars.append(flagScalar)
        }
    }
}

#endif

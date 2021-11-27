//
//  NSColor+base.swift
//  KYLMacUIKit
//
//  Created by kongyulu on 2021/11/27.
//

#if canImport(UIKit)
import UIKit
/// WSColor : 颜色别名，用于统一IOS和Mac平台使用
public typealias WSColor = UIColor
#endif

#if canImport(AppKit)
import AppKit
/// WSColor : 颜色别名，用于统一IOS和Mac平台使用
public typealias WSColor = NSColor
#endif


#if canImport(CoreGraphics)
import CoreGraphics

// MARK: - Properties

public extension CGColor {
    #if canImport(UIKit)
    /// WS: UIColor. IOS 平台使用
    var uiColor: UIColor? {
        return UIColor(cgColor: self)
    }
    #endif

    #if canImport(AppKit) && !targetEnvironment(macCatalyst)
    /// WS: NSColor.  Mac 平台使用
    var nsColor: NSColor? {
        return NSColor(cgColor: self)
    }
    #endif
}

#endif


#if canImport(AppKit) && !targetEnvironment(macCatalyst)
import AppKit


// MARK: - 便利构造函数
public extension NSColor {
    
    /// 创建一个深浅模式的NSColor 对象
    ///
    /// let color = NSColor(light: .red, dark: .white)  => 返回一个颜色对象，自动跟随系统颜色变化，
    ///   浅色模式下为红色，暗黑模式下为白色。
    ///   此函数只在10.15以上系统有用
    ///
    /// - Parameters:
    ///     - light: 浅色模式的颜色
    ///     - dark: 深色模式的颜色
    @available(OSX 10.15, *)
    convenience init(light: NSColor, dark: NSColor) {
        self.init(name: nil, dynamicProvider: { $0.name == .darkAqua ? dark : light })
    }
    
    
    /// 创建颜色从RGB值可选透明度
    ///
    ///
    /// let color = NSColor(red:255,green::0,blue:0)  => 返回一个颜色为红色的NSColor对象
    /// let color =NSColor(red:255,green::0,blue:0, alpha:0.5)   => 返回一个颜色为红色,透明度为0.5 的NSColor对象
    ///
    /// - Parameters:
    ///   - red: 红色值，大小为0~255
    ///   - green: 绿色值，大小为0~255
    ///   - blue: 蓝色色值，大小为0~255
    ///   - alpha: 可选的透明度值(默认为1)。
    convenience init?(red: Int, green: Int, blue: Int, alpha: CGFloat = 1) {
        guard red >= 0, red <= 255 else { return nil }
        guard green >= 0, green <= 255 else { return nil }
        guard blue >= 0, blue <= 255 else { return nil }

        var trans = alpha
        if trans < 0 { trans = 0 }
        if trans > 1 { trans = 1 }

        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: trans)
    }
    

    /// 创建十六进制值的颜色和可选的透明度。
    ///
    ///
    /// let color = NSColor(hex: 0xFFFFF) =》  创建一个颜色为白色的NSColor对象，透明度为1, 等价于 NSColor.white
    /// let color = NSColor(hex: 0xFFFFF， alpha:0.5) =》  创建一个颜色为白色的NSColor对象, 透明度为0.5
    ///
    /// - Parameters:
    ///   - hex: 十六进制Int(例如:0xDECEB5)。
    ///   - alpha: 可选的透明度值(默认为1)。
    convenience init?(hex: Int, alpha: CGFloat = 1) {
        var trans = alpha
        if trans < 0 { trans = 0 }
        if trans > 1 { trans = 1 }

        let red = (hex >> 16) & 0xFF
        let green = (hex >> 8) & 0xFF
        let blue = hex & 0xFF
        self.init(red: red, green: green, blue: blue, alpha: trans)
    }

    /// 创建十六进制字符串的颜色和可选的透明度(如果适用)。
    ///
    ///
    /// let color = NSColor(hexString: "#0xFFFFF") =》  创建一个颜色为白色的NSColor对象，透明度为1, 等价于 NSColor.white
    /// let color = NSColor(hexString: "#0xFFFFF", alpha:0.5) =》  创建一个颜色为白色的NSColor对象, 透明度为0.5
    ///
    /// - Parameters:
    ///   - hexString: 十六进制字符串 (例如: EDE7F6, 0xEDE7F6, #EDE7F6, #0ff, 0xF0F, ..).
    ///   - alpha: 可选的透明度值(默认为1)。
    convenience init?(hexString: String, alpha: CGFloat = 1) {
        var string = ""
        if hexString.lowercased().hasPrefix("0x") {
            string = hexString.replacingOccurrences(of: "0x", with: "")
        } else if hexString.hasPrefix("#") {
            string = hexString.replacingOccurrences(of: "#", with: "")
        } else {
            string = hexString
        }

        if string.count == 3 { // 将十六进制转换为6位数字格式，如果在短格式
            var str = ""
            string.forEach { str.append(String(repeating: String($0), count: 2)) }
            string = str
        }

        guard let hexValue = Int(string, radix: 16) else { return nil }

        var trans = alpha
        if trans < 0 { trans = 0 }
        if trans > 1 { trans = 1 }

        let red = (hexValue >> 16) & 0xFF
        let green = (hexValue >> 8) & 0xFF
        let blue = hexValue & 0xFF
        self.init(red: red, green: green, blue: blue, alpha: trans)
    }

    /// 用一种颜色的互补来创造颜色(如果适用的话)。
    ///
    /// - Parameter color: 需要相反颜色的颜色。
    convenience init?(complementaryFor color: NSColor) {
        let colorSpaceRGB = CGColorSpaceCreateDeviceRGB()
        let convertColorToRGBSpace: ((_ color: NSColor) -> NSColor?) = { color -> NSColor? in
            if color.cgColor.colorSpace!.model == CGColorSpaceModel.monochrome {
                let oldComponents = color.cgColor.components
                let components: [CGFloat] = [oldComponents![0], oldComponents![0], oldComponents![0], oldComponents![1]]
                let colorRef = CGColor(colorSpace: colorSpaceRGB, components: components)
                let colorOut = NSColor(cgColor: colorRef!)
                return colorOut
            } else {
                return color
            }
        }

        let color = convertColorToRGBSpace(color)
        guard let componentColors = color?.cgColor.components else { return nil }

        let red: CGFloat = sqrt(pow(255.0, 2.0) - pow(componentColors[0] * 255, 2.0)) / 255
        let green: CGFloat = sqrt(pow(255.0, 2.0) - pow(componentColors[1] * 255, 2.0)) / 255
        let blue: CGFloat = sqrt(pow(255.0, 2.0) - pow(componentColors[2] * 255, 2.0)) / 255
        self.init(red: red, green: green, blue: blue, alpha: 1.0)
    }
    
    
    /// 构造函数，根据十六进制颜色值，创建一个NSColor对象
    /// - Parameter argb: 十六进制表示的颜色RGBA值：如0xFFFFF
    convenience init(argb: Int) {
        let a = (argb >> 24) & 0xFF
        let r = (argb >> 16) & 0xFF
        let g = (argb >> 8) & 0xFF
        let b = argb & 0xFF
        
        self.init(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: CGFloat(a) / 255.0)
    }
    
    
    /// 构造函数，根据十六进制颜色值，创建一个NSColor对象
    /// - Parameters:
    ///   - rgb: 十六进制表示的颜色RGB值：如0xFFFFF
    ///   - alpha: 透明度值
    convenience init(rgb: Int, alpha: CGFloat) {
        let r = (rgb >> 16) & 0xFF
        let g = (rgb >> 8) & 0xFF
        let b = rgb & 0xFF
        
        self.init(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: alpha)
    }
    
    
    /// 构造函数，根据R，G，B 三个色值，创建一个NSColor对象
    /// - Parameters:
    ///   - red: 红色值，大小为0~255
    ///   - green: 绿色值，大小为0~255
    ///   - blue: 蓝色值，大小为0~255
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    /// 获取16位字符串颜色 类方法
    /// - Parameter hexStr: 6位字符串颜色 例如：0xFFFFF
    /// - Returns: 返回对应的颜色对象NSColor
    class func hexColor(_ hexStr: String)-> NSColor? {
        return NSColor.init(hexString: hexStr) ?? nil
    }
}

// MARK: - 获取颜色属性值
public extension NSColor {
    
    /// 获取一个随机颜色值的NSColor对象
    static var random: NSColor {
        let red = Int.random(in: 0...255)
        let green = Int.random(in: 0...255)
        let blue = Int.random(in: 0...255)
        return NSColor(red: red, green: green, blue: blue)
    }
    /// 获取透明度
    var alpha: CGFloat {
        var a: CGFloat = 0
        getRed(nil, green: nil, blue: nil, alpha: &a)
        return a
    }
    
    
    /// 红色色值
    var r: CGFloat {
        var r: CGFloat = 0
        getRed(&r, green: nil, blue: nil, alpha: nil)
        return r
    }
    
    
    /// 绿色色值
    var g: CGFloat {
        var g: CGFloat = 0
        getRed(nil, green: &g, blue: nil, alpha: nil)
        return g
    }
    
    
    /// 蓝色色值
    var b: CGFloat {
        var b: CGFloat = 0
        getRed(nil, green: nil, blue: &b, alpha: nil)
        return b
    }
    
    
    var hue: CGFloat {
        var h: CGFloat = 0
        getHue(&h, saturation: nil, brightness: nil, alpha: nil)
        return h
    }
    
    var saturation: CGFloat {
        var s: CGFloat = 0
        getHue(nil, saturation: &s, brightness: nil, alpha: nil)
        return s
    }
    
    var brightness: CGFloat {
        var b: CGFloat = 0
        getHue(nil, saturation: nil, brightness: &b, alpha: nil)
        return b
    }
    
    /// 16进制值字符串(只读)。
    var hexString: String {
        let components: [Int] = {
            let comps = cgColor.components!.map { Int($0 * 255.0) }
            guard comps.count != 4 else { return comps }
            return [comps[0], comps[0], comps[0], comps[1]]
        }()
        return String(format: "#%02X%02X%02X", components[0], components[1], components[2])
    }

    /// 短16进制值字符串
    var shortHexString: String? {
        let string = hexString.replacingOccurrences(of: "#", with: "")
        let chrs = Array(string)
        guard chrs[0] == chrs[1], chrs[2] == chrs[3], chrs[4] == chrs[5] else { return nil }
        return "#\(chrs[0])\(chrs[2])\(chrs[4])"
    }

    /// 短十六进制值字符串，如果不可能，则为全十六进制字符串(只读)。
    var shortHexOrHexString: String {
        let components: [Int] = {
            let comps = cgColor.components!.map { Int($0 * 255.0) }
            guard comps.count != 4 else { return comps }
            return [comps[0], comps[0], comps[0], comps[1]]
        }()
        let hexString = String(format: "#%02X%02X%02X", components[0], components[1], components[2])
        let string = hexString.replacingOccurrences(of: "#", with: "")
        let chrs = Array(string)
        guard chrs[0] == chrs[1], chrs[2] == chrs[3], chrs[4] == chrs[5] else { return hexString }
        return "#\(chrs[0])\(chrs[2])\(chrs[4])"
    }
    
    /// 获取颜色的UInt表示(只读)。
    var uInt: UInt {
        let components: [CGFloat] = {
            let comps: [CGFloat] = cgColor.components!
            guard comps.count != 4 else { return comps }
            return [comps[0], comps[0], comps[0], comps[1]]
        }()

        var colorAsUInt32: UInt32 = 0
        colorAsUInt32 += UInt32(components[0] * 255.0) << 16
        colorAsUInt32 += UInt32(components[1] * 255.0) << 8
        colorAsUInt32 += UInt32(components[2] * 255.0)

        return UInt(colorAsUInt32)
    }
}


// MARK: - 通用函数
public extension NSColor {
    
    /// 根据颜色十六进制值，获取颜色对象,例如：0xFFFFFF --> NSColor
    /// - Parameter value: 颜色十六进制值
    /// - Returns:  NSColor对象
    class func colorWithInt(_ value: Int) -> NSColor {
        let blue = CGFloat(value & 0xFF) / 255.0
        let green = CGFloat((value>>8) & 0xFF) / 255.0
        let red = CGFloat((value>>16) & 0xFF) / 255.0
        
        return NSColor.init(red: red, green: green, blue: blue, alpha: 1.0)
    }
    
    
    /// 根据颜色对象，获取对于的16进制表示Int值
    /// - Returns: 16进制表示Int值
    func intValue() -> Int {
        guard let color = self.usingColorSpace(NSColorSpace.deviceRGB) else {return 0}

        var value: Int = 0
        value |= lround(Double(color.blueComponent*255.0))
        value |= lround(Double(color.greenComponent*255.0)) << 8
        value |= lround(Double(color.redComponent*255.0)) << 16
        
        return value
    }
    
    
    /// 根据颜色对象，获取对于的16进制表示Int值，含透明通道值
    /// - Returns: 16进制表示Int值
    func argbIntValue() -> Int {//NSColor->NLEColor
        guard let color = self.usingColorSpace(NSColorSpace.deviceRGB) else {return 0}

        var value: Int = 0
        value |= lround(Double(color.blueComponent*255.0))
        value |= lround(Double(color.greenComponent*255.0)) << 8
        value |= lround(Double(color.redComponent*255.0)) << 16
        value |= lround(Double(color.alphaComponent*255.0)) << 24
        
        return value
    }
    
    
    /// 根据颜色值获取16进制表示的字符串
    /// - Parameter preString: 字符串前缀
    /// - Returns: 16进制表示的字符串
    func hexStringValue(preString: String = "0x") -> String {
        var strHex: String = preString
        guard let color = self.usingColorSpace(NSColorSpace.deviceRGB) else {return ""}

        let red = lround(Double(color.redComponent*255.0))
        let green = lround(Double(color.greenComponent*255.0))
        let blue = lround(Double(color.blueComponent*255.0))
        strHex = strHex.appendingFormat("FF%02X%02X%02X", red, green, blue)
        
        return strHex
    }
    
}


// MARK: - Methods

public extension NSColor {
    /// 混合两种颜色, 得到一个新的颜色对象
    ///
    /// - Parameters:
    ///   - color1: 第一种混合的颜色
    ///   - intensity1: 第一种颜色的强度(默认为0.5)
    ///   - color2: 第二种混合的颜色
    ///   - intensity2: 第二种颜色的强度(默认为0.5)
    /// - Returns: 通过混合第一种和第二种颜色创建的颜色。
    static func blend(_ color1: NSColor, intensity1: CGFloat = 0.5, with color2: NSColor,
                      intensity2: CGFloat = 0.5) -> NSColor {
        // http://stackoverflow.com/questions/27342715/blend-uicolors-in-swift

        let total = intensity1 + intensity2
        let level1 = intensity1 / total
        let level2 = intensity2 / total

        guard level1 > 0 else { return color2 }
        guard level2 > 0 else { return color1 }

        let components1: [CGFloat] = {
            let comps: [CGFloat] = color1.cgColor.components!
            guard comps.count != 4 else { return comps }
            return [comps[0], comps[0], comps[0], comps[1]]
        }()

        let components2: [CGFloat] = {
            let comps: [CGFloat] = color2.cgColor.components!
            guard comps.count != 4 else { return comps }
            return [comps[0], comps[0], comps[0], comps[1]]
        }()

        let red1 = components1[0]
        let red2 = components2[0]

        let green1 = components1[1]
        let green2 = components2[1]

        let blue1 = components1[2]
        let blue2 = components2[2]

        let alpha1 = color1.cgColor.alpha
        let alpha2 = color2.cgColor.alpha

        let red = level1 * red1 + level2 * red2
        let green = level1 * green1 + level2 * green2
        let blue = level1 * blue1 + level2 * blue2
        let alpha = level1 * alpha1 + level2 * alpha2

        return NSColor(red: red, green: green, blue: blue, alpha: alpha)
    }

    /// 浅化一个颜色值
    ///
    ///     let color = Color(red: r, green: g, blue: b, alpha: a)
    ///     let lighterColor: Color = color.lighten(by: 0.2)
    ///
    /// - Parameter percentage: 使颜色变亮的百分率
    /// - Returns: 通过系数浅化后的颜色值
    func lighten(by percentage: CGFloat = 0.2) -> NSColor {
        // https://stackoverflow.com/questions/38435308/swift-get-lighter-and-darker-color-variations-for-a-given-uicolor
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return NSColor(red: min(red + percentage, 1.0),
                     green: min(green + percentage, 1.0),
                     blue: min(blue + percentage, 1.0),
                     alpha: alpha)
    }

    /// 通过系数暗黑模式一个颜色值，加深颜色值
    ///
    ///     let color = Color(red: r, green: g, blue: b, alpha: a)
    ///     let darkerColor: Color = color.darken(by: 0.2)
    ///
    /// - Parameter percentage: 使颜色变暗的百分率
    /// - Returns: 暗黑后的颜色
    func darken(by percentage: CGFloat = 0.2) -> NSColor {
        // https://stackoverflow.com/questions/38435308/swift-get-lighter-and-darker-color-variations-for-a-given-uicolor
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return NSColor(red: max(red - percentage, 0),
                     green: max(green - percentage, 0),
                     blue: max(blue - percentage, 0),
                     alpha: alpha)
    }
}

#endif

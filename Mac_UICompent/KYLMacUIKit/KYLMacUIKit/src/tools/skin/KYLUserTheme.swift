//
//  KYLUserTheme.swift
//  KYLMacUIKit
//
//  Created by kongyulu on 2021/11/27.
//

#if canImport(Foundation)
import Foundation

/**
   用户自定义皮肤主题类说明：
 
    这个类用于解析用户提供的自定义皮肤配置文件(`.theme`).格式的文件，
 
    要启用用户自定义皮肤，需要调用`KYLThemeManager.userThemesFolderURL`.设置自定义配置文件的父目录文件夹路径

 关于自定义皮肤配置文件 `.theme` 格式说明:
 
 - `#` or `//` 开头的行表示是注释，将被忽略
 - 非注释行由简单的变量/值赋值组成(例如，' variable = value ');
 - “变量”名称可以包含字符“[a-zA-Z0-9_-.]+”;
 - 可以指定自定义变量(例如' myBackgroundColor =…');
 - 主题属性匹配' ThemeColor '， ' ThemeGradient '和' ThemeImage '(例如' labelColor ')的类方法;
 - 变量可以通过前缀' $ '来引用(例如' mainBorderColor = $commonBorderColor ');
 - 颜色使用' rgb(255, 255, 255) '或' rgba(255, 255, 255, 1.0) '(不区分大小写)定义;
 - 使用“linear-gradient(color1, color2)”定义梯度(其中颜色定义如上;不分大小写);
 - 模式图像使用' pattern(named:xxxx) ' (named images)或' pattern(file:../dddd/xxxx.yyy) '(文件系统图像)定义;
 - 图像使用' image(named:xxxx) ' (named images)或' image(file:../dddd/xxxx.yyy) '(文件系统图像)定义;
 - “WSThemeManager。当用户主题文件夹发生变化时，themes的属性会自动更新;
 - 如果文件更改对应于当前应用的主题，则会实时应用它。
 
 自定义皮肤配置文件 完整内容：
 
 Example `.theme` file:
 
 ```ruby
 // ************************* KYLTheme Info ************************* //
 displayName = My Theme 1
 identifier = com.luckymarmot.ThemeKit.MyTheme1
 darkTheme = true
 
 // ********************* Colors & Gradients ********************* //
 # define color for `KYLThemeColor.brandColor`
 brandColor = $blue
 # define a new color for `NSColor.labelColor` (overriding)
 labelColor = rgb(11, 220, 111)
 # define gradient for `KYLThemeGradient.brandGradient`
 brandGradient = linear-gradient($orange.sky, rgba(200, 140, 60, 1.0))
 
 // ********************* Images & Patterns ********************** //
 # define pattern image from named image "paper" for color `KYLThemeColor.contentBackgroundColor`
 contentBackgroundColor = pattern(named:paper)
 # define pattern image from filesystem (relative to user themes folder) for color `KYLThemeColor.bottomBackgroundColor`
 bottomBackgroundColor = pattern(file:../some/path/some-file.png)
 # use named image "apple"
 namedImage = image(named:apple)
 # use image from filesystem (relative to user themes folder)
 fileImage = image(file:../some/path/some-file.jpg)
 
 // *********************** Common Colors ************************ //
 blue = rgb(0, 170, 255)
 orange.sky = rgb(160, 90, 45, .5)
 
 // ********************** Fallback Assets *********************** //
 fallbackForegroundColor = rgb(255, 10, 90, 1.0)
 fallbackBackgroundColor = rgb(255, 200, 190)
 fallbackGradient = linear-gradient($blue, rgba(200, 140, 60, 1.0))
 ```
 
 除了系统覆盖的命名颜色(例如，' labelColor ')，它
 默认为原始系统提供的命名颜色、未实现的属性
 默认为' -fallbackBackgroundColor '， ' -fallbackBackgroundColor '，
 “-fallbackGradient”和“-fallbackImage”，用于前景色，背景色，
 分别是梯度和图像。
 
 
 */
@objc(KYLUserTheme)
public class KYLUserTheme: NSObject, KYLTheme {
    
    //MARK: -----------------public-------------------
    /// 唯一标识符
    public var identifier: String = "{WSUserTheme-Not-Loaded}"

    /// 主题名称
    public var displayName: String = "WSUserTheme Not Loaded"

    /// 名称缩写
    public var shortDisplayName: String = "Not Loaded"

    /// 是否是暗黑模式
    public var isDarkTheme: Bool = false

    /// 配置文件路径
    @objc public var fileURL: URL?


    /// 重新加载配置文件的内容
    @objc public func reload() {
        if let url = fileURL {
            _keyValues.removeAllObjects()
            _evaluatedKeyValues.removeAllObjects()
            loadThemeFile(from: url)
        }
    }

    // MARK: 主题资源

    /// 指定密钥的主题资产。支持的资产是' NSColor '， ' NSGradient '， ' NSImage '和' NSString '。
    ///
    /// - parameter key: 颜色名称、渐变名称、图像名称或主题字符串
    ///
    /// - returns: 指定键的主题值
    @objc public func themeAsset(_ key: String) -> Any? {
        var value = _evaluatedKeyValues[key]
        if value == nil,
            let evaluatedValue = _keyValues.evaluatedObject(key: key) {
            value = evaluatedValue
            _evaluatedKeyValues.setObject(evaluatedValue, forKey: key as NSString)
        }
        return value
    }

    /// 检查是否为给定的键提供了主题资产。
    ///
    /// 不要用' themeAsset(_:) '检查主题资产可用性，而是使用这个方法，它会快得多。
    ///
    /// - parameter key: A color name, gradient name, image name or a theme string
    ///
    /// - returns: 存在则返回true, 否则返回False
    @objc public func hasThemeAsset(_ key: String) -> Bool {
        return _keyValues[key] != nil
    }
    
    override public var description: String {
        return "<\(KYLUserTheme.self): \(themeDescription(self))>"
    }
    
    //MARK: -----------------private-------------------
    // MARK: 初始化

    /// `init()` is disabled.
    private override init() {
        super.init()
    }

    /// Calling `init(_:)` is not allowed outside this library.
    /// Use `WSThemeManager.shared.theme(:_)` instead.
    ///
    /// - parameter themeFileURL: A theme file (`.theme`) URL.
    ///
    /// - returns: An instance of `WSUserTheme`.
    @objc internal init(_ themeFileURL: URL) {
        super.init()

        // Load file
        fileURL = themeFileURL
        loadThemeFile(from: themeFileURL)
    }

    /// 从.theme文件中读取具有键/值对的字典
    private var _keyValues: NSMutableDictionary = NSMutableDictionary()

    /// 从.theme文件中读取的键/值对字典
    private var _evaluatedKeyValues: NSMutableDictionary = NSMutableDictionary()


}

//MARK: - 加载配置文件
extension KYLUserTheme {

    /// 加载配置文件内容到缓存
    ///
    /// - parameter from: 配置文件的完整路径
    private func loadThemeFile(from: URL) {
        // Load contents from theme file
        if let themeContents = try? String(contentsOf: from, encoding: String.Encoding.utf8) {

            // Split content into lines
            var lineCharset = CharacterSet(charactersIn: ";")
            lineCharset.formUnion(CharacterSet.newlines)
            let lines: [String] = themeContents.components(separatedBy: lineCharset)

            // Parse lines
            for line in lines {
                // Trim
                let trimmedLine = line.trimmingCharacters(in: CharacterSet.whitespaces)

                // Skip comments
                if trimmedLine.hasPrefix("#") || trimmedLine.hasPrefix("//") {
                    continue
                }

                // Assign theme key-values (lazy evaluation)
                let assignment = trimmedLine.components(separatedBy: "=")
                if assignment.count == 2 {
                    let key = assignment[0].trimmingCharacters(in: CharacterSet.whitespaces)
                    let value = assignment[1].trimmingCharacters(in: CharacterSet.whitespaces)
                    _keyValues.setObject(value, forKey: key as NSString)
                }
            }

            // Initialize properties with evaluated values from file

            // Identifier
            if let identifierString = themeAsset("identifier") as? String {
                identifier = identifierString
            } else {
                identifier = "{identifier: is mising}"
            }

            // Display Name
            if let displayNameString = themeAsset("displayName") as? String {
                displayName = displayNameString
            } else {
                displayName = "{displayName: is mising}"
            }

            // Short Display Name
            if let shortDisplayNameString = themeAsset("shortDisplayName") as? String {
                shortDisplayName = shortDisplayNameString
            } else {
                shortDisplayName = "{shortDisplayName: is mising}"
            }

            // Dark?
            if let isDarkThemeString = themeAsset("darkTheme") as? String {
                isDarkTheme = NSString(string: isDarkThemeString).boolValue
            } else {
                isDarkTheme = false
            }
        }
    }
}


#endif

//
//  FileManger+Extension.swift
//  WSUIKit
//
//  Created by kongyulu on 2021/1/7.
//

#if canImport(Foundation)
import Foundation

/// 文件类型
enum WSFileType {
    case png
    case jpeg
    case heic
    case tiff
    case gif

    static func from(fileExtension: String) -> Self {
        switch fileExtension {
        case "png":
            return .png
        case "jpg", "jpeg":
            return .jpeg
        case "heic":
            return .heic
        case "tif", "tiff":
            return .tiff
        case "gif":
            return .gif
        default:
            fatalError("Unsupported file type")
        }
    }

    static func from(url: URL) -> Self {
        from(fileExtension: url.pathExtension)
    }

    var name: String {
        switch self {
        case .png:
            return "PNG"
        case .jpeg:
            return "JPEG"
        case .heic:
            return "HEIC"
        case .tiff:
            return "TIFF"
        case .gif:
            return "GIF"
        }
    }

    var identifier: String {
        switch self {
        case .png:
            return "public.png"
        case .jpeg:
            return "public.jpeg"
        case .heic:
            return "public.heic"
        case .tiff:
            return "public.tiff"
        case .gif:
            return "com.compuserve.gif"
        }
    }

    var fileExtension: String {
        switch self {
        case .png:
            return "png"
        case .jpeg:
            return "jpg"
        case .heic:
            return "heic"
        case .tiff:
            return "tiff"
        case .gif:
            return "gif"
        }
    }
}

public extension FileManager {
    /// 从给定路径的JSON文件中读取。
    ///
    /// - Parameters:
    ///   - path: JSON 文件路径.
    ///   - readingOptions: JSONSerialization读取选项。
    /// - Returns: 返回一个可选类型字典.
    /// - Throws: 抛出由数据创建或JSON序列化抛出的任何错误。
    func jsonFromFile(
        atPath path: String,
        readingOptions: JSONSerialization.ReadingOptions = .allowFragments) throws -> [String: Any]? {
        let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
        let json = try JSONSerialization.jsonObject(with: data, options: readingOptions)

        return json as? [String: Any]
    }

    #if !os(Linux)
    /// 从具有给定文件名的JSON文件中读取。
    ///
    /// - Parameters:
    ///   - filename: 要读取的文件名
    ///   - bundleClass: 在关联文件的地方进行绑定。
    ///   - readingOptions: JSONSerialization读取选项
    /// - Returns: 返回一个可选类型字典.
    /// - Throws: 抛出由数据创建或JSON序列化抛出的任何错误。
    func jsonFromFile(
        withFilename filename: String,
        at bundleClass: AnyClass? = nil,
        readingOptions: JSONSerialization.ReadingOptions = .allowFragments) throws -> [String: Any]? {
        // https://stackoverflow.com/questions/24410881/reading-in-a-json-file-using-swift

        // 处理提供的文件名具有扩展名的情况
        let name = filename.components(separatedBy: ".")[0]
        let bundle = bundleClass != nil ? Bundle(for: bundleClass!) : Bundle.main

        if let path = bundle.path(forResource: name, ofType: "json") {
            let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
            let json = try JSONSerialization.jsonObject(with: data, options: readingOptions)

            return json as? [String: Any]
        }

        return nil
    }
    #endif

    /// 为保存临时文件创建一个唯一的目录。该目录可以用于创建多个用于共同目的的临时文件。
    ///
    ///     let tempDirectory = try fileManager.createTemporaryDirectory()
    ///     let tempFile1URL = tempDirectory.appendingPathComponent(ProcessInfo().globallyUniqueString)
    ///     let tempFile2URL = tempDirectory.appendingPathComponent(ProcessInfo().globallyUniqueString)
    ///
    /// - Returns: 用于保存临时文件的新目录的URL。
    /// - Throws: 如果无法找到或创建临时目录，则报错。
    func createTemporaryDirectory() throws -> URL {
        #if !os(Linux)
        let temporaryDirectoryURL: URL
        if #available(OSX 10.12, tvOS 10.0, watchOS 3.0, *) {
            temporaryDirectoryURL = temporaryDirectory
        } else {
            temporaryDirectoryURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
        }
        return try url(for: .itemReplacementDirectory,
                       in: .userDomainMask,
                       appropriateFor: temporaryDirectoryURL,
                       create: true)
        #else
        let envs = ProcessInfo.processInfo.environment
        let env = envs["TMPDIR"] ?? envs["TEMP"] ?? envs["TMP"] ?? "/tmp"
        let dir = "/\(env)/file-temp.XXXXXX"
        var template = [UInt8](dir.utf8).map { Int8($0) } + [Int8(0)]
        guard mkdtemp(&template) != nil else { throw CocoaError.error(.featureUnsupported) }
        return URL(fileURLWithPath: String(cString: template))
        #endif
    }
}


#endif

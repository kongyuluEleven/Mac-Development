//
//  NSImageView+base.swift
//  KYLMacUIKit
//
//  Created by kongyulu on 2021/11/27.
//

#if canImport(AppKit) && !targetEnvironment(macCatalyst)
import AppKit

// MARK: - Methods

public extension NSImageView {
    /// 从URL设置图像。
    ///
    /// - Parameters:
    ///   - url: 图像的URL。
    ///   - placeHolder: 可选图像占位符
    ///   - completionHandler: 可选的完成处理程序，在下载完成时运行(默认为nil)。
    func download(
        from url: URL,
        placeholder: NSImage? = nil,
        completionHandler: ((NSImage?) -> Void)? = nil) {
        image = placeholder
        URLSession.shared.dataTask(with: url) { data, response, _ in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data,
                let image = NSImage(data: data) else {
                completionHandler?(nil)
                return
            }
            DispatchQueue.main.async { [unowned self] in
                self.image = image
                completionHandler?(image)
            }
        }.resume()
        
    }

}

#endif

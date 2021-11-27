//
//  NSImage+cut.swift
//  KYLMacUIKit
//
//  Created by kongyulu on 2021/11/27.
//

#if canImport(AppKit) && !targetEnvironment(macCatalyst)
import AppKit

// MARK: - 裁剪图片

public extension NSImage {
    /// NSImage scaled to maximum size with respect to aspect ratio
    ///
    /// - Parameter maxSize: maximum size
    /// - Returns: scaled NSImage
    func scaled(toMaxSize maxSize: NSSize) -> NSImage {
        let imageWidth = size.width
        let imageHeight = size.height

        guard imageHeight > 0 else { return self }

        // Get ratio (landscape or portrait)
        let ratio: CGFloat
        if imageWidth > imageHeight {
            // Landscape
            ratio = maxSize.width / imageWidth
        } else {
            // Portrait
            ratio = maxSize.height / imageHeight
        }

        // Calculate new size based on the ratio
        let newWidth = imageWidth * ratio
        let newHeight = imageHeight * ratio

        // Create a new NSSize object with the newly calculated size
        let newSize = NSSize(width: newWidth.rounded(.down), height: newHeight.rounded(.down))

        // Cast the NSImage to a CGImage
        var imageRect = CGRect(origin: .zero, size: size)
        guard let imageRef = cgImage(forProposedRect: &imageRect, context: nil, hints: nil) else { return self }

        return NSImage(cgImage: imageRef, size: newSize)
    }
}


#endif


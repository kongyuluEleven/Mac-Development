//
//  KColorButton.swift
//  QEditor
//
//  Created by kongyulu on 2020/9/14.
//  Copyright © 2020 YiZhong Qi. All rights reserved.
//

import UIKit

@IBDesignable
class KColorButton: UIButton {
    @IBInspectable var color: UIColor? {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    override var isSelected: Bool {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    //private let context = try! MTIContext(device: MTLCreateSystemDefaultDevice()!)
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.height/2
        if isSelected {
            layer.borderWidth = 2
            layer.borderColor = UIColor.white.cgColor
            layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: bounds.height/2).cgPath
            layer.shadowRadius = 4
            layer.shadowColor = UIColor.black.cgColor
            layer.shadowOpacity = 0.2
            layer.shadowOffset = CGSize(width: 0, height: 2)
            layer.mask = nil
        } else {
            layer.borderWidth = 2
            layer.borderColor = UIColor.clear.cgColor
            layer.shadowPath = nil
            layer.shadowRadius = 0
            layer.shadowColor = UIColor.black.cgColor
            layer.shadowOpacity = 0
            layer.shadowOffset = .zero
            let mask = CAShapeLayer()
            mask.path = UIBezierPath(roundedRect: bounds.insetBy(dx: 2, dy: 2), cornerRadius: bounds.insetBy(dx: 2, dy: 2).height/2).cgPath
            mask.fillColor = UIColor.white.cgColor
            layer.mask = mask
        }
        if color == .clear {
//            struct Kernels {
//                static let iconGenerator = MTIRenderPipelineKernel(vertexFunctionDescriptor: .passthroughVertex, fragmentFunctionDescriptor: MTIFunctionDescriptor(name: "magicTintBrushIconGenerator", libraryURL: URL.defaultMetalLibraryURL(for: ColorButton.self)))
//            }
//            let icon = MTIRenderCommand.images(byPerforming: [
//                MTIRenderCommand(kernel: Kernels.iconGenerator, geometry: MTIVertices.fullViewportSquare, images: [], parameters: [:])
//                ], outputDescriptors: [
//                    MTIRenderPassOutputDescriptor(dimensions: MTITextureDimensions(cgSize: bounds.size), pixelFormat: .unspecified)
//            ]).first
//            let cgImage = try! context.makeCGImage(from: icon!)
//            backgroundColor = UIColor(patternImage: UIImage(cgImage: cgImage))
        } else {
            backgroundColor = color
        }
    }
}

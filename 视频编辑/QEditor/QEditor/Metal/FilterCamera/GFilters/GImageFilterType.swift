//
//  GImageFilterType.swift
//  MetalImageFilter
//
//  Created by LEE CHUL HYUN on 4/15/19.
//  Copyright © 2019 LEE CHUL HYUN. All rights reserved.
//

import Foundation

enum GImageFilterType {
    case gaussianBlur2D
    case saturationAdjustment
    case rotation
    case colorGBR
    case sepia
    case pixellation
    case luminance
    case normalMap
    case invert
    case centerMagnification
    case swellingUp
    case slimming
    case `repeat`
    case redEmphasis
    case greenEmphasis
    case blueEmphasis
    case rgbEmphasis
    case divide
    case mpsUnaryImageKernel(type: GMPSUnaryImageFilterType)
    case binaryImageKernel(type: BinaryImageFilterType)
    case carnivalMirror
    case kuwahara

    var name: String {
        switch self {
        case .gaussianBlur2D:
            return "GaussianBlur2D"
        case .saturationAdjustment:
            return "SaturationAdjustment"
        case .rotation:
            return "Rotation"
        case .colorGBR:
            return "ColorGBR"
        case .sepia:
            return "Sepia"
        case .pixellation:
            return "Pixellation"
        case .luminance:
            return "Luminance"
        case .normalMap:
            return "Normal Map"
        case .invert:
            return "Invert"
        case .centerMagnification:
            return "Maganifying glass "
        case .swellingUp:
            return "Swelling up"
        case .slimming:
            return "Slimming"
        case .repeat:
            return "Repeat"
        case .redEmphasis:
            return "Red Emphasis"
        case .greenEmphasis:
            return "Green Emphasis"
        case .blueEmphasis:
            return "Blue Emphasis"
        case .rgbEmphasis:
            return "RGB Emphasis"
        case .divide:
            return "Divide"
        case .carnivalMirror:
            return "Carnival Mirror"
        case .kuwahara:
            return "Kuwahara"
        case .mpsUnaryImageKernel(let type):
            return type.name
        case .binaryImageKernel(let type):
            return type.name
        }
    }
    
    func createImageFilter(context: GContext) -> GImageFilter? {
        
        switch self {
        case .gaussianBlur2D:
            return GGaussianBlur2DFilter(context: context, filterType: self)
        case .saturationAdjustment:
            return GSaturationAdjustmentFilter(context: context, filterType: self)
        case .rotation:
            return GRotationFilter(context: context, filterType: self)
        case .colorGBR:
            return GColorGBRFilter(context: context, filterType: self)
        case .sepia:
            return GSepiaFilter(context: context, filterType: self)
        case .pixellation:
            return GPixellationFilter(context: context, filterType: self)
        case .luminance:
            return GLuminanceFilter(context: context, filterType: self)
        case .normalMap:
            return GNormalMapFilter(context: context, filterType: self)
        case .invert:
            return GImageFilter(functionName: "invert", context: context, filterType: self)
        case .centerMagnification:
            return GCenterMagnificationFilter(context: context, filterType: self)
        case .swellingUp:
            return GWeightedCenterMagnificationFilter(context: context, filterType: self)
        case .slimming:
            return GSlimmingFilter(context: context, filterType: self)
        case .repeat:
            return GImageFilter(functionName: "repeat", context: context, filterType: self)
        case .redEmphasis:
            return GImageFilter(functionName: "emphasizeRed", context: context, filterType: self)
        case .greenEmphasis:
            return GImageFilter(functionName: "emphasizeGreen", context: context, filterType: self)
        case .blueEmphasis:
            return GImageFilter(functionName: "emphasizeBlue", context: context, filterType: self)
        case .rgbEmphasis:
            return GImageFilter(functionName: "emphasizeRGB", context: context, filterType: self)
        case .divide:
            return GDivideFilter(context: context, filterType: self)
        case .carnivalMirror:
            return GCarnivalMirrorFilter(context: context, filterType: self)
        case .kuwahara:
            return GKuwaharaFilter(context: context, filterType: self)
        case .mpsUnaryImageKernel(let type):
            return GMPSUnaryImageFilter(type: type, context: context, filterType: self)
        case .binaryImageKernel(let type):
            return BinaryImageFilter(type: type, functionName: "oneStepLaplacianPyramid", context: context, filterType: self)
        }
    }
    
    var inputMipmapped: Bool {
        
        switch self {
        case .mpsUnaryImageKernel(let type):
            return type.inputMipmapped
        case .binaryImageKernel(let type):
            return type.inputMipmapped
        default:
            return false
        }
    }
    
    var outputMipmapped: Bool {
        
        switch self {
        case .mpsUnaryImageKernel(let type):
            return type.outputMipmapped
        case .binaryImageKernel(let type):
            return type.outputMipmapped
        default:
            return false
        }
    }
    
    var inPlaceTexture: Bool {
        
        switch self {
        case .mpsUnaryImageKernel(let type):
            return type.inPlaceTexture
        case .binaryImageKernel(let type):
            return type.inPlaceTexture
        default:
            return false
        }
    }
    
    var output2Required: Bool {
        
        switch self {
        case .mpsUnaryImageKernel(let type):
            return type.output2Required
        case .binaryImageKernel(let type):
            return type.output2Required
        default:
            return false
        }
    }
}


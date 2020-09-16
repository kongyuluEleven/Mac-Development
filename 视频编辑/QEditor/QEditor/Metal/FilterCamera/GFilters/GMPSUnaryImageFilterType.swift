//
//  GMPSUnaryImageFilterType.swift
//  MetalImageFilter
//
//  Created by gzonelee on 26/04/2019.
//  Copyright © 2019 LEE CHUL HYUN. All rights reserved.
//

import Foundation

enum GMPSUnaryImageFilterType {
    case sobel
    case laplacian
    case gaussianBlur
    case gaussianPyramid
    case laplacianPyramid
    case emboss
    
    var name: String {
        switch self {
        case .sobel:
            return "MPS Sobel"
        case .laplacian:
            return "MPS Laplacian"
        case .gaussianBlur:
            return "MPS GaussianBlur"
        case .gaussianPyramid:
            return "MPS GaussianPyramid"
        case .laplacianPyramid:
            return "MPS LaplacianPyramid"
        case .emboss:
            return "Emboss"
        }
    }
    
    var inputMipmapped: Bool {
        switch self {
        case .gaussianPyramid:
            return true
        case .laplacianPyramid:
            return true
        default:
            return false
        }
    }
    
    var outputMipmapped: Bool {
        switch self {
        case .gaussianPyramid:
            return true
        case .laplacianPyramid:
            return true
        default:
            return false
        }
    }
    
    var inPlaceTexture: Bool {
        switch self {
        case .gaussianPyramid:
            return true
        case .laplacianPyramid:
            return false
        default:
            return false
        }
    }
    
    var output2Required: Bool {
        switch self {
        case .laplacian:
            return true
        case .laplacianPyramid:
            return false
        default:
            return false
        }
    }
}


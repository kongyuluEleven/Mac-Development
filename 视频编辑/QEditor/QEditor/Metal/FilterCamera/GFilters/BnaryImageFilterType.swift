//
//  BnaryImageFilterType.swift
//  MetalImageFilter
//
//  Created by LEE CHUL HYUN on 5/11/19.
//  Copyright © 2019 LEE CHUL HYUN. All rights reserved.
//

import Foundation

enum BinaryImageFilterType {
    case oneStepLaplacianPyramid
    
    var name: String {
        switch self {
        case .oneStepLaplacianPyramid:
            return "One Step Laplacian Pyramid"
        }
    }
    
    var inputMipmapped: Bool {
        switch self {
        case .oneStepLaplacianPyramid:
            return false
        }
    }
    
    var outputMipmapped: Bool {
        switch self {
        case .oneStepLaplacianPyramid:
            return false
        }
    }
    
    var inPlaceTexture: Bool {
        switch self {
        case .oneStepLaplacianPyramid:
            return false
        }
    }
    
    var output2Required: Bool {
        switch self {
        case .oneStepLaplacianPyramid:
            return false
        }
    }
}

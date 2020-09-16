//
//  GNormalMapFilter.swift
//  MetalImageFilter
//
//  Created by LEE CHUL HYUN on 4/23/19.
//  Copyright © 2019 LEE CHUL HYUN. All rights reserved.
//

import UIKit

class GNormalMapFilter: GImageFilter {

    override init?(context: GContext, filterType: GImageFilterType) {
        
        super.init(functionName: "normalMap", context: context, filterType: filterType)
    }
}

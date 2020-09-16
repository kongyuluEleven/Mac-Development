//
//  BinaryImageFilter.swift
//  MetalImageFilter
//
//  Created by LEE CHUL HYUN on 5/11/19.
//  Copyright © 2019 LEE CHUL HYUN. All rights reserved.
//

import UIKit
import Metal

class BinaryImageFilter: GImageFilter {
    
    var _value: Float = 0
    override func setValue(_ value: Float) {
        _value = value
        self.isDirty = true
    }
    
    let type: BinaryImageFilterType
    
    init?(type: BinaryImageFilterType, functionName: String, context: GContext, filterType: GImageFilterType) {
        self.type = type
        super.init(functionName: functionName, context: context, filterType: filterType)
    }
}

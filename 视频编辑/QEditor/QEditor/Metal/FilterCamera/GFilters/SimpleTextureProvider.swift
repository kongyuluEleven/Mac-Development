//
//  SimpleTextureProvider.swift
//  MetalFilterCamera
//
//  Created by gzonelee on 15/05/2019.
//  Copyright © 2019 gzonelee. All rights reserved.
//

import UIKit
import Metal

class SimpleTextureProvider: GTextureProvider {

    var texture: MTLTexture?
    
    init(texture: MTLTexture) {
        
        self.texture = texture
    }
}

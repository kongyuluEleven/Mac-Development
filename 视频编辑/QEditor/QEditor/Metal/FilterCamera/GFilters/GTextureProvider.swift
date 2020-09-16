//
//  GTextureProvider.swift
//  imageprocessing01
//
//  Created by LEE CHUL HYUN on 5/11/18.
//  Copyright © 2018 LEE CHUL HYUN. All rights reserved.
//

import Foundation
import Metal

protocol GTextureProvider {
    var texture: MTLTexture? {get}
}

extension GTextureProvider {
    var availableMipmapLevelCount: Int {
        
        if let t = texture {
            GZLogFunc(t.width)
            GZLogFunc(t.height)
            GZLogFunc(Int(max(log2(Double(t.width)), log2(Double(t.height)))))
            return Int(max(log2(Double(t.width)), log2(Double(t.height)))) + 1
        }
        else {
            return 0
        }
    }
}

protocol GTextureConsumer {
    var provider0: GTextureProvider! {get set}
    var provider1: GTextureProvider! {get set}
}

//
//  CGImage+base.swift
//  KYLMacUIKit
//
//  Created by kongyulu on 2021/11/27.
//

import Cocoa

public extension CGImage {
    /// 返回一个只读指针，指向图像的字节。
    var bytePointer: UnsafePointer<UInt8>? {
        guard let data = dataProvider?.data else {
            return nil
        }

        return CFDataGetBytePtr(data)
    }
}

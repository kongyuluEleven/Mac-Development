//
//  ContentProtocol.swift
//  RealtimeMatte
//
//  Created by ws on 2020/9/9.
//  Copyright © 2020 ws. All rights reserved.
//

import Foundation
import UIKit

/// 内容数据填充协议
protocol ContentDataFilling {
    associatedtype ContentData
    func fill(contentData: ContentData)
}

/// 设置内容视图在父容器视图中的层级结构
protocol ContentViewHierarchySettable {
    func setContentViewHierarchy(in containerView: UIView)
}

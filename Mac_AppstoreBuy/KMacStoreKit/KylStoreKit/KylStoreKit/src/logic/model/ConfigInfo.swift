//
//  ConfigInfo.swift
//  KylStoreKit
//
//  Created by kongyulu on 2021/11/26.
//

import Cocoa

public struct KeychainConfig {
    public static let serviceName = "com.kyl.myApp.shared.SDK"
    
    #if APP_STORE
    public static let accessGroup: String = "com.kyl.AppstoreApp"
    #else
    public static let accessGroup: String = "com.kyl.WebApp"
    #endif
}

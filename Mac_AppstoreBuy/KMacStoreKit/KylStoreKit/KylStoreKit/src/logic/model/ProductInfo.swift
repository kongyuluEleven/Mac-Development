//
//  ProductInfo.swift
//  KylStoreKit
//
//  Created by kongyulu on 2021/11/26.
//

import Foundation
import StoreKit

public enum ProductType {
    // 消耗型
    case consumable
    // 非消耗型
    case nonConsumable
    // 自动续期订阅型
    case autoRenewable
    // 非续期订阅型
    case nonRenewing(validDuration: TimeInterval)
}


public struct Product: Equatable {
    public var identifier :String {
        get {
            return self.originalProduct.productIdentifier
        }
    }
    
    public var buyDate: Date?
    public var expireDate: Date?
    public var expired = true
    /// SKProduct 源
    public let originalProduct: SKProduct

}


public struct RetrieveProduct{
    /// 有效商品
    public let validProducts: [String : Product]
    /// 无效商品
    public let invalidProductIDs: [String]
    public let error: Error?
    
    public init(retrievedProducts: [String : Product], invalidProductIDs: [String], error: Error?) {
        self.validProducts = retrievedProducts
        self.invalidProductIDs = invalidProductIDs
        self.error = error
    }
}

/// 购买结果
public enum ProductPurchaseResult {
    /// ReceiptItem：为购买验证结果信息
    case purchased(ReceiptItem)
    /// restored 只有购买过用户又点购买的时候出现，恢复购买不会出现
    case restored(PurchaseDetails)
    case expired(ReceiptItem)
    case notPurchased
    case error(error: SKError)
}


extension SKError {
   static func error(_ code: Int, descriptionKey: String ) -> SKError {
    let code: Code = SKError.Code(rawValue: code)!
    let error = SKError(code, userInfo: [NSLocalizedDescriptionKey : descriptionKey])
        return error
    }
    
}

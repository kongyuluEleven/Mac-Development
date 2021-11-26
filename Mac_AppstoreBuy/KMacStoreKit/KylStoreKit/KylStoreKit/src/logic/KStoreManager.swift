//
//  KStoreTool.swift
//  KylStoreKit
//
//  Created by kongyulu on 2021/11/26.
//

import Cocoa
import StoreKit


public typealias Swifty = SwiftyStoreKit

/// 用户 appstore 地区发生了变化的通知
@available(OSX 10.15, *)
public let kPaymentQueueDidChangeStorefront = NSNotification.Name("paymentQueueDidChangeStorefront")


public class KStoreManager: NSObject {
    
    //提供单例给外部调用
    public static let shared = KStoreManager()
    
    /// 是否需要记录日记
    public var needRecordLog = false
    
    ///  Since Swift 5.2 and Xcode 11.4
    #if compiler(>=5.2)
    /// 用于记录日志，如果需要
    public var logInfoView: NSTextView?
    #else
    /// 用于记录日志，如果需要
    public weak var logInfoView: NSTextView?
    #endif
    
    /// 已检索到的所有商品<SKProduct>
    public private(set) var validProducts: [String : Product]?
    
    /// 此帮助程序可用于检索（加密的）本地收据数据
    static public var appleReceipt = AppleReceiptValidator(service: .production, sharedSecret: "51cf895f763e496592020122fbf66e71")
    
    /// 加载进度视图，此值不为空时，会自动调用:`start/stopAnimation()`
    public weak var progressIndicator: NSProgressIndicator?

    /// 支付完成但待处理的交易事务
    private var completeTransactions: ProductPurchaseResult?
    
    /// 获取在`ApplicationDidFinishLaunching`时获取的支付完成但待处理的交易事务
    public var getCompleteTransactionsOnApplicationDidFinishLaunching: ((ProductPurchaseResult) -> Void)? {
        didSet {
            if let safeTransactions = completeTransactions {
                getCompleteTransactionsOnApplicationDidFinishLaunching?(safeTransactions)
                completeTransactions = nil
            }
        }
    }
    
    
    override init() {
        super.init()
    }
}

//MARK: - 交易处理
extension KStoreManager {
    /// 检索商品信息
    /// - Parameters:
    ///   - productIds: 需要检索的商品ID
    ///   - completion: 完成回调
    ///     - validProducts: Set<SKProduct>: 可售商品
    ///     - invalidProductIDs: Set<String>: 无效商品
    ///     - error: Error?: 错误信息(如果有)
    /// - Returns: 当前检索请求对象
    @discardableResult
    public func retrieveProducts(identifiers: [String], completion: @escaping (RetrieveProduct) -> Void) -> InAppRequest {
        startAnimation()
        var t_identifiers = Set<String>()
        for product in identifiers {
            t_identifiers.update(with: product)
        }
        return Swifty.retrieveProductsInfo(t_identifiers) { (result) in
            
            self.appedLogInfo("请求商品信息结果：")
            
            var retrievedProducts = [String : Product]()
            var invalidProductIDs = [String]()
            
            for product in result.retrievedProducts {
                let tempProduct = Product.init(originalProduct: product)
                retrievedProducts.updateValue(tempProduct, forKey: product.productIdentifier)
                self.appedLogInfo("有效商品：",product.productIdentifier,String(product.price.stringValue),product.localizedPrice ?? "0.00")
            }
            
            for identifier in result.invalidProductIDs {
                invalidProductIDs.append(identifier)
                self.appedLogInfo("无效商品：",identifier)
            }
            
            self.validProducts = retrievedProducts
            let result = RetrieveProduct.init(retrievedProducts: retrievedProducts, invalidProductIDs: invalidProductIDs, error: result.error)
            completion(result)
            self.stopAnimation()
        }
    }
        
    /// 购买商品
    /// - Parameters:
    ///   - product: 商品ID
    ///   - quantity: 数量，默认：1
    ///   - atomically: atomically 默认：true
    ///   - applicationUsername: 用户标识，默认为空
    ///   - simulatesAskToBuyInSandbox: 模拟"要求购买沙盒"，默认 false
    ///   - paymentDiscount: 折扣商品，不是则传nil
    ///   - completion: 完成回调
    ///     - success: 成功，返回商品及其交易信息
    ///     - error: 失败信息
    public func pruchase(productIdentifier: String, quantity: Int = 1, atomically: Bool = true, applicationUsername: String = "", simulatesAskToBuyInSandbox: Bool = false, paymentDiscount: PaymentDiscount? = nil, completion: @escaping (PurchaseResult) -> Void) {
        startAnimation()
        guard let product = getProductId(productIdentifier) else {
            var info = "你购买的商品可能下架了"
            self.appedLogInfo(info,productIdentifier)
            info = "The product is temporarily unavailable, please try again later"
            let error = PurchaseResult.error(error: SKError.error(400, descriptionKey: info))
            completion(error)
            self.stopAnimation()
            return
        }
        
        Swifty.purchaseProduct(product, quantity: quantity, atomically: atomically, applicationUsername: applicationUsername, simulatesAskToBuyInSandbox: simulatesAskToBuyInSandbox, paymentDiscount: paymentDiscount) { (result) in
            switch result {
            case let .success(purchase):
                let date = purchase.transaction.transactionDate?.toString() ?? ""
                self.appedLogInfo("购买成功：",purchase.productId, date, purchase.transaction.transactionState.debugDescription)
                completion(result)
                
            case let .error(error):
                self.appedLogInfo("购买错误：", product.productIdentifier, error.localizedDescription)
                completion(PurchaseResult.error(error: error))
            }
            self.stopAnimation()
        }
    }
    
    /// 购买商品，自动验证
    /// - Parameters:
    ///   - productIdentifier: 商品ID
    ///   - subscriptionType: 是否为订阅类型
    ///   - completion: 完成回调
    public func pruchaseAutoVerify(productIdentifier: String, productType: ProductType, atomically: Bool = true, applicationUsername: String = "", simulatesAskToBuyInSandbox: Bool = false, paymentDiscount: PaymentDiscount? = nil, completion: @escaping ( ProductPurchaseResult) -> Void) {
       
        startAnimation()
        
        pruchase(productIdentifier: productIdentifier, atomically: atomically, applicationUsername: applicationUsername, simulatesAskToBuyInSandbox: simulatesAskToBuyInSandbox, paymentDiscount: paymentDiscount) { (result) in
            switch result {
            case let .success(purchase):
                if purchase.transaction.transactionState == .restored {
                    completion(ProductPurchaseResult.restored(purchase))
                } else {
                    self.willBeAutoVerifyAtThePurchased(purchase: purchase, productIdentifier: purchase.productId, productType: productType, completion: completion)
                }
            case let .error(error):
                self.appedLogInfo("购买商品错误：", productIdentifier, error.localizedDescription)
                self.stopAnimation()
                completion(ProductPurchaseResult.error(error: error))
            }
        }
    }
    
    /// 验证收据
    /// - Parameters:
    ///   - validator: 共享密钥：`let appleReceipt`
    ///   - forceRefresh: 刷新收据，默认：false；false：则从文件返回本地收据，如果丢失，则刷新它；true：则始终刷新收据
    ///   - completion: 完成回调
    ///     - success: 成功，返回商品收据详情信息
    ///     - error: 失败信息
    /// - Returns: 当前验证请求对象
    /// - Note: 尚不支持在一个调用中验证多个购买和订阅，如果您需要验证多个购买/订阅，则可以：使用不同的产品标识符多次调用`verifyPurchase`或`verifySubscription`
    @discardableResult
    public func verifyReceipt(using validator: ReceiptValidator = KStoreManager.appleReceipt, productIdentifier: String, forceRefresh: Bool = false, completion: @escaping (VerifyReceiptResult) -> Void) -> InAppRequest? {
        
        startAnimation()
        return Swifty.verifyReceipt(using: validator, forceRefresh: false) { (verifyResult) in
            switch verifyResult {
            case .success(let info):
                var stringJson = info as Dictionary
                stringJson = self.resolvingJsonInDebug(&stringJson)
                self.appedLogInfo("验证收据成功：", stringJson.description)
                
            case .error(let error):
                switch error {
                case let .networkError(error):
                    self.appedLogInfo("验证收据错误", error.localizedDescription, error.localizedDescription)
                case let .jsonDecodeError(string):
                    self.appedLogInfo("验证收据错误", error.localizedDescription, (string ?? ""))
                case .noReceiptData:
                    self.appedLogInfo("验证收据错误", error.localizedDescription, "noReceiptData")
                case .noRemoteData:
                    self.appedLogInfo("验证收据错误", error.localizedDescription, "noRemoteData")
                case let .receiptInvalid(receipt, status):
                    self.appedLogInfo("验证收据错误", error.localizedDescription, receipt.debugDescription, status.rawValue.description)
                case let .requestBodyEncodeError(error):
                    self.appedLogInfo("验证收据错误", error.localizedDescription)
                }
            }
            self.stopAnimation()
            completion(verifyResult)
        }
    }
    
    /// 验证购买
    /// - Parameters:
    ///   - productId: 商品ID
    ///   - receipt: 验证后的收据信息（由apple返回）
    /// - Returns: 验证结果
    ///   - purchased: 已购买
    ///   - notPurchased: 没有购买
    /// 当找到给定商品ID的一个或多个订阅时，它们将以ReceiptItem排序的数组形式返回，第一个是最新的
    @discardableResult
    public func verifyPurchase(productId: String, inReceipt receipt: ReceiptInfo) -> VerifyPurchaseResult {
        startAnimation()
        let verifyPurchase = Swifty.verifyPurchase(productId: productId, inReceipt: receipt)
        
        switch verifyPurchase {
        case .purchased(let item):
            self.appedLogInfo("verifyPurchase: Product is valid", item.productId, "purchaseDate:\(item.purchaseDate.toString())")
            
            if item.cancellationDate != nil {
                self.appedLogInfo("取消订阅时间：", item.cancellationDate!.toString(), item.productId, item.purchaseDate.toString())
            }
            
            self.saveKeyInfo(productID: item.productId, transactionDate: item.purchaseDate) { (saveResult, error) in
                self.appedLogInfo("购买保存结果：", saveResult ?? "", error?.localizedDescription ?? "")
            }
            
        case .notPurchased:
            self.appedLogInfo("verifyPurchase: This product has never been purchased", productId)
        }
        stopAnimation()
        return verifyPurchase
    }

    /// 验证订阅
    /// - Parameters:
    ///   - type: 订阅类型, nonRenewing(validDuration：时间间隔（以秒为单位）)
    ///   - productIds: 商品ID
    ///   - receipt: 验证后的收据信息（由apple返回）
    ///   - date: 时间
    /// - Returns: 验证结果
    ///   - purchased: 已购买，并有效
    ///   - expired: 过期
    ///   - notPurchased: 没有购买
    @discardableResult
    public func verifySubscriptions(ofType type: SubscriptionType = .autoRenewable, productId: String, inReceipt receipt: ReceiptInfo, validUntil date: Date = Date()) -> VerifySubscriptionResult {
        startAnimation()
        let verifySubscription = Swifty.verifySubscriptions(ofType: type, productIds: [productId], inReceipt: receipt, validUntil: date)
        
        switch verifySubscription {
        case let .purchased(expiryDate, items):
            self.appedLogInfo("VerifySubscriptions is Purchased:\(items.count)")
            for (index, item) in items.enumerated() {
                if index == 0 {
                    self.saveKeyInfo(productID: item.productId, transactionDate: item.purchaseDate) { (saveResult, error) in
                        self.appedLogInfo("购买保存结果：", saveResult ?? "", error?.localizedDescription ?? "")
                    }
                }
                
                self.appedLogInfo("Purchased:", item.productId, "purchaseDate:\(item.purchaseDate.toString())", "expiredDate:\(expiryDate.toString())")
                
                if item.cancellationDate != nil {
                    self.appedLogInfo("取消订阅时间：\(item.cancellationDate!.toString())","expired count:\(items.count) ",item.productId,"Product is expired\(expiryDate.toString())","purchaseDate:\(item.purchaseDate.toString())")
                }
            }
            
        case let .expired(expiryDate, items):
            self.appedLogInfo("VerifySubscriptions is Expired:\(items.count)")
            for (index, item) in items.enumerated() {
                if index == 0 {
                    // 过期就从钥匙串中删除
                    self.removeKeyInfo(productID: productId) { (pID, dateString, error) in
                        // 确认日期是不是一样，返回true进行删除
                        let date = item.purchaseDate.toString()
                        return ((dateString ?? "") == date) || (pID == item.productId)
                    }
                }
                self.appedLogInfo("Expired:", item.productId, "purchaseDate:\(item.purchaseDate.toString())", "expiredDate:\(expiryDate.toString())")
                
                if item.cancellationDate != nil {
                    self.appedLogInfo("取消订阅：\(item.cancellationDate!.toString())","expired count:\(items.count) ",item.productId,"Product is expired\(expiryDate.toString())","purchaseDate:\(item.purchaseDate.toString())")
                }
            }
        case .notPurchased:
            self.appedLogInfo("verifySubscriptions: This product has never been purchased", productId)
        }
        stopAnimation()
        return verifySubscription
    }
    
    /// 购买完成后的验证流程
    /// - Parameters:
    ///   - productIdentifier: 商品ID
    ///   - subscriptionType: 是否为订阅类型
    ///   - completion: 完成回调
    public func willBeAutoVerifyAtThePurchased(purchase: PurchaseDetails? = nil, productIdentifier: String, productType: ProductType, completion: @escaping ( ProductPurchaseResult ) -> Void) {
        startAnimation()
        self.verifyReceipt(productIdentifier: productIdentifier) { (result) in
            switch result {
            case let .success(receiptInfo):
                switch productType {
                    // 订阅类型
                case .autoRenewable, .nonRenewing(_):
                    let verifySubscription = self.verifySubscriptions(ofType:self.conversionSubscriptionType(productType) ,productId: productIdentifier, inReceipt: receiptInfo)
                    switch verifySubscription {
                    case let .purchased(_ , items):
                        let fristItem = items.first
                        if let safeFristItem = fristItem {
                            let purchased = ProductPurchaseResult.purchased(safeFristItem)
                            completion(purchased)
                        }
                        
                    case let .expired(_ , items):
                        let fristItem = items.first
                        if let safeFristItem = fristItem {
                            let purchased = ProductPurchaseResult.expired(safeFristItem)
                            completion(purchased)
                            
                        }
                        for item in items {
                            self.removeKeyInfo(productID: item.productId) { (pID, dateString, error) -> Bool in
                                // 确认日期是不是一样，返回true进行删除
                                let date = item.purchaseDate.toString()
                                return ((dateString ?? "") == date) || (pID == item.productId)
                            }
                        }
                        
                    case .notPurchased:
                        completion(ProductPurchaseResult.notPurchased)
                    }
                    
                    self.stopAnimation()
                    
                    // 非消耗型
                default:
                    let verifyPurchase = self.verifyPurchase(productId: productIdentifier, inReceipt: receiptInfo)
                    self.stopAnimation()
                    switch verifyPurchase {
                    case .purchased(let item):
                        completion(ProductPurchaseResult.purchased(item))
                        
                    case .notPurchased:
                        completion(ProductPurchaseResult.notPurchased)
                    }
                }
                
            case let .error(error):
                self.appedLogInfo("购买商品错误：", productIdentifier, error.localizedDescription)
                let error = ProductPurchaseResult.error(error: SKError.error(400, descriptionKey: error.localizedDescription))
                self.stopAnimation()
                completion(error)
            }
        }
    }
     
    /// 获取收据，当`let appleReceipt`失效或过期的时候调用
    /// - Parameters:
    ///   - forceRefresh: 是否刷新收据：false：则从文件返回本地收据，如果丢失，则刷新它；true：则始终刷新收据
    ///    - success(receiptData: Data): 刷新后的收据数据
    ///    - error(error: ReceiptError): 失败详情
    ///   - completion: 完成回调: 如果fetchReceipt成功，它将以字符串形式返回加密的收据
    /// - Returns: 当前请求操作对象
    /// - Note:
    ///     - 如果用户未登录App Store，StoreKit将显示一个弹出窗口，要求登录iTunes Store
    ///     - 如果用户取消，收据刷新将失败，可能显示“无法连接到iTunes Store”错误
    @discardableResult
    class public func fetchReceipt(forceRefresh: Bool, completion: @escaping (FetchReceiptResult) -> Void) -> InAppRequest? {
       return Swifty.fetchReceipt(forceRefresh: forceRefresh, completion: completion)
    }

    /// 恢复购买
    /// - Parameters:
    ///   - atomically: atomically 默认：true
    ///   - applicationUsername: 购买时设置的用户标识
    ///   - completion: 完成回调用
    ///     - restoredPurchases: [Purchase]: 所有恢复成功的购买
    ///     - restoreFailedPurchases: [(SKError, String?)]: 恢复失败的购买
    public func restorePurchases(atomically: Bool = true, applicationUsername: String = "", productType: @escaping (_ productID: String) -> ProductType, verifyResult: @escaping (ProductPurchaseResult) -> Void, purchases: ((RestoreResults) -> Void)?) {
        
        startAnimation()
        
        Swifty.restorePurchases(atomically: atomically, applicationUsername: applicationUsername) { (results) in
            
            purchases?(results)
            
            self.resetLogInfo("restorePurchases:")
            
            let restoreFailedPurchases = results.restoreFailedPurchases
            if restoreFailedPurchases.count > 0 {
                let errors = results.restoreFailedPurchases.first
                if let error = errors?.0, let errorsString = errors?.1 {
                    self.appedLogInfo(String(error.code.rawValue), error.localizedDescription,errorsString)
                    verifyResult(ProductPurchaseResult.error(error: error))
                } else {
                    verifyResult(ProductPurchaseResult.error(error: errors?.0 ?? SKError(_nsError: NSError())))
                }
            
            } else {
                var productIdentifiers = [String]()
                if results.restoredPurchases.count == 0 {
                    verifyResult(ProductPurchaseResult.notPurchased)
                }
                for purchase in results.restoredPurchases {
                    if atomically && purchase.needsFinishTransaction{
                        Swifty.finishTransaction(purchase.transaction)
                    }
                    
                    let transaction = purchase.transaction
                    self.appedLogInfo(purchase.productId,
                                      "transactionDate:\(transaction.transactionDate?.toString() ?? "")",
                        "transactionState:\(transaction.transactionState.debugDescription)",
                        "needsFinish:\(purchase.needsFinishTransaction.description)")
                    
                    let type = productType(purchase.productId)
                    if !productIdentifiers.contains(purchase.productId) {
                        productIdentifiers.append(purchase.productId)
                        
                        switch type {
                            // 非消耗型
                        case .nonConsumable:
                            self.verifyReceipt(productIdentifier: purchase.productId) { (result) in
                                switch result {
                                case let .success(receipt):
                                    let item = ReceiptItem.init(receiptInfo: receipt)
                                    let item2 = ReceiptItem.init(productId: purchase.productId, quantity: purchase.quantity, transactionId: purchase.transaction.transactionIdentifier ?? "", originalTransactionId: "", purchaseDate: purchase.originalPurchaseDate, originalPurchaseDate: purchase.originalPurchaseDate, webOrderLineItemId: nil, subscriptionExpirationDate: nil, cancellationDate: nil, isTrialPeriod: false, isInIntroOfferPeriod: false)
                                    // 保存到钥匙串
                                    self.saveKeyInfo(productID: purchase.productId, transactionDate: purchase.originalPurchaseDate) { (saveResult, error) in
                                        self.appedLogInfo("购买保存结果：", saveResult ?? "", error?.localizedDescription ?? "")
                                    }
                                    if let safeItem = item {
                                        verifyResult(ProductPurchaseResult.purchased(safeItem))
                                    } else {
                                        verifyResult(ProductPurchaseResult.purchased(item2))
                                    }
                                case let .error(error):
                                    let t_error = ProductPurchaseResult.error(error: SKError.error(400, descriptionKey: error.localizedDescription));
                                    verifyResult(t_error)
                                }
                            }
                            // 订阅型
                        default:
                            let pr = PurchaseDetails(productId: purchase.productId, quantity: purchase.quantity, product: SKProduct(), transaction: purchase.transaction, originalTransaction: purchase.originalTransaction, needsFinishTransaction: purchase.needsFinishTransaction)
                            self.willBeAutoVerifyAtThePurchased(purchase: pr, productIdentifier: purchase.productId, productType: type, completion: verifyResult)
                            continue
                        }
                    }
                }
            }
            self.stopAnimation()
        }
    }
    
    /// 启动检查未完成的交易，处理具体交易事件；
    /// - Parameters:
    ///   - atomically: atomically description
    ///   - completion: 未完成的交易详情
    /// - Note: 如果没有挂起的事务，则不会调用完成块;只能在代码中的中调用一次；
    public func completeTransactions(atomically: Bool = true, productType: @escaping (_ productID: String) -> ProductType, verifyResult: @escaping (ProductPurchaseResult) -> Void, transactions: (([Purchase]) -> Void)?) {
        
        startAnimation()
        
        Swifty.completeTransactions { (purchases) in
            
            transactions?(purchases)
            
            for purchase in purchases {
                switch purchase.transaction.transactionState {
                case .purchased, .restored:
                    
                    if atomically && purchase.needsFinishTransaction{
                        Swifty.finishTransaction(purchase.transaction)
                    }
                    
                    let type = productType(purchase.productId)
                    let pr = PurchaseDetails(productId: purchase.productId, quantity: purchase.quantity, product: SKProduct(), transaction: purchase.transaction, originalTransaction: purchase.originalTransaction, needsFinishTransaction: purchase.needsFinishTransaction)
                    self.willBeAutoVerifyAtThePurchased(purchase: pr, productIdentifier: purchase.productId, productType: type) { (result) in
                        self.completeTransactions = result
                        verifyResult(result)
                    }
                    
                    self.appedLogInfo("completeTransaction: \(purchase.transaction.transactionState.debugDescription): \(purchase.productId)")
                    
                case .failed, .purchasing, .deferred:
                    self.appedLogInfo("completeTransaction: \(purchase.transaction.transactionState.debugDescription): \(purchase.productId)")
                    
                @unknown default:
                    break // do nothing
                }
            }
            self.stopAnimation()
        }
    }
    
    /// 完成交易
    /// - Parameter transaction: 需要完成的交易对象
    /// - Note: 只有在成功处理了交易并解锁了用户购买的功能后，才应调用
    class public func finishTransaction(_ transaction: PaymentTransaction) {
        SwiftyStoreKit.finishTransaction(transaction)
    }
}


//MARK: - UI 工具
extension KStoreManager {
    func startAnimation() {
        if Thread.current == Thread.main {
            progressIndicator?.startAnimation(nil)
        } else {
            DispatchQueue.main.sync {
                progressIndicator?.startAnimation(nil)
            }
        }
    }
    
    func stopAnimation() {
        if Thread.current == Thread.main {
            progressIndicator?.stopAnimation(nil)
        } else {
            DispatchQueue.main.sync {
                progressIndicator?.stopAnimation(nil)
            }
        }
    }
}

//MARK: -
extension KStoreManager {
    /// 读取存在钥匙串的购买信息
    /// - Parameters:
    ///   - productType: 订阅类型
    ///   - verifyResult: 验证结果
    ///     - ProductPurchaseResult: 验证结果详情
    ///     - identifier: 商品ID
    func readStoredItems(productType: @escaping (String) -> ProductType, readCompletion: @escaping (String?) -> Void, verifyResult: @escaping (ProductPurchaseResult, _ identifier: String) -> Void) {
        
        readStoredItems { (item) in
            
            readCompletion(item?.account.fromBase64())
            
            if let identifier = componentProductID(item?.account.fromBase64()) {
                let type = productType(identifier)
                switch type {
                // 非消耗型
                case .nonConsumable:
                    self.completeTransactions(productType: { (_) -> ProductType in
                        return .nonConsumable
                    }, verifyResult: { (result) in
                        
                    }, transactions: nil)
                    let center = NotificationCenter.default
                    center.addObserver(forName: NSApplication.didFinishLaunchingNotification, object: nil, queue: OperationQueue.main) { (_) in
                        self.restorePurchases(productType: { (_) -> ProductType in
                            return .nonConsumable
                        }, verifyResult: { (result) in
                            verifyResult(result, identifier)
                        }, purchases: nil)
                        center.removeObserver(NSApplication.didFinishLaunchingNotification)
                    }
                    
                // 订阅型
                default:
                    self.willBeAutoVerifyAtThePurchased(productIdentifier: identifier, productType: type) {(result) in
                        verifyResult(result, identifier)
                    }
                }
            }
        }
    }
    
    func componentProductID(_ pID: String?) -> String? {
        guard let safePId = pID else {
            return nil
        }
        let identifiers = safePId.components(separatedBy: "|")
        if let newID = identifiers.first {
            return newID
        }
        return safePId
    }
}

//MARK: -
extension KStoreManager {
    /// 保存购买信息，如果用户没有开启钥匙串同步功能，将无法多端同步
    /// - Parameters:
    ///   - productIdentifier: 商品ID
    ///   - transactionDate: 交易时间
    ///   - userName: 用户名
    ///   - completion: 完成回调
    ///   - item: 保存成功后的标识
    ///   - error: 保存失败详情
    func saveKeyInfo(productID: String, transactionDate: Date, userName: String = "Filmora", completion: @escaping (_ item: String?, _ error: Error?) -> Void) {
//        do {
//            let account = (productID + "|" + userName).toBase64()
//            if let safeAccount = account {
//                var item = AccountsItem(service: KeychainConfiguration.serviceName, account: safeAccount, accessGroup: KeychainConfiguration.accessGroup)
//                try item.renameAccount(safeAccount)
//                let base64String = transactionDate.toString().toBase64()
//                if base64String != nil {
////                    try item.savePassword(base64String!)
//                }
//            }
//            completion(account, nil)
//        } catch {
//            completion(nil, error)
//        }
    }
    
    /// 获取购买的历史信息，如果用户没有开启钥匙串同步功能，将无法多端同步，可能获取的还是为空
    /// - Parameters:
    ///   - product: 商品ID
    ///   - completion: 完成回调
    ///   - item: productIdentifier
    ///   - key: transactionDate
    ///   - error: 获取失败详情
    func getKeyInfo(productID: String, userName: String = "Filmora", completion: @escaping (_ item: String?,_ key: String?, _ error: Error?) -> Void) {
//        do {
//            let account = productID + "|" + userName
//            let passwordItems = try AccountsItem.readItems(forService: KeychainConfiguration.serviceName, accessGroup: KeychainConfiguration.accessGroup)
//            var tempItem = String()
//            var orgPasswd: String?
//            for item in passwordItems {
//                if let base64 = item.account.fromBase64() {
//                    if base64 == account {
//                        tempItem = base64
////                        let passwd: String = try item.readPassword()
////                        orgPasswd = passwd.fromBase64()
////                        debugPrint(orgPasswd as Any)
//                        break
//                    }
//                }
//            }
//            completion(tempItem, orgPasswd,nil)
//        }
//        catch {
//            completion(nil, nil, error)
//        }
    }
    
    
    /// 删除购买信息
    /// - Parameters:
    ///   - productID: 商品ID
    ///   - userName: 用户名
    ///   - completion: 查找结果，返回true就是确认删除
    ///   - date: transactionDate
    ///   - error: 保存失败详情
    func removeKeyInfo(productID: String, userName: String = "Filmora", confirm: @escaping (_ identifier: String? ,_ date: String? ,Error?) -> Bool) {
//        do {
//            let account = productID + "|" + userName
//            let passwordItems = try AccountsItem.readItems(forService: KeychainConfiguration.serviceName, accessGroup: KeychainConfiguration.accessGroup)
//            var tempItemString = String()
//            var tempItem: AccountsItem?
//            for item in passwordItems {
//                if let base64 = item.account.fromBase64(), base64 == account {
////                    let passwd: String = try item.readPassword()
////                    tempItemString = passwd.fromBase64() ?? ""
//                    tempItem = item
//                    if let identifier = componentProductID(base64) {
//                        let delete = confirm(identifier, tempItemString, nil)
//                        if delete {
//                            self.appedLogInfo("删除购买记录：",identifier,tempItemString)
//                            try tempItem?.deleteItem()
//                        }
//                    }
//                    break
//                }
//            }
//        }
//        catch {
//            _ = confirm(nil ,nil, error)
//        }
    }
    
    /// 读取存在钥匙串的购买信息
    /// - Parameter completion: 完成回调，如有多个购买可能会回调多次
    func readStoredItems(_ completion: (AccountsItem?) -> Void) {
//        do {
//            let passwordItems = try AccountsItem.readItems(forService: KeychainConfiguration.serviceName, accessGroup: KeychainConfiguration.accessGroup)
//            var items = String()
//            appedLogInfo("读取已存储的购买：")
//            for item in passwordItems {
//                completion(item)
//                let account = item.account
//                // items.append(item.accessGroup ?? "" + "\n")
//                // items.append(item.service + "\n")
//                // let passwd = try item.readPassword()
//                // items.append(passwd)
//                items.append(account.fromBase64() ?? "")
//                appedLogInfo(item.account.fromBase64() ?? "")
//            }
//        }
//        catch {
//            completion(nil)
//            appedLogInfo("Error fetching password items - \(error)")
//        }
    }
}

//MARK: - 内部逻辑
extension KStoreManager {
    private func conversionSubscriptionType(_ type: ProductType) -> SubscriptionType {
        switch type {
        case .autoRenewable:
            return .autoRenewable
        case let .nonRenewing(validDuration):
            return .nonRenewing(validDuration: validDuration)
        default:
            return .autoRenewable
        }
    }
    
    private func getProductId(_ key: String) -> SKProduct? {
           guard let products = validProducts else {
               return nil
           }
        return products[key]?.originalProduct
       }
    
   private func resetLogInfo(_ info: String...) {
        if !needRecordLog || logInfoView == nil { return }

         var tempInfo = ""
         for sub in info {
             tempInfo.append(sub)
         }
         if Thread.current == Thread.main {
             self.logInfoView!.string = tempInfo
             self.logInfoView!.scrollRangeToVisible(NSRange(location: self.logInfoView!.string.lengthOfBytes(using: .utf8), length: 0))
         } else {
             DispatchQueue.main.sync {
                 self.logInfoView!.string = tempInfo
                 self.logInfoView!.scrollRangeToVisible(NSRange(location: self.logInfoView!.string.lengthOfBytes(using: .utf8), length: 0))
             }
         }
     }
     
    private func appedLogInfo(_ info: String...) {
//        debugPrint(info)
        if !needRecordLog || logInfoView == nil { return }

         var tempInfo = "\n"
         for sub in info {
             tempInfo.append(" - ")
             tempInfo.append(sub)
         }
         if Thread.current == Thread.main {
             var oldInfo = self.logInfoView!.string
             oldInfo.append(tempInfo)
             self.logInfoView!.string = oldInfo
         } else {
             DispatchQueue.main.sync {
                 var oldInfo = self.logInfoView!.string
                 oldInfo.append(tempInfo)
                 self.logInfoView!.string = oldInfo
             }
         }
         DispatchQueue.main.async {
             self.logInfoView!.scrollRangeToVisible(NSRange(location: self.logInfoView!.string.lengthOfBytes(using: .utf8), length: 0))
         }
     }
    
    private func resolvingJsonInDebug(_ stringJson: inout [String : AnyObject]) -> [String : AnyObject] {
         stringJson.updateValue("..." as AnyObject, forKey: "latest_receipt")
         do {
             let data = try JSONSerialization.data(withJSONObject: stringJson as Any, options: .prettyPrinted)
             let jsonString = String(bytes: data, encoding: .utf8) ?? ""
             self.appedLogInfo(jsonString)
             
         } catch let err {
             self.appedLogInfo("解析JSON错误：", err.localizedDescription)
             return stringJson
         }
         return stringJson
     }
}




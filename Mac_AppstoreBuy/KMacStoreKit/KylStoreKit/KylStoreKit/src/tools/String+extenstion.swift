//
//  String+extenstion.swift
//  KylStoreKit
//
//  Created by kongyulu on 2021/11/26.
//

import Foundation
import StoreKit

public extension String {
    func getSKErrorDetail(_ err: SKError) -> String {
          switch err.code {
          case .unknown:
              return "未知的错误"
          case .clientInvalid:
              return "不允许客户端执行的操作"
          case .paymentCancelled:
              return "用户取消了付款请求"
          case .paymentInvalid:
              return "App Store无法识别付款参数"
          case .paymentNotAllowed:
              return "不允许用户授权付款"
          case .storeProductNotAvailable:
              return "所请求的产品在商店中不可用"
          case .privacyAcknowledgementRequired:
              return "用户尚未确认Apple的隐私政策"
          case .unauthorizedRequestData:
              return "该应用程序正在尝试使用其不具备必需权利的属性"
          case .invalidOfferIdentifier:
              return "商品标识符无效"
          case .invalidOfferPrice:
              return "在App Store Connect中指定的价格不再有效"
          case .invalidSignature:
              return "签名无效"
          case .missingOfferParams:
              return "缺少折扣中参数"
          default:
              break
          }
          return err.localizedDescription
      }
}

public extension String {
    /// 日期字符串转化为Date类型
    ///
    /// - Parameters:
    ///   - dateFormat: 格式化样式，默认为“yyyy-MM-dd HH:mm:ss”
    /// - Returns: Date类型
    func toDate(dateFormat: String="yyyy-MM-dd HH:mm:ss") -> Date {
        let dateFormatter = DateFormatter.init()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date = dateFormatter.date(from: self)
        return date!
    }
    
    // base64编码
    func toBase64() -> String? {
        if let data = self.data(using: .utf8) {
            return data.base64EncodedString()
        }
        return nil
    }
    
    // base64解码
    func fromBase64() -> String? {
        if let data = Data(base64Encoded: self) {
            return String(data: data, encoding: .utf8)
        }
        return nil
    }
}

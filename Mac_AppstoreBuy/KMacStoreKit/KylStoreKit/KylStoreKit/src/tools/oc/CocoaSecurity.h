//
//  CocoaSecurity.h
//  KylStoreKit
//
//  Created by kongyulu on 2021/11/26.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CocoaSecurityResult : NSObject
@property (strong, nonatomic, readonly) NSData *data;
@property (strong, nonatomic, readonly) NSString *utf8String;

/// md5 摘要信息，大写
@property (strong, nonatomic, readonly) NSString *hex;

/// md5 摘要信息，小写
@property (strong, nonatomic, readonly) NSString *hexLower;
@property (strong, nonatomic, readonly) NSString *base64;
@end

@interface CocoaSecurity : NSObject
/// 获取字符串 md5 摘要信息
/// @param hashString 需要摘要的字符串
+ (CocoaSecurityResult *)md5:(NSString *)hashString;

///  获取文件 md5 摘要信息
/// @param hashData 需要摘要的文件
+ (CocoaSecurityResult *)md5WithData:(NSData *)hashData;

// Custom method to calculate the SHA-256 hash using Common Crypto
// 请使用服务器上用户帐户名的单向哈希填充付款对象的applicationUsername属性
+ (NSString *)hashedValueForAccountName:(NSString*)userAccountName;

@end

NS_ASSUME_NONNULL_END

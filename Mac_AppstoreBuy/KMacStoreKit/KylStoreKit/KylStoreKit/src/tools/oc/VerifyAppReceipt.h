//
//  VerifyAppReceipt.h
//  KylStoreKit
//
//  Created by kongyulu on 2021/11/26.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface VerifyAppReceipt : NSObject

+(NSDictionary*)dictionaryWithAppStoreReceipt:(NSString *)path;

+(int)validateReceiptAtPath:(NSString *)path;
@end

NS_ASSUME_NONNULL_END

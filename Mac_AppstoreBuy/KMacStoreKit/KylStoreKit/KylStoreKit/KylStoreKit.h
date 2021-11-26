//
//  KylStoreKit.h
//  KylStoreKit
//
//  Created by kongyulu on 2021/11/26.
//

#import <Foundation/Foundation.h>

//! Project version number for KylStoreKit.
FOUNDATION_EXPORT double KylStoreKitVersionNumber;

//! Project version string for KylStoreKit.
FOUNDATION_EXPORT const unsigned char KylStoreKitVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <KylStoreKit/PublicHeader.h>


#if TARGET_OS_IOS
    #import <StoreKit/StoreKit.h>
    #import "DeviceInfo.h"
    #import "CocoaSecurity.h"
    #import "VerifyAppReceipt.h"
#elif TARGET_OS_MAC && !TARGET_OS_IPHONE

    #import <StoreKit/StoreKit.h>
//    #import "DeviceInfo.h"
//    #import "CocoaSecurity.h"
//    #import "VerifyAppReceipt.h"
#elif TARGET_OS_TV

#elif TARGET_OS_WATCH

#endif

//
//  SandboxFileAccessPersist.h
//  MacSandoxFileAccess
//
//  Created by kongyulu on 2020/6/7.
//  Copyright © 2020 kongyulu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SandboxFileAccess.h"
NS_ASSUME_NONNULL_BEGIN

@interface SandboxFileAccessPersist : NSObject<SandboxFileAccessProtocol>

- (NSData *)bookmarkDataForURL:(NSURL *)url;
- (void)setBookmarkData:(NSData *)data forURL:(NSURL *)url;
- (void)clearBookmarkDataForURL:(NSURL *)url;

@end

NS_ASSUME_NONNULL_END

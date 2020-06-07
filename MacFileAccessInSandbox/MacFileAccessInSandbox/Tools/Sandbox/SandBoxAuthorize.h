//
//  SandBoxAuthorize.h
//  MacSandoxFileAccess
//
//  Created by kongyulu on 2020/6/7.
//  Copyright © 2020 kongyulu. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SandBoxAuthorize : NSObject
+ (BOOL)addBookmark:(NSString*)strPath isDirectory:(BOOL)isDir;
+ (void)authorizePath:(NSString *)strPath;
+ (void)deauthorizePath:(NSString *)strPath;
+ (BOOL) itemWritable: (NSString *)itemPath;
+ (BOOL) itemReadable: (NSString *) itemPath;
+ (BOOL) isAuthoredFilePath: (NSString*) strFilePath;
+ (BOOL) storeFileURLWithBookmark:(NSURL*) mediaFileURL key:( NSString*) keyValue;
+ (NSURL*) getPathStoreBookmark: (NSString*) songPath key: (NSString*) keyValue;
@end

NS_ASSUME_NONNULL_END

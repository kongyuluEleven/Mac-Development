//
//  SandboxFileAccessPanelDelegate.h
//  MacSandoxFileAccess
//
//  Created by kongyulu on 2020/6/7.
//  Copyright © 2020 kongyulu. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SandboxFileAccessPanelDelegate : NSObject
- (instancetype)initWithFileURL:(NSURL *)fileURL;
@end

NS_ASSUME_NONNULL_END

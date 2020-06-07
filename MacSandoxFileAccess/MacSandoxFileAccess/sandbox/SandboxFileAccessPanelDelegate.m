//
//  SandboxFileAccessPanelDelegate.m
//  MacSandoxFileAccess
//
//  Created by kongyulu on 2020/6/7.
//  Copyright © 2020 kongyulu. All rights reserved.
//

#import "SandboxFileAccessPanelDelegate.h"

#if !__has_feature(objc_arc)
#error ARC must be enabled!
#endif

@interface SandboxFileAccessPanelDelegate ()

@property (readwrite, strong, nonatomic) NSArray *pathComponents;

@end


@implementation SandboxFileAccessPanelDelegate

- (instancetype)initWithFileURL:(NSURL *)fileURL {
    self = [super init];
    if (self) {
        NSParameterAssert(fileURL);
        self.pathComponents = fileURL.pathComponents;
    }
    return self;
}

#pragma mark -- NSOpenSavePanelDelegate

- (BOOL)panel:(id)sender shouldEnableURL:(NSURL *)url {
    NSParameterAssert(url);
    
    NSArray *pathComponents = self.pathComponents;
    NSArray *otherPathComponents = url.pathComponents;
    
    // if the url passed in has more components, it could not be a parent path or a exact same path
    if (otherPathComponents.count > pathComponents.count) {
        return NO;
    }
    
    // check that each path component in url, is the same as each corresponding component in self.url
    for (NSUInteger i = 0; i < otherPathComponents.count; ++i) {
        NSString *comp1 = otherPathComponents[i];
        NSString *comp2 = pathComponents[i];
        // not the same, therefore url is not a parent or exact match to self.url
        if (![comp1 isEqualToString:comp2]) {
            return NO;
        }
    }
    
    // there were no mismatches (or no components meaning url is root)
    return YES;
}

@end

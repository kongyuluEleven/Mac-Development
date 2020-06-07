//
//  SandboxFileAccessPersist.m
//  MacSandoxFileAccess
//
//  Created by kongyulu on 2020/6/7.
//  Copyright © 2020 kongyulu. All rights reserved.
//

#import "SandboxFileAccessPersist.h"

#if !__has_feature(objc_arc)
#error ARC must be enabled!
#endif

@implementation SandboxFileAccessPersist
+ (NSString *)keyForBookmarkDataForURL:(NSURL *)url {
    NSString *urlStr = [url absoluteString];
    return [NSString stringWithFormat:@"wondoershareFilmora_%1$@", urlStr];
    //return [NSString stringWithFormat:@"bd_%1$@", urlStr];
}

- (NSData *)bookmarkDataForURL:(NSURL *)url {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    // loop through the bookmarks one path at a time down the URL
    NSURL *subURL = url;
    while ([subURL path].length > 1) { // give up when only '/' is left in the path
        NSString *key = [SandboxFileAccessPersist keyForBookmarkDataForURL:subURL];
        NSData *bookmark = [defaults dataForKey:key];
        if (bookmark) { // if a bookmark is found, return it
            return bookmark;
        }
        subURL = [subURL URLByDeletingLastPathComponent];
    }
    
    // no bookmarks for the URL, or parent to the URL were found
    return nil;
}

- (void)setBookmarkData:(NSData *)data forURL:(NSURL *)url {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *key = [SandboxFileAccessPersist keyForBookmarkDataForURL:url];
    [defaults setObject:data forKey:key];
}

- (void)clearBookmarkDataForURL:(NSURL *)url {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *key = [SandboxFileAccessPersist keyForBookmarkDataForURL:url];
    [defaults removeObjectForKey:key];
}

@end

//
//  SandBoxAuthorize.m
//  MacSandoxFileAccess
//
//  Created by kongyulu on 2020/6/7.
//  Copyright © 2020 kongyulu. All rights reserved.
//

#import "SandBoxAuthorize.h"

#define KDefaultKey @"com.wondershare.customfolderbookmark"

@implementation SandBoxAuthorize
+ (BOOL)addBookmark:(NSString*)strPath isDirectory:(BOOL)isDir {
    NSURL * fileURL = [[NSURL alloc] initFileURLWithPath:strPath isDirectory:isDir];
    NSData *bookmarkData = nil;
    NSProcessInfo *info = [NSProcessInfo processInfo];
    NSUInteger MacMajorVersion = info.operatingSystemVersion.majorVersion;
    NSUInteger MacMinorVersion = info.operatingSystemVersion.minorVersion;
    NSUInteger MacBugFixVersion = info.operatingSystemVersion.patchVersion;
    NSError* error = nil;
    if (MacMajorVersion >= 10 && MacMinorVersion >= 7) {
        if (MacMinorVersion == 7) {
            if (MacBugFixVersion >= 3) {
                bookmarkData = [fileURL bookmarkDataWithOptions:1UL << 11//NSURLBookmarkCreationWithSecurityScope
                                 includingResourceValuesForKeys:nil
                                                  relativeToURL:nil
                                                          error:&error];
            }else
            {
                bookmarkData = [fileURL bookmarkDataWithOptions:NSURLBookmarkCreationSuitableForBookmarkFile
                                 includingResourceValuesForKeys:nil
                                                  relativeToURL:nil
                                                          error:&error];
            }
        }else{
            bookmarkData = [fileURL bookmarkDataWithOptions:1UL << 11//NSURLBookmarkCreationWithSecurityScope
                             includingResourceValuesForKeys:nil
                                              relativeToURL:nil
                                                      error:&error];
        }
    }else{
        bookmarkData = [fileURL bookmarkDataWithOptions:NSURLBookmarkCreationSuitableForBookmarkFile
                         includingResourceValuesForKeys:nil
                                          relativeToURL:nil
                                                  error:&error];
    }
    if (error) {
        NSLog(@"store bookmark error %@",fileURL.path);
        NSLog(@"bookmark data %@",bookmarkData);
        NSLog(@"book mark error %@",[error description]);
        return NO;
    }
    
    if (bookmarkData) {
        NSMutableDictionary * dicBookmarks = [[NSMutableDictionary alloc] init];
        NSDictionary * dicUDBookmarks = [[NSUserDefaults standardUserDefaults] valueForKey:KDefaultKey];
        
        if (dicUDBookmarks && [dicUDBookmarks isKindOfClass:[NSDictionary class]]) {
            [dicBookmarks addEntriesFromDictionary:dicUDBookmarks];
        }
        
        [dicBookmarks setValue:bookmarkData forKey:strPath];
        
        [[NSUserDefaults standardUserDefaults] setValue:dicBookmarks forKey:KDefaultKey];
        
        dicBookmarks = nil;
    }
    
    fileURL = nil;
    
    return nil == bookmarkData;
}

+ (void)authorizePath:(NSString *)strPath {
    NSDictionary * dicUDBookmarks = [[NSUserDefaults standardUserDefaults] valueForKey:KDefaultKey];

    if (dicUDBookmarks && [dicUDBookmarks isKindOfClass:[NSDictionary class]]) {
        NSData * bookmarkData = [dicUDBookmarks valueForKey:strPath];
        
        if (bookmarkData) {
            NSURL *url = nil;
            NSProcessInfo *info = [NSProcessInfo processInfo];
            NSUInteger MacMajorVersion = info.operatingSystemVersion.majorVersion;
            NSUInteger MacMinorVersion = info.operatingSystemVersion.minorVersion;
            NSUInteger MacBugFixVersion = info.operatingSystemVersion.patchVersion;
            NSError* error = nil;
            if (MacMajorVersion >= 10 && MacMinorVersion >= 7)
            {
                if (MacMinorVersion == 7) {
                    if (MacBugFixVersion >= 3) {
                        url = [NSURL URLByResolvingBookmarkData:bookmarkData options:1UL << 10 relativeToURL:nil bookmarkDataIsStale:nil error:&error];
                    }else
                    {
                        url =  [NSURL URLByResolvingBookmarkData:bookmarkData options:NSURLBookmarkResolutionWithoutUI relativeToURL:nil bookmarkDataIsStale:nil error:&error];
                    }
                }else
                {
                    url = [NSURL URLByResolvingBookmarkData:bookmarkData options:1UL << 10 relativeToURL:nil bookmarkDataIsStale:nil error:&error];
                }
            }else
            {
                url =  [NSURL URLByResolvingBookmarkData:bookmarkData options:NSURLBookmarkResolutionWithoutUI relativeToURL:nil bookmarkDataIsStale:nil error:&error];
            }
            if (url && [url respondsToSelector:@selector(startAccessingSecurityScopedResource)]) {
                [url performSelector:@selector(startAccessingSecurityScopedResource)];
            }
            
        }
    }
}

+ (void)deauthorizePath:(NSString *)strPath {
    NSDictionary * dicUDBookmarks = [[NSUserDefaults standardUserDefaults] valueForKey:KDefaultKey];
    
    if (dicUDBookmarks && [dicUDBookmarks isKindOfClass:[NSDictionary class]]) {
        NSData * bookmarkData = [dicUDBookmarks valueForKey:strPath];
        
        if (bookmarkData) {
            NSURL *url = nil;
            NSProcessInfo *info = [NSProcessInfo processInfo];
            NSUInteger MacMajorVersion = info.operatingSystemVersion.majorVersion;
            NSUInteger MacMinorVersion = info.operatingSystemVersion.minorVersion;
            NSUInteger MacBugFixVersion = info.operatingSystemVersion.patchVersion;
            NSError* error = nil;
            if (MacMajorVersion >= 10 && MacMinorVersion >= 7)
            {
                if (MacMinorVersion == 7) {
                    if (MacBugFixVersion >= 3) {
                        url = [NSURL URLByResolvingBookmarkData:bookmarkData options:1UL << 10 relativeToURL:nil bookmarkDataIsStale:nil error:&error];
                    }else
                    {
                        url =  [NSURL URLByResolvingBookmarkData:bookmarkData options:NSURLBookmarkResolutionWithoutUI relativeToURL:nil bookmarkDataIsStale:nil error:&error];
                    }
                }else
                {
                    url = [NSURL URLByResolvingBookmarkData:bookmarkData options:1UL << 10 relativeToURL:nil bookmarkDataIsStale:nil error:&error];
                }
            }else
            {
                url =  [NSURL URLByResolvingBookmarkData:bookmarkData options:NSURLBookmarkResolutionWithoutUI relativeToURL:nil bookmarkDataIsStale:nil error:&error];
            }

            if (url && [url respondsToSelector:@selector(stopAccessingSecurityScopedResource)]) {
                [url performSelector:@selector(stopAccessingSecurityScopedResource)];
            }

        }
    }
}

+ (BOOL) itemWritable: (NSString *)itemPath  {
    return [[NSFileManager defaultManager] isWritableFileAtPath:itemPath];
}

+ (BOOL) itemReadable: (NSString *) itemPath {
    return [[NSFileManager defaultManager] isReadableFileAtPath:itemPath];
}


+ (BOOL) isAuthoredFilePath: (NSString*) strFilePath {
     NSDictionary *dict=[[NSBundle mainBundle] infoDictionary];
     NSString *appId=[dict valueForKey:(NSString*)kCFBundleNameKey];
     NSString* appSupportPath = [NSHomeDirectory() stringByAppendingFormat:@"/Library/Application Support/%@",appId];
     NSString* movePath = [NSHomeDirectory() stringByAppendingFormat:@"/Movies"];
     NSString* photoPath = [NSHomeDirectory() stringByAppendingFormat:@"/Pictures"];
     NSString* musicPath = [NSHomeDirectory() stringByAppendingFormat:@"/Music"];
     NSString* downloadPath = [NSHomeDirectory() stringByAppendingFormat:@"/Downloads"];
     
     NSArray* arrResPath = [NSArray arrayWithObjects:appSupportPath, movePath, photoPath, musicPath, downloadPath, nil];
     for (NSString* path in arrResPath) {
         if ([strFilePath length] >= [path length] && [path isEqualToString:[strFilePath substringToIndex:[path length]]]) {
             return YES;
         }
     }
     
     return NO;
 }

+ (BOOL) storeFileURLWithBookmark:(NSURL*) mediaFileURL key:( NSString*) keyValue
 {
     NSData *bookmarkData = nil;
     NSProcessInfo *info = [NSProcessInfo processInfo];
     NSUInteger MacMajorVersion = info.operatingSystemVersion.majorVersion;
     NSUInteger MacMinorVersion = info.operatingSystemVersion.minorVersion;
     NSUInteger MacBugFixVersion = info.operatingSystemVersion.patchVersion;
     NSError* error = nil;
     if (MacMajorVersion >= 10 && MacMinorVersion >= 7) {
         if (MacMinorVersion == 7) {
             if (MacBugFixVersion >= 3) {
                 BOOL bWritable = [self itemWritable:[mediaFileURL absoluteString]];
                 BOOL bReadable = [self itemReadable:[mediaFileURL absoluteString]];
                 bookmarkData = [mediaFileURL bookmarkDataWithOptions:1UL << 11
                                       includingResourceValuesForKeys:nil
                                                        relativeToURL:nil
                                                                error:&error];
                 NSLog(@"%i",bWritable);
                 NSLog(@"%i",bReadable);
             }else
             {
                 bookmarkData = [mediaFileURL bookmarkDataWithOptions:NSURLBookmarkCreationSuitableForBookmarkFile
                                       includingResourceValuesForKeys:nil
                                                        relativeToURL:nil
                                                                error:&error];
             }
         }else{
             bookmarkData = [mediaFileURL bookmarkDataWithOptions:NSURLBookmarkCreationSuitableForBookmarkFile
                                   includingResourceValuesForKeys:nil
                                                    relativeToURL:nil
                                                            error:&error];
         }
     }else{
         bookmarkData = [mediaFileURL bookmarkDataWithOptions:NSURLBookmarkCreationSuitableForBookmarkFile
                               includingResourceValuesForKeys:nil
                                                relativeToURL:nil
                                                        error:&error];
     }
     
     NSLog(@"storeFileURLWithBookmark: bookmarkData=%@, url = %@, err = %@", bookmarkData, mediaFileURL, [error description]);
     
     if (error || !bookmarkData) {
         NSLog(@"store bookmark error %@",mediaFileURL.path);
         NSLog(@"bookmark data %@",bookmarkData);
         NSLog(@"book mark error %@",[error description]);
         return NO;
     }
     NSDictionary *urlDict = [[NSUserDefaults standardUserDefaults] objectForKey:keyValue];
     if (!urlDict) {
         urlDict = [NSMutableDictionary dictionaryWithObject:bookmarkData forKey:mediaFileURL.path];
     }else{
         NSMutableDictionary *mutUrlDict = [urlDict mutableCopy];
         [mutUrlDict setObject:bookmarkData forKey:mediaFileURL.path];
         urlDict = mutUrlDict;
     }
     [[NSUserDefaults standardUserDefaults] setObject:urlDict forKey:keyValue];
     [[NSUserDefaults standardUserDefaults] synchronize];
     
     return YES;
 }

+ (NSURL*) getPathStoreBookmark: (NSString*) songPath key: (NSString*) keyValue
    {
        NSDictionary *bookmarkDict = [[NSUserDefaults standardUserDefaults] objectForKey:keyValue];
        NSData *data = [bookmarkDict objectForKey:songPath];
        if (data) {
            NSURL *url = nil;
            NSProcessInfo *info = [NSProcessInfo processInfo];
            NSUInteger MacMajorVersion = info.operatingSystemVersion.majorVersion;
            NSUInteger MacMinorVersion = info.operatingSystemVersion.minorVersion;
            NSUInteger MacBugFixVersion = info.operatingSystemVersion.patchVersion;
            NSError* error = nil;
            
            if (MacMajorVersion >= 10 && MacMinorVersion >= 7)
            {
                if (MacMinorVersion == 7) {
                    if (MacBugFixVersion >= 3) {
                        url = [NSURL URLByResolvingBookmarkData:data options:1UL << 10 relativeToURL:nil bookmarkDataIsStale:nil error:nil];
                    }else
                    {
                        url =  [NSURL URLByResolvingBookmarkData:data options:NSURLBookmarkResolutionWithoutUI relativeToURL:nil bookmarkDataIsStale:nil error:nil];
                    }
                }else
                {
                    url = [NSURL URLByResolvingBookmarkData:data options:1UL << 10 relativeToURL:nil bookmarkDataIsStale:nil error:nil];
                }
            }else
            {
                url =  [NSURL URLByResolvingBookmarkData:data options:NSURLBookmarkResolutionWithoutUI relativeToURL:nil bookmarkDataIsStale:nil error:nil];
            }
            
            if (error) {
                NSLog(@"get store URL fail %@---%@---url %@",[error description],songPath,url);
                return [NSURL fileURLWithPath:songPath];
            }
            if (url) {
                if ([url respondsToSelector:@selector(startAccessingSecurityScopedResource)]) {
                    [url performSelector:@selector(startAccessingSecurityScopedResource)];
                }
                return url;
            }else
            {
                return [NSURL fileURLWithPath:songPath];
            }
        }else
        {
            return [NSURL fileURLWithPath:songPath];
        }
        return nil;
}




@end

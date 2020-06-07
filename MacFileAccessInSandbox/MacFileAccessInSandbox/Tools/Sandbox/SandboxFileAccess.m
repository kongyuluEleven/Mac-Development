//
//  SandboxFileAccess.m
//  MacSandoxFileAccess
//
//  Created by kongyulu on 2020/6/7.
//  Copyright © 2020 kongyulu. All rights reserved.
//

#import "SandboxFileAccess.h"

#import "SandboxFileAccessPersist.h"
#import "SandboxFileAccessPanelDelegate.h"


#if !__has_feature(objc_arc)
#error ARC must be enabled!
#endif

#define CFBundleDisplayName @"CFBundleDisplayName"
#define CFBundleName        @"CFBundleName"

@interface SandboxFileAccess ()
@property (nonatomic, strong) SandboxFileAccessPersist *defaultDelegate;
@end


@implementation SandboxFileAccess

+ (SandboxFileAccess *) fileAccess {
    return [[SandboxFileAccess alloc] init];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        NSString *applicationName = [[NSBundle mainBundle] objectForInfoDictionaryKey:CFBundleDisplayName];
        if (!applicationName) {
            applicationName = [[NSBundle mainBundle] objectForInfoDictionaryKey:CFBundleName];
        }
        
        self.title = NSLocalizedString(@"Allow Access", @"Sandbox Access panel title.");
        NSString *formatString = NSLocalizedString(@"%@ needs to access this path to continue. Click Allow to continue.", @"Sandbox Access panel message.");
        self.message = [NSString stringWithFormat:formatString, applicationName];
        self.prompt = NSLocalizedString(@"Allow", @"Sandbox Access panel prompt.");
        
        // create default delegate object that persists bookmarks to user defaults
        self.defaultDelegate = [[SandboxFileAccessPersist alloc] init];
        self.bookmarkPersistanceDelegate = _defaultDelegate;
    }
    return self;
}

- (NSURL *)askPermissionForURL:(NSURL *)url {
    NSParameterAssert(url);
    
    // this url will be the url allowed, it might be a parent url of the url passed in
    __block NSURL *allowedURL = nil;
    
    // create delegate that will limit which files in the open panel can be selected, to ensure only a folder
    // or file giving permission to the file requested can be selected
    SandboxFileAccessPanelDelegate *openPanelDelegate = [[SandboxFileAccessPanelDelegate alloc] initWithFileURL:url];
    
    // check that the url exists, if it doesn't, find the parent path of the url that does exist and ask permission for that
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *path = [url path];
    while (path.length > 1) { // give up when only '/' is left in the path or if we get to a path that exists
        if ([fileManager fileExistsAtPath:path isDirectory:NULL]) {
            break;
        }
        path = [path stringByDeletingLastPathComponent];
    }
    url = [NSURL fileURLWithPath:path];
    
    // display the open panel
    dispatch_block_t displayOpenPanelBlock = ^{
        NSOpenPanel *openPanel = [NSOpenPanel openPanel];
        [openPanel setMessage:self.message];
        [openPanel setCanCreateDirectories:NO];
        [openPanel setCanChooseFiles:YES];
        [openPanel setCanChooseDirectories:YES];
        [openPanel setAllowsMultipleSelection:NO];
        [openPanel setPrompt:self.prompt];
        [openPanel setTitle:self.title];
        [openPanel setShowsHiddenFiles:NO];
        [openPanel setExtensionHidden:NO];
        [openPanel setDirectoryURL:url];
        [openPanel setDelegate:openPanelDelegate];
        [[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
        NSInteger openPanelButtonPressed = [openPanel runModal];
        if (openPanelButtonPressed == NSFileHandlingPanelOKButton) {
            allowedURL = [openPanel URL];
            //NSData* bookmarkData = [self persistPermissionURL:allowedURL];
            NSError *err = nil;
            NSData *bookmarkData = [url bookmarkDataWithOptions:NSURLBookmarkCreationWithSecurityScope includingResourceValuesForKeys:nil relativeToURL:nil error:&err];
            
            NSLog(@"kongyulu获取到权限openPanelButtonPressed：bookmarkData=%@, url = %@,err=%@",bookmarkData,allowedURL,err);
        }
    };
    if ([NSThread isMainThread]) {
        displayOpenPanelBlock();
    } else {
        dispatch_sync(dispatch_get_main_queue(), displayOpenPanelBlock);
    }

    return allowedURL;
}

- (NSData *)persistPermissionPath:(NSString *)path {
    NSParameterAssert(path);
    
    return [self persistPermissionURL:[NSURL fileURLWithPath:path]];
}

- (NSData *)persistPermissionURL:(NSURL *)url {
    NSParameterAssert(url);
    // store the sandbox permissions
    NSError *err = nil;
    NSData *bookmarkData = [url bookmarkDataWithOptions:NSURLBookmarkCreationWithSecurityScope includingResourceValuesForKeys:nil relativeToURL:nil error:&err];
    if (bookmarkData) {
        [self.bookmarkPersistanceDelegate setBookmarkData:bookmarkData forURL:url];
        NSLog(@"kongyulu获取到权限：bookmarkData=%@, url = %@",bookmarkData,url);
    }
    return bookmarkData;
}

- (BOOL)accessFilePath:(NSString *)path withBlock:(SandboxFileAccessBlock)block persistPermission:(BOOL)persist {
    // Deprecated. Use 'accessFilePath:persistPermission:withBlock:' instead.
    return [self accessFilePath:path persistPermission:persist withBlock:block];
}

- (BOOL)accessFileURL:(NSURL *)fileURL withBlock:(SandboxFileAccessBlock)block persistPermission:(BOOL)persist {
    // Deprecated. Use 'accessFileURL:persistPermission:withBlock:' instead.
    return [self accessFileURL:fileURL persistPermission:persist withBlock:block];
}

- (BOOL)accessFilePath:(NSString *)path persistPermission:(BOOL)persist withBlock:(SandboxFileAccessBlock)block {
    return [self accessFileURL:[NSURL fileURLWithPath:path] persistPermission:persist withBlock:block];
}

- (BOOL)accessFileURL:(NSURL *)fileURL persistPermission:(BOOL)persist withBlock:(SandboxFileAccessBlock)block {
    NSParameterAssert(fileURL);
    NSParameterAssert(block);
    
    BOOL success = [self requestAccessPermissionsForFileURL:fileURL persistPermission:persist withBlock:^(NSURL *securityScopedFileURL, NSData *bookmarkData) {
        // execute the block with the file access permissions
        @try {
            [securityScopedFileURL startAccessingSecurityScopedResource];
            block();
        } @finally {
            [securityScopedFileURL stopAccessingSecurityScopedResource];
        }
    }];
    
    return success;
}

- (BOOL)requestAccessPermissionsForFilePath:(NSString *)filePath persistPermission:(BOOL)persist withBlock:(SandboxFileSecurityScopeBlock)block {
    NSParameterAssert(filePath);
    
    NSURL *fileURL = [NSURL fileURLWithPath:filePath];
    return [self requestAccessPermissionsForFileURL:fileURL persistPermission:persist withBlock:block];
}

- (BOOL)requestAccessPermissionsForFileURL:(NSURL *)fileURL persistPermission:(BOOL)persist withBlock:(SandboxFileSecurityScopeBlock)block {
    NSParameterAssert(fileURL);
    
    NSURL *allowedURL = nil;
    
    // standardize the file url and remove any symlinks so that the url we lookup in bookmark data would match a url given by the askPermissionForURL method
    fileURL = [[fileURL URLByStandardizingPath] URLByResolvingSymlinksInPath];
    
    // lookup bookmark data for this url, this will automatically load bookmark data for a parent path if we have it
    NSData *bookmarkData = [self.bookmarkPersistanceDelegate bookmarkDataForURL:fileURL];
    if (bookmarkData) {
        // resolve the bookmark data into an NSURL object that will allow us to use the file
        BOOL bookmarkDataIsStale;
        allowedURL = [NSURL URLByResolvingBookmarkData:bookmarkData options:NSURLBookmarkResolutionWithSecurityScope|NSURLBookmarkResolutionWithoutUI relativeToURL:nil bookmarkDataIsStale:&bookmarkDataIsStale error:NULL];
        // if the bookmark data is stale we'll attempt to recreate it with the existing url object if possible (not guaranteed)
        if (bookmarkDataIsStale) {
            bookmarkData = nil;
            [self.bookmarkPersistanceDelegate clearBookmarkDataForURL:fileURL];
            if (allowedURL) {
                bookmarkData = [self persistPermissionURL:allowedURL];
                if (!bookmarkData) {
                    allowedURL = nil;
                }
            }
        }
    }
    
    // if allowed url is nil, we need to ask the user for permission
    if (!allowedURL) {
        allowedURL = [self askPermissionForURL:fileURL];
        if (!allowedURL) {
            // if the user did not give permission, exit out here
            return NO;
        }
    }
    
    // if we have no bookmark data and we want to persist, we need to create it
    if (persist && !bookmarkData) {
        bookmarkData = [self persistPermissionURL:allowedURL];
    }
    
    if (block) {
        block(allowedURL, bookmarkData);
    }
    
    return YES;
}

- (void)setBookmarkPersistanceDelegate:(NSObject<SandboxFileAccessProtocol> *)bookmarkPersistanceDelegate
{
    // revert to default delegate object if no delegate provided
    if (bookmarkPersistanceDelegate == nil) {
        _bookmarkPersistanceDelegate = self.defaultDelegate;
    } else {
        _bookmarkPersistanceDelegate = bookmarkPersistanceDelegate;
    }
}

@end

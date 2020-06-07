//
//  SandboxFileAccess.h
//  MacSandoxFileAccess
//
//  Created by kongyulu on 2020/6/7.
//  Copyright © 2020 kongyulu. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@import AppKit;

#pragma mark -
#pragma mark SandboxFileAccessProtocol

@protocol SandboxFileAccessProtocol<NSObject>
@required
- (NSData *)bookmarkDataForURL:(NSURL *)url;
- (void)setBookmarkData:(NSData *)data forURL:(NSURL *)url;
- (void)clearBookmarkDataForURL:(NSURL *)url;

@end


#pragma mark -
#pragma mark SandboxFileAccess

typedef void (^SandboxFileAccessBlock)(void);
typedef void (^SandboxFileSecurityScopeBlock)(NSURL *securityScopedFileURL, NSData *bookmarkData);

@interface SandboxFileAccess : NSObject
/*! @brief The title of the NSOpenPanel displayed when asking permission to access a file.
 Default: "Allow Access"
 */
@property (readwrite, copy, nonatomic) NSString *title;
/*! @brief The message contained on the the NSOpenPanel displayed when asking permission to access a file.
 Default: "[Application Name] needs to access this path to continue. Click Allow to continue."
 */
@property (readwrite, copy, nonatomic) NSString *message;
/*! @brief The prompt button on the the NSOpenPanel displayed when asking permission to access a file.
 Default: "Allow"
 */
@property (readwrite, copy, nonatomic) NSString *prompt;

/*! @brief This is an optional delegate object that can be provided to customize the persistance of bookmark data (e.g. in a Core Data database).
 Default: nil (Default uses the AppSandboxFileAccessPersist class.)
 */
@property (nonatomic, weak) id <SandboxFileAccessProtocol> bookmarkPersistanceDelegate;

/*! @brief Create the object with the default values. */
+ (SandboxFileAccess *) fileAccess;

/*! @brief Initialise the object with the default values. */
- (instancetype)init;

/*! @brief Access a file path to read or write, automatically gaining permission from the user with NSOpenPanel if required
 and using persisted permissions if possible.
 
 @see accessFile:persistPermission:withBlock:
 @see securityScopedURLForFilePath:persistPermission:bookmark:
 
 @param path A file path, either a file or folder, that the caller needs access to.
 @param persist If YES will save the permission for future calls.
 @param block The block that will be given access to the file or folder.
 @return YES if permission was granted or already available, NO otherwise.
 */
- (BOOL)accessFilePath:(NSString *)path persistPermission:(BOOL)persist withBlock:(SandboxFileAccessBlock)block;

/*!
 @warning Deprecated.
 
 @see accessFilePath:persistPermission:withBlock:
 
 @param path A file path, either a file or folder, that the caller needs access to.
 @param block The block that will be given access to the file or folder.
 @param persist If YES will save the permission for future calls.
 @return YES if permission was granted or already available, NO otherwise.
 */
- (BOOL)accessFilePath:(NSString *)path withBlock:(SandboxFileAccessBlock)block persistPermission:(BOOL)persist __attribute__((deprecated("Use 'accessFilePath:persistPermission:withBlock:' instead.")));

/*! @brief Access a file URL to read or write, automatically gaining permission from the user with NSOpenPanel if required
 and using persisted permissions if possible.
 
 @see requestAccessPermissionsForFileURL:persistPermission:withBlock:
 
 @discussion Internally calls `requestAccessPermissionsForFileURL:persistPermission:withBlock:` and accesses the returned scoped URL if successful.
 
 @discussion See `requestAccessPermissionsForFileURL:persistPermission:withBlock:` for detailed behaviour.
 
 @param fileURL A file URL, either a file or folder, that the caller needs access to.
 @param persist If YES will save the permission for future calls.
 @param block The block that will be given access to the file or folder.
 @return YES if permission was granted or already available, NO otherwise.
 */
- (BOOL)accessFileURL:(NSURL *)fileURL persistPermission:(BOOL)persist withBlock:(SandboxFileAccessBlock)block;

/*!
 @warning Deprecated.
 
 @see accessFileURL:persistPermission:withBlock:
 
 @param fileURL A file URL, either a file or folder, that the caller needs access to.
 @param persist If YES will save the permission for future calls.
 @param block The block that will be given access to the file or folder.
 @return YES if permission was granted or already available, NO otherwise.
 */
- (BOOL)accessFileURL:(NSURL *)fileURL withBlock:(SandboxFileAccessBlock)block persistPermission:(BOOL)persist __attribute__((deprecated("Use 'accessFileURL:persistPermission:withBlock:' instead.")));

/*! @brief Request access permission for a file path to read or write, automatically with NSOpenPanel if required
 and using persisted permissions if possible.
 
 @see securityScopedURLForFilePath:persistPermission:bookmark:
 
 @param filePath A file path, either a file or folder, that the caller needs access to.
 @param persist If YES will save the permission for future calls.
 @return YES if permission was granted or already available, NO otherwise.
 */
- (BOOL)requestAccessPermissionsForFilePath:(NSString *)filePath persistPermission:(BOOL)persist withBlock:(SandboxFileSecurityScopeBlock)block;

/*! @brief Request access permission for a file path to read or write, automatically with NSOpenPanel if required
 and using persisted permissions if possible.
 
 @discussion Use this function to access a file URL to either read or write in an application restricted by the App Sandbox.
 This function will ask the user for permission if necessary using a well formed NSOpenPanel. The user will
 have the option of approving access to the URL you specify, or a parent path for that URL. If persist is YES
 the permission will be stored as a bookmark in NSUserDefaults and further calls to this function will
 load the saved permission and not ask for permission again.
 
 @discussion If the file URL does not exist, it's parent directory will be asked for permission instead, since permission
 to the directory will be required to write the file. If the parent directory doesn't exist, it will ask for
 permission of whatever part of the parent path exists.
 
 @discussion Note: If the caller has permission to access a file because it was dropped onto the application or introduced
 to the application in some other way, this function will not be aware of that permission and still prompt
 the user. To prevent this, use the persistPermission function to persist a permission you've been given
 whenever a user introduces a file to the application. E.g. when dropping a file onto the application window
 or dock or when using an NSOpenPanel.
 
 @param fileURL A file URL, either a file or folder, that the caller needs access to.
 @param persist If YES will save the permission for future calls.
 @param block The block that will be given access to the file or folder.
 @return YES if permission was granted or already available, NO otherwise.
 */
- (BOOL)requestAccessPermissionsForFileURL:(NSURL *)fileURL persistPermission:(BOOL)persist withBlock:(SandboxFileSecurityScopeBlock)block;

/*! @brief Persist a security bookmark for the given path. The calling application must already have permission.
 
 @see persistPermissionURL:
 
 @param path The path with permission that will be persisted.
 @return Bookmark data if permission was granted or already available, nil otherwise.
 */
- (NSData *)persistPermissionPath:(NSString *)path;

/*! @brief Persist a security bookmark for the given URL. The calling application must already have permission.
 
 @discussion Use this function to persist permission of a URL that has already been granted when a user introduced
 a file to the calling application. E.g. by dropping the file onto the application window, or dock icon,
 or when using an NSOpenPanel.
 
 Note: If the calling application does not have access to this file, this call will do nothing.
 
 @param url The URL with permission that will be persisted.
 @return Bookmark data if permission was granted or already available, nil otherwise.
 */
- (NSData *)persistPermissionURL:(NSURL *)url;
@end

NS_ASSUME_NONNULL_END

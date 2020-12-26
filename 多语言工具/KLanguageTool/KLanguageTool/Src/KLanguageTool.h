//
//  KLanguageTool.h
//  KLanguageTool
//
//  Created by kongyulu on 2020/12/26.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface KLanguageTool : NSObject
- (void)createFile:(NSString *)file;
- (void)createDefaultFile;
@end

NS_ASSUME_NONNULL_END

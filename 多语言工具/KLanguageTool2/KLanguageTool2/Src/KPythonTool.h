//
//  KPythonTool.h
//  KLanguageTool2
//
//  Created by kongyulu on 2020/12/28.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface KPythonTool : NSObject

- (BOOL) excutePython:(NSString *)pythonFilePath recursion:(NSString *)isRecursion;

@end

NS_ASSUME_NONNULL_END

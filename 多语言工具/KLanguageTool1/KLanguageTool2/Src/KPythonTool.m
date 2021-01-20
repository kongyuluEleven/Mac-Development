//
//  KPythonTool.m
//  KLanguageTool2
//
//  Created by kongyulu on 2020/12/28.
//

#import "KPythonTool.h"

@interface KPythonTool() {
    NSTask * _notarizationTask;
}

@end

@implementation KPythonTool

- (BOOL) excutePython:(NSString *)pythonFilePath recursion:(NSString *)isRecursion {
    
    if (![pythonFilePath hasSuffix:@".py"]) {
        NSLog(@"当前python文件类型不对!!!");
        return NO;
    }
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:@"/usr/bin/python"]) {
        NSLog(@"/usr/bin/python 下没有安装python2.7 !!!");
        return NO;
    }
    
    NSArray *params = @[pythonFilePath,isRecursion];
    NSString *ret = [self runCommandWithTask:@"/usr/bin/python" cmd:params waitTask:NO];
    NSLog(@"执行runCommandWithTask 结果: %@",ret);
    if ([ret length] > 1) return NO;
    
    return YES;
}


- (NSString *)runCommandWithTask:(NSString *)cmdPath cmd:(NSArray *)cmds waitTask:(BOOL)wait {
    [self destoryNotarizationTask];
    
    _notarizationTask = [[NSTask alloc] init];
    [_notarizationTask setLaunchPath: cmdPath];
    
    [_notarizationTask setArguments: cmds];
    
    NSLog(@"cmdPath: %@\nparams: %@",cmdPath, cmds);
    
    NSPipe *pipe = [NSPipe pipe];
    [_notarizationTask setStandardOutput: pipe];
    NSFileHandle *file = [pipe fileHandleForReading];
    
    NSPipe *errPipe = [NSPipe pipe];
    [_notarizationTask setStandardError:errPipe];
    NSFileHandle *errFileHandle = [errPipe fileHandleForReading];
    
    [_notarizationTask launch];
    
    if (wait) {
        [_notarizationTask waitUntilExit];
    }

    NSData *data = [file readDataToEndOfFile];
    NSData *errData = [errFileHandle readDataToEndOfFile];
    NSString *string = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding] ;
    NSString *errStr = [[NSString alloc] initWithData: errData encoding: NSUTF8StringEncoding];
    
    if (string) {
        if (errStr.length > 0) {
            string = [string stringByAppendingFormat:@"\n StandardError output: %@",errStr];
        }
        
    }else {
        NSLog(@"StandardOutput NULL");
        string = errStr;
    }

    
    if (wait) {
        return _notarizationTask.terminationStatus == 0 ? @"" : @"fail";
    }
    
    [self destoryNotarizationTask];
    
    return string;
}


- (void)destoryNotarizationTask {
    _notarizationTask = nil;
}


@end

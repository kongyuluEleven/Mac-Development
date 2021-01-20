//
//  KPythonManager.m
//  KLanguageTool2
//
//  Created by kongyulu on 2020/12/28.
//

#import "KPythonManager.h"
#import "KPythonTool.h"


@interface KPythonManager() {
    KPythonTool *_tool;
}

@property (nonatomic, strong) KPythonTool *tool;

@end


@implementation KPythonManager

- (KPythonTool *)tool {
    if (!_tool) {
        _tool = [[KPythonTool alloc] init];
    }
    return _tool;
}

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [KPythonManager sharedInstance];// 确保内部的变量、notification 都正确配置
    });
}

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static KPythonManager *instance = nil;
    dispatch_once(&onceToken,^{
        instance = [[super allocWithZone:NULL] init];
        // 先设置默认值，不然可能变量的指针地址错误
    });
    return instance;
}

+ (id)allocWithZone:(struct _NSZone *)zone{
    return [self sharedInstance];
}

- (void)dealloc {
    // QMUIHelper 若干个分类里有用到消息监听，所以在 dealloc 的时候注销一下
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

static NSMutableSet<NSString *> *executedIdentifiers;
+ (BOOL)executeBlock:(void (NS_NOESCAPE ^)(void))block oncePerIdentifier:(NSString *)identifier {
    if (!block || identifier.length <= 0) return NO;
    @synchronized (self) {
        if (!executedIdentifiers) {
            executedIdentifiers = NSMutableSet.new;
        }
        if (![executedIdentifiers containsObject:identifier]) {
            [executedIdentifiers addObject:identifier];
            block();
            return YES;
        }
        return NO;
    }
}

- (BOOL) convertStringToXls {
    NSString *pyPath = [[[[NSBundle mainBundle] executablePath] stringByDeletingLastPathComponent] stringByAppendingPathComponent:@"Strings2Xls.py"];
    [self.tool excutePython:pyPath recursion:@""];
    return YES;
}


- (BOOL) convertXlsToString {
    NSString *pyPath = [[[[NSBundle mainBundle] executablePath] stringByDeletingLastPathComponent] stringByAppendingPathComponent:@"Xls2Strings.py"];
    [self.tool excutePython:pyPath recursion:@""];
    return YES;
}

@end

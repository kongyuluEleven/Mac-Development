//
//  ViewController.m
//  KLanguageTool
//
//  Created by kongyulu on 2020/12/26.
//

#import "ViewController.h"
#import "KLanguageTool.h"

@interface ViewController ()

@property (weak) IBOutlet NSButton *openButton;
@property (weak) IBOutlet NSButton *saveButton;
@property (weak) IBOutlet NSTextField *fileLabel;
@property (weak) IBOutlet NSButton *testButton;

@property (nonatomic,strong) KLanguageTool *tool;

@end

@implementation ViewController

- (KLanguageTool *)tool {
    if (!_tool) {
        _tool = [[KLanguageTool alloc] init];
    }
    return _tool;
}



- (IBAction)openButtonPressed:(NSButton *)sender {
    
//    NSOpenPanel* panel = [NSOpenPanel openPanel];
//    __weak typeof(self)weakSelf = self;
//    //是否可以创建文件夹
//    panel.canCreateDirectories = YES;
//    //是否可以选择文件夹
//    panel.canChooseDirectories = YES;
//    //是否可以选择文件
//    panel.canChooseFiles = YES;
//
//    //是否可以多选
//    [panel setAllowsMultipleSelection:NO];
//
//    //显示
//    [panel beginSheetModalForWindow:self.window completionHandler:^(NSInteger result) {
//
//        //是否点击open 按钮
//        if (result == NSModalResponseOK) {
//            //NSURL *pathUrl = [panel URL];
//            NSString *pathString = [panel.URLs.firstObject path];
//            weakSelf.fileLabel.stringValue = pathString;
//        }
//
//
//    }];
}


- (IBAction)saveButtonPressed:(NSButton *)sender {
    if ([self.fileLabel.stringValue hasSuffix:@".xls"]) {
        [self.tool createFile:self.fileLabel.stringValue];
    }else {
        NSLog(@"不能解析该文件");
        [self openAlertPanelWithTitle:@"提示" message:@"只能解析xls文件" btnTitles:nil complete:nil];
    }
    
}


- (IBAction)defalutButtonPressed:(NSButton *)sender {
    [self.tool createDefaultFile];
}

- (void)openAlertPanelWithTitle:(NSString *)title
                        message:(NSString * )message
                      btnTitles:(NSArray * )btnTitles
                       complete:(void(^)(NSInteger index))complete
{
    
//    NSAlert *alert = [[NSAlert alloc] init];
//    alert.icon = [NSImage imageNamed:@"mainIcon"];
//
//    for (NSString * title in btnTitles) {
//        [alert addButtonWithTitle:title]; // 从1000开始递增
//    }
//    if(!title || title.length == 0){
//        title = @"温馨提示";
//    }
//    //提示的标题
//    [alert setMessageText:title];
//    //提示的详细内容
//    [alert setInformativeText:message];
//    //设置告警风格
//    [alert setAlertStyle:NSAlertStyleInformational];
//
//    //开始显示告警
//    [alert beginSheetModalForWindow:self.window
//                  completionHandler:^(NSModalResponse returnCode){
//                      //用户点击告警上面的按钮后的回调
//                      //从1000开始递增
//                      if (complete) {
//                          complete(returnCode - 1000);
//                      }
//
//                  }
//     ];
}

- (void)viewDidLoad {
    [super viewDidLoad];

}


- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}


@end

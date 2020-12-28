//
//  ViewController.m
//  KLanguageTool
//
//  Created by kongyulu on 2020/12/26.
//

#import "ViewController.h"
#import "KLangaugeWindowController.h"

@interface ViewController ()

@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];

}

- (IBAction)btnStringToExcelClicked:(id)sender {
}

- (IBAction)btnExcelToStringClicked:(id)sender {
    KLangaugeWindowController *vc = [[KLangaugeWindowController alloc] init];
    
}


- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}


@end

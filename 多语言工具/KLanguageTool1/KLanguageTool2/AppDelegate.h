//
//  AppDelegate.h
//  KLanguageTool2
//
//  Created by kongyulu on 2020/12/28.
//

#import <Cocoa/Cocoa.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (readonly, strong) NSPersistentContainer *persistentContainer;


@end


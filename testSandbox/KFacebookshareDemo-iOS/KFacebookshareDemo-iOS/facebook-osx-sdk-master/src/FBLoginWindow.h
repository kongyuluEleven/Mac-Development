#import <Cocoa/Cocoa.h>


@protocol FBLoginWindowDelegate <NSObject>

- (void)fbWindowLogin:(NSString*)token expirationDate:(NSDate*)expirationDate;

- (void)fbWindowNotLogin:(BOOL)cancelled;

@end

@interface FBLoginWindow : NSWindowController

- (instancetype)initWithWindow:(NSWindow *)window
                           URL:(NSString *)loginDialogURL
                   loginParams:(NSDictionary *)params
                      delegate:(id)delegate;

- (void)show;

@end

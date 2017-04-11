//
//  BSUScreenController.h
//
//
//  Created by Grzegorz Maciak on 18.11.2016.
//  Copyright © 2016 Grzegorz Maciak. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomNavigationBar.h"
#import "Constants.h"
#import "UIView+Find.h"
#import <MBProgressHUD/MBProgressHUD.h>
//#import <Google/Analytics.h>

//#define CustomNavigationBar UIView

@protocol BSUScreenDataLoading <NSObject>
@optional
- (void)userDidChangeLocale;

- (void)refresh;
- (void)refresh:(void (^)(void))done;

@required
+ (NSArray *)observedDataUpdates; // array of types (classes) for which Data Storage Update notifications are handled by the screen
- (void)didUpdateData:(Class)type;
- (void)didFailUpdatingData:(Class)type error:(NSError *)error;
@end

@interface UIViewController (BESynchronizationUtils)

@property(weak,nonatomic) IBOutlet CustomNavigationBar *customNavigationBar;

- (MBProgressHUD*)omShowHUD;
- (void)showInfoAlertWithTitle:(NSString*)title message:(NSString*)message;

- (void)registerForDataNotificationsObserving;

- (IBAction)onBack:(id)sender;
//- (IBAction)onMenu:(id)sender;
- (void)onRefresh:(id)sender;

@end


@interface BSUScreenController : UIViewController <BSUScreenDataLoading>

- (void)userDidChangeLocale;

- (void)refresh;
- (void)refresh:(void (^)(void))done;

@end

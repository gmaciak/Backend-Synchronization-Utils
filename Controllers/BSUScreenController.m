//
//  BSUScreenController.m
//  
//
//  Created by Grzegorz Maciak on 18.11.2016.
//  Copyright © 2016 Grzegorz Maciak. All rights reserved.
//

#import "BSUScreenController.h"
#import "Constants.h"
#import "BSUDataProvider.h"
#import <objc/runtime.h>
#import "NSString+Localizable.h"

@implementation UIViewController (BESynchronizationUtils)

- (void)registerForDataNotificationsObserving {
    [self.customNavigationBar.refreshButton addTarget:self action:@selector(onRefresh:) forControlEvents:UIControlEventTouchUpInside];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onLocaleDidChangeNotificationHandler:) name:NSCurrentLocaleDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onDataUpdateNotification:) name:BSUDataProviderDidUpdateDataNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onDataUpdatingFailedNotification:) name:BSUDataProviderUpdateingDataFailedNotification object:nil];
}

- (CustomNavigationBar *)customNavigationBar {
    return objc_getAssociatedObject(self, @selector(customNavigationBar));
}

- (void)setCustomNavigationBar:(CustomNavigationBar *)customNavigationBar{
    objc_setAssociatedObject(self, @selector(customNavigationBar), customNavigationBar, OBJC_ASSOCIATION_ASSIGN);
}

- (BOOL)enableRefreshButton {
    return objc_getAssociatedObject(self, @selector(enableRefreshButton));
}

- (void)setEnableRefreshButton:(BOOL)enableRefreshButton{
    objc_setAssociatedObject(self, @selector(enableRefreshButton), @(enableRefreshButton), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (MBProgressHUD*)omShowHUD {
    MBProgressHUD * hud = [MBProgressHUD HUDForView:self.view];
    if (!hud) {
        hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.removeFromSuperViewOnHide = NO;
        UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setImage:[UIImage imageNamed:@"icoRefresh"] forState:UIControlStateNormal];
        [button setTitle:NSLocalizedString(@"Refresh", nil) forState:UIControlStateNormal];
        [button addTarget:self action:@selector(onRefresh:) forControlEvents:UIControlEventTouchUpInside];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        hud.customView = button;
        hud.backgroundView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.7];
        UITapGestureRecognizer* tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onHUDTapGesture:)];
        [hud addGestureRecognizer:tapGR];
    }else  if ([[hud valueForKey:@"finished"] boolValue]) {
        [hud showAnimated:YES];
    }
    if (self.customNavigationBar) {
        [self.view bringSubviewToFront:self.customNavigationBar];
    }
    return hud;
}

- (void)onHUDTapGesture:(UITapGestureRecognizer*)sender {
    MBProgressHUD* hud = (MBProgressHUD*)sender.view;
    if (hud.mode == MBProgressHUDModeCustomView) {
        [hud hideAnimated:YES];
        if (self.enableRefreshButton) {
            [self.customNavigationBar setRefreshButtonVisible:YES];
        }
    }
}

#pragma mark Notification Handlers

- (void)onDataUpdateNotification:(NSNotification*)notif {
    if ([self conformsToProtocol:@protocol(BSUScreenDataLoading)]) {
        Class type = notif.userInfo[BSUDataProviderUpdatedTypeKey];
        if (type != Nil) {
            if ([[[self class] observedDataUpdates] indexOfObjectIdenticalTo:type] != NSNotFound) {
                [(id<BSUScreenDataLoading>)self didUpdateData:notif.userInfo[BSUDataProviderUpdatedTypeKey]];
            }
        }
    }
}

- (void)onDataUpdatingFailedNotification:(NSNotification*)notif {
    if ([self conformsToProtocol:@protocol(BSUScreenDataLoading)]) {
        Class type = notif.userInfo[BSUDataProviderUpdatedTypeKey];
        if (type != Nil) {
            if ([[[self class] observedDataUpdates] indexOfObjectIdenticalTo:type] != NSNotFound) {
                [(id<BSUScreenDataLoading>)self didFailUpdatingData:notif.userInfo[BSUDataProviderUpdatedTypeKey] error:notif.userInfo[BSUDataProviderUpdatedErrorKey]];
            }
        }
    }
}

-(void)onLocaleDidChangeNotificationHandler:(NSNotification*)notification {
    if ([self conformsToProtocol:@protocol(BSUScreenDataLoading)] &&
        [self respondsToSelector:@selector(userDidChangeLocale)]) {
        [(id<BSUScreenDataLoading>)self userDidChangeLocale];
    }
}

#pragma mark BSUScreenDataLoading (example)

//// array of types (classes) for which Data Storage Update notifications are handled by the screen
//+ (NSArray *)observedUpdates {
//    return nil;
//}
//
//- (void)refresh {
//    [self refresh:nil];
//}
//
//- (void)refresh:(void (^)(void))done {
//    if (done) done();
//}
//
//- (void)didUpdateData:(Class)type { }
//
//- (void)didFailUpdatingData:(Class)type error:(NSError *)error { }
//
//- (void)userDidChangeLocale {
//    [self refresh];
//}

- (void)showInfoAlertWithTitle:(NSString*)title message:(NSString*)message {
    // alert
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK".localizedWithKey(@"Alert.button: OK") style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - Actions

- (IBAction)onBack:(id)sender {
    if (self.presentingViewController) {
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}

//- (IBAction)onMenu:(id)sender {
//    if ([self.navigationController.parentViewController isKindOfClass:[MainViewController class]]) {
//        MainViewController* mainController = (MainViewController*)self.navigationController.parentViewController;
//        [mainController toogleMenu];
//    }
//}

- (void)onRefresh:(id)sender {
    //    [self.customNavigationBar setRefreshButtonVisible:NO animated:YES];
    MBProgressHUD* hud = [MBProgressHUD HUDForView:self.view];
    hud.mode = MBProgressHUDModeIndeterminate;
    if ([self conformsToProtocol:@protocol(BSUScreenDataLoading)] &&
        [self respondsToSelector:@selector(refresh)]) {
        [(id<BSUScreenDataLoading>)self refresh];
    }
    
}

@end

@implementation BSUScreenController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self registerForDataNotificationsObserving];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // !!!: Google Analytics use storyboard view controller title to track screens
//    if (self.title) {
//        id<GAITracker> tracker = [GAI sharedInstance].defaultTracker;
//        [tracker set:kGAIScreenName value:self.title];
//        [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
//    }
}

#pragma mark BSUScreenDataLoading

+ (NSArray *)observedDataUpdates {
    return nil;
}

- (void)refresh {
    [self refresh:nil];
}

- (void)refresh:(void (^)(void))done {
    if (done) done();
}

- (void)didUpdateData:(Class)type {
    [[MBProgressHUD HUDForView:self.view] hideAnimated:YES];
}

- (void)didFailUpdatingData:(Class)type error:(NSError *)error {
    MBProgressHUD * hud = [MBProgressHUD HUDForView:self.view];
    if (hud) {
        hud.mode = MBProgressHUDModeCustomView;
    }
}

- (void)userDidChangeLocale {
    [self refresh];
}

@end

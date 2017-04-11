//
//  LocationServiceManager.m
//  
//
//  Created by Grzegorz Maciak on 21.12.2016.
//  Copyright © 2016 Grzegorz Maciak. All rights reserved.
//

#import "BSULocationServiceManager.h"
#import "UIAlertController+Presentation.h"
#import "UIApplication+OpenURL.h"
#import "BSUConstants.h"
//#import <MapKit/MapKit.h>

NSString* const BSULocationServiceDidChangeStatusNotification = @"BSULocationServiceDidChangeStatusNotification";
NSString* const BSULocationServiceDidUpdateLocationNotification = @"BSULocationServiceDidUpdateLocationNotification";
NSString* const BSUUserDidNotEnableLocationServiceNotification = @"BSUUserDidNotEnableLocationServiceNotification";

// user defaults keys
NSString* const BSUSkipInAppLocationServiceRequestAlertKey = @"BSUSkipInAppLocationServiceRequestAlert";
NSString* const BSUInAppLocationServiceAllowedKey = @"BSUInAppLocationServiceAllowed";

@interface BSULocationServiceManager () {
    BOOL userShouldEnableLocationServiceOnDevice;
    NSNumberFormatter* distanceFormatter;
}
@property(nonatomic,assign) BOOL isInAppLocationServiceRequestAlertVisible;
@end

@implementation BSULocationServiceManager

@synthesize locationManager;
@synthesize lastLocation;
@synthesize locationServiceRestricted = isLocationServiceRestricted;

SINGLETON_IMPLEMENTATION(LocationServiceManager)

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (id)init {
    self = [super init];
    if (self){
        locationManager = [[CLLocationManager alloc] init];
        locationManager.delegate = self;
        lastLocation = locationManager.location;
#if defined(DEBUG) && defined(LOCATION)
        lastLocation = LOCATION;
#endif
        locationServiceStatusNotDetermined = [CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForegroundNotificationHandler:) name:UIApplicationWillEnterForegroundNotification object:nil];
    }
    return self;
}

- (BOOL)isInAppLocationServiceAllowed {
    return [[NSUserDefaults standardUserDefaults] boolForKey:BSUInAppLocationServiceAllowedKey];
}

- (BOOL)isLocationServiceUseAllowed {
    return [CLLocationManager authorizationStatus] > kCLAuthorizationStatusDenied && [self isInAppLocationServiceAllowed];
}

- (BOOL)isLocationAvailable {
    return [self isLocationServiceUseAllowed] && self.lastLocation != nil;
}

- (BOOL)shouldSkipInAppLocationServiceAccessRequest {
    return [[NSUserDefaults standardUserDefaults] boolForKey:BSUSkipInAppLocationServiceRequestAlertKey];
}

#pragma mark - Location Service access requests alerts

- (void)firstLaunchRequestIfNeeded {
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"BSUSkipFirstLaunchLocationRequest"]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"BSUSkipFirstLaunchLocationRequest"];
        [self requestLocationServiceAuthorizationIfNeeded];
    }
}

- (void)requestLocationServiceAuthorizationIfNeeded {
    weakify(self);
    if (![self isLocationServiceUseAllowed]) {
        [self requestInAppLocationServiceAccessWithCompletion:^(BOOL userShouldBeAsked, BOOL userDidAgree) {
            strongify(self);
            if (!userShouldBeAsked || userDidAgree) {
                if (userDidAgree) {
                    // set value
                    [self setAllowLocationServiceUse:YES notify:[CLLocationManager authorizationStatus] > kCLAuthorizationStatusDenied];
                }
                // notify about other requirements
                if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined) {
                    [self.locationManager requestWhenInUseAuthorization];
                }
                else if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied) {
                    [self requestLocationSettingsChangeWithCompletion:nil];
                }
            }
        }];
    }
}

- (void)requestInAppLocationServiceAccessWithCompletion:(void(^)(BOOL userShouldBeAsked, BOOL userDidAgree))completion {
    BOOL shuldAsk = ![self shouldSkipInAppLocationServiceAccessRequest];
    if (!_isInAppLocationServiceRequestAlertVisible && shuldAsk) {
        _isInAppLocationServiceRequestAlertVisible = YES;
        weakify(self);
        
        // alert
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"ALERT_IN_APP_REQUEST_LOCATION_SERVICE_TITLE", nil) message:NSLocalizedString(@"ALERT_IN_APP_REQUEST_LOCATION_SERVICE_MESSAGE", nil) preferredStyle:UIAlertControllerStyleAlert];
        
        // allow action
        [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"ALERT_IN_APP_REQUEST_LOCATION_SERVICE_BUTTON", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            strongify(self);
            
            // remember to not show this alert again
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:BSUSkipInAppLocationServiceRequestAlertKey];
            
            if (completion) {
                completion(shuldAsk,YES);
            }
            self.isInAppLocationServiceRequestAlertVisible = NO;
        }]];
        
        // cancel action
        [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"ALERT_IN_APP_REQUEST_LOCATION_SERVICE_CANCEL_BUTTON", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            strongify(self);
            
            if (completion) {
                completion(shuldAsk,NO);
            }
            self.isInAppLocationServiceRequestAlertVisible = NO;
        }]];
        [alert present];
        return;
    }
    
    if (completion) {
        completion(shuldAsk,NO);
    }
}

- (void)requestLocationSettingsChangeWithCompletion:(void(^)(BOOL canceled))completion {
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"ALERT_REQUEST_LOCATION_SETTINGS_CHANGE_TITLE", nil) message:NSLocalizedString(@"ALERT_REQUEST_LOCATION_SETTINGS_CHANGE_MESSAGE", nil) preferredStyle:UIAlertControllerStyleAlert];
    
    // go to settings
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"ALERT_REQUEST_LOCATION_SETTINGS_CHANGE_BUTTON", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        userShouldEnableLocationServiceOnDevice = YES;
        
        [UIApplication openURLWithString:UIApplicationOpenSettingsURLString];
        if (completion) {
            completion(NO);
        }
    }]];
    
    // cancel
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"ALERT_REQUEST_LOCATION_SETTINGS_CHANGE_CANCEL_BUTTON", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        if (completion) {
            completion(YES);
        }
    }]];
    [alert present];
}

- (void)requestLocationServiceEnableAlert:(void(^)(BOOL userDidAgree))completion {
    // alert
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:nil message:NSLocalizedString(@"ALERT_IN_APP_REQUEST_LOCATION_SERVICE_ENABLE_MESSAGE", nil) preferredStyle:UIAlertControllerStyleAlert];
    
    // allow action
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"ALERT_IN_APP_REQUEST_LOCATION_SERVICE_ENABLE_BUTTON", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (completion) {
            completion(YES);
        }
    }]];
    
    // cancel action
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"ALERT_IN_APP_REQUEST_LOCATION_SERVICE_ENABLE_CANCEL_BUTTON", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        if (completion) {
            completion(NO);
        }
    }]];
    [alert present];
}

#pragma mark Location Service access setters

- (void)setAllowLocationServiceUse:(BOOL)allow notify:(BOOL)shouldNotify {
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    if (allow != [defaults boolForKey:BSUInAppLocationServiceAllowedKey]) {
        [defaults setBool:allow forKey:BSUInAppLocationServiceAllowedKey];
        [self updateLocationUpdatingService];
        if (shouldNotify) {
            [[NSNotificationCenter defaultCenter] postNotificationName:BSULocationServiceDidChangeStatusNotification object:locationManager userInfo:nil];
        }
    }
}

- (void)tryToSetAllowLocationServiceUse:(BOOL)allow completion:(void(^)(BOOL settingsChangeRequired))completion {
    if (allow) {
        weakify(self);
        [self requestInAppLocationServiceAccessWithCompletion:^(BOOL userShouldBeAsked, BOOL userDidAgree) {
            strongify(self);
            
            // if did not show alert means the user did already see the alert eriler, if alert was displayed user must not click cancel to continue
            if (!userShouldBeAsked || userDidAgree) {
                // set value
                [self setAllowLocationServiceUse:YES notify:NO];
                
                // notify about other requirements
                if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined) {
                    [self.locationManager requestWhenInUseAuthorization];
                    if (completion) {
                        completion(NO);
                    }
                }
                else if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied) {
                    if (completion) {
                        completion(YES);
                    }
                }else{
                    if (completion) {
                        completion(NO);
                    }
                    [[NSNotificationCenter defaultCenter] postNotificationName:BSULocationServiceDidChangeStatusNotification object:locationManager userInfo:nil];
                }
            }else if (completion) {
                completion(NO);
            }
        }];
    }else{
        [self setAllowLocationServiceUse:NO notify:NO];
        if (completion) {
            completion(NO);
        }
        // notify observers
        [[NSNotificationCenter defaultCenter] postNotificationName:BSULocationServiceDidChangeStatusNotification object:locationManager userInfo:nil];
    }
}

#pragma mark - Location Updating

- (void)updateLocationUpdatingService {
    if ([self isLocationServiceUseAllowed]) {
        if (shouldStartUpdateingLocation) {
            [self beginUpdatingLocation];
        }
    }else{
        if (shouldStartUpdateingLocation) {
            [self endUpdatingLocation];
        }
    }
}

- (void)startUpdatingLocation {
    if (!shouldStartUpdateingLocation) {
        shouldStartUpdateingLocation = YES;
        [self beginUpdatingLocation];
    }
}

- (void)beginUpdatingLocation {
    if ([self isLocationServiceUseAllowed]) {
        [locationManager startUpdatingLocation];
    }
}

- (void)stopUpdatingLocation {
    if (shouldStartUpdateingLocation) {
        shouldStartUpdateingLocation = NO;
        [self endUpdatingLocation];
    }
}

- (void)endUpdatingLocation {
    [locationManager stopUpdatingLocation];
}

#pragma mark -

+ (NSNumber*)distanceFrom:(CLLocationCoordinate2D)coordinate toLocation:(CLLocation*) distantLocation {
    if (CLLocationCoordinate2DIsValid(coordinate)) {
        CLLocation* location = [[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
        return @([location distanceFromLocation:distantLocation]);
    }
    return nil;
}

+ (void)addNotificationsObserver:(id)observer didChangeUseAcceptanceSelector:(SEL)didChangeStatus didUpdateLocationSelector:(SEL)didUpdate {
    if (observer) {
        if (didChangeStatus) {
            [[NSNotificationCenter defaultCenter] addObserver:observer selector:didChangeStatus name:BSULocationServiceDidChangeStatusNotification object:nil];
        }
        if (didUpdate) {
            [[NSNotificationCenter defaultCenter] addObserver:observer selector:didUpdate name:BSULocationServiceDidUpdateLocationNotification object:nil];
        }
    }
}

#pragma mark - Notifications handlers

- (void)applicationWillEnterForegroundNotificationHandler:(NSNotification*)notification {
    // if user gone to device settings with intention of enabling the Location Service (-requestLocationSettingsChangeWithCompletion:)
    // and did return to the app but did not enable the service
    if (userShouldEnableLocationServiceOnDevice) {
        userShouldEnableLocationServiceOnDevice = NO;
        if ([CLLocationManager authorizationStatus] <= kCLAuthorizationStatusDenied) {
            [[NSNotificationCenter defaultCenter] postNotificationName:BSUUserDidNotEnableLocationServiceNotification object:locationManager userInfo:nil];
        }
    }
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    BOOL isRestricted = status == kCLAuthorizationStatusRestricted;
    if (isLocationServiceRestricted != isRestricted) {
        isLocationServiceRestricted = isRestricted;
    }
    [self updateLocationUpdatingService];
    [[NSNotificationCenter defaultCenter] postNotificationName:BSULocationServiceDidChangeStatusNotification object:locationManager userInfo:nil];
}

// TIP: Some custom location: 52.180297, 21.003616 (Warsaw)
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    CLLocation* location = locations.lastObject;
    
    if (lastLocation == nil || [location distanceFromLocation:lastLocation] > LOCATION_DELTA_CAUSING_UPDATE) {
        lastLocation = location;
#if defined(DEBUG) && defined(LOCATION)
        lastLocation = LOCATION;
#endif
        [[NSNotificationCenter defaultCenter] postNotificationName:BSULocationServiceDidUpdateLocationNotification object:locationManager userInfo:nil];
    }
}

@end

//
//  LocationServiceManager.h
//  
//
//  Created by Grzegorz Maciak on 21.12.2016.
//  Copyright © 2016 Grzegorz Maciak. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Singleton.h"
@import CoreLocation;

#define LOCATION_DELTA_CAUSING_UPDATE 10 //m

NS_ASSUME_NONNULL_BEGIN

@interface BSULocationServiceManager : NSObject <CLLocationManagerDelegate> {
    CLLocationManager* locationManager;
    CLLocation* lastLocation;
    BOOL isLocationServiceRestricted;
    BOOL locationServiceStatusNotDetermined;
    BOOL shouldStartUpdateingLocation;
}
SINGLETON_INTERFACE(LocationServiceManager)

@property(nonatomic,readonly,nullable) CLLocationManager* locationManager;
@property(nonatomic,readonly,nullable) CLLocation* lastLocation;
@property(nonatomic,readonly) BOOL locationServiceRestricted;

- (void)startUpdatingLocation;
- (void)stopUpdatingLocation;

- (BOOL)isInAppLocationServiceAllowed;
- (BOOL)isLocationServiceUseAllowed;
- (BOOL)isLocationAvailable;
- (BOOL)shouldSkipInAppLocationServiceAccessRequest;

- (void)firstLaunchRequestIfNeeded;
- (void)requestLocationServiceAuthorizationIfNeeded;
- (void)requestLocationSettingsChangeWithCompletion:(nullable void(^)(BOOL canceled))completion;
- (void)requestLocationServiceEnableAlert:(void(^)(BOOL userDidAgree))completion; // dislpayed on map button (nrearest stations button) if location is disabled locally
- (void)tryToSetAllowLocationServiceUse:(BOOL)allow completion:(nullable void(^)(BOOL settingsChangeRequired))completion;

+ (nullable NSNumber*)distanceFrom:(CLLocationCoordinate2D)coordinate toLocation:(CLLocation*)distantLocation;
+ (void)addNotificationsObserver:(id)observer didChangeUseAcceptanceSelector:(SEL)didChangeStatus didUpdateLocationSelector:(SEL)didUpdate;
//- (NSNumberFormatter*)distanceFormatter;
@end

FOUNDATION_EXPORT NSString* const BSULocationServiceDidChangeStatusNotification;
FOUNDATION_EXPORT NSString* const BSULocationServiceDidUpdateLocationNotification;
FOUNDATION_EXPORT NSString* const BSUUserDidNotEnableLocationServiceNotification;

// user defaults keys
FOUNDATION_EXPORT NSString* const BSUSkipInAppLocationServiceRequestAlertKey;
FOUNDATION_EXPORT NSString* const BSUInAppLocationServiceAllowedKey;

NS_ASSUME_NONNULL_END

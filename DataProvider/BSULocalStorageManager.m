//
//  BSULocalStorageManager.m
//  BESynchronizationUtils
//
//  Created by Grzegorz Maciak on 09.11.2016.
//  Copyright © 2016 Grzegorz Maciak. All rights reserved.
//

#import "BSULocalStorageManager.h"
#import "BSUWebServiceClient.h"
#import "BSULoadingWithJSON.h"
#import "BSULocationServiceManager.h"
#import "Constants.h"
#import "BSULocalStorageManager+ImageCache.h"
#import "BSUWebServiceModel.h"

NSString* const BSULocalStorageDidUpdateDataNotification = @"BSULocalStorageDidUpdateDataNotification";
NSString* const BSULocalStorageUpdateingDataFailedNotification = @"BSULocalStorageUpdateingDataFailedNotification";
NSString* const BSULocalStorageUpdatedTypeKey = @"BSULocalStorageUpdatedTypeKey";
NSString* const BSULocalStorageUpdatedErrorKey = @"BSULocalStorageUpdatedErrorKey";

@implementation BSULocalStorageManager

SINGLETON_IMPLEMENTATION(BSULocalStorageManager)

-(void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:BSUUserDidNotEnableLocationServiceNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
}

- (id)init {
    self = [super init];
    if (self){
        wsClient = [[BSUWebServiceClient alloc] init];
        imagesByClusterSize = [NSMutableDictionary dictionary];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidNotEnableLacationServiceNotificationHandler:) name:BSUUserDidNotEnableLocationServiceNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveMemoryWarning:) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
    }
    return self;
}

-(void)userDidNotEnableLacationServiceNotificationHandler:(NSNotification*)notification {

}

- (void)didReceiveMemoryWarning:(NSNotification*)notification {
    [imagesByClusterSize removeAllObjects];
}

+ (void)configureDataStorage {
    NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
    NSURL* cacheURL = [NSURL fileURLWithPath:cachePath];
    
    RLMRealmConfiguration *config = [RLMRealmConfiguration defaultConfiguration];
    config.deleteRealmIfMigrationNeeded = YES;
    
    // Use the default directory, but replace the filename with the username
    config.fileURL = [cacheURL URLByAppendingPathComponent:config.fileURL.lastPathComponent];
    NSLog(@"Realm PATH: %@",config.fileURL);
    
    // Set this as the configuration used for the default Realm
    [RLMRealmConfiguration setDefaultConfiguration:config];
}

#ifdef DEBUG
+ (void)resetAppData {
    RLMRealm* realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    [realm deleteAllObjects];
    [realm commitWriteTransaction];
    [self removeImageCache];
}
#endif

#pragma mark Data Access

- (BOOL)isUpdateNeeded:(Class)type {
    BSUCacheSettings* cacheSettings = [[[self class] cacheSettingsClass] objectForPrimaryKey:NSStringFromClass(type)];
    return cacheSettings == nil || cacheSettings.isExpired || ([type isKindOfClass:[RLMObject class]] && [type allObjects].count == 0);
}

- (BOOL)updateDataIfNeeded:(Class)type {
    BOOL needUpdate = [self isUpdateNeeded:type];
    if ( needUpdate ) {
        [self updateDataOfType:type success:^{
            [self notifyUpdateDone:type];
        } fail:^(BSUErrorStatus *error) {
            [self handleBSUErrorStatus:error ofUpdateOfType:type];
        }];
    }
    return needUpdate;
}

- (void)updateDataOfType:(Class)type success:(void (^)())success fail:(void (^)(BSUErrorStatus *error))fail {
    if ([type conformsToProtocol:@protocol(BSUWebServiceModel)]) {

        [wsClient startTaskWithServicePath:[type webServicePath] httpMethod:[type httpMethod] params:[type webServiceParams] success:^(NSArray *items, id rawValue, NSDate *updateDate, NSString *authToken) {
            
            if ([type conformsToProtocol:@protocol(BSULocalDataModel)]) {
                [type removeAssociatedImages];
            }
            
            if ([type conformsToProtocol:@protocol(BSULoadingWithJSON)]) {
                NSArray* objects = [type arrayWithJSON:items];
                
                BSUCacheSettings* cacheSettings = [self cacheSettingsToUpdate:type];
                RLMRealm* realm = [RLMRealm defaultRealm];
                [realm beginWriteTransaction];
                
                // cache settings update
                [self updateCacheSettings:cacheSettings withUpdateTS:updateDate realm:realm];
                
                // clean
                [realm deleteObjects:[type allObjects]];
                
                // additional clean
                if ([type conformsToProtocol:@protocol(BSULocalDataModel)]) {
                    [type removeAssociatedObjectsWithRealm:realm];
                }
                
                // add
                [realm addOrUpdateObjectsFromArray:objects];
                [realm commitWriteTransaction];
            }
            
            if (success) success();
            
        } fail:^(BSUErrorStatus *error) {
            if (fail) fail(error);
        }];
    }
    
}

- (void)notifyUpdateDone:(Class)type {
    [[NSNotificationCenter defaultCenter] postNotificationName:BSULocalStorageDidUpdateDataNotification object:self userInfo:@{BSULocalStorageUpdatedTypeKey: type}];
}

- (void)handleBSUErrorStatus:(BSUErrorStatus*)error ofUpdateOfType:(Class)type {
    if (error.code != BSUErrorStatusCodeTaskAlreadyRunning) {
        [[NSNotificationCenter defaultCenter] postNotificationName:BSULocalStorageUpdateingDataFailedNotification object:self userInfo:@{BSULocalStorageUpdatedTypeKey: type}];
    }
}

//- (void)getAboutInfo:(void (^)(NSString* value))success fail:(void (^)(BSUErrorStatus *error))fail {
//    [wsClient getAboutInfo:^(NSArray* items, id rawValue, NSDate* date) {
//        if (success) success(rawValue);
//    } fail:^(BSUErrorStatus *error) {
//        if (fail) fail(error);
//    }];
//}
//
//- (void)getRegulations:(void (^)(NSString* value))success fail:(void (^)(BSUErrorStatus *error))fail {
//    [wsClient getRegulations:^(NSArray* items, id rawValue, NSDate* date) {
//        if (success) success(rawValue);
//    } fail:^(BSUErrorStatus *error) {
//        if (fail) fail(error);
//    }];
//}

#pragma mark Cache Settings

+ (Class)cacheSettingsClass {
    return [BSUCacheSettings class];
}

- (BSUCacheSettings *)cacheSettingsToUpdate:(Class)type {
    NSString* key = NSStringFromClass(type);
    BSUCacheSettings *cacheSettings = [[[self class] cacheSettingsClass] objectForPrimaryKey:key];
    if (cacheSettings == nil) {
        cacheSettings = [[[self class] cacheSettingsClass] cacheSettingsForKey:key];
    }
    return cacheSettings;
}

- (void)updateCacheSettings:(BSUCacheSettings*)cacheSettings withUpdateTS:(NSDate*)updateTS realm:(RLMRealm*)realm {
    cacheSettings.lastUpdate = updateTS;
    if (cacheSettings.realm == nil) {
        [realm addObject:cacheSettings];
    }
}

@end

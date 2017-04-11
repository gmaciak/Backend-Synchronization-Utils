//
//  BSUDataProvider.m
//  BESynchronizationUtils
//
//  Created by Grzegorz Maciak on 09.11.2016.
//  Copyright © 2016 Grzegorz Maciak. All rights reserved.
//

#import "BSUDataProvider.h"
#import "BSUWebServiceClient.h"
#import "BSUDataProvider.h"
#import "BSUDataProvider+ImageCache.h"
#import "BSULocationServiceManager.h"

#import "BSUCacheSettings.h"

#import "BSULoadingWithJSON.h"
#import "BSUWebServiceModel.h"

NSString* const BSUDataProviderDidUpdateDataNotification = @"BSUDataProviderDidUpdateDataNotification";
NSString* const BSUDataProviderUpdateingDataFailedNotification = @"BSUDataProviderUpdateingDataFailedNotification";
NSString* const BSUDataProviderUpdatedTypeKey = @"BSUDataProviderUpdatedTypeKey";
NSString* const BSUDataProviderUpdatedErrorKey = @"BSUDataProviderUpdatedErrorKey";

@implementation BSUDataProvider

SINGLETON_IMPLEMENTATION(BSUDataProvider)

-(void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:BSUUserDidNotEnableLocationServiceNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
}

- (id)init {
    self = [super init];
    if (self){
        //self.wsClient = [[BSUWebServiceClient alloc] init];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidNotEnableLacationServiceNotificationHandler:) name:BSUUserDidNotEnableLocationServiceNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveMemoryWarning:) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
    }
    return self;
}

-(void)userDidNotEnableLacationServiceNotificationHandler:(NSNotification*)notification {

}

- (void)didReceiveMemoryWarning:(NSNotification*)notification {
    
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

+ (void)addNotificationsObserver:(id)observer didUpdateDataSelector:(nullable SEL)successSelector didFailUpdatingDataSelector:(nullable SEL)failSelector {
    if (observer) {
        if (successSelector) {
            [[NSNotificationCenter defaultCenter] addObserver:observer selector:successSelector name:BSUDataProviderDidUpdateDataNotification object:nil];
        }
        if (failSelector) {
            [[NSNotificationCenter defaultCenter] addObserver:observer selector:failSelector name:BSUDataProviderUpdateingDataFailedNotification object:nil];
        }
    }
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

- (BOOL)updateDataIfNeeded:(Class)type {
    BOOL needUpdate = [self isUpdateNeeded:type];
    if ( needUpdate ) {
        [self updateDataOfType:type success:^{
            [self notifyUpdateDone:type];
        } fail:^(BSUError *error) {
            [self handleBSUError:error ofUpdateOfType:type];
        }];
    }
    return needUpdate;
}

- (void)updateDataOfType:(Class)type success:(void (^)())success fail:(void (^)(BSUError *error))fail {
    if ([type conformsToProtocol:@protocol(BSUWebServiceModel)]) {
        [self updateDataOfType:type params:[type defaultWebServiceParams] success:success fail:fail];
    }else{
        if (fail) fail([BSUError errorWithCode:BSUErrorCodeClassDoNotImplementBSUWebServiceModel userInfo:nil]);
    }
}

- (void)updateDataOfType:(Class)type params:(NSDictionary *)params success:(void (^)())success fail:(void (^)(BSUError *error))fail {
    if ([type conformsToProtocol:@protocol(BSUWebServiceModel)]) {
        
        [self.wsClient startTaskWithServicePath:[type webServicePath] httpMethod:[type httpMethod] params:params success:^(NSArray *items, id jsonData, NSDate *updateDate, NSString *authToken) {
            
            [self handleResponseForType:type items:items jsonData:jsonData updateDate:updateDate authToken:authToken];
            if (success) success();
            
        } fail:^(BSUError *error) {
            if (fail) fail(error);
        }];
    }else{
        if (fail) fail([BSUError errorWithCode:BSUErrorCodeClassDoNotImplementBSUWebServiceModel userInfo:nil]);
    }
}

- (void)handleResponseForType:(Class)type items:(NSArray *)items jsonData:(id)jsonData updateDate:(NSDate *)updateDate authToken:(NSString *)authToken {
    
    if ([type conformsToProtocol:@protocol(BSULocalDataModel)]) {
        [type removeAssociatedImages];
    }
    
    if ([type conformsToProtocol:@protocol(BSULoadingWithJSON)]) {
        NSArray* objects = nil;
        if (items) {
            objects = [type arrayWithJSON:items];
        }
        else if ([jsonData isKindOfClass:[NSDictionary class]]) {
            id object = [[type alloc] initWithJSON:jsonData];
            if (object) {
                objects = @[object];
            }
        }
        
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
        if (objects.count > 0) {
            if ([type primaryKey]) {
                // inner collections may need update for repeated items
                [realm addOrUpdateObjectsFromArray:objects];
            }else {
                // items without primary key cannot be updated
                [realm addObjects:objects];
            }
        }
        [realm commitWriteTransaction];
    }
}

- (void)notifyUpdateDone:(Class)type {
    [[NSNotificationCenter defaultCenter] postNotificationName:BSUDataProviderDidUpdateDataNotification object:self userInfo:@{BSUDataProviderUpdatedTypeKey: type}];
}

- (void)handleBSUError:(BSUError*)error ofUpdateOfType:(Class)type {
    if (error.code != BSUErrorCodeTaskAlreadyRunning) {
        [[NSNotificationCenter defaultCenter] postNotificationName:BSUDataProviderUpdateingDataFailedNotification object:self userInfo:@{BSUDataProviderUpdatedTypeKey: type}];
    }
}

#pragma mark Cache Settings

+ (Class)cacheSettingsClass {
    return [BSUCacheSettings class];
}

- (BOOL)isUpdateNeededForCacheKey:(NSString *)key {
    BSUCacheSettings* cacheSettings = [BSUCacheSettings objectForPrimaryKey:key];
    return cacheSettings == nil || cacheSettings.isExpired;
}

- (BOOL)isUpdateNeeded:(Class)type {
    return [self isUpdateNeededForCacheKey:NSStringFromClass(type)] || ([type isKindOfClass:[RLMObject class]] && [type allObjects].count == 0);
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

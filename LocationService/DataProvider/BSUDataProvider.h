//
//  BSUDataProvider.h
//  BESynchronizationUtils
//
//  Created by Grzegorz Maciak on 09.11.2016.
//  Copyright © 2016 Grzegorz Maciak. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Realm/Realm.h>
#import "Singleton.h"
#import "BSUConstants.h"
#import "BSULocalDataModel.h"
#import "BSUError.h"
#import "BSUWebServiceModel.h"

@class BSUWebServiceClient, BSUCacheSettings;

@interface BSUDataProvider : NSObject
SINGLETON_INTERFACE(BSUDataProvider)

@property(nonatomic,strong) BSUWebServiceClient* wsClient;;

+ (void)configureDataStorage;

#pragma mark API
- (BOOL)isUpdateNeededForCacheKey:(NSString *)key;

/**
 @name Generic methods to support download objects or collections (lists) of data objects
 */

- (BOOL)isUpdateNeeded:(Class<BSUWebServiceModel>)type;

/** Generic methods to download objects or collections (lists) of data objects
 Returns YES if update needed, then there is a need to listen for the notifications:
 * - VMLocalDataStorageDidUpdateDataNotification
 * - VMLocalDataStorageUpdateingDataFailedNotification
 
 @returns YES if update needed, otherwise NO.
 */
- (BOOL)updateDataIfNeeded:(Class<BSUWebServiceModel>)type;
- (void)updateDataOfType:(Class<BSUWebServiceModel>)type success:(BSUSuccessBlock)success fail:(void (^)(BSUError *error))fail;

/*
 * Not recommanded, `params` keys should be known by WSClient only,
 * but you can uncomment following line if you realy need
 */
//- (void)updateDataOfType:(Class<BSUWebServiceModel>)type params:(NSDictionary *)params success:(BSUSuccessBlock)success fail:(void (^)(WSError *error))fail;

+ (void)addNotificationsObserver:(id)observer didUpdateDataSelector:(SEL)successSelector didFailUpdatingDataSelector:(SEL)failSelector;

#ifdef DEBUG
+ (void)resetAppData;
#endif

@end



@interface BSUDataProvider (Private)
- (void)notifyUpdateDone:(Class)type;
- (void)handleBSUError:(BSUError*)error ofUpdateOfType:(Class)type;

- (BSUCacheSettings*)cacheSettingsToUpdateWithKey:(NSString *)key;
- (void)updateCacheSettings:(BSUCacheSettings*)cacheSettings withUpdateTS:(NSDate*)updateTS realm:(RLMRealm*)realm;

- (void)handleResponseForType:(Class)type items:(NSArray *)items jsonData:(id)jsonData updateDate:(NSDate *)updateDate authToken:(NSString *)authToken;

@end



@protocol BSUDataProviderExtension <NSObject>

- (void)handleResponseForType:(Class<BSUWebServiceModel>)type items:(NSArray *)items jsonData:(id)jsonData updateDate:(NSDate *)updateDate;

@end


FOUNDATION_EXPORT NSString* const BSUDataProviderDidUpdateDataNotification;
FOUNDATION_EXPORT NSString* const BSUDataProviderUpdateingDataFailedNotification;
FOUNDATION_EXPORT NSString* const BSUDataProviderUpdatedTypeKey;
FOUNDATION_EXPORT NSString* const BSUDataProviderUpdatedErrorKey;

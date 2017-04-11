//
//  BSUCacheSettings.h
//  BESynchronizationUtils
//
//  Created by Grzegorz Maciak on 09.11.2016.
//  Copyright © 2016 Grzegorz Maciak. All rights reserved.
//

#import <Realm/Realm.h>
#import "BSULocalDataObject.h"

NS_ASSUME_NONNULL_BEGIN

@interface BSUCacheSettings : RLMObject <NSCopying>

@property(assign,nonatomic) NSString *key;
@property(strong,nonatomic) NSDate *lastUpdate;
@property(nonatomic,strong) NSString *language;
@property(nonatomic,strong) NSString *mobileInfo;

+ (instancetype)cacheSettingsForKey:(NSString *)sourceTypeName;
- (BOOL)isExpired;

+ (NSString*)currentMobileInfo;

@end

NS_ASSUME_NONNULL_END

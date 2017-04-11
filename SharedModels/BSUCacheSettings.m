//
//  BSUCacheSettings.m
//  BESynchronizationUtils
//
//  Created by Grzegorz Maciak on 09.11.2016.
//  Copyright © 2016 Grzegorz Maciak. All rights reserved.
//

#import "BSUCacheSettings.h"
#import "Constants.h"

//NSTimeInterval const PERIOD_OF_VALIDITY = 86400; // one day 24*3600

@implementation BSUCacheSettings

+ (id)cacheSettingsForKey:(NSString *)key {
    BSUCacheSettings* settings = [[BSUCacheSettings alloc] init];
    settings.key = key;
    settings.language = [[[NSLocale autoupdatingCurrentLocale].localeIdentifier componentsSeparatedByString:@"_"] firstObject];
    settings.mobileInfo = [self currentMobileInfo];
    return settings;
}

- (BOOL)isExpired {
    if (![self.language isEqualToString:[[[NSLocale autoupdatingCurrentLocale].localeIdentifier componentsSeparatedByString:@"_"] firstObject]]) {
        return YES;
    }
    NSNumber* validityPeriod = [NSBundle mainBundle].infoDictionary[INFO_DICTIONARY_KEY_SETTINGS][@"CACHE"][@"PERIOD_OF_VALIDITY"][self.key] ?: @(1.0);
    return self.lastUpdate.timeIntervalSinceNow < -[validityPeriod doubleValue];
}

+ (NSString *)primaryKey {
    return @"key";
}

+ (NSDictionary *)defaultPropertyValues {
    return @{@"lastUpdate" : [NSDate distantFuture]};
}

#pragma mark NSCopying

- (id)copyWithZone:(nullable NSZone *)zone {
    BSUCacheSettings* copy = [RLM_SELF_CLASS new];
    copy.key = self.key;
    copy.language = self.language;
    copy.lastUpdate = self.lastUpdate;
    return copy;
}

+ (NSString*)currentMobileInfo {
    
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *appVersion = infoDictionary[@"CFBundleShortVersionString"];
    NSString *appId = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    NSString *buildVersion = infoDictionary[(NSString*)kCFBundleVersionKey];
    NSString *osVersion = [[UIDevice currentDevice] systemVersion];
    NSString *deviceName = [[UIDevice currentDevice] model];
    
    NSString *mobileInfo = [NSString stringWithFormat:@"%@;%@;%@;iOS;%@;%@;Apple", appId, appVersion, buildVersion, osVersion, deviceName];
    
    return mobileInfo;
}

@end

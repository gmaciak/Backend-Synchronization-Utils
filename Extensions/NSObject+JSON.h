//
//  NSObject+JSON.h
//  
//
//  Created by Grzegorz Maciak on 23.02.2017.
//  Copyright © 2017 Grzegorz Maciak. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol LoadingWithJSON <NSObject>
-(instancetype)initWithJSON:(NSDictionary*)json;
@end


@interface NSObject (JSON)

+(instancetype)instanceWithJSON:(NSDictionary *)json;
+(NSMutableArray *)arrayOfInstancesWithJSON:(NSArray *)json;

-(void)fromDictionaryByProperties:(NSDictionary *)dictionary;
-(void)fromDictionaryByProperties:(NSDictionary *)dictionary downToClass:(nullable Class)firstExcludedClass ignoreNotIncludedProperties:(BOOL)ignore;
-(void)fromDictionary:(NSDictionary *)dictionary keyMap:(nullable NSDictionary<NSString *, NSString *> *)propertiesByKeys;
-(void)fromDictionary:(NSDictionary*)dictionary keyMap:(nullable NSDictionary<NSString *, NSString *> *)propertiesByKeys ignoreKeys:(nullable NSArray*)ignoredKeys;

-(NSMutableDictionary *)toDictionary;
-(NSMutableDictionary *)toDictionaryIgnoringNilValues:(BOOL)ignoreNil;
-(NSMutableDictionary *)toDictionaryIgnoringNilValues:(BOOL)ignoreNil downToClass:(nullable Class)firstExcludedClass;
-(NSMutableDictionary *)toDictionaryIgnoringNilValues:(BOOL)ignoreNil downToClass:(nullable Class)firstExcludedClass ignorePropertiesWithNames:(nullable NSArray *)ignoredProperties;

+(NSMutableArray *) getPropertiesNamesOf:(Class)class includingInheritedProperties:(BOOL)includeInherited downToFirstSubclassOf:(nullable Class)excludedClass;
+(NSMutableArray *) getPropertiesNamesIncludingInheritedPropertiesDownToClass:(nullable Class)firstExcludedClass;
+(NSMutableArray *) getPropertiesNamesIncludingInheritedProperties:(BOOL)includeInherited;
+(NSMutableArray *) getPropertiesNames;
-(NSMutableArray *) propertiesNames;

@end

NS_ASSUME_NONNULL_END

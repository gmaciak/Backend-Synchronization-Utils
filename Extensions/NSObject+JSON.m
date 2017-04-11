//
//  NSObject+JSON.m
//  
//
//  Created by Grzegorz Maciak on 23.02.2017.
//  Copyright © 2017 Grzegorz Maciak. All rights reserved.
//

#import "NSObject+JSON.h"
#import <objc/runtime.h>

@implementation NSObject (JSON)

+(instancetype)instanceWithJSON:(NSDictionary *)json {
    id instance = nil;
    if ([self conformsToProtocol:@protocol(LoadingWithJSON)]) {
        instance = [(id<LoadingWithJSON>)[[self class] alloc] initWithJSON:json];
    }else{
        instance = [[[self class] alloc] init];
        [instance fromDictionaryByProperties:json];
    }
    return instance;
}

+(NSMutableArray *)arrayOfInstancesWithJSON:(NSArray*)json {
    NSMutableArray * array = [NSMutableArray arrayWithCapacity:json.count];
    if ([json.firstObject isKindOfClass:[NSDictionary class]]) {
        for (NSDictionary* jsonObj in json) {
            [array addObject:[(id<LoadingWithJSON>)[self alloc] initWithJSON:jsonObj]];
        }
    }
    return array;
}

-(void)fromDictionaryByProperties:(NSDictionary*)dictionary {
    [self fromDictionaryByProperties:dictionary downToClass:Nil ignoreNotIncludedProperties:YES];
}

// if ignoreNotIncludedProperties is NO and dictionary does not contain the key such as property name, property will be set to nil, otherwise it remains unchanged
-(void)fromDictionaryByProperties:(NSDictionary*)dictionary downToClass:(Class)firstExcludedClass ignoreNotIncludedProperties:(BOOL)ignore {
    
    if (dictionary) {
        NSMutableArray* propertiesNames = [[self class]getPropertiesNamesIncludingInheritedPropertiesDownToClass:firstExcludedClass];
        
        id dbValue;
        for(NSString* propertyName in propertiesNames){
            dbValue = [dictionary objectForKey:propertyName];
            if (dbValue || !ignore) {
                [self setValue:dbValue forKey:propertyName];
            }
        }
    }
}

-(void)fromDictionary:(NSDictionary*)dictionary keyMap:(nullable NSDictionary<NSString *, NSString *> *)propertiesByKeys {
    [self fromDictionary:dictionary keyMap:propertiesByKeys ignoreKeys:nil];
}

-(void)fromDictionary:(NSDictionary*)dictionary keyMap:(nullable NSDictionary<NSString *, NSString *> *)propertiesByKeys ignoreKeys:(NSArray*)ignoredKeys {
    if (dictionary) {
        id dbValue;
        for(NSString* key in dictionary){
            if (key.length > 0 && ![ignoredKeys containsObject:key]) {
                NSString* propertyName = propertiesByKeys[key] ?: key.capitalizedString;
                
                //DLog(@"pascalCaseKey: %@ selector: %@",pascalCaseKey, [NSString stringWithFormat:@"set%@:",pascalCaseKey])
                if ([self respondsToSelector:NSSelectorFromString([NSString stringWithFormat:@"set%@:",propertyName])]) {
                    dbValue = [dictionary objectForKey:key];
                    [self setValue:dbValue forKey:key];
                }
            }
        }
    }
}

-(NSMutableDictionary*)toDictionary {
    return [self toDictionaryIgnoringNilValues:YES];
}

-(NSMutableDictionary*)toDictionaryIgnoringNilValues:(BOOL)ignoreNil {
    return [self toDictionaryIgnoringNilValues:ignoreNil downToClass:Nil];
}

-(NSMutableDictionary*)toDictionaryIgnoringNilValues:(BOOL)ignoreNil downToClass:(Class)firstExcludedClass {
    return [self toDictionaryIgnoringNilValues:ignoreNil downToClass:firstExcludedClass ignorePropertiesWithNames:nil];
}

-(NSMutableDictionary*)toDictionaryIgnoringNilValues:(BOOL)ignoreNil downToClass:(Class)firstExcludedClass ignorePropertiesWithNames:(NSArray*)ignoredProperties {
    
    NSMutableArray* propertiesNames = [[self class]getPropertiesNamesIncludingInheritedPropertiesDownToClass:firstExcludedClass];
    //DLogIF(DS_CATEGORY_SHOULD_DISPLAY_LOGS,@"propertiesNames %@",propertiesNames)
    NSMutableDictionary* dictionary = [NSMutableDictionary dictionaryWithCapacity:propertiesNames.count];
    id dsValue;
    for(NSString* propertyName in propertiesNames){
        dsValue = [self valueForKey:propertyName];
        if (ignoredProperties==nil || [ignoredProperties isEqual:[NSNull null]] || ![ignoredProperties containsObject:propertyName]) {
            if (dsValue == nil && !ignoreNil) {
                dsValue = [NSNull null];
            }
            //DLogIF(DS_CATEGORY_SHOULD_DISPLAY_LOGS,@"propertyName: %@ value: %@",propertyName,dsValue)
            if (dsValue) {
                [dictionary setObject:dsValue forKey:propertyName];
            }
        }
    }
    return dictionary;
}

#pragma mark - Properties

+(NSMutableArray*) getPropertiesNamesOf:(Class)class includingInheritedProperties:(BOOL)includeInherited downToFirstSubclassOf:(Class)excludedClass {
    
    if (class == excludedClass) return [NSMutableArray array];
    
    unsigned int outCount, i;
    if (!excludedClass) excludedClass = [NSObject class];
    
    objc_property_t* properties = class_copyPropertyList(class, &outCount);
    
    NSMutableArray* propertiesArray = [NSMutableArray arrayWithCapacity:outCount];
    
    for(i = 0; i < outCount; i++) {
        objc_property_t property = properties[i];
        const char* propName = property_getName(property);
        if(propName) {
            NSString* propertyName = [NSString stringWithUTF8String:propName];
            [propertiesArray addObject: propertyName];
            NSLog(@"Property name: %@",propertyName);
        }
    }
    free(properties);
    
    if (includeInherited && [class superclass] != excludedClass) {
        [propertiesArray addObjectsFromArray: [self getPropertiesNamesOf:[class superclass] includingInheritedProperties:includeInherited downToFirstSubclassOf:excludedClass] ];
    }
    [propertiesArray removeObjectsInArray:@[@"hash",@"debugDescription",@"description",@"superclass"]];
    return propertiesArray;
}

+(NSMutableArray*) getPropertiesNamesIncludingInheritedPropertiesDownToClass:(Class)firstExcludedClass {
    return [NSObject getPropertiesNamesOf:self includingInheritedProperties:YES downToFirstSubclassOf:firstExcludedClass];
}

+(NSMutableArray*) getPropertiesNamesIncludingInheritedProperties:(BOOL)includeInherited {
    return [NSObject getPropertiesNamesOf:self includingInheritedProperties:includeInherited downToFirstSubclassOf:nil];
}

-(NSMutableArray*) propertiesNames {
    return [[self class] getPropertiesNamesIncludingInheritedProperties:YES];
}

+(NSMutableArray*) getPropertiesNames {
    return [self getPropertiesNamesIncludingInheritedProperties:YES];
}

@end

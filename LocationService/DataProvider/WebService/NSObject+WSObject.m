//
//  NSObject+WSObject.m
//  BESynchronizationUtils
//
//  Created by Grzegorz Maciak on 09.11.2016.
//  Copyright © 2016 Grzegorz Maciak. All rights reserved.
//

#import "NSObject+WSObject.h"
#import "BSULoadingWithJSON.h"

@implementation NSObject (WSObject)

+(id)arrayWithJSON:(NSArray*)json {   
    return [self arrayOfInstancesWithJSON:json];
}

@end

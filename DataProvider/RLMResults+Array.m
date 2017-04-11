//
//  RLMResults+Array.m
//  BESynchronizationUtils
//
//  Created by Grzegorz Maciak on 18.11.2016.
//  Copyright © 2016 Grzegorz Maciak. All rights reserved.
//

#import "RLMResults+Array.h"

@implementation RLMResults (Array)

- (NSArray*)copyOfAllObjects {
    NSMutableArray* copiedObjects = [NSMutableArray arrayWithCapacity:self.count];
    for (id obj in self) {
        if ([[obj class] conformsToProtocol:@protocol(NSCopying)]) {
            [copiedObjects addObject:[obj copy]];
        }
    }
    return copiedObjects;
}

- (NSArray*)arrayOfObjects {
    NSMutableArray* allObjects = [NSMutableArray arrayWithCapacity:self.count];
    for (id obj in self) {
        [allObjects addObject:obj];
    }
    return allObjects;
}

- (NSArray*)arrayOfObjectsToIndex:(NSUInteger)index {
    NSMutableArray* result = [NSMutableArray arrayWithCapacity:self.count];
    for (NSUInteger i = 0; i < MIN(index, self.count); ++i) {
        [result addObject:self[i]];
    }
    return result;
}

@end

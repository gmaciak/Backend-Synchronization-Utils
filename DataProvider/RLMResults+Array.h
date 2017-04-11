//
//  RLMResults+Array.h
//  BESynchronizationUtils
//
//  Created by Grzegorz Maciak on 18.11.2016.
//  Copyright © 2016 Grzegorz Maciak. All rights reserved.
//

#import <Realm/Realm.h>

@interface RLMResults (Array)
- (NSArray*)copyOfAllObjects; // returns an array of unmanaged copies of objects
- (NSArray*)arrayOfObjects;
- (NSArray*)arrayOfObjectsToIndex:(NSUInteger)index;
@end

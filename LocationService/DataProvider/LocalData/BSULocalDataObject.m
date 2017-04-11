//
//  BSULocalDataModel.m
//  BESynchronizationUtils
//
//  Created by Grzegorz Maciak on 24.02.2017.
//  Copyright © 2017 Grzegorz Maciak. All rights reserved.
//

#import "BSULocalDataObject.h"

@implementation BSULocalDataObject

-(id)initWithJSON:(NSDictionary*)json {
    self = [super init];
    if (self) {
    }
    return self;
}

+ (void)removeAssociatedObjectsWithRealm:(RLMRealm *)realm { }

+ (void)removeAssociatedImages { }

@end

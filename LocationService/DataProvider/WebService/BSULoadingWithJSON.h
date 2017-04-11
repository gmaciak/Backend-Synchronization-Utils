//
//  BSULoadingWithJSON.h
//  BESynchronizationUtils
//
//  Created by Grzegorz Maciak on 08.11.2016.
//  Copyright © 2016 Grzegorz Maciak. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSObject+JSON.h"

@protocol BSULoadingWithJSON <NSObject>

- (instancetype)initWithJSON:(NSDictionary *)json;

@optional
+ (NSMutableArray *)arrayWithJSON:(NSArray *)json;
    
@end

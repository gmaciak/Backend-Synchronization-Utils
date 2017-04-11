//
//  BSULocalDataModel.h
//  SetPoint
//
//  Created by Grzegorz Maciak on 15.03.2017.
//  Copyright © 2017 Grzegorz Maciak. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RLMRealm;

@protocol BSULocalDataModel <NSObject>
+ (void)removeAssociatedImages;
+ (void)removeAssociatedObjectsWithRealm:(RLMRealm *)realm;
@end

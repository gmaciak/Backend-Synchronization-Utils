//
//  BSUWebServiceModel.h
//  BESynchronizationUtils
//
//  Created by Grzegorz Maciak on 24.02.2017.
//  Copyright © 2017 Grzegorz Maciak. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BSUWebServiceClient.h"

@protocol BSUWebServiceModel <NSObject>
+ (NSString *)httpMethod;
+ (NSString *)webServicePath;
+ (NSDictionary *)webServiceParams;
@end

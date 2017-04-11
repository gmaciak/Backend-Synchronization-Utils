//
//  BSUErrorStatus.h
//  BESynchronizationUtils
//
//  Created by Grzegorz Maciak on 08.11.2016.
//  Copyright © 2016 Grzegorz Maciak. All rights reserved.
//

#import <Foundation/Foundation.h>

FOUNDATION_EXPORT NSString* const kBSUErrorDomain;

typedef NS_ENUM(NSInteger, BSUErrorStatusCode) {
    BSUErrorStatusCodeTaskAlreadyRunning = 10100
};

@interface BSUErrorStatus : NSError

@property NSInteger httpStatusCode;
@property(nonatomic,strong) NSString *apiKey;
@property(nonatomic,strong) NSString *status;

- (NSString *)message;
- (NSError *)originalError;

+ (id)errorWith:(NSError*)error;
+ (id)errorWithCode:(NSInteger)code userInfo:(NSDictionary*)userInfo;

@end

//
//  ErrorStatus.m
//  BESynchronizationUtils
//
//  Created by Grzegorz Maciak on 08.11.2016.
//  Copyright © 2016 Grzegorz Maciak. All rights reserved.
//

#import "BSUError.h"

NSString* const kBSUAPIErrorDomain = @"BSUAPIErrorDomain";
NSString* const kBSUApplicationErrorDomain = @"BSUApplicationErrorDomain";

@implementation BSUError

+ (id)errorWith:(NSError*)error {
    return [[self alloc] initWith:error];
}

+ (id)errorWithCode:(NSInteger)code userInfo:(NSDictionary*)userInfo {
    return [[self alloc] initWithCode:code userInfo:userInfo];
}

- (id)initWith:(NSError*)error {
    NSMutableDictionary *mutableUserInfo = error.userInfo ? [error.userInfo mutableCopy] : [NSMutableDictionary dictionary];
    self = [super initWithDomain:kBSUAPIErrorDomain code:error.code userInfo:mutableUserInfo];
    if (self) {
        _status = [NSString stringWithFormat:@"%@", [@(error.code) stringValue]];
        NSString* message = nil;
        switch (error.code) {
            default:
                message = @"";
                break;
        }
        mutableUserInfo[NSUnderlyingErrorKey] = error;
        mutableUserInfo[NSLocalizedDescriptionKey] = message ?: @"";
    }
    return self;
}

- (id)initWithCode:(NSInteger)code userInfo:(NSDictionary*)userInfo {
    NSMutableDictionary *mutableUserInfo = userInfo ? [userInfo mutableCopy] : [NSMutableDictionary dictionary];
    NSString *message = nil;
    NSString *domain = kBSUAPIErrorDomain;
    switch (code) {
        case BSUErrorCodeTaskAlreadyRunning:
            message = @"Task already running";
            
        case BSUErrorCodeClassDoNotImplementBSUWebServiceModel:
            message = @"Class does not implement BSUWebServiceModel protocol.";
            domain = kBSUApplicationErrorDomain;
        default:
            message = @"";
            break;
    }
    mutableUserInfo[NSLocalizedDescriptionKey] = message ?: @"";
    
    self = [super initWithDomain:domain code:code userInfo:mutableUserInfo];
    if (self) {
        _status = [NSString stringWithFormat:@"%@", [@(code) stringValue]];
    }
    return self;
}

- (NSError *)originalError {
    return self.userInfo[NSUnderlyingErrorKey];
}

- (NSString *)message {
    return self.userInfo[NSLocalizedDescriptionKey];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ Code=%@ \"%@\" UserInfo=%@", [super description], _status, self.message, self.userInfo];
}

@end

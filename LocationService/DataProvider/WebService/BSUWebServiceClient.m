//
//  BSUWebServiceClient.m
//  BESynchronizationUtils
//
//  Created by Grzegorz Maciak on 08.11.2016.
//  Copyright © 2016 Grzegorz Maciak. All rights reserved.
//

#import "BSUWebServiceClient.h"
#import "AFNetworking.h"
#import "BSUDataProvider.h"
#import "Constants.h"
#import <AFNetworking/AFImageDownloader.h>
#import <AFNetworking/UIImageView+AFNetworking.h>
#import <AFNetworking/UIButton+AFNetworking.h>
#import "BSUCacheSettings.h"

@implementation BSUWebServiceClient
SINGLETON_IMPLEMENTATION(BSUWebServiceClient)

- (id)init {
    self = [super init];
    if (self){
        manager = [[AFHTTPSessionManager alloc] init];
        /*
        [(AFJSONResponseSerializer*)manager.responseSerializer setRemovesKeysWithNullValues:YES];
#ifdef DEBUG
        manager.securityPolicy.allowInvalidCertificates = YES;
        manager.securityPolicy.validatesDomainName = NO;
        [UIImageView sharedImageDownloader].sessionManager.securityPolicy.allowInvalidCertificates = YES;
        [UIImageView sharedImageDownloader].sessionManager.securityPolicy.validatesDomainName = NO;
        [UIButton sharedImageDownloader].sessionManager.securityPolicy.allowInvalidCertificates = YES;
        [UIButton sharedImageDownloader].sessionManager.securityPolicy.validatesDomainName = NO;
#endif
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
         */
    }
    return self;
}

#pragma mark - 

- (void)cancelTasksWithURL:(NSString*)urlString {
    for (NSURLSessionTask* task in [manager.tasks copy]) {
        if ([task.originalRequest.URL.absoluteString isEqualToString:urlString]) {
            [task cancel];
        }
    }
}

- (NSURLSessionTask *)runningTaskForURL:(NSString*)urlString {
    for (NSURLSessionTask* task in [manager.tasks copy]) {
        if ([task.originalRequest.URL.absoluteString isEqualToString:urlString] && task.state == NSURLSessionTaskStateRunning) {
            return task;
        }
    }
    return nil;
}

- (BOOL)isTaskForURLAlreadyStarted:(NSString*)urlString {
    return [self runningTaskForURL:urlString] != nil;
}

- (void)startTaskWithServicePath:(NSString*)path httpMethod:(NSString *)method params:(NSDictionary*)params success:(BSUWebServiceClientSuccessBlock)success fail:(BSUWebServiceClientFailBlock)fail {
    
    NSString* urlString = [_apiUrl stringByAppendingPathComponent:path];
    NSError *error;
    NSMutableURLRequest *request = [manager.requestSerializer requestWithMethod:method URLString:urlString parameters:params error:&error];
    
    if (error && fail) {
        fail([BSUError errorWith:error]);
    }

    NSURLSessionTask *task = [self runningTaskForURL:urlString];
    if (!task || params) {
        // cancel previous tasks if any is running
        if (task) [task cancel];
        
        weakify(self);
        NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
            strongify(self);
            if (error) {
                NSLog(@"[Line %4d] %s %@",__LINE__,__PRETTY_FUNCTION__,error);
                
                if (fail) fail([BSUError errorWith:error]);
            } else {
                NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)responseObject;
                //NSLog(@"[Line %4d] %s Responce hearders: %@",__LINE__,__PRETTY_FUNCTION__,[httpResponse allHeaderFields]);
                
                // data
                id jsonData = responseObject[@"Response"];
                
                // valid json data is an array
                NSArray* items = nil;
                if ([jsonData isKindOfClass:[NSArray class]]) {
                    items = jsonData;
                }
                
                // update date
                NSDate* serverDate = [[self class] serverDateWithHTTPHeaders:httpResponse.allHeaderFields];
                NSString *authToken = httpResponse.allHeaderFields[@"Auth-Token"];
                
                if (success) success(items, jsonData, serverDate, authToken);
            }
        }];
        [dataTask resume];

    }else if (fail) {
//        fail([BSUError errorWithCode:BSUErrorCodeTaskAlreadyRunning userInfo:@{NSURLErrorFailingURLStringErrorKey: urlString}]);
    }
}

+ (NSDate*)serverDateWithHTTPHeaders:(NSDictionary*)allHeaders {
    NSDateFormatter* formater = [[NSDateFormatter alloc] init];
    formater.dateFormat = @"E, dd MMM yyyy HH:mm:ss zzz";
    return [formater dateFromString:allHeaders[@"Date"]] ?: [NSDate date];
}

@end

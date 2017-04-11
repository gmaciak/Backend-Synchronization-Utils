//
//  BSUWebServiceClient.h
//  BESynchronizationUtils
//
//  Created by Grzegorz Maciak on 08.11.2016.
//  Copyright © 2016 Grzegorz Maciak. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BSUError.h"
#import "Singleton.h"

//#define LOG_REQUEST_HEADERS

typedef void(^BSUWebServiceClientSuccessBlock)(NSArray* items, id rawValue, NSDate* updateDate, NSString *authToken);
typedef void(^BSUWebServiceClientFailBlock)(BSUError *error);

@class AFHTTPSessionManager;

@interface BSUWebServiceClient : NSObject {
    AFHTTPSessionManager* manager;
}
SINGLETON_INTERFACE(BSUWebServiceClient)

@property(nonatomic,strong) NSString *apiUrl;

+ (NSDate*)serverDateWithHTTPHeaders:(NSDictionary*)allHeaders;
- (void)startTaskWithServicePath:(NSString*)path httpMethod:(NSString *)method params:(NSDictionary*)params success:(BSUWebServiceClientSuccessBlock)success fail:(BSUWebServiceClientFailBlock)fail;

@end

@interface BSUWebServiceClient (Private)

- (NSURLSessionTask *)runningTaskForURL:(NSString*)urlString;
- (BOOL)isTaskForURLAlreadyStarted:(NSString*)urlString;
- (void)cancelTasksWithURL:(NSString*)urlString;

@end



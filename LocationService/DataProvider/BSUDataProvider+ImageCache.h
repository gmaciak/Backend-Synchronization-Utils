//
//  BSUDataProvider+ImageCache.h
//  BESynchronizationUtils
//
//  Created by Grzegorz Maciak on 23.02.2017.
//  Copyright © 2017 Grzegorz Maciak. All rights reserved.
//

#import "BSUDataProvider.h"

@interface BSUDataProvider (ImageCache)

+ (NSString*)imageFilePathWithKey:(NSString*)key;
+ (UIImage*)imageForKey:(NSString*)key;
+ (void)saveImage:(UIImage *)image forKey:(NSString*)key;
+ (void)saveImage:(UIImage *)image forKey:(NSString*)key asPNG:(BOOL)saveAsPNG;

+ (UIImage*)imageForURL:(NSURL*)url;
+ (void)saveImage:(UIImage*)image forURL:(NSURL*)url;
+ (void)removeImageForURL:(NSURL*)url;
+ (void)loadInBackgroundImageForURL:(NSURL*)url completion:(void(^)(UIImage* image))completion;

+ (void)removeImageCache;

@end

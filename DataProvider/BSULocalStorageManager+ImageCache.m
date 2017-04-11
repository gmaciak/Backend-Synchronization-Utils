//
//  BSULocalStorageManager+ImageCache.m
//  BESynchronizationUtils
//
//  Created by Grzegorz Maciak on 23.02.2017.
//  Copyright © 2017 Grzegorz Maciak. All rights reserved.
//

#import "BSULocalStorageManager+ImageCache.h"
#import "Constants.h"

@implementation BSULocalStorageManager (ImageCache)

- (UIImage*)pinImageWithCount:(NSInteger)count {
    CGFloat diameter = count == -1 ? 5 : 20;
    if (count >= 10){
        do {
            count = count/10;
            diameter += 4;
        } while(count >= 10);
    }
    NSNumber* key = @(diameter);
    UIImage* image = imagesByClusterSize[key];
    if (image == nil) {
        image = [UIImage placeholderImageWithTitle:nil size:CGSizeMake(diameter, diameter) backgroundColor: [UIColor colorWithRed:216.0f / 255.0f green:30.0f / 255.0f blue:4.0f / 255.0f alpha:1.0f] cornerRadius:diameter*0.5 borderWidth:0];
    }
    return image;
}

+ (NSString*)imageCacheDirPath {
    NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
    return [cachePath stringByAppendingPathComponent:@"Images"];
}


+ (NSString*)imageFilePathWithKey:(NSString*)key {
    NSString* dirPath = [self imageCacheDirPath];
    return [dirPath stringByAppendingPathComponent:key];
}


+ (UIImage*)imageForKey:(NSString*)key {
    NSString* fileName = [self imageFilePathWithKey:key];
    NSFileManager* fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:fileName]) {
        return [UIImage imageWithContentsOfFile:fileName];
    }
    return nil;
}

+ (void)saveImage:(UIImage *)image forKey:(NSString*)key {
    [self saveImage:image forKey:key asPNG:NO];
}

+ (void)saveImage:(UIImage *)image forKey:(NSString*)key asPNG:(BOOL)saveAsPNG {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString* dirPath = [self imageCacheDirPath];
        NSError* error = nil;
        NSFileManager* fileManager = [NSFileManager defaultManager];
        if (![fileManager fileExistsAtPath:dirPath]) {
            [fileManager createDirectoryAtPath:dirPath withIntermediateDirectories:NO attributes:nil error:&error];
        }
        if (!error) {
            NSString* filePath = [self imageFilePathWithKey:key];
            if ([fileManager fileExistsAtPath:filePath]) {
                [fileManager removeItemAtPath:filePath error:&error];
            }
            if (!error && image) {
                NSData* imageData = saveAsPNG ? UIImagePNGRepresentation(image) : UIImageJPEGRepresentation(image, 1.0);
                [fileManager createFileAtPath:filePath contents:imageData attributes:nil];
            }
        }
    });
}

+ (void)removeImageForKey:(NSString*)key {
    NSString* filePath = [self imageFilePathWithKey:key];
    NSFileManager* fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:filePath]) {
        [fileManager removeItemAtPath:filePath error:nil];
    }
}

+ (void)removeImageCache {
    NSString* filePath = [self imageCacheDirPath];
    NSFileManager* fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:filePath]) {
        [fileManager removeItemAtPath:filePath error:nil];
    }
}

#pragma mark Image for URL

+ (NSString*)imageKeyWithURL:(NSURL*)url {
    return [url.path stringByReplacingOccurrencesOfString:@"/" withString:@"_"];
}

+ (UIImage*)imageForURL:(NSURL*)url {
    return [self imageForKey:[self imageKeyWithURL:url]];
}

+ (void)saveImage:(UIImage*)image forURL:(NSURL*)url {
    [self saveImage:image forKey:[self imageKeyWithURL:url]];
}

+ (void)removeImageForURL:(NSURL*)url {
    [self removeImageForKey:[self imageKeyWithURL:url]];
}

+ (void)loadInBackgroundImageForURL:(NSURL*)url completion:(void(^)(UIImage* image))completion {
#ifdef ENABLE_PERMANENT_IMAGE_CACHE
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImage* image = [self imageForURL:url];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) {
                completion(image);
            }
        });
    });
#else
    if (completion) {
        completion(nil);
    }
#endif
}

@end

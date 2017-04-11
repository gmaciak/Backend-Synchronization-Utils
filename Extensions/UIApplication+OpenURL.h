//
//  UIApplication+OpenURL.h
//  
//
//  Created by Grzegorz Maciak on 20.02.2017.
//  Copyright © 2017 Grzegorz Maciak. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIApplication (OpenURL)

+ (void)openURLWithString:(NSString *)urlString;
+ (void)openURL:(NSURL *)url;

@end

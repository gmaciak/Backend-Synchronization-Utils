//
//  UIApplication+OpenURL.m
//  
//
//  Created by Grzegorz Maciak on 20.02.2017.
//  Copyright © 2017 Grzegorz Maciak. All rights reserved.
//

#import "UIApplication+OpenURL.h"

@implementation UIApplication (OpenURL)

+ (void)openURLWithString:(NSString *)urlString {
    NSURL* url = [NSURL URLWithString:urlString];
    [self openURL:url];
}

+ (void)openURL:(NSURL *)url {
    if ([[UIApplication sharedApplication] canOpenURL:url]){
        if ([[UIApplication sharedApplication] respondsToSelector:@selector(openURL:options:completionHandler:)]) {
            [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
        }else{
            [[UIApplication sharedApplication] openURL:url];
        }
    }
}

@end

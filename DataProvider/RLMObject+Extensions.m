//
//  RLMObject+Extensions.m
//  BESynchronizationUtils
//
//  Created by Grzegorz Maciak on 02.12.2016.
//  Copyright © 2016 Grzegorz Maciak. All rights reserved.
//

#import "RLMObject+Extensions.h"
//#import "NSAttributedString+HTML.h"
//#import "Constants.h"

@implementation RLMObject (Extensions)

+ (NSArray*)copyOfAllObjects {
    if ([self conformsToProtocol:@protocol(NSCopying)]) {
        RLMResults* allObjects = [self allObjects];
        NSMutableArray* copiedObjects = [NSMutableArray arrayWithCapacity:allObjects.count];
        for (__typeof(self) obj in allObjects) {
            [copiedObjects addObject:[obj copy]];
        }
        return copiedObjects;
    }
    return nil;
}

//- (NSAttributedString*)attributedStringFromHTML:(NSString*)html fontMarkup:(NSString*)markup {
//    if (html) {
//        if (markup) {
//            html = [markup stringByReplacingOccurrencesOfString:@"{0}" withString:html];
//        }
//        return [NSAttributedString attributedStringWithHTML:html];
//    }
//    return nil;
//}
//
//- (NSData*)archivedAttributedStringFromHTML:(NSString*)html fontMarkup:(NSString*)markup {
//    if (html) {
//        if (markup) {
//            html = [markup stringByReplacingOccurrencesOfString:@"{0}" withString:html];
//        }
//        NSAttributedString* attrString = [NSAttributedString attributedStringWithHTML:html];
//        NSString* trimmed = [attrString.string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
//        if (trimmed.length < attrString.string.length) {
//            NSRange range = [attrString.string rangeOfString:trimmed];
//            attrString = [attrString attributedSubstringFromRange:range];
//        }
//        return [NSKeyedArchiver archivedDataWithRootObject:attrString];
//    }
//    return nil;
//}
//
//- (NSAttributedString*)attributedStringFromArchivedHTML:(NSData*)data {
//    return [NSKeyedUnarchiver unarchiveObjectWithData:data];
//}

@end

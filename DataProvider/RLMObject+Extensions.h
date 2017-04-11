//
//  RLMObject+Extensions.h
//  BESynchronizationUtils
//
//  Created by Grzegorz Maciak on 02.12.2016.
//  Copyright © 2016 Grzegorz Maciak. All rights reserved.
//

#import <Realm/Realm.h>

@interface RLMObject (Extensions)

+ (NSArray*)copyOfAllObjects;
//- (NSData*)archivedAttributedStringFromHTML:(NSString*)html fontMarkup:(NSString*)markup;
//- (NSAttributedString*)attributedStringFromArchivedHTML:(NSData*)data;

@end

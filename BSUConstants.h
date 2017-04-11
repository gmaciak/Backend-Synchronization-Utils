//
//  BSUConstants.h
//  SetPoint
//
//  Created by Grzegorz Maciak on 30.03.2017.
//  Copyright © 2017 Grzegorz Maciak. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^BSUSuccessBlock)();

@interface BSUConstants : NSObject

@end

#if !defined(weakify) && !defined(strongify)
#define weakify(obj) __weak __typeof__(obj)weak##obj = obj;

#define strongify(obj) \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Wshadow\"") \
__strong __typeof__(weak##obj)obj = weak##obj; \
_Pragma("clang diagnostic pop")

#endif

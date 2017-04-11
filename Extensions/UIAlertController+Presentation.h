//
//  UIAlertController+Presentation.h
//  
//
//  Created by Grzegorz Maciak on 25.11.2016.
//  Copyright © 2016 Grzegorz Maciak. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIAlertController (Presentation)

- (void)present;

@end

//  see: http://stackoverflow.com/a/30941356
@interface UIAlertController (Window)

- (void)show;
- (void)show:(BOOL)animated;

@end

//
//  UIAppearance+Swift.m
//  higi
//
//  Created by Remy Panicker on 2/29/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@implementation UIBarButtonItem (UIBarButtonItemAppearance_Swift)

+ (instancetype)higi_appearanceWhenContainedIn:(Class<UIAppearanceContainer>)containerClass {
    return [self appearanceWhenContainedIn:containerClass, nil];
}

@end

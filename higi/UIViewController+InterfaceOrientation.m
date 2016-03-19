//
//  UIViewController+InterfaceOrientation.m
//  higi
//
//  Created by Remy Panicker on 3/19/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

#import "UIViewController+InterfaceOrientation.h"

@implementation UIViewController (InterfaceOrientation)

- (UIInterfaceOrientation)higi_interfaceOrientation {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    return self.interfaceOrientation;
#pragma clang diagnostic pop
}

@end

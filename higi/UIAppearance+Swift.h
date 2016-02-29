//
//  UIAppearance+Swift.h
//  higi
//
//  Created by Remy Panicker on 2/29/16.
//  Copyright © 2016 higi, LLC. All rights reserved.
//

@interface UIBarButtonItem (UIBarButtonItemAppearance_Swift)

/// appearanceWhenContainedIn: is not available in Swift. This fixes that. http://stackoverflow.com/a/27807417/5897233
+ (instancetype)higi_appearanceWhenContainedIn:(Class<UIAppearanceContainer>)containerClass;

@end

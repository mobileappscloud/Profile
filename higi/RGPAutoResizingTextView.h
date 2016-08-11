//
//  RGPAutoResizingTextView.h
//
//  Created by Remy Panicker on 2/3/15.
//  Copyright (c) 2015 Remy Panicker. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 This class inherits the behavior of a UITextView, with the added support
 for resizing in height as text is inserted/removed. This text view is ideal
 for in-line, multi-line, user text-input.
 
 Example: A chat or messaging view, where the user is able to view threaded
 messages as well as submit their own message to the thread.
 
 @note This class requires the use of auto layout constraints. The property
 translatesAutoresizingMaskIntoConstraints is NO by default because of the
 auto layout requirement.
 
 @warning An exception will be thrown if a height constraint is not attained.
 */

IB_DESIGNABLE
@interface RGPAutoResizingTextView : UITextView

/**
 The maximum number of lines to use for rendering text.
 
 Default value is 1 (single line). A value of 0 means there is no limit.
 */
@property (nonatomic) IBInspectable NSInteger maximumNumberOfLines;

/**
 The placeholder text which is displayed when there is no other text in the view.
 
 This value is nil by default.
 */
@property (nonatomic, copy) IBInspectable NSString *placeholder;

/** This property acts as a bridge to the layer's corner radius. */
@property (nonatomic) IBInspectable CGFloat cornerRadius;

/** This property acts as a bridge to the layer's border width. */
@property (nonatomic) IBInspectable CGFloat borderWidth;

/** This property acts as a bridge to the layer's border color. */
@property (nonatomic) IBInspectable UIColor *borderColor;

@end

//
//  RGPAutoResizingTextView.m
//
//  Created by Remy Panicker on 2/3/15.
//  Copyright (c) 2015 Remy Panicker. All rights reserved.
//

#import "RGPAutoResizingTextView.h"

@interface RGPAutoResizingTextView()

@property (strong, nonatomic) UILabel *placeholderLabel;

@property (strong, nonatomic) NSLayoutConstraint *heightConstraint;

/** Temporary flag indicating if text was pasted within the current event loop. */
@property (nonatomic) BOOL didPasteText;

@end

static NSInteger kRGPAutoResizingTextViewNumberOfLinesDefault = 1;

@implementation RGPAutoResizingTextView

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Initialization

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        _maximumNumberOfLines = kRGPAutoResizingTextViewNumberOfLinesDefault;
        
        [self commonInit];
    }
    return self;
}

/*
 Since -initWithCoder is called before -awakeFromNib, this is a good place
 to set default values for IBInspectable properties. This is necessary because
 unlike its Swift counterpart, Obj-C is not able to set a default value.
 */
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        if (_maximumNumberOfLines == 0)
        {
            _maximumNumberOfLines = kRGPAutoResizingTextViewNumberOfLinesDefault;
        }
    }
    return self;
}

- (void)awakeFromNib
{
    [self commonInit];
}

#pragma mark

- (void)commonInit
{
    self.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self attainHeightConstraint];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(autoresizingTextViewTextDidChange:) name:UITextViewTextDidChangeNotification object:nil];
}

#pragma mark - Layer

- (void)setCornerRadius:(CGFloat)cornerRadius
{
    _cornerRadius = cornerRadius;
    
    self.layer.cornerRadius = cornerRadius;
}

- (void)setBorderColor:(UIColor *)borderColor
{
    _borderColor = borderColor;
    
    self.layer.borderColor = borderColor.CGColor;
}

- (void)setBorderWidth:(CGFloat)borderWidth
{
    _borderWidth = borderWidth;
    
    self.layer.borderWidth = borderWidth;
}

#pragma mark - Layout

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self updateHeightConstraint];
    
    [self centerVerticallyIfNecessary];
    
    self.placeholderLabel.hidden = self.shouldHidePlaceholder;
    [self showPlaceholderIfNecessary];
}

#pragma mark

/**
 @abstract Vertically center the text view while the context size is smaller/equal to the text view frame.
 
 @discussion We're  supposed to have a maximum height contstraint for the text view which will eventually
 make the intrinsic height higher than the height of the text view - if we have enough text.
 This method will adjust the content offset to vertically center the text when applicable.
 */
- (void)centerVerticallyIfNecessary
{
    if (self.intrinsicContentSize.height <= CGRectGetHeight(self.bounds))
    {
        CGFloat topCorrect = (CGRectGetHeight(self.bounds) - (self.contentSize.height * self.zoomScale)) / 2.0;
        topCorrect = ( topCorrect < 0.0 ? 0.0 : topCorrect);
        self.contentOffset = (CGPoint){.x = 0, .y = -topCorrect};
    }
}

- (void)updateHeightConstraint
{
    CGSize intrinsicSize = self.intrinsicContentSize;
    if (self.maximumNumberOfLines != kRGPAutoResizingTextViewNumberOfLinesDefault)
    {
        intrinsicSize.height = MIN(intrinsicSize.height, self.maximumHeight);
    }
    self.heightConstraint.constant = intrinsicSize.height;
}

- (CGSize)intrinsicContentSize
{
    CGSize intrinsicContentSize = self.contentSize;
    
    // Add the text container insets so that there is padding around the content
    intrinsicContentSize.width += self.textContainerHorizontalInsets / 2.0;
    intrinsicContentSize.height += self.textContainerVerticalInsets / 2.0;
    
    return intrinsicContentSize;
}

/** Returns the top and bottom container insets. */
- (CGFloat)textContainerVerticalInsets
{
    return (self.textContainerInset.top + self.textContainerInset.bottom);
}

/** Returns the left and right container insets. */
- (CGFloat)textContainerHorizontalInsets
{
    return (self.textContainerInset.left + self.textContainerInset.right);
}

#pragma mark

/** Attains a reference to the height constraint and sets the local property. */
- (void)attainHeightConstraint
{
    for (NSLayoutConstraint *constraint in self.constraints)
    {
        if (constraint.firstAttribute == NSLayoutAttributeHeight)
        {
            self.heightConstraint = constraint;
            break;
        }
    }
}

- (NSLayoutConstraint *)heightConstraint
{
    // If the text view is initialized programatically, then we will need to
    // get the height constraint before we can use this class.
    if (!_heightConstraint)
    {
        [self attainHeightConstraint];
    }
    
#if !TARGET_INTERFACE_BUILDER
    NSAssert(_heightConstraint, @"A height constraint is required in order to utilitze this class.");
#endif
    
    return _heightConstraint;
}

#pragma mark - Placeholder

- (UILabel *)placeholderLabel
{
    if (!_placeholderLabel)
    {
        _placeholderLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _placeholderLabel.enabled = NO;
        _placeholderLabel.autoresizesSubviews = NO;
        _placeholderLabel.numberOfLines = 1;
        _placeholderLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _placeholderLabel.font = self.font;
        _placeholderLabel.backgroundColor = UIColor.clearColor;
        _placeholderLabel.hidden = YES;
        
        [self addSubview:_placeholderLabel];
        [self sendSubviewToBack:_placeholderLabel];
    }
    return _placeholderLabel;
}

- (BOOL)shouldHidePlaceholder
{
    if (self.placeholderLabel.text.length == 0 || self.text.length > 0)
    {
        return YES;
    }
    return NO;
}

- (void)showPlaceholderIfNecessary
{
    if (self.placeholderLabel.hidden)
    {
        return;
    }
    
    // TODO: Configure placeholder label to make use of autolayout constraints
    self.placeholderLabel.frame = [self placeholderRectThatFits];
    
    [self sendSubviewToBack:self.placeholderLabel];
}

- (CGRect)placeholderRectThatFits
{
    CGRect rect = CGRectZero;
    
    CGRect expectedFrame = [self.placeholder boundingRectWithSize:self.bounds.size
                                                          options:NSStringDrawingUsesLineFragmentOrigin
                                                       attributes:@{NSFontAttributeName : self.placeholderLabel.font}
                                                          context:nil];
    
    rect.size.width = expectedFrame.size.width;
    rect.size.height = self.placeholderLabel.font.lineHeight;

    rect.origin.x += self.textContainer.lineFragmentPadding;
    rect.origin.y = self.textContainerInset.top;
    
    return rect;
}

#pragma mark - Notifications

- (void)autoresizingTextViewTextDidChange:(NSNotification *)notification
{
    if (![notification.object isEqual:self])
    {
        return;
    }
    
    if (self.placeholderLabel.hidden != self.shouldHidePlaceholder)
    {
        [self setNeedsLayout];
    }
    
    if (self.didPasteText)
    {
        [self scrollRangeToVisible:NSMakeRange(self.text.length, 1)];
        
        self.didPasteText = NO;
    }
}

#pragma mark - Pasteboard

- (void)paste:(id)sender
{
    self.didPasteText = YES;
    
    [super paste:sender];
}

#pragma mark - Misc

- (CGFloat)maximumHeight
{
    NSInteger numberOfLines = self.maximumNumberOfLines = 0 ? INFINITY : self.maximumNumberOfLines;
    return (ceilf(self.font.lineHeight) * numberOfLines) + (self.textContainerVerticalInsets * 2.0);
}

- (void)setPlaceholder:(NSString *)placeholder
{
    _placeholder = placeholder.copy;
    self.placeholderLabel.text = placeholder.copy;
    
    [self setNeedsLayout];
}

- (void)setFont:(UIFont *)font
{
    [super setFont:font];
    
    self.placeholderLabel.font = font;
}

- (void)setText:(NSString *)text
{
    [super setText:text];
    
    if (!(text) || text.length == 0)
    {
        self.placeholderLabel.hidden = NO;
    }
}

@end

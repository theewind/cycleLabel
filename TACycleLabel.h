//
//  TACycleLabel.h
//  Nova
//
//  Created by sanfeng Li on 2/25/15.
//  Copyright (c) 2015 xxxx. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TACycleLabel : UIView

@property(nonatomic, copy) NSString *text;
@property(nonatomic, assign) NSUInteger rate;
@property (nonatomic) CGFloat fadeLength;

// UILabel properties
@property (nonatomic, copy) UIColor *backgroundColor;
@property (nonatomic) BOOL adjustsFontSizeToFitWidth;
@property (nonatomic) UIBaselineAdjustment baselineAdjustment;
@property (nonatomic, getter=isEnabled) BOOL enabled;
@property (nonatomic, retain) UIFont *font;
@property (nonatomic, getter=isHighlighted) BOOL highlighted;
@property (nonatomic, strong) UIColor *highlightedTextColor;
@property (nonatomic) UILineBreakMode lineBreakMode;
@property (nonatomic) CGFloat minimumFontSize;
@property (nonatomic) NSInteger numberOfLines;
@property (nonatomic, strong) UIColor *shadowColor;
@property (nonatomic) CGSize shadowOffset;
@property (nonatomic) NSTextAlignment textAlignment;
@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, getter=isUserInteractionEnabled) BOOL userInteractionEnabled;

@end

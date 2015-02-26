//
//  TALoopLabel.h
//  Nova
//
//  Created by sanfeng Li on 2/25/15.
//  Copyright (c) 2015 xxxx. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TALoopLabel : UIView

@property(nonatomic, assign) CGFloat runSpeed;
@property(nonatomic, assign) CGFloat gap;
@property(nonatomic, copy)  NSString *text;

// UILabel properties
@property (nonatomic, copy) UIColor *backgroundColor;
@property (nonatomic, retain) UIFont *font;
@property (nonatomic) NSInteger numberOfLines;
@property (nonatomic) NSTextAlignment textAlignment;
@property (nonatomic, strong) UIColor *textColor;


@end

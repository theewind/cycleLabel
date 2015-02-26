//
//  TACycleLabel.m
//  Nova
//
//  Created by sanfeng Li on 2/25/15.
//  Copyright (c) 2015 xxxx. All rights reserved.
//

#import "TACycleLabel.h"

@interface TACycleLabel()

@property (nonatomic, strong) UILabel *subLabel;
@property (nonatomic, strong) NSString *labelText;
@property (nonatomic, assign) NSUInteger animationOptions;
@property (nonatomic, assign) NSTimeInterval animationDuration;
@property (nonatomic, assign) CGFloat pixelsPerSec;
@property (nonatomic, assign) CGRect normalLabelFrame;
@property (nonatomic, assign) CGRect offsetLabelFrame;
@property (nonatomic, assign) BOOL autoReverse;

@end

@implementation TACycleLabel

@dynamic backgroundColor, adjustsFontSizeToFitWidth, baselineAdjustment, enabled, font, highlighted, highlightedTextColor, lineBreakMode, numberOfLines, minimumFontSize, shadowColor, shadowOffset, textAlignment, textColor, userInteractionEnabled;

- (void)awakeFromNib {
    [super awakeFromNib];
    [self p_setupLabel];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self p_setupLabel];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self removeAnimation];
}

#pragma mark - properties

- (void)setText:(NSString *)newText {
    if (![newText isEqualToString:self.labelText]) {
        self.labelText = newText;
        self.subLabel.text = self.labelText;
        CGSize maximumLabelSize = CGSizeMake(MAXFLOAT, self.frame.size.height);
        CGSize expectedLabelSize = [self.labelText sizeWithFont:self.subLabel.font
                                              constrainedToSize:maximumLabelSize
                                                  lineBreakMode:self.subLabel.lineBreakMode];

        self.normalLabelFrame = CGRectMake(self.fadeLength, 0, expectedLabelSize.width + self.fadeLength, self.height);
        self.offsetLabelFrame = CGRectOffset(self.normalLabelFrame, -expectedLabelSize.width + self.width - self.fadeLength * 2, 0.0);

        if ([self labelCanAnimaiton]) {
            self.animationDuration = (NSTimeInterval)fabs(self.offsetLabelFrame.origin.x) / self.pixelsPerSec;
            self.animationDuration = MAX(3, self.animationDuration);
            self.subLabel.frame = self.normalLabelFrame;
            [self moveLeftWithInterval:self.animationDuration withDelay:1.0];
        }
    }
}

- (NSString *)text {
    return self.labelText;
}

- (void)setRate:(NSUInteger)rate {
    _rate = rate;
    self.pixelsPerSec = rate;
}

- (void)setFadeLength:(CGFloat)aFadeLength {
    if (_fadeLength != aFadeLength) {
        _fadeLength = MIN(aFadeLength, self.width/2);
        
        [self p_applyGradientMask];
    }
}

#pragma mark - privates

- (void)p_setupLabel {
    [self setClipsToBounds:YES];
    self.backgroundColor = [UIColor whiteColor];
    self.animationOptions = (UIViewAnimationOptionCurveLinear | UIViewAnimationOptionAutoreverse | UIViewAnimationOptionRepeat | UIViewAnimationOptionAllowUserInteraction );
    self.subLabel = [[UILabel alloc] initWithFrame:self.bounds];
    self.subLabel.centerX = CGRectGetMidX(self.bounds);
    self.subLabel.backgroundColor = [UIColor clearColor];
    self.pixelsPerSec = 8;
    self.fadeLength = 0;
    [self addSubview:self.subLabel];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(restartAnimation) name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeAnimation) name:UIApplicationDidEnterBackgroundNotification object:nil];
}

- (void)p_applyGradientMask {
    if (self.fadeLength != 0.0f) {
        CAGradientLayer* gradientMask = [CAGradientLayer layer];
        gradientMask.bounds = self.layer.bounds;
        gradientMask.position = CGPointMake([self bounds].size.width / 2, [self bounds].size.height / 2);
        NSObject *transparent = (NSObject*) [[UIColor clearColor] CGColor];
        NSObject *opaque = (NSObject*) [[UIColor blackColor] CGColor];
        gradientMask.startPoint = CGPointMake(0.0, CGRectGetMidY(self.frame));
        gradientMask.endPoint = CGPointMake(1.0, CGRectGetMidY(self.frame));
        float fadePoint = (float)self.fadeLength/self.frame.size.width;
        [gradientMask setColors: [NSArray arrayWithObjects: transparent, opaque, opaque, transparent, nil]];
        [gradientMask setLocations: [NSArray arrayWithObjects:
                                     [NSNumber numberWithFloat: 0.0],
                                     [NSNumber numberWithFloat: fadePoint],
                                     [NSNumber numberWithFloat: 1 - fadePoint],
                                     [NSNumber numberWithFloat: 1.0],
                                     nil]];
        self.layer.mask = gradientMask;
    } else {
        self.layer.mask = nil;
    }
    
    if ([self labelCanAnimaiton]) {
        [self moveLabelToOriginImmediately];
        [self moveLeftWithInterval:self.animationDuration withDelay:1.0];
    }
}


#pragma mark - animation

- (BOOL)labelCanAnimaiton {
    return ((self.labelText != nil) && self.offsetLabelFrame.origin.x < 0);
}

- (void)moveLeftWithInterval:(NSTimeInterval)interval withDelay:(NSTimeInterval)delay {
    [UIView animateWithDuration:interval
                          delay:delay
                        options:self.animationOptions
                     animations:^{
                         self.subLabel.frame = self.offsetLabelFrame;
                     }
                     completion:^(BOOL finished) {
                         if (finished && self.autoReverse) {
                             [self moveRightWithInterval:interval];
                         }
                     }];
}

- (void)moveRightWithInterval:(NSTimeInterval)interval {
        [UIView animateWithDuration:self.animationDuration
                          delay:0.3
                        options:self.animationOptions
                     animations:^{
                         self.subLabel.frame = self.normalLabelFrame;
                     }
                     completion:^(BOOL finished){
                         if (finished && self.autoReverse) {
                             [self moveLeftWithInterval:interval withDelay:1.0];
                         }
                     }];
}

- (void)moveLabelToOriginImmediately {
    if (!CGRectEqualToRect(self.subLabel.frame, self.normalLabelFrame)) {
        self.subLabel.frame = self.normalLabelFrame;
    }
}

- (void)restartAnimation {
    if (self.labelCanAnimaiton) {
        [self moveLabelToOriginImmediately];
        [self moveLeftWithInterval:self.animationDuration withDelay:0.3];
    }
}

- (void)removeAnimation {
    [self.layer removeAllAnimations];
}

#pragma mark - UILabel Message Forwarding

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
    return [UILabel instanceMethodSignatureForSelector:aSelector];
}

- (void)forwardInvocation:(NSInvocation *)anInvocation {
    if ([self.subLabel respondsToSelector:[anInvocation selector]]) {
        [anInvocation invokeWithTarget:self.subLabel];
    } else {
        [super forwardInvocation:anInvocation];
    }
}

- (id)valueForUndefinedKey:(NSString *)key {
    return [self.subLabel valueForKey:key];
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    [self.subLabel setValue:value forKey:key];
}


@end

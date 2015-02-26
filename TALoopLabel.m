//
//  TALoopLabel.m
//  Nova
//
//  Created by sanfeng Li on 2/25/15.
//  Copyright (c) 2015 xxx.com. All rights reserved.
//

#import "TALoopLabel.h"

@interface TALoopLabel()
{
}

@property (nonatomic, strong) UILabel *headLabel;
@property (nonatomic, strong) UILabel *tailLabel;
@property (nonatomic, copy)   NSString *labelText;
@property (nonatomic, assign) CGSize textSize;
@property (nonatomic, assign) CGFloat delayTime;

@end

@implementation TALoopLabel

@dynamic backgroundColor, font, numberOfLines, textAlignment, textColor;


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self p_setupView];
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder {
    if( (self = [super initWithCoder:aDecoder]) ) {
        [self p_setupView];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.layer removeAllAnimations];
}
#pragma mark - properties

- (void)setText:(NSString *)newText {
    if (![newText isEqualToString:self.labelText]) {
        self.labelText = newText;
        self.headLabel.text = self.labelText;
        CGSize maximumLabelSize = CGSizeMake(MAXFLOAT, self.height);
        CGSize textSize = [self.labelText sizeWithFont:self.headLabel.font
                                     constrainedToSize:maximumLabelSize
                                         lineBreakMode:self.headLabel.lineBreakMode];
        textSize.width += self.gap/2;
        self.textSize = textSize;
        if ([self labelCanAnimation]) {
            self.tailLabel.hidden = NO;
            [self animationLabel];
        } else {
            self.tailLabel.hidden = YES;
        }
    }
}

- (NSString *)text {
    return self.labelText;
}

#pragma mark - animation

- (BOOL)labelCanAnimation {
    return ((self.labelText != nil) && self.textSize.width > self.width + self.gap/2);
}

- (void)animationLabel {
    self.headLabel.frame = CGRectMake(0, 0, self.textSize.width, self.textSize.height);
    self.tailLabel.frame = CGRectMake(self.textSize.width, 0, self.textSize.width, self.textSize.height);

    CGFloat duration = (2 * self.textSize.width - self.width) / self.runSpeed;
    CGFloat duration2 = self.width / self.runSpeed;
    
    [UIView animateWithDuration:duration delay:self.delayTime options:UIViewAnimationOptionCurveLinear | UIViewAnimationOptionBeginFromCurrentState animations:^{
        self.headLabel.frame = CGRectMake(self.width-2*self.textSize.width, 0, self.textSize.width, self.textSize.height);
        self.tailLabel.frame = CGRectMake(self.width-self.textSize.width, 0, self.textSize.width, self.textSize.height);
    } completion:^(BOOL finished) {
        if (finished) {
            self.headLabel.frame = CGRectMake(self.width, 0, self.textSize.width, self.textSize.height);
            
            [UIView animateWithDuration:duration2 delay:0 options:UIViewAnimationOptionCurveLinear | UIViewAnimationOptionBeginFromCurrentState animations:^{
                self.headLabel.frame = CGRectMake(0, 0, self.textSize.width, self.textSize.height);
                self.tailLabel.frame = CGRectMake(-self.textSize.width, 0, self.textSize.width, self.textSize.height);
            } completion:^(BOOL finished) {
                if (finished) {
                    self.delayTime = 0;
                    [self animationLabel];
                }
            }];
        }
    }];
}

- (void)pauseAnimation {
    [self.layer removeAllAnimations];
}

- (void)resumeAnimation {
    if ([self labelCanAnimation]) {
        self.delayTime = 1;
        [self animationLabel];
    }
}

#pragma mark - privates

-(void)p_setupView
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resumeAnimation) name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pauseAnimation) name:UIApplicationDidEnterBackgroundNotification object:nil];

    [self setBackgroundColor:[UIColor whiteColor]];
    [self setClipsToBounds:YES];
    
    self.headLabel = [[UILabel alloc] initWithFrame:self.bounds];
    [self.headLabel setBackgroundColor:[UIColor clearColor]];
    [self addSubview:self.headLabel];
    
    self.tailLabel = [[UILabel alloc] initWithFrame:self.bounds];
    [self.tailLabel setBackgroundColor:[UIColor clearColor]];
    [self addSubview:self.tailLabel];
    
    self.gap = 20;
    self.runSpeed = 20;
    self.delayTime = 1;
    
    RAC(self.tailLabel, font)               = RACObserve(self.headLabel, font);
    RAC(self.tailLabel, text)               = RACObserve(self.headLabel, text);
    RAC(self.tailLabel, backgroundColor)    = RACObserve(self.headLabel, backgroundColor);
    RAC(self.tailLabel, numberOfLines)      = RACObserve(self.headLabel, numberOfLines);
    RAC(self.tailLabel, textAlignment)      = RACObserve(self.headLabel, textAlignment);
    RAC(self.tailLabel, textColor)          = RACObserve(self.headLabel, textColor);
}

#pragma mark - UILabel Message Forwarding

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
    return [UILabel instanceMethodSignatureForSelector:aSelector];
}

- (void)forwardInvocation:(NSInvocation *)anInvocation {
    if ([self.headLabel respondsToSelector:[anInvocation selector]]) {
        [anInvocation invokeWithTarget:self.headLabel];
    } else {
        [super forwardInvocation:anInvocation];
    }
}

- (id)valueForUndefinedKey:(NSString *)key {
    return [self.headLabel valueForKey:key];
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    [self.headLabel setValue:value forKey:key];
}

@end

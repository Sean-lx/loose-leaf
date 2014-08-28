//
//  MMAvatarButton.m
//  LooseLeaf
//
//  Created by Adam Wulf on 8/27/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMAvatarButton.h"
#import <CoreText/CoreText.h>
#import "Constants.h"
#import "NSThread+BlockAdditions.h"
#import "UIFont+UIBezierCurve.h"

@implementation MMAvatarButton{
    NSString* letter;
    CGFloat pointSize;
    CTFontSymbolicTraits traits;
    UIFont* font;
    
    CGFloat targetProgress;
    BOOL targetSuccess;
    CGFloat lastProgress;
}

- (id)initWithFrame:(CGRect)_frame forLetter:(NSString*)_letter{
    self = [super initWithFrame:_frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        self.opaque = NO;
        letter = _letter;
        font = [UIFont systemFontOfSize:16];
        pointSize = [font pointSize] * kWidthOfSidebarButton / 50.0;
    }
    return self;
}

-(UIColor*) backgroundColor{
    if(self.shouldDrawDarkBackground){
        return [[self borderColor] colorWithAlphaComponent:.5];
    }else{
        return [[UIColor whiteColor] colorWithAlphaComponent:.7];
    }
}

-(UIColor*) fontColor{
    if(self.shouldDrawDarkBackground){
        return [[UIColor whiteColor] colorWithAlphaComponent:.7];
    }else{
        return [self borderColor];
    }
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGFloat smallest = MIN(self.bounds.size.width, self.bounds.size.height);
    CGFloat drawingWidth = (smallest - 2*kWidthOfSidebarButtonBuffer);
    CGRect frame = CGRectMake(kWidthOfSidebarButtonBuffer, kWidthOfSidebarButtonBuffer, drawingWidth, drawingWidth);
    CGFloat scaledPointSize = drawingWidth * pointSize / (kWidthOfSidebarButton - 2*kWidthOfSidebarButtonBuffer);
    
    //// Color Declarations
    UIColor* darkerGreyBorder = [self borderColor];
    UIColor* halfGreyFill = [self backgroundColor];
    
    
    CGContextSaveGState(context);
    
    
    UIBezierPath* glyphPath = [[font fontWithSize:scaledPointSize] bezierPathForString:letter];
    CGRect glyphRect = [glyphPath bounds];
    [glyphPath applyTransform:CGAffineTransformConcat(CGAffineTransformMakeTranslation(-glyphRect.origin.x - .5, -glyphRect.size.height),
                                                      CGAffineTransformMakeScale(1.f, -1.f))];
    [glyphPath applyTransform:CGAffineTransformMakeTranslation((drawingWidth - glyphRect.size.width) / 2 + kWidthOfSidebarButtonBuffer,
                                                               (drawingWidth - glyphRect.size.height) / 2 + kWidthOfSidebarButtonBuffer)];
    
    //// Oval Drawing
    UIBezierPath* ovalPath = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(CGRectGetMinX(frame) + 0.5, CGRectGetMinY(frame) + 0.5, floor(CGRectGetWidth(frame) - 1.0), floor(CGRectGetHeight(frame) - 1.0))];
    [ovalPath appendPath:glyphPath];
    [ovalPath closePath];
    [halfGreyFill setFill];
    [ovalPath fill];
    [darkerGreyBorder setStroke];
    ovalPath.lineWidth = 1;
    [ovalPath stroke];
    
    
    //
    // clear the arrow and box, then fill with
    // border color
    CGContextSetBlendMode(context, kCGBlendModeClear);
    [[UIColor whiteColor] setFill];
    [glyphPath fill];
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    
    [[self fontColor] setFill];
    [glyphPath fill];
    
    CGContextRestoreGState(context);
}


-(void) animateOffScreen{
    CGPoint offscreen = CGPointMake(self.center.x, self.center.y - self.bounds.size.height / 2);
    [UIView animateWithDuration:.3 animations:^{
        self.alpha = 0;
        self.center = offscreen;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

-(void) animateBounceToTopOfScreenWithDuration:(CGFloat)duration completion:(void (^)(BOOL finished))completion{
    
    [UIView animateKeyframesWithDuration:duration delay:0 options:UIViewKeyframeAnimationOptionCalculationModeLinear animations:^{
        
        CGPoint originalCenter = self.center;
        CGPoint targetCenter = CGPointMake(100 + self.bounds.size.width/2, self.bounds.size.height/2);
        
        
        int firstDrop = 14;
        int topOfBounce = 18;
        int maxSteps = 20;
        CGFloat bounceHeight = 25;
        
        for (int foo = 1; foo <= maxSteps; foo += 1) {
            [UIView addKeyframeWithRelativeStartTime:((foo-1)/(float)maxSteps) relativeDuration:1/(float)maxSteps animations:^{
                CGFloat x;
                CGFloat y;
                CGFloat t;
                if(foo <= firstDrop){
                    t = foo/(float)firstDrop;
                    x = logTransform(originalCenter.x, targetCenter.x, t);
                    y = sqTransform(originalCenter.y, targetCenter.y, t);
                }else if(foo <= topOfBounce){
                    // 7, 8
                    t = (foo-firstDrop)/(float)(topOfBounce - firstDrop);
                    x = targetCenter.x;
                    y = sqrtTransform(targetCenter.y, targetCenter.y + bounceHeight, t);
                }else{
                    // 9
                    t = (foo-topOfBounce) / (float)(maxSteps - topOfBounce);
                    x = targetCenter.x;
                    y = sqTransform(targetCenter.y + bounceHeight, targetCenter.y, t);
                }
                self.center = CGPointMake(x, y);
            }];
        }
        
    } completion:^(BOOL finished) {
        if(completion) completion(finished);
    }];
}

-(void) animateToPercent:(CGFloat)progress success:(BOOL)succeeded{
    targetProgress = progress;
    targetSuccess = succeeded;
    
    if(lastProgress < targetProgress){
        lastProgress += (targetProgress / 10.0);
        if(lastProgress > targetProgress){
            lastProgress = targetProgress;
        }
    }
    
    CGPoint center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
    
    CGFloat radius = self.drawableFrame.size.width / 2;
    CAShapeLayer *circle;
    if([self.layer.sublayers count] > 1){
        circle = [self.layer.sublayers lastObject];
    }else{
        circle=[CAShapeLayer layer];
        circle.path=[UIBezierPath bezierPathWithArcCenter:center radius:radius startAngle:2*M_PI*0-M_PI_2 endAngle:2*M_PI*1-M_PI_2 clockwise:YES].CGPath;
        circle.fillColor=[UIColor clearColor].CGColor;
        circle.strokeColor=[[UIColor whiteColor] colorWithAlphaComponent:.7].CGColor;
        circle.lineWidth=radius*2;
        CAShapeLayer *mask=[CAShapeLayer layer];
        mask.path=[UIBezierPath bezierPathWithArcCenter:center radius:radius-2 startAngle:2*M_PI*0-M_PI_2 endAngle:2*M_PI*1-M_PI_2 clockwise:YES].CGPath;
        circle.mask = mask;
        [self.layer addSublayer:circle];
    }
    
    circle.strokeEnd = lastProgress;
    
    if(lastProgress >= 1.0){
        CAShapeLayer *mask2=[CAShapeLayer layer];
        mask2.path=[UIBezierPath bezierPathWithArcCenter:center radius:radius-2 startAngle:2*M_PI*0-M_PI_2 endAngle:2*M_PI*1-M_PI_2 clockwise:YES].CGPath;
        
        UIView* checkOrXView = [[UIView alloc] initWithFrame:self.bounds];
        checkOrXView.backgroundColor = [UIColor whiteColor];
        checkOrXView.layer.mask = mask2;
        
        [[NSThread mainThread] performBlock:^{
            CAShapeLayer* checkMarkOrXLayer = [CAShapeLayer layer];
            checkMarkOrXLayer.anchorPoint = CGPointZero;
            checkMarkOrXLayer.bounds = self.bounds;
            UIBezierPath* path = [UIBezierPath bezierPath];
            if(succeeded){
                CGPoint start = CGPointMake(28, 39);
                CGPoint corner = CGPointMake(start.x + 6, start.y + 6);
                CGPoint end = CGPointMake(corner.x + 14, corner.y - 14);
                [path moveToPoint:start];
                [path addLineToPoint:corner];
                [path addLineToPoint:end];
            }else{
                CGFloat size = 14;
                CGPoint start = CGPointMake(31, 31);
                CGPoint end = CGPointMake(start.x + size, start.y + size);
                [path moveToPoint:start];
                [path addLineToPoint:end];
                start = CGPointMake(start.x + size, start.y);
                end = CGPointMake(start.x - size, start.y + size);
                [path moveToPoint:start];
                [path addLineToPoint:end];
            }
            checkMarkOrXLayer.path = path.CGPath;
            checkMarkOrXLayer.strokeColor = [UIColor blackColor].CGColor;
            checkMarkOrXLayer.lineWidth = 6;
            checkMarkOrXLayer.lineCap = @"square";
            checkMarkOrXLayer.strokeStart = 0;
            checkMarkOrXLayer.strokeEnd = 1;
            checkMarkOrXLayer.backgroundColor = [UIColor clearColor].CGColor;
            checkMarkOrXLayer.fillColor = [UIColor clearColor].CGColor;
            
            checkOrXView.alpha = 0;
            [checkOrXView.layer addSublayer:checkMarkOrXLayer];
            [self addSubview:checkOrXView];
            [UIView animateWithDuration:.3 animations:^{
                checkOrXView.alpha = 1;
            } completion:^(BOOL finished){
                if(succeeded){
//                    [delegate didShare:self];
                }
                [[NSThread mainThread] performBlock:^{
                    [self animateOffScreen];
//                    [checkOrXView removeFromSuperview];
//                    [circle removeAnimationForKey:@"drawCircleAnimation"];
//                    [circle removeFromSuperlayer];
//                    // reset state
//                    lastProgress = 0;
//                    targetSuccess = 0;
//                    targetProgress = 0;
                } afterDelay:.5];
            }];
        } afterDelay:.3];
    }else{
        [[NSThread mainThread] performBlock:^{
            [self animateToPercent:targetProgress success:targetSuccess];
        } afterDelay:.03];
    }
}


@end

//
//  AMARadialView.m
//  AMARadialView
//
//  Created by Andreas Mächler on 06.02.14.
//  Copyright (c) 2014 Andreas Maechler. All rights reserved.
//

#import "AMARadialView.h"

#define fequal(a,b) (fabs((a) - (b)) < FLT_EPSILON)
#define fequalzero(a) (fabs(a) < FLT_EPSILON)


@interface AMARadialView ()

@property (assign, nonatomic) CGFloat radialThickness;
@property (assign, nonatomic) CGFloat radialCurrentWidth;

@property (strong, nonatomic) UIColor *radialBackgroundColor;

@end


@implementation AMARadialView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup
{
    // Setup the view
	self.backgroundColor = [UIColor clearColor];
    
    // Setup the properties
    self.radialThickness = 15.0f;
    self.radialCurrentWidth = 0.1f;
    
    self.radialBackgroundColor = [UIColor colorWithRed:70/255.0 green:70/255.0 blue:60/255.0 alpha:1.0];
}


#pragma mark - Setters

- (void)setOffsetCurrent:(float)offsetCurrent
{
	_offsetCurrent = offsetCurrent;

	dispatch_async(dispatch_get_main_queue(), ^{
        [self setNeedsDisplay];
    });
}

- (void)setOffsetTotal:(float)offsetTotal
{
	_offsetTotal = offsetTotal;

	dispatch_async(dispatch_get_main_queue(), ^{
        [self setNeedsDisplay];
    });
}


#pragma mark - Drawing

- (void)drawRect:(CGRect)rect
{
    if (self.offsetTotal <= 0) {
        NSLog(@"offsetTotal needs to be defined.");
        return;
    }

    if (self.offsetCurrent < -self.offsetTotal || self.offsetCurrent > self.offsetTotal) {
        NSLog(@"offsetCurrent is out of bounds, %f %f", self.offsetCurrent, self.offsetTotal);
        return;
    }

	CGContextRef contextRef = UIGraphicsGetCurrentContext();
	CGSize viewSize = self.bounds.size;
	CGPoint center = CGPointMake(viewSize.width / 2, viewSize.height / 2);

    // 1. Draw the background circle
    float outerRadius = viewSize.width / 2;
    
    CGContextBeginPath(contextRef);
    CGContextMoveToPoint(contextRef, center.x, center.y);
    CGContextAddArc(contextRef, center.x, center.y, outerRadius, M_PI_4, 3 * M_PI_4, YES);
	CGContextSetFillColorWithColor(contextRef, self.radialBackgroundColor.CGColor);
    CGContextFillPath(contextRef);
    
    // 2. Draw the current offset arc
    CGContextBeginPath(contextRef);
    CGContextMoveToPoint(contextRef, center.x, center.y);

    float angle = M_PI_4 - 3 * M_PI_2 * (self.offsetCurrent + self.offsetTotal)/(2 * self.offsetTotal);
    CGContextAddArc(contextRef, center.x, center.y, outerRadius, angle + self.radialCurrentWidth, angle - self.radialCurrentWidth, YES);
    CGContextSetFillColorWithColor(contextRef, [self calculateCurrentArcColor]);
    CGContextFillPath(contextRef);

    
    // 3. Draw the inner circle (clear color)
    int innerRadius = outerRadius - (self.radialThickness / 2.0f);

	CGRect innerCircle = CGRectMake(center.x - innerRadius, center.y - innerRadius,
									innerRadius * 2.0f, innerRadius * 2.0f);
	CGContextAddEllipseInRect(contextRef, innerCircle);
	CGContextClip(contextRef);
	CGContextClearRect(contextRef, innerCircle);
	CGContextSetFillColorWithColor(contextRef, [UIColor clearColor].CGColor);
	CGContextFillRect(contextRef, innerCircle);
}

- (CGColorRef)calculateCurrentArcColor
{
    float fOffset = fabs(self.offsetCurrent);
    float midLocation = self.offsetTotal / 2.0f;
    
    CGFloat redComponents[4] = { 221/255.0f, 75/255.0f, 75/255.0f, 1.0f };
    CGFloat yellowComponents[4] = { 255/255.0f, 246/255.0f, 86/255.0f, 1.0f };
    CGFloat greenComponents[4] = { 85/255.0f, 193/255.0f, 99/255.0f, 1.0f };
    
    CGFloat currentComponents[4];
    if (fOffset <= midLocation) {
        // Interpolate color between red and yellow
        float k = -fOffset / midLocation + 1;
        for (int i = 0; i < 4; i++) {
            currentComponents[i] = yellowComponents[i] + (greenComponents[i] - yellowComponents[i]) * k;
        }
    } else {
        // Interpolate color between yellow and green
        float k = -fOffset / midLocation + 2;
        for (int i = 0; i < 4; i++) {
            currentComponents[i] = redComponents[i] + (yellowComponents[i] - redComponents[i]) * k;
        }
    }
    
//    CGFloat currentComponents[4];
//    // Interpolate color between red and yellow
//    float k = -fOffset / self.offsetTotal + 1;
//    for (int i = 0; i < 4; i++) {
//        currentComponents[i] = redComponents[i] + (greenComponents[i] - redComponents[i]) * k;
//    }

    return CGColorCreate(CGColorSpaceCreateDeviceRGB(), currentComponents);
}

@end

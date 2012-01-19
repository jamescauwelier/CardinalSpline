//
//  CatmullRomSplineVIew.m
//  SimpleObjectiveChipmunk
//
//  Created by Ben Ford on 1/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CatmullRomSplineView.h"

#define kPointSize 10

@interface CatmullRomSplineView(PrivateMethods)

- (CGFloat)catmullRomForTime:(CGFloat)t p0:(CGFloat)P0 p1:(CGFloat)P1 p2:(CGFloat)P2 p3:(CGFloat)P3;

- (CGRect)rectForPoint:(CGPoint)somePoint size:(CGFloat)size;
@end

@implementation CatmullRomSplineView
@synthesize handle1;
@synthesize handle2;
@synthesize point1;
@synthesize point2;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        self.handle1 = CGPointMake(10.0f, 450.0f);
        self.handle2 = CGPointMake(320.0f, 240.0f);
        
        self.point1 = CGPointMake(100.0f, 190.0f);
        self.point2 = CGPointMake(280.0f, 290.0f);
        
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
        pan.cancelsTouchesInView = NO;
        [self addGestureRecognizer:pan];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetLineWidth(context, 2.0f);
    CGContextSetStrokeColorWithColor(context, [UIColor blueColor].CGColor);
    CGContextMoveToPoint(context, point1.x, point1.y);
    for( CGFloat t = 0.0f; t < 1.01f; t += 0.05f ) {
        CGFloat x = [self catmullRomForTime:t p0:handle1.x p1:point1.x p2:point2.x p3:handle2.y];
        CGFloat y = [self catmullRomForTime:t p0:handle1.y p1:point1.y p2:point2.y p3:handle2.y];
        CGContextAddLineToPoint(context, x, y);
    }
    CGContextStrokePath(context);
    
    CGContextSetFillColorWithColor(context, [UIColor blueColor].CGColor);
    CGContextFillEllipseInRect(context, [self rectForPoint:point1 size:kPointSize]);
    CGContextFillEllipseInRect(context, [self rectForPoint:point2 size:kPointSize]);

    CGContextSetFillColorWithColor(context, [UIColor blackColor].CGColor);
    CGContextFillEllipseInRect(context, [self rectForPoint:handle1 size:kPointSize]);
    CGContextFillEllipseInRect(context, [self rectForPoint:handle2 size:kPointSize]);
}


@end

@implementation CatmullRomSplineView(PrivateMethods)

- (CGRect)rectForPoint:(CGPoint)somePoint size:(CGFloat)size {
    return CGRectMake(somePoint.x-size/2.0f, somePoint.y-size/2.0f, size, size);
}

- (CGFloat)catmullRomForTime:(CGFloat)t p0:(CGFloat)P0 p1:(CGFloat)P1 p2:(CGFloat)P2 p3:(CGFloat)P3 {
    return 0.5 * ((2 * P1) +
                  (-P0 + P2) * t +
                  (2*P0 - 5*P1 + 4*P2 - P3) * powf(t,2.0f) +
                  (-P0 + 3*P1- 3*P2 + P3) * powf(t, 3.0f));
}

- (void)tap:(UITapGestureRecognizer *)tapGesture {
    CGPoint touchPoint = [tapGesture locationInView:self];
    
    if( CGRectContainsPoint([self rectForPoint:point1], touchPoint) == YES )
        dragPoint = &point1;
    else if( CGRectContainsPoint([self rectForPoint:point2], touchPoint) == YES )
        dragPoint = &point2;
    else if( CGRectContainsPoint([self rectForPoint:handle1], touchPoint) == YES )
        dragPoint = &handle1;
    else if( CGRectContainsPoint([self rectForPoint:handle2], touchPoint) == YES )
        dragPoint = &handle2;
    else
        dragPoint = nil;
    
    if( dragPoint != nil )
        NSLog(@"captured point: %@", NSStringFromCGPoint(*dragPoint));
    else
        NSLog(@"no point found");
}

- (void)pan:(UIPanGestureRecognizer *)panGesture {

    CGPoint touchPoint = [panGesture locationInView:self];
    
    if( panGesture.state == UIGestureRecognizerStateBegan ) {
        if( CGRectContainsPoint([self rectForPoint:point1 size:50], touchPoint) == YES )
            dragPoint = &point1;
        else if( CGRectContainsPoint([self rectForPoint:point2 size:50], touchPoint) == YES )
            dragPoint = &point2;
        else if( CGRectContainsPoint([self rectForPoint:handle1 size:50], touchPoint) == YES )
            dragPoint = &handle1;
        else if( CGRectContainsPoint([self rectForPoint:handle2 size:50], touchPoint) == YES )
            dragPoint = &handle2;
        else
            dragPoint = nil;
        
        if( dragPoint != nil )
            NSLog(@"captured point: %@", NSStringFromCGPoint(*dragPoint));
        else
            NSLog(@"no point found");

    } else if( panGesture.state == UIGestureRecognizerStateChanged ) {
        //NSLog(@"dragging: %@", NSStringFromCGPoint(touchPoint));
        if( dragPoint != nil ) {
            dragPoint->x = touchPoint.x;
            dragPoint->y = touchPoint.y;
        }
        [self setNeedsDisplay];
    } 
}
@end
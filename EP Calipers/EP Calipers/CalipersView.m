//
//  CaliperView.m
//  EP Calipers
//
//  Created by David Mann on 3/23/15.
//  Copyright (c) 2015 EP Studios. All rights reserved.
//

#import "CalipersView.h"
#import "Caliper.h"
#import "EPSLogging.h"

@implementation CalipersView

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        NSMutableArray *array = [[NSMutableArray alloc] init];
        self.calipers = array;
        UITapGestureRecognizer *t = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
        [self addGestureRecognizer:t];
        UIPanGestureRecognizer *p = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dragging:)];
        [self addGestureRecognizer:p];
        self.clearsContextBeforeDrawing = YES;
    }
    return self;
}




// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    CGContextRef con = UIGraphicsGetCurrentContext();
    for (Caliper *caliper in self.calipers) {
        [caliper drawWithContext:con inRect:rect];
    }
}

- (void)selectCaliper:(Caliper *)c {
    c.color = [UIColor redColor];
    [self setNeedsDisplay];
    
}

- (void)unselectCaliper:(Caliper *)c {
    // TODO c.color = settings.defaultColor;, etc.
    c.color = [UIColor blackColor];
    [self setNeedsDisplay];
}

- (void)singleTap:(UITapGestureRecognizer *)t {
    CGPoint location = [t locationInView:self];
    EPSLog(@"single x = %f, y = %f", location.x, location.y);

    for (int i = self.calipers.count -1; i >= 0; i--) {
        if ([(Caliper *)self.calipers[i] pointNearCaliper:location]) {
            [self selectCaliper:(Caliper *)self.calipers[i]];
        }
        else {
            [self unselectCaliper:(Caliper *)self.calipers[i]];
        }
        
    }
}

- (void)dragging:(UIPanGestureRecognizer *)p {
    //EPSLog(@"dragging");
    //    UIView *view = p.view;
    CGPoint location = [p locationInView:self];
    static Caliper *selectedCaliper = nil;
    static BOOL bar1Selected = NO;
    static BOOL bar2Selected = NO;
    static BOOL crossBarSelected = NO;
    if (p.state == UIGestureRecognizerStateBegan) {
        // TODO reverse this; most recently added caliper should win
        for (int i = self.calipers.count -1; i >= 0; i--) {
            if ([(Caliper *)self.calipers[i] pointNearCaliper:location]) {
                selectedCaliper = (Caliper *)self.calipers[i];
                EPSLog(@"caliper selected");
                if ([selectedCaliper pointNearCrossBar:location]) {
                    crossBarSelected = YES;
                    EPSLog(@"crossbarSelected");
                }
                else if ([selectedCaliper pointNearBar:location forBarPosition:selectedCaliper.bar1Position]) {
                    bar1Selected = YES;
                    EPSLog(@"bar1Selected");
                }
                else if ([selectedCaliper pointNearBar:location forBarPosition:selectedCaliper.bar2Position]) {
                    bar2Selected = YES;
                    EPSLog(@"bar2Selected");
                }
            }
        }
    }
    if (p.state == UIGestureRecognizerStateEnded) {
        selectedCaliper = nil;
        bar1Selected = NO;
        bar2Selected = NO;
        crossBarSelected = NO;
        return;
    }
    if (selectedCaliper != nil) {
        CGPoint delta = [p translationInView:self];
        EPSLog(@"delta.x = %f, delta.y = %f", delta.x, delta.y);
        if (crossBarSelected) {
        selectedCaliper.bar1Position += delta.x;
        selectedCaliper.bar2Position += delta.x;
        selectedCaliper.crossBarPosition += delta.y;
        }
        else if (bar1Selected) {
            selectedCaliper.bar1Position += delta.x;
        }
        else if (bar2Selected) {
            selectedCaliper.bar2Position += delta.x;
        }
        [p setTranslation:CGPointZero inView:self];
        [self setNeedsDisplay];
        EPSLog(@"set needs display");
    }
    
    
    
}

//-(void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
//    UITouch *aTouch = [touches anyObject];
//    CGPoint location = [aTouch locationInView:self];
//    Caliper *c = (Caliper *)self.calipers[0];
//    if (location.x > c.bar1Position + 20 && location.x < c.bar2Position - 20
//        && location.y > c.crossBarPosition - 20 && location.y < c.crossBarPosition +20) {
//        CGPoint previousLocation = [aTouch previousLocationInView:self];
//        self.frame = CGRectOffset(self.frame, (location.x - previousLocation.x), (location.y - previousLocation.y));
//    }
//}

@end

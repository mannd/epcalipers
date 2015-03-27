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
    c.color = [UIColor magentaColor];
    [self setNeedsDisplay];
}

- (void)singleTap:(UITapGestureRecognizer *)t {
    CGPoint location = [t locationInView:self];
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
    CGPoint location = [p locationInView:self];
    static Caliper *selectedCaliper = nil;
    static BOOL bar1Selected = NO;
    static BOOL bar2Selected = NO;
    static BOOL crossBarSelected = NO;
    if (p.state == UIGestureRecognizerStateBegan) {
        for (int i = self.calipers.count -1; i >= 0; i--) {
            if ([(Caliper *)self.calipers[i] pointNearCaliper:location]) {
                selectedCaliper = (Caliper *)self.calipers[i];
                if ([selectedCaliper pointNearCrossBar:location]) {
                    crossBarSelected = YES;
                }
                else if ([selectedCaliper pointNearBar:location forBarPosition:selectedCaliper.bar1Position]) {
                    bar1Selected = YES;
                }
                else if ([selectedCaliper pointNearBar:location forBarPosition:selectedCaliper.bar2Position]) {
                    bar2Selected = YES;
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
        // swap delta x and y for vertical
        if (selectedCaliper.direction == Vertical) {
            float tmp = delta.x;
            delta.x = delta.y;
            delta.y = tmp;
        }
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
    }
}

@end

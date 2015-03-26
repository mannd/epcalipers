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
    [self setNeedsDisplayInRect:[c rect:[self frame]]];
    
}

- (void)unselectCaliper:(Caliper *)c {
    // TODO c.color = settings.defaultColor;, etc.
    c.color = [UIColor blackColor];
    [self setNeedsDisplayInRect:[c rect:[self frame]]];
}

- (void)singleTap:(UITapGestureRecognizer *)t {
    CGPoint location = [t locationInView:self];
    EPSLog(@"single x = %f, y = %f", location.x, location.y);

    for (int i = self.calipers.count -1; i >= 0; i--) {
        CGRect rect = [(Caliper *)self.calipers[i] rect:self.frame];
        if (CGRectContainsPoint(rect, location)) {
            [self selectCaliper:(Caliper *)self.calipers[i]];
        }
        else {
            [self unselectCaliper:(Caliper *)self.calipers[i]];
        }
        
    }
}

- (void)dragging:(UIPanGestureRecognizer *)p {
    EPSLog(@"dragging");
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

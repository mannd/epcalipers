//
//  CaliperView.m
//  EP Calipers
//
//  Created by David Mann on 3/23/15.
//  Copyright (c) 2015 EP Studios. All rights reserved.
//

#import "CalipersView.h"
#import "EPSLogging.h"

#define IMAGE_LOCK NSLocalizedString(@"Image_lock", nil)

@implementation CalipersView

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        NSMutableArray *array = [[NSMutableArray alloc] init];
        self.calipers = array;
        UIPanGestureRecognizer *draggingPanGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dragging:)];
        [self addGestureRecognizer:draggingPanGestureRecognizer];
        UITapGestureRecognizer *singleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
        singleTapGestureRecognizer.numberOfTapsRequired = 1;
        [self addGestureRecognizer:singleTapGestureRecognizer];
        UITapGestureRecognizer *doubleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
        doubleTapGestureRecognizer.numberOfTapsRequired = 2;
        [self addGestureRecognizer:doubleTapGestureRecognizer];
        [singleTapGestureRecognizer requireGestureRecognizerToFail:doubleTapGestureRecognizer];
        
        self.clearsContextBeforeDrawing = YES;
        self.allowTweakPosition = NO;
        self.lockImageScreen = NO;
        self.lockImageMessageForegroundColor = WHITE_COLOR;
        self.lockImageMessageBackgroundColor = RED_COLOR;
        self.aCaliperIsMarching = NO;
   }
    return self;
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (void)drawRect:(CGRect)rect {
    CGContextRef con = UIGraphicsGetCurrentContext();
    for (Caliper *caliper in self.calipers) {
        [caliper drawWithContext:con inRect:rect];
    }
    if (self.lockImageScreen) {
        [self showLockImageWarning:rect];
    }
}

- (void)showLockImageWarning:(CGRect)rect {
    NSString *text = IMAGE_LOCK;
    NSMutableDictionary *attributes = [NSMutableDictionary new];
    UIFont *textFont = [UIFont fontWithName:@"Helvetica" size:14.0];
    [attributes setObject:textFont forKey:NSFontAttributeName];
    [attributes setObject:self.lockImageMessageForegroundColor forKey:NSForegroundColorAttributeName];
    [attributes setObject:self.lockImageMessageBackgroundColor forKey:NSBackgroundColorAttributeName];
    rect = CGRectMake(rect.origin.x + 5, rect.origin.y + 5, rect.size.width, rect.size.height);
    [text drawInRect:rect withAttributes:attributes];
}

- (void)selectCaliperNoNeedsDisplay:(Caliper *)c {
    c.color = c.selectedColor;
    c.selected = YES;
}

- (void)unselectCaliperNoNeedsDisplay:(Caliper *)c {
    c.color = c.unselectedColor;
    c.selected = NO;
}

- (void)selectCaliper:(Caliper *)c {
    [self selectCaliperNoNeedsDisplay:c];
    [self setNeedsDisplay];
}

- (void)unselectCaliper:(Caliper *)c {
    [self unselectCaliperNoNeedsDisplay:c];
    [self setNeedsDisplay];
}

// Single tap initially highlights (selects) caliper,
// second tap unselects it.  Quick double tap is used
// to delete caliper.  This is new behavior with v2.0+.
- (void)singleTap:(UITapGestureRecognizer *)t {
    CGPoint location = [t locationInView:self];
    BOOL caliperToggled = NO;
    for (int i = (int)self.calipers.count - 1; i >= 0; i--) {
        if ([(Caliper *)self.calipers[i] pointNearCaliper:location] && !caliperToggled) {
            caliperToggled = YES;
            if (((Caliper *)self.calipers[i]).selected) {
                [self unselectCaliperNoNeedsDisplay:(Caliper *)self.calipers[i]];
            }
            else  {
                [self selectCaliperNoNeedsDisplay:(Caliper *)self.calipers[i]];
            }
        }
        else {
            [self unselectCaliperNoNeedsDisplay:(Caliper *)self.calipers[i]];
        }
    }
    if (caliperToggled) {
        [self setNeedsDisplay];
    }
}

- (void)doubleTap:(UITapGestureRecognizer *)t {
    CGPoint location = [t locationInView:self];
    [self deleteCaliper:location];
}

- (void)deleteCaliper:(CGPoint)location {
    for (int i = (int)self.calipers.count - 1; i >= 0; i--) {
        if ([(Caliper *)self.calipers[i] pointNearCaliper:location]) {
            [self.calipers removeObject:self.calipers[i]];
            if ([self thereAreNoTimeCalipers]) {
                self.aCaliperIsMarching = NO;
            }
            [self setNeedsDisplay];
            return;
        }
    }
}

- (void)dragging:(UIPanGestureRecognizer *)p {
    CGPoint location = [p locationInView:self];
    static Caliper *selectedCaliper = nil;
    static BOOL bar1Selected = NO;
    static BOOL bar2Selected = NO;
    static BOOL crossBarSelected = NO;
    BOOL selectionMade = NO;
    if (p.state == UIGestureRecognizerStateBegan) {
        for (int i = (int)self.calipers.count - 1; i >= 0; i--) {
            if ([(Caliper *)self.calipers[i] pointNearCaliper:location]  && !selectionMade) {
                selectedCaliper = (Caliper *)self.calipers[i];
                if ([selectedCaliper pointNearCrossBar:location]) {
                    crossBarSelected = YES;
                    selectionMade = YES;
                }
                else if ([selectedCaliper pointNearBar1:location]) {
                    bar1Selected = YES;
                    selectionMade = YES;
                }
                else if ([selectedCaliper pointNearBar2:location]) {
                    bar2Selected = YES;
                    selectionMade = YES;
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
        // swap delta x and y for vertical caliper
        if (selectedCaliper.direction == Vertical) {
            float tmp = delta.x;
            delta.x = delta.y;
            delta.y = tmp;
        }
        if (crossBarSelected) {
            [selectedCaliper moveCrossBar:delta];
        }
        else if (bar1Selected) {
            [selectedCaliper moveBar1:delta forLocation:location];
        }
        else if (bar2Selected) {
            [selectedCaliper moveBar2:delta forLocation:location];
        }
        [p setTranslation:CGPointZero inView:self];
        [self setNeedsDisplay];
    }
}

- (void)changeColor:(CGPoint)location {
    for (Caliper *c in self.calipers) {
        if ([c pointNearCaliper:location]) {
            [self.delegate chooseColor:c];
            break;
        }
    }
}

- (void) tweakPosition:(CGPoint)location {
    for (Caliper *c in self.calipers) {
        CaliperComponent component = [c getCaliperComponent:location];
        if (component != None) {
            [self.delegate tweakComponent:component forCaliper:c];
            break;
        }
    }
}

- (void)clearChosenComponentsExceptFor:(Caliper *)caliper {
    if (caliper == nil) {
        [self clearAllChosenComponents];
    }
    else {
        for (Caliper *c in self.calipers) {
            if (c != caliper) {
                c.chosenComponent = None;
            }
        }
    }
}

- (void)clearAllChosenComponents {
    for (Caliper *c in self.calipers) {
        c.chosenComponent = None;
    }
}

- (Caliper *) caliperNearLocation:(CGPoint)location {
    for (Caliper *c in self.calipers) {
        if ([c pointNearCaliper:location]) {
            return c;
        }
    }
    return nil;
}

- (BOOL) caliperNearLocationIsTimeCaliper:(CGPoint)location {
    Caliper *c = [self caliperNearLocation:location];
    if (c != nil) {
        return c.isTimeCaliper;
    }
    else {
        return NO;
    }
}

- (void)selectCaliperIfNoneSelected {
    if (self.calipers.count > 0 && [self noCaliperIsSelected]) {
        [self selectCaliper:(Caliper *)self.calipers[self.calipers.count - 1]];
    }
}

- (BOOL)noCaliperIsSelected {
    BOOL noneSelected = YES;
    for (int i = (int)self.calipers.count - 1; i >= 0; i--) {
        if ([(Caliper *)self.calipers[i] selected]) {
            noneSelected = NO;
            break;
        }
    }
    return noneSelected;
}

- (Caliper *)activeCaliper {
    if (self.calipers.count <= 0) {
        return nil;
    }
    Caliper *c = nil;
    for (int i = (int)self.calipers.count - 1; i >= 0; i--) {
        if ([(Caliper *)self.calipers[i] selected]) {
            c = (Caliper *)self.calipers[i];
        }
    }
    return c;
}

- (void)updateCaliperPreferences:(UIColor *)unselectedColor selectedColor:(UIColor*)selectedColor lineWidth:(NSInteger)lineWidth roundMsec:(BOOL)roundMsec autoPositionText:(BOOL)autoPositionText timeTextPosition:(TextPosition)timeTextPosition amplitudeTextPosition:(TextPosition)amplitudeTextPosition {
    // This method has been changed so that unselected color only applies to new calipers, since we can now change
    // individual caliper colors.
    for(Caliper *c in self.calipers) {
        c.selectedColor = selectedColor;
        //c.unselectedColor = unselectedColor;
        if (c.selected) {
            c.color = selectedColor;
        }
//        else {
//            c.color = unselectedColor;
//        }
        c.lineWidth = lineWidth;
        c.roundMsecRate = roundMsec;
        c.autoPositionText = autoPositionText;
        if (c.direction == Horizontal) {
            c.textPosition = timeTextPosition;
        }
        else {
            c.textPosition = amplitudeTextPosition;
        }
    }
}

- (NSUInteger)count {
    return [self.calipers count];
}

- (void)toggleShowMarchingCaliper:(CGPoint)location {
    if (self.calipers.count <= 0) {
        self.aCaliperIsMarching = NO;
        return;
    }
    Caliper *selectedCaliper = [self caliperNearLocation:location];
    if (selectedCaliper != nil && selectedCaliper.marching) {
        selectedCaliper.marching = NO;
        self.aCaliperIsMarching = NO;
        return;
    }
    else {
        for (Caliper *c in self.calipers) {
            c.marching = NO;
        }
        selectedCaliper.marching = YES;
        self.aCaliperIsMarching = YES;
    }
}

- (BOOL)thereAreNoTimeCalipers {
    if (self.calipers.count <= 0) {
        return YES;
    }
    BOOL noTimeCalipers = YES;
    for (Caliper *c in self.calipers) {
        if ([c isTimeCaliper]) {
            noTimeCalipers = NO;
            break;
        }
    }
    return noTimeCalipers;
}

- (CGPoint)getATimeCaliperMidpoint {
    Caliper *c = [self getATimeCaliper];
    return [c getCaliperMidPoint];
}

- (Caliper *)getATimeCaliper {
    Caliper *caliper = nil;
    if (self.calipers.count < 1) {
        return caliper;
    }
    for (Caliper *c in self.calipers) {
        if ([c isTimeCaliper]) {
            caliper = c;
            break;
        }
    }
    return caliper;
}

// This is a overriden UIView procedure that lets the event go down to the view beneath.
- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    for (int i = (int)self.calipers.count - 1; i >= 0; i--) {
        if ([(Caliper *)self.calipers[i] pointNearCaliper:point]) {
            return YES;
        }
    }
    return NO;
}

@end

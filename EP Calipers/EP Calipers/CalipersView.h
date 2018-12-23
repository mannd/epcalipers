//
//  CaliperView.h
//  EP Calipers
//
//  Created by David Mann on 3/23/15.
//  Copyright (c) 2015 EP Studios. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Caliper.h"

@protocol CalipersViewDelegate <NSObject>

@required
- (void)chooseColor:(Caliper *)caliper;
- (void)tweakComponent:(CaliperComponent)component forCaliper:(Caliper *)caliper;

@end

@interface CalipersView : UIView

- (id)initWithCoder:(NSCoder *)aDecoder;

@property (nonatomic, weak) id<CalipersViewDelegate> delegate;
@property (nonatomic, strong) NSMutableArray *calipers;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (nonatomic) BOOL locked;
@property (nonatomic) BOOL allowTweakPosition;
@property (nonatomic) BOOL lockImageScreen;
@property (nonatomic, strong) UIColor *lockImageMessageForegroundColor;
@property (nonatomic, strong) UIColor *lockImageMessageBackgroundColor;
@property (nonatomic) BOOL aCaliperIsMarching;

- (void)selectCaliperIfNoneSelected;
- (BOOL)noCaliperIsSelected;
- (Caliper *)activeCaliper;
- (void)selectCaliper:(Caliper *)c;
- (void)unselectCaliper:(Caliper *)c;
- (void)selectCaliperNoNeedsDisplay:(Caliper *)c;
- (void)unselectCaliperNoNeedsDisplay:(Caliper *)c;
- (void)updateCaliperPreferences:(UIColor *)unselectedColor selectedColor:(UIColor*)selectedColor lineWidth:(NSInteger)lineWidth roundMsec:(BOOL)roundMsec autoPositionText:(BOOL)autoPositionText timeTextPosition:(TextPosition)timeTextPosition amplitudeTextPosition:(TextPosition)amplitudeTextPosition;
- (NSUInteger)count;
- (void)toggleShowMarchingCaliper:(CGPoint)location;
- (BOOL)canBecomeFirstResponder;
- (void)changeColor:(CGPoint)location;
- (void) tweakPosition:(CGPoint)location;
- (BOOL) caliperNearLocationIsTimeCaliper:(CGPoint)location;
- (CGPoint)getATimeCaliperMidpoint;

@end

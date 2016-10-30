//
//  CaliperView.h
//  EP Calipers
//
//  Created by David Mann on 3/23/15.
//  Copyright (c) 2015 EP Studios. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Caliper.h"

@interface CalipersView : UIView

- (id)initWithCoder:(NSCoder *)aDecoder;

@property (nonatomic, strong) NSMutableArray *calipers;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (nonatomic) BOOL locked;

- (void)selectCaliperIfNoneSelected;
- (BOOL)noCaliperIsSelected;
- (Caliper *)activeCaliper;
- (void)selectCaliper:(Caliper *)c;
- (void)unselectCaliper:(Caliper *)c;
- (void)selectCaliperNoNeedsDisplay:(Caliper *)c;
- (void)unselectCaliperNoNeedsDisplay:(Caliper *)c;
- (void)updateCaliperPreferences:(UIColor *)unselectedColor selectedColor:(UIColor*)selectedColor lineWidth:(NSInteger)lineWidth roundMsec:(BOOL)roundMsec;

@end

//
//  Settings.h
//  EP Calipers
//
//  Created by David Mann on 3/27/15.
//  Copyright (c) 2015 EP Studios. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Defs.h"

typedef NS_ENUM(NSUInteger, QTcFormulaPreference) {
    Bazett = 0,
    Framingham = 1,
    Hodges = 2,
    Fridericia = 3,
    all = 4
};

@interface Settings : NSObject

@property (strong, nonatomic) UIColor *caliperColor;
@property (strong, nonatomic) UIColor *highlightColor;
@property (nonatomic) NSInteger lineWidth;
@property (strong, nonatomic) NSString *defaultCalibration;
@property (strong, nonatomic) NSString *defaultVerticalCalibration;
@property (nonatomic) BOOL roundMsecRate;
@property (nonatomic) QTcFormulaPreference qtcFormula;
@property (nonatomic) BOOL autoPositionText;
@property (nonatomic) TextPosition timeTextPosition;
@property (nonatomic) TextPosition amplitudeTextPosition;

- (instancetype)init;
- (void)loadPreferences;

@end

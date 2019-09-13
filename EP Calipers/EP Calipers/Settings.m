//
//  Settings.m
//  EP Calipers
//
//  Created by David Mann on 3/27/15.
//  Copyright (c) 2015 EP Studios. All rights reserved.
//

#import "Settings.h"
#import "Translation.h"
#import "EPSLogging.h"
#import "Defs.h"

@implementation Settings

- (instancetype)init {
    self = [super init];
    if (self) {
        self.caliperColor = BLUE_COLOR;
        self.highlightColor = RED_COLOR;
        self.lineWidth = 2;
        self.defaultCalibration = L(@"1000 msec");
        self.defaultVerticalCalibration = L(@"10 mm");
        self.roundMsecRate = YES;
        self.qtcFormula = Bazett;
        self.autoPositionText = YES;
        self.timeTextPosition = CenterAbove;
        self.amplitudeTextPosition = RightAbove;
    }
    return self;
}

- (void)loadPreferences {
    NSArray *colorKeys = [NSArray arrayWithObjects:@"Black", @"Magenta", @"Light Gray", @"Blue", @"Green", @"White", @"Red", @"Yellow", @"Orange", nil];
    NSArray *colorValues = [NSArray arrayWithObjects:BLACK_COLOR, MAGENTA_COLOR, GRAY_COLOR, BLUE_COLOR, GREEN_COLOR, WHITE_COLOR, RED_COLOR, YELLOW_COLOR, ORANGE_COLOR, nil];
    NSDictionary *colorMap = [NSDictionary dictionaryWithObjects:colorValues forKeys:colorKeys];
    
    NSArray *qtcFormulaKeys = [NSArray arrayWithObjects:@"Bazett", @"Framingham", @"Hodges", @"Fridericia", @"All", nil];
    NSArray *qtcFormulaValues = [NSArray arrayWithObjects:[NSNumber numberWithInteger:Bazett],
                          [NSNumber numberWithInteger:Framingham],
                          [NSNumber numberWithInteger:Hodges],
                          [NSNumber numberWithInteger:Fridericia],
                          [NSNumber numberWithInteger:all],
                          nil];
    NSDictionary *qtcFormulaMap = [NSDictionary dictionaryWithObjects:qtcFormulaValues forKeys:qtcFormulaKeys];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    self.lineWidth = [[defaults objectForKey:@"lineWidthPreference"] intValue];
    self.defaultCalibration = [defaults objectForKey:@"calibrationPreference"];
    self.defaultVerticalCalibration = [defaults objectForKey:@"verticalCalibrationPreference"];
    
    NSString *colorName = [defaults objectForKey:@"caliperColorPreference"];
    NSString *highlightColorName = [defaults objectForKey:@"highlightColorPreference"];
    self.caliperColor = [colorMap valueForKey:colorName];
    self.highlightColor = [colorMap valueForKey:highlightColorName];
    self.roundMsecRate = [defaults boolForKey:@"roundMsecRatePreference"];
    NSString *qtcFormulaName = [defaults objectForKey:@"qtcFormulaPreference"];
    self.qtcFormula = (QTcFormulaPreference)[[qtcFormulaMap valueForKey:qtcFormulaName] integerValue];
    self.autoPositionText = [defaults boolForKey:@"autopositionPreference"];
    // The values here are just NSNumbers and correspond to the TextPosition values.
    NSString *timeTextPositionValue = [defaults objectForKey:@"timeTextPositionPreference"];
    self.timeTextPosition = [timeTextPositionValue integerValue];
    NSString *amplitudeTextPositionValue = [defaults objectForKey:@"amplitudeTextPositionPreference"];
    self.amplitudeTextPosition = [amplitudeTextPositionValue integerValue];
}

@end

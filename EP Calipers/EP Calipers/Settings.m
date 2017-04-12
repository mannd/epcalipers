//
//  Settings.m
//  EP Calipers
//
//  Created by David Mann on 3/27/15.
//  Copyright (c) 2015 EP Studios. All rights reserved.
//

#import "Settings.h"
#import "EPSLogging.h"

@implementation Settings

- (instancetype)init {
    self = [super init];
    if (self) {
        self.caliperColor = [UIColor blueColor];
        self.highlightColor = [UIColor redColor];
        self.lineWidth = 2;
        self.defaultCalibration = @"1000 msec";
        self.defaultVerticalCalibration = @"10 mm";
        self.roundMsecRate = YES;
    }
    return self;
}

- (void)loadPreferences {
    NSArray *colorKeys = [NSArray arrayWithObjects:@"Black", @"Magenta", @"Light Gray", @"Blue", @"Green", @"White", @"Red", @"Yellow", @"Orange", nil];
    NSArray *colorValues = [NSArray arrayWithObjects:[UIColor blackColor], [UIColor magentaColor], [UIColor lightGrayColor], [UIColor blueColor], [UIColor greenColor], [UIColor whiteColor], [UIColor redColor], [UIColor yellowColor], [UIColor orangeColor], nil];
    NSDictionary *colorMap = [NSDictionary dictionaryWithObjects:colorValues forKeys:colorKeys];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    self.lineWidth = [[defaults objectForKey:@"lineWidthPreference"] intValue];
    self.defaultCalibration = [defaults objectForKey:@"calibrationPreference"];
    self.defaultVerticalCalibration = [defaults objectForKey:@"verticalCalibrationPreference"];
    
    NSString *colorName = [defaults objectForKey:@"caliperColorPreference"];
    NSString *highlightColorName = [defaults objectForKey:@"highlightColorPreference"];
    self.caliperColor = [colorMap valueForKey:colorName];
    self.highlightColor = [colorMap valueForKey:highlightColorName];

    self.roundMsecRate = [defaults boolForKey:@"roundMsecRatePreference"];
}

@end

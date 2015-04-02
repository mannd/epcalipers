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
        self.hideStartImage = NO;
    }
    return self;
}

- (void)loadPreferences {
    NSArray *colorKeys = [NSArray arrayWithObjects:@"Black", @"Magenta", @"Light Gray", @"Blue", @"Green", @"White", @"Red", @"Yellow", @"Orange", nil];
    NSArray *colorValues = [NSArray arrayWithObjects:[UIColor blackColor], [UIColor magentaColor], [UIColor lightGrayColor], [UIColor blueColor], [UIColor greenColor], [UIColor whiteColor], [UIColor redColor], [UIColor yellowColor], [UIColor orangeColor], nil];
    NSDictionary *colorMap = [NSDictionary dictionaryWithObjects:colorValues forKeys:colorKeys];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    // until user changes defaults, they don't work
    int lineWidth = [[defaults objectForKey:@"lineWidthPreference"] intValue];
    if (lineWidth > 1) {
        self.lineWidth = lineWidth;
    }
    NSString *defaultCalibration = [defaults objectForKey:@"calibrationPreference"];
    if (defaultCalibration != nil) {
        self.defaultCalibration = defaultCalibration;
    }
    NSString *colorName = [defaults objectForKey:@"caliperColorPreference"];
    NSString *highlightColorName = [defaults objectForKey:@"highlightColorPreference"];
    UIColor *caliperColor = [colorMap valueForKey:colorName];
    if (caliperColor != nil) {
        self.caliperColor = caliperColor;
    }
    UIColor *highlightColor = [colorMap valueForKey:highlightColorName];
    if (highlightColor != nil) {
        self.highlightColor = highlightColor;
    }
    
    // doesn't matter if not set, will be NO which is the default anyway
    self.hideStartImage = [defaults boolForKey:@"hideStartImagePreference"];
    
    EPSLog(@"Color = %@, highlightColor = %@", colorName, highlightColor);

    
}

@end

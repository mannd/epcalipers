//
//  EP_CalipersTests.m
//  EP CalipersTests
//
//  Created by David Mann on 3/15/15.
//  Copyright (c) 2015 EP Studios. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "Caliper.h"
#import "Calibration.h"

@interface EP_CalipersTests : XCTestCase

@end

@implementation EP_CalipersTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    XCTAssert(YES, @"Pass");
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

- (void)testBarCoord {
    Caliper *c = [[Caliper alloc] init];
    XCTAssert(c.bar1Position == 0);
    XCTAssert(c.bar2Position == 0);
    XCTAssert(c.crossBarPosition == 100.0);
    CGPoint p = CGPointMake(100, 50);
    XCTAssert([c barCoord:p] == 100);
    c.direction = Vertical;
    XCTAssert([c barCoord:p] == 50);
}

- (void)testCanDisplayRate {
    Calibration *cal = [[Calibration alloc] init];
    cal.calibratedProtraitMode = YES;
    cal.units = @"msec";
    XCTAssert([cal canDisplayRate]);
    cal.units = @"milliseconds";
    XCTAssert([cal canDisplayRate]);
    cal.units = @"sec";
    XCTAssert([cal canDisplayRate]);
    cal.units = @"secs";
    XCTAssert([cal canDisplayRate]);
    cal.units = @"Msec";
    XCTAssert([cal canDisplayRate]);
    cal.units = @"ms";
    XCTAssert([cal canDisplayRate]);
    cal.units = @"mm";
    XCTAssert(![cal canDisplayRate]);
    cal.units = @"mSecs";
    XCTAssert([cal canDisplayRate]);
    cal.direction = Vertical;
    XCTAssert(![cal canDisplayRate]);
}

- (void)testCurrentHorizontalCalFactor {
    Calibration *cal = [[Calibration alloc] init];
    cal.zOriginalZoom = 1.0;
    cal.zOriginalMaximum = 500.0;
    cal.zOriginalCalFactor = 0.5;
    cal.zCurrentZoom = 1.0;
    cal.zCurrentMaximum = 1000.0;
    XCTAssert([cal zCurrentCalFactor] == 0.25);
    cal.zCurrentZoom = 2.0;
    XCTAssert([cal zCurrentCalFactor] == 0.125);
}

@end

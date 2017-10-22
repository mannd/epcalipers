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
#import "AngleCaliper.h"
#import "EPSMainViewController.h"



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
    cal.calibrated = YES;
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
    cal.originalZoom = 1.0;
    cal.originalCalFactor = 0.5;
    cal.currentZoom = 1.0;
    XCTAssert([cal currentCalFactor] == 0.5);
    cal.currentZoom = 2.0;
    XCTAssert([cal currentCalFactor] == 0.25);
}

- (void)testUnitsAreMM {
    Calibration *cal = [[Calibration alloc] init];
    cal.calibrated = YES;
    cal.direction = Vertical;
    cal.units = @"mm";
    XCTAssert([cal unitsAreMM]);
    cal.units = @"millimeters";
    XCTAssert([cal unitsAreMM]);
    cal.units = @"Millimeter";
    XCTAssert([cal unitsAreMM]);
    cal.units = @"MM";
    XCTAssert([cal unitsAreMM]);
    cal.units = @"milliM";
    XCTAssert([cal unitsAreMM]);
    cal.units = @"milliVolts";
    XCTAssert(![cal unitsAreMM]);
    cal.units = @"mV";
    XCTAssert(![cal unitsAreMM]);
    cal.units = @"msec";
    XCTAssert(![cal unitsAreMM]);
}

- (void)testRadiansToDegrees {
    double angle = 0;
    XCTAssert([AngleCaliper radiansToDegrees:angle] == 0.0);
    angle = M_PI / 2.0;
    XCTAssert([AngleCaliper radiansToDegrees:angle] == 90.0);
    angle = M_PI;
    XCTAssert([AngleCaliper radiansToDegrees:angle] == 180.0);
}

- (void)testIsAngleCaliber {
    Caliper *caliper = [[Caliper alloc] init];
    XCTAssert([caliper requiresCalibration]);
    XCTAssert(!caliper.isAngleCaliper);
    Caliper *angleCaliper = [[AngleCaliper alloc] init];
    XCTAssert(![angleCaliper requiresCalibration]);
    XCTAssert(angleCaliper.isAngleCaliper);
}

- (void)testBrugadaTriangles {
    // equilateral triangle
    double height = 5.0;
    double angle1 = M_PI_2 * 4 / 3;
    double angle2 = M_PI_2 * 2 / 3;
    double base = [AngleCaliper calculateBaseFromHeight:height andAngle1:angle1 andAngle2:angle2];
    XCTAssertEqualWithAccuracy(base, 2 * height / sqrt(3.0), 0.001);
    // arbitrary values from an online triangle calculator http://keisan.casio.com/exec/system/1273847553
    height = 16.9;
    base = [AngleCaliper calculateBaseFromHeight:height andAngle1:angle1 andAngle2:angle2];
    XCTAssertEqualWithAccuracy(base, 19.51443, 0.001);
    // scalene triangle
}

@end

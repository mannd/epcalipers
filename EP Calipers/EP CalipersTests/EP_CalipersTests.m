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
#import "MiniQTcResult.h"
#import "Translation.h"
#import "Version.h"

@interface EP_CalipersTests : XCTestCase

@end

@implementation EP_CalipersTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    if (![L(@"lang") isEqualToString:@"en"]) {
        NSLog(@"Tests must be run using English localization.");
        exit(1);
    }
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

- (void)testCaliperInitialPosition {
    Caliper *c = [[Caliper alloc] init];
    CGRect rect = CGRectMake(0, 0, 200, 200);
    [c setInitialPositionInRect:rect];
    Caliper *d = [[Caliper alloc] init];
    [d setInitialPositionInRect:rect];
    XCTAssertFalse(c.bar1Position == d.bar1Position);
    XCTAssertFalse(c.bar2Position == d.bar2Position);
    XCTAssertFalse(c.crossBarPosition == d.crossBarPosition);
    c.direction = Vertical;
    d.direction = Vertical;
    [c setInitialPositionInRect:rect];
    [d setInitialPositionInRect:rect];
    XCTAssertFalse(c.bar1Position == d.bar1Position);
    XCTAssertFalse(c.bar2Position == d.bar2Position);
    XCTAssertFalse(c.crossBarPosition == d.crossBarPosition);
    for (int i = 0; i < 20; i++) {
        [c setInitialPositionInRect:rect];
        [d setInitialPositionInRect:rect];
        XCTAssertFalse(c.bar1Position == d.bar1Position);
        XCTAssertFalse(c.bar2Position == d.bar2Position);
        XCTAssertFalse(c.crossBarPosition == d.crossBarPosition);
    }
    Caliper *e = [[Caliper alloc] initWithDirection:Vertical bar1Position:0 bar2Position:10 crossBarPosition:30];
    Caliper *f = [[Caliper alloc] initWithDirection:Vertical bar1Position:0 bar2Position:10 crossBarPosition:30];
    XCTAssertTrue(e.bar1Position == f.bar1Position);
    XCTAssertTrue(e.bar2Position == f.bar2Position);
    XCTAssertTrue(e.crossBarPosition == f.crossBarPosition);
    [e setInitialPositionInRect:rect];
    [f setInitialPositionInRect:rect];
    XCTAssertFalse(e.bar1Position == f.bar1Position);
    XCTAssertFalse(e.bar2Position == f.bar2Position);
    XCTAssertFalse(e.crossBarPosition == f.crossBarPosition);
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
    cal.units = @"миллиметр";
    XCTAssert([cal unitsAreMM]);
    cal.units = @"миллиметра";
    XCTAssert([cal unitsAreMM]);
    cal.units = @"мм";
    XCTAssert([cal unitsAreMM]);
    cal.direction = Horizontal;
    XCTAssertFalse([cal unitsAreMM]);
    cal.units = @"";
    XCTAssertFalse([cal unitsAreMM]);
}

- (void)testUnitsAreSec {
    Calibration *cal = [[Calibration alloc] init];
    cal.units = @"sec";
    XCTAssert([cal unitsAreSeconds]);
    cal.units = @"seconds";
    XCTAssert([cal unitsAreSeconds]);
    cal.units = @"SEC";
    XCTAssert([cal unitsAreSeconds]);
    cal.units = @"s";
    XCTAssert([cal unitsAreSeconds]);
    cal.units = @"msec";
    XCTAssertFalse([cal unitsAreSeconds]);
    cal.units = @"секунд";
    XCTAssert([cal unitsAreSeconds]);
    cal.units = @"сек";
    XCTAssert([cal unitsAreSeconds]);
    cal.units = @"с";
    XCTAssert([cal unitsAreSeconds]);
    cal.units = @"";
    XCTAssertFalse([cal unitsAreSeconds]);
    cal.units = @"blah";
    XCTAssertFalse([cal unitsAreSeconds]);
    cal.units = @"sec";
    cal.direction = Vertical;
    XCTAssertFalse([cal unitsAreSeconds]);

}

- (void)testUnitsAreMsec {
    Calibration *cal = [[Calibration alloc] init];
    cal.units = @"msec";
    XCTAssert([cal unitsAreMsec]);
    cal.units = @"Msec";
    XCTAssert([cal unitsAreMsec]);
    cal.units = @"MSECs";
    XCTAssert([cal unitsAreMsec]);
    cal.units = @"ms";
    XCTAssert([cal unitsAreMsec]);
    cal.units = @"millisec";
    XCTAssert([cal unitsAreMsec]);
    cal.units = @"millimeters";
    XCTAssertFalse([cal unitsAreMsec]);
    cal.units = @"мс";
    XCTAssert([cal unitsAreMsec]);
    cal.units = @"мсек";
    XCTAssert([cal unitsAreMsec]);
    cal.units = @"миллисекунду";
    XCTAssert([cal unitsAreMsec]);
    cal.units = @"";
    XCTAssertFalse([cal unitsAreMsec]);
    cal.units = @"blah";
    XCTAssertFalse([cal unitsAreMsec]);
    cal.units = @"msec";
    cal.direction = Vertical;
    XCTAssertFalse([cal unitsAreMsec]);
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

- (void)testQT {
    MiniQTcResult *qtcResult = [[MiniQTcResult alloc] init];
    NSString  *result = [qtcResult calculateFromQtInSec:0.4 rrInSec:1.0 formula:Bazett convertToMsec:NO units:@"sec"];
    XCTAssertEqualObjects(result, @"Mean RR = 1 sec\nQT = 0.4 sec\nQTc = 0.4 sec (Bazett formula)");
    result = [qtcResult calculateFromQtInSec:0.4 rrInSec:1.0 formula:Hodges convertToMsec:NO units:@"sec"];
    XCTAssertEqualObjects(result, @"Mean RR = 1 sec\nQT = 0.4 sec\nQTc = 0.4 sec (Hodges formula)");
    result = [qtcResult calculateFromQtInSec:0.278 rrInSec:0.6818 formula:Bazett convertToMsec:NO units:@"sec"];
    XCTAssertEqualObjects(result, @"Mean RR = 0.6818 sec\nQT = 0.278 sec\nQTc = 0.3367 sec (Bazett formula)");
    result = [qtcResult calculateFromQtInSec:0.278 rrInSec:0.6818 formula:Fridericia convertToMsec:NO units:@"sec"];
    XCTAssertEqualObjects(result, @"Mean RR = 0.6818 sec\nQT = 0.278 sec\nQTc = 0.3159 sec (Fridericia formula)");
    result = [qtcResult calculateFromQtInSec:0.278 rrInSec:0.6818 formula:Framingham convertToMsec:NO units:@"sec"];
    XCTAssertEqualObjects(result, @"Mean RR = 0.6818 sec\nQT = 0.278 sec\nQTc = 0.327 sec (Framingham formula)");
    result = [qtcResult calculateFromQtInSec:0.278 rrInSec:0.6818 formula:Hodges convertToMsec:NO units:@"sec"];
    XCTAssertEqualObjects(result, @"Mean RR = 0.6818 sec\nQT = 0.278 sec\nQTc = 0.327 sec (Hodges formula)");
    result = [qtcResult calculateFromQtInSec:0.334 rrInSec:0.5357 formula:Bazett convertToMsec:YES units:@"msec"];
    XCTAssertEqualObjects(result, @"Mean RR = 535.7 msec\nQT = 334 msec\nQTc = 456.3 msec (Bazett formula)");
    result = [qtcResult calculateFromQtInSec:0.334 rrInSec:0.5357 formula:Fridericia convertToMsec:YES units:@"msec"];
    XCTAssertEqualObjects(result, @"Mean RR = 535.7 msec\nQT = 334 msec\nQTc = 411.3 msec (Fridericia formula)");
    result = [qtcResult calculateFromQtInSec:0.334 rrInSec:0.5357 formula:Framingham convertToMsec:YES units:@"msec"];
    XCTAssertEqualObjects(result, @"Mean RR = 535.7 msec\nQT = 334 msec\nQTc = 405.5 msec (Framingham formula)");
    result = [qtcResult calculateFromQtInSec:0.334 rrInSec:0.5357 formula:Hodges convertToMsec:YES units:@"msec"];
    XCTAssertEqualObjects(result, @"Mean RR = 535.7 msec\nQT = 334 msec\nQTc = 425 msec (Hodges formula)");
    result = [qtcResult calculateFromQtInSec:0.3 rrInSec:0 formula:Framingham convertToMsec:NO units:@"sec"];
    XCTAssertEqualObjects(result, L(@"Invalid_result"));
}

- (void)testCaliperMidpoint {
    Caliper *c1 = [[Caliper alloc] initWithDirection:Horizontal bar1Position:200 bar2Position:100 crossBarPosition:100];
    CGPoint midPoint = CGPointMake(150, 100);
    XCTAssertEqual(c1.getCaliperMidPoint.x, midPoint.x);
    XCTAssertEqual(c1.getCaliperMidPoint.y, midPoint.y);
    Caliper *c2 = [[Caliper alloc] initWithDirection:Vertical bar1Position:200 bar2Position:100 crossBarPosition:100];
    midPoint = CGPointMake(100, 150);
    XCTAssertEqual(c2.getCaliperMidPoint.x, midPoint.x);
    XCTAssertEqual(c2.getCaliperMidPoint.y, midPoint.y);
    Caliper *c3;
    XCTAssertEqual(c3.getCaliperMidPoint.x, 0);
    XCTAssertEqual(c3.getCaliperMidPoint.y, 0);
}

- (void)testVersion {
    NSString *testVersion = @"2.1.3";
    XCTAssertEqualObjects(@"2", [Version getMajorVersion:testVersion]);
    Version *versionTest = [[Version alloc] initWithVersion:@"3.1.9" previousVersion:@"2.1.9"];
    versionTest.doUnitTest = YES;
    XCTAssertTrue([versionTest isUpgrade]);
    XCTAssertFalse([versionTest isNewInstallation]);
    versionTest.previousVersion = nil;
    XCTAssertTrue([versionTest isNewInstallation]);
    versionTest.previousVersion = nil;
    XCTAssertTrue([versionTest isNewInstallation]);
    versionTest.currentVersion = @"1.0";
    XCTAssertFalse([versionTest isUpgrade]);
}

- (void)testCalipersView {
    // Note: some of these tests just "exercise" the code for coverage and don't really test anything.
    CGRect rect = CGRectMake(0, 0, 300, 300);
    CalipersView *view = [[CalipersView alloc] initWithFrame:rect];
    Caliper *c = [[Caliper alloc] initWithDirection:Vertical bar1Position:0 bar2Position:10 crossBarPosition:200];
    Caliper *d = [[Caliper alloc] init];
    view.calipers = [[NSMutableArray alloc] init];
    [view.calipers addObject:c];
    [view.calipers addObject:d];
    [view drawRect:rect];
    XCTAssertTrue(c.direction == Vertical);
    XCTAssertTrue(d.direction == Horizontal);
    XCTAssertEqual([view.calipers count], 2);
    d.marching = YES;
    d.bar1Position = 100;
    d.bar2Position = 150;
    [view drawRect:rect];
    // too narrow to draw marching calipers
    d.bar1Position = 10;
    d.bar2Position = 20;
    [view drawRect:rect];
    XCTAssertTrue(d.marching);
    XCTAssertFalse(c.marching);
    d.chosenComponent = Bar1;
    [view drawRect:rect];
    d.chosenComponent = Bar2;
    [view drawRect:rect];
    d.chosenComponent = Crossbar;
    [view drawRect:rect];
    c.chosenComponent = Bar1;
    [view drawRect:rect];
    c.chosenComponent = Bar2;
    [view drawRect:rect];
    c.chosenComponent = Crossbar;
    [view drawRect:rect];
    c.selected = YES;
    [view drawRect:rect];
    c.selected = NO;
    Calibration *cal = [[Calibration alloc] initWithDirection:Horizontal];
    [d setCalibration:cal];
    d.bar1Position = 0;
    d.bar2Position = 100;
    [view drawRect:rect];
    XCTAssertEqual(d.intervalResult, 100);
    XCTAssertEqualObjects([d measurement], @"100 points");
    // Calibrate and test zooming
    cal.units = @"msec";
    cal.calibrated = YES;
    cal.originalZoom = 1;
    cal.currentZoom = 1;
    cal.originalCalFactor = 1;
    XCTAssertEqualObjects([d measurement], @"100 msec");
    cal.currentZoom = 2;
    XCTAssertEqualObjects([d measurement], @"50 msec");
    cal.currentZoom = 0.5;
    XCTAssertEqualObjects([d measurement], @"200 msec");
    cal.displayRate = YES;
    XCTAssertEqualObjects([d measurement], @"300 bpm");
    XCTAssert(cal.canDisplayRate);
    cal.displayRate = NO;
    cal.units = @"sec";
    cal.currentZoom = 1;
    cal.originalCalFactor = 0.01;
    XCTAssertEqualObjects([d measurement], @"1 sec");
    cal.displayRate = YES;
    XCTAssertEqualObjects([d measurement], @"60 bpm");

    cal.calibrated = NO;
    XCTAssertFalse(cal.canDisplayRate);
    // use all text positions
}

- (void)testTextPosition {
    Caliper *c = [[Caliper alloc] init];
    c.textPosition = CenterAbove;
    CalipersView *view = [[CalipersView alloc] init];
    view.calipers = [[NSMutableArray alloc] init];
    [view.calipers addObject:c];
    CGRect rect = CGRectMake(0, 0, 200, 200);
    [view drawRect:rect];
    c.textPosition = CenterBelow;
    [view drawRect:rect];
    c.textPosition = RightAbove;
    [view drawRect:rect];
    c.textPosition = LeftAbove;
    [view drawRect:rect];
    c.direction = Vertical;
    c.textPosition = Top;
    [view drawRect:rect];
    c.textPosition = Bottom;
    [view drawRect:rect];
    // Start squeezing bars
    c.direction = Horizontal;
    c.textPosition = RightAbove;
    c.bar1Position = 100;
    c.bar2Position = 190;
    [view drawRect:rect];
    c.bar1Position = 100;
    c.bar2Position = 130;
    [view drawRect:rect];
    c.bar1Position = 20;
    c.bar2Position = 180;
    [view drawRect:rect];
    c.textPosition = LeftAbove;
    c.bar1Position = 100;
    c.bar2Position = 190;
    [view drawRect:rect];
    c.bar1Position = 100;
    c.bar2Position = 130;
    [view drawRect:rect];
    c.bar1Position = 20;
    c.bar2Position = 180;
    [view drawRect:rect];
    c.textPosition = CenterBelow;
    c.bar1Position = 100;
    c.bar2Position = 190;
    [view drawRect:rect];
    c.bar1Position = 100;
    c.bar2Position = 130;
    [view drawRect:rect];
    c.bar1Position = 20;
    c.bar2Position = 180;
    [view drawRect:rect];
    c.autoPositionText = NO;
    c.direction = Horizontal;
    c.textPosition = RightAbove;
    c.bar1Position = 100;
    c.bar2Position = 190;
    [view drawRect:rect];
    c.bar1Position = 100;
    c.bar2Position = 130;
    [view drawRect:rect];
    c.bar1Position = 20;
    c.bar2Position = 180;
    [view drawRect:rect];
    c.textPosition = LeftAbove;
    c.bar1Position = 100;
    c.bar2Position = 190;
    [view drawRect:rect];
    c.bar1Position = 100;
    c.bar2Position = 130;
    [view drawRect:rect];
    c.bar1Position = 20;
    c.bar2Position = 180;
    [view drawRect:rect];
    c.textPosition = CenterBelow;
    c.bar1Position = 100;
    c.bar2Position = 190;
    [view drawRect:rect];
    c.bar1Position = 100;
    c.bar2Position = 130;
    [view drawRect:rect];
    c.bar1Position = 20;
    c.bar2Position = 180;
    [view drawRect:rect];
    c.autoPositionText = YES;
    c.direction = Vertical;
    c.textPosition = RightAbove;
    c.bar1Position = 100;
    c.bar2Position = 190;
    [view drawRect:rect];
    c.bar1Position = 100;
    c.bar2Position = 130;
    [view drawRect:rect];
    c.bar1Position = 20;
    c.bar2Position = 180;
    [view drawRect:rect];
    c.textPosition = LeftAbove;
    c.bar1Position = 100;
    c.bar2Position = 190;
    [view drawRect:rect];
    c.bar1Position = 100;
    c.bar2Position = 130;
    [view drawRect:rect];
    c.bar1Position = 20;
    c.bar2Position = 180;
    [view drawRect:rect];
    c.textPosition = CenterBelow;
    c.bar1Position = 100;
    c.bar2Position = 190;
    [view drawRect:rect];
    c.bar1Position = 100;
    c.bar2Position = 130;
    [view drawRect:rect];
    c.bar1Position = 20;
    c.bar2Position = 180;
    [view drawRect:rect];
    c.textPosition = Top;
    c.bar1Position = 100;
    c.bar2Position = 190;
    [view drawRect:rect];
    c.bar1Position = 100;
    c.bar2Position = 130;
    [view drawRect:rect];
    c.bar1Position = 20;
    c.bar2Position = 180;
    [view drawRect:rect];
    c.textPosition = Bottom;
    c.bar1Position = 100;
    c.bar2Position = 190;
    [view drawRect:rect];
    c.bar1Position = 100;
    c.bar2Position = 130;
    [view drawRect:rect];
    c.bar1Position = 20;
    c.bar2Position = 180;
    [view drawRect:rect];




}

@end

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
#import "Version.h"

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
    cal.units = @"миллиметр";
    XCTAssert([cal unitsAreMM]);
    cal.units = @"миллиметра";
    XCTAssert([cal unitsAreMM]);
    cal.units = @"мм";
    XCTAssert([cal unitsAreMM]);

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
@end

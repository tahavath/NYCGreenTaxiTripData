//
//  ModelCoordinatorTests.m
//  NYCGreenTaxiTripData
//
//  Created by KRKT on 13/05/16.
//  Copyright © 2016 tahavath. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ModelCoordinator.h"

@interface ModelCoordinatorTests : XCTestCase

@end

@implementation ModelCoordinatorTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testSharedInstanceIsASingleton {
	id modelCoord1 = [ModelCoordinator sharedInstance];
	id modelCoord2 = [ModelCoordinator sharedInstance];
	
	XCTAssertEqual(modelCoord1, modelCoord2, @"ModelCoordinator should be a singleton!");
}

- (void)testAllocInitWillFail {
	XCTAssertThrows([[ModelCoordinator alloc] init]);
}

- (void)testNewWillFail {
	XCTAssertThrows([ModelCoordinator new]);
}

@end

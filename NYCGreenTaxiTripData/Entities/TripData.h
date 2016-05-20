//
//  TripData.h
//  NYCGreenTaxiTripData
//
//  Created by KRKT on 13/05/16.
//  Copyright © 2016 tahavath. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ParentEntity.h"
#import <MapKit/MapKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TripData : ParentEntity

#pragma mark - MapKit operations helper methods
-(CLLocationCoordinate2D)pickupCoordinate;
-(CLLocationCoordinate2D)dropoffCoordinate;

@end

NS_ASSUME_NONNULL_END

#import "TripData+CoreDataProperties.h"

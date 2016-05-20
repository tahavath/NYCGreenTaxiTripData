//
//  TripPointMapAnnotation.h
//  NYCGreenTaxiTripData
//
//  Created by KRKT on 20/05/16.
//  Copyright © 2016 tahavath. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

typedef enum {
	THVTripPointTypePickup,
	THVTripPointTypeDropoff
} THVTripPointType;

@interface TripPointMapAnnotation : NSObject <MKAnnotation>

- (id)initWithTripPointType:(THVTripPointType)type tripId:(NSString *)tripId coordinate:(CLLocationCoordinate2D)coordinate tripPointDateTime:(NSDate *)tripPointDateTime;

@property (nonatomic) THVTripPointType tripPointType;

@end

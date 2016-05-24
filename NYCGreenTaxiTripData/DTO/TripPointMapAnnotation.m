//
//  TripPointMapAnnotation.m
//  NYCGreenTaxiTripData
//
//  Created by KRKT on 20/05/16.
//  Copyright © 2016 tahavath. All rights reserved.
//

#import "TripPointMapAnnotation.h"

NSString *const THVTripPointTypePickupName = @"Pickup";
NSString *const THVTripPointTypeDropoffName = @"Dropoff";

@interface TripPointMapAnnotation()

@property (nonatomic) CLLocationCoordinate2D coordinate;
@property (nonatomic) NSDate *tripPointDateTime;

@end

@implementation TripPointMapAnnotation

- (id)initWithTripPointType:(THVTripPointType)type tripId:(NSString *)tripId coordinate:(CLLocationCoordinate2D)coordinate tripPointDateTime:(NSDate *)tripPointDateTime {
	self = [super init];
	
	if (self) {
		self.tripPointType = type;
		self.tripId = tripId;
		self.coordinate = coordinate;
		self.tripPointDateTime = tripPointDateTime;
	}
	
	return self;
}

-(BOOL)isEqual:(id)object {
	if (self == object) {
		return YES;
	}
	
	if (object && [object isKindOfClass:[TripPointMapAnnotation class]]) {
		TripPointMapAnnotation *otherObject = object;
		
		if (otherObject.tripPointType == self.tripPointType &&
			[otherObject.tripId isEqualToString:self.tripId]) {
			return YES;
		}
	}
	
	return NO;
}

#pragma mark - MKAnnotation protocol methods
- (NSString *)title {
	
	NSMutableString *titleString = [NSMutableString stringWithFormat:@" (id: %@)", self.tripId];
	
	switch (self.tripPointType) {
		case THVTripPointTypePickup:
			[titleString insertString:@"Pickup" atIndex:0];
			break;
		case THVTripPointTypeDropoff:
			[titleString insertString:@"Dropoff" atIndex:0];
			break;
	}
	
	return titleString;
}

- (NSString *)subtitle {
	return [[[Commons sharedInstance] dateFormatter] stringFromDate:self.tripPointDateTime];
}

- (CLLocationCoordinate2D)coordinate {
	return _coordinate;
}

@end

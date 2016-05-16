//
//  TripData.m
//  NYCGreenTaxiTripData
//
//  Created by KRKT on 13/05/16.
//  Copyright © 2016 tahavath. All rights reserved.
//

#import "TripData.h"

@implementation TripData

+ (NSString *)entityName {
	return @"TripData";
}

+ (NSDictionary *)attributeMappingsDictionary {
	NSMutableDictionary *entityMapping = [NSMutableDictionary dictionaryWithObjectsAndKeys:
										  @"dropoffDateTime", @"lpep_dropoff_datetime",
										  @"dropoffLatitude", @"dropoff_latitude",
										  @"dropoffLongitude", @"dropoff_longitude",
										  @"extra", @"extra",
										  @"fareAmount", @"fare_amount",
										  @"mtaTax", @"mta_tax",
										  @"passengerCount", @"passenger_count",
										  @"paymentType", @"payment_type",
										  @"pickupDateTime", @"lpep_pickup_datetime",
										  @"pickupLatitude", @"pickup_latitude",
										  @"pickupLongitude", @"pickup_longitude",
										  @"tipAmount", @"tip_amount",
										  @"tollsAmount", @"tolls_amount",
										  @"totalAmount", @"total_amount",
										  @"tripDistance", @"trip_distance",
										  nil];
	
	[entityMapping addEntriesFromDictionary:[super attributeMappingsDictionary]];
	
	return entityMapping;
}

+ (NSString *)sortDescriptorName {
	return @"pickupDateTime";
}

@end

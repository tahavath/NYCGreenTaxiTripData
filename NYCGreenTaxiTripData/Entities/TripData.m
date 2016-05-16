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
										  @"lpep_pickup_datetime", @"pickupDateTime",
										  @"total_amount", @"totalAmount",
										  nil];
	
	[entityMapping addEntriesFromDictionary:[super attributeMappingsDictionary]];
	
	return entityMapping;
}

+ (NSString *)sortDescriptorName {
	return @"pickupDateTime";
}

@end

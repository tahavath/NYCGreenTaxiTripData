//
//  TripData+CoreDataProperties.m
//  NYCGreenTaxiTripData
//
//  Created by KRKT on 12/05/16.
//  Copyright © 2016 tahavath. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "TripData+CoreDataProperties.h"

@implementation TripData (CoreDataProperties)

@dynamic pickupDateTime;
@dynamic dropoffDateTime;
@dynamic pickupLatitude;
@dynamic pickupLongitude;
@dynamic dropoffLongitude;
@dynamic dropoffLatitude;
@dynamic passengerCount;
@dynamic tripDistance;
@dynamic fareAmount;
@dynamic extra;
@dynamic mtaTax;
@dynamic tipAmount;
@dynamic tollsAmount;
@dynamic totalAmount;

@end

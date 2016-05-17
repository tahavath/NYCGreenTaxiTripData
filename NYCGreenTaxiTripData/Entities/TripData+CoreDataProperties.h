//
//  TripData+CoreDataProperties.h
//  NYCGreenTaxiTripData
//
//  Created by KRKT on 17/05/16.
//  Copyright © 2016 tahavath. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "TripData.h"

NS_ASSUME_NONNULL_BEGIN

@interface TripData (CoreDataProperties)

@property (nullable, nonatomic, retain) NSDate *dropoffDateTime;
@property (nullable, nonatomic, retain) NSNumber *dropoffLatitude;
@property (nullable, nonatomic, retain) NSNumber *dropoffLongitude;
@property (nullable, nonatomic, retain) NSNumber *extra;
@property (nullable, nonatomic, retain) NSNumber *fareAmount;
@property (nullable, nonatomic, retain) NSNumber *mtaTax;
@property (nullable, nonatomic, retain) NSNumber *passengerCount;
@property (nullable, nonatomic, retain) NSNumber *paymentType;
@property (nullable, nonatomic, retain) NSDate *pickupDateTime;
@property (nullable, nonatomic, retain) NSNumber *pickupLatitude;
@property (nullable, nonatomic, retain) NSNumber *pickupLongitude;
@property (nullable, nonatomic, retain) NSNumber *tipAmount;
@property (nullable, nonatomic, retain) NSNumber *tollsAmount;
@property (nullable, nonatomic, retain) NSNumber *totalAmount;
@property (nullable, nonatomic, retain) NSNumber *tripDistance;
@property (nullable, nonatomic, retain) NSString *month;

@end

NS_ASSUME_NONNULL_END

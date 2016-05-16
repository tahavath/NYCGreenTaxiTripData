//
//  ParentEntity+CoreDataProperties.h
//  NYCGreenTaxiTripData
//
//  Created by KRKT on 13/05/16.
//  Copyright © 2016 tahavath. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "ParentEntity.h"

NS_ASSUME_NONNULL_BEGIN

@interface ParentEntity (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *dataYear;
@property (nullable, nonatomic, retain) NSDate *createdAt;
@property (nullable, nonatomic, retain) NSString *entityId;
@property (nullable, nonatomic, retain) NSDate *updatedAt;
@property (nullable, nonatomic, retain) NSString *version;

@end

NS_ASSUME_NONNULL_END

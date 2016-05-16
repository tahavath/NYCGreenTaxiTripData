//
//  ParentEntity.h
//  NYCGreenTaxiTripData
//
//  Created by KRKT on 13/05/16.
//  Copyright © 2016 tahavath. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

@interface ParentEntity : NSManagedObject

+ (NSString *)entityName;
+ (NSDictionary *)attributeMappingsDictionary;
+ (NSString *)sortDescriptorName;
+ (BOOL)sortAscending;
+ (NSArray *)identificationAttributes;

@end

NS_ASSUME_NONNULL_END

#import "ParentEntity+CoreDataProperties.h"

//
//  ParentEntity.h
//  NYCGreenTaxiTripData
//
//  Created by KRKT on 13/05/16.
//  Copyright © 2016 tahavath. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <RestKit/RestKit.h>
#import <RestKit/ObjectMapping.h>

NS_ASSUME_NONNULL_BEGIN

@interface ParentEntity : NSManagedObject

+ (NSString *)entityName;

+ (NSString *)sortDescriptorName;
+ (BOOL)sortAscending;

+ (RKResponseDescriptor *)responseDescriptorInObjectStore:(RKManagedObjectStore *)objectStore;

+ (NSDictionary *)attributeMappingsDictionary;
+ (NSArray *)identificationAttributes;

@end

NS_ASSUME_NONNULL_END

#import "ParentEntity+CoreDataProperties.h"

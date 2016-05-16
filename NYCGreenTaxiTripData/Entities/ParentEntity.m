//
//  ParentEntity.m
//  NYCGreenTaxiTripData
//
//  Created by KRKT on 13/05/16.
//  Copyright © 2016 tahavath. All rights reserved.
//

#import "ParentEntity.h"

@implementation ParentEntity

+ (NSString *)entityName {
	return @"ParentEntity";
}

+ (NSDictionary *)attributeMappingsDictionary {
	//@":created_at": @"createdAt",
	return [NSDictionary dictionary];
}

+ (NSString *)sortDescriptorName {
	return @"entityId";
}

+ (BOOL)sortAscending {
	return YES;
}

@end

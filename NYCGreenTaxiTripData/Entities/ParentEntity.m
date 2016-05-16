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
	return [NSDictionary dictionaryWithObjectsAndKeys:
			@"createdAt", @":created_at",
			@"entityId", @":id",
			@"updatedAt", @":updated_at",
			@"version", @":version",
			nil];
}

+ (NSString *)sortDescriptorName {
	return @"entityId";
}

+ (BOOL)sortAscending {
	return YES;
}

+ (NSArray *)identificationAttributes {
	return @[@"entityId"];
}

@end

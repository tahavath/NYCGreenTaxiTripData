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

+ (NSString *)sortDescriptorName {
	return @"entityId";
}

+ (BOOL)sortAscending {
	return YES;
}

+ (RKResponseDescriptor *)responseDescriptorInObjectStore:(RKManagedObjectStore *)objectStore {
	RKEntityMapping *entityMapping = [RKEntityMapping mappingForEntityForName:[[self class] entityName] inManagedObjectStore:objectStore];
	[entityMapping addAttributeMappingsFromDictionary:[[self class] attributeMappingsDictionary]];
	entityMapping.identificationAttributes = [[self class] identificationAttributes];
	
	RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor
												responseDescriptorWithMapping:entityMapping
												method:RKRequestMethodGET
												pathPattern:nil
												keyPath:nil
												statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
	

	
	return responseDescriptor;
}

+ (NSDictionary *)attributeMappingsDictionary {
	return [NSDictionary dictionaryWithObjectsAndKeys:
			@"createdAt", @":created_at",
			@"entityId", @":id",
			@"updatedAt", @":updated_at",
			@"version", @":version",
			nil];
}

+ (NSArray *)identificationAttributes {
	return @[@"entityId"];
}

@end

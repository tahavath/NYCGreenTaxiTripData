//
//  DownloadCoordinator.m
//  NYCGreenTaxiTripData
//
//  Created by KRKT on 16/05/16.
//  Copyright © 2016 tahavath. All rights reserved.
//

#import "DownloadCoordinator.h"
#import "ModelCoordinator.h"
#import "TripData.h"

@interface DownloadCoordinator ()

@property (nonatomic) id<RKManagedObjectCaching> objectCache;

@end

@implementation DownloadCoordinator

#pragma mark - DownloadCoordinatorProtocol methods
+ (id<DownloadCoordinatorProtocol>)sharedInstance {
	static DownloadCoordinator *downloadCoordinatorSharedInstance = nil;
	static dispatch_once_t onceToken;
	
	dispatch_once(&onceToken, ^{
		downloadCoordinatorSharedInstance = [[DownloadCoordinator alloc] initForSharedInstance];
	});
	
	return downloadCoordinatorSharedInstance;
}

- (void)downloadNextItems:(NSUInteger)amount {
	NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://data.cityofnewyork.us/resource/h4pe-ymjc.json?$select=:*,*&$limit=100&$offset=0"]];
	RKManagedObjectRequestOperation *op = [[RKManagedObjectRequestOperation alloc] initWithRequest:request responseDescriptors:@[[[ModelCoordinator sharedInstance] getDescriptorForEntity:[TripData entityName]]]];
	[op setManagedObjectCache:self.objectCache];
	op.managedObjectContext = [[ModelCoordinator sharedInstance] mainQueueContext];
	[[NSOperationQueue currentQueue] addOperation:op];
}

#pragma mark - init methods

- (instancetype)init {
	NSAssert(false, @"%@ is a singleton - use %@", NSStringFromClass([DownloadCoordinator class]), NSStringFromSelector(@selector(sharedInstance)));
	
	return nil;
}

- (instancetype)initForSharedInstance {
	self = [super init];
	
	if (self) {
		
	}
	
	return self;
}

#pragma mark - properties lazy initializators
- (id<RKManagedObjectCaching>)objectCache {
	if (!_objectCache) {
		_objectCache = [RKFetchRequestManagedObjectCache new];
	}
	
	return _objectCache;
}

@end

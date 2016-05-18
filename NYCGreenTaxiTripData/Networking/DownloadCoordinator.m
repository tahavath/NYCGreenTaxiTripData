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


#pragma mark - inner class
@interface OverallTripsCount : NSObject
@property (nonatomic) NSUInteger count;
@end

@implementation OverallTripsCount
@end

#pragma mark - DownloadCoordinator class implementation
@interface DownloadCoordinator ()

@property (nonatomic) id<RKManagedObjectCaching> objectCache;

@property (nonatomic, getter=isDownloadPaused) BOOL downloadPaused;

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

- (void)checkOverallTripsCount {
	NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:THVCheckOverallTripsCountURLString]];
	
	RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[OverallTripsCount class]];
	[mapping addAttributeMappingsFromDictionary:@{@"count" : @"count"}];
	
	RKResponseDescriptor *descriptor = [RKResponseDescriptor
										responseDescriptorWithMapping:mapping
										method:RKRequestMethodGET
										pathPattern:nil
										keyPath:nil
										statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
	
	RKObjectRequestOperation *op = [[RKObjectRequestOperation alloc] initWithRequest:request responseDescriptors:@[descriptor]];
	
	[op setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
		OverallTripsCount *tripsCount = [mappingResult firstObject];
		[Commons writeValue:[NSNumber numberWithUnsignedInteger:tripsCount.count] toUserDefaultsForKey:THVUserDefaultsOverallTripsCountKey];
		[[NSNotificationCenter defaultCenter] postNotificationName:THVNotificationNameOverallTripsChecked object:nil];
	} failure:^(RKObjectRequestOperation *operation, NSError *error) {
		NSLog(@"Could not retrieve overall trips count!");
	}];
	
	[[NSOperationQueue currentQueue] addOperation:op];
}

- (void)downloadTrips {
	
	_downloadPaused = NO;
	
	NSUInteger __block offset = 0;
	id storedOffset = [Commons readValueFromUserDefaultsForKey:THVUserDefaultsDownloadOffsetKey];
	if (storedOffset) {
		offset = [storedOffset unsignedIntegerValue];
	}
	
	NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:THVDownloadURLStringWithFormat, THVDefaultDownloadStep, offset]]];
	
	RKManagedObjectRequestOperation *op = [[RKManagedObjectRequestOperation alloc]
										   initWithRequest:request
										   responseDescriptors:@[[[ModelCoordinator sharedInstance] getDescriptorForEntity:[TripData entityName]]]];
	[op setManagedObjectCache:self.objectCache];
	op.managedObjectContext = [[ModelCoordinator sharedInstance] mainQueueContext];
	
	[op setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
		NSUInteger currentOffset = offset + THVDefaultDownloadStep;
		[Commons writeValue:[NSNumber numberWithUnsignedInteger:currentOffset] toUserDefaultsForKey:THVUserDefaultsDownloadOffsetKey];
		[[NSNotificationCenter defaultCenter] postNotificationName:THVNotificationNameTripsOffsetChanged object:nil];
		NSLog(@"Trips downloaded\n\toffset = %lu", offset);
		
		for (TripData *trip in mappingResult.array) {
			trip.month = [[[Commons sharedInstance] monthFormatterForStoringAndSorting] stringFromDate:trip.pickupDateTime];
		}
		NSError *error = nil;
		[[[ModelCoordinator sharedInstance] mainQueueContext] saveToPersistentStore:&error];
		if (error) {
			NSLog(@"Error while saving to persistent store:\n%@\n%@", error.localizedDescription, error.userInfo);
		}
		
		if (![[DownloadCoordinator sharedInstance] isDownloadPaused]) {
			[[DownloadCoordinator sharedInstance] downloadTrips];
		}
	} failure:^(RKObjectRequestOperation *operation, NSError *error) {
		NSLog(@"Downloading of trips not successfull!\n\toffset = %lu", offset);
		[[DownloadCoordinator sharedInstance] pauseDownload];
	}];
	
	[[NSOperationQueue currentQueue] addOperation:op];
}

- (BOOL)isDownloadPaused {
	return _downloadPaused;
}

- (void)pauseDownload {
	_downloadPaused = YES;
}

#pragma mark - init methods

- (instancetype)init {
	NSAssert(false, @"%@ is a singleton - use %@", NSStringFromClass([DownloadCoordinator class]), NSStringFromSelector(@selector(sharedInstance)));
	
	return nil;
}

- (instancetype)initForSharedInstance {
	self = [super init];
	
	if (self) {
		_downloadPaused = YES;
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

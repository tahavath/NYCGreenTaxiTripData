//
//  ModelCoordinator.m
//  NYCGreenTaxiTripData
//
//  Created by KRKT on 13/05/16.
//  Copyright © 2016 tahavath. All rights reserved.
//

#import "ModelCoordinator.h"

@class RKObjectManager;

@interface ModelCoordinator ()

@property (nonatomic) NSManagedObjectModel *managedObjectModel;
@property (nonatomic) RKManagedObjectStore *managedObjectStore;
@property (nonatomic) NSPersistentStore *persistentStore;
@property (nonatomic) NSManagedObjectContext *persistentStoreMOC;
@property (nonatomic) NSManagedObjectContext *mainQueueMOC;

@end

@implementation ModelCoordinator

+ (id<ModelCoordinatorProtocol>)sharedInstance {
	static ModelCoordinator *modelCoordinatorSharedInstance = nil;
	static dispatch_once_t onceToken;
	
	dispatch_once(&onceToken, ^{
		modelCoordinatorSharedInstance = [[ModelCoordinator alloc] initForSharedInstance];
	});
	
	return modelCoordinatorSharedInstance;
}

#pragma mark - init methods
- (instancetype)init {
	NSAssert(false, @"%@ is a singleton - use %@", NSStringFromClass([ModelCoordinator class]), NSStringFromSelector(@selector(sharedInstance)));
	
	return nil;
}

- (instancetype)initForSharedInstance {
	self = [super init];
	
	if (self) {
		// setup core data stack with restkit
		
		// 1 create object model basing
		NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"NYCGreenTaxiTripData" withExtension:@"momd"];
		_managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
		
		// 2 create RKManagedObjectStore using model
		_managedObjectStore = [[RKManagedObjectStore alloc] initWithManagedObjectModel:_managedObjectModel];
		
		// 3 create SQLite persistent store
		NSError *error = nil;
		BOOL success = RKEnsureDirectoryExistsAtPath(RKApplicationDataDirectory(), &error);
		if (! success) {
			RKLogError(@"Failed to create Application Data Directory at path '%@': %@", RKApplicationDataDirectory(), error);
		}
		NSString *path = [RKApplicationDataDirectory() stringByAppendingPathComponent:@"NYCGreenTaxiTripDataStore.sqlite"];
		_persistentStore = [_managedObjectStore addSQLitePersistentStoreAtPath:path fromSeedDatabaseAtPath:nil withConfiguration:nil options:nil error:&error];
		if (! _persistentStore) {
			RKLogError(@"Failed adding persistent store at path '%@': %@", path, error);
		}
		
		// 4 create managed object contexts and assaign them to class properties
		[_managedObjectStore createManagedObjectContexts];
		_persistentStoreMOC = [_managedObjectStore persistentStoreManagedObjectContext];
		_mainQueueMOC = [_managedObjectStore mainQueueManagedObjectContext];
	}
	
	return self;
}

@end

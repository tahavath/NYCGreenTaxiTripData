//
//  ModelCoordinator.m
//  NYCGreenTaxiTripData
//
//  Created by KRKT on 13/05/16.
//  Copyright © 2016 tahavath. All rights reserved.
//

#import "ModelCoordinator.h"
#import "TripData.h"

@interface ModelCoordinator ()

@property (nonatomic) NSManagedObjectModel *managedObjectModel;
@property (nonatomic) RKManagedObjectStore *managedObjectStore;
@property (nonatomic) NSPersistentStore *persistentStore;
@property (nonatomic) NSManagedObjectContext *persistentStoreMOC;
@property (nonatomic) NSManagedObjectContext *mainQueueMOC;
@property (nonatomic) NSMutableDictionary *descriptorsDictionary;

@end

@implementation ModelCoordinator

#pragma mark - ModelCoordinatorProtocol methods
+ (id<ModelCoordinatorProtocol>)sharedInstance {
	static ModelCoordinator *modelCoordinatorSharedInstance = nil;
	static dispatch_once_t onceToken;
	
	dispatch_once(&onceToken, ^{
		modelCoordinatorSharedInstance = [[ModelCoordinator alloc] initForSharedInstance];
	});
	
	return modelCoordinatorSharedInstance;
}

- (NSManagedObjectContext *)mainQueueContext {
	return self.mainQueueMOC;
}

- (NSManagedObjectContext *)persistentStoreContext {
	return self.persistentStoreMOC;
}

- (RKResponseDescriptor *)getDescriptorForEntity:(NSString *)entityName {
	return [self.descriptorsDictionary objectForKey:entityName];
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
		
		// 3 create persistent store coordinator
		[_managedObjectStore createPersistentStoreCoordinator];
		
		// 4 create SQLite persistent store
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
		
		// 5 create managed object contexts and assaign them to class properties
		[_managedObjectStore createManagedObjectContexts];
		_persistentStoreMOC = [_managedObjectStore persistentStoreManagedObjectContext];
		_mainQueueMOC = [_managedObjectStore mainQueueManagedObjectContext];
		
		// 6 set default object store for rest kit
		[RKManagedObjectStore setDefaultStore:_managedObjectStore];
	}
	
	return self;
}

#pragma mark - properties lazy initializers
- (NSMutableDictionary *)descriptorsDictionary {
	if (!_descriptorsDictionary) {
		_descriptorsDictionary = [NSMutableDictionary dictionary];
		
		[_descriptorsDictionary setObject:[TripData responseDescriptorInObjectStore:self.managedObjectStore] forKey:[TripData entityName]];
	}
	
	return _descriptorsDictionary;
}

@end

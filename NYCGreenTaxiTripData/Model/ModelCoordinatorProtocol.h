//
//  ModelCoordinatorProtocol.h
//  NYCGreenTaxiTripData
//
//  Created by KRKT on 13/05/16.
//  Copyright © 2016 tahavath. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RestKit/RestKit.h>

@protocol ModelCoordinatorProtocol <NSObject>

+ (id<ModelCoordinatorProtocol>)sharedInstance;

- (NSManagedObjectContext *)mainQueueContext;
- (NSManagedObjectContext *)persistentStoreContext;

- (RKResponseDescriptor *)getDescriptorForEntity:(NSString *)entityName;

@end

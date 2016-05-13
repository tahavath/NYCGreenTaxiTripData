//
//  ModelCoordinatorProtocol.h
//  NYCGreenTaxiTripData
//
//  Created by KRKT on 13/05/16.
//  Copyright © 2016 tahavath. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ModelCoordinatorProtocol <NSObject>

+ (id<ModelCoordinatorProtocol>)sharedInstance;

@end

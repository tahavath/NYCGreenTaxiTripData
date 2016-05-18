//
//  DownloadCoordinatorProtocol.h
//  NYCGreenTaxiTripData
//
//  Created by KRKT on 16/05/16.
//  Copyright © 2016 tahavath. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import <RestKit/Network.h>

@protocol DownloadCoordinatorProtocol <NSObject>

+ (id<DownloadCoordinatorProtocol>)sharedInstance;

- (void)checkOverallTripsCount;

- (void)downloadTrips;

- (BOOL)isDownloadPaused;
- (void)pauseDownload;

@end

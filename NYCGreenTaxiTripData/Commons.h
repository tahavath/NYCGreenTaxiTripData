//
//  Commons.h
//  NYCGreenTaxiTripData
//
//  Created by KRKT on 16/05/16.
//  Copyright © 2016 tahavath. All rights reserved.
//

extern NSString *const THVUserDefaultsDownloadOffsetKey;
extern NSString *const THVUserDefaultsOverallTripsCountKey;

extern NSUInteger const THVDefaultDownloadStep;
extern NSString *const THVDownloadURLStringWithFormat;


@interface Commons : NSObject

+ (id)readValueFromUserDefaultsForKey:(NSString *)key;
+ (void)writeValue:(id)value toUserDefaultsForKey:(NSString *)key;

@end
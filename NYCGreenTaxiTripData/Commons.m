//
//  Commons.m
//  NYCGreenTaxiTripData
//
//  Created by KRKT on 16/05/16.
//  Copyright © 2016 tahavath. All rights reserved.
//

NSString *const THVUserDefaultsDownloadOffsetKey = @"downloadOffset";
NSString *const THVUserDefaultsOverallTripsCountKey = @"overallTripsCount";

NSUInteger const THVDefaultDownloadStep = 100;
NSString *const THVDownloadURLStringWithFormat = @"https://data.cityofnewyork.us/resource/h4pe-ymjc.json?$select=:*,*&$limit=%lu&$offset=%lu";

double const THVNewYorkLatitude = 40.7128;
double const THVNewYorkLongitude = -74.0059;

@implementation Commons

+ (id)readValueFromUserDefaultsForKey:(NSString *)key {
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	return [userDefaults valueForKey:key];
}

+ (void)writeValue:(id)value toUserDefaultsForKey:(NSString *)key {
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	[userDefaults setObject:value forKey:key];
	if (![userDefaults synchronize]) {
		NSLog(@"Writing to user defaults not succeeded!\nvkey = %@\nvalue = %@", key, value);
	}
}

@end
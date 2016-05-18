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
NSString *const THVCheckOverallTripsCountURLString = @"https://data.cityofnewyork.us/resource/h4pe-ymjc.json?$select=count(*)";
NSString *const THVDownloadURLStringWithFormat = @"https://data.cityofnewyork.us/resource/h4pe-ymjc.json?$select=:*,*&$limit=%lu&$offset=%lu";

double const THVNewYorkLatitude = 40.7128;
double const THVNewYorkLongitude = -74.0059;

NSString *const THVDateFormat = @"yyyy-MM-dd HH:mm:ss";
NSString *const THVMonthFormatForStoringAndSorting = @"yyyyMM";
NSString *const THVMonthFormatForSectionHeaders = @"MMMM yyyy";
NSString *const THVMonthFormatForSectionIndexTitles = @"MMMyy";

NSString *const THVNotificationNameOverallTripsChecked = @"THVNotificationNameOverallTripsChecked";
NSString *const THVNotificationNameTripsOffsetChanged = @"THVNotificationNameTripsOffsetChanged";

NSString *const THVLabelNoTripsToShow = @"There are no trips to show.\n\nPlease download data first.";


@interface Commons ()

@property (nonatomic) NSDateFormatter *dateFormatter;
@property (nonatomic) NSDateFormatter *monthFormatterForStoringAndSorting;
@property (nonatomic) NSDateFormatter *monthFormatterForSections;
@property (nonatomic) NSDateFormatter *monthFormatterForSectionsIndexTitles;

@end

@implementation Commons

+ (instancetype)sharedInstance {
	static Commons *sharedCommons = nil;
	static dispatch_once_t onceToken;
	
	dispatch_once(&onceToken, ^{
		sharedCommons = [[Commons alloc] initForSharedInstance];
	});
	
	return sharedCommons;
}

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

- (NSDateFormatter *)dateFormatter {
	if (!_dateFormatter) {
		_dateFormatter = [[NSDateFormatter alloc] init];
		[_dateFormatter setDateFormat:THVDateFormat];
	}
	
	return _dateFormatter;
}

- (NSDateFormatter *)monthFormatterForStoringAndSorting {
	if (!_monthFormatterForStoringAndSorting) {
		_monthFormatterForStoringAndSorting = [[NSDateFormatter alloc] init];
		[_monthFormatterForStoringAndSorting setDateFormat:THVMonthFormatForStoringAndSorting];
	}
	
	return _monthFormatterForStoringAndSorting;
}

- (NSDateFormatter *)monthFormatterForSectionHeaders {
	if (!_monthFormatterForSections) {
		_monthFormatterForSections = [[NSDateFormatter alloc] init];
		[_monthFormatterForSections setDateFormat:THVMonthFormatForSectionHeaders];
	}
	
	return _monthFormatterForSections;
}

- (NSDateFormatter *)monthFormatterForSectionsIndexTitles {
	if (!_monthFormatterForSectionsIndexTitles) {
		_monthFormatterForSectionsIndexTitles = [[NSDateFormatter alloc] init];
		[_monthFormatterForSectionsIndexTitles setDateFormat:THVMonthFormatForSectionIndexTitles];
	}
	
	return _monthFormatterForSectionsIndexTitles;
}

#pragma mark - init methods
- (id)initForSharedInstance {
	return [super init];
}

- (id)init {
	NSAssert(false, @"%@ is a singleton - use %@", NSStringFromClass([Commons class]), NSStringFromSelector(@selector(sharedInstance)));
	return nil;
}

@end
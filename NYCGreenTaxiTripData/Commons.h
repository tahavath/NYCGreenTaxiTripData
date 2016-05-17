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

extern double const THVNewYorkLatitude;
extern double const THVNewYorkLongitude;

extern NSString *const THVDateFormat;
extern NSString *const THVMonthFormatForStoringAndSorting;
extern NSString *const THVMonthFormatForSectionHeaders;
extern NSString *const THVMonthFormatForSectionIndexTitles;


@interface Commons : NSObject

+ (instancetype)sharedInstance;

+ (id)readValueFromUserDefaultsForKey:(NSString *)key;
+ (void)writeValue:(id)value toUserDefaultsForKey:(NSString *)key;

- (NSDateFormatter *)dateFormatter;
- (NSDateFormatter *)monthFormatterForStoringAndSorting;
- (NSDateFormatter *)monthFormatterForSectionHeaders;
- (NSDateFormatter *)monthFormatterForSectionsIndexTitles;

@end
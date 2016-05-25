//
//  Commons.h
//  NYCGreenTaxiTripData
//
//  Created by KRKT on 16/05/16.
//  Copyright © 2016 tahavath. All rights reserved.
//

#import "TripData.h"

extern NSString *const THVUserDefaultsDownloadOffsetKey;
extern NSString *const THVUserDefaultsOverallTripsCountKey;

extern NSUInteger const THVDefaultDownloadStep;
extern NSString *const THVCheckOverallTripsCountURLString;
extern NSString *const THVDownloadURLStringWithFormat;

extern double const THVNewYorkLatitude;
extern double const THVNewYorkLongitude;

extern NSString *const THVDateFormat;
extern NSString *const THVMonthFormatForStoringAndSorting;
extern NSString *const THVMonthFormatForSectionHeaders;
extern NSString *const THVMonthFormatForSectionIndexTitles;

extern NSString *const THVNotificationNameOverallTripsChecked;
extern NSString *const THVNotificationNameTripsOffsetChanged;

extern NSString *const THVLabelNoTripsToShow;

extern double const THVPinScaleWhenSelected;
extern double const THVPinScaleNormal;

@interface Commons : NSObject

+ (instancetype)sharedInstance;

+ (id)readValueFromUserDefaultsForKey:(NSString *)key;
+ (void)writeValue:(id)value toUserDefaultsForKey:(NSString *)key;

+ (TripData *)selectedTrip;
+ (TripData *)previouslySelectedTrip;
+ (NSArray *)tripRoutes;
+ (void)setSelectedTrip:(TripData *)trip;
+ (void)setPreviouslySelectedTrip:(TripData *)previousTrip;
+ (void)setTripRoutes:(NSArray *)routes;

- (NSDateFormatter *)dateFormatter;
- (NSDateFormatter *)monthFormatterForStoringAndSorting;
- (NSDateFormatter *)monthFormatterForSectionHeaders;
- (NSDateFormatter *)monthFormatterForSectionsIndexTitles;

@end
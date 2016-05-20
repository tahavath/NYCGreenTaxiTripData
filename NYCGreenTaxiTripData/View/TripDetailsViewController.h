//
//  TripDetailsViewController.h
//  NYCGreenTaxiTripData
//
//  Created by KRKT on 20/05/16.
//  Copyright © 2016 tahavath. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface TripDetailsViewController : UIViewController

@property (nonatomic) CLLocationDegrees pickupLatitude;
@property (nonatomic) CLLocationDegrees pickupLongitude;

@property (nonatomic) CLLocationDegrees dropoffLatitude;
@property (nonatomic) CLLocationDegrees dropoffLongitude;

@property (nonatomic) float tripDistance;

@end

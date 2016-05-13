//
//  MainViewController.h
//  NYCGreenTaxiTripData
//
//  Created by KRKT on 12/05/16.
//  Copyright © 2016 tahavath. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

extern double const THVStartingRegionDistance;

@interface MainViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *downloadPercentBarButtonItem;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@end

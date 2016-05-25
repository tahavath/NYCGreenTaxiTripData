//
//  TripDetailsViewController.h
//  NYCGreenTaxiTripData
//
//  Created by KRKT on 20/05/16.
//  Copyright © 2016 tahavath. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "TripData.h"

@interface TripDetailsViewController : UIViewController

@property (nonatomic) TripData *selectedTripEntity;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@end

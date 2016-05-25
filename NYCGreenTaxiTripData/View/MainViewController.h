//
//  MainViewController.h
//  NYCGreenTaxiTripData
//
//  Created by KRKT on 12/05/16.
//  Copyright © 2016 tahavath. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "TripData.h"
#import "MainScreenTripDetailsDelegateProtocol.h"

extern double const THVStartingRegionDistance;

@interface MainViewController : UIViewController <NSFetchedResultsControllerDelegate, MKMapViewDelegate, MainScreenTripDetailsDelegateProtocol>

@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *tripsBarButton;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIView *tripDetailsView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tripDetailsHeightConstraint;

@end

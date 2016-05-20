//
//  TripDetailsViewController.m
//  NYCGreenTaxiTripData
//
//  Created by KRKT on 20/05/16.
//  Copyright © 2016 tahavath. All rights reserved.
//

#import "TripDetailsViewController.h"

@interface TripDetailsViewController ()

@property (nonatomic) CLLocationCoordinate2D pickupCoordinate;
@property (nonatomic) CLLocationCoordinate2D dropoffCoordinate;

@end

@implementation TripDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - properties lazy initializations
- (CLLocationCoordinate2D)pickupCoordinate {
	if (!_pickupCoordinate.latitude && !_pickupCoordinate.longitude) {
		_pickupCoordinate = CLLocationCoordinate2DMake(self.pickupLatitude, self.pickupLongitude);
	}
	
	return _pickupCoordinate;
}

- (CLLocationCoordinate2D)dropoffCoordinate {
	if (!_dropoffCoordinate.latitude && !_dropoffCoordinate.longitude) {
		_dropoffCoordinate = CLLocationCoordinate2DMake(self.dropoffLatitude, self.dropoffLongitude);
	}
	
	return _dropoffCoordinate;
}

@end

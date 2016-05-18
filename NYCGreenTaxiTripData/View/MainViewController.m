//
//  MainViewController.m
//  NYCGreenTaxiTripData
//
//  Created by KRKT on 12/05/16.
//  Copyright © 2016 tahavath. All rights reserved.
//

#import "MainViewController.h"

double const THVStartingRegionDistance = 2000.0;

@interface MainViewController()

@end

@implementation MainViewController

- (void)viewDidLoad {
	CLLocationCoordinate2D startingCoord = CLLocationCoordinate2DMake(THVNewYorkLatitude, THVNewYorkLongitude);
	MKCoordinateRegion startingRegion = MKCoordinateRegionMakeWithDistance(startingCoord, THVStartingRegionDistance, THVStartingRegionDistance);
	
	if (![Commons readValueFromUserDefaultsForKey:THVUserDefaultsDownloadOffsetKey]) {
		UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:THVLabelNoTripsToShow preferredStyle:UIAlertControllerStyleAlert];
		UIAlertAction *defaultAction = [UIAlertAction
										actionWithTitle:@"OK"
										style:UIAlertActionStyleDefault
										handler:^(UIAlertAction *action) {
											[self performSegueWithIdentifier:@"showTripsTable" sender:self];
										}];
		
		[alert addAction:defaultAction];
		
		[self presentViewController:alert animated:YES completion:nil];
	}
	
	[self.mapView setRegion:startingRegion];
}

@end

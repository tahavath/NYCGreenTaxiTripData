//
//  TripDetailsViewController.m
//  NYCGreenTaxiTripData
//
//  Created by KRKT on 20/05/16.
//  Copyright © 2016 tahavath. All rights reserved.
//

#import "TripDetailsViewController.h"
#import "TripPointMapAnnotation.h"

@interface TripDetailsViewController ()

@end

@implementation TripDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	
	[self setupMapView];
}

- (void)viewDidLayoutSubviews {
	TripPointMapAnnotation *pickupAnnotation = [[TripPointMapAnnotation alloc] initWithTripPointType:THVTripPointTypePickup
																							  tripId:self.selectedTripEntity.entityId
																						  coordinate:self.selectedTripEntity.pickupCoordinate
																				   tripPointDateTime:self.selectedTripEntity.pickupDateTime];
	TripPointMapAnnotation *dropoffAnnotation = [[TripPointMapAnnotation alloc] initWithTripPointType:THVTripPointTypePickup
																							   tripId:self.selectedTripEntity.entityId
																						   coordinate:self.selectedTripEntity.dropoffCoordinate
																					tripPointDateTime:self.selectedTripEntity.dropoffDateTime];
	NSArray *annotations = @[pickupAnnotation, dropoffAnnotation];
	[self.mapView addAnnotations:annotations];
	[self.mapView showAnnotations:[self.mapView annotations] animated:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - helper methods
- (void)setupMapView {
}

@end

//
//  TripDetailsViewController.m
//  NYCGreenTaxiTripData
//
//  Created by KRKT on 20/05/16.
//  Copyright © 2016 tahavath. All rights reserved.
//

#import "TripDetailsViewController.h"
#import "TripPointMapAnnotation.h"

@interface TripDetailsViewController () {
	MKDirections *_directions;
}

@end

@implementation TripDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	
	[self setupMapView];
}

- (void)viewDidLayoutSubviews {
	NSLog(@"viewDidLayoutSubviews");
	if (!_directions) {
		[self.mapView tda_showRouteWithAnnotation:self.mapView.annotations.firstObject directions:&_directions];
	}
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - MKMapViewDelegate methods
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
	return [mapView tda_viewForAnnotation:annotation];
}

#pragma mark - MKPolyline delegate functions
- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {
	return [mapView tda_rendererForOverlay:overlay];
}

#pragma mark - helper methods
- (void)setupMapView {
	[self.mapView addAnnotationsAndReturnPickupWithTripId:self.selectedTripEntity.entityId pickupCoordinate:self.selectedTripEntity.pickupCoordinate pickupDateTime:self.selectedTripEntity.pickupDateTime dropoffCoordinate:self.selectedTripEntity.dropoffCoordinate dropoffDateTime:self.selectedTripEntity.dropoffDateTime];
}

@end

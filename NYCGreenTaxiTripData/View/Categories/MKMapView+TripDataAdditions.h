//
//  MKMapView+TripDataAdditions.h
//  NYCGreenTaxiTripData
//
//  Created by KRKT on 25/05/16.
//  Copyright © 2016 tahavath. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "TripPointMapAnnotation.h"

@interface MKMapView (TripDataAdditions)

#pragma mark - MKMapViewDelegate methods
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
;

#pragma mark MKPolyline delegate functions
- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay;

#pragma mark - MapView operating helper methods
- (void)zoomMap:(MKMapView *)mapView toSeeRoutes:(NSArray<MKRoute *> *)routes;
- (void)zoomMap:(MKMapView *)mapView toSeePickupCoordinate:(CLLocationCoordinate2D)pickupCoordinate dropoffCoordinate:(CLLocationCoordinate2D)dropoffCoordinate;
- (void)showRouteInMap:(MKMapView *)mapView withAnnotation:(TripPointMapAnnotation *)annotation directions:(MKDirections * __strong *)directions;

@end

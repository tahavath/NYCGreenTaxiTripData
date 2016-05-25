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
- (MKAnnotationView *)tda_viewForAnnotation:(id<MKAnnotation>)annotation
;

#pragma mark MKPolyline delegate functions
- (MKOverlayRenderer *)tda_rendererForOverlay:(id<MKOverlay>)overlay;

#pragma mark - MapView operating helper methods
- (void)tda_zoomToSeeRoutes:(NSArray<MKRoute *> *)routes;
- (void)tda_zoomToSeePickupCoordinate:(CLLocationCoordinate2D)pickupCoordinate dropoffCoordinate:(CLLocationCoordinate2D)dropoffCoordinate;
- (void)tda_showRouteWithAnnotation:(TripPointMapAnnotation *)annotation directions:(MKDirections * __strong *)directions;

@end

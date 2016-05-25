//
//  MKMapView+TripDataAdditions.m
//  NYCGreenTaxiTripData
//
//  Created by KRKT on 25/05/16.
//  Copyright © 2016 tahavath. All rights reserved.
//

#import "MKMapView+TripDataAdditions.h"

@implementation MKMapView (TripDataAdditions)

#pragma mark - MKMapViewDelegate methods
- (MKAnnotationView *)tda_viewForAnnotation:(id<MKAnnotation>)annotation {
	static NSString *identifier = @"TripPoinIdentifier";
	
	if ([annotation isKindOfClass:[TripPointMapAnnotation class]]) {
		MKPinAnnotationView *annotationView = (MKPinAnnotationView *)[self dequeueReusableAnnotationViewWithIdentifier:identifier];
		
		if (annotationView == nil) {
			annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
		} else {
			annotationView.annotation = annotation;
		}
		
		annotationView.enabled = YES;
		annotationView.animatesDrop = YES;
		//		annotationView.canShowCallout = YES;
		
		switch(((TripPointMapAnnotation *)annotation).tripPointType) {
			case THVTripPointTypePickup:
				annotationView.pinTintColor = [MKPinAnnotationView redPinColor];
				break;
			case THVTripPointTypeDropoff:
				annotationView.pinTintColor = [MKPinAnnotationView greenPinColor];
				break;
		}
		
		return annotationView;
	}
	
	return nil;
}

#pragma mark MKPolyline delegate functions
- (MKOverlayRenderer *)tda_rendererForOverlay:(id<MKOverlay>)overlay {
	if ([overlay isKindOfClass:[MKPolyline class]]) {
		MKPolyline *route = overlay;
		MKPolylineRenderer *routeRenderer = [[MKPolylineRenderer alloc] initWithPolyline:route];
		routeRenderer.strokeColor = [UIColor blueColor];
		return routeRenderer;
	}
	else {
		return nil;
	}
}

#pragma mark - MapView operating helper methods
- (void)tda_zoomToSeeRoutes:(NSArray<MKRoute *> *)routes {
	
	MKMapRect boundingRouteRect = MKMapRectWorld;
	
	for (MKRoute *route in routes) {
		boundingRouteRect = route.polyline.boundingMapRect;
	}
	
	MKCoordinateRegion region = MKCoordinateRegionForMapRect(boundingRouteRect);
	
	region.span.latitudeDelta *= 1.2;
	region.span.longitudeDelta *= 1.2;
	
	region = [self regionThatFits:region];
	[self setRegion:region animated:YES];
}

- (void)tda_zoomToSeePickupCoordinate:(CLLocationCoordinate2D)pickupCoordinate dropoffCoordinate:(CLLocationCoordinate2D)dropoffCoordinate
{
	CLLocationCoordinate2D topLeftCoord;
	CLLocationCoordinate2D bottomRightCoord;
	
	topLeftCoord.latitude = fmin(pickupCoordinate.latitude, dropoffCoordinate.latitude);
	topLeftCoord.longitude = fmin(pickupCoordinate.longitude, dropoffCoordinate.longitude);
	
	bottomRightCoord.latitude = fmax(pickupCoordinate.latitude, dropoffCoordinate.latitude);
	bottomRightCoord.longitude = fmax(pickupCoordinate.longitude, dropoffCoordinate.longitude);
	
	MKCoordinateRegion region;
	region.center.latitude = topLeftCoord.latitude - (topLeftCoord.latitude - bottomRightCoord.latitude) * 0.5;
	region.center.longitude = topLeftCoord.longitude + (bottomRightCoord.longitude - topLeftCoord.longitude) * 0.5;
	
	// Add a little extra space on the sides
	region.span.latitudeDelta = fabs(topLeftCoord.latitude - bottomRightCoord.latitude) * 1.2;
	region.span.longitudeDelta = fabs(bottomRightCoord.longitude - topLeftCoord.longitude) * 1.2;
	
	region = [self regionThatFits:region];
	[self setRegion:region animated:YES];
}

- (void)tda_showRouteWithAnnotation:(TripPointMapAnnotation *)annotation directions:(MKDirections * __strong *)directions {
	
	if (directions == NULL) {
		MKDirections *localDirections;
		directions = &localDirections;
	}
	
	TripPointMapAnnotation *relatedAnnotation = annotation.relatedTripPoint;
	
	CLLocationCoordinate2D __block pickupCoordinate = annotation.tripPointType == THVTripPointTypePickup ? annotation.coordinate : relatedAnnotation.coordinate;
	CLLocationCoordinate2D __block dropoffCoordinate = annotation.tripPointType == THVTripPointTypeDropoff ? annotation.coordinate : relatedAnnotation.coordinate;
	
	
	MKDirectionsRequest *directionReuquest = [MKDirectionsRequest new];
	directionReuquest.source = [[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc] initWithCoordinate:pickupCoordinate addressDictionary:nil]];
	directionReuquest.destination = [[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc] initWithCoordinate:dropoffCoordinate addressDictionary:nil]];
	directionReuquest.transportType = MKDirectionsTransportTypeAutomobile;
	[directionReuquest setRequestsAlternateRoutes:NO];
	
	if ([*directions isCalculating]) {
		[*directions cancel];
	}
	
	MKMapView __block *this = self;
	
	*directions = [[MKDirections alloc] initWithRequest:directionReuquest];
	[*directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse * _Nullable response, NSError * _Nullable error) {
		[this removeOverlays:[this overlays]];
		if (!error) {
			NSArray *routes = [response.routes valueForKeyPath:@"polyline"];
			[this addOverlays:routes];
			[this tda_zoomToSeeRoutes:response.routes];
		} else {
			NSLog(@"Could not retrieve route!\n%@\n%@", error.localizedDescription, error.userInfo);
			[this tda_zoomToSeePickupCoordinate:pickupCoordinate dropoffCoordinate:dropoffCoordinate];
		}
	}];
}

- (TripPointMapAnnotation *)addAnnotationsAndReturnPickupWithTripId:(NSString *)entityId pickupCoordinate:(CLLocationCoordinate2D)pickupCoordinate pickupDateTime:(NSDate *)pickupDateTime dropoffCoordinate:(CLLocationCoordinate2D)dropoffCoordinate dropoffDateTime:(NSDate *)dropoffDateTime {
	
	// add pickup pin
	TripPointMapAnnotation *pickupAnnotation = [[TripPointMapAnnotation alloc] initWithTripPointType:THVTripPointTypePickup tripId:entityId coordinate:pickupCoordinate tripPointDateTime:pickupDateTime];
	
	if (![[self annotations] containsObject:pickupAnnotation]) {
		[self addAnnotation:pickupAnnotation];
	}
	
	// add dropoff pin
	TripPointMapAnnotation *dropoffAnnotation = [[TripPointMapAnnotation alloc] initWithTripPointType:THVTripPointTypeDropoff tripId:entityId coordinate:dropoffCoordinate tripPointDateTime:dropoffDateTime];
	
	if (![[self annotations] containsObject:dropoffAnnotation]) {
		[self addAnnotation:dropoffAnnotation];
	}
	
	// set related pins
	pickupAnnotation.relatedTripPoint = dropoffAnnotation;
	dropoffAnnotation.relatedTripPoint = pickupAnnotation;
	
	return pickupAnnotation;
}

@end

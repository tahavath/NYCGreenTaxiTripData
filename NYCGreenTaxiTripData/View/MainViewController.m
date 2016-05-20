//
//  MainViewController.m
//  NYCGreenTaxiTripData
//
//  Created by KRKT on 12/05/16.
//  Copyright © 2016 tahavath. All rights reserved.
//

#import "MainViewController.h"
#import "ModelCoordinator.h"
#import "TripData.h"
#import "TripPointMapAnnotation.h"

double const THVStartingRegionDistance = 2000.0;

@interface MainViewController() {
	MKCoordinateRegion _currentRegion;
	
	CLLocationDegrees _currentRegionCenterLat;
	CLLocationDegrees _currentRegionCenterLong;
	
	CLLocationDegrees _currentRegionSpanLatDelta;
	CLLocationDegrees _currentRegionSpanLongDelta;
}

@property (nonatomic) NSFetchedResultsController *fetchedResultController;
@property (nonatomic) NSFetchRequest *fetchRequest;

@property (nonatomic) NSMutableArray<TripPointMapAnnotation *> *tripsPointPinsArray;

@end

@implementation MainViewController

- (void)viewDidLoad {
	[self setCurrentRegionDataFromRegion:self.mapView.region];
	
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
	
	CLLocationCoordinate2D startingCoord = CLLocationCoordinate2DMake(THVNewYorkLatitude, THVNewYorkLongitude);
	MKCoordinateRegion startingRegion = MKCoordinateRegionMakeWithDistance(startingCoord, THVStartingRegionDistance, THVStartingRegionDistance);
	[self.mapView setRegion:startingRegion];
}

#pragma mark - MKMapViewDelegate methods
- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated {
	[self removeOldMapPins];
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
	[self setCurrentRegionDataFromRegion:mapView.region];
	
	// load date from database for current region
	NSError *fetchError = nil;
	if (![self.fetchedResultController performFetch:&fetchError]) {
		NSLog(@"Failed to load data for region: %@\n%@", [fetchError localizedDescription], [fetchError userInfo]);
	}
	
	[self showNewMapPins];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
	static NSString *identifier = @"TripPoinIdentifier";
	
	if ([annotation isKindOfClass:[TripPointMapAnnotation class]]) {
		MKPinAnnotationView *annotationView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
		
		if (annotationView == nil) {
			annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
		} else {
			annotationView.annotation = annotation;
		}
		
		annotationView.enabled = YES;
		annotationView.animatesDrop = YES;
		annotationView.canShowCallout = YES;
		
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

#pragma mark - MapView operating helper methods
- (void)showNewMapPins {
	NSArray<TripData *> *tripDataArray = self.fetchedResultController.fetchedObjects;
	
	for (TripData *tripData in tripDataArray) {
		// add pickup pin
		TripPointMapAnnotation *pickupAnnotation = [[TripPointMapAnnotation alloc] initWithTripPointType:THVTripPointTypePickup tripId:tripData.entityId coordinate:tripData.pickupCoordinate tripPointDateTime:tripData.pickupDateTime];
		
		if (![self.tripsPointPinsArray containsObject:pickupAnnotation]) {
			[self.mapView addAnnotation:pickupAnnotation];
			[self.tripsPointPinsArray addObject:pickupAnnotation];
		}
		
		// add dropoff pin
		TripPointMapAnnotation *dropoffAnnotation = [[TripPointMapAnnotation alloc] initWithTripPointType:THVTripPointTypeDropoff tripId:tripData.entityId coordinate:tripData.dropoffCoordinate tripPointDateTime:tripData.dropoffDateTime];
		
		if (![self.tripsPointPinsArray containsObject:dropoffAnnotation]) {
			[self.mapView addAnnotation:dropoffAnnotation];
			[self.tripsPointPinsArray addObject:dropoffAnnotation];
		}
	}
}

- (void)removeOldMapPins {
	
}

#pragma mark - helper methods
- (void)setCurrentRegionDataFromRegion:(MKCoordinateRegion)region {
	_currentRegion = region;
	_currentRegionCenterLat = region.center.latitude;
	_currentRegionCenterLong = region.center.longitude;
	_currentRegionSpanLatDelta = region.span.latitudeDelta;
	_currentRegionSpanLongDelta = region.span.longitudeDelta;
	
	NSLog(@"regionDidChangeAnimated: region: center.lat = %f, center.long = %f, delta.lat = %f, delta.long = %f", _currentRegionCenterLat, _currentRegionCenterLong, _currentRegionSpanLatDelta, _currentRegionSpanLongDelta);
	
	self.fetchRequest.predicate = [self currentRegionFetchPredicate];
}

- (NSPredicate *)currentRegionFetchPredicate {
	
	CLLocationDegrees minLatitude = _currentRegionCenterLat - _currentRegionSpanLatDelta;
	CLLocationDegrees maxLatitude = _currentRegionCenterLat + _currentRegionSpanLatDelta;
	CLLocationDegrees minLongitude = _currentRegionCenterLong - _currentRegionSpanLongDelta;
	CLLocationDegrees maxLongitude = _currentRegionCenterLong + _currentRegionSpanLongDelta;
	
	NSPredicate *fetchPredicate = [NSPredicate predicateWithFormat:
								   @"\
								   (pickupLatitude >= %f AND pickupLatitude <= %f AND pickupLongitude >= %f AND pickupLongitude <= %f) \
								   OR \
								   (dropoffLatitude >= %f AND dropoffLatitude <= %f AND dropoffLongitude >= %f AND dropoffLongitude <= %f)",
								   minLatitude, maxLatitude, minLongitude, maxLongitude,
								   minLatitude, maxLatitude, minLongitude, maxLongitude
								   ];
	
	return fetchPredicate;
}

#pragma mark - NSFetchedResultsControllerDelegate methods
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
	NSLog(@"controllerDidChangeContent - fetched count:%lu", (unsigned long)controller.fetchedObjects.count);
	
	[self showNewMapPins];
}

#pragma mark - lazy properties initializers
- (NSFetchedResultsController *)fetchedResultController {
	if (!_fetchedResultController) {
		_fetchedResultController = [[NSFetchedResultsController alloc] initWithFetchRequest:self.fetchRequest managedObjectContext:[[ModelCoordinator sharedInstance] mainQueueContext] sectionNameKeyPath:nil cacheName:nil];
		[_fetchedResultController setDelegate:self];
	}
	
	return _fetchedResultController;
}

- (NSFetchRequest *)fetchRequest {
	if (!_fetchRequest) {
		_fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[TripData entityName]];
		_fetchRequest.predicate = [self currentRegionFetchPredicate];
		_fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"entityId" ascending:YES]];
	}
	
	return _fetchRequest;
}

- (NSMutableArray<TripPointMapAnnotation *>*)tripsPointPinsArray {
	if (!_tripsPointPinsArray) {
		_tripsPointPinsArray = [NSMutableArray array];
	}
	
	return _tripsPointPinsArray;
}

@end

	//
//  MainViewController.m
//  NYCGreenTaxiTripData
//
//  Created by KRKT on 12/05/16.
//  Copyright © 2016 tahavath. All rights reserved.
//

#import "MainViewController.h"
#import "ModelCoordinator.h"
#import "TripPointMapAnnotation.h"
#import "TripsListViewController.h"
#import "TripDetailsViewController.h"
#import "MainScreenTripDetailsViewController.h"

double const THVStartingRegionDistance = 2000.0;

double const THVTripDetailsViewHeight = 100.0;

NSString *const THVShowTripsTableSegueName = @"showTripsTable";
NSString *const THVTripsTableStoryboardId = @"tripsList";
NSString *const THVTripDetailsStoryboardId = @"tripDetails";


@interface MainViewController() {
	MKCoordinateRegion _currentRegion;
	
	CLLocationDegrees _currentRegionCenterLat;
	CLLocationDegrees _currentRegionCenterLong;
	
	CLLocationDegrees _currentRegionSpanLatDelta;
	CLLocationDegrees _currentRegionSpanLongDelta;
}

@property (nonatomic) NSFetchedResultsController *fetchedResultController;
@property (nonatomic) NSFetchRequest *fetchRequest;

@property (nonatomic) MKDirections *directions;

@property (nonatomic) MainScreenTripDetailsViewController *tripDetailsVC;

@end

@implementation MainViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	
	if (![Commons readValueFromUserDefaultsForKey:THVUserDefaultsDownloadOffsetKey]) {
		UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:THVLabelNoTripsToShow preferredStyle:UIAlertControllerStyleAlert];
		UIAlertAction *defaultAction = [UIAlertAction
										actionWithTitle:@"OK"
										style:UIAlertActionStyleDefault
										handler:^(UIAlertAction *action) {
											[self performSegueWithIdentifier:THVShowTripsTableSegueName sender:self];
										}];
		
		[alert addAction:defaultAction];
		
		[self presentViewController:alert animated:YES completion:nil];
	}
	
	CLLocationCoordinate2D startingCoord = CLLocationCoordinate2DMake(THVNewYorkLatitude, THVNewYorkLongitude);
	MKCoordinateRegion startingRegion = MKCoordinateRegionMakeWithDistance(startingCoord, THVStartingRegionDistance, THVStartingRegionDistance);
	[self.mapView setRegion:startingRegion];
}

- (void)viewWillAppear:(BOOL)animated {
	if ([Commons selectedTrip] && ([Commons selectedTrip] != [Commons previouslySelectedTrip])) {
		// remove previous route
		if ([Commons previouslySelectedTrip]) {
			[self.mapView removeOverlays:[self.mapView overlays]];
		}
		
		// select new trip
		NSUInteger annotationIndex = [self.mapView.annotations indexOfObjectPassingTest:^BOOL(id<MKAnnotation>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
			return [((TripPointMapAnnotation *)obj).tripId isEqualToString:[Commons selectedTrip].entityId];
		}];
		
		TripPointMapAnnotation *pickupAnnotation = nil;
		
		if (annotationIndex == NSNotFound) {
			pickupAnnotation =
			[self.mapView addAnnotationsAndReturnPickupWithTripId:[Commons selectedTrip].entityId pickupCoordinate:[Commons selectedTrip].pickupCoordinate pickupDateTime:[Commons selectedTrip].pickupDateTime dropoffCoordinate:[Commons selectedTrip].dropoffCoordinate dropoffDateTime:[Commons selectedTrip].dropoffDateTime];
		} else {
			pickupAnnotation = [self.mapView.annotations objectAtIndex:annotationIndex];
		}
		
		[self.mapView selectAnnotation:pickupAnnotation animated:YES];
	}
	[super viewWillAppear:animated];
}

#pragma mark - MKMapViewDelegate methods
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
	return [mapView tda_viewForAnnotation:annotation];
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
	if ([view.annotation isKindOfClass:[TripPointMapAnnotation class]]) {
		[Commons setPreviouslySelectedTrip:[Commons selectedTrip]];
		
		[Commons setSelectedTrip:[self retrieveSelectedTripWithEntityId:((TripPointMapAnnotation *)view.annotation).tripId]];
		
		[self showTripDetailsViewWithTripData:[Commons selectedTrip]];
		[mapView tda_showRouteWithAnnotation:view.annotation directions:&_directions];
	}
}

- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view {
	if ([view.annotation isKindOfClass:[TripPointMapAnnotation class]]) {
		
		if ([self.directions isCalculating]) {
			[self.directions cancel];
		}
		[mapView removeOverlays:[mapView overlays]];
		
		[self hideTripDetailsView];

		[Commons setPreviouslySelectedTrip:[Commons selectedTrip]];
		[Commons setSelectedTrip:nil];
	}
}

#pragma mark - MKPolyline delegate functions
- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {
	return [mapView tda_rendererForOverlay:overlay];
}

#pragma mark - MapView operating helper methods
- (void)showNewMapPins {
	NSArray<TripData *> *tripDataArray = self.fetchedResultController.fetchedObjects;
	
	for (TripData *tripData in tripDataArray) {
		[self.mapView addAnnotationsAndReturnPickupWithTripId:tripData.entityId pickupCoordinate:tripData.pickupCoordinate pickupDateTime:tripData.pickupDateTime dropoffCoordinate:tripData.dropoffCoordinate dropoffDateTime:tripData.dropoffDateTime];
	}
}

#pragma mark - Trip details view methods
- (void)showTripDetailsViewWithTripData:(TripData *)tripData {
	
	[self addChildViewController:self.tripDetailsVC];
	[self.tripDetailsView addSubview:self.tripDetailsVC.view];
	
	[self.tripDetailsView setTranslatesAutoresizingMaskIntoConstraints:NO];
	[self.tripDetailsVC.view setTranslatesAutoresizingMaskIntoConstraints:NO];
	NSDictionary *viewsDictionary = [NSDictionary dictionaryWithObjectsAndKeys:self.tripDetailsView, @"mainView", self.tripDetailsVC.view, @"tripView", nil];
	
	[self.tripDetailsView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[tripView]|" options:0 metrics:nil views:viewsDictionary]];
	[self.tripDetailsView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[tripView]|" options:0 metrics:nil views:viewsDictionary]];
	
	self.tripDetailsHeightConstraint.constant = THVTripDetailsViewHeight;
	[self.view setNeedsUpdateConstraints];
	
	[UIView animateWithDuration:0.2 animations:^{
		[self.view layoutIfNeeded];
	}];
}

- (void)hideTripDetailsView {
	
	self.tripDetailsHeightConstraint.constant = 0;
	[self.view setNeedsUpdateConstraints];
	
	[UIView animateWithDuration:0.2 animations:^{
		[self.view layoutIfNeeded];
	}];
	
	[self.tripDetailsVC removeFromParentViewController];
	[self.tripDetailsVC.view removeFromSuperview];
	self.tripDetailsVC = nil;
}

#pragma mark - helper methods
- (void)setCurrentRegionDataFromRegion:(MKCoordinateRegion)region {
	_currentRegion = region;
	_currentRegionCenterLat = region.center.latitude;
	_currentRegionCenterLong = region.center.longitude;
	_currentRegionSpanLatDelta = region.span.latitudeDelta;
	_currentRegionSpanLongDelta = region.span.longitudeDelta;
	
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

- (TripData *)retrieveSelectedTripWithEntityId:(NSString *)selectedTripEntityId {
	NSFetchRequest *selectedTripFetchRequest = [NSFetchRequest fetchRequestWithEntityName:[TripData entityName]];
	selectedTripFetchRequest.predicate = [NSPredicate predicateWithFormat:@"entityId = %@", selectedTripEntityId];
	
	NSError *error = nil;
	NSArray<TripData *> *fetchedTrips = [[[ModelCoordinator sharedInstance] mainQueueContext] executeFetchRequest:selectedTripFetchRequest error:&error];
	
	if (error) {
		NSLog(@"Could not retrieve selected trip entity!\n%@\n%@", error.localizedDescription, error.userInfo);
		return nil;
	} else {
		return fetchedTrips.firstObject;
	}
}

- (NSString *)pickupStringFromSelectedTrip {
	NSString *pickupString = [NSString stringWithFormat:
							  @"%.4f° %@\n%.4f° %@",
							  fabs([[Commons selectedTrip].pickupLongitude doubleValue]),
							  ([Commons selectedTrip].pickupLongitude > 0 ? @"N" : @"S"),
							  fabs([[Commons selectedTrip].pickupLatitude doubleValue]),
							  ([Commons selectedTrip].pickupLatitude > 0 ? @"E" : @"W")
							  ];
	return pickupString;
}

- (NSString *)dropoffStringFromSelectedTrip {
	NSString *dropoffString = [NSString stringWithFormat:
								  @"%.4f° %@\n%.4f° %@",
								  fabs([[Commons selectedTrip].dropoffLongitude doubleValue]),
								  ([Commons selectedTrip].dropoffLongitude > 0 ? @"N" : @"S"),
								  fabs([[Commons selectedTrip].dropoffLatitude doubleValue]),
								  ([Commons selectedTrip].dropoffLatitude > 0 ? @"E" : @"W")
								  ];
	return dropoffString;
}

- (NSString *)additionalInfoFromSelectedTrip {
	NSString *additionalInfo = [NSString stringWithFormat:
								@"%.f %@ · %.0f minutes",
								[[Commons selectedTrip].tripDistance doubleValue],
								[[Commons selectedTrip].tripDistance floatValue] <= 1 ? @"mile" : @"miles",
								[[Commons selectedTrip].dropoffDateTime timeIntervalSinceDate:[Commons selectedTrip].pickupDateTime] / 60.0];
	return additionalInfo;
}

#pragma mark - NSFetchedResultsControllerDelegate methods
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
	NSLog(@"controllerDidChangeContent - fetched count:%lu", (unsigned long)controller.fetchedObjects.count);
	
	[self showNewMapPins];
}

#pragma mark - MainScreenTripDetailsDelegateProtocol methods
- (void)goToTripDetails {
	UINavigationController *navigationController = self.navigationController;
	
	TripsListViewController *newTripsListVC = [self.storyboard instantiateViewControllerWithIdentifier:THVTripsTableStoryboardId];
	[navigationController pushViewController:newTripsListVC animated:NO];
	
	TripDetailsViewController *newTripDetailsVC = [self.storyboard instantiateViewControllerWithIdentifier:THVTripDetailsStoryboardId];
	[navigationController pushViewController:newTripDetailsVC animated:YES];
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

- (MainScreenTripDetailsViewController *)tripDetailsVC {
	if (!_tripDetailsVC) {
		_tripDetailsVC = [[MainScreenTripDetailsViewController alloc]
						  initWithPickupString:[self pickupStringFromSelectedTrip]
						  dropoffString:[self dropoffStringFromSelectedTrip]
						  additionalInfoString:[self additionalInfoFromSelectedTrip]
						  delegate:self
						  ];
	}
	
	return _tripDetailsVC;
}

@end

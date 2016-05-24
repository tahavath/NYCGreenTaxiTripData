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
double const THVPinScaleWhenSelected = 1.1;
double const THVPinScaleNormal = 1.0;

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
	NSLog(@"viewDidLoad");
	
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
	if (self.selectedTripEntity) {
		NSUInteger annotationIndex = [self.mapView.annotations indexOfObjectPassingTest:^BOOL(id<MKAnnotation>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
			return [((TripPointMapAnnotation *)obj).tripId isEqualToString:self.selectedTripEntity.entityId];
		}];
		
		TripPointMapAnnotation *pickupAnnotation = nil;
		
		if (annotationIndex == NSNotFound) {
			pickupAnnotation = [self addAnnotationsAndReturnPickupWithTripData:self.selectedTripEntity];
		} else {
			pickupAnnotation = [self.mapView.annotations objectAtIndex:annotationIndex];
		}
		
		[self.mapView selectAnnotation:pickupAnnotation animated:YES];
	}
	[super viewWillAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
	for (id<MKAnnotation> annotation in self.mapView.annotations) {
		[self.mapView deselectAnnotation:annotation animated:NO];
	}
	[super viewDidDisappear:animated];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if ([segue.identifier isEqualToString:THVShowTripsTableSegueName]) {
		((TripsListViewController *)segue.destinationViewController).selectedTrip = self.selectedTripEntity;
	}
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

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
	if ([view.annotation isKindOfClass:[TripPointMapAnnotation class]]) {
		self.selectedTripEntity = [self retrieveSelectedTripWithEntityId:((TripPointMapAnnotation *)view.annotation).tripId];
		[self showTripDetailsViewWithTripData:self.selectedTripEntity];
		[self showRouteWithAnnotation:view.annotation];
	}
}

- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view {
	if ([view.annotation isKindOfClass:[TripPointMapAnnotation class]]) {
		view.transform = CGAffineTransformMakeScale(THVPinScaleNormal, THVPinScaleNormal);
		[view setHighlighted:NO];
		
		MKAnnotationView *relatedAnnotationView = [mapView viewForAnnotation:((TripPointMapAnnotation *)view.annotation).relatedTripPoint];
		relatedAnnotationView.transform = CGAffineTransformMakeScale(THVPinScaleNormal, THVPinScaleNormal);
		[relatedAnnotationView setHighlighted:NO];
		
		if ([self.directions isCalculating]) {
			[self.directions cancel];
		}
		[mapView removeOverlays:[mapView overlays]];
		
		[self hideTripDetailsView];
		
		self.selectedTripEntity = nil;
	}
}

#pragma mark MKPolyline delegate functions
- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {
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
- (void)showNewMapPins {
	NSArray<TripData *> *tripDataArray = self.fetchedResultController.fetchedObjects;
	
	for (TripData *tripData in tripDataArray) {
		[self addAnnotationsAndReturnPickupWithTripData:tripData];
	}
}

- (void)zoomMap:(MKMapView *)mapView toSeeRoutes:(NSArray<MKRoute *> *)routes {
	
	MKMapRect boundingRouteRect = MKMapRectWorld;
	
	for (MKRoute *route in routes) {
		boundingRouteRect = route.polyline.boundingMapRect;
	}
	
	MKCoordinateRegion region = MKCoordinateRegionForMapRect(boundingRouteRect);
	
	region.span.latitudeDelta *= 1.2;
	region.span.longitudeDelta *= 1.2;
	
	region = [mapView regionThatFits:region];
	[mapView setRegion:region animated:YES];
}

- (void)zoomMap:(MKMapView *)mapView toSeePickupCoordinate:(CLLocationCoordinate2D)pickupCoordinate dropoffCoordinate:(CLLocationCoordinate2D)dropoffCoordinate
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
	
	region = [mapView regionThatFits:region];
	[mapView setRegion:region animated:YES];
}

- (void)showRouteWithAnnotation:(TripPointMapAnnotation *)annotation {
	
	MKAnnotationView *annotationView = [self.mapView viewForAnnotation:annotation];
	annotationView.transform = CGAffineTransformMakeScale(THVPinScaleWhenSelected, THVPinScaleWhenSelected);
	[annotationView setHighlighted:YES];
	
	
	TripPointMapAnnotation *relatedAnnotation = annotation.relatedTripPoint;
	MKAnnotationView *relatedAnnotationView = [self.mapView viewForAnnotation:relatedAnnotation];
	relatedAnnotationView.transform = CGAffineTransformMakeScale(THVPinScaleWhenSelected, THVPinScaleWhenSelected);
	[relatedAnnotationView setHighlighted:YES];
	
	CLLocationCoordinate2D __block pickupCoordinate = annotation.tripPointType == THVTripPointTypePickup ? annotation.coordinate : relatedAnnotation.coordinate;
	CLLocationCoordinate2D __block dropoffCoordinate = annotation.tripPointType == THVTripPointTypeDropoff ? annotation.coordinate : relatedAnnotation.coordinate;
	
	
	MKDirectionsRequest *directionReuquest = [MKDirectionsRequest new];
	directionReuquest.source = [[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc] initWithCoordinate:pickupCoordinate addressDictionary:nil]];
	directionReuquest.destination = [[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc] initWithCoordinate:dropoffCoordinate addressDictionary:nil]];
	directionReuquest.transportType = MKDirectionsTransportTypeAutomobile;
	[directionReuquest setRequestsAlternateRoutes:NO];
	
	if ([self.directions isCalculating]) {
		[self.directions cancel];
	}
	
	MainViewController __block *this = self;
	
	self.directions = [[MKDirections alloc] initWithRequest:directionReuquest];
	[self.directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse * _Nullable response, NSError * _Nullable error) {
		[this.mapView removeOverlays:[this.mapView overlays]];
		if (!error) {
			NSArray *routes = [response.routes valueForKeyPath:@"polyline"];
			[this.mapView addOverlays:routes];
			[this zoomMap:this.mapView toSeeRoutes:response.routes];
		} else {
			NSLog(@"Could not retrieve route!\n%@\n%@", error.localizedDescription, error.userInfo);
			[this zoomMap:this.mapView toSeePickupCoordinate:pickupCoordinate dropoffCoordinate:dropoffCoordinate];
		}
	}];
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

- (TripPointMapAnnotation *)addAnnotationsAndReturnPickupWithTripData:(TripData *)tripData {
	
	// add pickup pin
	TripPointMapAnnotation *pickupAnnotation = [[TripPointMapAnnotation alloc] initWithTripPointType:THVTripPointTypePickup tripId:tripData.entityId coordinate:tripData.pickupCoordinate tripPointDateTime:tripData.pickupDateTime];
	
	if (![[self.mapView annotations] containsObject:pickupAnnotation]) {
		[self.mapView addAnnotation:pickupAnnotation];
	}
	
	// add dropoff pin
	TripPointMapAnnotation *dropoffAnnotation = [[TripPointMapAnnotation alloc] initWithTripPointType:THVTripPointTypeDropoff tripId:tripData.entityId coordinate:tripData.dropoffCoordinate tripPointDateTime:tripData.dropoffDateTime];
	
	if (![[self.mapView annotations] containsObject:dropoffAnnotation]) {
		[self.mapView addAnnotation:dropoffAnnotation];
	}
	
	// set related pins
	pickupAnnotation.relatedTripPoint = dropoffAnnotation;
	dropoffAnnotation.relatedTripPoint = pickupAnnotation;
	
	return pickupAnnotation;
}

- (NSString *)pickupStringFromSelectedTrip {
	NSString *pickupString = [NSString stringWithFormat:
							  @"%.4f° %@\n%.4f° %@",
							  fabs([self.selectedTripEntity.pickupLongitude doubleValue]),
							  (self.selectedTripEntity.pickupLongitude > 0 ? @"N" : @"S"),
							  fabs([self.selectedTripEntity.pickupLatitude doubleValue]),
							  (self.selectedTripEntity.pickupLatitude > 0 ? @"E" : @"W")
							  ];
	return pickupString;
}

- (NSString *)dropoffStringFromSelectedTrip {
	NSString *dropoffString = [NSString stringWithFormat:
								  @"%.4f° %@\n%.4f° %@",
								  fabs([self.selectedTripEntity.dropoffLongitude doubleValue]),
								  (self.selectedTripEntity.dropoffLongitude > 0 ? @"N" : @"S"),
								  fabs([self.selectedTripEntity.dropoffLatitude doubleValue]),
								  (self.selectedTripEntity.dropoffLatitude > 0 ? @"E" : @"W")
								  ];
	return dropoffString;
}

- (NSString *)additionalInfoFromSelectedTrip {
	NSString *additionalInfo = [NSString stringWithFormat:
								@"%.f %@ · %.0f minutes",
								[self.selectedTripEntity.tripDistance doubleValue],
								[self.selectedTripEntity.tripDistance floatValue] <= 1 ? @"mile" : @"miles",
								[self.selectedTripEntity.dropoffDateTime timeIntervalSinceDate:self.selectedTripEntity.pickupDateTime] / 60.0];
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
	newTripsListVC.selectedTrip = self.selectedTripEntity;
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
